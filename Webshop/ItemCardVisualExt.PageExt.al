pageextension 50353 "Item Card Visual Ext" extends "Item Card"
{
    actions
    {
        addlast(navigation)
        {
            action(VisualProductView)
            {
                ApplicationArea = All;
                Caption = 'View in Webshop';
                Image = View;
                ToolTip = 'Open this item as a webshop product page, including every standard and custom field.';

                trigger OnAction()
                begin
                    Page.Run(Page::"Product Visual Card", Rec);
                end;
            }
            action(ProductWebshop)
            {
                ApplicationArea = All;
                Caption = 'Product Webshop';
                Image = ShowList;
                ToolTip = 'Browse items in a webshop catalog view.';

                trigger OnAction()
                begin
                    Page.Run(Page::"Product Webshop");
                end;
            }
        }
        addlast(Category_Process)
        {
            actionref(VisualProductView_Promoted; VisualProductView) { }
            actionref(ProductWebshop_Promoted; ProductWebshop) { }
        }
    }
}
