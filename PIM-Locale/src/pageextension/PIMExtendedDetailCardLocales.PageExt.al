pageextension 50111 "PIM Extended Detail Card Locales" extends "Extended Detail Card"
{
    trigger OnOpenPage()
    var
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
    begin
        PIMLocaleMgt.EnsureExtendedDetailTableSetup();
    end;

    trigger OnAfterGetRecord()
    begin
        ApplyActiveLocaleToPage();
    end;

    trigger OnAfterGetCurrRecord()
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

        RecRef.GetTable(Rec);
        ItemNo := PIMLocaleMgt.GetItemNoFromRecord(RecRef);
        if ItemNo = '' then
            exit;

        PIMLocaleSession.SetCurrentItemNo(ItemNo);
        PIMLocaleMgt.ApplyLocaleFieldsToRecord(RecRef, ItemNo, PIMLocaleSession.GetActiveLocale());
        RecRef.SetTable(Rec);
    end;

    local procedure SaveActiveLocaleFromPage()
    var
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
        PIMLocaleSession: Codeunit "PIM Locale Session";
        RecRef: RecordRef;
        ItemNo: Code[20];
    begin
        if PIMLocaleSession.IsSourceLocaleActive() then
            exit;

        RecRef.GetTable(Rec);
        ItemNo := PIMLocaleMgt.GetItemNoFromRecord(RecRef);
        if ItemNo = '' then
            exit;

        PIMLocaleMgt.SaveLocaleFieldsFromRecord(RecRef, ItemNo, PIMLocaleSession.GetActiveLocale());
    end;
}
