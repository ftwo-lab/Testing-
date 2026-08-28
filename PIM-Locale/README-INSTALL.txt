PIM LOCALE - COPY INTO ZVG-Nonpa
================================

STEP 1: Copy files into your project
------------------------------------
Copy everything from PIM-Locale/src/ into your ZVG-Nonpa/src/ folder.

Example:
  PIM-Locale/src/table/*         ->  ZVG-Nonpa/src/table/
  PIM-Locale/src/tableextension/* ->  ZVG-Nonpa/src/tableextension/
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
Your Extended Detail Card uses table 50116 Extended Text (Item No. = field 2).
This is registered automatically on install/open.

If your table number is different, change these procedures in PIM Locale Mgt.:
  GetExtendedDetailTableNo()
  GetExtendedDetailItemNoFieldNo()

Or add your own line in PIM Locale Table Setup manually.

STEP 6: Where translated content appears
----------------------------------------
After Locales -> Germany or Swiss German:

1. Item Card main fields = translated in place
2. Home -> Extended Details action = translated on Extended Detail Card page
3. Marketing Text action = translated on Edit Marketing Text page

Marketing Text and Extended Details are NO LONGER shown in separate locale factboxes.

STEP 7: Product families on default items
-----------------------------------------
1. Search: PIM Product Family Groups -> Create Example Families
   (optional: PIM Product Families -> Create Example Items)
2. Open Item Card -> FastTab Product Family
   - Product Family = family code
   - Family Role = Default Item (Parent)
3. Processing -> Product Family -> Add Variant (pick related SKU)
4. Open Product Family Card to see Parent / V1 / V2
   See PIM-Product-Family-Guide.md

FILES INCLUDED
--------------
table/
  PIMLocale.Table.al
  PIMItemLocaleData.Table.al
  PIMAISetup.Table.al
  PIMItemLocaleField.Table.al
  PIMLocaleTableSetup.Table.al
  PIMItemLocaleAttribute.Table.al
  PIMProductFamilyGroup.Table.al
  PIMProductFamily.Table.al
  PIMProductFamilyMember.Table.al

tableextension/
  PIMItemFamily.TableExt.al

enum/
  PIMTranslationStatus.Enum.al
  PIMAIProvider.Enum.al
  PIMFamilyMemberRole.Enum.al

codeunit/
  PIMLocaleSession.Codeunit.al
  PIMLocaleMgt.Codeunit.al
  PIMAITranslator.Codeunit.al
  PIMLocalesInstall.Codeunit.al
  PIMProductFamilyMgt.Codeunit.al

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
  PIMTableFieldList.Page.al
  PIMProductFamilyGroups.Page.al
  PIMProductFamilyGroupCard.Page.al
  PIMProductFamilies.Page.al
  PIMProductFamilyCard.Page.al
  PIMProductFamilyMembers.Page.al
  PIMFamilyMemberListPart.Page.al
  PIMItemFamilyFactbox.Page.al
  PIMFamiliesListPart.Page.al

pageextension/
  PIMItemCardLocales.PageExt.al
  PIMExtendedDetailCardLocales.PageExt.al
  PIMEditMarketingTextLocales.PageExt.al
  PIMItemCardFamily.PageExt.al
  PIMItemListFamily.PageExt.al
