pageextension 50121 "PIM Item List Family" extends "Item List"
{
    layout
    {
        addlast(Control1)
        {
            field("PIM Product Family Code"; Rec."PIM Product Family Code")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("PIM Family Role"; Rec."PIM Family Role")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("PIM Variant Label"; Rec."PIM Variant Label")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("PIM Parent Item No."; Rec."PIM Parent Item No.")
            {
                ApplicationArea = All;
                Visible = false;
            }
            field("PIM Variant Dim. Value"; Rec."PIM Variant Dim. Value")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }

    actions
    {
        addlast(Navigation)
        {
            action(PIMOpenFamilies)
            {
                ApplicationArea = All;
                Caption = 'Product Families';
                Image = ItemGroup;
                RunObject = page "PIM Product Families";
                ToolTip = 'Open product families, default items, and variants.';
            }
        }
    }
}
