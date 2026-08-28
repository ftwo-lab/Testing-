page 50122 "PIM Product Families"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "PIM Product Family";
    Caption = 'PIM Product Families';
    CardPageId = "PIM Product Family Card";
    Editable = true;

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
                }
                field("Variant Dimension"; Rec."Variant Dimension")
                {
                    ApplicationArea = All;
                }
                field("Primary Default Item No."; Rec."Primary Default Item No.")
                {
                    ApplicationArea = All;
                }
                field("Primary Default Item Name"; Rec."Primary Default Item Name")
                {
                    ApplicationArea = All;
                }
                field("Default Item Count"; Rec."Default Item Count")
                {
                    ApplicationArea = All;
                }
                field("Variant Count"; Rec."Variant Count")
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
                ToolTip = 'Creates Cleaning Soap and Coca Cola (Glass / PET / Can) families.';

                trigger OnAction()
                var
                    PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
                begin
                    PIMProductFamilyMgt.EnsureExampleFamilies();
                    CurrPage.Update(false);
                    Message('Example product families are ready.');
                end;
            }
            action(CreateExampleItems)
            {
                ApplicationArea = All;
                Caption = 'Create Example Items';
                Image = New;
                ToolTip = 'Creates sample default items and variants for Cleaning Soap and Coca Cola, using posting groups from an existing item.';

                trigger OnAction()
                var
                    PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
                    Created: Integer;
                begin
                    if not Confirm('Create sample items (PIM-SOAP-* and PIM-COKE-*) and attach them as default items and variants?', false) then
                        exit;
                    Created := PIMProductFamilyMgt.CreateExampleItems();
                    CurrPage.Update(false);
                    Message('%1 new example item(s) created. Open a family card to see Parent / V1 / V2.', Created);
                end;
            }
        }
        area(Navigation)
        {
            action(OpenCard)
            {
                ApplicationArea = All;
                Caption = 'Family Card';
                Image = Card;
                RunObject = page "PIM Product Family Card";
                RunPageLink = Code = field(Code);
            }
        }
    }
}
