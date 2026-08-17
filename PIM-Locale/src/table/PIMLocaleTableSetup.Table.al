table 50105 "PIM Locale Table Setup"
{
    Caption = 'PIM Locale Table Setup';
    DataClassification = CustomerContent;
    LookupPageId = "PIM Locale Table Setup";
    DrillDownPageId = "PIM Locale Table Setup";

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" where("Object Type" = const(Table));
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
        }
        field(3; "Table Name"; Text[30])
        {
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table),
                                                                        "Object ID" = field("Table No.")));
        }
        field(4; "Field Name"; Text[30])
        {
            Caption = 'Field Name';
            Editable = false;
        }
        field(5; "Link Field No."; Integer)
        {
            Caption = 'Link Field No.';
            ToolTip = 'Field on this table that links to Item No., e.g. Item No. field number.';
        }
        field(6; Enabled; Boolean)
        {
            Caption = 'Enabled';
            InitValue = true;
        }
        field(7; "Translate All Fields"; Boolean)
        {
            Caption = 'Translate All Fields';
            ToolTip = 'When enabled, every translatable text field on each related record is translated. When disabled, only the selected Field No. is translated.';
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Optional note, e.g. Extended Details table.';
        }
    }

    keys
    {
        key(PK; "Table No.", "Field No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        UpdateFieldName();
    end;

    trigger OnModify()
    begin
        UpdateFieldName();
    end;

    local procedure UpdateFieldName()
    var
        Field: Record Field;
    begin
        if Field.Get("Table No.", "Field No.") then
            "Field Name" := Field.FieldName;
    end;
}
