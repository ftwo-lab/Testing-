# Product families, default items, and variants

**Use native Item Variants** for V1/V2 when those SKUs already exist as **Item Variants** on the default item. Then **Add to Shopify** (Microsoft connector) publishes one Shopify product with those variants. Do not build a second Shopify sync.

**Attach the AL files:** use folder `PIM-Product-Family/` (or zip `PIM-Product-Family.zip`). Copy `src/*` into `ZVG-Nonpa/src/` and follow `PIM-Product-Family/README.md`.

This is how the **Cleaning Soap** and **Coca Cola** hierarchies from the product-structure examples are modelled on **standard Business Central items** (the Item Card / Item List — your default items).

Each sellable SKU stays a normal **Item**. The PIM layer groups those items so one SKU is the **default item (Parent)** and the others are **V1, V2, …** under it.

## The three levels

```
Main Product Family     Coca Cola                         Cleaning Soap
        │
Product Family          Glass Bottle / PET / Can          Cleaning Soap
        │
Default item (Parent)   0.5 L                             Blue, 1L
        │
Variants                0.33 L, 0.1 L, WM Edition         Pink 1L (V1), Yellow 1L (V2)
```

| Screenshot term | In Business Central | Where |
|-----------------|---------------------|--------|
| Main Product Family | PIM Product Family Group | Tell Me → **PIM Product Family Groups** |
| Product Family (Glass Bottle, PET, Can) | PIM Product Family | Tell Me → **PIM Product Families** |
| Classification | Family field `Classification` | Family card |
| Produkt (Main) / Parent | **Default Item** role on the Item | Item Card → Product Family |
| Varianten / V1 / V2 | **Variant** role + parent item | Item Card → Product Family |
| Variant Dimension (Gebinde Volumen) | Family field `Variant Dimension` | Family card |
| UOM / VAT | Standard Item `Base Unit of Measure` and `VAT Prod. Posting Group` | Item Card; copy from parent if needed |

## When an item is a variant vs a new default item

Use this rule from the Cleaning Soap example:

| Situation | Role | Why |
|-----------|------|-----|
| Same size and UOM, only color (or edition) changes — Blue 1L, Pink 1L, Yellow 1L | **One default item + variants** | Shared bottle UOM and VAT |
| Volume/packaging changes UOM — 5L **Canister** vs 1L **Bottle** | **Separate default items** | Different unit of measure, own master data |
| Packaging type changes — Glass vs PET vs Can | **Separate product families** under the same main family | Different classification |

Coca Cola uses **packaging as the product family** and **volume as the variant dimension**. Cleaning Soap 1L uses **color as the variant dimension**. Different soap volumes stay extra default items in the same family (Parent rows with no children).

Do **not** use native BC **Item Variants** (table 5401) for this. Those are sub-SKUs of a single item. The examples are separate items (own name, barcode, UOM, VAT) linked as a family.

## Setup (once)

1. Copy the new objects from `PIM-Locale/src/` into `ZVG-Nonpa` and publish (same as the locale extension).
2. In BC, Tell Me → **PIM Product Family Groups**.
3. Action **Create Example Families** to load Cleaning Soap + Coca Cola (Glass / PET / Can).
4. Optional: **PIM Product Families** → **Create Example Items** builds `PIM-SOAP-*` and `PIM-COKE-*` items (needs at least one existing item so posting groups can be copied).

Or create your own groups and families without the examples.

## Put this on your default items

### A. Make an existing item the default item (Parent)

1. Open the **Item Card**.
2. FastTab **Product Family**:
   - **Product Family** = e.g. `SOAP` or `COKE-GLS`
   - **Family Role** = **Default Item (Parent)**
3. Or: **Processing → Product Family → Make Default Item**.
4. The factbox **Family: Default Item and Variants** lists Parent / V1 / V2 for that family.

### B. Hang variants under that default item

1. Stay on the default item.
2. **Processing → Product Family → Add Variant**.
3. Pick the existing item (create the item first if it does not exist).
4. Set **Variant Dimension Value** (e.g. `Pink`, `0.33 L`).
5. Optional: **Copy UOM and VAT from Default Item** so Bottle / 19% posting group match the parent.

You can also open the **Product Family Card** and add rows in **Default Items and Variants**:

| Label | Item | Role | Default Item No. | Dimension value | UOM |
|-------|------|------|------------------|-----------------|-----|
| Parent | Cleaning Soap, Blue, 1L | Default Item | *(blank)* | Blue 1L | Bottle |
| V1 | Cleaning Soap, Pink, 1L | Variant | Blue 1L item | Pink 1L | Bottle |
| V2 | Cleaning Soap, Yellow, 1L | Variant | Blue 1L item | Yellow 1L | Bottle |
| Parent | Cleaning Soap, Blue, 2L | Default Item | *(blank)* | Blue 2L | Bottle |
| Parent | Cleaning Soap, Pink, 0.5L | Default Item | *(blank)* | Pink 0.5L | Bottle |
| Parent | Cleaning Soap, Yellow, 5L | Default Item | *(blank)* | Yellow 5L | Canister |

### C. Coca Cola-style families

1. Main family group **COKE** = Coca Cola.
2. Three families: **COKE-GLS** (Glass Bottle), **COKE-PET** (PET), **COKE-CAN** (Can).
3. On each family set **Classification** and **Variant Dimension** = `Gebinde Volumen`.
4. **Primary Default Item No.** = the main product (0.5 L glass, 0.5 L PET, 0.33 L can).
5. Add volume/edition SKUs as variants of that default item.

## Item Card fields

| Field | Meaning |
|-------|---------|
| Main Product Family | Group code (read-only, from the family) |
| Product Family | Family this SKU belongs to |
| Classification | Glass Bottle / PET / Can / Cleaning Soap |
| Family Role | Default Item or Variant |
| Family Label | Parent, V1, V2 (calculated) |
| Default Item No. | Parent item, only for variants |
| Variant Dimension | From the family (Gebinde Volumen, Color, …) |
| Variant Dimension Value | This SKU’s value (0.5 L, Pink, …) |

Item List shows Product Family, Role, and Label so you can filter default items vs variants.

## Object list (copy into ZVG-Nonpa)

| Type | ID | Name |
|------|----|------|
| Enum | 50110 | PIM Family Member Role |
| Table | 50120 | PIM Product Family Group |
| Table | 50121 | PIM Product Family |
| Table | 50122 | PIM Product Family Member |
| TableExt | 50120 | PIM Item Family (on Item) |
| Codeunit | 50120 | PIM Product Family Mgt. |
| Pages | 50120–50127 | Groups, families, members, factbox |
| PageExt | 50120 | Item Card |
| PageExt | 50121 | Item List |
