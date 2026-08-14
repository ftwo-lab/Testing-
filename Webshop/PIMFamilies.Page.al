page 50614 "PIM Families"
{
    Caption = 'PIM Families';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    AdditionalSearchTerms = 'PIM, Akeneo, family';
    SourceTable = "PIM Family";
    CardPageId = "PIM Family Card";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SeedDefaults)
            {
                ApplicationArea = All;
                Caption = 'Create default PIM setup';
                Image = Setup;

                trigger OnAction()
                var
                    PIMInstall: Codeunit "PIM Install";
                begin
                    PIMInstall.SeedPIM();
                    Message('Default PIM groups, attributes, family, and categories are ready.');
                end;
            }
        }
        area(Promoted)
        {
            actionref(SeedDefaults_Promoted; SeedDefaults) { }
        }
    }
}
