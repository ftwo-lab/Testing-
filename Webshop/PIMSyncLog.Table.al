table 50638 "PIM Sync Log"
{
    Caption = 'PIM Sync Log';
    DataClassification = SystemMetadata;
    DrillDownPageId = "PIM Sync Log";
    LookupPageId = "PIM Sync Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(3; "Marketplace Code"; Code[20])
        {
            Caption = 'Marketplace Code';
        }
        field(4; "Company Name"; Text[50])
        {
            Caption = 'Company Name';
        }
        field(5; Status; Text[30])
        {
            Caption = 'Status';
        }
        field(6; Message; Text[250])
        {
            Caption = 'Message';
        }
        field(7; "Created at"; DateTime)
        {
            Caption = 'Created at';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Item; "Item No.", "Created at") { }
    }
}
