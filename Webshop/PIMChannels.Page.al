page 50620 "PIM Channels"
{
    Caption = 'PIM Channels';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    AdditionalSearchTerms = 'PIM, Akeneo, channel, webshop, locale, ecommerce';
    SourceTable = "PIM Channel";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Channel Type"; Rec."Channel Type") { ApplicationArea = All; }
                field(Enabled; Rec.Enabled) { ApplicationArea = All; }
                field("Show in Webshop"; Rec."Show in Webshop") { ApplicationArea = All; }
                field("Language Code"; Rec."Language Code") { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field("Category Tree Code"; Rec."Category Tree Code") { ApplicationArea = All; }
                field("Marketplace Code"; Rec."Marketplace Code") { ApplicationArea = All; }
                field("Sort Order"; Rec."Sort Order") { ApplicationArea = All; }
            }
        }
    }
}
