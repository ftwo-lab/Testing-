page 50109 "PIM Item Locale Overview"
{
    PageType = Worksheet;
    ApplicationArea = All;
    SourceTable = "PIM Item Locale Field";
    Caption = 'All Translated Item Data';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(AllFields)
            {
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
                field("Locale Code"; Rec."Locale Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        PIMLocaleSession: Codeunit "PIM Locale Session";
    begin
        Rec.SetRange("Locale Code", PIMLocaleSession.GetActiveLocale());
    end;

    procedure SetItemNo(ItemNo: Code[20])
    begin
        Rec.SetRange("Item No.", ItemNo);
    end;
}
