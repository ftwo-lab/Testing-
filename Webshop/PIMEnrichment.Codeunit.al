codeunit 50632 "PIM Enrichment"
{
    procedure EnsureFamilyAttributes(ItemNo: Code[20]; FamilyCode: Code[20])
    var
        Item: Record Item;
        ChannelCode: Code[20];
    begin
        if Item.Get(ItemNo) then
            ChannelCode := Item."PIM Channel Code";
        EnsureFamilyAttributes(ItemNo, FamilyCode, ChannelCode);
    end;

    procedure EnsureFamilyAttributes(ItemNo: Code[20]; FamilyCode: Code[20]; ChannelCode: Code[20])
    var
        FamilyAttribute: Record "PIM Family Attribute";
        Attr: Record "PIM Attribute";
    begin
        if (ItemNo = '') or (FamilyCode = '') then
            exit;

        FamilyAttribute.SetRange("Family Code", FamilyCode);
        if FamilyAttribute.FindSet() then
            repeat
                EnsureValueRow(ItemNo, FamilyAttribute."Attribute Code", '');
                if Attr.Get(FamilyAttribute."Attribute Code") then
                    if Attr.Scopable and (ChannelCode <> '') then
                        EnsureValueRow(ItemNo, FamilyAttribute."Attribute Code", ChannelCode);
            until FamilyAttribute.Next() = 0;
    end;

    local procedure EnsureValueRow(ItemNo: Code[20]; AttributeCode: Code[20]; ChannelCode: Code[20])
    var
        ProductValue: Record "PIM Product Value";
    begin
        if ProductValue.Get(ItemNo, AttributeCode, ChannelCode, '') then
            exit;
        ProductValue.Init();
        ProductValue."Item No." := ItemNo;
        ProductValue."Attribute Code" := AttributeCode;
        ProductValue."Channel Code" := ChannelCode;
        ProductValue."Language Code" := '';
        ProductValue.Insert();
    end;

    procedure CompletenessPercent(ItemNo: Code[20]; FamilyCode: Code[20]): Decimal
    var
        Item: Record Item;
        ChannelCode: Code[20];
    begin
        if Item.Get(ItemNo) then
            ChannelCode := Item."PIM Channel Code";
        exit(CompletenessPercent(ItemNo, FamilyCode, ChannelCode));
    end;

    procedure CompletenessPercent(ItemNo: Code[20]; FamilyCode: Code[20]; ChannelCode: Code[20]): Decimal
    var
        FamilyAttribute: Record "PIM Family Attribute";
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
                if DelChr(GetValue(ItemNo, FamilyAttribute."Attribute Code", ChannelCode), '<>', ' ') <> '' then
                    FilledCount += 1;
            until FamilyAttribute.Next() = 0;

        if RequiredCount = 0 then
            exit(100);
        exit(Round(FilledCount / RequiredCount * 100, 1));
    end;

    procedure GetValue(ItemNo: Code[20]; AttributeCode: Code[20]): Text
    var
        Item: Record Item;
        ChannelCode: Code[20];
    begin
        if Item.Get(ItemNo) then
            ChannelCode := Item."PIM Channel Code";
        exit(GetValue(ItemNo, AttributeCode, ChannelCode));
    end;

    procedure GetValue(ItemNo: Code[20]; AttributeCode: Code[20]; ChannelCode: Code[20]): Text
    var
        ProductValue: Record "PIM Product Value";
    begin
        if ChannelCode <> '' then
            if ProductValue.Get(ItemNo, AttributeCode, ChannelCode, '') then
                if DelChr(ProductValue.Value, '<>', ' ') <> '' then
                    exit(ProductValue.Value);
        if ProductValue.Get(ItemNo, AttributeCode, '', '') then
            exit(ProductValue.Value);
        exit('');
    end;

    procedure EnsureItemChannels(ItemNo: Code[20])
    var
        Channel: Record "PIM Channel";
        ItemChannel: Record "PIM Item Channel";
        Item: Record Item;
        EnableWebshop: Boolean;
    begin
        if ItemNo = '' then
            exit;
        if Item.Get(ItemNo) then
            EnableWebshop := Item."PIM Published";

        Channel.SetRange(Enabled, true);
        if Channel.FindSet() then
            repeat
                if not ItemChannel.Get(ItemNo, Channel.Code) then begin
                    ItemChannel.Init();
                    ItemChannel."Item No." := ItemNo;
                    ItemChannel."Channel Code" := Channel.Code;
                    ItemChannel.Enabled := Channel."Show in Webshop" and EnableWebshop;
                    ItemChannel.Insert();
                end;
            until Channel.Next() = 0;
    end;

    procedure SyncWebshopPublish(ItemNo: Code[20]; Published: Boolean)
    var
        Channel: Record "PIM Channel";
        ItemChannel: Record "PIM Item Channel";
    begin
        EnsureItemChannels(ItemNo);
        Channel.SetRange("Show in Webshop", true);
        Channel.SetRange(Enabled, true);
        if Channel.FindSet() then
            repeat
                if ItemChannel.Get(ItemNo, Channel.Code) then
                    if ItemChannel.Enabled <> Published then begin
                        ItemChannel.Enabled := Published;
                        ItemChannel.Modify();
                    end;
            until Channel.Next() = 0;
    end;

    procedure OnItemChannelChanged(ItemChannel: Record "PIM Item Channel")
    var
        Channel: Record "PIM Channel";
        Item: Record Item;
    begin
        if not Channel.Get(ItemChannel."Channel Code") then
            exit;
        if not Channel."Show in Webshop" then
            exit;
        if not Item.Get(ItemChannel."Item No.") then
            exit;
        if Item."PIM Published" = ItemChannel.Enabled then
            exit;
        Item."PIM Published" := ItemChannel.Enabled;
        Item.Modify();
    end;

    procedure ItemOnWebshopChannel(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
        ItemChannel: Record "PIM Item Channel";
        Channel: Record "PIM Channel";
    begin
        if Item.Get(ItemNo) then
            if Item."PIM Published" then
                exit(true);

        ItemChannel.SetRange("Item No.", ItemNo);
        ItemChannel.SetRange(Enabled, true);
        if ItemChannel.FindSet() then
            repeat
                if Channel.Get(ItemChannel."Channel Code") then
                    if Channel.Enabled and Channel."Show in Webshop" then
                        exit(true);
            until ItemChannel.Next() = 0;
        exit(false);
    end;
}
