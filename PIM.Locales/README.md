# PIM Locales for Business Central

Akeneo-style locale switcher for Item product data with AI translation.

## What it does

- Adds locale actions on **Item Card**: English, Germany, Swiss German
- Stores translated content per item/locale in **PIM Item Locale Data**
- **Translate Current Locale with AI** uses Azure OpenAI
- Shows locale status in a FactBox

## Setup

1. Publish the extension to your BC environment
2. Open **PIM Locales** → run **Create Default Locales** (or use install defaults)
3. Open **PIM AI Setup** → configure Azure OpenAI endpoint, deployment, API key
4. On Item Card → **Locales** → pick Germany/Swiss/English

## Default locales

| Code | Name | BC Language | AI Tag |
|------|------|-------------|--------|
| EN | English | ENU | en-GB |
| DE | Germany | DEU | de-DE |
| CH | Swiss German | DES | de-CH |

## Extend for custom tables

Add fields to `PIM Item Locale Data` and map them in:
- `PIM Locale Mgt.` (load/save)
- `PIM AI Translator` (translate)
- Shopify export events (push metafields per locale)

## Shopify integration

Map locale content to Shopify metafields per market, e.g.:
- `custom.description_de`
- `custom.description_ch`

Use `Shpfy Product Events` to read from `PIM Item Locale Data` when syncing.
