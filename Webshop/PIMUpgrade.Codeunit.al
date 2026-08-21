codeunit 50635 "PIM Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        PIMInstall: Codeunit "PIM Install";
    begin
        PIMInstall.SeedPIM();
    end;
}
