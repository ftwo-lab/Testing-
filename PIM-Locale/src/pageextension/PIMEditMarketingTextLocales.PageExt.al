pageextension 50112 "PIM Edit Marketing Text Locales" extends "Edit Marketing Text"
{
    trigger OnOpenPage()
    begin
        ApplyActiveLocaleToPage();
    end;

    trigger OnAfterGetRecord()
    begin
        ApplyActiveLocaleToPage();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        SaveActiveLocaleFromPage();
        exit(false);
    end;

    local procedure ApplyActiveLocaleToPage()
    var
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
        PIMLocaleSession: Codeunit "PIM Locale Session";
        RecRef: RecordRef;
        ItemNo: Code[20];
    begin
        if PIMLocaleSession.IsSourceLocaleActive() then
            exit;

        ItemNo := PIMLocaleSession.GetCurrentItemNo();
        RecRef.GetTable(Rec);
        if ItemNo = '' then
            ItemNo := PIMLocaleMgt.GetItemNoFromRecord(RecRef);
        if ItemNo = '' then
            exit;

        PIMLocaleMgt.ApplyLocaleMarketingTextToRecord(RecRef, ItemNo, PIMLocaleSession.GetActiveLocale());
        RecRef.SetTable(Rec);
    end;

    local procedure SaveActiveLocaleFromPage()
    var
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
        PIMLocaleSession: Codeunit "PIM Locale Session";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldIndex: Integer;
        ItemNo: Code[20];
        MarketingText: Text;
    begin
        if PIMLocaleSession.IsSourceLocaleActive() then
            exit;

        ItemNo := PIMLocaleSession.GetCurrentItemNo();
        if ItemNo = '' then
            exit;

        RecRef.GetTable(Rec);
        for FieldIndex := 1 to RecRef.FieldCount do begin
            FieldRef := RecRef.FieldIndex(FieldIndex);
            if not PIMLocaleMgt.IsTranslatableFieldForLocale(FieldRef) then
                continue;

            MarketingText := PIMLocaleMgt.GetFieldTextValueForLocale(FieldRef);
            if MarketingText.Trim() = '' then
                continue;

            PIMLocaleMgt.SaveLocaleMarketingText(ItemNo, PIMLocaleSession.GetActiveLocale(), MarketingText);
            exit;
        end;
    end;
}
