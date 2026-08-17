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

                field(ActiveLocaleName; ActiveLocaleName)
                {
                    ApplicationArea = All;
                    Caption = 'Active Locale';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                }
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
                ToolTip = 'Switch language and translate item content.';
                Image = Language;

                action(LocaleEnglish)
                {
                    ApplicationArea = All;
                    Caption = 'English';
                    Image = Language;
                    ToolTip = 'Show English source content.';

                    trigger OnAction()
                    begin
                        SwitchLocale('EN');
                        Message('Active locale: English');
                    end;
                }
                action(LocaleGermany)
                {
                    ApplicationArea = All;
                    Caption = 'Germany';
                    Image = Language;
                    ToolTip = 'Switch to German and translate all item content.';

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
                    ToolTip = 'Switch to Swiss German and translate all item content.';

                    trigger OnAction()
                    begin
                        SwitchLocaleAndTranslate('CH');
                    end;
                }
                action(OpenLocaleContent)
                {
                    ApplicationArea = All;
                    Caption = 'Edit Locale Content';
                    Image = EditLines;
                    ToolTip = 'Open the locale content card for manual edits.';

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

    local procedure SwitchLocaleAndTranslate(LocaleCode: Code[10])
    var
        PIMAITranslator: Codeunit "PIM AI Translator";
    begin
        PIMAITranslator.ApplyLocaleAndTranslate(Rec."No.", LocaleCode);
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
