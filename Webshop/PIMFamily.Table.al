table 50603 "PIM Family"
{
    Caption = 'PIM Family';
    DataClassification = CustomerContent;
    LookupPageId = "PIM Families";
    DrillDownPageId = "PIM Families";

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
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
