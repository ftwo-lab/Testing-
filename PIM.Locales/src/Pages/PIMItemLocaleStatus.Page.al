page 50103 "PIM Item Locale Status"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "PIM Item Locale Data";
    Caption = 'Locale Status';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(LocaleLines)
            {
                field("Locale Code"; Rec."Locale Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Translation Status"; Rec."Translation Status")
                {
                    ApplicationArea = All;
                }
                field("Translated by AI"; Rec."Translated by AI")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
