page 50110 "PIM Table Field List"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = Field;
    Caption = 'Table Fields';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Fields)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'Field No.';
                    ToolTip = 'Use this number in PIM Locale Table Setup.';
                }
                field(FieldName; Rec.FieldName)
                {
                    ApplicationArea = All;
                    Caption = 'Field Name';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field(Len; Rec.Len)
                {
                    ApplicationArea = All;
                    Caption = 'Length';
                }
                field(Class; Rec.Class)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
