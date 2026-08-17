table 50106 "PIM Item Locale Attribute"
{
    Caption = 'PIM Item Locale Attribute';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(2; "Locale Code"; Code[10])
        {
            Caption = 'Locale Code';
            TableRelation = "PIM Locale".Code;
        }
        field(3; "Attribute ID"; Integer)
        {
            Caption = 'Attribute ID';
        }
        field(4; "Attribute Name"; Text[250])
        {
            Caption = 'Attribute Name';
        }
        field(5; Value; Text[250])
        {
            Caption = 'Value';
        }
    }

    keys
    {
        key(PK; "Item No.", "Locale Code", "Attribute ID")
        {
            Clustered = true;
        }
    }
}
