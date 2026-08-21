table 50608 "PIM Channel"
{
    Caption = 'PIM Channel';
    DataClassification = CustomerContent;
    LookupPageId = "PIM Channels";
    DrillDownPageId = "PIM Channels";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Channel Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; Enabled; Boolean)
        {
            Caption = 'Enabled';
            InitValue = true;
        }
        field(4; "Show in Webshop"; Boolean)
        {
            Caption = 'Show in Webshop';
            ToolTip = 'Items enabled on this channel appear in Product Webshop.';
        }
        field(5; "Language Code"; Code[10])
        {
            Caption = 'Locale / Language';
            TableRelation = Language;
        }
        field(6; "Currency Code"; Code[10])
        {
            Caption = 'Currency';
            TableRelation = Currency;
        }
        field(7; "Category Tree Code"; Code[20])
        {
            Caption = 'Category Tree';
            TableRelation = "PIM Category";
        }
        field(8; "Marketplace Code"; Code[20])
        {
            Caption = 'Linked Marketplace';
            TableRelation = "PIM Marketplace";
            ToolTip = 'Optional. Links this sales channel to a BC company for sync (DE, AT, …).';
        }
        field(9; "Channel Type"; Text[30])
        {
            Caption = 'Type';
            ToolTip = 'Webshop, B2B, Print, or Country.';
        }
        field(10; "Sort Order"; Integer)
        {
            Caption = 'Sort Order';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
        key(Sort; "Sort Order", Code) { }
    }
}
