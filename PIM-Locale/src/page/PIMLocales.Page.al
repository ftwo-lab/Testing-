page 50100 "PIM Locales"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "PIM Locale";
    Caption = 'PIM Locales';
    InsertAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(Locales)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = All;
                }
                field("AI Locale Tag"; Rec."AI Locale Tag")
                {
                    ApplicationArea = All;
                }
                field("Is Source Locale"; Rec."Is Source Locale")
                {
                    ApplicationArea = All;
                }
                field("Display Order"; Rec."Display Order")
                {
                    ApplicationArea = All;
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateDefaults)
            {
                ApplicationArea = All;
                Caption = 'Create Default Locales';
                Image = Setup;
                ToolTip = 'Creates English, Germany, and Swiss German locales.';

                trigger OnAction()
                var
                    PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
                begin
                    PIMLocaleMgt.EnsureDefaultLocales();
                    CurrPage.Update(false);
                end;
            }
            action(OpenTableSetup)
            {
                ApplicationArea = All;
                Caption = 'Locale Table Setup';
                Image = SetupList;
                ToolTip = 'Configure custom tables such as Extended Details for translation.';

                trigger OnAction()
                begin
                    Page.Run(Page::"PIM Locale Table Setup");
                end;
            }
        }
    }
}
