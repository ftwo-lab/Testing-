# PIM Developer Guide
## Building a Product Information Management System on Microsoft Dynamics 365 Business Central

**Audience:** Fresh developers joining the ZVG / ICS Master project  
**Purpose:** Explain what PIM is, how it differs from Business Central, and how we are building a PIM solution **with Business Central as the main source of truth**.

**Version:** 1.0  
**Date:** August 2026  
**Reference implementation:** `PIM-Locale` folder in this repository

---

## 1. Executive summary (read this first)

| Question | Short answer |
|----------|--------------|
| **What is PIM?** | A system to manage rich product content (descriptions, images, attributes, translations) for many channels (web, print, marketplaces). |
| **What is Business Central?** | An ERP system for finance, inventory, sales, purchasing, and operations. |
| **Are they the same?** | **No.** BC is the operational backbone. PIM is the product content layer on top. |
| **Our approach** | **Business Central is the main source.** We extend BC with PIM features (locales, translations, extended details, attributes) instead of buying a separate PIM and syncing everything. |
| **Inspiration** | Akeneo-style locales (EN / DE / CH) with AI translation, shown directly on the Item Card. |

---

## 2. What is PIM?

**PIM = Product Information Management**

PIM is software used to:

- Store and organize **product information** in one place
- Manage **multiple languages** (locales)
- Manage **attributes** (color, size, material, certifications)
- Manage **marketing text**, SEO content, images, documents
- Publish the same product data to **many channels**:
  - Company website (Shopify, Magento, etc.)
  - Marketplaces (Amazon, eBay)
  - Printed catalogs and sales documents
  - B2B portals

### Real-world example

A cleaning product in our system:

| Data type | Example |
|-----------|---------|
| SKU / Item No. | `000000385` |
| Description (EN) | ClaraClean® Brillant Eco – ecological rinse aid |
| Description (DE) | ClaraClean® Brillant Eco – ökologischer Glanztrockner |
| Marketing text | Long sales copy for website |
| SEO keyword | "Glass cleaning rinse aid" |
| Attributes | Color, product family, certifications |
| Images | Product photos in SharePoint |
| Documents | PDF datasheets |

**PIM owns the rich content.** The ERP still owns stock, price, and orders.

---

## 3. What is Business Central?

**Microsoft Dynamics 365 Business Central (BC)** is an ERP. It is strong at:

- Items (SKU master)
- Inventory and warehouses
- Sales orders and invoices
- Purchase and vendors
- Finance and posting
- Basic item fields: Description, Unit of Measure, GTIN, categories

BC is **not** designed as a full PIM out of the box. It has:

- One main **Description** per item (limited locale support natively)
- **Item Attributes** (good, but not a full Akeneo-style experience)
- **Marketing Text** (newer versions, Entity Text)
- **Extended Text** (notes, not full multilingual PIM)

So customers often add PIM **on top of** BC or **inside** BC via customization.

---

## 4. PIM vs Business Central — key differences

| Topic | PIM (e.g. Akeneo) | Business Central (ERP) |
|-------|-------------------|-------------------------|
| **Primary goal** | Product content & syndication | Business operations & finance |
| **Master data** | Marketing-ready product content | Operational item master |
| **Languages** | Core feature (locales, channels) | Limited; needs extension |
| **Attributes** | Flexible families, schemas | Item Attributes (simpler) |
| **Workflow** | Enrich → review → publish | Create item → sell → ship |
| **Channels** | Export to web, marketplaces | Sales documents, API, integrations |
| **Images/docs** | DAM, media library | SharePoint attachments, files |
| **Who uses it** | Marketing, product managers | Finance, sales, warehouse |
| **Stock & price** | Usually synced from ERP | Native strength |

### Simple analogy

- **Business Central** = the warehouse + cash register + accounting  
- **PIM** = the product catalog + brochure + website content  

They work together. The **Item No.** links them.

---

## 5. Our strategy: Business Central as the main source (BC PIM)

We are **not** replacing Business Central with a separate PIM tool as the master system.

We are building:

> **A PIM layer inside Business Central**, where BC remains the single source of truth for items, and we add locale-aware content, translation, and extended product data.

### Why this approach?

| Benefit | Explanation |
|---------|-------------|
| **One system** | Users stay on Item Card; no duplicate item masters |
| **No heavy sync** | No nightly Akeneo ↔ BC sync jobs for 50+ fields |
| **Lower cost** | No separate PIM license for basic needs |
| **Fits ZVG** | Custom Extended Details, SharePoint, Shopify already in BC |

### What we add on top of standard BC

```
┌─────────────────────────────────────────────────────────────┐
│                    BUSINESS CENTRAL (ERP)                    │
│  Item Card │ Inventory │ Sales │ Purchase │ Finance          │
├─────────────────────────────────────────────────────────────┤
│              PIM LAYER (our custom extension)                │
│  • Locales (EN, DE, CH)                                      │
│  • AI Translation (Azure Translator)                         │
│  • Translated fields on Item Card                            │
│  • Extended Detail Card (SEO, description text)              │
│  • Marketing Text per locale                                 │
│  • Item Attributes per locale                                │
│  • Locale table setup for custom tables                      │
│  • (Future) SharePoint document translation                  │
└─────────────────────────────────────────────────────────────┘
         │                              │
         ▼                              ▼
    Shopify / Web                 Sales PDF / Print
```

---

## 6. How our PIM works (functional overview)

### 6.1 Locales

We use an **Akeneo-style locale** model:

| Locale code | Name | BC language | Azure Translator tag |
|-------------|------|-------------|----------------------|
| EN | English | ENU | en |
| DE | Germany | DEU | de |
| CH | Swiss German | DES | de |

- **EN** = source locale (original content)
- **DE / CH** = target locales (translated content)

User flow on **Item Card**:

1. Open item
2. **Processing → Locales → Germany**
3. System translates all configured text and shows German on the page
4. Open **Extended Details** → German SEO and description
5. Open **Marketing Text** action → German marketing copy

### 6.2 What gets translated

| Data area | Where it lives | Where user sees translation |
|-----------|----------------|----------------------------|
| Item fields | Item table | Item Card (Description, etc.) |
| Marketing text | PIM Item Locale Data + Entity Text | Marketing Text action |
| Extended details | Table 50116 Extended Text | Extended Detail Card |
| Item attributes | PIM Item Locale Attribute | Item Card / attributes |
| Custom tables | PIM Locale Table Setup | Configured pages |

**Not translated:** codes, numbers, GTIN, prices, quantities.

### 6.3 AI translation

- **Provider:** Azure Translator (resource: MSBCTranslator, region: eastasia)
- **Config page:** PIM AI Setup
- **Flow:** Source locale text → API → stored in PIM tables → shown on UI

---

## 7. Technical architecture for developers

### 7.1 Project structure (ZVG-Nonpa)

Files from `PIM-Locale/src/` are merged into the main extension:

```
ZVG-Nonpa/src/
├── table/          ← PIM data tables
├── page/           ← Setup & list pages
├── pageextension/  ← Item Card, Extended Detail Card, Marketing Text
├── codeunit/       ← Business logic
└── enum/           ← Status, AI provider
```

**Do not** copy `PIM-Locale` as a subfolder. Merge files into existing `src/` folders.

### 7.2 Core data model

```
PIM Locale
    └── Defines EN, DE, CH (language codes, AI tags)

PIM Item Locale Data (header per item + locale)
    └── Description, Marketing Text, Extended Description, status

PIM Item Locale Field (field-level storage)
    └── Item No. + Locale + Table No. + Field No. + Value
    └── Supports long/blob text via Long Value blob field

PIM Item Locale Attribute
    └── Translated attribute values per locale

PIM Locale Table Setup
    └── Register custom tables (e.g. Extended Text 50116) for translation

PIM AI Setup
    └── Azure Translator endpoint, key, region
```

### 7.3 Core codeunits

| Codeunit | Responsibility |
|----------|----------------|
| **PIM Locale Session** | SingleInstance: remembers active locale (EN/DE/CH) per user session |
| **PIM Locale Mgt.** | Locale logic, translate all fields, apply locale to records, blob handling |
| **PIM AI Translator** | Calls Azure Translator / Claude / Azure OpenAI |
| **PIM Locales Install** | Creates default locales on install |

### 7.4 Key pages & extensions

| Object | Purpose |
|--------|---------|
| PIM Locales | Admin: manage locale list |
| PIM AI Setup | Azure API configuration |
| PIM Locale Table Setup | Register Extended Details table |
| PIM Item Card Locales (PageExt) | Locales menu on Item Card |
| PIM Extended Detail Card Locales | Show translated extended details |
| PIM Edit Marketing Text Locales | Show translated marketing text |

### 7.5 Object ID ranges

Starter repo uses **50100–50149**.  
ZVG production may use **503xx / 506xx** — developer must align IDs with `app.json` and avoid conflicts.

### 7.6 app.json requirements

```json
{
  "idRanges": [{ "from": 50100, "to": 50149 }],
  "allowHttpClientRequests": true
}
```

In BC: **Extension Management → Allow HTTPClient Requests = ON**

---

## 8. Standard BC vs our PIM — field mapping

| BC standard | Our PIM enhancement |
|-------------|---------------------|
| Item.Description | Translated per locale; shown on Item Card when locale active |
| Item Attributes | Values translated; stored in PIM Item Locale Attribute |
| Marketing Text (Entity Text) | Translated; shown in Edit Marketing Text page |
| Extended Text (custom 50116) | Description Text (blob), SEO fields; Extended Detail Card |
| SharePoint attachments | **Not yet** — future Document Translation API |

---

## 9. Comparison with standalone PIM (e.g. Akeneo)

| Feature | Akeneo PIM | Our BC PIM |
|---------|------------|------------|
| Item master | Separate catalog | BC Item table |
| Locales | Native | PIM Locale table |
| Translation | Built-in / plugins | Azure Translator |
| Workflows | Review, publish channels | Translation status enum (Draft, AI Generated, Reviewed) |
| Syndication | Connectors to Shopify, etc. | BC integrations (Shopify app, etc.) |
| Complexity | High; second system | Medium; one BC extension |
| Best for | Large catalogs, many channels | BC-centric companies (like ZVG) |

We took **Akeneo concepts** (locales, locale-specific fields) and implemented them **inside BC**.

---

## 10. Developer onboarding checklist

### Week 1 — Understand the domain

- [ ] Read this document
- [ ] Open BC and find **Item Card** for item `000000385`
- [ ] Try **Processing → Locales → Germany**
- [ ] Open **Extended Details** and **Marketing Text**
- [ ] Read `PIM-Locale/README-INSTALL.txt`

### Week 2 — Understand the code

- [ ] Clone repo: `https://github.com/ftwo-lab/Testing-/tree/main/PIM-Locale`
- [ ] Trace flow: `PIMItemCardLocales.PageExt.al` → `PIMAITranslator` → `PIMLocaleMgt`
- [ ] Open tables in BC: PIM Locales, PIM AI Setup, PIM Locale Table Setup
- [ ] Publish extension locally (F5)

### Week 3 — Extend

- [ ] Add a new locale (e.g. FR)
- [ ] Register another custom table in PIM Locale Table Setup
- [ ] Fix/report bugs with blob fields (Description Text)

---

## 11. Environment setup (developer)

### Tools

- Visual Studio Code
- AL Language extension
- Business Central sandbox or Docker container
- Git

### Azure (for translation)

| Setting | Value |
|---------|-------|
| Resource | MSBCTranslator |
| Type | Text Translation |
| Region | eastasia |
| Endpoint | `https://api.cognitive.microsofttranslator.com` |
| API Key | From Azure Portal → Keys and Endpoint |

### BC setup after publish

1. Search **PIM Locales** → Create Default Locales  
2. Search **PIM AI Setup** → Enable, Azure Translator, key, region  
3. Extension Management → Allow HTTPClient Requests  
4. Test on one item  

---

## 12. Roadmap (what exists vs planned)

| Feature | Status |
|---------|--------|
| Locales EN / DE / CH | ✅ Done |
| AI translation (Azure Translator) | ✅ Done |
| Item Card field translation | ✅ Done |
| Extended Detail Card translation | ✅ Done |
| Marketing Text translation | ✅ Done |
| Item Attributes translation | ✅ Done |
| Custom table setup | ✅ Done |
| Blob field (Description Text) | ✅ Done (with Long Value storage) |
| SharePoint document translation | 🔲 Planned |
| Publish workflow (review/approve) | 🔲 Partial (status enum exists) |
| Shopify sync per locale | 🔲 Depends on Shopify connector |
| Channel-specific content | 🔲 Future |

---

## 13. Glossary for new developers

| Term | Meaning |
|------|---------|
| **PIM** | Product Information Management |
| **ERP** | Enterprise Resource Planning (BC) |
| **Locale** | Language/market variant (EN, DE, CH) |
| **Source locale** | Original language content is written in |
| **Target locale** | Language we translate into |
| **Item** | Product SKU in BC |
| **Extension** | AL code published into BC (our app) |
| **PageExt** | Extends standard BC page (e.g. Item Card) |
| **RDLC** | Report layout format (sales PDFs) |
| **Entity Text** | BC feature for Marketing Text |
| **Blob field** | Large text stored as binary (Description Text) |
| **Syndication** | Sending product data to external channels |

---

## 14. FAQ

**Q: Is BC a PIM?**  
A: No. BC is an ERP. We are **adding PIM capabilities** to BC.

**Q: Why not use Akeneo?**  
A: Cost, complexity, and duplicate item masters. ZVG wants BC as the hub.

**Q: Where is the “main source”?**  
A: **Business Central Item** + custom ZVG tables (Extended Text, etc.). PIM tables store **locale overlays**, not a second item master.

**Q: Does translation change the database for English?**  
A: No. English stays in source fields. German is stored in PIM locale tables and shown when locale = DE.

**Q: What API do we use?**  
A: Azure Translator Text API (not Document API for fields).

---

## 15. Contact & repository

| Resource | Location |
|----------|----------|
| AL source code | `PIM-Locale/` in GitHub repo `ftwo-lab/Testing-` |
| Install steps | `PIM-Locale/README-INSTALL.txt` |
| BC app name | ICS Master by ZVG (customer environment) |
| Custom Extended Details | Table **50116** Extended Text, Page **50189** Extended Detail Card |

---

## 16. One-page summary for the third-party developer

**Project:** Build a PIM-style product content system **inside** Microsoft Dynamics 365 Business Central for ZVG.

**You are not building a separate web app.** You are extending BC with AL code.

**Main ideas:**
1. BC Item is the master product record.  
2. Locales (EN, DE, CH) hold translated content.  
3. Azure Translator fills target locales from English.  
4. Users switch locale on Item Card and see translated content in place.  
5. Extended Details and Marketing Text have their own page extensions.  

**Start here:** Read sections 1–7, clone `PIM-Locale`, publish to a sandbox, translate item `000000385` to German.

---

*Document prepared for handoff to external development partner. Update as features are added.*
