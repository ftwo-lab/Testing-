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
                ToolTip = 'Select a language. All text fields on this item page are translated and shown here.';
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
                    ToolTip = 'Translate all item text fields to German and show them on this page.';

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
                    ToolTip = 'Translate all item text fields to Swiss German and show them on this page.';

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
        ActiveLocaleCode := PIMLocaleSession.GetActiveLocale();
        SourceLocaleActive := ActiveLocaleCode = PIMLocaleMgt.GetSourceLocaleCode();
    end;

    trigger OnAfterGetCurrRecord()
    var
        Item: Record Item;
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
    begin
        if SourceLocaleActive then
            exit;

        Item := Rec;
        PIMLocaleMgt.ApplyLocaleFieldsToItem(Item, ActiveLocaleCode);
        Rec := Item;
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

        Message('All text fields translated to %1 and shown on this page.', PIMLocaleMgt.GetLocaleName(LocaleCode));
    end;
}
