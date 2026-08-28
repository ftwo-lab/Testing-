page 50129 "PIM Family Shared ListPart"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "PIM Family Shared Content";
    Caption = 'Shared SharePoint documents and notes';
    DelayedInsert = true;

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
                        HyperLink(Rec."SharePoint URL")
                    else
                        Message('Enter a SharePoint URL first.');
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if Rec."Product Family Code" <> '' then
            Rec.Scope := Rec.Scope::"Product Family"
        else
            Rec.Scope := Rec.Scope::"Main Product Family";
    end;
}
