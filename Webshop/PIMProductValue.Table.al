table 50606 "PIM Product Value"
{
    Caption = 'PIM Product Value';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            NotBlank = true;
        }
        field(2; "Attribute Code"; Code[20])
        {
            Caption = 'Attribute';
            TableRelation = "PIM Attribute";
            NotBlank = true;

            trigger OnValidate()
            begin
                CalcFields("Attribute Caption", "Group Code", "Attribute Type");
            end;
        }
        field(3; Value; Text[2048])
        {
            Caption = 'Value';
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
        field(6; "Attribute Type"; Enum "PIM Attribute Type")
        {
            Caption = 'Type';
            FieldClass = FlowField;
            CalcFormula = lookup("PIM Attribute"."Type" where("Code" = field("Attribute Code")));
            Editable = false;
        }
        field(7; "Channel Code"; Code[20])
        {
            Caption = 'Channel';
            TableRelation = "PIM Channel";
            ToolTip = 'Blank = common value for all channels. DE, ES, AMAZON, SHOPIFY = value only for that channel.';
        }
        field(8; "Language Code"; Code[10])
        {
            Caption = 'Language';
            TableRelation = Language;
        }
    }

    keys
    {
        key(PK; "Item No.", "Attribute Code", "Channel Code", "Language Code")
        {
            Clustered = true;
        }
    }
}
