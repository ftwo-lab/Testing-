var productState = {
    data: null,
    search: '',
    filledOnly: false,
    customOnly: false,
    collapsed: {}
};

function SetProductData(jsonData) {
    try {
        productState.data = typeof jsonData === 'string' ? JSON.parse(jsonData) : jsonData;
        productState.collapsed = {};
        renderProduct();
    } catch (err) {
        renderMessage('Could not read product data', err.message || String(err));
    }
}

function rerenderKeepingUi() {
    var scrollY = window.scrollY || 0;
    var searchLen = productState.search.length;
    renderProduct();
    var next = document.querySelector('.pvc-search');
    if (next) {
        next.focus();
        if (typeof next.setSelectionRange === 'function')
            next.setSelectionRange(searchLen, searchLen);
    }
    window.scrollTo(0, scrollY);
}

function renderMessage(title, detail) {
    document.body.innerHTML = '';
    var root = document.createElement('div');
    root.id = 'pvc-root';
    root.innerHTML =
        '<div class="pvc-empty"><div class="pvc-photo-fallback">Visual Product View</div><h2>' +
        escapeHtml(title) +
        '</h2><p>' +
        escapeHtml(detail || '') +
        '</p></div>';
    document.body.appendChild(root);
}

function renderProduct() {
    var data = productState.data;
    if (!data || !data.header || !data.header.no) {
        renderMessage('No product selected', 'Open this page from an Item Card or Item List, or use Tell Me and choose an item.');
        return;
    }

    document.body.innerHTML = '';
    var root = document.createElement('div');
    root.id = 'pvc-root';
    document.body.appendChild(root);

    root.appendChild(renderHero(data));
    root.appendChild(renderToolbar());

    var groups = data.groups || [];
    var visibleGroups = 0;
    groups.forEach(function (group) {
        var fields = filterFields(group.fields || []);
        if (!fields.length)
            return;
        visibleGroups += 1;
        root.appendChild(renderGroup(group.name, fields, group.source));
    });

    if (!visibleGroups)
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

function renderHero(data) {
    var h = data.header;
    var hero = document.createElement('section');
    hero.className = 'pvc-hero';

    var photo = document.createElement('div');
    photo.className = 'pvc-photo';
    if (h.picture) {
        var img = document.createElement('img');
        img.alt = h.description || h.no;
        img.src = h.picture;
        photo.appendChild(img);
    } else {
        photo.innerHTML = '<div class="pvc-photo-fallback">No picture<br/>' + escapeHtml(h.no) + '</div>';
    }

    var info = document.createElement('div');
    info.innerHTML =
        '<p class="pvc-kicker">Business Central product</p>' +
        '<h1 class="pvc-title">' + escapeHtml(h.description || h.no) + '</h1>' +
        '<p class="pvc-sub">' + escapeHtml(h.description2 || 'Every standard and custom field on this item, plus related product records.') + '</p>';

    var chips = document.createElement('div');
    chips.className = 'pvc-chips';
    chips.appendChild(chip('No. ' + h.no, 'accent'));
    if (h.blocked)
        chips.appendChild(chip('Blocked', 'danger'));
    else
        chips.appendChild(chip('Active', 'ok'));
    if (h.type)
        chips.appendChild(chip(h.type));
    if (h.itemCategory)
        chips.appendChild(chip('Category ' + h.itemCategory));
    if (h.baseUom)
        chips.appendChild(chip('UOM ' + h.baseUom));
    if (h.fieldCount)
        chips.appendChild(chip(h.fieldCount + ' fields'));
    if (h.customFieldCount)
        chips.appendChild(chip(h.customFieldCount + ' custom / extension', 'accent'));
    info.appendChild(chips);

    var stats = document.createElement('div');
    stats.className = 'pvc-stats';
    stats.appendChild(stat('Inventory', h.inventory));
    stats.appendChild(stat('Unit Price', h.unitPrice));
    stats.appendChild(stat('Unit Cost', h.unitCost));
    stats.appendChild(stat('Vendor', h.vendorNo || '—'));
    info.appendChild(stats);

    hero.appendChild(photo);
    hero.appendChild(info);
    return hero;
}

function renderToolbar() {
    var bar = document.createElement('div');
    bar.className = 'pvc-toolbar';

    var search = document.createElement('input');
    search.className = 'pvc-search';
    search.placeholder = 'Search field names and values…';
    search.value = productState.search;
    search.addEventListener('input', function (e) {
        productState.search = e.target.value;
        rerenderKeepingUi();
    });

    var filled = document.createElement('button');
    filled.className = 'pvc-toggle' + (productState.filledOnly ? ' active' : '');
    filled.textContent = 'Hide empty';
    filled.onclick = function () {
        productState.filledOnly = !productState.filledOnly;
        rerenderKeepingUi();
    };

    var custom = document.createElement('button');
    custom.className = 'pvc-toggle' + (productState.customOnly ? ' active' : '');
    custom.textContent = 'Custom fields only';
    custom.onclick = function () {
        productState.customOnly = !productState.customOnly;
        rerenderKeepingUi();
    };

    bar.appendChild(search);
    bar.appendChild(filled);
    bar.appendChild(custom);
    return bar;
}

function renderGroup(name, fields, source) {
    var key = name;
    var section = document.createElement('section');
    section.className = 'pvc-section';
    var header = document.createElement('header');
    header.innerHTML = '<h3>' + escapeHtml(name) + '</h3><span class="pvc-count">' + fields.length + ' fields' + (source ? ' · ' + escapeHtml(source) : '') + '</span>';
    header.onclick = function () {
        productState.collapsed[key] = !productState.collapsed[key];
        renderProduct();
    };
    section.appendChild(header);
    if (productState.collapsed[key])
        return section;

    var grid = document.createElement('div');
    grid.className = 'pvc-grid';
    fields.forEach(function (field) {
        var card = document.createElement('article');
        card.className = 'pvc-field' + (field.source === 'Custom' || field.source === 'Extension' ? ' custom' : '');
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
    section.className = 'pvc-section';
    var list = rows || [];
    var header = document.createElement('header');
    header.innerHTML = '<h3>' + escapeHtml(title) + '</h3><span class="pvc-count">' + list.length + '</span>';
    var key = 'rel:' + title;
    header.onclick = function () {
        productState.collapsed[key] = !productState.collapsed[key];
        renderProduct();
    };
    section.appendChild(header);
    if (productState.collapsed[key])
        return section;
    if (!list.length) {
        section.appendChild(note('No ' + title.toLowerCase() + ' for this product.'));
        return section;
    }
    var wrap = document.createElement('div');
    wrap.className = 'pvc-table-wrap';
    var table = document.createElement('table');
    table.className = 'pvc-table';
    var thead = '<tr>' + columns.map(function (c) { return '<th>' + escapeHtml(prettyCol(c)) + '</th>'; }).join('') + '</tr>';
    var tbody = list.map(function (row) {
        return '<tr>' + columns.map(function (c) { return '<td>' + escapeHtml(displayVal(row[c])) + '</td>'; }).join('') + '</tr>';
    }).join('');
    table.innerHTML = '<thead>' + thead + '</thead><tbody>' + tbody + '</tbody>';
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
        return [field.caption, field.name, field.value, String(field.fieldNo), field.source]
            .join(' ')
            .toLowerCase()
            .indexOf(q) >= 0;
    });
}

function chip(text, kind) {
    var el = document.createElement('span');
    el.className = 'pvc-chip' + (kind ? ' ' + kind : '');
    el.textContent = text;
    return el;
}

function stat(label, value) {
    var el = document.createElement('div');
    el.className = 'pvc-stat';
    el.innerHTML = '<span>' + escapeHtml(label) + '</span><strong>' + escapeHtml(displayVal(value)) + '</strong>';
    return el;
}

function note(text) {
    var el = document.createElement('div');
    el.className = 'pvc-note';
    el.textContent = text;
    return el;
}

function prettyCol(name) {
    return String(name)
        .replace(/([A-Z])/g, ' $1')
        .replace(/^./, function (c) { return c.toUpperCase(); })
        .trim();
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
