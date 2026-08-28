page 50121 "PIM Product Family Group Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "PIM Product Family Group";
    Caption = 'Main Product Family';

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
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
                field("Family Count"; Rec."Family Count")
                {
                    ApplicationArea = All;
                }
            }
            part(Families; "PIM Families ListPart")
            {
                ApplicationArea = All;
                SubPageLink = "Family Group Code" = field(Code);
            }
            part(Shared; "PIM Family Shared ListPart")
            {
                ApplicationArea = All;
                SubPageLink = "Family Group Code" = field(Code);
                Caption = 'Shared SharePoint documents and notes (whole main family)';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenVisualBoard)
            {
                ApplicationArea = All;
                Caption = 'Visual Board';
                Image = Hierarchy;
                ToolTip = 'Show Main Product Family → Product Family → Default Item → Item Variants, like the Coca Cola layout.';

                trigger OnAction()
                var
                    VisualBoard: Page "PIM Family Visual Board";
                begin
                    VisualBoard.SetFamilyGroupCode(Rec.Code);
                    VisualBoard.Run();
                end;
            }
            action(ShopifyHelp)
            {
                ApplicationArea = All;
                Caption = 'How this publishes to Shopify';
                Image = Export;

                trigger OnAction()
                begin
                    Message('Each default item is one Shopify product via Add to Shopify. Glass / PET / Can are separate default items (separate Shopify products). Item Variants under each default item become Shopify variants. Documents stored here are shared by every item in this main family.');
                end;
            }
        }
    }
}
