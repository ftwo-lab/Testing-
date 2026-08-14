# Product Webshop for Business Central

This folder is an **AL extension**. You install it into Microsoft Dynamics 365 Business Central, then open a shop-style page that shows your real items (products).

It is not a public website. You use it **inside Business Central**.

---

## What you need first

1. A Business Central **sandbox** (trial or your company’s sandbox).
2. A user who can **publish extensions** (typically SUPER or a delegated admin).
3. **Visual Studio Code** on your PC.
4. The **AL Language** extension in VS Code (publisher: Microsoft).

---

## Part A — Put the app into Business Central

### 1. Get this project on your PC

Clone or download this repository and open the folder in VS Code:

`File → Open Folder…` → select this project folder (the one that contains `app.json`).

### 2. Sign VS Code in to your environment

1. In VS Code, press `Ctrl+Shift+P` (Mac: `Cmd+Shift+P`).
2. Run **AL: Download symbols**.
3. Choose your **Microsoft cloud sandbox** (or on-prem if that is what you use).
4. Sign in with the same account you use for Business Central.
5. Wait until symbols finish downloading (a `.alpackages` folder appears).

If download fails, your BC version may be newer than `22.0.0.0` in `app.json`. That is OK: downloading symbols still works against a newer sandbox in most cases. If the compiler asks you to raise the version, set `"application"` and `"platform"` in `app.json` to match your BC version.

### 3. Publish the extension

1. Press `F5`, or `Ctrl+F5` (Mac: `Cmd+F5`).
2. VS Code compiles the app and publishes **Product Webshop** to the sandbox.
3. A browser window should open Business Central.

If publish says the ID range is in use, change the object IDs in `app.json` (`idRanges`) and in each `.al` file from `50100` to a free range, then publish again.

### 4. Give yourself permission

1. In Business Central, click **Tell Me** (the search icon, or `/` / `Alt+Q`).
2. Search **Permission Sets**.
3. Open **Permission Sets**.
4. Find **Visual Product View**.
5. Open it → **Users** (or use **User Permission Sets** from the user card).
6. Assign **Visual Product View** to your user (SUPER already sees everything).

---

## Part B — Open the webshop and view a product

### 5. Open the shop catalog

1. In Business Central, click **Tell Me**.
2. Type **Product Webshop**.
3. Open the page **Product Webshop**.

You should see a grid of items: picture, name, price, category, stock.

- Use the search box to find a product.
- Click a category chip to filter.
- Click a product card to open its shop page.

The catalog lists up to **48 items that are not blocked**. Other items can still be opened from the Item Card (step 7).

### 6. Read one product like a webshop page

On the product page you will see:

- Picture, name, SKU, price, in stock / out of stock
- **Overview** — main details and attributes
- **Specifications** — filled fields (standard + custom)
- **All product data** — every field, plus variants, units, inventory by location, and more

Buttons:

- **Open Item Card** — standard Business Central form for the same item
- **Shop** (breadcrumb) — back to the catalog (when you came from the webshop)

### 7. Open the shop view from an existing item

If you are already on a product:

1. Go to **Items** (Tell Me → **Items**).
2. Open the item you care about (**Item Card**).
3. On the action bar choose **View in Webshop**.

Or from the item list, select a row → **View in Webshop**.

**Product Webshop** on that same bar opens the full catalog.

### 8. Refresh if data looks old

On the webshop page, use **Refresh shop**.  
On a single product page, use **Refresh**.

---

## What you will not see

- This is **not** checkout, cart, or a public storefront.
- It does **not** sync to Shopify by itself.
- Blocked items are hidden from the catalog (you can still open them from the Item Card).
- If an item has no picture in BC, the shop shows a placeholder.

---

## Objects in this app

| What you search / click | Object |
| --- | --- |
| Product Webshop | Page 50103 |
| View in Webshop | Page 50100 (from Item Card / Item List) |
| Visual Product View | Permission set 50100 |
