# Visual Product Catalog for Business Central

A Business Central extension that shows one item (product) in a website-style page: picture, key facts, **every standard and custom field** on the Item record, and related data (attributes, variants, units, inventory by location, and more).

## What you get

From **Item Card** or **Item List**, use **Visual Product View**.

The page includes:

- Product hero: picture, number, description, blocked/active, type, category, inventory, price, cost
- All Item table fields, including per-tenant custom fields (50,000–99,999) and extension fields (1,000,000+) such as Master SKU No. or Product Family Code
- Search, **Hide empty**, and **Custom fields only**
- Related records: attributes, variants, units of measure, item references, translations, inventory by location, SKUs, default dimensions, extended texts

## Install in Business Central

1. Open this folder in Visual Studio Code with the **AL Language** extension.
2. **AL: Download symbols** against your sandbox (credentials in `.vscode/launch.json`).
3. **AL: Package** or **Command+F5 / Ctrl+F5** to publish.
4. In BC, search **Permission Sets**, open **Visual Product View**, and assign it to the users who should open the page.
5. Open an item → **Visual Product View**.

You can also search Tell Me for **Visual Product View** and select an item.

## Objects

| ID | Type | Name |
| --- | --- | --- |
| 50100 | Page | Product Visual Card |
| 50100 | Codeunit | Product Visual Data |
| 50100 | Permission set | Product Visual View |
| 50101 / 50102 | Page extensions | Item Card / Item List |
| — | Control add-in | ProductVisualViewer |

If 50100–50149 clashes with another app in your environment, change `idRanges` in `app.json` and the object IDs to a free range.
