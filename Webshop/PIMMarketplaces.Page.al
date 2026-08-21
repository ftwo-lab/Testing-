page 50640 "PIM Marketplaces"
{
    Caption = 'PIM Marketplaces';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    AdditionalSearchTerms = 'PIM, sync, Germany, Austria, Shopify, company';
    SourceTable = "PIM Marketplace";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Company Name"; Rec."Company Name") { ApplicationArea = All; }
                field("Country/Region Code"; Rec."Country/Region Code") { ApplicationArea = All; }
                field(Enabled; Rec.Enabled) { ApplicationArea = All; }
                field("Template Item No."; Rec."Template Item No.") { ApplicationArea = All; }
                field("Copy Unit Price"; Rec."Copy Unit Price") { ApplicationArea = All; }
                field("Copy Posting Groups"; Rec."Copy Posting Groups") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SyncSetup)
            {
                ApplicationArea = All;
                Caption = 'Sync PIM setup to this company';
                Image = Import;

                trigger OnAction()
                var
                    PIMCompanySync: Codeunit "PIM Company Sync";
                begin
                    PIMCompanySync.SyncPIMSetup(Rec.Code);
                    Message('PIM setup synced to %1.', Rec."Company Name");
                end;
            }
        }
        area(Promoted)
        {
            actionref(SyncSetup_Promoted; SyncSetup) { }
        }
    }
}
