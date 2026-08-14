# Copy this into YOUR Business Central app

Do **not** publish this Testing repository as its own app.

Copy the **`Webshop`** folder into the root of **your existing AL app** (the folder that already has your `app.json`).

Your app should look like this:

```text
YourApp/
  app.json          ← yours, do not replace
  src/              ← your existing objects
  Webshop/          ← paste this whole folder here
    ProductVisualViewer.ControlAddin.al
    ProductVisualData.Codeunit.al
    ProductVisualCard.Page.al
    ProductWebshop.Page.al
    ItemCardVisualExt.PageExt.al
    ItemListVisualExt.PageExt.al
    ProductVisualView.PermissionSet.al
    scripts/
    styles/
```

## Then do this in your app

1. Open **your** `app.json`.
2. Make sure `idRanges` includes **50100–50103** (or change the IDs in the Webshop `.al` files to IDs that are free in your range).
3. In VS Code, run **AL: Download symbols** on **your** app.
4. Press **F5** to publish **your** app (same way you always publish).
5. In Business Central: Tell Me → **Product Webshop**.

If the control add-in cannot find the JavaScript/CSS, the `Webshop` folder is not next to `app.json`. Paths in `ProductVisualViewer.ControlAddin.al` must match the folder location.

## If 50100 is already used in your app

Change these IDs in the `.al` files to free numbers from your range:

| File | Object |
| --- | --- |
| ProductVisualData.Codeunit.al | codeunit 50100 |
| ProductVisualView.PermissionSet.al | permissionset 50100 |
| ProductVisualCard.Page.al | page 50100 |
| ItemCardVisualExt.PageExt.al | pageextension 50101 |
| ItemListVisualExt.PageExt.al | pageextension 50102 |
| ProductWebshop.Page.al | page 50103 |

The control add-in has no object ID.

## After publish

- Tell Me → **Product Webshop**
- Or open an **Item Card** → **View in Webshop**
