page 50100 "Product Visual Card"
{
    Caption = 'Visual Product View';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Item;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    DataCaptionFields = "No.", Description;
    AboutTitle = 'Visual Product View';
    AboutText = 'Shows this Business Central item as a product page, including every standard and custom field plus related records.';

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
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RefreshView)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Image = Refresh;
                ToolTip = 'Reload all product fields and related data into the visual view.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    SendProductData();
                end;
            }
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
