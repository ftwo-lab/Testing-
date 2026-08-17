page 50102 "PIM Item Locale Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "PIM Item Locale Data";
    Caption = 'Item Locale Content';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Locale Code"; Rec."Locale Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                }
                field("Extended Description"; Rec."Extended Description")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
                field("Marketing Text"; Rec."Marketing Text")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
            }
            group(Status)
            {
                Caption = 'Status';

                field("Translation Status"; Rec."Translation Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Translated by AI"; Rec."Translated by AI")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Last Translated At"; Rec."Last Translated At")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TranslateWithAI)
            {
                ApplicationArea = All;
                Caption = 'Translate with AI';
                Image = Translate;
                ToolTip = 'Generate translated content from the source locale using AI.';

                trigger OnAction()
                var
                    PIMAITranslator: Codeunit "PIM AI Translator";
                begin
                    PIMAITranslator.TranslateItemToLocale(Rec."Item No.", Rec."Locale Code", true);
                    CurrPage.Update(false);
                end;
            }
            action(MarkReviewed)
            {
                ApplicationArea = All;
                Caption = 'Mark Reviewed';
                Image = Approve;

                trigger OnAction()
                begin
                    Rec."Translation Status" := Rec."Translation Status"::Reviewed;
                    Rec.Modify(true);
                end;
            }
        }
    }
}
