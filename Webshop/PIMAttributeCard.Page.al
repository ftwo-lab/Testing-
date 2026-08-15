page 50612 "PIM Attribute Card"
{
    Caption = 'PIM Attribute';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "PIM Attribute";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field(Caption; Rec.Caption) { ApplicationArea = All; }
                field("Type"; Rec."Type") { ApplicationArea = All; }
                field("Group Code"; Rec."Group Code") { ApplicationArea = All; }
                field("Shopify Field"; Rec."Shopify Field") { ApplicationArea = All; }
                field(Scopable; Rec.Scopable) { ApplicationArea = All; }
                field(Localizable; Rec.Localizable) { ApplicationArea = All; }
            }
            part(Options; "PIM Attribute Options")
            {
                ApplicationArea = All;
                SubPageLink = "Attribute Code" = field("Code");
                Visible = Rec.Type = Rec.Type::Option;
            }
        }
    }
}
