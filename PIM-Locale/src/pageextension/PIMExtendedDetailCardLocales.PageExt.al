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

        ItemNo := PIMLocaleMgt.GetItemNoFromRecord(Rec);
        if ItemNo = '' then
            exit;

        PIMLocaleSession.SetCurrentItemNo(ItemNo);
        PIMLocaleMgt.ApplyLocaleFieldsToRecord(Rec, ItemNo, PIMLocaleSession.GetActiveLocale());
    end;

    local procedure SaveActiveLocaleFromPage()
    var
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
        PIMLocaleSession: Codeunit "PIM Locale Session";
        ItemNo: Code[20];
    begin
        if PIMLocaleSession.IsSourceLocaleActive() then
            exit;

        ItemNo := PIMLocaleMgt.GetItemNoFromRecord(Rec);
        if ItemNo = '' then
            exit;

        PIMLocaleMgt.SaveLocaleFieldsFromRecord(Rec, ItemNo, PIMLocaleSession.GetActiveLocale());
    end;
}
