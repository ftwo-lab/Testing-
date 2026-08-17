PIM LOCALE - COPY INTO ZVG-Nonpa
================================

STEP 1: Copy files into your project
------------------------------------
Copy everything from PIM-Locale/src/ into your ZVG-Nonpa/src/ folder.

Example:
  PIM-Locale/src/table/*         ->  ZVG-Nonpa/src/table/
  PIM-Locale/src/page/*          ->  ZVG-Nonpa/src/page/
  PIM-Locale/src/codeunit/*      ->  ZVG-Nonpa/src/codeunit/
  PIM-Locale/src/enum/*          ->  ZVG-Nonpa/src/enum/
  PIM-Locale/src/pageextension/* ->  ZVG-Nonpa/src/pageextension/

Do NOT copy as a subfolder. Merge files into existing folders.

STEP 2: Update app.json in ZVG-Nonpa root
-----------------------------------------
Add this ID range if not already present:

  "from": 50100,
  "to": 50149

Also add:
  "allowHttpClientRequests": true

If 50100 is already used in your app, change all object IDs in these files
to free numbers in your range.

STEP 3: Publish
---------------
Open ZVG-Nonpa in VS Code and press F5.

In BC: Extension Management -> ICS Master by ZVG -> Allow HTTPClient Requests = ON

STEP 4: Setup in Business Central
---------------------------------
1. Search: PIM Locales -> Create Default Locales
2. Search: PIM AI Setup
   - Enabled = ON
   - AI Provider = Azure Translator
   - Endpoint URL = https://api.cognitive.microsofttranslator.com
   - API Region = eastasia
   - API Key = your MSBCTranslator KEY 1
3. Open Item -> Processing -> Locales -> Germany or Swiss German

WHAT GETS TRANSLATED NOW
------------------------
When you choose Germany or Swiss German, ALL of this is translated:

1. Item Card fields (Description, Description 2, and other text fields)
2. Marketing Text (Extended Text Text No. 2)
3. Extended Description (Extended Text Text No. 1)
4. Item Attribute values (text values only; numbers/codes like 11 are skipped)
5. Custom tables registered in PIM Locale Table Setup (Extended Details, etc.)

WHERE YOU SEE TRANSLATED DATA ON ITEM CARD
------------------------------------------
After switching locale, look at the right-hand factboxes:

- Marketing Text (Locale)
- Item Attributes (Locale)
- Extended Details (Locale)
- Translated Fields

Use Processing -> Locales -> View All Translated Data for one full list.

STEP 5: Configure Extended Details table
----------------------------------------
Your Extended Details button opens a custom ZVG table. Register it once:

1. Search: PIM Locale Table Setup
2. Add a line:
   - Table No. = your Extended Details table number
   - Link Field No. = field number that stores Item No.
   - Translate All Fields = ON
   - Enabled = ON
3. Use action "Show Table Fields" to find field numbers

Example: if Extended Details table is 50123 and Item No. is field 2:
  Table No. = 50123
  Link Field No. = 2
  Translate All Fields = ON

After setup, translate again with Locales -> Germany.

FILES INCLUDED
--------------
table/
  PIMLocale.Table.al
  PIMItemLocaleData.Table.al
  PIMAISetup.Table.al
  PIMItemLocaleField.Table.al
  PIMLocaleTableSetup.Table.al
  PIMItemLocaleAttribute.Table.al

enum/
  PIMTranslationStatus.Enum.al
  PIMAIProvider.Enum.al

codeunit/
  PIMLocaleSession.Codeunit.al
  PIMLocaleMgt.Codeunit.al
  PIMAITranslator.Codeunit.al
  PIMLocalesInstall.Codeunit.al

page/
  PIMLocales.Page.al
  PIMAISetup.Page.al
  PIMItemLocaleCard.Page.al
  PIMItemLocaleStatus.Page.al
  PIMItemLocaleFields.Page.al
  PIMLocaleTableSetup.Page.al
  PIMItemLocaleMarketingText.Page.al
  PIMItemLocaleAttributes.Page.al
  PIMItemLocaleRelatedFields.Page.al
  PIMItemLocaleOverview.Page.al

pageextension/
  PIMItemCardLocales.PageExt.al
