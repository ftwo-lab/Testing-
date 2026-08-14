page 50617 "PIM Categories"
{
    Caption = 'PIM Categories';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    AdditionalSearchTerms = 'PIM, Akeneo, category';
    SourceTable = "PIM Category";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Parent Code"; Rec."Parent Code") { ApplicationArea = All; }
            }
        }
    }
}
