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
        ItemNo: Code[20];
    begin
        if PIMLocaleSession.IsSourceLocaleActive() then
            exit;

        ItemNo := PIMLocaleSession.GetCurrentItemNo();
        if ItemNo = '' then
            ItemNo := PIMLocaleMgt.GetItemNoFromRecord(Rec);
        if ItemNo = '' then
            exit;

        PIMLocaleMgt.ApplyLocaleMarketingTextToRecord(Rec, ItemNo, PIMLocaleSession.GetActiveLocale());
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
            if FieldRef.Type <> FieldRef.Type::Text then
                continue;
            if FieldRef.Length < 250 then
                continue;

            MarketingText := Format(FieldRef.Value(), 0, 9);
            PIMLocaleMgt.SaveLocaleMarketingText(ItemNo, PIMLocaleSession.GetActiveLocale(), MarketingText);
            exit;
        end;
    end;
}
