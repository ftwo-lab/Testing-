page 50135 "PIM Family Shared Content"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "PIM Family Shared Content";
    Caption = 'PIM Family Shared Content';

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Scope; Rec.Scope)
                {
                    ApplicationArea = All;
                }
                field("Family Group Code"; Rec."Family Group Code")
                {
                    ApplicationArea = All;
                }
                field("Product Family Code"; Rec."Product Family Code")
                {
                    ApplicationArea = All;
                }
                field("Content Type"; Rec."Content Type")
                {
                    ApplicationArea = All;
                }
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                }
                field("Document Kind"; Rec."Document Kind")
                {
                    ApplicationArea = All;
                }
                field("SharePoint URL"; Rec."SharePoint URL")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = URL;
                }
                field(Notes; Rec.Notes)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
                field("Share with Default Items"; Rec."Share with Default Items")
                {
                    ApplicationArea = All;
                }
                field("Share with Variants"; Rec."Share with Variants")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenUrl)
            {
                ApplicationArea = All;
                Caption = 'Open SharePoint';
                Image = Link;

                trigger OnAction()
                begin
                    if Rec."SharePoint URL" <> '' then
                        HyperLink(Rec."SharePoint URL");
                end;
            }
        }
    }
}
