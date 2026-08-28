table 50120 "PIM Product Family Group"
{
    Caption = 'PIM Product Family Group';
    DataClassification = CustomerContent;
    LookupPageId = "PIM Product Family Groups";
    DrillDownPageId = "PIM Product Family Groups";

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
        field(3; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(10; "Family Count"; Integer)
        {
            Caption = 'Product Families';
            FieldClass = FlowField;
            CalcFormula = count("PIM Product Family" where("Family Group Code" = field(Code)));
            Editable = false;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        PIMProductFamily: Record "PIM Product Family";
    begin
        PIMProductFamily.SetRange("Family Group Code", Rec.Code);
        if not PIMProductFamily.IsEmpty() then
            Error('Remove or reassign product families in group %1 before deleting it.', Rec.Code);
    end;
}
