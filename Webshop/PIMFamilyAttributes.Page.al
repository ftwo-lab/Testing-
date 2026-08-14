page 50616 "PIM Family Attributes"
{
    Caption = 'Family attributes';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "PIM Family Attribute";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Code"; Rec."Attribute Code") { ApplicationArea = All; }
                field("Attribute Caption"; Rec."Attribute Caption") { ApplicationArea = All; }
                field("Group Code"; Rec."Group Code") { ApplicationArea = All; }
                field(Required; Rec.Required) { ApplicationArea = All; }
            }
        }
    }
}
