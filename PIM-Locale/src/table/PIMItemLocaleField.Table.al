table 50104 "PIM Item Locale Field"
{
    Caption = 'PIM Item Locale Field';
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
        field(3; "Table No."; Integer)
        {
            Caption = 'Table No.';
        }
        field(4; "Field No."; Integer)
        {
            Caption = 'Field No.';
        }
        field(5; "Field Name"; Text[80])
        {
            Caption = 'Field Name';
        }
        field(6; Value; Text[2048])
        {
            Caption = 'Value';
        }
    }

    keys
    {
        key(PK; "Item No.", "Locale Code", "Table No.", "Field No.")
        {
            Clustered = true;
        }
    }
}
