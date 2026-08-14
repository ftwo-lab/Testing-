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
        if (!(data.products || []).length)
            wrap.appendChild(note('No published PIM products. Open PIM Product Enrichment, fill attributes, then enable Published to Webshop.'));
        else
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
    var pics = (data && data.pictures) || [];
    var mainUrl = h.picture || (pics[0] && pics[0].url) || '';
    if (mainUrl) {
        var img = document.createElement('img');
        img.alt = h.description || h.no;
        img.src = mainUrl;
        img.id = 'pdp-main-img';
        photo.appendChild(img);
        if (pics.length > 1) {
            var thumbs = document.createElement('div');
            thumbs.className = 'pdp-thumbs';
            pics.forEach(function (p) {
                if (!p.url) return;
                var t = document.createElement('img');
                t.src = p.url;
                t.alt = p.source || '';
                t.onclick = function () {
                    var main = document.getElementById('pdp-main-img');
                    if (main) main.src = p.url;
                };
                thumbs.appendChild(t);
            });
            photo.appendChild(thumbs);
        }
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
    tabs.appendChild(tabBtn('Attributes & variants', 'specs'));
    tabs.appendChild(tabBtn('Documents & Shopify', 'all'));
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
    if (data.shopifyMap && data.shopifyMap.length)
        return data.shopifyMap.map(function (r) {
            return [r.shopify, r.source, r.value];
        });
    var h = data.header || {};
    return [
        ['title', 'PIM title', h.description],
        ['vendor', 'PIM brand', h.vendorName],
        ['product_type', 'PIM category', h.categoryName || h.itemCategory],
        ['status', 'PIM Published', h.published ? 'active' : 'draft'],
        ['body_html', 'PIM description', h.longDescription || h.description2],
        ['variants[0].sku', 'Item No.', h.no],
        ['variants[0].price', 'Unit Price', h.unitPrice],
        ['variants[0].inventory_quantity', 'Inventory', h.inventory]
    ];
}

function renderOverview(data) {
    var wrap = document.createElement('div');
    var desc = document.createElement('section');
    desc.className = 'panel';
    desc.innerHTML = '<header><h3>Description</h3></header>';
    var body = (data.header && (data.header.longDescription || data.header.description2 || data.header.description)) || '';
    desc.insertAdjacentHTML('beforeend', '<p class="pdp-desc">' + escapeHtml(body) + '</p>');
    wrap.appendChild(desc);

    var details = document.createElement('section');
    details.className = 'panel';
    details.innerHTML = '<header><h3>Product details</h3></header>';
    var attrs = data.attributes || [];
    var html = '<div class="attr-list">';
    html += attrRow('SKU', data.header.no);
    html += attrRow('Title', data.header.description);
    html += attrRow('Brand', data.header.vendorName);
    html += attrRow('Category', data.header.categoryName || data.header.itemCategory);
    html += attrRow('Price', data.header.unitPrice);
    html += attrRow('Inventory', data.header.inventory);
    attrs.forEach(function (a) { html += attrRow(a.caption || a.code, a.value); });
    html += '</div>';
    details.insertAdjacentHTML('beforeend', html);
    wrap.appendChild(details);

    var variants = data.variants || [];
    if (variants.length) {
        var v = document.createElement('section');
        v.className = 'panel';
        v.innerHTML = '<header><h3>Variants</h3></header>' +
            '<div class="table-wrap"><table class="shop-table"><thead><tr><th>Code</th><th>Description</th><th>Blocked</th></tr></thead><tbody>' +
            variants.map(function (x) {
                return '<tr><td>' + escapeHtml(x.code) + '</td><td>' + escapeHtml(x.description) + '</td><td>' + escapeHtml(x.blocked) + '</td></tr>';
            }).join('') + '</tbody></table></div>';
        wrap.appendChild(v);
    }

    var texts = data.extendedTexts || [];
    texts.forEach(function (t) {
        if (!t.text) return;
        var s = document.createElement('section');
        s.className = 'panel';
        s.innerHTML = '<header><h3>' + escapeHtml(t.description || ('Extended text ' + (t.textNo || ''))) + '</h3></header><p class="pdp-desc">' + escapeHtml(t.text) + '</p>';
        wrap.appendChild(s);
    });
    return wrap;
}

function attrRow(name, value) {
    return '<div><dt>' + escapeHtml(displayVal(name)) + '</dt><dd>' + escapeHtml(displayVal(value)) + '</dd></div>';
}

function renderSpecs(data) {
    var wrap = document.createElement('div');
    var panel = document.createElement('section');
    panel.className = 'panel';
    panel.innerHTML = '<header><h3>PIM attributes</h3></header>';
    var attrs = data.attributes || [];
    var table = document.createElement('div');
    table.className = 'table-wrap';
    var rows = attrs.map(function (a) {
        return '<tr><td>' + escapeHtml(a.group || '') + '</td><td>' + escapeHtml(a.caption || a.code) + '</td><td>' + escapeHtml(a.value) + '</td></tr>';
    }).join('');
    table.innerHTML = '<table class="shop-table"><thead><tr><th>Group</th><th>Attribute</th><th>Value</th></tr></thead><tbody>' +
        (rows || '<tr><td colspan="3">No PIM attribute values.</td></tr>') +
        '</tbody></table>';
    panel.appendChild(table);
    wrap.appendChild(panel);

    var bcAttrs = data.itemAttributes || [];
    if (bcAttrs.length) {
        var p2 = document.createElement('section');
        p2.className = 'panel';
        p2.innerHTML = '<header><h3>Master item attributes</h3></header><div class="table-wrap"><table class="shop-table"><thead><tr><th>Attribute</th><th>Value</th></tr></thead><tbody>' +
            bcAttrs.map(function (a) {
                return '<tr><td>' + escapeHtml(a.name) + '</td><td>' + escapeHtml(a.value) + '</td></tr>';
            }).join('') + '</tbody></table></div>';
        wrap.appendChild(p2);
    }

    var uoms = data.unitsOfMeasure || [];
    if (uoms.length) {
        var p3 = document.createElement('section');
        p3.className = 'panel';
        p3.innerHTML = '<header><h3>Units of measure</h3></header><div class="table-wrap"><table class="shop-table"><thead><tr><th>Code</th><th>Qty per</th></tr></thead><tbody>' +
            uoms.map(function (u) {
                return '<tr><td>' + escapeHtml(u.code) + '</td><td>' + escapeHtml(u.qtyPerUnit) + '</td></tr>';
            }).join('') + '</tbody></table></div>';
        wrap.appendChild(p3);
    }
    return wrap;
}

function renderAllData(root, data) {
    var docs = data.documents || [];
    var panel = document.createElement('section');
    panel.className = 'panel';
    panel.innerHTML = '<header><h3>Documents (SharePoint / attachments)</h3></header>';
    if (!docs.length)
        panel.insertAdjacentHTML('beforeend', '<div class="note">No document attachments on this item.</div>');
    else {
        var list = '<div class="doc-list">';
        docs.forEach(function (d) {
            var name = (d.fileName || 'Document') + (d.extension ? '.' + d.extension : '');
            if (d.url)
                list += '<a class="doc-link" href="' + escapeHtml(d.url) + '" target="_blank" rel="noopener">' + escapeHtml(name) + '</a>';
            else
                list += '<div class="doc-link">' + escapeHtml(name) + '</div>';
        });
        list += '</div>';
        panel.insertAdjacentHTML('beforeend', list);
    }
    root.appendChild(panel);

    var map = document.createElement('section');
    map.className = 'panel';
    map.innerHTML = '<header><h3>How this looks on Shopify</h3></header>';
    map.insertAdjacentHTML('beforeend', '<div class="map-note">PIM content plus variants, pictures, UOMs, extended texts, and attachments. Inventory, cost, and orders stay in each company.</div>');
    var rows = shopifyRows(data).map(function (r) {
        return '<tr><td>' + escapeHtml(r[0]) + '</td><td>' + escapeHtml(r[1]) + '</td><td>' + escapeHtml(displayVal(r[2])) + '</td></tr>';
    }).join('');
    map.insertAdjacentHTML(
        'beforeend',
        '<div class="table-wrap"><table class="shop-table"><thead><tr><th>Shopify field</th><th>PIM / BC source</th><th>Value</th></tr></thead><tbody>' +
            rows + '</tbody></table></div>'
    );
    root.appendChild(map);
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
