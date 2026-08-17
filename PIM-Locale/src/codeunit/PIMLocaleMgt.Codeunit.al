codeunit 50101 "PIM Locale Mgt."
{
    procedure GetSourceLocaleCode(): Code[10]
    var
        PIMLocale: Record "PIM Locale";
    begin
        PIMLocale.SetRange("Is Source Locale", true);
        PIMLocale.SetRange(Enabled, true);
        if PIMLocale.FindFirst() then
            exit(PIMLocale.Code);

        PIMLocale.SetRange("Is Source Locale");
        PIMLocale.SetRange(Enabled, true);
        PIMLocale.SetCurrentKey("Display Order");
        PIMLocale.SetAscending("Display Order", true);
        if PIMLocale.FindFirst() then
            exit(PIMLocale.Code);

        exit('');
    end;

    procedure EnsureDefaultLocales()
    var
        PIMLocale: Record "PIM Locale";
    begin
        if not PIMLocale.IsEmpty() then
            exit;

        InsertLocale('EN', 'English', 'ENU', 'en-GB', true, 10);
        InsertLocale('DE', 'Germany', 'DEU', 'de-DE', false, 20);
        InsertLocale('CH', 'Swiss German', 'DES', 'de-CH', false, 30);
    end;

    local procedure InsertLocale(Code: Code[10]; Name: Text[50]; LanguageCode: Code[10]; AILocaleTag: Text[20]; IsSource: Boolean; DisplayOrder: Integer)
    var
        PIMLocale: Record "PIM Locale";
    begin
        PIMLocale.Init();
        PIMLocale.Code := Code;
        PIMLocale.Name := Name;
        PIMLocale."Language Code" := LanguageCode;
        PIMLocale."AI Locale Tag" := AILocaleTag;
        PIMLocale."Is Source Locale" := IsSource;
        PIMLocale."Display Order" := DisplayOrder;
        PIMLocale.Enabled := true;
        PIMLocale.Insert();
    end;

    procedure GetItemLocaleData(ItemNo: Code[20]; LocaleCode: Code[10]; var PIMItemLocaleData: Record "PIM Item Locale Data"): Boolean
    begin
        if LocaleCode = '' then
            exit(false);

        PIMItemLocaleData.Init();
        if PIMItemLocaleData.Get(ItemNo, LocaleCode) then
            exit(true);

        PIMItemLocaleData."Item No." := ItemNo;
        PIMItemLocaleData."Locale Code" := LocaleCode;
        exit(false);
    end;

    procedure SaveItemLocaleData(var PIMItemLocaleData: Record "PIM Item Locale Data")
    begin
        if PIMItemLocaleData."Translation Status" = PIMItemLocaleData."Translation Status"::"Not Translated" then
            PIMItemLocaleData."Translation Status" := PIMItemLocaleData."Translation Status"::Draft;

        if not PIMItemLocaleData.Insert(true) then
            PIMItemLocaleData.Modify(true);
    end;

    procedure LoadItemTextsForLocale(ItemNo: Code[20]; LocaleCode: Code[10]; var Description: Text[100]; var Description2: Text[50]; var ExtendedDescription: Text[2048]; var MarketingText: Text[2048])
    var
        Item: Record Item;
        PIMItemLocaleData: Record "PIM Item Locale Data";
        SourceLocaleCode: Code[10];
    begin
        if not Item.Get(ItemNo) then
            exit;

        SourceLocaleCode := GetSourceLocaleCode();
        if (LocaleCode = '') or (LocaleCode = SourceLocaleCode) then begin
            Description := Item.Description;
            Description2 := Item."Description 2";
            LoadExtendedTexts(ItemNo, SourceLocaleCode, ExtendedDescription, MarketingText);
            exit;
        end;

        if GetItemLocaleData(ItemNo, LocaleCode, PIMItemLocaleData) then begin
            Description := PIMItemLocaleData.Description;
            Description2 := PIMItemLocaleData."Description 2";
            ExtendedDescription := PIMItemLocaleData."Extended Description";
            MarketingText := PIMItemLocaleData."Marketing Text";
        end else begin
            Description := '';
            Description2 := '';
            ExtendedDescription := '';
            MarketingText := '';
        end;
    end;

    procedure SaveItemTextsForLocale(ItemNo: Code[20]; LocaleCode: Code[10]; Description: Text[100]; Description2: Text[50]; ExtendedDescription: Text[2048]; MarketingText: Text[2048])
    var
        PIMItemLocaleData: Record "PIM Item Locale Data";
        SourceLocaleCode: Code[10];
    begin
        SourceLocaleCode := GetSourceLocaleCode();
        if (LocaleCode = '') or (LocaleCode = SourceLocaleCode) then
            Error('Switch to a non-source locale to edit translated content, or edit the Item directly for the source locale.');

        GetItemLocaleData(ItemNo, LocaleCode, PIMItemLocaleData);
        PIMItemLocaleData.Description := Description;
        PIMItemLocaleData."Description 2" := Description2;
        PIMItemLocaleData."Extended Description" := ExtendedDescription;
        PIMItemLocaleData."Marketing Text" := MarketingText;
        SaveItemLocaleData(PIMItemLocaleData);
    end;

    local procedure LoadExtendedTexts(ItemNo: Code[20]; LocaleCode: Code[10]; var ExtendedDescription: Text[2048]; var MarketingText: Text[2048])
    var
        ExtendedTextHeader: Record "Extended Text Header";
        ExtendedTextLine: Record "Extended Text Line";
        Builder: TextBuilder;
    begin
        ExtendedDescription := '';
        MarketingText := '';

        ExtendedTextHeader.SetRange("Table Name", ExtendedTextHeader."Table Name"::Item);
        ExtendedTextHeader.SetRange("No.", ItemNo);
        ExtendedTextHeader.SetRange("Language Code", LocaleCode);
        if ExtendedTextHeader.FindSet() then
            repeat
                Builder.Clear();
                ExtendedTextLine.SetRange("Table Name", ExtendedTextHeader."Table Name");
                ExtendedTextLine.SetRange("No.", ExtendedTextHeader."No.");
                ExtendedTextLine.SetRange("Language Code", ExtendedTextHeader."Language Code");
                ExtendedTextLine.SetRange("Text No.", ExtendedTextHeader."Text No.");
                if ExtendedTextLine.FindSet() then
                    repeat
                        Builder.AppendLine(ExtendedTextLine.Text);
                    until ExtendedTextLine.Next() = 0;

                case ExtendedTextHeader."Text No." of
                    1:
                        ExtendedDescription := CopyStr(Builder.ToText(), 1, MaxStrLen(ExtendedDescription));
                    2:
                        MarketingText := CopyStr(Builder.ToText(), 1, MaxStrLen(MarketingText));
                end;
            until ExtendedTextHeader.Next() = 0;
    end;

    procedure GetLocaleName(LocaleCode: Code[10]): Text[50]
    var
        PIMLocale: Record "PIM Locale";
    begin
        if PIMLocale.Get(LocaleCode) then
            exit(PIMLocale.Name);
        exit(LocaleCode);
    end;

    procedure TranslateAllItemFields(ItemNo: Code[20]; TargetLocaleCode: Code[10]; SourceLocale: Record "PIM Locale"; TargetLocale: Record "PIM Locale")
    var
        Item: Record Item;
        PIMAITranslator: Codeunit "PIM AI Translator";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldIndex: Integer;
        SourceValue: Text;
        TranslatedValue: Text;
        TranslatedFieldCount: Integer;
    begin
        if not Item.Get(ItemNo) then
            exit;

        RecRef.GetTable(Item);
        for FieldIndex := 1 to RecRef.FieldCount do begin
            FieldRef := RecRef.FieldIndex(FieldIndex);
            if not IsTranslatableField(FieldRef) then
                continue;

            SourceValue := GetFieldTextValue(FieldRef);
            if SourceValue.Trim() = '' then
                continue;

            TranslatedValue := PIMAITranslator.TranslateText(
                SourceValue, SourceLocale."AI Locale Tag", TargetLocale."AI Locale Tag");

            SaveItemLocaleFieldValue(
                ItemNo, TargetLocaleCode, Database::Item, FieldRef.Number, CopyStr(FieldRef.Name, 1, 80), TranslatedValue);
            TranslatedFieldCount += 1;
        end;

        if TranslatedFieldCount = 0 then
            Error('No translatable text was found on item %1.', ItemNo);
    end;

    procedure ApplyLocaleFieldsToItem(var Item: Record Item; LocaleCode: Code[10])
    var
        PIMItemLocaleField: Record "PIM Item Locale Field";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if (LocaleCode = '') or (LocaleCode = GetSourceLocaleCode()) then
            exit;

        RecRef.GetTable(Item);
        PIMItemLocaleField.SetRange("Item No.", Item."No.");
        PIMItemLocaleField.SetRange("Locale Code", LocaleCode);
        PIMItemLocaleField.SetRange("Table No.", Database::Item);
        if PIMItemLocaleField.FindSet() then
            repeat
                if RecRef.FieldExist(PIMItemLocaleField."Field No.") then begin
                    FieldRef := RecRef.Field(PIMItemLocaleField."Field No.");
                    SetFieldTextValue(FieldRef, PIMItemLocaleField.Value);
                end;
            until PIMItemLocaleField.Next() = 0;

        RecRef.SetTable(Item);
    end;

    procedure SaveItemLocaleFieldsFromItem(Item: Record Item; LocaleCode: Code[10])
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldIndex: Integer;
    begin
        if (LocaleCode = '') or (LocaleCode = GetSourceLocaleCode()) then
            exit;

        RecRef.GetTable(Item);
        for FieldIndex := 1 to RecRef.FieldCount do begin
            FieldRef := RecRef.FieldIndex(FieldIndex);
            if not IsTranslatableField(FieldRef) then
                continue;

            if GetFieldTextValue(FieldRef).Trim() = '' then
                continue;

            SaveItemLocaleFieldValue(
                Item."No.", LocaleCode, Database::Item, FieldRef.Number, CopyStr(FieldRef.Name, 1, 80), GetFieldTextValue(FieldRef));
        end;
    end;

    local procedure SaveItemLocaleFieldValue(ItemNo: Code[20]; LocaleCode: Code[10]; TableNo: Integer; FieldNo: Integer; FieldName: Text[80]; Value: Text[2048])
    var
        PIMItemLocaleField: Record "PIM Item Locale Field";
    begin
        if not PIMItemLocaleField.Get(ItemNo, LocaleCode, TableNo, FieldNo) then begin
            PIMItemLocaleField.Init();
            PIMItemLocaleField."Item No." := ItemNo;
            PIMItemLocaleField."Locale Code" := LocaleCode;
            PIMItemLocaleField."Table No." := TableNo;
            PIMItemLocaleField."Field No." := FieldNo;
            PIMItemLocaleField."Field Name" := FieldName;
            PIMItemLocaleField.Value := CopyStr(Value, 1, MaxStrLen(PIMItemLocaleField.Value));
            PIMItemLocaleField.Insert(true);
        end else begin
            PIMItemLocaleField."Field Name" := FieldName;
            PIMItemLocaleField.Value := CopyStr(Value, 1, MaxStrLen(PIMItemLocaleField.Value));
            PIMItemLocaleField.Modify(true);
        end;
    end;

    local procedure IsTranslatableField(FieldRef: FieldRef): Boolean
    var
        FieldNameLower: Text;
    begin
        if FieldRef.Class <> FieldClass::Normal then
            exit(false);

        case FieldRef.Type of
            FieldRef.Type::Text:
                exit(true);
            FieldRef.Type::Code:
                begin
                    FieldNameLower := LowerCase(FieldRef.Name);
                    exit(
                      (StrPos(FieldNameLower, 'description') > 0) or
                      (StrPos(FieldNameLower, 'comment') > 0) or
                      (StrPos(FieldNameLower, 'text') > 0) or
                      (StrPos(FieldNameLower, 'name') > 0));
                end;
            else
                exit(false);
        end;
    end;

    local procedure GetFieldTextValue(FieldRef: FieldRef): Text
    begin
        exit(Format(FieldRef.Value(), 0, 9));
    end;

    local procedure SetFieldTextValue(var FieldRef: FieldRef; Value: Text)
    begin
        case FieldRef.Type of
            FieldRef.Type::Text:
                FieldRef.Value := CopyStr(Value, 1, FieldRef.Length());
            FieldRef.Type::Code:
                FieldRef.Value := CopyStr(Value, 1, FieldRef.Length());
        end;
    end;
}
