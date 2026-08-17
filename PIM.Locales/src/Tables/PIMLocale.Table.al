table 50100 "PIM Locale"
{
    Caption = 'PIM Locale';
    DataClassification = CustomerContent;
    LookupPageId = "PIM Locales";
    DrillDownPageId = "PIM Locales";

    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(3; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
        }
        field(4; "AI Locale Tag"; Text[20])
        {
            Caption = 'AI Locale Tag';
            ToolTip = 'Locale passed to the AI translator, e.g. de-DE, de-CH, en-GB.';
        }
        field(5; "Is Source Locale"; Boolean)
        {
            Caption = 'Is Source Locale';
            ToolTip = 'The source locale used as the basis for AI translation.';
        }
        field(6; "Display Order"; Integer)
        {
            Caption = 'Display Order';
        }
        field(7; Enabled; Boolean)
        {
            Caption = 'Enabled';
            InitValue = true;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if Rec."Is Source Locale" then
            ValidateSourceLocale();
    end;

    trigger OnModify()
    begin
        if Rec."Is Source Locale" then
            ValidateSourceLocale();
    end;

    local procedure ValidateSourceLocale()
    var
        PIMLocale: Record "PIM Locale";
    begin
        PIMLocale.SetRange("Is Source Locale", true);
        PIMLocale.SetFilter(Code, '<>%1', Rec.Code);
        if PIMLocale.FindFirst() then begin
            PIMLocale."Is Source Locale" := false;
            PIMLocale.Modify();
        end;
    end;
}
