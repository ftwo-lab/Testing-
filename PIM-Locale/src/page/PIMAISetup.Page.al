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
                    ToolTip = 'Choose Azure OpenAI or Claude (Anthropic) for translations.';
                }
                field("Endpoint URL"; Rec."Endpoint URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Claude: https://api.anthropic.com/v1/messages. Azure: your full chat/completions URL.';
                }
                field("Deployment Name"; Rec."Deployment Name")
                {
                    ApplicationArea = All;
                    Caption = 'Model / Deployment Name';
                }
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Claude: Anthropic API key. Azure: KEY 1 from Azure OpenAI resource.';
                }
                field("System Prompt"; Rec."System Prompt")
                {
                    ApplicationArea = All;
                    MultiLine = true;
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
                    ToolTip = 'Use https://api.anthropic.com/v1/messages';
                }
                field(ClaudeModelHelp; ClaudeModelHelp)
                {
                    ApplicationArea = All;
                    Caption = 'Model example';
                    Editable = false;
                    ToolTip = 'Example model: claude-sonnet-4-20250514 or claude-3-5-haiku-latest';
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
            Rec."AI Provider" := Rec."AI Provider"::Claude;
            Rec."Endpoint URL" := 'https://api.anthropic.com/v1/messages';
            Rec."Deployment Name" := 'claude-sonnet-4-20250514';
            Rec.Insert();
        end;

        ClaudeEndpointHelp := 'https://api.anthropic.com/v1/messages';
        ClaudeModelHelp := 'claude-sonnet-4-20250514';
    end;

    var
        ClaudeEndpointHelp: Text[100];
        ClaudeModelHelp: Text[100];
}
