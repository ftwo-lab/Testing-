# Attach product family code + test on your default item

Copy these AL files into **ZVG-Nonpa**, publish, then test on a normal **Item Card**.

This does **not** replace the Microsoft **Shopify Connector**.  
**Add to Shopify** on the default item is still the publish path.

---

## How BC maps to Shopify (connector you already have)

| Business Central | Product family view | Shopify Connector |
|---|---|---|
| **Item** (your default item) | Parent / Produkt Main | **Shopify Product** via **Add to Shopify** |
| **Item Variants** (standard BC variants) | V1, V2, V3 | **Shopify Product Variants** |
| Product Family (Glass / PET / Can) | Family column | Separate default items = separate Shopify products |
| Main Product Family (Coca Cola) | Visual Board header | Collection / vendor you already set in the connector |
| Shared SharePoint URL / note | Family card + Item factbox | Stays on the **product** (do not duplicate per variant) |

Do not create extra Items for 0.33 L / 0.1 L if those are already **Item Variants** of the default item.

---

## Part A — Attach the code

Merge into existing folders (do not nest this folder):

```bash
cp PIM-Product-Family/src/enum/*               ZVG-Nonpa/src/enum/
cp PIM-Product-Family/src/table/*              ZVG-Nonpa/src/table/
mkdir -p ZVG-Nonpa/src/tableextension
cp PIM-Product-Family/src/tableextension/*     ZVG-Nonpa/src/tableextension/
cp PIM-Product-Family/src/codeunit/*           ZVG-Nonpa/src/codeunit/
cp PIM-Product-Family/src/page/*               ZVG-Nonpa/src/page/
cp PIM-Product-Family/src/pageextension/*      ZVG-Nonpa/src/pageextension/
```

`app.json` `idRanges` must include **50120–50136**. Publish with F5.

---

## Part B — Test visualization on your default item

### 1. Family structure (Coca Cola picture)

1. Tell Me → **PIM Product Family Groups** → **Create Example Families** (or create Coca Cola / Glass / PET / Can yourself).
2. Tell Me → **Product Family Visual Board**.
3. Select the main family (e.g. COKE). You should see:

```
Main Family     Coca Cola
  Family        Glass Bottle
    Parent      <default item>     0.5 L
      V1        <Item Variant>     0.33 L
      V2        <Item Variant>     0.1 L
  Family        PET
    Parent      ...
  Family        Can
    Parent      ...
```

### 2. Your default item + its Item Variants

1. Open **your default Item**.
2. FastTab **Product Family**: set **Product Family**, **Family Role = Default Item**. Save.
3. **Processing → Product Family → Item Variants** and confirm V1/V2 exist as standard BC variants (create them here if needed).
4. **Processing → Product Family → Load Item Variants**.
5. Factbox **Family: Default Item and Variants** shows Parent + V1 + V2 with **Item Variant** codes.
6. **Product Family Visual Board** shows the same tree.

### 3. Shared SharePoint documents and notes

1. Open the **Product Family Card** (or Main Product Family card for brand-wide files).
2. In **Shared SharePoint documents and notes** add:
   - Type **SharePoint Document**, Title, **SharePoint URL**, kind = Datasheet
   - Type **Shared Note**, Notes = handling text
3. Open any default item in that family. Factboxes **Family SharePoint / notes** and **Main family SharePoint / notes** show the same rows. Variants inherit them; you do not attach the PDF on every variant.

### 4. Publish with the connector you already have

1. Stay on the **default item** (Parent).
2. Use the standard **Shopify → Add to Shopify** (or **Add to Shopify**) action. Do not use a second custom Shopify app.
3. In Shopify you should get:
   - **One product** = the default item
   - **Variants** = the Item Variants (V1, V2)
   - Product-level files/notes = what you stored as shared family content (map SharePoint URLs in the connector metafields if you already do that)

Glass vs PET vs Can: run **Add to Shopify** on **each default item** (each is its own Shopify product).

---

## Cleaning Soap rule

- Same item, color variants → **Item Variants** under one default item → one Shopify product  
- Different UOM (5L Canister) → **another default item** → another Shopify product
