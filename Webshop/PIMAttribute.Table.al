table 50601 "PIM Attribute"
{
    Caption = 'PIM Attribute';
    DataClassification = CustomerContent;
    LookupPageId = "PIM Attributes";
    DrillDownPageId = "PIM Attributes";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Caption; Text[100])
        {
            Caption = 'Caption';
        }
        field(3; "Type"; Enum "PIM Attribute Type")
        {
            Caption = 'Type';
        }
        field(4; "Group Code"; Code[20])
        {
            Caption = 'Group';
            TableRelation = "PIM Attribute Group";
        }
        field(5; "Shopify Field"; Text[50])
        {
            Caption = 'Shopify Field';
            ToolTip = 'Optional Shopify field name, for example title, vendor, body_html, or a metafield key.';
        }
        field(6; Scopable; Boolean)
        {
            Caption = 'Different per channel';
            ToolTip = 'If enabled, Germany, Spain, Amazon, and Shopify can each have their own value.';
        }
        field(7; Localizable; Boolean)
        {
            Caption = 'Different per language';
            ToolTip = 'If enabled, values can differ by language code.';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
