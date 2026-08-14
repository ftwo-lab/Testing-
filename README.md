# Product Webshop for Business Central

An AL extension that shows Business Central items in a **webshop** layout inside BC — a product grid plus a storefront-style product page.

It does not replace Shopify or an external storefront. It is a visual shop you open in Business Central so you can see product information the way a website would show it.

## What you get

**Product Webshop** (Tell Me: `Product Webshop`)

- Catalog grid with picture, name, price, category, and stock
- Search and category chips
- Click a product to open a webshop product page

**Product page**

- Large picture, SKU, price, in-stock badge, description
- Overview, Specifications, and All product data tabs
- Every Item field, including custom and extension fields
- Related data: attributes, variants, units, references, inventory by location, and more
- **Open Item Card** to return to the standard BC form

From **Item Card** or **Item List** use **View in Webshop** or **Product Webshop**.

## Install

1. Open this folder in Visual Studio Code with the **AL Language** extension.
2. Download symbols for your sandbox and publish the app.
3. Assign permission set **Visual Product View**.
4. Search Tell Me for **Product Webshop**.

Object IDs are **50100–50149**. Change them if that range is already used.

The catalog shows up to 48 non-blocked items. Open a single item with **View in Webshop** if you need a product that is not in that first page of the catalog.
