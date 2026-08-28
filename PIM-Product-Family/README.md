# Attach product family code + test on your default item

Copy these AL files into **ZVG-Nonpa** (ICS Master by ZVG), publish, then test on a normal **Item Card**.

A zip of this folder is in the repo root: `PIM-Product-Family.zip`.

---

## Part A — Attach the code

### 1. Copy files (merge, do not nest)

From this folder, copy **into the matching folders** of your app. Do **not** copy `PIM-Product-Family` as one subfolder.

| Copy this file | Into your app |
|---|---|
| `src/enum/PIMFamilyMemberRole.Enum.al` | `ZVG-Nonpa/src/enum/` |
| `src/table/PIMProductFamilyGroup.Table.al` | `ZVG-Nonpa/src/table/` |
| `src/table/PIMProductFamily.Table.al` | `ZVG-Nonpa/src/table/` |
| `src/table/PIMProductFamilyMember.Table.al` | `ZVG-Nonpa/src/table/` |
| `src/tableextension/PIMItemFamily.TableExt.al` | `ZVG-Nonpa/src/tableextension/` (create the folder if missing) |
| `src/codeunit/PIMProductFamilyMgt.Codeunit.al` | `ZVG-Nonpa/src/codeunit/` |
| `src/page/PIMProductFamilyGroups.Page.al` | `ZVG-Nonpa/src/page/` |
| `src/page/PIMProductFamilyGroupCard.Page.al` | `ZVG-Nonpa/src/page/` |
| `src/page/PIMProductFamilies.Page.al` | `ZVG-Nonpa/src/page/` |
| `src/page/PIMProductFamilyCard.Page.al` | `ZVG-Nonpa/src/page/` |
| `src/page/PIMProductFamilyMembers.Page.al` | `ZVG-Nonpa/src/page/` |
| `src/page/PIMFamilyMemberListPart.Page.al` | `ZVG-Nonpa/src/page/` |
| `src/page/PIMItemFamilyFactbox.Page.al` | `ZVG-Nonpa/src/page/` |
| `src/page/PIMFamiliesListPart.Page.al` | `ZVG-Nonpa/src/page/` |
| `src/pageextension/PIMItemCardFamily.PageExt.al` | `ZVG-Nonpa/src/pageextension/` |
| `src/pageextension/PIMItemListFamily.PageExt.al` | `ZVG-Nonpa/src/pageextension/` |

Terminal (from the repo root, if your app is beside this folder):

```bash
cp PIM-Product-Family/src/enum/*               ZVG-Nonpa/src/enum/
cp PIM-Product-Family/src/table/*              ZVG-Nonpa/src/table/
mkdir -p ZVG-Nonpa/src/tableextension
cp PIM-Product-Family/src/tableextension/*     ZVG-Nonpa/src/tableextension/
cp PIM-Product-Family/src/codeunit/*           ZVG-Nonpa/src/codeunit/
cp PIM-Product-Family/src/page/*               ZVG-Nonpa/src/page/
cp PIM-Product-Family/src/pageextension/*      ZVG-Nonpa/src/pageextension/
```

### 2. Check `app.json` in ZVG-Nonpa

IDs used: **50120–50127** (pages/tables/codeunit/enum) and Item fields **50120–50127**.

Your `idRanges` must cover that, for example:

```json
"idRanges": [
  { "from": 50100, "to": 50149 }
]
```

If compile says the object ID or field ID is already used, change every `50120`–`50127` in these files to free numbers in your range (keep the same relative order).

If compile says control `Control1` is not found on Item List, in `PIMItemListFamily.PageExt.al` change `addlast(Control1)` to match your Item List repeater name.

### 3. Publish

Open **ZVG-Nonpa** in VS Code → **F5** (or publish the extension). Wait until the sandbox/web client opens.

---

## Part B — Test on your default item

Use **your own existing item** (the SKU you already treat as the main/default product). Example below uses names from the Cleaning Soap sheet; substitute your item numbers.

### Test 1 — Create the family structure

1. In BC, Tell Me (Alt+Q) → **PIM Product Family Groups**.
2. **Create Example Families** (or create your own group + family).
3. Tell Me → **PIM Product Families**.
4. Open **SOAP** (Cleaning Soap) or the family you created.
5. Confirm **Classification** and **Variant Dimension** (e.g. Color).
6. Set **Variant Dimension** if you created the family yourself.

### Test 2 — Mark your item as the default item (Parent)

1. Tell Me → **Items** → open **your default item** (the parent SKU, e.g. Blue 1L).
2. Scroll to FastTab **Product Family** (near the bottom of the card).
3. **Product Family** = `SOAP` (or your family code).
4. **Family Role** = **Default Item (Parent)**.
5. **Variant Dimension Value** = e.g. `Blue 1L`.
6. Leave **Default Item No.** blank.
7. Save.
8. Check:
   - **Family Label** shows **Parent**
   - Right-hand factbox **Family: Default Item and Variants** lists this item as Parent
   - **Processing → Product Family → Open Product Family** shows the same row

### Test 3 — Add variants under that default item

1. Stay on the **default item** card.
2. Create (or pick) the related items first if they do not exist yet (e.g. Pink 1L, Yellow 1L). They must be normal Items.
3. **Processing → Product Family → Add Variant**.
4. Select the Pink item → OK.
5. Repeat **Add Variant** for the Yellow item.
6. On each variant item, set **Variant Dimension Value** (`Pink 1L`, `Yellow 1L`).
7. Check on the **family card** and on the default item factbox:

| Label | Item | Role |
|-------|------|------|
| Parent | your default item | Default Item |
| V1 | first variant | Variant (indented) |
| V2 | second variant | Variant (indented) |

8. Open a **variant** Item Card:
   - **Family Role** = Variant
   - **Default Item No.** = your parent item
   - **Family Label** = V1 or V2

### Test 4 — Copy UOM and VAT from the default item

1. Open a **variant** Item Card.
2. **Processing → Product Family → Copy UOM and VAT from Default Item**.
3. Confirm **Base Unit of Measure** and **VAT Prod. Posting Group** match the parent (Bottle / 19% posting group in the soap example).

### Test 5 — Extra default items (different volume / UOM)

1. Open a **different** item (e.g. Yellow 5L Canister).
2. Same **Product Family**, **Family Role = Default Item**.
3. Do **not** hang it under the 1L parent.
4. Family list should show a **second Parent** row with no V1/V2 under it.

That matches the soap sheet: 1L colors share one parent; other volumes stay their own default items.

### Test 6 — Item List

1. Tell Me → **Items**.
2. Confirm columns **Product Family**, **Family Role**, **Family Label**.
3. Filter **Family Role** = Default Item to see only parents.

---

## Expected result

On your default item you get the same structure as the examples:

```
Product Family Cleaning Soap
  Parent    <your default item>
    V1      <variant>
    V2      <variant>
  Parent    <other size / UOM — optional>
```

Coca Cola-style: use group **COKE** and families **COKE-GLS** / **COKE-PET** / **COKE-CAN**, with **Variant Dimension** = Gebinde Volumen.

Optional shortcut after at least one item exists: **PIM Product Families → Create Example Items** builds `PIM-SOAP-*` and `PIM-COKE-*` so you can inspect a finished Parent/V1/V2 tree before assigning your real SKUs.
