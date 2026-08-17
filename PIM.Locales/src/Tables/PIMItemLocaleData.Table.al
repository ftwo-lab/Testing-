table 50101 "PIM Item Locale Data"
{
    Caption = 'PIM Item Locale Data';
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
            TableRelation = "PIM Locale".Code where(Enabled = const(true));
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(4; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(5; "Extended Description"; Text[2048])
        {
            Caption = 'Extended Description';
        }
        field(6; "Marketing Text"; Text[2048])
        {
            Caption = 'Marketing Text';
        }
        field(7; "Translated by AI"; Boolean)
        {
            Caption = 'Translated by AI';
            Editable = false;
        }
        field(8; "Last Translated At"; DateTime)
        {
            Caption = 'Last Translated At';
            Editable = false;
        }
        field(9; "Translation Status"; Enum "PIM Translation Status")
        {
            Caption = 'Translation Status';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Item No.", "Locale Code")
        {
            Clustered = true;
        }
    }
}
