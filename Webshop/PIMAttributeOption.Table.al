table 50602 "PIM Attribute Option"
{
    Caption = 'PIM Attribute Option';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Attribute Code"; Code[20])
        {
            Caption = 'Attribute Code';
            TableRelation = "PIM Attribute";
            NotBlank = true;
        }
        field(2; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(3; Caption; Text[100])
        {
            Caption = 'Caption';
        }
        field(4; "Sort Order"; Integer)
        {
            Caption = 'Sort Order';
        }
    }

    keys
    {
        key(PK; "Attribute Code", "Code")
        {
            Clustered = true;
        }
    }
}
