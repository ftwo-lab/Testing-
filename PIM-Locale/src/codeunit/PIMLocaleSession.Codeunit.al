codeunit 50100 "PIM Locale Session"
{
    SingleInstance = true;

    var
        ActiveLocaleCode: Code[10];
        LocaleInitialized: Boolean;

    procedure SetActiveLocale(LocaleCode: Code[10])
    begin
        ActiveLocaleCode := LocaleCode;
        LocaleInitialized := true;
    end;

    procedure GetActiveLocale(): Code[10]
    var
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
    begin
        if not LocaleInitialized then
            SetActiveLocale(PIMLocaleMgt.GetSourceLocaleCode());
        exit(ActiveLocaleCode);
    end;

    procedure IsSourceLocaleActive(): Boolean
    var
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
    begin
        exit(GetActiveLocale() = PIMLocaleMgt.GetSourceLocaleCode());
    end;

    procedure ResetToSourceLocale()
    var
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
    begin
        SetActiveLocale(PIMLocaleMgt.GetSourceLocaleCode());
    end;
}
