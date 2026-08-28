page 50120 "PIM Product Family Groups"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "PIM Product Family Group";
    Caption = 'PIM Product Family Groups';
    CardPageId = "PIM Product Family Group Card";
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(Groups)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Family Count"; Rec."Family Count")
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
            action(CreateExamples)
            {
                ApplicationArea = All;
                Caption = 'Create Example Families';
                Image = Setup;
                ToolTip = 'Creates the Cleaning Soap and Coca Cola family structure from the product-family examples.';

                trigger OnAction()
                var
                    PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
                begin
                    PIMProductFamilyMgt.EnsureExampleFamilies();
                    CurrPage.Update(false);
                    Message('Example main product families are ready: Cleaning Soap and Coca Cola.');
                end;
            }
        }
        area(Navigation)
        {
            action(OpenFamilies)
            {
                ApplicationArea = All;
                Caption = 'Product Families';
                Image = ItemGroup;
                RunObject = page "PIM Product Families";
                RunPageLink = "Family Group Code" = field(Code);
            }
        }
    }
}
