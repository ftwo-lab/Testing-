table 50121 "PIM Product Family"
{
    Caption = 'PIM Product Family';
    DataClassification = CustomerContent;
    LookupPageId = "PIM Product Families";
    DrillDownPageId = "PIM Product Families";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(3; "Family Group Code"; Code[20])
        {
            Caption = 'Main Product Family';
            TableRelation = "PIM Product Family Group";
        }
        field(4; "Family Group Name"; Text[100])
        {
            Caption = 'Main Product Family Name';
            FieldClass = FlowField;
            CalcFormula = lookup("PIM Product Family Group".Name where(Code = field("Family Group Code")));
            Editable = false;
        }
        field(5; Classification; Text[50])
        {
            Caption = 'Classification';
            ToolTip = 'Packaging or product class for this family, e.g. Glass Bottle, PET, Can.';
        }
        field(6; "Variant Dimension"; Text[50])
        {
            Caption = 'Variant Dimension';
            ToolTip = 'The attribute that distinguishes variants from the default item, e.g. Gebinde Volumen, Color.';
        }
        field(7; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(8; "Primary Default Item No."; Code[20])
        {
            Caption = 'Primary Default Item No.';
            TableRelation = Item;
        }
        field(9; "Primary Default Item Name"; Text[100])
        {
            Caption = 'Primary Default Item';
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("Primary Default Item No.")));
            Editable = false;
        }
        field(10; "Member Count"; Integer)
        {
            Caption = 'Members';
            FieldClass = FlowField;
            CalcFormula = count("PIM Product Family Member" where("Product Family Code" = field(Code)));
            Editable = false;
        }
        field(11; "Default Item Count"; Integer)
        {
            Caption = 'Default Items';
            FieldClass = FlowField;
            CalcFormula = count("PIM Product Family Member" where("Product Family Code" = field(Code), Role = const("Default Item")));
            Editable = false;
        }
        field(12; "Variant Count"; Integer)
        {
            Caption = 'Variants';
            FieldClass = FlowField;
            CalcFormula = count("PIM Product Family Member" where("Product Family Code" = field(Code), Role = const(Variant)));
            Editable = false;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
        key(Group; "Family Group Code") { }
    }

    trigger OnDelete()
    var
        PIMProductFamilyMember: Record "PIM Product Family Member";
        Item: Record Item;
        PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
    begin
        PIMProductFamilyMember.SetRange("Product Family Code", Rec.Code);
        if PIMProductFamilyMember.FindSet() then
            repeat
                if PIMProductFamilyMember."Variant Code" = '' then
                    if Item.Get(PIMProductFamilyMember."Item No.") then
                        PIMProductFamilyMgt.ClearItemFamilyFields(Item);
            until PIMProductFamilyMember.Next() = 0;

        PIMProductFamilyMember.DeleteAll();
    end;
}
