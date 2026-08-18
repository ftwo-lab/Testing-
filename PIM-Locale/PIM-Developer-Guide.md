# Product Information Management (PIM) on Business Central
## Technical Architecture & Developer Handbook

| | |
|---|---|
| **Project** | ZVG / ICS Master by ZVG |
| **Platform** | Microsoft Dynamics 365 Business Central |
| **Approach** | Business Central as the **main source of truth** with an embedded PIM layer |
| **Audience** | New developers and third-party implementation partners |
| **Version** | 2.0 |
| **Date** | August 2026 |
| **Code reference** | `PIM-Locale/` in repository `ftwo-lab/Testing-` |

---

## Table of contents

1. [Purpose of this document](#1-purpose-of-this-document)  
2. [Executive summary](#2-executive-summary)  
3. [What is PIM?](#3-what-is-pim)  
4. [What is Business Central?](#4-what-is-business-central)  
5. [PIM vs Business Central](#5-pim-vs-business-central)  
6. [Solution strategy: BC as the PIM backbone](#6-solution-strategy-bc-as-the-pim-backbone)  
7. [System architecture](#7-system-architecture)  
8. [Product data model — entities and fields](#8-product-data-model--entities-and-fields)  
9. [Product families, related items, and shared content](#9-product-families-related-items-and-shared-content)  
10. [Locales and translation](#10-locales-and-translation)  
11. [SharePoint attachments and documents (future)](#11-sharepoint-attachments-and-documents-future)  
12. [Technical implementation (AL extension)](#12-technical-implementation-al-extension)  
13. [Data flow diagrams](#13-data-flow-diagrams)  
14. [Developer environment setup](#14-developer-environment-setup)  
15. [Feature status and roadmap](#15-feature-status-and-roadmap)  
16. [Glossary](#16-glossary)  
17. [FAQ](#17-faq)  
18. [Repository and key object references](#18-repository-and-key-object-references)

---

## 1. Purpose of this document

This handbook is written for a **developer who is new to PIM and Business Central**. It explains:

- What we are building and why  
- How **product data** is structured in our solution  
- How **locales, families, channels, variants, and SharePoint** fit together  
- Where the **AL extension code** lives and how translation works today  
- What is **planned next** (including SharePoint document translation)

After reading this document, a developer should be able to open Business Central, understand the Item Card ecosystem, and start working on the `PIM-Locale` extension without prior PIM experience.

---

## 2. Executive summary

| Question | Answer |
|----------|--------|
| What is PIM? | Software to manage rich product content: descriptions, attributes, images, documents, and languages for multiple sales channels. |
| What is Business Central? | Microsoft ERP for finance, inventory, sales, purchasing, and operations. |
| Are they the same? | **No.** BC runs the business. PIM enriches product content. |
| What are we building? | A **PIM capability inside BC** — not a separate PIM database. |
| What is the main source? | **Business Central Item** and ZVG custom tables (Extended Text, families, SharePoint links). |
| How do languages work? | **Locales** (EN, DE, CH) with AI translation via **Azure Translator**. |
| Where is Channel stored? | Inside **Extended Text** (custom table), not as a separate synced master field. |

**Design principle:** One product master in BC. Locale-specific overlays for text. Families and SharePoint for shared group content. Channels captured in Extended Text per item/language.

---

## 3. What is PIM?

**PIM (Product Information Management)** centralises everything a customer sees about a product **before** they buy it.

| PIM manages | Examples |
|-------------|----------|
| Descriptions | Short name, long description, marketing copy |
| Attributes | Colour, material, certifications, size |
| Media | Pictures, videos, PDF datasheets |
| Languages | English, German, Swiss German per market |
| Channels | Web shop, B2B portal, marketplace, print catalog |
| Relationships | Product families, related items, variants |

PIM does **not** typically own stock levels, purchase prices, or general ledger posting — that is ERP territory.

---

## 4. What is Business Central?

**Microsoft Dynamics 365 Business Central (BC)** is the ERP used by ZVG. Native BC product features include:

| BC capability | Role |
|---------------|------|
| **Item** | SKU / product master |
| **Item Category** | Product categorisation |
| **Item Unit of Measure (UOM)** | How the item is sold, stocked, and priced |
| **Item Variant** | Size, colour, or other variant dimensions |
| **Item Attributes** | Flexible attribute values on items |
| **Item Picture** | Product imagery on the Item Card |
| **Inventory & sales** | Stock, orders, invoicing |

BC is strong at operations. It is **not** a full multilingual PIM out of the box. Our extension adds that layer.

---

## 5. PIM vs Business Central

| Dimension | Standalone PIM (e.g. Akeneo) | Business Central (ERP) | Our BC + PIM extension |
|-----------|------------------------------|------------------------|-------------------------|
| Master record | Separate product catalog | Item table | **Same Item table** |
| Languages | Native locales | Limited | **PIM Locale tables** |
| Channels | First-class channel objects | Not native | **Stored in Extended Text** |
| Families | Product models / families | Custom ZVG tables | **Product Family + Groups** |
| Documents | DAM / media library | SharePoint attachments | **SharePoint + future translation** |
| Translation | Built-in connectors | None | **Azure Translator** |
| Stock & pricing | Synced from ERP | Native | **Native — no sync needed** |

**Analogy:** Business Central is the warehouse and accounting office. PIM is the product catalogue, brochure, and website content. We built the catalogue **inside** the same building.

---

## 6. Solution strategy: BC as the PIM backbone

### 6.1 Core decisions

1. **Business Central Item is the single product master** — no duplicate SKU in an external PIM.  
2. **Locale-specific text** is stored in PIM overlay tables, not by overwriting English source data.  
3. **Channel** (sales/distribution channel) is captured in **Extended Text**, not as a separate synchronised master entity.  
4. **Product families** group items; family members can **share SharePoint notes and links**.  
5. **Variants** carry variant-level attributes tied to the base item.  
6. **SharePoint Attachments** hold supplementary files outside the core item blob fields.  
7. **AI translation** (Azure Translator) fills target locales from the English source locale.

### 6.2 High-level architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                     MICROSOFT DYNAMICS 365 BUSINESS CENTRAL               │
│                                                                          │
│  ┌──────────────────── ERP CORE ────────────────────┐                     │
│  │ Item │ Category │ UOM │ Variants │ Inventory │ Sales │ Finance       │ │
│  └──────────────────────────────────────────────────┘                     │
│                              │                                            │
│  ┌──────────────── ZVG PRODUCT CONTENT LAYER ──────────────────────┐   │
│  │ Extended Text (50116)  │ Channel, SEO, Description Text          │   │
│  │ Product Family / Groups │ Related items, family structure         │   │
│  │ Item Attributes        │ Colour, size, certifications             │   │
│  │ Item Picture           │ Product imagery                          │   │
│  │ SharePoint Attachments │ PDFs, datasheets, notes (per item/family)│   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                              │                                            │
│  ┌──────────────── PIM LOCALE EXTENSION (our AL code) ───────────────┐   │
│  │ Locales (EN/DE/CH) │ AI Translation │ Locale field overlays       │   │
│  │ Item Card UI        │ Extended Detail Card │ Marketing Text      │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────────┘
         │                    │                         │
         ▼                    ▼                         ▼
   Shopify / Web        Sales documents           SharePoint Online
   (per channel)        (Offer Confirmation)       (attachments)
```

---

## 7. System architecture

### 7.1 Logical layers

| Layer | Responsibility | Technology |
|-------|----------------|------------|
| **Presentation** | Item Card, Extended Detail Card, Marketing Text, family pages | BC Pages + PageExtensions |
| **PIM services** | Locale session, translation orchestration, field apply/save | AL Codeunits |
| **PIM persistence** | Locale definitions, translated field values, attributes | AL Tables |
| **Product content** | Extended Text, families, attributes, pictures | ZVG custom + standard BC tables |
| **External services** | Machine translation | Azure Translator API |
| **Document storage** | Files, notes, shared family links | SharePoint Online |
| **ERP core** | Item master, UOM, variants, stock, sales | Standard BC |

### 7.2 Component diagram

```
                    ┌─────────────────┐
                    │   Item Card     │
                    │  (PageExt)      │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
┌────────────────┐  ┌────────────────┐  ┌──────────────────┐
│ PIM Locale     │  │ PIM Locale     │  │ PIM AI           │
│ Session        │  │ Mgt.           │  │ Translator       │
│ (active locale)│  │ apply/save     │  │ Azure API        │
└────────────────┘  └───────┬────────┘  └──────────────────┘
                            │
         ┌──────────────────┼──────────────────┐
         ▼                  ▼                  ▼
┌────────────────┐ ┌──────────────┐ ┌───────────────────┐
│ PIM Item       │ │ PIM Item     │ │ PIM Item Locale   │
│ Locale Data    │ │ Locale Field │ │ Attribute         │
└────────────────┘ └──────────────┘ └───────────────────┘
                            │
         ┌──────────────────┼──────────────────┐
         ▼                  ▼                  ▼
┌────────────────┐ ┌──────────────┐ ┌───────────────────┐
│ Item (BC)      │ │ Extended Text│ │ Item Attributes   │
│                │ │ (50116)      │ │ Item Picture      │
└────────────────┘ └──────────────┘ └───────────────────┘
                            │
                            ▼
                   ┌──────────────────┐
                   │ SharePoint       │
                   │ Attachments      │
                   └──────────────────┘
```

---

## 8. Product data model — entities and fields

This section defines **every major product concept** in our solution. A new developer should memorise this table first.

### 8.1 Entity reference

| Entity | What it is | Where stored | PIM / locale behaviour |
|--------|------------|--------------|------------------------|
| **Item** | Base product / SKU master | BC `Item` table | Description and text fields translated per locale |
| **Category** | Product categorisation (hierarchy) | BC `Item Category` | Category **codes** are not translated; descriptions may be extended later |
| **Item UOM** | Unit of measure (piece, roll, pallet) | BC `Item Unit of Measure` | UOM **codes** are operational — not translated |
| **Variants** | Variant-level SKU (size, colour, etc.) tied to base item | BC `Item Variant` + variant attributes | Variant **attributes** (text) can be translated; codes are not |
| **Extended Text** | Free-text / rich content: descriptions, SEO, **Channel** | ZVG table **50116** `Extended Text`, page **50189** Extended Detail Card | **Fully locale-aware**; Channel stored here |
| **Channel** | Sales / distribution channel identifier | **Inside Extended Text** (`Channel Code` field) — **not** a separate synced master | Per item + language + channel row in Extended Text |
| **Item Attributes** | Flexible attributes (Farbe, material, etc.) | BC `Item Attribute` + `Item Attribute Value Mapping` | Text attribute **values** translated per locale |
| **Pictures** | Product imagery | BC `Item Picture` | Binary media — not text-translated; may have locale-specific images in future |
| **SharePoint Attachments** | Supplementary files (PDF, Word, datasheets) | SharePoint via BC integration | **Outside** core item record; **document translation planned** |
| **Locales** | Language/market-specific data overlay | PIM tables (`PIM Locale`, `PIM Item Locale Data`, etc.) | EN = source; DE, CH = targets |
| **Product Family** | Groups related products under a family code | ZVG custom tables | Family-level metadata; members share structure |
| **Product Family Groups** | Higher-level grouping of families | ZVG custom tables | Organisational hierarchy for catalogues |
| **Related Items** | Cross-sell, upsell, spare parts links | ZVG / BC item references | Links by Item No.; content on each item still locale-specific |

### 8.2 Extended Text — the rich content hub

**Extended Text** (table 50116) is the most important custom table for PIM content. Each record is keyed by:

| Key field | Purpose |
|-----------|---------|
| Table Name | Links to `Item` |
| No. (Item No.) | Which product |
| Language Code | e.g. CHS, ENU (BC language, separate from PIM locale overlay) |
| Channel Code | **Sales / distribution channel** — see below |
| Item Variant Code | Optional variant scope |

**Content fields on Extended Detail Card:**

| Field | Type | Purpose |
|-------|------|---------|
| Description Text | Blob | Long product description |
| SEO Keyword | Text | Search optimisation |
| SEO Description | Text | Meta description |
| Special Instruction Text | Blob | Handling / usage instructions |
| Alternative No. | Text | Cross-reference number |

### 8.3 Channel — important design rule

> **Channel is NOT maintained as an independent master field that syncs from an external system.**

Instead:

- **Channel** represents a sales or distribution channel (e.g. web shop, B2B portal, marketplace).  
- It is stored **within Extended Text** using the **Channel Code** field.  
- Each combination of **Item + Language Code + Channel Code** (+ optional variant) can have its own Extended Text row.  
- This allows **channel-specific descriptions and SEO** without a separate channel sync engine.

```
Item 000000385
 ├── Extended Text row: Language=ENU, Channel=WEB   → English web copy
 ├── Extended Text row: Language=ENU, Channel=B2B   → English B2B copy
 └── Extended Text row: Language=DEU, Channel=WEB   → German web copy (via PIM locale)
```

When the user switches PIM locale to **Germany**, the Extended Detail Card shows the **German overlay** for the active Extended Text record.

### 8.4 Variants

| Concept | Detail |
|---------|--------|
| **Base item** | Master SKU (e.g. `000000385`) |
| **Item Variant** | Sub-SKU for size, colour, packaging (e.g. `BLUE-L`) |
| **Variant attributes** | Attributes tied to the variant (size, colour) |
| **PIM rule** | Variant codes and numeric values are **not translated**. Text attribute values **are translated** when locale is active. |

### 8.5 Category and UOM

| Entity | Translated? | Notes |
|--------|-------------|-------|
| **Item Category Code** | No | Operational code (`CCC-01`) — stays as-is |
| **Category description** | Future | May add locale overlay if needed |
| **Item UOM Code** | No | `ROLL`, `PCS` — operational |
| **UOM description** | Future | Standard BC unit names |

### 8.6 Pictures

| Aspect | Detail |
|--------|--------|
| Storage | BC `Item Picture` table (binary) |
| UI | Item Card picture factbox |
| Locale | Currently **one picture set per item**; locale-specific imagery is a future enhancement |
| vs SharePoint | Pictures are **in BC**; SharePoint holds **documents** (PDFs, spec sheets) |

### 8.7 Locales

| Locale code | Market | BC language | Azure tag | Role |
|-------------|--------|-------------|-----------|------|
| **EN** | English | ENU | `en` | **Source locale** — original content |
| **DE** | Germany | DEU | `de` | Target — AI translation |
| **CH** | Swiss German | DES | `de` | Target — AI translation |

Locale data is stored in PIM tables and **applied on screen** when the user selects a locale on the Item Card. English source data in BC is **never overwritten**.

---

## 9. Product families, related items, and shared content

### 9.1 Product Family and Product Family Groups

```
Product Family Group (e.g. "Cleaning Products")
 └── Product Family (e.g. "CC -03" ClaraClean line)
      ├── Item 000000385  ClaraClean Brillant Eco
      ├── Item 000000386  ClaraClean variant B
      └── Item 000000387  Related accessory
```

| Concept | Purpose |
|---------|---------|
| **Product Family Code** | Groups items in the same product line (visible on Item Card) |
| **Product Family Group** | Higher-level catalogue grouping for reporting and navigation |
| **Family members** | All items sharing a family code |

### 9.2 Shared SharePoint notes and links

Family members can **share** supplementary content:

| Shared at family level | Stored in |
|------------------------|-----------|
| Common datasheets | SharePoint folder / links shared across family |
| Compliance documents | SharePoint |
| Marketing notes | SharePoint notes or links |

**Design intent:** Avoid uploading the same PDF to every item in a family. Maintain shared links at family or group level; items **reference** or **inherit** access where the ZVG extension defines it.

> **Developer note:** Implement family-level SharePoint inheritance according to ZVG table design. The PIM locale extension today focuses on **item-level** text. Family-level sharing is part of the broader ZVG SharePoint integration.

### 9.3 Related Items

| Type | Example |
|------|---------|
| Cross-sell | Detergent + rinse aid |
| Accessory | Machine + spare part |
| Substitute | Alternative SKU |

Related items are **links between Item records**. Each linked item maintains its **own locale content**. Translation does not automatically copy between related items.

---

## 10. Locales and translation

### 10.1 User workflow

```
1. User opens Item Card (e.g. 000000385)
2. Processing → Locales → Germany
3. System calls Azure Translator for all configured text fields
4. Translated values stored in PIM tables
5. Item Card, Extended Detail Card, and Marketing Text show German content
6. Processing → Locales → English restores source view
```

### 10.2 What is translated

| Source | Stored in | Displayed on |
|--------|-----------|--------------|
| Item.Description, Description 2 | PIM Item Locale Field | Item Card |
| Marketing Text | PIM Item Locale Data | Edit Marketing Text page |
| Extended Text fields (50116) | PIM Item Locale Field (+ Long Value blob) | Extended Detail Card |
| Item Attribute values (text) | PIM Item Locale Attribute | Item Attributes factbox |
| Custom tables (via setup) | PIM Item Locale Field | Configured pages |

### 10.3 What is NOT translated

| Data | Reason |
|------|--------|
| Item No., GTIN, barcodes | Identifiers |
| Category codes, UOM codes | Operational codes |
| Channel codes | Operational identifiers |
| Numeric attribute values | Not language content |
| Prices, quantities | ERP transactional data |
| Pictures (binary) | Media — separate workflow |

### 10.4 Translation architecture

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────────┐
│ Source text │────▶│ PIM AI Translator │────▶│ Azure Translator API │
│ (EN locale) │     │ (codeunit)        │     │ (eastasia region)    │
└─────────────┘     └────────┬─────────┘     └─────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────┐
              │ PIM Item Locale Data         │
              │ PIM Item Locale Field        │
              │ PIM Item Locale Attribute    │
              └──────────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────┐
              │ Apply to UI (RecordRef)      │
              │ Item Card / Extended Detail  │
              └──────────────────────────────┘
```

### 10.5 Azure configuration

| Setting | Value |
|---------|-------|
| Resource | MSBCTranslator |
| API | Text Translation |
| Endpoint | `https://api.cognitive.microsofttranslator.com` |
| Region | `eastasia` |
| BC setup page | PIM AI Setup |
| Prerequisite | `allowHttpClientRequests: true` in app.json |

---

## 11. SharePoint attachments and documents (future)

### 11.1 Current state

| Aspect | Status |
|--------|--------|
| SharePoint Attachments on Item Card | **Exists** in ZVG BC |
| File storage | **Outside** core Item record (SharePoint Online) |
| Text field translation | **Done** (PIM Locale extension) |
| **Document translation** (PDF, Word) | **Planned — not yet implemented** |

### 11.2 Planned document translation flow

SharePoint files cannot use the Text Translation API. They require **Azure Document Translation**:

```
SharePoint file (PDF/DOCX)
        │
        ▼ Download
Azure Blob Storage (source container)
        │
        ▼ Document Translation API
Azure Blob Storage (target container, e.g. /de/)
        │
        ▼ Upload
SharePoint (translated file, e.g. datasheet_DE.pdf)
```

| Requirement | Detail |
|-------------|--------|
| Azure Storage Account | Source + target blob containers |
| Document endpoint | `https://msbctranslator.cognitiveservices.azure.com/` |
| BC action (future) | e.g. "Translate SharePoint Documents to German" on Item Card |
| Family sharing | Translated family documents available to all family members |

### 11.3 SharePoint vs Pictures vs Extended Text

| Content type | Location | Translation approach |
|--------------|----------|----------------------|
| Short / long text | Extended Text, Item fields | **Text API** (live today) |
| Product photos | Item Picture | Locale-specific images (future) |
| PDF datasheets | SharePoint Attachments | **Document API** (planned) |
| Family shared notes | SharePoint links | Document or link per locale (planned) |

---

## 12. Technical implementation (AL extension)

### 12.1 Repository structure

```
PIM-Locale/
├── PIM-Developer-Guide.md      ← This document
├── README-INSTALL.txt          ← Install steps
├── app.json
└── src/
    ├── table/                  ← PIM data tables
    ├── page/                   ← Admin & setup pages
    ├── pageextension/          ← Item Card, Extended Detail, Marketing Text
    ├── codeunit/               ← Business logic
    └── enum/                   ← Status, AI provider
```

Merge `src/` contents into `ZVG-Nonpa/src/` — **do not** nest as a sub-app.

### 12.2 PIM tables

| Table | Purpose |
|-------|---------|
| `PIM Locale` | Locale definitions (EN, DE, CH) |
| `PIM Item Locale Data` | Header per item + locale (description, marketing text, status) |
| `PIM Item Locale Field` | Field-level translated values; `Long Value` blob for large text |
| `PIM Item Locale Attribute` | Translated attribute values |
| `PIM Locale Table Setup` | Register tables for translation (50116 Extended Text) |
| `PIM AI Setup` | Azure Translator configuration |

### 12.3 Codeunits

| Codeunit | Responsibility |
|----------|----------------|
| `PIM Locale Session` | SingleInstance — tracks active locale per user session |
| `PIM Locale Mgt.` | Translate, apply, save locale fields; blob handling; table 50116 setup |
| `PIM AI Translator` | Azure Translator / Claude / Azure OpenAI integration |
| `PIM Locales Install` | Default locales and setup on install |

### 12.4 Page extensions

| Extension | Extends | Purpose |
|-----------|---------|---------|
| `PIM Item Card Locales` | Item Card | Locales menu; apply translated item fields |
| `PIM Extended Detail Card Locales` | Extended Detail Card (50189) | Show translated Extended Text incl. Channel row |
| `PIM Edit Marketing Text Locales` | Edit Marketing Text | Show translated marketing copy |

### 12.5 Key ZVG object IDs

| Object | ID | Name |
|--------|-----|------|
| Table | 50116 | Extended Text |
| Page | 50189 | Extended Detail Card |
| Link field | 2 | No. (Item No.) |
| PIM starter IDs | 50100–50149 | May differ in production (503xx / 506xx) |

### 12.6 app.json requirements

```json
{
  "idRanges": [{ "from": 50100, "to": 50149 }],
  "allowHttpClientRequests": true
}
```

BC: **Extension Management → Allow HTTPClient Requests = ON**

---

## 13. Data flow diagrams

### 13.1 Item enrichment flow (end-to-end)

```
┌──────────┐    ┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│ Create   │───▶│ Assign      │───▶│ Fill Extended│───▶│ Add pictures│
│ Item     │    │ Category,   │    │ Text + Channel│   │ + SharePoint│
│          │    │ UOM, Family │    │ + attributes │    │ attachments │
└──────────┘    └─────────────┘    └──────────────┘    └──────┬──────┘
                                                              │
                                                              ▼
                                                    ┌─────────────────┐
                                                    │ Locales → DE/CH │
                                                    │ AI translation  │
                                                    └────────┬────────┘
                                                             │
                              ┌──────────────────────────────┼──────────────────┐
                              ▼                              ▼                  ▼
                        Item Card (DE)              Extended Detail (DE)   Marketing Text (DE)
                              │                              │                  │
                              └──────────────────────────────┴──────────────────┘
                                                             │
                                                             ▼
                                                    Shopify / Sales docs / Web
```

### 13.2 Channel + locale matrix (conceptual)

| Item | Language Code | Channel Code | PIM Locale | Content |
|------|---------------|--------------|------------|---------|
| 000000385 | ENU | WEB | EN (source) | English web description |
| 000000385 | ENU | B2B | EN (source) | English B2B description |
| 000000385 | ENU | WEB | DE (overlay) | German web description (translated) |
| 000000385 | CHS | WEB | CH (overlay) | Swiss German web description |

---

## 14. Developer environment setup

### 14.1 Prerequisites

| Tool | Purpose |
|------|---------|
| Visual Studio Code | AL development |
| AL Language extension | Compile and publish |
| Business Central sandbox | Testing |
| Git | Source control |
| Azure Portal access | Translator API key (for translation testing) |

### 14.2 First-time setup

1. Clone `https://github.com/ftwo-lab/Testing-`  
2. Copy `PIM-Locale/src/*` into `ZVG-Nonpa/src/`  
3. Align object IDs with `app.json`  
4. Publish extension (F5)  
5. In BC: **PIM Locales** → Create Default Locales  
6. In BC: **PIM AI Setup** → Enable, Azure Translator, key, region `eastasia`  
7. Test item `000000385`: Locales → Germany → Extended Details  

### 14.3 Recommended learning path for a new developer

| Step | Action | Outcome |
|------|--------|---------|
| 1 | Read Sections 2, 6, 8, 10 of this document | Understand domain model |
| 2 | Open Item `000000385` in BC | See real data |
| 3 | Switch Locales → Germany | See translation in action |
| 4 | Open Extended Detail Card | See Channel + SEO + Description Text |
| 5 | Clone `PIM-Locale` and trace `PIMLocaleMgt.Codeunit.al` | Understand code flow |
| 6 | Publish to sandbox | Confirm you can compile |

---

## 15. Feature status and roadmap

| Feature | Status |
|---------|--------|
| Locales EN / DE / CH | ✅ Implemented |
| AI text translation (Azure Translator) | ✅ Implemented |
| Item Card field translation | ✅ Implemented |
| Extended Detail Card (incl. blob Description Text) | ✅ Implemented |
| Marketing Text page translation | ✅ Implemented |
| Item Attributes (text values) | ✅ Implemented |
| PIM Locale Table Setup (custom tables) | ✅ Implemented |
| Channel in Extended Text | ✅ Data model exists; locale overlay applies |
| Product Family / Groups | ✅ ZVG tables; locale on family metadata — future |
| Related items | ✅ Links exist; per-item locale |
| SharePoint Attachments | ✅ Storage exists |
| **SharePoint document translation** | 🔲 **Planned** |
| Locale-specific product pictures | 🔲 Planned |
| Publish / review workflow | 🔲 Partial (translation status enum) |
| Shopify per-locale sync | 🔲 Depends on Shopify connector |

---

## 16. Glossary

| Term | Definition |
|------|------------|
| **PIM** | Product Information Management |
| **ERP** | Enterprise Resource Planning — Business Central |
| **Item** | Product SKU — the master record in BC |
| **Locale** | Language/market overlay (EN, DE, CH) |
| **Source locale** | Original language (English) — never overwritten |
| **Target locale** | Translated language (German, Swiss German) |
| **Channel** | Sales/distribution channel — stored in Extended Text `Channel Code` |
| **Extended Text** | ZVG table 50116 — rich text, SEO, channel-specific content |
| **Product Family** | Group of related items under one family code |
| **Product Family Group** | Higher-level grouping of product families |
| **Related Items** | Linked items (cross-sell, accessories) |
| **Variant** | Item sub-SKU (size, colour) tied to base item |
| **Item UOM** | Unit of measure (roll, piece, pallet) |
| **Category** | Item categorisation code and hierarchy |
| **Item Attributes** | Flexible name/value pairs on items |
| **Pictures** | Product images on Item Card |
| **SharePoint Attachments** | Files stored in SharePoint, linked from BC |
| **PageExt** | AL page extension — extends standard BC pages |
| **RecordRef** | AL variable for generic record access (used for blob fields) |
| **Syndication** | Publishing product data to external channels |

---

## 17. FAQ

**Q: Is Business Central a PIM system?**  
A: No. BC is an ERP. We add PIM capabilities through a custom AL extension.

**Q: Where is the main source of product truth?**  
A: The BC **Item** table and ZVG **Extended Text** table. PIM tables store locale overlays only.

**Q: Why is Channel inside Extended Text instead of its own table?**  
A: Channel-specific copy (web vs B2B) naturally varies per item and language. Storing it in Extended Text avoids a separate sync layer and keeps channel content with the product description it belongs to.

**Q: Do family members automatically share translated text?**  
A: No. Family members share **SharePoint notes and links** at family level. Each item's text fields are still translated per item.

**Q: Are variant codes translated?**  
A: No. Variant codes and numeric values stay as-is. Text variant attributes can be translated.

**Q: Does German translation overwrite English in the database?**  
A: No. English remains in source fields. German is stored in PIM locale tables and shown when locale DE is active.

**Q: How will SharePoint PDFs be translated?**  
A: Future feature using Azure **Document Translation** API — separate from text field translation.

---

## 18. Repository and key object references

| Resource | Location |
|----------|----------|
| AL source code | `PIM-Locale/` in `ftwo-lab/Testing-` |
| Install guide | `PIM-Locale/README-INSTALL.txt` |
| This handbook | `PIM-Locale/PIM-Developer-Guide.md` |
| BC extension name | ICS Master by ZVG |
| Extended Text table | 50116 |
| Extended Detail Card page | 50189 |
| Azure Translator resource | MSBCTranslator (eastasia) |

---

## Document control

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Aug 2026 | Initial developer guide |
| 2.0 | Aug 2026 | Professional architecture; product model; families; channel in Extended Text; SharePoint future; removed weekly progress |

---

*Prepared for ZVG / third-party developer handoff. Business Central remains the main source. PIM locale extension enriches product content for multi-market, multi-channel distribution.*
