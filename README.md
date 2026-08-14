# PIM in Business Central + company sync + webshop

Copy the `Webshop` folder into **ICS Master** and publish. Publish the same app in **every child company** you sync to.

## Design (does not replace ERP)

- Item **No. is the same** in master and in DE / AT / ES / CH / NP / CZ. Sales and purchase keep using that number.
- PIM only writes: description, optional unit price, PIM attributes, family/category. It does **not** change inventory, vendors, costing, or documents.
- New items in a child company can take **posting groups from a template item** that already exists there.

## Setup (once, in Master Product Tenant)

1. Tell Me → **PIM Families** → **Create default PIM setup**
2. Tell Me → **PIM Marketplaces**
3. For DE, AT, ES, CH, NP, CZ set **Business Central Company** to the exact company name
4. Set **Enabled**
5. Set **Template Item No.** (an item that already exists in that company, for posting groups)
6. **Sync PIM setup to this company** for each marketplace

## Per item

1. **PIM Product Enrichment** — family, attributes, completeness
2. Item Card → **Sync to companies** — tick DE / AT / ES / …  
3. **Sync to companies** action  
4. **Published to Webshop** — only then it appears in Product Webshop (master)

Webshop still shows **PIM data only** (plus SKU, price, stock, image).
