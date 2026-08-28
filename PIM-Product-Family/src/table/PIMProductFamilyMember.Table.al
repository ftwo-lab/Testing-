table 50122 "PIM Product Family Member"
{
    Caption = 'PIM Product Family Member';
    DataClassification = CustomerContent;
    DrillDownPageId = "PIM Product Family Members";
    LookupPageId = "PIM Product Family Members";

    fields
    {
        field(1; "Product Family Code"; Code[20])
        {
            Caption = 'Product Family Code';
            TableRelation = "PIM Product Family";
            NotBlank = true;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            NotBlank = true;

            trigger OnValidate()
            begin
                CalcFields(Description, "Base Unit of Measure", "VAT Prod. Posting Group", "Variant Description");
            end;
        }
        field(10; "Variant Code"; Code[10])
        {
            Caption = 'Item Variant';
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
            ToolTip = 'Blank = the default item itself. Filled = a native Business Central Item Variant under that item.';
        }
        field(11; "Is Native Variant"; Boolean)
        {
            Caption = 'Native Item Variant';
            Editable = false;
        }
        field(3; Role; Enum "PIM Family Member Role")
        {
            Caption = 'Role';
            InitValue = "Default Item";
        }
        field(4; "Parent Item No."; Code[20])
        {
            Caption = 'Parent / Default Item No.';
            TableRelation = Item where("PIM Product Family Code" = field("Product Family Code"), "PIM Family Role" = const("Default Item"));
        }
        field(5; "Variant Label"; Text[10])
        {
            Caption = 'Label';
            ToolTip = 'Parent, V1, V2, … as shown in the family hierarchy.';
        }
        field(6; "Variant Dim. Value"; Text[50])
        {
            Caption = 'Variant Dimension Value';
            ToolTip = 'Value of the family variant dimension for this item, e.g. 0.5L, Pink, 1L.';
        }
        field(7; "Display Order"; Integer)
        {
            Caption = 'Display Order';
        }
        field(8; Indentation; Integer)
        {
            Caption = 'Indentation';
        }
        field(9; "Is Primary Default"; Boolean)
        {
            Caption = 'Primary Default Item';
            ToolTip = 'Marks the main product (Produkt Main) for this family.';
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("Item No.")));
            Editable = false;
        }
        field(21; "Base Unit of Measure"; Code[10])
        {
            Caption = 'UOM';
            FieldClass = FlowField;
            CalcFormula = lookup(Item."Base Unit of Measure" where("No." = field("Item No.")));
            Editable = false;
        }
        field(22; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT';
            FieldClass = FlowField;
            CalcFormula = lookup(Item."VAT Prod. Posting Group" where("No." = field("Item No.")));
            Editable = false;
        }
        field(23; "Family Group Code"; Code[20])
        {
            Caption = 'Main Product Family';
            FieldClass = FlowField;
            CalcFormula = lookup("PIM Product Family"."Family Group Code" where(Code = field("Product Family Code")));
            Editable = false;
        }
        field(24; Classification; Text[50])
        {
            Caption = 'Classification';
            FieldClass = FlowField;
            CalcFormula = lookup("PIM Product Family".Classification where(Code = field("Product Family Code")));
            Editable = false;
        }
        field(25; "Variant Dimension"; Text[50])
        {
            Caption = 'Variant Dimension';
            FieldClass = FlowField;
            CalcFormula = lookup("PIM Product Family"."Variant Dimension" where(Code = field("Product Family Code")));
            Editable = false;
        }
        field(26; "Variant Description"; Text[100])
        {
            Caption = 'Variant Description';
            FieldClass = FlowField;
            CalcFormula = lookup("Item Variant".Description where("Item No." = field("Item No."), Code = field("Variant Code")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Product Family Code", "Item No.", "Variant Code")
        {
            Clustered = true;
        }
        key(Parent; "Product Family Code", "Parent Item No.", "Display Order") { }
        key(Display; "Product Family Code", "Display Order") { }
        key(Item; "Item No.", "Variant Code") { }
    }

    trigger OnInsert()
    var
        PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
    begin
        PIMProductFamilyMgt.PrepareMemberOnInsert(Rec);
    end;

    trigger OnModify()
    var
        PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
    begin
        PIMProductFamilyMgt.PrepareMemberOnModify(Rec);
    end;

    trigger OnDelete()
    var
        ChildMember: Record "PIM Product Family Member";
        Item: Record Item;
        PIMProductFamilyMgt: Codeunit "PIM Product Family Mgt.";
    begin
        ChildMember.SetRange("Product Family Code", Rec."Product Family Code");
        ChildMember.SetRange("Parent Item No.", Rec."Item No.");
        ChildMember.SetRange(Role, ChildMember.Role::Variant);
        if (Rec."Variant Code" = '') and (not ChildMember.IsEmpty()) then
            Error('Item %1 is a default item with variants. Reassign or remove the variants first.', Rec."Item No.");

        if (Rec."Variant Code" = '') and Item.Get(Rec."Item No.") then
            PIMProductFamilyMgt.ClearItemFamilyFields(Item);
    end;
}
