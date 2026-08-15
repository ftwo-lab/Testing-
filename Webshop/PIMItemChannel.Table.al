table 50609 "PIM Item Channel"
{
    Caption = 'PIM Item Channel';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            NotBlank = true;
        }
        field(2; "Channel Code"; Code[20])
        {
            Caption = 'Channel';
            TableRelation = "PIM Channel";
            NotBlank = true;

            trigger OnValidate()
            begin
                CalcFields("Channel Name", "Show in Webshop", "Channel Type");
            end;
        }
        field(3; Enabled; Boolean)
        {
            Caption = 'Enabled on channel';
            ToolTip = 'Product is published on this PIM channel (Akeneo-style).';

            trigger OnValidate()
            var
                PIMEnrichment: Codeunit "PIM Enrichment";
            begin
                PIMEnrichment.OnItemChannelChanged(Rec);
            end;
        }
        field(4; "Channel Name"; Text[100])
        {
            Caption = 'Channel';
            FieldClass = FlowField;
            CalcFormula = lookup("PIM Channel".Description where("Code" = field("Channel Code")));
            Editable = false;
        }
        field(5; "Show in Webshop"; Boolean)
        {
            Caption = 'Webshop';
            FieldClass = FlowField;
            CalcFormula = lookup("PIM Channel"."Show in Webshop" where("Code" = field("Channel Code")));
            Editable = false;
        }
        field(6; "Channel Type"; Text[30])
        {
            Caption = 'Type';
            FieldClass = FlowField;
            CalcFormula = lookup("PIM Channel"."Channel Type" where("Code" = field("Channel Code")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Item No.", "Channel Code")
        {
            Clustered = true;
        }
    }
}
