page 50642 "PIM Sync Log"
{
    Caption = 'PIM Sync Log';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    AdditionalSearchTerms = 'PIM, sync log';
    SourceTable = "PIM Sync Log";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Created at"; Rec."Created at") { ApplicationArea = All; }
                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field("Marketplace Code"; Rec."Marketplace Code") { ApplicationArea = All; }
                field("Company Name"; Rec."Company Name") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field(Message; Rec.Message) { ApplicationArea = All; }
            }
        }
    }
}
