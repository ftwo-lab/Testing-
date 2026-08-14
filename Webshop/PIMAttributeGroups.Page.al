page 50610 "PIM Attribute Groups"
{
    Caption = 'PIM Attribute Groups';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    AdditionalSearchTerms = 'PIM, Akeneo, attribute group';
    SourceTable = "PIM Attribute Group";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Sort Order"; Rec."Sort Order") { ApplicationArea = All; }
            }
        }
    }
}
