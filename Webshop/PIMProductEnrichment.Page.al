page 50619 "PIM Product Enrichment"
{
    Caption = 'PIM Product Enrichment';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Lists;
    AdditionalSearchTerms = 'PIM, Akeneo, enrichment, product information';
    SourceTable = Item;
    DataCaptionFields = "No.", Description;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'Product';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("PIM Family Code"; Rec."PIM Family Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("PIM Category Code"; Rec."PIM Category Code")
                {
                    ApplicationArea = All;
                }
                field("PIM Published"; Rec."PIM Published")
                {
                    ApplicationArea = All;
                    ToolTip = 'If enabled, this product appears in the webshop with PIM data only.';
                }
                field(CompletenessPct; CompletenessPct)
                {
                    ApplicationArea = All;
                    Caption = 'Completeness %';
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = CompletenessPct >= 100;
                }
            }
            part(Values; "PIM Product Values")
            {
                ApplicationArea = All;
                SubPageLink = "Item No." = field("No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(LoadFamily)
            {
                ApplicationArea = All;
                Caption = 'Load family attributes';
                Image = Refresh;

                trigger OnAction()
                var
                    PIMEnrichment: Codeunit "PIM Enrichment";
                begin
                    PIMEnrichment.EnsureFamilyAttributes(Rec."No.", Rec."PIM Family Code");
                    CurrPage.Update(false);
                end;
            }
            action(OpenWebshop)
            {
                ApplicationArea = All;
                Caption = 'Preview Webshop';
                Image = View;
                Enabled = Rec."PIM Published";

                trigger OnAction()
                begin
                    Page.Run(Page::"Product Visual Card", Rec);
                end;
            }
        }
        area(Promoted)
        {
            actionref(LoadFamily_Promoted; LoadFamily) { }
            actionref(OpenWebshop_Promoted; OpenWebshop) { }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        PIMEnrichment: Codeunit "PIM Enrichment";
    begin
        PIMEnrichment.EnsureFamilyAttributes(Rec."No.", Rec."PIM Family Code");
        CompletenessPct := PIMEnrichment.CompletenessPercent(Rec."No.", Rec."PIM Family Code");
    end;

    var
        CompletenessPct: Decimal;
}
