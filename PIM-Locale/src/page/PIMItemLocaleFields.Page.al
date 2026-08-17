page 50104 "PIM Item Locale Fields"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "PIM Item Locale Field";
    Caption = 'Translated Fields';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Fields)
            {
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                }
            }
        }
    trigger OnOpenPage()
    var
        PIMLocaleSession: Codeunit "PIM Locale Session";
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Locale Code", PIMLocaleSession.GetActiveLocale());
        Rec.FilterGroup(0);
    end;
}
