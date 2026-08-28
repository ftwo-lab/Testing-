page 50126 "PIM Item Family Factbox"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "PIM Product Family Member";
    Caption = 'Product Family';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
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
                    Style = Strong;
                    StyleExpr = IsCurrentItem;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Caption = 'Item Variant';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = IsDefaultItem;
                }
                field("Variant Dim. Value"; Rec."Variant Dim. Value")
                {
                    ApplicationArea = All;
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsDefaultItem := Rec.Role = Rec.Role::"Default Item";
        IsCurrentItem := Rec."Item No." = CurrentItemNo;
    end;

    var
        IsDefaultItem: Boolean;
        IsCurrentItem: Boolean;
        CurrentItemNo: Code[20];

    procedure SetCurrentItemNo(ItemNo: Code[20])
    begin
        CurrentItemNo := ItemNo;
    end;
}
