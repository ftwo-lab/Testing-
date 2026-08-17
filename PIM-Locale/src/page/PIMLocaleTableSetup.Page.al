page 50105 "PIM Locale Table Setup"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "PIM Locale Table Setup";
    Caption = 'PIM Locale Table Setup';
    InsertAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(SetupLines)
            {
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Custom table number, e.g. your Extended Details table.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Link Field No."; Rec."Link Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Field number on this table that stores the Item No.';
                }
                field("Translate All Fields"; Rec."Translate All Fields")
                {
                    ApplicationArea = All;
                }
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Used only when Translate All Fields is off.';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenFields)
            {
                ApplicationArea = All;
                Caption = 'Show Table Fields';
                Image = FilterLines;
                ToolTip = 'Open the Field list for the selected table to find field numbers.';

                trigger OnAction()
                var
                    Field: Record Field;
                begin
                    if Rec."Table No." = 0 then
                        Error('Select a table first.');

                    Field.SetRange(TableNo, Rec."Table No.");
                    Page.Run(Page::"Field List", Field);
                end;
            }
        }
    }
}
