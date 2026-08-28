table 50123 "PIM Family Shared Content"
{
    Caption = 'PIM Family Shared Content';
    DataClassification = CustomerContent;
    DrillDownPageId = "PIM Family Shared Content";
    LookupPageId = "PIM Family Shared Content";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; Scope; Enum "PIM Shared Content Scope")
        {
            Caption = 'Share at';
        }
        field(3; "Family Group Code"; Code[20])
        {
            Caption = 'Main Product Family';
            TableRelation = "PIM Product Family Group";
        }
        field(4; "Product Family Code"; Code[20])
        {
            Caption = 'Product Family';
            TableRelation = "PIM Product Family";
        }
        field(5; "Content Type"; Enum "PIM Shared Content Type")
        {
            Caption = 'Type';
        }
        field(6; Title; Text[100])
        {
            Caption = 'Title';
        }
        field(7; "SharePoint URL"; Text[250])
        {
            Caption = 'SharePoint URL';
            ExtendedDatatype = URL;
        }
        field(8; Notes; Text[2048])
        {
            Caption = 'Note';
        }
        field(9; "Share with Default Items"; Boolean)
        {
            Caption = 'Show on default items';
            InitValue = true;
        }
        field(10; "Share with Variants"; Boolean)
        {
            Caption = 'Show on variants';
            InitValue = true;
        }
        field(11; "Document Kind"; Text[50])
        {
            Caption = 'Document kind';
            ToolTip = 'e.g. Datasheet, Certificate, SDS, Image.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Group; "Family Group Code", Scope) { }
        key(Family; "Product Family Code", Scope) { }
    }

    trigger OnInsert()
    var
        Family: Record "PIM Product Family";
    begin
        if Rec.Scope = Rec.Scope::"Product Family" then begin
            if Rec."Product Family Code" = '' then
                Error('Select a product family for family-level shared content.');
            if Family.Get(Rec."Product Family Code") then
                Rec."Family Group Code" := Family."Family Group Code";
        end else
            if Rec."Family Group Code" = '' then
                Error('Select a main product family for group-level shared content.');
    end;
}
