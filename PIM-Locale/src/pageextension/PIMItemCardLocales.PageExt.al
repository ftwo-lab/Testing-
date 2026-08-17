pageextension 50100 "PIM Item Card Locales" extends "Item Card"
{
    layout
    {
        addfirst(factboxes)
        {
            part(PIMLocaleStatus; "PIM Item Locale Status")
            {
                ApplicationArea = All;
                SubPageLink = "Item No." = field("No.");
            }
            part(PIMLocaleAttributes; "PIM Item Locale Attributes")
            {
                ApplicationArea = All;
                Caption = 'Item Attributes (Locale)';
                SubPageLink = "Item No." = field("No.");
                Visible = not SourceLocaleActive;
            }
            part(PIMLocaleFields; "PIM Item Locale Fields")
            {
                ApplicationArea = All;
                SubPageLink = "Item No." = field("No.");
                Visible = not SourceLocaleActive;
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
                ToolTip = 'Select a language. Item fields, marketing text, attributes, and extended details are translated in their own pages.';
                Image = Language;

                action(LocaleEnglish)
                {
                    ApplicationArea = All;
                    Caption = 'English';
                    Image = Language;
                    ToolTip = 'Show original English values on all item fields.';

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
                    ToolTip = 'Translate all item data to German. Open Extended Details and Marketing Text to view it there.';

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
                    ToolTip = 'Translate all item data to Swiss German. Open Extended Details and Marketing Text to view it there.';

                    trigger OnAction()
                    begin
                        SwitchLocaleAndTranslate('CH');
                    end;
                }
                action(ViewAllTranslatedData)
                {
                    ApplicationArea = All;
                    Caption = 'View All Translated Data';
                    Image = ViewDetails;
                    ToolTip = 'Open a list of every translated field for the active locale.';

                    trigger OnAction()
                    var
                        PIMItemLocaleField: Record "PIM Item Locale Field";
                        PIMItemLocaleOverview: Page "PIM Item Locale Overview";
                        PIMLocaleSession: Codeunit "PIM Locale Session";
                    begin
                        PIMItemLocaleField.SetRange("Item No.", Rec."No.");
                        PIMItemLocaleField.SetRange("Locale Code", PIMLocaleSession.GetActiveLocale());
                        PIMItemLocaleOverview.SetTableView(PIMItemLocaleField);
                        PIMItemLocaleOverview.RunModal();
                    end;
                }
                action(OpenLocaleTableSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Configure Extended Details Tables';
                    Image = Setup;
                    ToolTip = 'Register custom tables such as Extended Details so their fields are included in translation.';

                    trigger OnAction()
                    begin
                        Page.Run(Page::"PIM Locale Table Setup");
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
        PIMLocaleMgt.EnsureExtendedDetailTableSetup();
        PIMLocaleSession.ResetToSourceLocale();
        ActiveLocaleCode := PIMLocaleSession.GetActiveLocale();
        SourceLocaleActive := ActiveLocaleCode = PIMLocaleMgt.GetSourceLocaleCode();
    end;

    trigger OnAfterGetCurrRecord()
    var
        Item: Record Item;
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
        PIMLocaleSession: Codeunit "PIM Locale Session";
    begin
        PIMLocaleSession.SetCurrentItemNo(Rec."No.");

        if SourceLocaleActive then
            exit;

        Item := Rec;
        PIMLocaleMgt.ApplyLocaleFieldsToItem(Item, ActiveLocaleCode);
        Rec := Item;
        UpdateLocaleFactboxes();
    end;

    trigger OnModifyRecord(): Boolean
    var
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
    begin
        if SourceLocaleActive then
            exit(true);

        PIMLocaleMgt.SaveItemLocaleFieldsFromItem(Rec, ActiveLocaleCode);
        exit(false);
    end;

    var
        ActiveLocaleCode: Code[10];
        SourceLocaleActive: Boolean;

    local procedure SwitchLocale(LocaleCode: Code[10])
    var
        Item: Record Item;
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
        PIMLocaleSession: Codeunit "PIM Locale Session";
    begin
        PIMLocaleSession.SetActiveLocale(LocaleCode);
        ActiveLocaleCode := LocaleCode;
        SourceLocaleActive := ActiveLocaleCode = PIMLocaleMgt.GetSourceLocaleCode();

        if Item.Get(Rec."No.") then begin
            Rec := Item;
            CurrPage.Update(false);
        end;

        UpdateLocaleFactboxes();
        Message('Showing locale: %1', PIMLocaleMgt.GetLocaleName(LocaleCode));
    end;

    local procedure SwitchLocaleAndTranslate(LocaleCode: Code[10])
    var
        PIMAITranslator: Codeunit "PIM AI Translator";
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
        PIMLocaleSession: Codeunit "PIM Locale Session";
        Item: Record Item;
    begin
        PIMAITranslator.ApplyLocaleAndTranslate(Rec."No.", LocaleCode);

        PIMLocaleSession.SetActiveLocale(LocaleCode);
        ActiveLocaleCode := LocaleCode;
        SourceLocaleActive := false;

        if Item.Get(Rec."No.") then begin
            PIMLocaleMgt.ApplyLocaleFieldsToItem(Item, ActiveLocaleCode);
            Rec := Item;
            CurrPage.Update(false);
        end;

        UpdateLocaleFactboxes();
        Message(
          'Translated to %1. Open Extended Details and Marketing Text to see translated content there.',
          PIMLocaleMgt.GetLocaleName(LocaleCode));
    end;

    local procedure UpdateLocaleFactboxes()
    begin
        if SourceLocaleActive then
            exit;

        CurrPage.PIMLocaleAttributes.Page.RefreshForActiveLocale();
        CurrPage.PIMLocaleFields.Page.RefreshForActiveLocale();
    end;
}
