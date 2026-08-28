page 50123 "PIM Product Family Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "PIM Product Family";
    Caption = 'Product Family';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("Family Group Code"; Rec."Family Group Code")
                {
                    ApplicationArea = All;
                }
                field("Family Group Name"; Rec."Family Group Name")
                {
                    ApplicationArea = All;
                }
                field(Classification; Rec.Classification)
                {
                    ApplicationArea = All;
                    ToolTip = 'Packaging or product class, e.g. Glass Bottle, PET-Bottle, Can.';
                }
                field("Variant Dimension"; Rec."Variant Dimension")
                {
                    ApplicationArea = All;
                    ToolTip = 'What makes a variant different from the default item, e.g. Gebinde Volumen or Color.';
                }
                field("Primary Default Item No."; Rec."Primary Default Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The main product (Produkt Main) for this family.';
                }
                field("Primary Default Item Name"; Rec."Primary Default Item Name")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
            }
            part(Members; "PIM Family Member ListPart")
            {
                ApplicationArea = All;
                SubPageLink = "Product Family Code" = field(Code);
                SubPageView = sorting("Product Family Code", "Display Order");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshHierarchy)
            {
                ApplicationArea = All;
                Caption = 'Refresh Parent / V1 / V2';
                Image = Refresh;
                ToolTip = 'Recalculates Parent, V1, V2 labels and indentation.';

                trigger OnAction()
                var
                    PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
                begin
                    PIMProductFamilyMgt.RecalculateFamilyDisplay(Rec.Code);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
