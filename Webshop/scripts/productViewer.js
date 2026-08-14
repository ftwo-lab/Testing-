var productState = {
    data: null,
    search: '',
    filledOnly: true,
    customOnly: false,
    collapsed: {},
    tab: 'overview',
    shopSearch: '',
    category: '',
    qty: 1
};

function SetProductData(jsonData) {
    try {
        productState.data = typeof jsonData === 'string' ? JSON.parse(jsonData) : jsonData;
        productState.collapsed = {};
        productState.search = '';
        productState.tab = 'overview';
        productState.qty = 1;
        renderApp();
    } catch (err) {
        renderMessage('Could not read product data', err.message || String(err));
    }
}

function invokeNav(methodName, args) {
    if (window.Microsoft && Microsoft.Dynamics && Microsoft.Dynamics.NAV)
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(methodName, args || []);
}

function renderApp() {
    document.documentElement.style.overflowY = 'auto';
    document.body.style.overflowY = 'auto';
    var host = document.getElementById('controlAddIn');
    if (host)
        host.style.overflowY = 'auto';

    var data = productState.data;
    if (!data) {
        renderMessage('Product Webshop', 'Loading…');
        return;
    }
    if (data.view === 'catalog') {
        renderCatalog(data);
        return;
    }
    renderProductPage(data);
}

function renderMessage(title, detail) {
    document.body.innerHTML = '';
    var root = document.createElement('div');
    root.id = 'pvc-root';
    root.innerHTML = '<div class="pvc-empty"><h2>' + escapeHtml(title) + '</h2><p>' + escapeHtml(detail || '') + '</p></div>';
    document.body.appendChild(root);
}

function renderCatalog(data) {
    var products = (data.products || []).filter(function (p) {
        var q = (productState.shopSearch || '').toLowerCase();
        var catOk = !productState.category || p.itemCategory === productState.category || p.categoryName === productState.category;
        var text = [p.no, p.description, p.description2, p.categoryName].join(' ').toLowerCase();
        return catOk && (!q || text.indexOf(q) >= 0);
    });
    var categories = unique(data.products || [], 'categoryName');

    document.body.innerHTML = '';
    var root = document.createElement('div');
    root.id = 'pvc-root';
    document.body.appendChild(root);
    root.appendChild(shopHeader(data.shopName || 'Store', true));

    var wrap = document.createElement('div');
    wrap.className = 'shop-wrap';
    wrap.innerHTML = '<div class="shop-hero-copy"><h1>Products</h1><p>Business Central items shown in a Shopify-style storefront.</p></div>';

    var filters = document.createElement('div');
    filters.className = 'chips';
    filters.appendChild(filterChip('All', '', productState.category === ''));
    categories.forEach(function (cat) {
        if (cat)
            filters.appendChild(filterChip(cat, cat, productState.category === cat));
    });
    wrap.appendChild(filters);

    var grid = document.createElement('div');
    grid.className = 'product-grid';
    if (!products.length) {
        wrap.appendChild(note('No products match this search.'));
    } else {
        products.forEach(function (p) { grid.appendChild(productCard(p)); });
        wrap.appendChild(grid);
    }
    root.appendChild(wrap);
    bindShopSearch();
}

function productCard(p) {
    var card = document.createElement('article');
    card.className = 'product-card';
    card.onclick = function () { invokeNav('ProductSelected', [p.no]); };
    var thumb = document.createElement('div');
    thumb.className = 'thumb';
    if (p.picture) {
        var img = document.createElement('img');
        img.alt = p.description || p.no;
        img.src = p.picture;
        thumb.appendChild(img);
    } else {
        thumb.innerHTML = '<div class="pdp-photo-fallback">' + escapeHtml(p.no) + '</div>';
    }
    if (!(Number(p.inventoryValue) > 0))
        thumb.insertAdjacentHTML('beforeend', '<span class="soldout">Sold out</span>');
    card.appendChild(thumb);
    card.insertAdjacentHTML(
        'beforeend',
        '<div class="body">' +
            '<div class="cat">' + escapeHtml(p.categoryName || p.type || '') + '</div>' +
            '<h3>' + escapeHtml(p.description || p.no) + '</h3>' +
            '<div class="price">' + escapeHtml(displayVal(p.unitPrice)) + '</div>' +
        '</div>'
    );
    return card;
}

function filterChip(label, value, active) {
    var el = document.createElement('button');
    el.className = 'chip' + (active ? ' accent' : '');
    el.textContent = label;
    el.onclick = function () {
        productState.category = value;
        renderCatalog(productState.data);
    };
    return el;
}

function shopHeader(name, withSearch) {
    var top = document.createElement('div');
    top.className = 'shop-top';
    top.innerHTML = '<div class="shop-brand">' + escapeHtml(name || 'Store') + '</div>';
    if (withSearch) {
        var input = document.createElement('input');
        input.id = 'shop-search';
        input.placeholder = 'Search';
        top.appendChild(input);
    }
    return top;
}

function bindShopSearch() {
    var search = document.getElementById('shop-search');
    if (!search)
        return;
    search.value = productState.shopSearch;
    search.addEventListener('input', function (e) {
        productState.shopSearch = e.target.value;
        renderCatalog(productState.data);
        var next = document.getElementById('shop-search');
        if (next) {
            next.focus();
            next.setSelectionRange(productState.shopSearch.length, productState.shopSearch.length);
        }
    });
}

function renderProductPage(data) {
    var h = data.header || {};
    if (!h.no) {
        renderMessage('No product selected', 'Open Product Webshop or use View in Webshop on an item.');
        return;
    }

    document.body.innerHTML = '';
    var root = document.createElement('div');
    root.id = 'pvc-root';
    document.body.appendChild(root);
    root.appendChild(shopHeader(data.shopName || 'Store', false));

    var wrap = document.createElement('div');
    wrap.className = 'shop-wrap';
    var crumb = document.createElement('div');
    crumb.className = 'crumb';
    if (data.showBack) {
        crumb.innerHTML = '<button type="button">Home</button> / ' + escapeHtml(h.categoryName || h.itemCategory || 'Products') + ' / ' + escapeHtml(h.description || h.no);
        crumb.querySelector('button').onclick = function () { invokeNav('BackToCatalog', []); };
    } else {
        crumb.textContent = (h.categoryName || h.itemCategory || 'Products') + ' / ' + (h.description || h.no);
    }
    wrap.appendChild(crumb);
    wrap.appendChild(renderPdp(h, data));
    wrap.appendChild(renderTabs());

    if (productState.tab === 'overview')
        wrap.appendChild(renderOverview(data));
    else if (productState.tab === 'specs')
        wrap.appendChild(renderSpecs(data));
    else
        renderAllData(wrap, data);

    root.appendChild(wrap);
}

function renderPdp(h, data) {
    var pdp = document.createElement('section');
    pdp.className = 'pdp';
    var photo = document.createElement('div');
    photo.className = 'pdp-photo';
    if (h.picture) {
        var img = document.createElement('img');
        img.alt = h.description || h.no;
        img.src = h.picture;
        photo.appendChild(img);
    } else {
        photo.innerHTML = '<div class="pdp-photo-fallback">No product image</div>';
    }

    var inStock = Number(h.inventoryValue) > 0;
    var vendor = h.vendorName || h.vendorNo || '';
    var info = document.createElement('div');
    info.innerHTML =
        (vendor ? '<p class="pdp-vendor">' + escapeHtml(vendor) + '</p>' : '') +
        '<h1>' + escapeHtml(h.description || h.no) + '</h1>' +
        '<div class="pdp-price">' + escapeHtml(displayVal(h.unitPrice)) + '</div>' +
        '<p class="pdp-tax">Tax included.</p>' +
        '<p class="pdp-sku">SKU: ' + escapeHtml(h.no) +
            (h.commonItemNo ? ' · Barcode: ' + escapeHtml(h.commonItemNo) : '') +
            (h.baseUom ? ' · ' + escapeHtml(h.baseUom) : '') +
        '</p>';

    var chips = document.createElement('div');
    chips.className = 'chips';
    chips.appendChild(chip(inStock ? 'In stock' : 'Sold out', inStock ? '' : 'danger'));
    if (h.categoryName || h.itemCategory)
        chips.appendChild(chip(h.categoryName || h.itemCategory));
    if (h.type)
        chips.appendChild(chip(h.type));
    info.appendChild(chips);

    var qty = document.createElement('div');
    qty.className = 'qty';
    qty.innerHTML = '<button type="button" id="qty-minus">−</button><span>' + productState.qty + '</span><button type="button" id="qty-plus">+</button>';
    info.appendChild(qty);

    var add = document.createElement('button');
    add.className = 'btn primary';
    add.textContent = inStock ? 'Add to cart' : 'Sold out';
    add.disabled = !inStock;
    add.onclick = function () { invokeNav('OpenItemCard', [h.no]); };
    var buy = document.createElement('button');
    buy.className = 'btn ghost';
    buy.textContent = 'Open Item Card';
    buy.onclick = function () { invokeNav('OpenItemCard', [h.no]); };
    info.appendChild(add);
    info.appendChild(buy);

    if (h.longDescription || h.description2)
        info.insertAdjacentHTML('beforeend', '<div class="pdp-desc">' + escapeHtml(h.longDescription || h.description2) + '</div>');

    pdp.appendChild(photo);
    pdp.appendChild(info);

    setTimeout(function () {
        var minus = document.getElementById('qty-minus');
        var plus = document.getElementById('qty-plus');
        if (minus)
            minus.onclick = function () {
                productState.qty = Math.max(1, productState.qty - 1);
                renderApp();
            };
        if (plus)
            plus.onclick = function () {
                productState.qty += 1;
                renderApp();
            };
    }, 0);

    return pdp;
}

function renderTabs() {
    var tabs = document.createElement('div');
    tabs.className = 'tabs';
    tabs.appendChild(tabBtn('Description', 'overview'));
    tabs.appendChild(tabBtn('Specifications', 'specs'));
    tabs.appendChild(tabBtn('All Business Central data', 'all'));
    return tabs;
}

function tabBtn(label, id) {
    var btn = document.createElement('button');
    btn.className = 'tab' + (productState.tab === id ? ' active' : '');
    btn.textContent = label;
    btn.onclick = function () {
        productState.tab = id;
        renderApp();
    };
    return btn;
}

function shopifyRows(data) {
    var h = data.header || {};
    var variants = (data.related && data.related.variants) || [];
    var attrs = (data.related && data.related.attributes) || [];
    var handle = String(h.description || h.no || '').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
    var status = h.blocked ? 'draft' : 'active';
    var rows = [
        ['title', 'Item.Description', h.description],
        ['handle', 'From description / No.', handle],
        ['vendor', 'Vendor Name / Vendor No.', h.vendorName || h.vendorNo],
        ['product_type', 'Item Category', h.categoryName || h.itemCategory],
        ['status', 'Blocked → draft, else active', status],
        ['body_html', 'Extended text / Description 2', h.longDescription || h.description2],
        ['variants[0].sku', 'Item No.', h.no],
        ['variants[0].barcode', 'Common Item No.', h.commonItemNo],
        ['variants[0].price', 'Unit Price', h.unitPrice],
        ['variants[0].inventory_quantity', 'Inventory', h.inventory],
        ['variants[0].option1', 'Base UOM', h.baseUom],
        ['images[0].src', 'Item Picture', h.picture ? 'Product image' : ''],
        ['options', 'Item Variants', variants.length ? variants.map(function (v) { return v.code; }).join(', ') : 'Default Title']
    ];
    attrs.forEach(function (a) {
        rows.push(['metafields.' + (a.name || 'attribute'), 'Item Attribute', a.value]);
    });
    (data.groups || []).forEach(function (g) {
        if (g.name !== 'Custom Fields' && g.name !== 'Extension Fields')
            return;
        (g.fields || []).forEach(function (f) {
            if (!isEmptyValue(f.value))
                rows.push(['metafields.custom.' + (f.name || f.caption), f.caption || f.name, f.value]);
        });
    });
    return rows;
}

function renderOverview(data) {
    var wrap = document.createElement('div');
    var desc = document.createElement('section');
    desc.className = 'panel';
    desc.innerHTML = '<header><h3>Description</h3></header>';
    var body = (data.header && (data.header.longDescription || data.header.description2 || data.header.description)) || '';
    desc.insertAdjacentHTML('beforeend', '<p class="pdp-desc">' + escapeHtml(body) + '</p>');
    wrap.appendChild(desc);

    var map = document.createElement('section');
    map.className = 'panel';
    map.innerHTML = '<header><h3>How this looks on Shopify</h3></header>';
    map.insertAdjacentHTML('beforeend', '<div class="map-note">If this Business Central item is sent to Shopify, Shopify stores it as one product with variants, images, and metafields. This table is that mapping.</div>');
    var rows = shopifyRows(data).map(function (r) {
        return '<tr><td>' + escapeHtml(r[0]) + '</td><td>' + escapeHtml(r[1]) + '</td><td>' + escapeHtml(displayVal(r[2])) + '</td></tr>';
    }).join('');
    map.insertAdjacentHTML(
        'beforeend',
        '<div class="table-wrap"><table class="shop-table"><thead><tr><th>Shopify field</th><th>Business Central source</th><th>Value</th></tr></thead><tbody>' +
            rows + '</tbody></table></div>'
    );
    wrap.appendChild(map);

    var details = document.createElement('section');
    details.className = 'panel';
    details.innerHTML = '<header><h3>Product details</h3></header>';
    var attrs = (data.related && data.related.attributes) || [];
    var html = '<div class="attr-list">';
    html += attrRow('Item No. / SKU', data.header.no);
    html += attrRow('Title', data.header.description);
    html += attrRow('Vendor', data.header.vendorName || data.header.vendorNo);
    html += attrRow('Product type', data.header.categoryName || data.header.itemCategory);
    html += attrRow('Price', data.header.unitPrice);
    html += attrRow('Inventory', data.header.inventory);
    html += attrRow('UOM', data.header.baseUom);
    attrs.forEach(function (a) { html += attrRow(a.name, a.value); });
    html += '</div>';
    details.insertAdjacentHTML('beforeend', html);
    wrap.appendChild(details);
    return wrap;
}

function attrRow(name, value) {
    return '<div><dt>' + escapeHtml(displayVal(name)) + '</dt><dd>' + escapeHtml(displayVal(value)) + '</dd></div>';
}

function renderSpecs(data) {
    var panel = document.createElement('section');
    panel.className = 'panel';
    panel.innerHTML = '<header><h3>Specifications</h3></header>';
    var filled = [];
    (data.groups || []).forEach(function (g) {
        (g.fields || []).forEach(function (f) {
            if (!isEmptyValue(f.value))
                filled.push(f);
        });
    });
    var wrap = document.createElement('div');
    wrap.className = 'table-wrap';
    var rows = filled.map(function (f) {
        return '<tr><td>' + escapeHtml(f.caption || f.name) + '</td><td>' + escapeHtml(f.value) + '</td><td>' + escapeHtml(f.source || '') + '</td></tr>';
    }).join('');
    wrap.innerHTML = '<table class="shop-table"><thead><tr><th>Field</th><th>Value</th><th>Source</th></tr></thead><tbody>' +
        (rows || '<tr><td colspan="3">No filled fields</td></tr>') + '</tbody></table>';
    panel.appendChild(wrap);
    return panel;
}

function renderAllData(root, data) {
    var bar = document.createElement('div');
    bar.className = 'toolbar';
    var search = document.createElement('input');
    search.className = 'pvc-search';
    search.placeholder = 'Search every field…';
    search.value = productState.search;
    search.addEventListener('input', function (e) {
        productState.search = e.target.value;
        var y = window.scrollY || 0;
        renderApp();
        var next = document.querySelector('.pvc-search');
        if (next) {
            next.focus();
            next.setSelectionRange(productState.search.length, productState.search.length);
        }
        window.scrollTo(0, y);
    });
    bar.appendChild(search);
    bar.appendChild(toggleBtn('Hide empty', 'filledOnly'));
    bar.appendChild(toggleBtn('Custom fields only', 'customOnly'));
    root.appendChild(bar);

    var visible = 0;
    (data.groups || []).forEach(function (group) {
        var fields = filterFields(group.fields || []);
        if (!fields.length)
            return;
        visible += 1;
        root.appendChild(renderGroup(group.name, fields));
    });
    if (!visible)
        root.appendChild(note('No fields match the current search or filters.'));

    var related = data.related || {};
    root.appendChild(renderRelated('Attributes', related.attributes, ['name', 'value']));
    root.appendChild(renderRelated('Variants', related.variants, ['code', 'description', 'blocked']));
    root.appendChild(renderRelated('Units of Measure', related.unitsOfMeasure, ['code', 'qtyPerUnit', 'description']));
    root.appendChild(renderRelated('Item References', related.references, ['referenceNo', 'referenceType', 'description', 'variantCode']));
    root.appendChild(renderRelated('Translations', related.translations, ['languageCode', 'description', 'description2']));
    root.appendChild(renderRelated('Inventory by Location', related.inventoryByLocation, ['locationCode', 'locationName', 'inventory']));
    root.appendChild(renderRelated('Stockkeeping Units', related.stockkeepingUnits, ['locationCode', 'variantCode', 'replenishmentSystem', 'vendorNo']));
    root.appendChild(renderRelated('Default Dimensions', related.dimensions, ['dimensionCode', 'dimensionValueCode', 'valuePosting']));
    root.appendChild(renderRelated('Extended Texts', related.extendedTexts, ['languageCode', 'textNo', 'description']));
}

function toggleBtn(label, key) {
    var btn = document.createElement('button');
    btn.className = 'toggle' + (productState[key] ? ' active' : '');
    btn.textContent = label;
    btn.onclick = function () {
        productState[key] = !productState[key];
        renderApp();
    };
    return btn;
}

function renderGroup(name, fields) {
    var section = document.createElement('section');
    section.className = 'panel';
    var header = document.createElement('header');
    header.innerHTML = '<h3>' + escapeHtml(name) + '</h3><span>' + fields.length + ' fields</span>';
    header.onclick = function () {
        productState.collapsed[name] = !productState.collapsed[name];
        renderApp();
    };
    section.appendChild(header);
    if (productState.collapsed[name])
        return section;
    var grid = document.createElement('div');
    grid.className = 'grid';
    fields.forEach(function (field) {
        var card = document.createElement('article');
        card.className = 'field' + (field.source === 'Custom' || field.source === 'Extension' ? ' custom' : '');
        card.innerHTML =
            '<div class="caption">' + escapeHtml(field.caption || field.name) + '</div>' +
            '<div class="value">' + escapeHtml(field.value || '—') + '</div>' +
            '<div class="meta">' + escapeHtml((field.name || '') + ' · #' + field.fieldNo + ' · ' + (field.source || 'Standard')) + '</div>';
        grid.appendChild(card);
    });
    section.appendChild(grid);
    return section;
}

function renderRelated(title, rows, columns) {
    var section = document.createElement('section');
    section.className = 'panel';
    var list = rows || [];
    var header = document.createElement('header');
    header.innerHTML = '<h3>' + escapeHtml(title) + '</h3><span>' + list.length + '</span>';
    var key = 'rel:' + title;
    header.onclick = function () {
        productState.collapsed[key] = !productState.collapsed[key];
        renderApp();
    };
    section.appendChild(header);
    if (productState.collapsed[key])
        return section;
    if (!list.length) {
        section.appendChild(note('No ' + title.toLowerCase() + ' for this product.'));
        return section;
    }
    var wrap = document.createElement('div');
    wrap.className = 'table-wrap';
    var table = document.createElement('table');
    table.className = 'shop-table';
    table.innerHTML =
        '<thead><tr>' + columns.map(function (c) { return '<th>' + escapeHtml(prettyCol(c)) + '</th>'; }).join('') + '</tr></thead>' +
        '<tbody>' + list.map(function (row) {
            return '<tr>' + columns.map(function (c) { return '<td>' + escapeHtml(displayVal(row[c])) + '</td>'; }).join('') + '</tr>';
        }).join('') + '</tbody>';
    wrap.appendChild(table);
    section.appendChild(wrap);
    return section;
}

function filterFields(fields) {
    var q = (productState.search || '').toLowerCase();
    return fields.filter(function (field) {
        if (productState.filledOnly && isEmptyValue(field.value))
            return false;
        if (productState.customOnly && field.source !== 'Custom' && field.source !== 'Extension')
            return false;
        if (!q)
            return true;
        return [field.caption, field.name, field.value, String(field.fieldNo), field.source].join(' ').toLowerCase().indexOf(q) >= 0;
    });
}

function chip(text, kind) {
    var el = document.createElement('span');
    el.className = 'chip' + (kind ? ' ' + kind : '');
    el.textContent = text;
    return el;
}

function note(text) {
    var el = document.createElement('div');
    el.className = 'note';
    el.textContent = text;
    return el;
}

function unique(items, key) {
    var seen = {};
    var out = [];
    items.forEach(function (item) {
        var value = item[key] || '';
        if (!seen[value]) {
            seen[value] = true;
            out.push(value);
        }
    });
    return out;
}

function prettyCol(name) {
    return String(name).replace(/([A-Z])/g, ' $1').replace(/^./, function (c) { return c.toUpperCase(); }).trim();
}

function displayVal(value) {
    if (value === null || value === undefined || value === '')
        return '—';
    return String(value);
}

function isEmptyValue(value) {
    if (value === null || value === undefined)
        return true;
    var text = String(value).trim();
    return text === '' || text === '—';
}

function escapeHtml(value) {
    return String(value == null ? '' : value)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

window.SetProductData = SetProductData;
