pageextension 50101 "Item Card Visual Ext" extends "Item Card"
{
    actions
    {
        addlast(navigation)
        {
            action(VisualProductView)
            {
                ApplicationArea = All;
                Caption = 'Visual Product View';
                Image = View;
                ToolTip = 'Open a website-style view of every standard and custom field for this item, plus related product data.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Page.Run(Page::"Product Visual Card", Rec);
                end;
            }
        }
    }
}
