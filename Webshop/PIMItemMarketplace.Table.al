table 50637 "PIM Item Marketplace"
{
    Caption = 'PIM Item Marketplace';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            NotBlank = true;
        }
        field(2; "Marketplace Code"; Code[20])
        {
            Caption = 'Marketplace Code';
            TableRelation = "PIM Marketplace";
            NotBlank = true;
        }
        field(3; "Sync Enabled"; Boolean)
        {
            Caption = 'Sync to this company';
            InitValue = true;
        }
        field(4; "Last Sync at"; DateTime)
        {
            Caption = 'Last Sync at';
            Editable = false;
        }
        field(5; "Last Sync Status"; Text[50])
        {
            Caption = 'Last Sync Status';
            Editable = false;
        }
        field(6; "Last Error"; Text[250])
        {
            Caption = 'Last Error';
            Editable = false;
        }
        field(7; "Marketplace Name"; Text[100])
        {
            Caption = 'Marketplace';
            FieldClass = FlowField;
            CalcFormula = lookup("PIM Marketplace".Description where("Code" = field("Marketplace Code")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Item No.", "Marketplace Code")
        {
            Clustered = true;
        }
    }
}
