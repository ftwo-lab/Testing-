table 50605 "PIM Category"
{
    Caption = 'PIM Category';
    DataClassification = CustomerContent;
    LookupPageId = "PIM Categories";
    DrillDownPageId = "PIM Categories";

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
        field(3; "Parent Code"; Code[20])
        {
            Caption = 'Parent Category';
            TableRelation = "PIM Category";
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
