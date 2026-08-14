page 50613 "PIM Attribute Options"
{
    Caption = 'Options';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "PIM Attribute Option";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field(Caption; Rec.Caption) { ApplicationArea = All; }
                field("Sort Order"; Rec."Sort Order") { ApplicationArea = All; }
            }
        }
    }
}
