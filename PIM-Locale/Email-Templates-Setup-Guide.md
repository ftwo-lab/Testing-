# Email Templates in Business Central
## Setup Guide for ZVG / ICS Master

**Version:** 1.1 | **Date:** August 2026

Business Central does **not** have one page called **Email Templates**.  
Email templates are set up in **two places**, depending on what you email.

**Download:** Ready-to-copy template text is in the **`Email-Templates/`** folder (English + German).

---

## Quick reference — what to search in BC

| I want to email… | Search this in BC | This is your "email template" |
|------------------|-------------------|-------------------------------|
| Sales Quote, Order, Invoice, Shipment | **Report Selection - Sales** | **Email Body Layout Description** |
| Purchase Order, Purchase Invoice | **Report Selection - Purchase** | **Email Body Layout Description** |
| Customer / Vendor / Contact (general email) | **Word Templates** | Word template → **Use Word Template** in email |
| Default attachments (T&C PDF, etc.) | **Email Scenarios** | Default Attachments |

---

## Ready-to-use ZVG templates (copy from files)

Open the **`Email-Templates`** folder in this package:

| Template file | BC setup location | Usage |
|---------------|---------------------|-------|
| `EN/Sales-Quote-Email-Body.txt` | Report Selection - Sales | Quote |
| `EN/Sales-Order-Email-Body.txt` | Report Selection - Sales | Order |
| `EN/Sales-Invoice-Email-Body.txt` | Report Selection - Sales | Invoice |
| `EN/Sales-Shipment-Email-Body.txt` | Report Selection - Sales | Shipment |
| `EN/Purchase-Order-Email-Body.txt` | Report Selection - Purchase | Order |
| `EN/Customer-Welcome-Email.txt` | Word Templates | Customer |
| `DE/*.txt` | Same as above | German versions |

**Suggested layout names in BC:**

| Layout name | Language |
|-------------|----------|
| ZVG Sales Quote Email EN | English |
| ZVG Sales Order Email EN | English |
| ZVG Sales Invoice Email EN | English |
| ZVG Sales Shipment Email EN | English |
| ZVG Purchase Order Email EN | English |
| ZVG Customer Welcome EN | English |
| ZVG Sales Order Email DE | German |
| (etc.) | German |

---

## Part 1 — Prerequisites (do this first)

### Step 1: Set up email

1. Search: **Set Up Email**
2. Complete the assisted setup (Microsoft 365 or SMTP)
3. Search: **Email Accounts** → confirm **Default Account** is set

### Step 2: Assign email scenarios

1. Search: **Email Scenarios**
2. Assign your email account to:
   - Sales Invoice
   - Sales Order
   - Sales Quote
   - Purchase Order
   - (other scenarios you use)

---

## Part 2 — Email templates for documents (Sales / Purchase)

This is the main **Email Body Template** used when you click **Print/Send → Send by Email**.

### Example: Sales Order / Offer Confirmation email

#### Step 1 — Open Report Selection

1. Search: **Report Selection - Sales**
2. Set **Usage** = **Order** (for Sales Orders / Offer Confirmations)

#### Step 2 — Enable email fields

On the report line, set:

| Field | Value |
|-------|-------|
| **Use for Email Body** | ✅ Yes |
| **Use for Email Attachment** | ✅ Yes |
| **Email Body Layout Description** | Select or create template |

#### Step 3 — Create a custom email body template

1. Search: **Custom Report Layouts**
2. Click **New** → **Copy** (copy an existing layout, e.g. *Sales Order - Default Email Body*)
3. Give it a name, e.g. `ZVG Sales Order Email EN`
4. Click **Layout → Export Layout**
5. Open the Word file
6. **Copy text** from `Email-Templates/EN/Sales-Order-Email-Body.txt` into the Word body
7. Add merge fields: Word → **Developer** tab → **XML Mapping Pane** → drag fields from BC data (Customer Name, Document No., Document Date)
8. Save Word file
9. Back in BC → **Layout → Import Layout**
10. Return to **Report Selection - Sales** → Usage = **Order**
11. Set **Email Body Layout Description** = `ZVG Sales Order Email EN`

#### Step 4 — Test

1. Open a Sales Order
2. **Print/Send → Send by Email**
3. The **Body** field should show your template text automatically

---

## Part 3 — Email templates per document type

Repeat Part 2 for each document. Use the matching file from `Email-Templates/EN/` or `Email-Templates/DE/`.

### Report Selection - Sales

| Usage | When used | Template file |
|-------|-----------|---------------|
| **Quote** | Sales Quote email | `Sales-Quote-Email-Body.txt` |
| **Order** | Sales Order / Offer email | `Sales-Order-Email-Body.txt` |
| **Invoice** | Posted Sales Invoice email | `Sales-Invoice-Email-Body.txt` |
| **Shipment** | Shipment notification | `Sales-Shipment-Email-Body.txt` |

### Report Selection - Purchase

| Usage | When used | Template file |
|-------|-----------|---------------|
| **Order** | Purchase Order email | `Purchase-Order-Email-Body.txt` |
| **Invoice** | Posted Purchase Invoice email | Create similar text from Sales Invoice template |

---

## Part 4 — Word Templates (Customer / Vendor emails)

For **general emails** (not tied to a sales document PDF):

1. Search: **Word Templates**
2. Click **New** → **Create a template**
3. Choose data source: **Customer**, **Vendor**, or **Contact**
4. Download blank template package (ZIP)
5. Edit Word file — paste text from `Email-Templates/EN/Customer-Welcome-Email.txt`
6. Use **Insert Merge Field** for name, email, balance, etc.
7. Upload template back to BC
8. Enter **Code** = `ZVG-WELCOME-EN`, **Name** = `ZVG Customer Welcome EN`, **Language** = `ENU` → Finish

### How to use

1. Open **Customer List** → select customer
2. **Process → Send Email**
3. In email editor → **Use Word Template**
4. Pick your template → body fills automatically

Microsoft guide: [Use Word Templates for Bulk Communication](https://learn.microsoft.com/en-us/dynamics365/business-central/ui-mail-merge)

---

## Part 5 — German emails (DE locale)

For German customers:

1. Create separate layouts with names ending in `DE` (e.g. `ZVG Sales Order Email DE`)
2. Copy text from `Email-Templates/DE/` files
3. On **Word Templates**, set **Language** = `DEU` or `DES`
4. Optionally assign **Document Sending Profile** or language on **Customer Card** so the correct template is used

> **Tip:** BC picks report layout language based on report/report selection setup. Keep EN and DE as separate Custom Report Layouts and link the correct one on Report Selection.

---

## Part 6 — Default attachments on emails

To always attach a file (e.g. Terms & Conditions PDF):

1. Search: **Email Scenarios**
2. Open scenario (e.g. Sales Invoice)
3. Add **Default Attachment**
4. File attaches automatically when that email type is sent

---

## Part 7 — Auto-send without popup (optional)

1. Search: **Document Sending Profiles**
2. Create profile: **Email** = **Yes (Use Default Settings)**
3. Assign on **Customer Card** → **Document Sending Profile**

BC sends using default template without opening the email window each time.

---

## Body vs PDF attachment (important)

| Email part | Controlled by |
|------------|---------------|
| **Message body text** | **Email Body Layout** on Report Selection |
| **PDF attachment** | **Report Layout** on Report Selection (separate setting) |

These are **two different Word layouts**. You must set up both if you want custom body AND custom PDF.

---

## ZVG recommended default templates to create

| Template name | Report Selection | Usage | Source file |
|---------------|------------------|-------|-------------|
| ZVG Sales Quote Email EN | Report Selection - Sales | Quote | `EN/Sales-Quote-Email-Body.txt` |
| ZVG Sales Order Email EN | Report Selection - Sales | Order | `EN/Sales-Order-Email-Body.txt` |
| ZVG Sales Invoice Email EN | Report Selection - Sales | Invoice | `EN/Sales-Invoice-Email-Body.txt` |
| ZVG Sales Shipment Email EN | Report Selection - Sales | Shipment | `EN/Sales-Shipment-Email-Body.txt` |
| ZVG Purchase Order Email EN | Report Selection - Purchase | Order | `EN/Purchase-Order-Email-Body.txt` |
| ZVG Customer Welcome EN | Word Templates | Customer | `EN/Customer-Welcome-Email.txt` |
| ZVG Sales Order Email DE | Report Selection - Sales | Order | `DE/Sales-Order-Email-Body.txt` |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Email body is blank / standard text | **Email Body Layout Description** not set on Report Selection |
| Body does not update after edit | Re-import layout on **Custom Report Layouts**; refresh Report Selection link |
| PDF attaches but body is wrong | You edited Report Layout, not **Email Body Layout** — they are different |
| Word Template not in email editor | Template must match entity (Customer template only on Customer emails) |
| Email does not send | Check **Set Up Email** and **Email Accounts** |
| Wrong language template | Create separate EN/DE layouts; check Word Template Language field |

---

## Microsoft documentation

- [Set Up Email](https://learn.microsoft.com/en-us/dynamics365/business-central/admin-how-setup-email)
- [Set Up Reusable Email Texts and Layouts](https://learn.microsoft.com/en-us/dynamics365/business-central/admin-how-setup-email#set-up-reusable-email-texts-and-layouts)
- [Report Selection](https://learn.microsoft.com/en-us/dynamics365/business-central/across-report-selections)
- [Send Documents by Email](https://learn.microsoft.com/en-us/dynamics365/business-central/ui-how-send-documents-email)
- [Word Templates for Bulk Communication](https://learn.microsoft.com/en-us/dynamics365/business-central/ui-mail-merge)

---

*Prepared for ZVG Business Central users and developers.*
