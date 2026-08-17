page 50108 "PIM Item Locale Related Fields"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "PIM Item Locale Field";
    Caption = 'Extended Details (Locale)';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(RelatedFields)
            {
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    Caption = 'Field';
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    Caption = 'Translated Value';
                    MultiLine = true;
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        ApplyFilters();
    end;

    procedure RefreshForActiveLocale()
    begin
        ApplyFilters();
        CurrPage.Update(false);
    end;

    local procedure ApplyFilters()
    var
        PIMLocaleSession: Codeunit "PIM Locale Session";
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Locale Code", PIMLocaleSession.GetActiveLocale());
        Rec.SetFilter("Table No.", '<>%1&<>%2', Database::Item, Database::"Extended Text Line");
        Rec.FilterGroup(0);
    end;
}
