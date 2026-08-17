page 50107 "PIM Item Locale Attributes"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "PIM Item Locale Attribute";
    Caption = 'Item Attributes (Locale)';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Attributes)
            {
                field("Attribute Name"; Rec."Attribute Name")
                {
                    ApplicationArea = All;
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                }
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
