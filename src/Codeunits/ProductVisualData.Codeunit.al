codeunit 50100 "Product Visual Data"
{
    procedure BuildProductJson(Item: Record Item): Text
    var
        ItemRec: Record Item;
        Root: JsonObject;
        Header: JsonObject;
        Groups: JsonObject;
        GroupsArray: JsonArray;
        Related: JsonObject;
        RecRef: RecordRef;
        FldRef: FieldRef;
        JsonText: Text;
        i: Integer;
        FieldCount: Integer;
        CustomFieldCount: Integer;
        ValueText: Text;
        GroupName: Text;
        SourceName: Text;
    begin
        Header.Add('no', '');
        Root.Add('header', Header);
        Root.Add('groups', GroupsArray);
        Root.Add('related', Related);

        if Item."No." = '' then begin
            Root.WriteTo(JsonText);
            exit(JsonText);
        end;

        if not ItemRec.Get(Item."No.") then begin
            Root.WriteTo(JsonText);
            exit(JsonText);
        end;

        ItemRec.CalcFields(Inventory);

        RecRef.GetTable(ItemRec);
        for i := 1 to RecRef.FieldCount do begin
            FldRef := RecRef.FieldIndex(i);
            if IncludeField(FldRef) then begin
                if FldRef.Class = FieldClass::FlowField then
                    if not TryCalcField(FldRef) then
                        ValueText := ''
                    else
                        ValueText := GetFieldText(FldRef)
                else
                    ValueText := GetFieldText(FldRef);

                SourceName := GetFieldSource(FldRef.Number);
                GroupName := GetGroupName(FldRef);
                AddFieldToGroup(Groups, GroupName, CreateFieldObject(FldRef, ValueText, SourceName));
                FieldCount += 1;
                if SourceName in ['Custom', 'Extension'] then
                    CustomFieldCount += 1;
            end;
        end;

        Header := BuildHeader(ItemRec, FieldCount, CustomFieldCount);
        GroupsArray := GroupsToArray(Groups);
        Related := BuildRelated(ItemRec);

        Clear(Root);
        Root.Add('header', Header);
        Root.Add('groups', GroupsArray);
        Root.Add('related', Related);
        Root.WriteTo(JsonText);
        exit(JsonText);
    end;

    local procedure IncludeField(FldRef: FieldRef): Boolean
    begin
        if not FldRef.Active then
            exit(false);
        if FldRef.Class = FieldClass::FlowFilter then
            exit(false);
        if FldRef.ObsoleteState = ObsoleteState::Removed then
            exit(false);
        if FldRef.Type in [FieldType::Blob, FieldType::Media, FieldType::MediaSet] then
            exit(false);
        exit(true);
    end;

    local procedure GetFieldText(FldRef: FieldRef): Text
    var
        ValueText: Text;
    begin
        if not TryFormatField(FldRef, ValueText) then
            exit('');
        exit(ValueText);
    end;

    [TryFunction]
    local procedure TryFormatField(FldRef: FieldRef; var ValueText: Text)
    begin
        case FldRef.Type of
            FieldType::Blob:
                ValueText := '[Binary]';
            FieldType::Media:
                ValueText := '[Media]';
            FieldType::MediaSet:
                ValueText := '[Media set]';
            else
                ValueText := Format(FldRef.Value);
        end;
    end;

    [TryFunction]
    local procedure TryCalcField(FldRef: FieldRef)
    begin
        FldRef.CalcField();
    end;

    local procedure CreateFieldObject(FldRef: FieldRef; ValueText: Text; SourceName: Text): JsonObject
    var
        FieldObj: JsonObject;
    begin
        FieldObj.Add('fieldNo', FldRef.Number);
        FieldObj.Add('name', FldRef.Name);
        FieldObj.Add('caption', FldRef.Caption);
        FieldObj.Add('value', ValueText);
        FieldObj.Add('type', Format(FldRef.Type));
        FieldObj.Add('class', Format(FldRef.Class));
        FieldObj.Add('source', SourceName);
        exit(FieldObj);
    end;

    local procedure GetFieldSource(FieldNo: Integer): Text
    begin
        if FieldNo >= 1000000 then
            exit('Extension');
        if FieldNo >= 50000 then
            exit('Custom');
        exit('Standard');
    end;

    local procedure GetGroupName(FldRef: FieldRef): Text
    var
        FieldNo: Integer;
        Name: Text;
    begin
        FieldNo := FldRef.Number;
        if (FieldNo >= 50000) and (FieldNo <= 99999) then
            exit('Custom Fields');
        if FieldNo >= 1000000 then
            exit('Extension Fields');

        Name := UpperCase(FldRef.Name);
        if ContainsAny(Name, 'INVENTORY|QTY.|QUANTITY|STOCK|SHELF|PHYS INV|AVAILABILITY|RESERVE') then
            exit('Inventory');
        if ContainsAny(Name, 'COST|PROFIT|PRICE|DISCOUNT|TARIFF|VAT |TAX|CURRENCY') then
            exit('Pricing & Costing');
        if ContainsAny(Name, 'PRODUCTION BOM|ROUTING|ASSEMBLY|SCRAP %|OVERHEAD RATE|FLUSHING') then
            exit('Production & Assembly');
        if ContainsAny(Name, 'VENDOR|PURCHAS|REPLENISH|LEAD TIME|MANUFACTURER|REORDER|ORDER MULT|SAFETY STOCK') then
            exit('Replenishment & Purchasing');
        if ContainsAny(Name, 'PLANNING|MPS|MRP|DAMPENER|LOT ACCUM|RESCHEDUL|TIME BUCKET|SAFETY LEAD') then
            exit('Planning');
        if ContainsAny(Name, 'SERIAL|LOT NO|PACKAGE TRACK|ITEM TRACKING|EXPIRATION|WARRANTY') then
            exit('Item Tracking');
        if ContainsAny(Name, 'WAREHOUSE|BIN |PUT-AWAY|PICKING|RECEIV|SHIPPING|CUBAGE|GROSS WEIGHT|NET WEIGHT|UNITS PER PARCEL') then
            exit('Warehouse');
        if ContainsAny(Name, 'SALES|COMMISSION|INVOICE DISC|CUSTOMER') then
            exit('Sales');
        if ContainsAny(Name, 'SERVICE|QUALITY|ITEM CATEGORY|STATISTICS GROUP|PRODUCT GROUP') then
            exit('Quality & Service');
        if FieldNo <= 99 then
            exit('General');
        exit('Other Standard Fields');
    end;

    local procedure ContainsAny(Name: Text; PatternList: Text): Boolean
    var
        Pattern: Text;
        Patterns: List of [Text];
    begin
        Patterns := PatternList.Split('|');
        foreach Pattern in Patterns do
            if StrPos(Name, Pattern) > 0 then
                exit(true);
        exit(false);
    end;

    local procedure AddFieldToGroup(var Groups: JsonObject; GroupName: Text; FieldObj: JsonObject)
    var
        GroupToken: JsonToken;
        GroupObj: JsonObject;
        FieldsToken: JsonToken;
        FieldsArray: JsonArray;
    begin
        if Groups.Get(GroupName, GroupToken) then begin
            GroupObj := GroupToken.AsObject();
            GroupObj.Get('fields', FieldsToken);
            FieldsArray := FieldsToken.AsArray();
            FieldsArray.Add(FieldObj);
            GroupObj.Replace('fields', FieldsArray);
            Groups.Replace(GroupName, GroupObj);
        end else begin
            FieldsArray.Add(FieldObj);
            GroupObj.Add('name', GroupName);
            GroupObj.Add('fields', FieldsArray);
            Groups.Add(GroupName, GroupObj);
        end;
    end;

    local procedure GroupsToArray(Groups: JsonObject): JsonArray
    var
        Result: JsonArray;
        OrderedNames: List of [Text];
        GroupName: Text;
        GroupToken: JsonToken;
    begin
        OrderedNames.Add('General');
        OrderedNames.Add('Inventory');
        OrderedNames.Add('Pricing & Costing');
        OrderedNames.Add('Replenishment & Purchasing');
        OrderedNames.Add('Planning');
        OrderedNames.Add('Item Tracking');
        OrderedNames.Add('Warehouse');
        OrderedNames.Add('Production & Assembly');
        OrderedNames.Add('Sales');
        OrderedNames.Add('Quality & Service');
        OrderedNames.Add('Other Standard Fields');
        OrderedNames.Add('Custom Fields');
        OrderedNames.Add('Extension Fields');

        foreach GroupName in OrderedNames do
            if Groups.Get(GroupName, GroupToken) then
                Result.Add(GroupToken.AsObject());
        exit(Result);
    end;

    local procedure BuildHeader(ItemRec: Record Item; FieldCount: Integer; CustomFieldCount: Integer): JsonObject
    var
        Header: JsonObject;
    begin
        Header.Add('no', ItemRec."No.");
        Header.Add('description', ItemRec.Description);
        Header.Add('description2', ItemRec."Description 2");
        Header.Add('blocked', ItemRec.Blocked);
        Header.Add('type', Format(ItemRec.Type));
        Header.Add('baseUom', ItemRec."Base Unit of Measure");
        Header.Add('itemCategory', ItemRec."Item Category Code");
        Header.Add('unitPrice', Format(ItemRec."Unit Price"));
        Header.Add('unitCost', Format(ItemRec."Unit Cost"));
        Header.Add('inventory', Format(ItemRec.Inventory));
        Header.Add('vendorNo', ItemRec."Vendor No.");
        Header.Add('picture', GetPictureDataUrl(ItemRec));
        Header.Add('fieldCount', FieldCount);
        Header.Add('customFieldCount', CustomFieldCount);
        exit(Header);
    end;

    local procedure GetPictureDataUrl(ItemRec: Record Item): Text
    var
        TenantMedia: Record "Tenant Media";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
        MediaId: Guid;
        Base64Text: Text;
    begin
        if ItemRec.Picture.Count = 0 then
            exit('');
        MediaId := ItemRec.Picture.Item(1);
        if IsNullGuid(MediaId) then
            exit('');
        if not TenantMedia.Get(MediaId) then
            exit('');
        TenantMedia.CalcFields(Content);
        if not TenantMedia.Content.HasValue then
            exit('');
        TenantMedia.Content.CreateInStream(InStr);
        Base64Text := Base64Convert.ToBase64(InStr);
        if Base64Text = '' then
            exit('');
        if StrLen(Base64Text) > 900000 then
            exit('');
        if TenantMedia."Mime Type" = '' then
            exit('data:image/png;base64,' + Base64Text);
        exit('data:' + TenantMedia."Mime Type" + ';base64,' + Base64Text);
    end;

    local procedure BuildRelated(ItemRec: Record Item): JsonObject
    var
        Related: JsonObject;
    begin
        Related.Add('attributes', GetAttributes(ItemRec));
        Related.Add('variants', GetVariants(ItemRec));
        Related.Add('unitsOfMeasure', GetUnitsOfMeasure(ItemRec));
        Related.Add('references', GetReferences(ItemRec));
        Related.Add('translations', GetTranslations(ItemRec));
        Related.Add('inventoryByLocation', GetInventoryByLocation(ItemRec));
        Related.Add('stockkeepingUnits', GetStockkeepingUnits(ItemRec));
        Related.Add('dimensions', GetDimensions(ItemRec));
        Related.Add('extendedTexts', GetExtendedTexts(ItemRec));
        exit(Related);
    end;

    local procedure GetAttributes(ItemRec: Record Item): JsonArray
    var
        Mapping: Record "Item Attribute Value Mapping";
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValue: Record "Item Attribute Value";
        Result: JsonArray;
        Row: JsonObject;
    begin
        Mapping.SetRange("Table ID", Database::Item);
        Mapping.SetRange("No.", ItemRec."No.");
        if Mapping.FindSet() then
            repeat
                Clear(Row);
                if ItemAttribute.Get(Mapping."Item Attribute ID") then
                    Row.Add('name', ItemAttribute.Name)
                else
                    Row.Add('name', Format(Mapping."Item Attribute ID"));
                if ItemAttributeValue.Get(Mapping."Item Attribute ID", Mapping."Item Attribute Value ID") then
                    Row.Add('value', ItemAttributeValue.Value)
                else
                    Row.Add('value', '');
                Result.Add(Row);
            until Mapping.Next() = 0;
        exit(Result);
    end;

    local procedure GetVariants(ItemRec: Record Item): JsonArray
    var
        ItemVariant: Record "Item Variant";
        Result: JsonArray;
        Row: JsonObject;
    begin
        ItemVariant.SetRange("Item No.", ItemRec."No.");
        if ItemVariant.FindSet() then
            repeat
                Clear(Row);
                Row.Add('code', ItemVariant.Code);
                Row.Add('description', ItemVariant.Description);
                Row.Add('blocked', Format(ItemVariant.Blocked));
                Result.Add(Row);
            until ItemVariant.Next() = 0;
        exit(Result);
    end;

    local procedure GetUnitsOfMeasure(ItemRec: Record Item): JsonArray
    var
        ItemUOM: Record "Item Unit of Measure";
        Result: JsonArray;
        Row: JsonObject;
    begin
        ItemUOM.SetRange("Item No.", ItemRec."No.");
        if ItemUOM.FindSet() then
            repeat
                Clear(Row);
                Row.Add('code', ItemUOM.Code);
                Row.Add('qtyPerUnit', Format(ItemUOM."Qty. per Unit of Measure"));
                Row.Add('description', ItemUOM.Code);
                Result.Add(Row);
            until ItemUOM.Next() = 0;
        exit(Result);
    end;

    local procedure GetReferences(ItemRec: Record Item): JsonArray
    var
        ItemReference: Record "Item Reference";
        Result: JsonArray;
        Row: JsonObject;
    begin
        ItemReference.SetRange("Item No.", ItemRec."No.");
        if ItemReference.FindSet() then
            repeat
                Clear(Row);
                Row.Add('referenceNo', ItemReference."Reference No.");
                Row.Add('referenceType', Format(ItemReference."Reference Type"));
                Row.Add('description', ItemReference.Description);
                Row.Add('variantCode', ItemReference."Variant Code");
                Result.Add(Row);
            until ItemReference.Next() = 0;
        exit(Result);
    end;

    local procedure GetTranslations(ItemRec: Record Item): JsonArray
    var
        ItemTranslation: Record "Item Translation";
        Result: JsonArray;
        Row: JsonObject;
    begin
        ItemTranslation.SetRange("Item No.", ItemRec."No.");
        if ItemTranslation.FindSet() then
            repeat
                Clear(Row);
                Row.Add('languageCode', ItemTranslation."Language Code");
                Row.Add('description', ItemTranslation.Description);
                Row.Add('description2', ItemTranslation."Description 2");
                Result.Add(Row);
            until ItemTranslation.Next() = 0;
        exit(Result);
    end;

    local procedure GetInventoryByLocation(ItemRec: Record Item): JsonArray
    var
        Location: Record Location;
        ItemCopy: Record Item;
        Result: JsonArray;
        Row: JsonObject;
    begin
        if not ItemCopy.Get(ItemRec."No.") then
            exit(Result);
        if Location.FindSet() then
            repeat
                ItemCopy.SetRange("Location Filter", Location.Code);
                ItemCopy.CalcFields(Inventory);
                if ItemCopy.Inventory <> 0 then begin
                    Clear(Row);
                    Row.Add('locationCode', Location.Code);
                    Row.Add('locationName', Location.Name);
                    Row.Add('inventory', Format(ItemCopy.Inventory));
                    Result.Add(Row);
                end;
            until Location.Next() = 0;
        exit(Result);
    end;

    local procedure GetStockkeepingUnits(ItemRec: Record Item): JsonArray
    var
        SKU: Record "Stockkeeping Unit";
        Result: JsonArray;
        Row: JsonObject;
    begin
        SKU.SetRange("Item No.", ItemRec."No.");
        if SKU.FindSet() then
            repeat
                Clear(Row);
                Row.Add('locationCode', SKU."Location Code");
                Row.Add('variantCode', SKU."Variant Code");
                Row.Add('replenishmentSystem', Format(SKU."Replenishment System"));
                Row.Add('vendorNo', SKU."Vendor No.");
                Result.Add(Row);
            until SKU.Next() = 0;
        exit(Result);
    end;

    local procedure GetDimensions(ItemRec: Record Item): JsonArray
    var
        DefaultDimension: Record "Default Dimension";
        Result: JsonArray;
        Row: JsonObject;
    begin
        DefaultDimension.SetRange("Table ID", Database::Item);
        DefaultDimension.SetRange("No.", ItemRec."No.");
        if DefaultDimension.FindSet() then
            repeat
                Clear(Row);
                Row.Add('dimensionCode', DefaultDimension."Dimension Code");
                Row.Add('dimensionValueCode', DefaultDimension."Dimension Value Code");
                Row.Add('valuePosting', Format(DefaultDimension."Value Posting"));
                Result.Add(Row);
            until DefaultDimension.Next() = 0;
        exit(Result);
    end;

    local procedure GetExtendedTexts(ItemRec: Record Item): JsonArray
    var
        ExtendedTextHeader: Record "Extended Text Header";
        Result: JsonArray;
        Row: JsonObject;
    begin
        ExtendedTextHeader.SetRange("Table Name", ExtendedTextHeader."Table Name"::Item);
        ExtendedTextHeader.SetRange("No.", ItemRec."No.");
        if ExtendedTextHeader.FindSet() then
            repeat
                Clear(Row);
                Row.Add('languageCode', ExtendedTextHeader."Language Code");
                Row.Add('textNo', Format(ExtendedTextHeader."Text No."));
                Row.Add('description', ExtendedTextHeader.Description);
                Result.Add(Row);
            until ExtendedTextHeader.Next() = 0;
        exit(Result);
    end;
}
