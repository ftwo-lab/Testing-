codeunit 50632 "PIM Enrichment"
{
    procedure EnsureFamilyAttributes(ItemNo: Code[20]; FamilyCode: Code[20])
    var
        FamilyAttribute: Record "PIM Family Attribute";
        ProductValue: Record "PIM Product Value";
    begin
        if (ItemNo = '') or (FamilyCode = '') then
            exit;

        FamilyAttribute.SetRange("Family Code", FamilyCode);
        if FamilyAttribute.FindSet() then
            repeat
                if not ProductValue.Get(ItemNo, FamilyAttribute."Attribute Code") then begin
                    ProductValue.Init();
                    ProductValue."Item No." := ItemNo;
                    ProductValue."Attribute Code" := FamilyAttribute."Attribute Code";
                    ProductValue.Insert();
                end;
            until FamilyAttribute.Next() = 0;
    end;

    procedure CompletenessPercent(ItemNo: Code[20]; FamilyCode: Code[20]): Decimal
    var
        FamilyAttribute: Record "PIM Family Attribute";
        ProductValue: Record "PIM Product Value";
        RequiredCount: Integer;
        FilledCount: Integer;
    begin
        if (ItemNo = '') or (FamilyCode = '') then
            exit(0);

        FamilyAttribute.SetRange("Family Code", FamilyCode);
        FamilyAttribute.SetRange(Required, true);
        if FamilyAttribute.FindSet() then
            repeat
                RequiredCount += 1;
                if ProductValue.Get(ItemNo, FamilyAttribute."Attribute Code") then
                    if DelChr(ProductValue.Value, '<>', ' ') <> '' then
                        FilledCount += 1;
            until FamilyAttribute.Next() = 0;

        if RequiredCount = 0 then
            exit(100);
        exit(Round(FilledCount / RequiredCount * 100, 1));
    end;

    procedure GetValue(ItemNo: Code[20]; AttributeCode: Code[20]): Text
    var
        ProductValue: Record "PIM Product Value";
    begin
        if ProductValue.Get(ItemNo, AttributeCode) then
            exit(ProductValue.Value);
        exit('');
    end;
}
