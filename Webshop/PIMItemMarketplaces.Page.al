page 50641 "PIM Item Marketplaces"
{
    Caption = 'Sync to companies';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "PIM Item Marketplace";
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Marketplace Code"; Rec."Marketplace Code")
                {
                    ApplicationArea = All;
                }
                field("Marketplace Name"; Rec."Marketplace Name")
                {
                    ApplicationArea = All;
                }
                field("Sync Enabled"; Rec."Sync Enabled")
                {
                    ApplicationArea = All;
                }
                field("Last Sync at"; Rec."Last Sync at")
                {
                    ApplicationArea = All;
                }
                field("Last Sync Status"; Rec."Last Sync Status")
                {
                    ApplicationArea = All;
                }
                field("Last Error"; Rec."Last Error")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
