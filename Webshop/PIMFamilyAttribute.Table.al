table 50604 "PIM Family Attribute"
{
    Caption = 'PIM Family Attribute';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Family Code"; Code[20])
        {
            Caption = 'Family Code';
            TableRelation = "PIM Family";
            NotBlank = true;
        }
        field(2; "Attribute Code"; Code[20])
        {
            Caption = 'Attribute Code';
            TableRelation = "PIM Attribute";
            NotBlank = true;
        }
        field(3; Required; Boolean)
        {
            Caption = 'Required';
        }
        field(4; "Attribute Caption"; Text[100])
        {
            Caption = 'Caption';
            FieldClass = FlowField;
            CalcFormula = lookup("PIM Attribute".Caption where("Code" = field("Attribute Code")));
            Editable = false;
        }
        field(5; "Group Code"; Code[20])
        {
            Caption = 'Group';
            FieldClass = FlowField;
            CalcFormula = lookup("PIM Attribute"."Group Code" where("Code" = field("Attribute Code")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Family Code", "Attribute Code")
        {
            Clustered = true;
        }
    }
}
