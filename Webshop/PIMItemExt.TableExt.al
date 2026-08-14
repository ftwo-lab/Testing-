tableextension 50607 "PIM Item Ext" extends Item
{
    fields
    {
        field(50600; "PIM Family Code"; Code[20])
        {
            Caption = 'PIM Family';
            TableRelation = "PIM Family";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PIMEnrichment: Codeunit "PIM Enrichment";
            begin
                PIMEnrichment.EnsureFamilyAttributes("No.", "PIM Family Code");
            end;
        }
        field(50601; "PIM Category Code"; Code[20])
        {
            Caption = 'PIM Category';
            TableRelation = "PIM Category";
            DataClassification = CustomerContent;
        }
        field(50602; "PIM Published"; Boolean)
        {
            Caption = 'Published to Webshop';
            DataClassification = CustomerContent;
        }
    }
}
