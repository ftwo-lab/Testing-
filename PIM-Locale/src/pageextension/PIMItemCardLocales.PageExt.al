pageextension 50100 "PIM Item Card Locales" extends "Item Card"
{
    layout
    {
        modify(Description)
        {
            Visible = SourceLocaleActive;
        }
        modify("Description 2")
        {
            Visible = SourceLocaleActive;
        }
        addafter(Description)
        {
            field(LocaleDescription; LocaleDescription)
            {
                ApplicationArea = All;
                Caption = 'Description';
                ToolTip = 'Translated description for the selected locale.';
                Visible = not SourceLocaleActive;

                trigger OnValidate()
                begin
                    SaveLocaleField();
                end;
            }
        }
        addafter("Description 2")
        {
            field(LocaleDescription2; LocaleDescription2)
            {
                ApplicationArea = All;
                Caption = 'Description 2';
                ToolTip = 'Translated description 2 for the selected locale.';
                Visible = not SourceLocaleActive;

                trigger OnValidate()
                begin
                    SaveLocaleField();
                end;
            }
        }
        addfirst(factboxes)
        {
            part(PIMLocaleStatus; "PIM Item Locale Status")
            {
                ApplicationArea = All;
                SubPageLink = "Item No." = field("No.");
            }
        }
    }

    actions
    {
        addfirst(Processing)
        {
            group(PIMLocales)
            {
                Caption = 'Locales';
                ToolTip = 'Select a language. Item text is translated and shown on this page.';
                Image = Language;

                action(LocaleEnglish)
                {
                    ApplicationArea = All;
                    Caption = 'English';
                    Image = Language;
                    ToolTip = 'Show original English item text.';

                    trigger OnAction()
                    begin
                        SwitchLocale('EN');
                    end;
                }
                action(LocaleGermany)
                {
                    ApplicationArea = All;
                    Caption = 'Germany';
                    Image = Language;
                    ToolTip = 'Translate and show German text on this item page.';

                    trigger OnAction()
                    begin
                        SwitchLocaleAndTranslate('DE');
                    end;
                }
                action(LocaleSwiss)
                {
                    ApplicationArea = All;
                    Caption = 'Swiss German';
                    Image = Language;
                    ToolTip = 'Translate and show Swiss German text on this item page.';

                    trigger OnAction()
                    begin
                        SwitchLocaleAndTranslate('CH');
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
        PIMLocaleSession: Codeunit "PIM Locale Session";
    begin
        PIMLocaleMgt.EnsureDefaultLocales();
        PIMLocaleSession.ResetToSourceLocale();
        LoadLocaleFields();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        LoadLocaleFields();
    end;

    var
        LocaleDescription: Text[100];
        LocaleDescription2: Text[50];
        LocaleExtendedDescription: Text[2048];
        LocaleMarketingText: Text[2048];
        SourceLocaleActive: Boolean;

    local procedure SwitchLocale(LocaleCode: Code[10])
    var
        PIMLocaleSession: Codeunit "PIM Locale Session";
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
    begin
        PIMLocaleSession.SetActiveLocale(LocaleCode);
        LoadLocaleFields();
        CurrPage.Update(false);
        Message('Showing locale: %1', PIMLocaleMgt.GetLocaleName(LocaleCode));
    end;

    local procedure SwitchLocaleAndTranslate(LocaleCode: Code[10])
    var
        PIMAITranslator: Codeunit "PIM AI Translator";
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
    begin
        PIMAITranslator.ApplyLocaleAndTranslate(Rec."No.", LocaleCode);
        LoadLocaleFields();
        CurrPage.Update(false);
        Message('Translated to %1. Text is shown on this item page.', PIMLocaleMgt.GetLocaleName(LocaleCode));
    end;

    local procedure LoadLocaleFields()
    var
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
        PIMLocaleSession: Codeunit "PIM Locale Session";
        ActiveLocaleCode: Code[10];
        SourceLocaleCode: Code[10];
    begin
        ActiveLocaleCode := PIMLocaleSession.GetActiveLocale();
        SourceLocaleCode := PIMLocaleMgt.GetSourceLocaleCode();
        SourceLocaleActive := (ActiveLocaleCode = SourceLocaleCode) or (SourceLocaleCode = '');

        PIMLocaleMgt.LoadItemTextsForLocale(
            Rec."No.", ActiveLocaleCode,
            LocaleDescription, LocaleDescription2, LocaleExtendedDescription, LocaleMarketingText);
    end;

    local procedure SaveLocaleField()
    var
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
        PIMLocaleSession: Codeunit "PIM Locale Session";
    begin
        PIMLocaleMgt.SaveItemTextsForLocale(
            Rec."No.", PIMLocaleSession.GetActiveLocale(),
            LocaleDescription, LocaleDescription2, LocaleExtendedDescription, LocaleMarketingText);
    end;
}
