page 50611 "PIM Attributes"
{
    Caption = 'PIM Attributes';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    AdditionalSearchTerms = 'PIM, Akeneo, attribute';
    SourceTable = "PIM Attribute";
    CardPageId = "PIM Attribute Card";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field(Caption; Rec.Caption) { ApplicationArea = All; }
                field("Type"; Rec."Type") { ApplicationArea = All; }
                field("Group Code"; Rec."Group Code") { ApplicationArea = All; }
                field("Shopify Field"; Rec."Shopify Field") { ApplicationArea = All; }
                field(Scopable; Rec.Scopable) { ApplicationArea = All; }
                field(Localizable; Rec.Localizable) { ApplicationArea = All; }
            }
        }
    }
}
