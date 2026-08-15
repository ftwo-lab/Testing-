page 50618 "PIM Product Values"
{
    Caption = 'PIM Attributes';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "PIM Product Value";
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Channel Code"; Rec."Channel Code") { ApplicationArea = All; }
                field("Language Code"; Rec."Language Code") { ApplicationArea = All; }
                field("Attribute Code"; Rec."Attribute Code") { ApplicationArea = All; }
                field("Attribute Caption"; Rec."Attribute Caption") { ApplicationArea = All; }
                field("Group Code"; Rec."Group Code") { ApplicationArea = All; }
                field("Attribute Type"; Rec."Attribute Type") { ApplicationArea = All; }
                field(Value; Rec.Value) { ApplicationArea = All; }
            }
        }
    }
}
