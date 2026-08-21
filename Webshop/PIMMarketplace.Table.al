table 50636 "PIM Marketplace"
{
    Caption = 'PIM Marketplace';
    DataClassification = CustomerContent;
    LookupPageId = "PIM Marketplaces";
    DrillDownPageId = "PIM Marketplaces";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Marketplace Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Company Name"; Text[50])
        {
            Caption = 'Business Central Company';
            TableRelation = Company.Name;
            ToolTip = 'Exact company name in this environment. Sync uses ChangeCompany and keeps the same Item No.';
        }
        field(4; Enabled; Boolean)
        {
            Caption = 'Enabled';
        }
        field(5; "Template Item No."; Code[20])
        {
            Caption = 'Template Item No. (in target)';
            ToolTip = 'Optional item that already exists in the target company. Used only for posting groups when creating a new item. Item No. is never taken from the template.';
        }
        field(6; "Copy Unit Price"; Boolean)
        {
            Caption = 'Copy Unit Price';
            InitValue = true;
        }
        field(7; "Copy Posting Groups"; Boolean)
        {
            Caption = 'Copy Posting Groups from Master';
            InitValue = false;
        }
        field(8; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
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
