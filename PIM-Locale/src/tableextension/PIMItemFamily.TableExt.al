tableextension 50120 "PIM Item Family" extends Item
{
    fields
    {
        field(50120; "PIM Product Family Code"; Code[20])
        {
            Caption = 'Product Family';
            TableRelation = "PIM Product Family";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
            begin
                PIMProductFamilyMgt.OnItemFamilyCodeValidate(Rec);
            end;
        }
        field(50121; "PIM Family Group Code"; Code[20])
        {
            Caption = 'Main Product Family';
            TableRelation = "PIM Product Family Group";
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50122; "PIM Family Role"; Enum "PIM Family Member Role")
        {
            Caption = 'Family Role';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
            begin
                PIMProductFamilyMgt.OnItemFamilyRoleValidate(Rec);
            end;
        }
        field(50123; "PIM Parent Item No."; Code[20])
        {
            Caption = 'Default Item No.';
            TableRelation = Item where("PIM Product Family Code" = field("PIM Product Family Code"), "PIM Family Role" = const("Default Item"));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
            begin
                PIMProductFamilyMgt.OnItemParentValidate(Rec);
            end;
        }
        field(50124; "PIM Variant Dim. Value"; Text[50])
        {
            Caption = 'Variant Dimension Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
            begin
                PIMProductFamilyMgt.SyncMemberFromItem(Rec);
            end;
        }
        field(50125; "PIM Classification"; Text[50])
        {
            Caption = 'Classification';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50126; "PIM Variant Dimension"; Text[50])
        {
            Caption = 'Variant Dimension';
            FieldClass = FlowField;
            CalcFormula = lookup("PIM Product Family"."Variant Dimension" where(Code = field("PIM Product Family Code")));
            Editable = false;
        }
        field(50127; "PIM Variant Label"; Text[10])
        {
            Caption = 'Family Label';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
