pageextension 50100 "PIM Item Card Locales" extends "Item Card"
{
    layout
    {
        addlast(Content)
        {
            group(PIMLocaleContent)
            {
                Caption = 'Locale Content';
                Visible = LocaleFieldsVisible;

                field(LocaleDescription; LocaleDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Description for the active locale.';

                    trigger OnValidate()
                    begin
                        SaveLocaleField();
                    end;
                }
                field(LocaleDescription2; LocaleDescription2)
                {
                    ApplicationArea = All;
                    Caption = 'Description 2';
                    ToolTip = 'Description 2 for the active locale.';

                    trigger OnValidate()
                    begin
                        SaveLocaleField();
                    end;
                }
                field(LocaleExtendedDescription; LocaleExtendedDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Extended Description';
                    MultiLine = true;
                    ToolTip = 'Extended description for the active locale.';

                    trigger OnValidate()
                    begin
                        SaveLocaleField();
                    end;
                }
                field(LocaleMarketingText; LocaleMarketingText)
                {
                    ApplicationArea = All;
                    Caption = 'Marketing Text';
                    MultiLine = true;
                    ToolTip = 'Marketing text for the active locale.';

                    trigger OnValidate()
                    begin
                        SaveLocaleField();
                    end;
                }
                field(ActiveLocaleName; ActiveLocaleName)
                {
                    ApplicationArea = All;
                    Caption = 'Active Locale';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                }
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
        addlast(Processing)
        {
            group(PIMLocales)
            {
                Caption = 'Locales';
                Image = Language;

                action(LocaleEnglish)
                {
                    ApplicationArea = All;
                    Caption = 'English';
                    Image = Language;
                    ToolTip = 'Switch to English locale content.';

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
                    ToolTip = 'Switch to Germany locale content.';

                    trigger OnAction()
                    begin
                        SwitchLocale('DE');
                    end;
                }
                action(LocaleSwiss)
                {
                    ApplicationArea = All;
                    Caption = 'Swiss German';
                    Image = Language;
                    ToolTip = 'Switch to Swiss German locale content.';

                    trigger OnAction()
                    begin
                        SwitchLocale('CH');
                    end;
                }
                action(TranslateCurrentLocale)
                {
                    ApplicationArea = All;
                    Caption = 'Translate Current Locale with AI';
                    Image = Translate;
                    ToolTip = 'Translate item content from the source locale to the active locale using AI.';

                    trigger OnAction()
                    var
                        PIMAITranslator: Codeunit "PIM AI Translator";
                        PIMLocaleSession: Codeunit "PIM Locale Session";
                    begin
                        PIMAITranslator.TranslateItemToLocale(Rec."No.", PIMLocaleSession.GetActiveLocale(), false);
                        LoadLocaleFields();
                        CurrPage.Update(false);
                    end;
                }
                action(OpenLocaleContent)
                {
                    ApplicationArea = All;
                    Caption = 'Open Locale Content';
                    Image = EditLines;
                    ToolTip = 'Open the locale content card for the active locale.';

                    trigger OnAction()
                    var
                        PIMItemLocaleData: Record "PIM Item Locale Data";
                        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
                        PIMLocaleSession: Codeunit "PIM Locale Session";
                        PIMItemLocaleCard: Page "PIM Item Locale Card";
                    begin
                        PIMLocaleMgt.GetItemLocaleData(Rec."No.", PIMLocaleSession.GetActiveLocale(), PIMItemLocaleData);
                        PIMItemLocaleCard.SetRecord(PIMItemLocaleData);
                        PIMItemLocaleCard.RunModal();
                        LoadLocaleFields();
                        CurrPage.Update(false);
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
        ActiveLocaleName: Text[50];
        LocaleFieldsVisible: Boolean;

    local procedure SwitchLocale(LocaleCode: Code[10])
    var
        PIMLocaleSession: Codeunit "PIM Locale Session";
    begin
        PIMLocaleSession.SetActiveLocale(LocaleCode);
        LoadLocaleFields();
        CurrPage.Update(false);
    end;

    local procedure LoadLocaleFields()
    var
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
        PIMLocaleSession: Codeunit "PIM Locale Session";
        ActiveLocaleCode: Code[10];
    begin
        ActiveLocaleCode := PIMLocaleSession.GetActiveLocale();
        ActiveLocaleName := PIMLocaleMgt.GetLocaleName(ActiveLocaleCode);
        LocaleFieldsVisible := ActiveLocaleCode <> '';

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
