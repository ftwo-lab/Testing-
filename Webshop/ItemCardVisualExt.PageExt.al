pageextension 50353 "Item Card Visual Ext" extends "Item Card"
{
    layout
    {
        addlast(content)
        {
            group(PIM)
            {
                Caption = 'PIM';
                field("PIM Family Code"; Rec."PIM Family Code")
                {
                    ApplicationArea = All;
                }
                field("PIM Category Code"; Rec."PIM Category Code")
                {
                    ApplicationArea = All;
                }
                field("PIM Published"; Rec."PIM Published")
                {
                    ApplicationArea = All;
                    ToolTip = 'Show this item in the webshop using PIM data only.';
                }
            }
            part(PIMMarketplaces; "PIM Item Marketplaces")
            {
                ApplicationArea = All;
                SubPageLink = "Item No." = field("No.");
                Caption = 'Sync to companies';
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
                ToolTip = 'Edit Akeneo-style product information for this item.';

                trigger OnAction()
                begin
                    Page.Run(Page::"PIM Product Enrichment", Rec);
                end;
            }
            action(SyncToCompanies)
            {
                ApplicationArea = All;
                Caption = 'Sync to companies';
                Image = Refresh;

                trigger OnAction()
                var
                    PIMCompanySync: Codeunit "PIM Company Sync";
                begin
                    PIMCompanySync.SyncItem(Rec."No.");
                    Message('Sync finished. Check Sync to companies and PIM Sync Log.');
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
            actionref(SyncToCompanies_Promoted; SyncToCompanies) { }
            actionref(VisualProductView_Promoted; VisualProductView) { }
            actionref(ProductWebshop_Promoted; ProductWebshop) { }
        }
    }
}
