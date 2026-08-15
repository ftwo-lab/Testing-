# Where product data lives, and how it syncs to 6 companies

This is **not** a second Item Card. Business Central already has variants, pictures, UOM, Item UOM, and SharePoint attachments on the **standard Item**. PIM adds **family / attributes / channels / publish**. Sync copies **product-master data** from the master company into DE, AT, ES, CH, NP, CZ using the **same Item No.**

```text
Master company                          Child company (e.g. Germany)
─────────────────                       ────────────────────────────
Item 1000  ──────────────────────────►  Item 1000   (same number)
  variants, picture, UOM, attachments      same commercial copy
  PIM family, values, channels             same PIM copy
  inventory 12                             inventory stays local
  unit cost                                unit cost stays local
  sales orders                             documents stay local
```

---

## Two different “places” — do not mix them

| Concept | What it is | Where you maintain it | Role vs 6 companies |
|---------|------------|------------------------|---------------------|
| **PIM Channel** | Akeneo-style **sales channel** (WEBSHOP, B2B, DE, AT, …) | Tell Me **PIM Channels**; ticks on Item Card **PIM Channels** | Publish the product *commercially* (webshop / country storefront). Does **not** create the item in the other company by itself. |
| **PIM Marketplace** | **Business Central company** mapping (DE → exact company name) | Tell Me **PIM Marketplaces**; ticks **Sync to companies** | **ERP copy** of the item into that company (`ChangeCompany`). |
| **Item Variant** | Standard BC SKU split (color/size codes) | Item Card → **Variants** | Copied with the item. Stock per variant stays in that company. |
| **Picture** | Standard BC `Item.Picture` (MediaSet) | Item Card picture | Media GUID copied. |
| **SharePoint / attachments** | Standard BC **Document Attachment** (file + URL/URI fields) | Item Card → Attachments / SharePoint | File name, media ref, and URL/SharePoint fields copied. |
| **Unit of Measure** | Shared UOM codes (PCS, BOX) | Units of Measure | Created in child if missing. |
| **Item Unit of Measure** | Qty per UOM, weight, size **for this item** | Item Card → Units of Measure | Copied per Item No. |
| **PIM attributes** | Title, brand, SEO, color options, … | **PIM Product Enrichment** | Copied as `PIM Product Value`. |

**Channel ≠ Variant.** Channel = *where the product is sold/shown*. Variant = *which SKU option* (BLACK / 500ML).  
**Channel ≠ Marketplace.** Channel = *PIM publication*. Marketplace = *which BC company receives the ERP item*.

Typical use:

1. Enable **WEBSHOP** (or **Published to Webshop**) → product appears in Product Webshop in **this** company.  
2. Enable channel **DE** → product is flagged for the Germany storefront.  
3. Tick marketplace **DE** and **Sync to companies** → Item 1000 is created/updated **in the Germany company**.

---

## Standard Business Central Item (already there)

Maintain these on the **Item Card**. PIM does not replace them.

### Variants (`Item Variant`)

- Item No. + Variant Code (e.g. `1000` + `BLK`).
- Description, blocked.
- **Synced:** code, descriptions, blocked.  
- **Not synced:** inventory per variant, reservations, warehouse.

Webshop JSON: `variants[]`.

### Picture (`Item.Picture`)

- MediaSet on the Item.
- **Synced:** each media ID inserted on the child item.
- Webshop uses the first picture on the catalog card and all pictures on the product page. Extra images on **Document Attachment** that look like images are also offered.

### SharePoint / document attachments (`Document Attachment`)

- Table ID = Item, No. = Item No.
- File name, extension, `Document Reference ID` (media).
- Any field whose name contains **URL**, **URI**, or **SHAREPOINT** is copied (SharePoint link / URI used by BC).
- **Synced** as above. Child company must be able to open the same SharePoint URL (same tenant / permissions).
- Webshop JSON: `documents[]` with fileName and url.

### Unit of Measure vs Item UOM

| Table | Meaning | Sync |
|-------|---------|------|
| `Unit of Measure` | Company-wide codes: PCS, BOX, KG | If the child does not have the code, sync **inserts** it. |
| Item fields | Base, Sales, Purchase UOM | Copied on the Item. |
| `Item Unit of Measure` | For this Item: qty per UOM, length/width/height, cubage, weight | Copied insert/update by Item No. + UOM code. |

Webshop JSON: `unitsOfMeasure[]` plus header `baseUom`.

---

## PIM (added by ICS Master)

| Object | What you do |
|--------|-------------|
| Family / attributes / options / categories | Setup once (**Create default PIM setup**) |
| PIM Product Value | Enrich title, description, color, … |
| **PIM Channel** | WEBSHOP, B2B, DE, AT, ES, CH, NP, CZ |
| **PIM Item Channel** | Enable this item on those channels |
| PIM Published | Shortcut for WEBSHOP (kept in sync) |
| PIM Marketplace | Map DE/AT/… to **exact** BC company name |
| PIM Item Marketplace | Which companies get ERP sync |

Tell Me: **PIM Channels**, **PIM Marketplaces**, **PIM Product Enrichment**.

---

## How sync to 6 companies works

Same **environment**, six **companies**. One app published in all of them.

```text
Master  --ChangeCompany(Germany)-->  Item 1000
        --ChangeCompany(Austria)-->  Item 1000
        --ChangeCompany(Spain)---->  Item 1000
        ... CH, NP, CZ
```

1. **PIM Marketplaces:** set **Company Name** = exact name from the Companies page, **Enabled**, optional **Template Item No.** (exists **in the child**, posting groups only).  
2. **Sync PIM setup to this company** — copies families, attributes, categories, **channels**.  
3. On the item: tick marketplaces, **Sync to companies**.  
4. **PIM Sync Log** shows Success / Error.

If a country is a **separate tenant**, `ChangeCompany` cannot reach it.

---

## What is copied vs not

### Copied (product master) — same Item No.

- Item description, search description, GTIN, tariff, origin, weights, volume  
- Base / sales / purchase UOM + **Unit of Measure** codes + **Item UOM** (qty, dimensions, weight)  
- Item category (BC) + PIM family / category / published  
- **PIM values** and **PIM item channels**  
- **Picture**  
- **Item variants**  
- Item translations (incl. variant code)  
- Extended texts  
- Item references (barcode etc., incl. variant + UOM)  
- **Document attachments** including SharePoint URL/URI  
- Standard Item Attributes **by Name** (IDs are local)  
- Optional: unit price; optional: posting groups from master  
- On **insert**: posting groups from **template item in the child**

### Never copied (operations stay in each company)

- Inventory / stock (including per variant)  
- Unit cost  
- Sales, purchase, warehouse documents  
- Whole Item `TransferFields`  
- PTE Marketplace Code / Master SKU  

---

## Webshop (preview in BC)

Reads **this company’s** Item + PIM. It does not call Shopify and is not a public website.

Shown when **Published to Webshop** and/or enabled on a channel with **Show in Webshop** (seed: **WEBSHOP**).

JSON includes: PIM attributes, channels, variants, UOMs, pictures, SharePoint/documents, translations, extended texts.

---

## Test in one pass

1. Master company: Create default PIM setup.  
2. Item Card: add picture, variant, extra UOM, SharePoint attachment.  
3. PIM Enrichment: family DEFAULT, enable **WEBSHOP**, fill title.  
4. Product Webshop: see picture, variant, UOM, channels.  
5. Marketplaces: set Germany company name → Sync PIM setup → tick DE on item → Sync to companies.  
6. Switch to Germany: same Item No.; picture, variants, UOM, attachments, PIM; stock is **not** the master’s.
