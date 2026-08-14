page 50615 "PIM Family Card"
{
    Caption = 'PIM Family';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "PIM Family";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
            }
            part(Attributes; "PIM Family Attributes")
            {
                ApplicationArea = All;
                SubPageLink = "Family Code" = field("Code");
            }
        }
    }
}
