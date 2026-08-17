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
            if not ShouldTranslateValue(SourceValue) then
                continue;

            TranslatedValue := PIMAITranslator.TranslateText(
                SourceValue, SourceLocale."AI Locale Tag", TargetLocale."AI Locale Tag");

            SaveItemLocaleFieldValue(
                ItemNo, TargetLocaleCode, Database::Item, FieldRef.Number, CopyStr(FieldRef.Name, 1, 80), TranslatedValue);
            TranslatedFieldCount += 1;
        end;

        TranslatedFieldCount += TranslateItemExtendedTexts(ItemNo, TargetLocaleCode, SourceLocale, TargetLocale);
        TranslatedFieldCount += TranslateItemAttributes(ItemNo, TargetLocaleCode, SourceLocale, TargetLocale);
        TranslatedFieldCount += TranslateConfiguredRelatedTables(ItemNo, TargetLocaleCode, SourceLocale, TargetLocale);

        if TranslatedFieldCount = 0 then
            Error('No translatable text was found on item %1.', ItemNo);
    end;

    procedure GetLocaleMarketingText(ItemNo: Code[20]; LocaleCode: Code[10]): Text
    var
        PIMItemLocaleData: Record "PIM Item Locale Data";
    begin
        if GetItemLocaleData(ItemNo, LocaleCode, PIMItemLocaleData) then
            exit(PIMItemLocaleData."Marketing Text");
        exit('');
    end;

    procedure GetLocaleExtendedDescription(ItemNo: Code[20]; LocaleCode: Code[10]): Text
    var
        PIMItemLocaleData: Record "PIM Item Locale Data";
    begin
        if GetItemLocaleData(ItemNo, LocaleCode, PIMItemLocaleData) then
            exit(PIMItemLocaleData."Extended Description");
        exit('');
    end;

    procedure EnsureExtendedDetailTableSetup()
    var
        PIMLocaleTableSetup: Record "PIM Locale Table Setup";
        ExtendedDetailTableNo: Integer;
        ItemNoFieldNo: Integer;
    begin
        ExtendedDetailTableNo := GetExtendedDetailTableNo();
        ItemNoFieldNo := GetExtendedDetailItemNoFieldNo();
        if ExtendedDetailTableNo = 0 then
            exit;

        if PIMLocaleTableSetup.Get(ExtendedDetailTableNo, 0) then begin
            PIMLocaleTableSetup."Link Field No." := ItemNoFieldNo;
            PIMLocaleTableSetup."Translate All Fields" := true;
            PIMLocaleTableSetup.Enabled := true;
            PIMLocaleTableSetup.Description := 'Extended Detail Card';
            PIMLocaleTableSetup.Modify(true);
            exit;
        end;

        PIMLocaleTableSetup.Init();
        PIMLocaleTableSetup."Table No." := ExtendedDetailTableNo;
        PIMLocaleTableSetup."Field No." := 0;
        PIMLocaleTableSetup."Link Field No." := ItemNoFieldNo;
        PIMLocaleTableSetup."Translate All Fields" := true;
        PIMLocaleTableSetup.Enabled := true;
        PIMLocaleTableSetup.Description := 'Extended Detail Card';
        PIMLocaleTableSetup.Insert(true);
    end;

    procedure GetExtendedDetailTableNo(): Integer
    begin
        exit(50116);
    end;

    procedure GetExtendedDetailItemNoFieldNo(): Integer
    begin
        exit(2);
    end;

    procedure ApplyLocaleFieldsToRecord(var RecRef: RecordRef; ItemNo: Code[20]; LocaleCode: Code[10])
    var
        PIMItemLocaleField: Record "PIM Item Locale Field";
        FieldRef: FieldRef;
        SubKey: Code[20];
        AppliedAny: Boolean;
    begin
        if (LocaleCode = '') or (LocaleCode = GetSourceLocaleCode()) then
            exit;

        if ItemNo = '' then
            exit;

        SubKey := GetRecordSubKey(RecRef);

        PIMItemLocaleField.SetRange("Item No.", ItemNo);
        PIMItemLocaleField.SetRange("Locale Code", LocaleCode);
        PIMItemLocaleField.SetRange("Table No.", RecRef.Number);
        PIMItemLocaleField.SetRange("Sub Key", SubKey);
        if PIMItemLocaleField.FindSet() then
            repeat
                if RecRef.FieldExist(PIMItemLocaleField."Field No.") then begin
                    FieldRef := RecRef.Field(PIMItemLocaleField."Field No.");
                    SetFieldTextValue(FieldRef, GetStoredLocaleFieldValue(PIMItemLocaleField));
                    AppliedAny := true;
                end;
            until PIMItemLocaleField.Next() = 0;

        if AppliedAny then
            exit;

        PIMItemLocaleField.SetRange("Sub Key");
        if PIMItemLocaleField.FindSet() then
            repeat
                if RecRef.FieldExist(PIMItemLocaleField."Field No.") then begin
                    FieldRef := RecRef.Field(PIMItemLocaleField."Field No.");
                    SetFieldTextValue(FieldRef, GetStoredLocaleFieldValue(PIMItemLocaleField));
                end;
            until PIMItemLocaleField.Next() = 0;
    end;

    procedure SaveLocaleFieldsFromRecord(RecRef: RecordRef; ItemNo: Code[20]; LocaleCode: Code[10])
    var
        FieldRef: FieldRef;
        FieldIndex: Integer;
    begin
        if (LocaleCode = '') or (LocaleCode = GetSourceLocaleCode()) then
            exit;

        if ItemNo = '' then
            exit;

        for FieldIndex := 1 to RecRef.FieldCount do begin
            FieldRef := RecRef.FieldIndex(FieldIndex);
            if not IsTranslatableField(FieldRef) then
                continue;

            if GetFieldTextValue(FieldRef).Trim() = '' then
                continue;

            SaveItemLocaleFieldValue(
                ItemNo, LocaleCode, RecRef.Number, FieldRef.Number, CopyStr(FieldRef.Name, 1, 80),
                GetFieldTextValue(FieldRef), GetRecordLineNo(RecRef), GetRecordSubKey(RecRef));
        end;
    end;

    procedure SaveLocaleMarketingText(ItemNo: Code[20]; LocaleCode: Code[10]; MarketingText: Text)
    var
        PIMItemLocaleData: Record "PIM Item Locale Data";
    begin
        if (LocaleCode = '') or (LocaleCode = GetSourceLocaleCode()) then
            exit;

        GetItemLocaleData(ItemNo, LocaleCode, PIMItemLocaleData);
        PIMItemLocaleData."Marketing Text" := CopyStr(MarketingText, 1, MaxStrLen(PIMItemLocaleData."Marketing Text"));
        SaveItemLocaleData(PIMItemLocaleData);
    end;

    procedure ApplyLocaleMarketingTextToRecord(var RecRef: RecordRef; ItemNo: Code[20]; LocaleCode: Code[10])
    var
        MarketingText: Text;
        FieldRef: FieldRef;
        FieldIndex: Integer;
    begin
        MarketingText := GetLocaleMarketingText(ItemNo, LocaleCode);
        if MarketingText = '' then
            exit;

        for FieldIndex := 1 to RecRef.FieldCount do begin
            FieldRef := RecRef.FieldIndex(FieldIndex);
            if not IsTranslatableField(FieldRef) then
                continue;
            if FieldRef.Type = FieldRef.Type::Text then
                if FieldRef.Length < 250 then
                    continue;

            SetFieldTextValue(FieldRef, MarketingText);
            exit;
        end;
    end;

    procedure GetItemNoFromRecord(RecRef: RecordRef): Code[20]
    var
        FieldRef: FieldRef;
        FieldIndex: Integer;
    begin
        for FieldIndex := 1 to RecRef.FieldCount do begin
            FieldRef := RecRef.FieldIndex(FieldIndex);
            if FieldRef.Name in ['Item No.', 'No.'] then
                exit(CopyStr(Format(FieldRef.Value()), 1, 20));
        end;

        exit('');
    end;

    procedure IsTranslatableFieldForLocale(FieldRef: FieldRef): Boolean
    begin
        exit(IsTranslatableField(FieldRef));
    end;

    procedure GetFieldTextValueForLocale(FieldRef: FieldRef): Text
    begin
        exit(GetFieldTextValue(FieldRef));
    end;

    local procedure TranslateItemExtendedTexts(ItemNo: Code[20]; TargetLocaleCode: Code[10]; SourceLocale: Record "PIM Locale"; TargetLocale: Record "PIM Locale"): Integer
    var
        ExtendedTextHeader: Record "Extended Text Header";
        ExtendedTextLine: Record "Extended Text Line";
        PIMItemLocaleData: Record "PIM Item Locale Data";
        PIMAITranslator: Codeunit "PIM AI Translator";
        Builder: TextBuilder;
        SourceText: Text;
        TranslatedText: Text;
        TranslatedCount: Integer;
    begin
        ExtendedTextHeader.SetRange("Table Name", ExtendedTextHeader."Table Name"::Item);
        ExtendedTextHeader.SetRange("No.", ItemNo);
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

                SourceText := Builder.ToText();
                if not ShouldTranslateValue(SourceText) then
                    continue;

                TranslatedText := PIMAITranslator.TranslateText(
                    SourceText, SourceLocale."AI Locale Tag", TargetLocale."AI Locale Tag");

                SaveItemLocaleFieldValue(
                    ItemNo, TargetLocaleCode, Database::"Extended Text Line", ExtendedTextLine.FieldNo(Text),
                    CopyStr(StrSubstNo('Extended Text %1', ExtendedTextHeader."Text No."), 1, 80),
                    TranslatedText, 0, CopyStr(Format(ExtendedTextHeader."Text No."), 1, 20));

                GetItemLocaleData(ItemNo, TargetLocaleCode, PIMItemLocaleData);
                if ExtendedTextHeader."Text No." = 2 then
                    PIMItemLocaleData."Marketing Text" := CopyStr(TranslatedText, 1, MaxStrLen(PIMItemLocaleData."Marketing Text"))
                else
                    PIMItemLocaleData."Extended Description" := CopyStr(TranslatedText, 1, MaxStrLen(PIMItemLocaleData."Extended Description"));
                PIMItemLocaleData."Translation Status" := PIMItemLocaleData."Translation Status"::"AI Generated";
                SaveItemLocaleData(PIMItemLocaleData);

                TranslatedCount += 1;
            until ExtendedTextHeader.Next() = 0;

        exit(TranslatedCount);
    end;

    procedure GetLocaleAttributeValue(ItemNo: Code[20]; LocaleCode: Code[10]; AttributeID: Integer): Text
    var
        PIMItemLocaleAttribute: Record "PIM Item Locale Attribute";
    begin
        if PIMItemLocaleAttribute.Get(ItemNo, LocaleCode, AttributeID) then
            exit(PIMItemLocaleAttribute.Value);
        exit('');
    end;

    procedure GetRelatedLocaleFieldValue(ItemNo: Code[20]; LocaleCode: Code[10]; TableNo: Integer; FieldNo: Integer; LineNo: Integer; SubKey: Code[20]): Text
    var
        PIMItemLocaleField: Record "PIM Item Locale Field";
    begin
        if PIMItemLocaleField.Get(ItemNo, LocaleCode, TableNo, FieldNo, LineNo, SubKey) then
            exit(PIMItemLocaleField.Value);
        exit('');
    end;

    local procedure TranslateItemAttributes(ItemNo: Code[20]; TargetLocaleCode: Code[10]; SourceLocale: Record "PIM Locale"; TargetLocale: Record "PIM Locale"): Integer
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        ItemAttribute: Record "Item Attribute";
        PIMItemLocaleAttribute: Record "PIM Item Locale Attribute";
        PIMAITranslator: Codeunit "PIM AI Translator";
        TranslatedValue: Text;
        TranslatedCount: Integer;
    begin
        ItemAttributeValueMapping.SetRange("Table ID", Database::Item);
        ItemAttributeValueMapping.SetRange("No.", ItemNo);
        if ItemAttributeValueMapping.FindSet() then
            repeat
                if not ShouldTranslateValue(ItemAttributeValueMapping.Value) then
                    continue;

                TranslatedValue := PIMAITranslator.TranslateText(
                    ItemAttributeValueMapping.Value, SourceLocale."AI Locale Tag", TargetLocale."AI Locale Tag");

                if not PIMItemLocaleAttribute.Get(ItemNo, TargetLocaleCode, ItemAttributeValueMapping."Item Attribute ID") then begin
                    PIMItemLocaleAttribute.Init();
                    PIMItemLocaleAttribute."Item No." := ItemNo;
                    PIMItemLocaleAttribute."Locale Code" := TargetLocaleCode;
                    PIMItemLocaleAttribute."Attribute ID" := ItemAttributeValueMapping."Item Attribute ID";
                    if ItemAttribute.Get(ItemAttributeValueMapping."Item Attribute ID") then
                        PIMItemLocaleAttribute."Attribute Name" := ItemAttribute.Name;
                    PIMItemLocaleAttribute.Value := CopyStr(TranslatedValue, 1, MaxStrLen(PIMItemLocaleAttribute.Value));
                    PIMItemLocaleAttribute.Insert(true);
                end else begin
                    PIMItemLocaleAttribute.Value := CopyStr(TranslatedValue, 1, MaxStrLen(PIMItemLocaleAttribute.Value));
                    PIMItemLocaleAttribute.Modify(true);
                end;

                TranslatedCount += 1;
            until ItemAttributeValueMapping.Next() = 0;

        exit(TranslatedCount);
    end;

    local procedure TranslateConfiguredRelatedTables(ItemNo: Code[20]; TargetLocaleCode: Code[10]; SourceLocale: Record "PIM Locale"; TargetLocale: Record "PIM Locale"): Integer
    var
        PIMLocaleTableSetup: Record "PIM Locale Table Setup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        LinkFieldRef: FieldRef;
        TranslatedCount: Integer;
        FieldIndex: Integer;
    begin
        PIMLocaleTableSetup.SetRange(Enabled, true);
        if PIMLocaleTableSetup.FindSet() then
            repeat
                RecRef.Open(PIMLocaleTableSetup."Table No.");
                if not RecRef.FieldExist(PIMLocaleTableSetup."Link Field No.") then begin
                    RecRef.Close();
                    continue;
                end;

                LinkFieldRef := RecRef.Field(PIMLocaleTableSetup."Link Field No.");
                LinkFieldRef.SetRange(ItemNo);
                if RecRef.FindSet() then
                    repeat
                        if PIMLocaleTableSetup."Translate All Fields" then begin
                            for FieldIndex := 1 to RecRef.FieldCount do begin
                                FieldRef := RecRef.FieldIndex(FieldIndex);
                                TranslatedCount += TranslateRelatedFieldRef(
                                    ItemNo, TargetLocaleCode, SourceLocale, TargetLocale, RecRef, FieldRef);
                            end;
                        end else begin
                            if not RecRef.FieldExist(PIMLocaleTableSetup."Field No.") then
                                continue;

                            FieldRef := RecRef.Field(PIMLocaleTableSetup."Field No.");
                            TranslatedCount += TranslateRelatedFieldRef(
                                ItemNo, TargetLocaleCode, SourceLocale, TargetLocale, RecRef, FieldRef);
                        end;
                    until RecRef.Next() = 0;

                RecRef.Close();
            until PIMLocaleTableSetup.Next() = 0;

        exit(TranslatedCount);
    end;

    local procedure TranslateRelatedFieldRef(ItemNo: Code[20]; TargetLocaleCode: Code[10]; SourceLocale: Record "PIM Locale"; TargetLocale: Record "PIM Locale"; RecRef: RecordRef; FieldRef: FieldRef): Integer
    var
        PIMAITranslator: Codeunit "PIM AI Translator";
        SourceValue: Text;
        TranslatedValue: Text;
        FieldCaption: Text[80];
    begin
        if not IsTranslatableField(FieldRef) then
            exit(0);

        SourceValue := GetFieldTextValue(FieldRef);
        if not ShouldTranslateValue(SourceValue) then
            exit(0);

        TranslatedValue := PIMAITranslator.TranslateText(
            SourceValue, SourceLocale."AI Locale Tag", TargetLocale."AI Locale Tag");

        FieldCaption := CopyStr(StrSubstNo('%1.%2', RecRef.Name, FieldRef.Name), 1, 80);
        SaveItemLocaleFieldValue(
            ItemNo, TargetLocaleCode, RecRef.Number, FieldRef.Number, FieldCaption, TranslatedValue,
            GetRecordLineNo(RecRef), GetRecordSubKey(RecRef));

        exit(1);
    end;

    local procedure GetRecordLineNo(RecRef: RecordRef): Integer
    var
        FieldRef: FieldRef;
        FieldIndex: Integer;
    begin
        for FieldIndex := 1 to RecRef.FieldCount do begin
            FieldRef := RecRef.FieldIndex(FieldIndex);
            if FieldRef.Name = 'Line No.' then
                exit(FieldRef.Value());
        end;

        exit(0);
    end;

    local procedure GetRecordSubKey(RecRef: RecordRef): Code[20]
    var
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        FieldIndex: Integer;
        KeyBuilder: TextBuilder;
    begin
        KeyRef := RecRef.KeyIndex(1);
        for FieldIndex := 1 to KeyRef.FieldCount() do begin
            FieldRef := KeyRef.FieldIndex(FieldIndex);
            KeyBuilder.Append(Format(FieldRef.Value(), 0, 9));
            KeyBuilder.Append('|');
        end;

        exit(CopyStr(KeyBuilder.ToText(), 1, 20));
    end;

    local procedure ShouldTranslateValue(SourceValue: Text): Boolean
    var
        DecimalValue: Decimal;
        TrimmedValue: Text;
    begin
        TrimmedValue := SourceValue.Trim();
        if TrimmedValue = '' then
            exit(false);

        if Evaluate(DecimalValue, TrimmedValue) then
            if Format(DecimalValue, 0, 9) = TrimmedValue then
                exit(false);

        exit(true);
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
                    SetFieldTextValue(FieldRef, GetStoredLocaleFieldValue(PIMItemLocaleField));
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

    local procedure SaveItemLocaleFieldValue(ItemNo: Code[20]; LocaleCode: Code[10]; TableNo: Integer; FieldNo: Integer; FieldName: Text[80]; Value: Text; LineNo: Integer; SubKey: Code[20])
    var
        PIMItemLocaleField: Record "PIM Item Locale Field";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
    begin
        if not PIMItemLocaleField.Get(ItemNo, LocaleCode, TableNo, FieldNo, LineNo, SubKey) then begin
            PIMItemLocaleField.Init();
            PIMItemLocaleField."Item No." := ItemNo;
            PIMItemLocaleField."Locale Code" := LocaleCode;
            PIMItemLocaleField."Table No." := TableNo;
            PIMItemLocaleField."Field No." := FieldNo;
            PIMItemLocaleField."Line No." := LineNo;
            PIMItemLocaleField."Sub Key" := SubKey;
            PIMItemLocaleField."Field Name" := FieldName;
            PIMItemLocaleField.Insert(true);
        end else
            PIMItemLocaleField."Field Name" := FieldName;

        PIMItemLocaleField.Value := CopyStr(Value, 1, MaxStrLen(PIMItemLocaleField.Value));

        if ShouldStoreLongValue(FieldName, Value) then begin
            RecRef.GetTable(PIMItemLocaleField);
            FieldRef := RecRef.Field(PIMItemLocaleField.FieldNo("Long Value"));
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStream, TEXTENCODING::UTF8);
            OutStream.WriteText(Value);
            TempBlob.ToFieldRef(FieldRef);
            RecRef.SetTable(PIMItemLocaleField);
        end;

        PIMItemLocaleField.Modify(true);
    end;

    local procedure ShouldStoreLongValue(FieldName: Text[80]; Value: Text): Boolean
    var
        FieldNameLower: Text;
        PIMItemLocaleField: Record "PIM Item Locale Field";
    begin
        if Value = '' then
            exit(false);

        if StrLen(Value) > MaxStrLen(PIMItemLocaleField.Value) then
            exit(true);

        FieldNameLower := LowerCase(FieldName);
        exit(
          (StrPos(FieldNameLower, 'description text') > 0) or
          (StrPos(FieldNameLower, 'special instruction') > 0));
    end;

    local procedure SaveItemLocaleFieldValue(ItemNo: Code[20]; LocaleCode: Code[10]; TableNo: Integer; FieldNo: Integer; FieldName: Text[80]; Value: Text)
    begin
        SaveItemLocaleFieldValue(ItemNo, LocaleCode, TableNo, FieldNo, FieldName, Value, 0, '');
    end;

    local procedure GetStoredLocaleFieldValue(PIMItemLocaleField: Record "PIM Item Locale Field"): Text
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        LongValue: Text;
    begin
        RecRef.GetTable(PIMItemLocaleField);
        FieldRef := RecRef.Field(PIMItemLocaleField.FieldNo("Long Value"));
        LongValue := ReadBlobFieldRef(FieldRef);
        if LongValue <> '' then
            exit(LongValue);

        exit(PIMItemLocaleField.Value);
    end;

    local procedure ReadBlobFieldRef(FieldRef: FieldRef): Text
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        LineText: Text;
        ResultBuilder: TextBuilder;
    begin
        FieldRef.CalcField();
        TempBlob.FromFieldRef(FieldRef);
        if TempBlob.Length() = 0 then
            exit('');

        TempBlob.CreateInStream(InStream, TEXTENCODING::UTF8);
        while not InStream.EOS() do begin
            InStream.ReadText(LineText);
            if LineText <> '' then
                ResultBuilder.AppendLine(LineText);
        end;

        exit(ResultBuilder.ToText().Trim());
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
            FieldRef.Type::Blob:
                begin
                    FieldNameLower := LowerCase(FieldRef.Name);
                    exit(
                      (StrPos(FieldNameLower, 'description') > 0) or
                      (StrPos(FieldNameLower, 'comment') > 0) or
                      (StrPos(FieldNameLower, 'text') > 0) or
                      (StrPos(FieldNameLower, 'instruction') > 0));
                end;
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
        if FieldRef.Type = FieldRef.Type::Blob then
            exit(ReadBlobFieldRef(FieldRef));

        exit(Format(FieldRef.Value(), 0, 9));
    end;

    local procedure SetFieldTextValue(var FieldRef: FieldRef; Value: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
    begin
        if FieldRef.Type = FieldRef.Type::Blob then begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStream, TEXTENCODING::UTF8);
            OutStream.WriteText(Value);
            TempBlob.ToFieldRef(FieldRef);
            FieldRef.CalcField();
            exit;
        end;

        case FieldRef.Type of
            FieldRef.Type::Text:
                FieldRef.Value := CopyStr(Value, 1, FieldRef.Length());
            FieldRef.Type::Code:
                FieldRef.Value := CopyStr(Value, 1, FieldRef.Length());
        end;
    end;
}
