page 50621 "PIM Item Channels"
{
    Caption = 'Channels';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "PIM Item Channel";
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;
                }
                field("Channel Name"; Rec."Channel Name")
                {
                    ApplicationArea = All;
                }
                field("Channel Type"; Rec."Channel Type")
                {
                    ApplicationArea = All;
                }
                field("Show in Webshop"; Rec."Show in Webshop")
                {
                    ApplicationArea = All;
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
