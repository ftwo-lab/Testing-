page 50128 "PIM Family Visual Board"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "PIM Family Visual Line";
    SourceTableTemporary = true;
    Caption = 'Product Family Visual Board';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = true;

    layout
    {
        area(Content)
        {
            group(FilterGroup)
            {
                Caption = 'Main Product Family';

                field(FamilyGroupFilter; FamilyGroupCode)
                {
                    ApplicationArea = All;
                    Caption = 'Main Product Family';
                    TableRelation = "PIM Product Family Group";

                    trigger OnValidate()
                    begin
                        ReloadBoard();
                    end;
                }
            }
            repeater(Tree)
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = Description;
                Editable = false;

                field("Variant Label"; Rec."Variant Label")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = Rec."Style Strong";
                    Caption = 'Label';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = Rec."Style Strong";
                }
                field("Node Type"; Rec."Node Type")
                {
                    ApplicationArea = All;
                }
                field(Classification; Rec.Classification)
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Caption = 'Item Variant';
                }
                field("Variant Dim. Value"; Rec."Variant Dim. Value")
                {
                    ApplicationArea = All;
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Shared Content Count"; Rec."Shared Content Count")
                {
                    ApplicationArea = All;
                    Caption = 'Shared docs / notes';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Reload)
            {
                ApplicationArea = All;
                Caption = 'Refresh Board';
                Image = Refresh;

                trigger OnAction()
                begin
                    ReloadBoard();
                end;
            }
            action(OpenItem)
            {
                ApplicationArea = All;
                Caption = 'Open Default Item';
                Image = Item;
                Enabled = Rec."Item No." <> '';

                trigger OnAction()
                var
                    Item: Record Item;
                begin
                    if Rec."Item No." = '' then
                        exit;
                    Item.Get(Rec."Item No.");
                    Page.Run(Page::"Item Card", Item);
                end;
            }
            action(OpenVariants)
            {
                ApplicationArea = All;
                Caption = 'Item Variants';
                Image = ItemVariant;
                Enabled = Rec."Item No." <> '';

                trigger OnAction()
                var
                    ItemVariant: Record "Item Variant";
                begin
                    if Rec."Item No." = '' then
                        exit;
                    ItemVariant.SetRange("Item No.", Rec."Item No.");
                    Page.Run(Page::"Item Variants", ItemVariant);
                end;
            }
            action(OpenShared)
            {
                ApplicationArea = All;
                Caption = 'Shared SharePoint / Notes';
                Image = Links;

                trigger OnAction()
                var
                    SharedContent: Record "PIM Family Shared Content";
                begin
                    if Rec."Product Family Code" <> '' then
                        SharedContent.SetRange("Product Family Code", Rec."Product Family Code")
                    else
                        SharedContent.SetRange("Family Group Code", FamilyGroupCode);
                    Page.Run(Page::"PIM Family Shared Content", SharedContent);
                end;
            }
            action(ShopifyHelp)
            {
                ApplicationArea = All;
                Caption = 'How this publishes to Shopify';
                Image = Export;

                trigger OnAction()
                begin
                    Message('Use the Microsoft Shopify Connector on the default item (Add to Shopify). Default Item becomes the Shopify product. Item Variants (V1, V2) become Shopify product variants. Shared SharePoint documents and notes stay on the product, not on each variant.');
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if FamilyGroupCode = '' then
            FamilyGroupCode := FirstGroupCode();
        ReloadBoard();
    end;

    var
        FamilyGroupCode: Code[20];

    procedure SetFamilyGroupCode(GroupCode: Code[20])
    begin
        FamilyGroupCode := GroupCode;
    end;

    local procedure ReloadBoard()
    var
        PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
    begin
        PIMProductFamilyMgt.FillVisualBoard(FamilyGroupCode, Rec);
        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    local procedure FirstGroupCode(): Code[20]
    var
        Group: Record "PIM Product Family Group";
    begin
        if Group.FindFirst() then
            exit(Group.Code);
        exit('');
    end;
}
