PIM LOCALE - COPY INTO ZVG-Nonpa
================================

STEP 1: Copy files into your project
------------------------------------
Copy everything from PIM-Locale/src/ into your ZVG-Nonpa/src/ folder.

Example:
  PIM-Locale/src/table/*        ->  ZVG-Nonpa/src/table/
  PIM-Locale/src/page/*         ->  ZVG-Nonpa/src/page/
  PIM-Locale/src/codeunit/*     ->  ZVG-Nonpa/src/codeunit/
  PIM-Locale/src/enum/*         ->  ZVG-Nonpa/src/enum/
  PIM-Locale/src/pageextension/* -> ZVG-Nonpa/src/pageextension/

Do NOT copy as a subfolder. Merge files into existing folders.

STEP 2: Update app.json in ZVG-Nonpa root
-----------------------------------------
Add this ID range if not already present:

  "from": 50100,
  "to": 50149

If 50100 is already used in your app, change all object IDs in these files
to free numbers in your range.

STEP 3: Publish
---------------
Open ZVG-Nonpa in VS Code and press F5.

STEP 4: Setup in Business Central
---------------------------------
1. Search: PIM Locales -> Create Default Locales
2. Search: PIM AI Setup -> add Azure OpenAI (optional)
3. Open Item -> Processing -> Locales

FILES INCLUDED
--------------
table/
  PIMLocale.Table.al
  PIMItemLocaleData.Table.al
  PIMAISetup.Table.al

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

pageextension/
  PIMItemCardLocales.PageExt.al
