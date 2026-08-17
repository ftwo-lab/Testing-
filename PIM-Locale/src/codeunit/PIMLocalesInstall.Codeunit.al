codeunit 50103 "PIM Locales Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
        PIMAISetup: Record "PIM AI Setup";
    begin
        PIMLocaleMgt.EnsureDefaultLocales();

        if not PIMAISetup.Get() then begin
            PIMAISetup.Init();
            PIMAISetup."Primary Key" := '';
            PIMAISetup."System Prompt" := 'You are a professional product content translator for ERP/PIM data. Preserve brand names, measurements, SKU codes, and technical values. Return only the translated text without quotes or explanations.';
            PIMAISetup.Insert();
        end;
    end;
}
