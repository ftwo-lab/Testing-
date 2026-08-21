page 50351 "Product Visual Card"
{
    Caption = 'Visual Product View';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Lists;
    AdditionalSearchTerms = 'Shopify, Webshop, Shop, Storefront, Visual product';
    SourceTable = Item;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    DataCaptionFields = "No.", Description;
    AboutTitle = 'Visual Product View';
    AboutText = 'Shows this Business Central item as a webshop product page, including price, stock, picture, and every standard and custom field.';

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
                    SendProductData();
                end;

                trigger OpenItemCard(ItemNo: Text)
                var
                    Item: Record Item;
                begin
                    if Item.Get(ItemNo) then
                        Page.Run(Page::"Item Card", Item);
                end;

                trigger BackToCatalog()
                begin
                    Page.Run(Page::"Product Webshop");
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(OpenWebshop)
            {
                ApplicationArea = All;
                Caption = 'Open Webshop';
                Image = ShowList;
                ToolTip = 'Open the product webshop catalog.';

                trigger OnAction()
                begin
                    Page.Run(Page::"Product Webshop");
                end;
            }
            action(RefreshView)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Image = Refresh;
                ToolTip = 'Reload all product fields and related data into the visual view.';

                trigger OnAction()
                begin
                    SendProductData();
                end;
            }
        }
        area(Promoted)
        {
            actionref(OpenWebshop_Promoted; OpenWebshop) { }
            actionref(RefreshView_Promoted; RefreshView) { }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SendProductData();
    end;

    var
        ControlIsReady: Boolean;

    local procedure SendProductData()
    var
        ProductVisualData: Codeunit "Product Visual Data";
    begin
        if not ControlIsReady then
            exit;
        CurrPage.ProductViewer.SetProductData(ProductVisualData.BuildProductJson(Rec));
    end;
}
