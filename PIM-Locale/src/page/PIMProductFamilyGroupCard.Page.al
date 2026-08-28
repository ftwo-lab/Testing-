page 50121 "PIM Product Family Group Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "PIM Product Family Group";
    Caption = 'Main Product Family';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
                field("Family Count"; Rec."Family Count")
                {
                    ApplicationArea = All;
                }
            }
            part(Families; "PIM Families ListPart")
            {
                ApplicationArea = All;
                SubPageLink = "Family Group Code" = field(Code);
            }
        }
    }
}
