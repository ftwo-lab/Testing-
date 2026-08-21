pageextension 50354 "Item List Visual Ext" extends "Item List"
{
    layout
    {
        addafter(Description)
        {
            field("PIM Published"; Rec."PIM Published")
            {
                ApplicationArea = All;
            }
            field("PIM Family Code"; Rec."PIM Family Code")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action(PIMEnrichment)
            {
                ApplicationArea = All;
                Caption = 'PIM Enrichment';
                Image = ItemTracking;

                trigger OnAction()
                begin
                    Page.Run(Page::"PIM Product Enrichment", Rec);
                end;
            }
            action(VisualProductView)
            {
                ApplicationArea = All;
                Caption = 'View in Webshop';
                Image = View;

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

                trigger OnAction()
                begin
                    Page.Run(Page::"Product Webshop");
                end;
            }
        }
        addlast(Promoted)
        {
            actionref(PIMEnrichment_Promoted; PIMEnrichment) { }
            actionref(VisualProductView_Promoted; VisualProductView) { }
            actionref(ProductWebshop_Promoted; ProductWebshop) { }
        }
    }
}
