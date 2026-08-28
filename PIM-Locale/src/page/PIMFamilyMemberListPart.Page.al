page 50125 "PIM Family Member ListPart"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "PIM Product Family Member";
    Caption = 'Default Items and Variants';
    SourceTableView = sorting("Product Family Code", "Display Order");
    AutoSplitKey = false;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Members)
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = Description;

                field("Variant Label"; Rec."Variant Label")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = IsDefaultItem;
                    ToolTip = 'Parent for a default item, V1 / V2 / … for its variants.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Caption = 'Item Variant';
                    ToolTip = 'Blank on the default item. Filled for a native Business Central Item Variant.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = IsDefaultItem;
                }
                field(Role; Rec.Role)
                {
                    ApplicationArea = All;
                }
                field("Parent Item No."; Rec."Parent Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Blank on a default item. On a variant, the parent default item.';
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
                field("Is Primary Default"; Rec."Is Primary Default")
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
            action(OpenItem)
            {
                ApplicationArea = All;
                Caption = 'Item Card';
                Image = Item;
                RunObject = page "Item Card";
                RunPageLink = "No." = field("Item No.");
            }
            action(CopyFromParent)
            {
                ApplicationArea = All;
                Caption = 'Copy UOM and VAT from Default Item';
                Image = Copy;
                ToolTip = 'Copies unit of measure and VAT posting group from the parent default item onto this variant.';

                trigger OnAction()
                var
                    PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
                begin
                    PIMProductFamilyMgt.CopyOperationalAttributesFromParent(Rec."Item No.");
                    CurrPage.Update(false);
                end;
            }
            action(LoadItemVariants)
            {
                ApplicationArea = All;
                Caption = 'Load Item Variants';
                Image = ItemVariant;
                ToolTip = 'Pull native Item Variants of this default item into the family as V1, V2.';

                trigger OnAction()
                var
                    PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
                begin
                    PIMProductFamilyMgt.SyncNativeVariants(Rec."Item No.");
                    CurrPage.Update(false);
                end;
            }
            action(MakeDefault)
            {
                ApplicationArea = All;
                Caption = 'Make Default Item';
                Image = MakeOrder;

                trigger OnAction()
                var
                    PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
                begin
                    PIMProductFamilyMgt.MakeDefaultItem(Rec."Item No.");
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Role := Rec.Role::"Default Item";
        Rec.Indentation := 0;
        Rec."Variant Label" := 'Parent';
    end;

    trigger OnAfterGetRecord()
    begin
        IsDefaultItem := Rec.Role = Rec.Role::"Default Item";
    end;

    var
        IsDefaultItem: Boolean;
}
