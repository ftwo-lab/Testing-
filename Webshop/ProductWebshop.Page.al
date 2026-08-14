page 50103 "Product Webshop"
{
    Caption = 'Product Webshop';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    AboutTitle = 'Product Webshop';
    AboutText = 'Browse Business Central items in a webshop layout. Open a product to see its picture, price, stock, and all standard and custom fields.';

    layout
    {
        area(content)
        {
            usercontrol(ProductViewer; ProductVisualViewer)
            {
                ApplicationArea = All;

                trigger ControlReady()
                begin
                    ControlIsReady := true;
                    SendCatalog();
                end;

                trigger ProductSelected(ItemNo: Text)
                var
                    Item: Record Item;
                    ProductVisualData: Codeunit "Product Visual Data";
                begin
                    if not ControlIsReady then
                        exit;
                    if Item.Get(ItemNo) then
                        CurrPage.ProductViewer.SetProductData(ProductVisualData.BuildProductJson(Item, true));
                end;

                trigger BackToCatalog()
                begin
                    SendCatalog();
                end;

                trigger OpenItemCard(ItemNo: Text)
                var
                    Item: Record Item;
                begin
                    if Item.Get(ItemNo) then
                        Page.Run(Page::"Item Card", Item);
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RefreshShop)
            {
                ApplicationArea = All;
                Caption = 'Refresh shop';
                Image = Refresh;
                ToolTip = 'Reload the webshop catalog from current Item data.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    SendCatalog();
                end;
            }
        }
    }

    var
        ControlIsReady: Boolean;

    local procedure SendCatalog()
    var
        ProductVisualData: Codeunit "Product Visual Data";
    begin
        if not ControlIsReady then
            exit;
        CurrPage.ProductViewer.SetProductData(ProductVisualData.BuildCatalogJson());
    end;
}
