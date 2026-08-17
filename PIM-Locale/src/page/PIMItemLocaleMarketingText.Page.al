page 50106 "PIM Item Locale Marketing Text"
{
    PageType = CardPart;
    ApplicationArea = All;
    SourceTable = "PIM Item Locale Data";
    Caption = 'Marketing Text (Locale)';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            field("Marketing Text"; Rec."Marketing Text")
            {
                ApplicationArea = All;
                Caption = 'Marketing Text';
                MultiLine = true;
                ToolTip = 'Translated marketing text for the active locale.';
            }
            field("Extended Description"; Rec."Extended Description")
            {
                ApplicationArea = All;
                Caption = 'Extended Description';
                MultiLine = true;
                ToolTip = 'Translated extended description for the active locale.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        ApplyLocaleFilter();
    end;

    procedure RefreshForActiveLocale()
    begin
        ApplyLocaleFilter();
        CurrPage.Update(false);
    end;

    local procedure ApplyLocaleFilter()
    var
        PIMLocaleSession: Codeunit "PIM Locale Session";
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Locale Code", PIMLocaleSession.GetActiveLocale());
        Rec.FilterGroup(0);
    end;
}
