pageextension 50120 "PIM Item Card Family" extends "Item Card"
{
    layout
    {
        addlast(Content)
        {
            group(PIMProductFamily)
            {
                Caption = 'Product Family';

                field("PIM Family Group Code"; Rec."PIM Family Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Main product family (brand or line), e.g. Coca Cola or Cleaning Soap.';
                }
                field("PIM Product Family Code"; Rec."PIM Product Family Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Product family this item belongs to, e.g. Glass Bottle or Cleaning Soap.';
                }
                field("PIM Classification"; Rec."PIM Classification")
                {
                    ApplicationArea = All;
                    ToolTip = 'Classification copied from the product family (Glass Bottle, PET, Can, …).';
                }
                field("PIM Family Role"; Rec."PIM Family Role")
                {
                    ApplicationArea = All;
                    ToolTip = 'Default Item is the parent (Produkt Main). Variant is V1, V2, … under that parent.';
                }
                field("PIM Variant Label"; Rec."PIM Variant Label")
                {
                    ApplicationArea = All;
                    ToolTip = 'Parent, V1, V2 as shown in the family hierarchy.';
                }
                field("PIM Parent Item No."; Rec."PIM Parent Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The default item this variant belongs to. Blank when this item is a default item.';
                    Enabled = IsVariantRole;
                }
                field("PIM Variant Dimension"; Rec."PIM Variant Dimension")
                {
                    ApplicationArea = All;
                    ToolTip = 'Dimension that distinguishes variants, e.g. Gebinde Volumen or Color.';
                }
                field("PIM Variant Dim. Value"; Rec."PIM Variant Dim. Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'This item''s value for the family variant dimension, e.g. 0.5L or Pink.';
                }
            }
        }
        addlast(factboxes)
        {
            part(PIMFamilyMembers; "PIM Item Family Factbox")
            {
                ApplicationArea = All;
                Caption = 'Family: Default Item and Variants';
                SubPageLink = "Product Family Code" = field("PIM Product Family Code");
                SubPageView = sorting("Product Family Code", "Display Order");
                Visible = HasProductFamily;
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            group(PIMFamily)
            {
                Caption = 'Product Family';
                Image = ItemGroup;

                action(PIMOpenFamily)
                {
                    ApplicationArea = All;
                    Caption = 'Open Product Family';
                    Image = ItemGroup;
                    ToolTip = 'Open the family card with Parent / V1 / V2 members.';

                    trigger OnAction()
                    begin
                        OpenCurrentFamily();
                    end;
                }
                action(PIMMakeDefaultItem)
                {
                    ApplicationArea = All;
                    Caption = 'Make Default Item';
                    Image = MakeOrder;
                    ToolTip = 'Mark this item as the parent / default item in its product family.';

                    trigger OnAction()
                    var
                        PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
                    begin
                        CurrPage.SaveRecord();
                        PIMProductFamilyMgt.MakeDefaultItem(Rec."No.");
                        CurrPage.Update(false);
                        Message('Item %1 is now a default item (Parent) in family %2.', Rec."No.", Rec."PIM Product Family Code");
                    end;
                }
                action(PIMAddVariant)
                {
                    ApplicationArea = All;
                    Caption = 'Add Variant';
                    Image = ItemVariant;
                    ToolTip = 'Pick an existing item and hang it under this default item as V1, V2, …';

                    trigger OnAction()
                    begin
                        AddVariantToThisItem();
                    end;
                }
                action(PIMCopyFromParent)
                {
                    ApplicationArea = All;
                    Caption = 'Copy UOM and VAT from Default Item';
                    Image = Copy;
                    ToolTip = 'Copy unit of measure and VAT posting group from the parent default item.';

                    trigger OnAction()
                    var
                        PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
                    begin
                        CurrPage.SaveRecord();
                        PIMProductFamilyMgt.CopyOperationalAttributesFromParent(Rec."No.");
                        CurrPage.Update(false);
                    end;
                }
                action(PIMOpenFamilyGroups)
                {
                    ApplicationArea = All;
                    Caption = 'Product Family Groups';
                    Image = Hierarchy;
                    RunObject = page "PIM Product Family Groups";
                    ToolTip = 'Maintain main product families such as Coca Cola or Cleaning Soap.';
                }
                action(PIMOpenFamilies)
                {
                    ApplicationArea = All;
                    Caption = 'Product Families';
                    Image = Category;
                    RunObject = page "PIM Product Families";
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        IsVariantRole := Rec."PIM Family Role" = Rec."PIM Family Role"::Variant;
        HasProductFamily := Rec."PIM Product Family Code" <> '';
        CurrPage.PIMFamilyMembers.Page.SetCurrentItemNo(Rec."No.");
    end;

    var
        IsVariantRole: Boolean;
        HasProductFamily: Boolean;

    local procedure OpenCurrentFamily()
    var
        PIMProductFamily: Record "PIM Product Family";
    begin
        if Rec."PIM Product Family Code" = '' then begin
            Page.Run(Page::"PIM Product Families");
            exit;
        end;

        PIMProductFamily.Get(Rec."PIM Product Family Code");
        Page.Run(Page::"PIM Product Family Card", PIMProductFamily);
    end;

    local procedure AddVariantToThisItem()
    var
        VariantItem: Record Item;
        ItemList: Page "Item List";
        PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
        DimensionValue: Text[50];
    begin
        CurrPage.SaveRecord();
        Rec.Get(Rec."No.");

        if Rec."PIM Product Family Code" = '' then
            Error('Assign a Product Family on this item first, then add variants.');

        if Rec."PIM Family Role" <> Rec."PIM Family Role"::"Default Item" then
            PIMProductFamilyMgt.MakeDefaultItem(Rec."No.");

        VariantItem.SetFilter("No.", '<>%1', Rec."No.");
        ItemList.SetTableView(VariantItem);
        ItemList.LookupMode(true);
        if ItemList.RunModal() <> Action::LookupOK then
            exit;

        ItemList.GetRecord(VariantItem);
        DimensionValue := CopyStr(VariantItem.Description, 1, 50);
        PIMProductFamilyMgt.AddItemAsVariant(Rec."No.", VariantItem."No.", DimensionValue);
        Message('Item %1 was added as a variant of default item %2.', VariantItem."No.", Rec."No.");
        CurrPage.Update(false);
    end;
}
