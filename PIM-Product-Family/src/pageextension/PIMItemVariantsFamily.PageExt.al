pageextension 50122 "PIM Item Variants Family" extends "Item Variants"
{
    actions
    {
        addlast(Processing)
        {
            action(PIMLoadIntoFamily)
            {
                ApplicationArea = All;
                Caption = 'Show in Product Family';
                Image = ItemGroup;
                ToolTip = 'Refresh V1, V2 on the product family for this item. Add to Shopify still uses these Item Variants.';

                trigger OnAction()
                var
                    PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
                    Loaded: Integer;
                begin
                    Loaded := PIMProductFamilyMgt.SyncNativeVariants(Rec."Item No.");
                    Message('%1 Item Variant(s) are shown in the product family under the default item.', Loaded);
                end;
            }
        }
    }
}
