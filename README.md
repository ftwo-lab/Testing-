# PIM in Business Central + company sync + webshop

**Architecture (Word, download):** [Webshop/PIM-Architecture.docx](https://github.com/ftwo-lab/Testing-/raw/cursor/visual-product-view-6d56/Webshop/PIM-Architecture.docx)

Markdown (same content, GitHub diagrams): [Webshop/PIM-ARCHITECTURE.md](Webshop/PIM-ARCHITECTURE.md)

Copy the `Webshop` folder into **ICS Master** and publish. If your AL objects live under `src`, put it at `src/Webshop` and use control add-in paths `src/Webshop/scripts/...` and `src/Webshop/styles/...`. Publish the same app in **every child company** you sync to.

## Design (does not replace ERP)

- Item **No. is the same** in master and in DE / AT / ES / CH / NP / CZ. Sales and purchase keep using that number.
- PIM only writes commercial / product-master data. It does **not** change inventory, vendors, costing, or documents.
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
4. **Published to Webshop** — only then it appears in Product Webshop

## What syncs to child companies (same Item No.)

Pictures, variants, item UOMs, master UOM, item categories, PIM + standard attributes, translations, default/custom extended texts, document attachments (including SharePoint URLs), item references, weights, GTIN, tariff, country of origin.

Not synced: inventory, unit cost, sales/purchase orders, warehouse SKUs.
