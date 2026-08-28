page 50124 "PIM Product Family Members"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "PIM Product Family Member";
    Caption = 'Product Family Members';
    SourceTableView = sorting("Product Family Code", "Display Order");

    layout
    {
        area(Content)
        {
            repeater(Members)
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = Description;

                field("Variant Label"; Rec."Variant Label")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = IsDefaultItem;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = IsDefaultItem;
                }
                field(Role; Rec.Role)
                {
                    ApplicationArea = All;
                }
                field("Parent Item No."; Rec."Parent Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Dim. Value"; Rec."Variant Dim. Value")
                {
                    ApplicationArea = All;
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Is Primary Default"; Rec."Is Primary Default")
                {
                    ApplicationArea = All;
                }
                field("Product Family Code"; Rec."Product Family Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsDefaultItem := Rec.Role = Rec.Role::"Default Item";
    end;

    var
        IsDefaultItem: Boolean;
}
