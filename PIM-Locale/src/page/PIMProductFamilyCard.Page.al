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
            part(Shared; "PIM Family Shared ListPart")
            {
                ApplicationArea = All;
                SubPageLink = "Product Family Code" = field(Code);
                Caption = 'Shared SharePoint documents and notes';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LoadItemVariants)
            {
                ApplicationArea = All;
                Caption = 'Load Item Variants';
                Image = ItemVariant;
                ToolTip = 'Pull native Item Variants of the primary default item into this family as V1, V2, …';

                trigger OnAction()
                var
                    PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
                    Loaded: Integer;
                begin
                    if Rec."Primary Default Item No." = '' then
                        Error('Set Primary Default Item No. first.');
                    Loaded := PIMProductFamilyMgt.SyncNativeVariants(Rec."Primary Default Item No.");
                    CurrPage.Update(false);
                    Message('%1 Item Variant(s) are shown as V1, V2 under the default item.', Loaded);
                end;
            }
            action(OpenVisualBoard)
            {
                ApplicationArea = All;
                Caption = 'Visual Board';
                Image = Hierarchy;

                trigger OnAction()
                var
                    VisualBoard: Page "PIM Family Visual Board";
                begin
                    VisualBoard.SetFamilyGroupCode(Rec."Family Group Code");
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
                    Message('Do not build a second Shopify sync. Open the default item and use the Microsoft connector action Add to Shopify. That item becomes the Shopify product; its Item Variants become Shopify variants. Shared documents on this family stay at product level.');
                end;
            }
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
