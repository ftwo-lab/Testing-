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
        field(2; "AI Provider"; Enum "PIM AI Provider")
        {
            Caption = 'AI Provider';
            InitValue = "Azure Translator";
        }
        field(3; "Endpoint URL"; Text[250])
        {
            Caption = 'Endpoint URL';
            ExtendedDatatype = URL;
        }
        field(4; "Deployment Name"; Text[100])
        {
            Caption = 'Model / Deployment Name';
            ToolTip = 'Azure OpenAI: deployment name, e.g. gpt-4o-mini. Claude: model name, e.g. claude-sonnet-4-20250514. Not used for Azure Translator.';
        }
        field(8; "API Region"; Code[20])
        {
            Caption = 'API Region';
            InitValue = eastasia;
            ToolTip = 'Azure Translator only. Region of your Translator resource, e.g. eastasia, westeurope.';
        }
        field(5; "API Key"; Text[250])
        {
            Caption = 'API Key';
            ExtendedDatatype = Masked;
        }
        field(6; Enabled; Boolean)
        {
            Caption = 'Enabled';
        }
        field(7; "System Prompt"; Text[2048])
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
