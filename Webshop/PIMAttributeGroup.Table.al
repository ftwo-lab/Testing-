table 50600 "PIM Attribute Group"
{
    Caption = 'PIM Attribute Group';
    DataClassification = CustomerContent;
    LookupPageId = "PIM Attribute Groups";
    DrillDownPageId = "PIM Attribute Groups";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Sort Order"; Integer)
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
        key(Sort; "Sort Order") { }
    }
}
