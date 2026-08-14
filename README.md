# PIM in Business Central (Akeneo-style) + Webshop

Copy the whole `Webshop` folder into **ICS Master** (next to `app.json`). Publish ICS Master.

## What it is

- **PIM** = product information (title, brand, descriptions, specs, SEO), like Akeneo families/attributes.
- **Webshop** = storefront that shows **only published PIM products**, not costing/planning/warehouse fields.

## After publish

1. Tell Me → **PIM Families** → **Create default PIM setup**
2. Tell Me → **PIM Product Enrichment** → open an item
3. Set **PIM Family** = DEFAULT, fill Title / Description / other attributes
4. Enable **Published to Webshop**
5. Tell Me → **Product Webshop**

Also on Item Card: group **PIM**, actions **PIM Enrichment** and **View in Webshop**.

## Search in Tell Me

- PIM Families, PIM Attributes, PIM Categories, PIM Product Enrichment
- Product Webshop
