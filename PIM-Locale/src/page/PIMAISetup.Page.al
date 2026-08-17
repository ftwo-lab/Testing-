page 50101 "PIM AI Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "PIM AI Setup";
    Caption = 'PIM AI Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                }
                field("AI Provider"; Rec."AI Provider")
                {
                    ApplicationArea = All;
                    ToolTip = 'Choose Azure Translator, Azure OpenAI, or Claude.';
                }
                field("Endpoint URL"; Rec."Endpoint URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Azure Translator: https://api.cognitive.microsofttranslator.com';
                }
                field("API Region"; Rec."API Region")
                {
                    ApplicationArea = All;
                    Visible = Rec."AI Provider" = Rec."AI Provider"::"Azure Translator";
                    ToolTip = 'Region of your Translator resource. For MSBCTranslator in East Asia use eastasia.';
                }
                field("Deployment Name"; Rec."Deployment Name")
                {
                    ApplicationArea = All;
                    Caption = 'Model / Deployment Name';
                    Visible = Rec."AI Provider" <> Rec."AI Provider"::"Azure Translator";
                }
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Azure Translator: Key 1 from Keys and Endpoint page.';
                }
                field("System Prompt"; Rec."System Prompt")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    Visible = Rec."AI Provider" <> Rec."AI Provider"::"Azure Translator";
                }
            }
            group(TranslatorHelp)
            {
                Caption = 'Azure Translator quick setup (MSBCTranslator)';
                Visible = Rec."AI Provider" = Rec."AI Provider"::"Azure Translator";

                field(TranslatorEndpointHelp; TranslatorEndpointHelp)
                {
                    ApplicationArea = All;
                    Caption = 'Endpoint URL';
                    Editable = false;
                }
                field(TranslatorRegionHelp; TranslatorRegionHelp)
                {
                    ApplicationArea = All;
                    Caption = 'API Region';
                    Editable = false;
                }
            }
            group(ClaudeHelp)
            {
                Caption = 'Claude quick setup';
                Visible = Rec."AI Provider" = Rec."AI Provider"::Claude;

                field(ClaudeEndpointHelp; ClaudeEndpointHelp)
                {
                    ApplicationArea = All;
                    Caption = 'Endpoint URL';
                    Editable = false;
                }
                field(ClaudeModelHelp; ClaudeModelHelp)
                {
                    ApplicationArea = All;
                    Caption = 'Model example';
                    Editable = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec."AI Provider" := Rec."AI Provider"::"Azure Translator";
            Rec."Endpoint URL" := 'https://api.cognitive.microsofttranslator.com';
            Rec."API Region" := 'eastasia';
            Rec.Insert();
        end;

        TranslatorEndpointHelp := 'https://api.cognitive.microsofttranslator.com';
        TranslatorRegionHelp := 'eastasia';
        ClaudeEndpointHelp := 'https://api.anthropic.com/v1/messages';
        ClaudeModelHelp := 'claude-sonnet-4-20250514';
    end;

    var
        TranslatorEndpointHelp: Text[100];
        TranslatorRegionHelp: Text[50];
        ClaudeEndpointHelp: Text[100];
        ClaudeModelHelp: Text[100];
}
