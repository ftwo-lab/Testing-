var productState = {
    data: null,
    search: '',
    filledOnly: true,
    customOnly: false,
    collapsed: {},
    tab: 'overview',
    shopSearch: '',
    category: ''
};

function SetProductData(jsonData) {
    try {
        productState.data = typeof jsonData === 'string' ? JSON.parse(jsonData) : jsonData;
        productState.collapsed = {};
        productState.search = '';
        productState.tab = 'overview';
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
    root.innerHTML =
        '<div class="pvc-empty"><h2>' + escapeHtml(title) + '</h2><p>' + escapeHtml(detail || '') + '</p></div>';
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

    root.appendChild(shopHeader(data.shopName || 'Product Webshop', true));

    var wrap = document.createElement('div');
    wrap.className = 'shop-wrap';
    wrap.innerHTML =
        '<div class="shop-hero-copy"><h1>Shop products</h1><p>Live item data from Business Central, shown as a webshop. Click a product to open its page.</p></div>';

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
        wrap.appendChild(note('No products match this search. Publish the app to a company that has items, then refresh.'));
    } else {
        products.forEach(function (p) {
            grid.appendChild(productCard(p));
        });
        wrap.appendChild(grid);
    }
    root.appendChild(wrap);

    var search = document.getElementById('shop-search');
    if (search) {
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
}

function productCard(p) {
    var card = document.createElement('article');
    card.className = 'product-card';
    card.onclick = function () {
        invokeNav('ProductSelected', [p.no]);
    };
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
    var inStock = Number(p.inventoryValue) > 0;
    card.appendChild(thumb);
    card.insertAdjacentHTML(
        'beforeend',
        '<div class="body">' +
            '<div class="cat">' + escapeHtml(p.categoryName || p.type || 'Product') + '</div>' +
            '<h3>' + escapeHtml(p.description || p.no) + '</h3>' +
            '<div class="price">' + escapeHtml(displayVal(p.unitPrice)) + '</div>' +
            '<div class="stock">' + (inStock ? 'In stock · ' + escapeHtml(p.inventory) : 'Out of stock') + '</div>' +
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
    top.innerHTML = '<div class="shop-brand">' + escapeHtml(name) + ' <span>Webshop</span></div>';
    if (withSearch) {
        var input = document.createElement('input');
        input.id = 'shop-search';
        input.placeholder = 'Search products…';
        top.appendChild(input);
    }
    return top;
}

function renderProductPage(data) {
    var h = data.header || {};
    if (!h.no) {
        renderMessage('No product selected', 'Open Product Webshop from Tell Me, or use View in Webshop on an item.');
        return;
    }

    document.body.innerHTML = '';
    var root = document.createElement('div');
    root.id = 'pvc-root';
    document.body.appendChild(root);
    root.appendChild(shopHeader(data.shopName || 'Product Webshop', false));

    var wrap = document.createElement('div');
    wrap.className = 'shop-wrap';
    if (data.showBack) {
        var crumb = document.createElement('div');
        crumb.className = 'crumb';
        crumb.innerHTML = '<button type="button">Shop</button> / ' + escapeHtml(h.categoryName || h.itemCategory || 'Product') + ' / ' + escapeHtml(h.description || h.no);
        crumb.querySelector('button').onclick = function () {
            invokeNav('BackToCatalog', []);
        };
        wrap.appendChild(crumb);
    }

    wrap.appendChild(renderPdp(h));
    root.appendChild(wrap);
    root.appendChild(renderTabs());

    if (productState.tab === 'overview')
        root.appendChild(renderOverview(data));
    else if (productState.tab === 'specs')
        root.appendChild(renderSpecs(data));
    else
        renderAllData(root, data);
}

function renderPdp(h) {
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
        photo.innerHTML = '<div class="pdp-photo-fallback">No product picture<br/>' + escapeHtml(h.no) + '</div>';
    }

    var inStock = Number(h.inventoryValue) > 0;
    var info = document.createElement('div');
    info.innerHTML =
        '<p class="pdp-kicker">' + escapeHtml(h.categoryName || h.itemCategory || h.type || 'Product') + '</p>' +
        '<h1>' + escapeHtml(h.description || h.no) + '</h1>' +
        '<p class="pdp-sku">SKU ' + escapeHtml(h.no) +
            (h.commonItemNo ? ' · Common item ' + escapeHtml(h.commonItemNo) : '') +
            (h.baseUom ? ' · ' + escapeHtml(h.baseUom) : '') +
        '</p>' +
        '<div class="pdp-price">' + escapeHtml(displayVal(h.unitPrice)) +
            (h.baseUom ? '<small>/ ' + escapeHtml(h.baseUom) + '</small>' : '') +
        '</div>';

    var chips = document.createElement('div');
    chips.className = 'chips';
    chips.appendChild(chip(inStock ? 'In stock · ' + displayVal(h.inventory) : 'Out of stock', inStock ? 'ok' : 'danger'));
    if (h.blocked)
        chips.appendChild(chip('Blocked', 'danger'));
    if (h.type)
        chips.appendChild(chip(h.type));
    if (h.vendorNo)
        chips.appendChild(chip('Vendor ' + h.vendorNo));
    info.appendChild(chips);

    if (h.longDescription || h.description2)
        info.insertAdjacentHTML('beforeend', '<p class="pdp-desc">' + escapeHtml(h.longDescription || h.description2) + '</p>');

    var actions = document.createElement('div');
    actions.className = 'pdp-actions';
    var openBtn = document.createElement('button');
    openBtn.className = 'btn primary';
    openBtn.textContent = 'Open Item Card';
    openBtn.onclick = function () {
        invokeNav('OpenItemCard', [h.no]);
    };
    actions.appendChild(openBtn);
    if (h.customFieldCount)
        info.insertAdjacentHTML('beforeend', '');
    info.appendChild(actions);

    pdp.appendChild(photo);
    pdp.appendChild(info);
    return pdp;
}

function renderTabs() {
    var tabs = document.createElement('div');
    tabs.className = 'tabs';
    tabs.appendChild(tabBtn('Overview', 'overview'));
    tabs.appendChild(tabBtn('Specifications', 'specs'));
    tabs.appendChild(tabBtn('All product data', 'all'));
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

function renderOverview(data) {
    var panel = document.createElement('section');
    panel.className = 'panel';
    panel.innerHTML = '<header><h3>Product details</h3></header>';
    var attrs = (data.related && data.related.attributes) || [];
    var variants = (data.related && data.related.variants) || [];
    var html = '<div class="attr-list">';
    html += attrRow('Item No.', data.header.no);
    html += attrRow('Description', data.header.description);
    html += attrRow('Category', data.header.categoryName || data.header.itemCategory);
    html += attrRow('Base UOM', data.header.baseUom);
    html += attrRow('Unit price', data.header.unitPrice);
    html += attrRow('Unit cost', data.header.unitCost);
    html += attrRow('Inventory', data.header.inventory);
    html += attrRow('Vendor', data.header.vendorNo);
    attrs.forEach(function (a) {
        html += attrRow(a.name, a.value);
    });
    html += '</div>';
    if (variants.length) {
        html += '<div class="note">Variants: ' + variants.map(function (v) { return v.code + (v.description ? ' ' + v.description : ''); }).join(', ') + '</div>';
    }
    panel.insertAdjacentHTML('beforeend', html);
    return panel;
}

function attrRow(name, value) {
    return '<div><dt>' + escapeHtml(displayVal(name)) + '</dt><dd>' + escapeHtml(displayVal(value)) + '</dd></div>';
}

function renderSpecs(data) {
    var panel = document.createElement('section');
    panel.className = 'panel';
    panel.innerHTML = '<header><h3>Specifications</h3><span>' + escapeHtml(String((data.header && data.header.fieldCount) || 0)) + ' fields</span></header>';
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
        (rows || '<tr><td colspan="3">No filled fields</td></tr>') +
        '</tbody></table>';
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
            '<div class="meta">' + escapeHtml((field.name || '') + ' · #' + field.fieldNo + ' · ' + (field.type || '') + ' · ' + (field.source || 'Standard')) + '</div>';
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
