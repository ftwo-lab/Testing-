table 50124 "PIM Family Visual Line"
{
    Caption = 'PIM Family Visual Line';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Node Type"; Enum "PIM Visual Node Type")
        {
            Caption = 'Level';
        }
        field(3; "Variant Label"; Text[30])
        {
            Caption = 'Label';
        }
        field(4; Description; Text[150])
        {
            Caption = 'Description';
        }
        field(5; Classification; Text[50])
        {
            Caption = 'Classification';
        }
        field(6; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(7; "Variant Code"; Code[10])
        {
            Caption = 'Variant';
        }
        field(8; "Base Unit of Measure"; Code[10])
        {
            Caption = 'UOM';
        }
        field(9; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT';
        }
        field(10; "Variant Dim. Value"; Text[50])
        {
            Caption = 'Dimension value';
        }
        field(11; Indentation; Integer)
        {
            Caption = 'Indentation';
        }
        field(12; "Family Group Code"; Code[20])
        {
            Caption = 'Main Product Family';
        }
        field(13; "Product Family Code"; Code[20])
        {
            Caption = 'Product Family';
        }
        field(14; "Shared Content Count"; Integer)
        {
            Caption = 'Shared docs / notes';
        }
        field(15; "Style Strong"; Boolean)
        {
            Caption = 'Bold';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
