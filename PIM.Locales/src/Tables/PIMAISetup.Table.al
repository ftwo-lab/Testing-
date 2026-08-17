table 50102 "PIM AI Setup"
{
    Caption = 'PIM AI Setup';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Endpoint URL"; Text[250])
        {
            Caption = 'Endpoint URL';
            ExtendedDatatype = URL;
        }
        field(3; "Deployment Name"; Text[100])
        {
            Caption = 'Deployment Name';
        }
        field(4; "API Key"; Text[250])
        {
            Caption = 'API Key';
            ExtendedDatatype = Masked;
        }
        field(5; Enabled; Boolean)
        {
            Caption = 'Enabled';
        }
        field(6; "System Prompt"; Text[2048])
        {
            Caption = 'System Prompt';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
