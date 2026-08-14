# Add Product Webshop to ICS Master (ZVG)

Copy the **`Webshop`** folder into the **ICS Master** app root (the folder that already has this `app.json`). Do not create a second app and do not change your app id.

```text
ICS Master/
  app.json
  src/                 ← your existing objects
  Webshop/             ← paste this folder here
```

Your `idRanges` already include `50350–50399`. These objects use that range:

| ID | Object |
| --- | --- |
| 50350 | Codeunit Product Visual Data |
| 50351 | Page Product Visual Card |
| 50352 | Page Product Webshop |
| 50353 | Page extension Item Card |
| 50354 | Page extension Item List |
| 50355 | Permission set Visual Product View |

If any of those IDs are already used in ICS Master, change only that object’s number to another free ID in `50350–50399` or `50600–50700`.

## Publish ICS Master

1. Open the **ICS Master** folder in VS Code.
2. Run **AL: Download symbols**.
3. Press **F5** to publish ICS Master (version can stay `1.0.0.3` or bump to `1.0.0.4`).
4. In Business Central: Tell Me → **Product Webshop**.

Or open an **Item Card** → **View in Webshop**.

If JavaScript does not load, `Webshop` must sit next to `app.json`, because the control add-in paths are `Webshop/scripts/...` and `Webshop/styles/...`.
