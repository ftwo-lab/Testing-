# SMTP test works, but **Send by Email** does not

## What is going on

A successful **Send Test Email** only proves that Business Central can log in to SMTP (`smtp.gmail.com` in your case) and send a **plain text** message.

**Print/Send → Send by Email** on a Sales Quote is a different process. It:

1. Looks up the **customer / contact email address**
2. Uses **Email Scenarios** (Sales Quote), not “whatever account you just tested”
3. Builds a **PDF** from **Report Selection - Sales** (Usage = Quote)
4. Opens the **email editor** (HTML body + PDF attachment)
5. Puts the message in **Email Outbox** — a job queue often sends it, the test path does not

If any of those steps fail, the action looks “dead” even though the SMTP test email arrived.

---

## Do this first (5 minutes)

Work through these in order. Stop when you find the error — that is the real cause.

### 1. Click Send by Email again, then open **Email Outbox**

1. Search: **Email Outbox**
2. If a row appears after you click **Send by Email**, open it and read **Error Message**

Typical errors:

| Outbox / dialog error | What to do |
|------------------------|------------|
| No email account for the scenario / default | Assign scenarios (step 2) |
| Email address is empty | Put an E-Mail on the customer (step 3) |
| *The SMTP server rejected the…* | Click **Show Error**. Gmail rejected this message (app password, port, From address). See step 4. |
| Authentication / SMTP / 535 / 534 | Gmail app password + sender type (steps 4–5) |
| Cannot generate report / layout | Report Selection for Quote (step 6) |
| Message sits on **Queued** forever | Start **Email Dispatcher** job (step 7) |

Also search **Sent Emails**. If the quote email is there, BC sent it — check spam or the **To** address.

If **nothing** appears in Outbox and no editor opens, continue with steps 2–3 and 6. The failure is usually **before** SMTP (missing To-address, report, or scenario).

### If Outbox only shows **Test Email Message** (no quote row)

That row is **not** Sales Quote **Send by Email**. Description **Test Email Message**, sender **FUNC3**, from `ftwo@netgains.org` is only **Email Accounts → Send Test Email**.

**Print/Send → Send by Email** creates an outbox row only after BC has a recipient, a quote PDF, and you send from the compose window. If the action “does nothing”, **no new error appears in Outbox** — that is expected.

1. On the **Failed** test row, click **Show Error** (red X). Read the full text after *The SMTP server rejected the…*. That is Gmail rejecting the **test** (often wrong password, port 465, or FUNC3 sending as `ftwo@netgains.org`).
2. Go back to quote **1169**, click **Send by Email** once, and watch **this quote page** (not Outbox):
   - A **notification** at the top (yellow/red)
   - A dialog: empty email, no scenario, cannot create report
   - The **email compose** window (To / Subject / PDF). Outbox updates only after you press **Send** there.
3. Confirm customer **L.R. Eurotechnik GmbH** has **E-Mail**, **Email Scenarios** include **Sales Quote**, and **Print...** / **Download as PDF** work on the same quote.

Until a row appears whose description is the **quote number / customer name** (not “Test Email Message”), the quote action is still failing **before** SMTP.

### 2. Assign **Email Scenarios** (most common miss)

Test email uses the account you selected on **Email Accounts**.  
Quote email uses the account assigned to scenario **Sales Quote** (or **Default**).

1. Search: **Email Accounts**
2. Select the Gmail SMTP account that passed the test
3. **Email Scenarios** (or Navigate → Email Scenarios)
4. Assign that account to at least:
   - **Default**
   - **Sales Quote**
   - Sales Order / Sales Invoice if you send those too

On the SMTP account card, set **Sender Type** = **Specific User** (the Gmail address you tested, e.g. the FTWO mailbox).

If Sender Type is **Current User**, the test still sends from the SMTP account you configured, but **Send by Email** tries to send as the **signed-in BC user**. That user usually has no Gmail SMTP login, so the action fails or does nothing.

Confirm one account is the **default** email account.

### 3. Customer must have an email address

For Sales Quote **1169 · L.R. Eurotechnik GmbH**:

1. Open the quote → **Sell-to Customer** (and **Bill-to** if different)
2. Customer Card → **E-Mail** must be filled
3. If you email the contact, the **Contact** card needs **E-Mail** too

Empty To-address is the usual reason the button “does nothing” or shows a dialog then closes.

### 4. Gmail SMTP settings that work with **document** emails

Your test used:

- Server: `smtp.gmail.com`
- Port: **465**
- Authentication: **Basic**
- Secure connection: Yes

That can succeed for a tiny test mail and still fail for **HTML + PDF**.

Use this on the SMTP account (then send another test):

| Field | Recommended value |
|-------|-------------------|
| Server | `smtp.gmail.com` |
| Port | **587** (not 465) |
| Authentication | Basic |
| Secure connection | Yes (STARTTLS) |
| User name | Full Gmail address |
| Password | Google **App Password** (16 characters), not the normal Gmail password |
| Sender Type | **Specific User** |
| Email / From | Same Gmail address as User name |

Google requires **2-Step Verification** and an **App Password** for SMTP. The mailbox you tested as user **FTWO** must be that Gmail account.

### 5. Confirm the email editor actually opens

After **Send by Email** you should get the compose window (To, Subject, Body, PDF attached).

- If it **never opens**: scenario, customer email, or Quote report (steps 2, 3, 6)
- If it **opens** and Send fails: Outbox error, Gmail, or job queue (steps 1, 4, 7)

Allow pop-ups for the Business Central URL if the browser blocks the email page.

### 6. Report Selection for **Quote**

1. Search: **Report Selection - Sales**
2. **Usage** = **Quote**
3. There must be a report line (standard is often report **1304** / **Sales Quote**)
4. **Use for Email Attachment** = Yes
5. Optionally **Use for Email Body** + **Email Body Layout Description** (templates in `Email-Templates/`)

If the Quote report or layout is missing or broken, **Send by Email** stops before SMTP. **Print...** and **Download as PDF** on the same quote are a quick check: if those fail, fix the report first.

### 7. Job queue: **Email Dispatcher**

Document emails are often **queued**; the SMTP test is **immediate**.

1. Search: **Job Queue Entries**
2. Find **Email Dispatcher** (or similar “email” entry)
3. Status must be **Ready**; if **On Hold**, resume it
4. Search **Email Outbox** again — queued rows should move to **Sent Emails**

### 8. Permissions and Document Sending Profile

- Your user needs permission to send email (e.g. **D365 BUS FULL ACCESS**, or a set that includes **Email**).
- Search **Document Sending Profiles**. The profile on the customer should not disable email. For testing, **Email** = Yes (prompt or default settings) is enough.

---

## Why the test can succeed and the action still fail

```
Send Test Email
  Email Accounts  →  SMTP login  →  tiny plain text  →  sent now

Print/Send → Send by Email (Sales Quote)
  Customer E-Mail
    → Email Scenario "Sales Quote"
      → Report Selection (PDF + optional body layout)
        → Email editor (HTML + PDF)
          → Email Outbox
            → Email Dispatcher job
              → SMTP (Gmail)
```

SMTP is only the last step. The test never runs the steps above it.

---

## Quick checklist

- [ ] **Email Outbox** shows the real error (or **Sent Emails** shows it went out)
- [ ] SMTP account is assigned to **Default** + **Sales Quote**
- [ ] **Sender Type** = Specific User (Gmail), not Current User
- [ ] Customer **L.R. Eurotechnik GmbH** has **E-Mail**
- [ ] SMTP: `smtp.gmail.com`, port **587**, App Password, From = Gmail user
- [ ] **Report Selection - Sales** / Usage **Quote** has an email attachment report
- [ ] **Email Dispatcher** job is running
- [ ] Compose window: To, subject, PDF attached, then Send

---

## Related ZVG docs

- Email body templates: `Email-Templates-Setup-Guide.md`
- Copy-paste bodies: `Email-Templates/EN/` and `Email-Templates/DE/`

Microsoft:

- [Set up email](https://learn.microsoft.com/en-us/dynamics365/business-central/admin-how-setup-email)
- [Send documents by email](https://learn.microsoft.com/en-us/dynamics365/business-central/ui-how-send-documents-email)
