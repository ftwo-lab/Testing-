page 50136 "PIM Item Shared Content"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "PIM Family Shared Content";
    Caption = 'Family shared documents / notes';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
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
                }
                field(Scope; Rec.Scope)
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
