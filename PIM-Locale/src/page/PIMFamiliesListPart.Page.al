page 50127 "PIM Families ListPart"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "PIM Product Family";
    Caption = 'Product Families';
    CardPageId = "PIM Product Family Card";

    layout
    {
        area(Content)
        {
            repeater(Families)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Classification; Rec.Classification)
                {
                    ApplicationArea = All;
                }
                field("Variant Dimension"; Rec."Variant Dimension")
                {
                    ApplicationArea = All;
                }
                field("Primary Default Item No."; Rec."Primary Default Item No.")
                {
                    ApplicationArea = All;
                }
                field("Member Count"; Rec."Member Count")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenFamily)
            {
                ApplicationArea = All;
                Caption = 'Open Family';
                Image = Card;
                RunObject = page "PIM Product Family Card";
                RunPageLink = Code = field(Code);
            }
        }
    }
}
