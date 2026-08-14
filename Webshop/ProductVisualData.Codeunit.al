codeunit 50633 "Product Visual Data"
{
    procedure BuildProductJson(Item: Record Item): Text
    begin
        exit(BuildProductJson(Item, false));
    end;

    procedure BuildProductJson(Item: Record Item; ShowBack: Boolean): Text
    var
        ItemRec: Record Item;
        Root: JsonObject;
        Header: JsonObject;
        JsonText: Text;
    begin
        if (Item."No." = '') or (not ItemRec.Get(Item."No.")) then begin
            Root.Add('view', 'product');
            Root.Add('header', Header);
            Root.WriteTo(JsonText);
            exit(JsonText);
        end;

        ItemRec.CalcFields(Inventory);
        Header := BuildHeader(ItemRec);
        Root.Add('view', 'product');
        Root.Add('showBack', ShowBack);
        Root.Add('shopName', GetShopName());
        Root.Add('header', Header);
        Root.Add('attributes', GetPimAttributes(ItemRec."No."));
        Root.Add('itemAttributes', GetStandardItemAttributes(ItemRec."No."));
        Root.Add('variants', GetVariants(ItemRec."No."));
        Root.Add('unitsOfMeasure', GetUnitsOfMeasure(ItemRec."No."));
        Root.Add('extendedTexts', GetExtendedTexts(ItemRec."No."));
        Root.Add('documents', GetDocuments(ItemRec."No."));
        Root.Add('pictures', GetPictures(ItemRec));
        Root.Add('translations', GetTranslations(ItemRec."No."));
        Root.Add('shopifyMap', GetShopifyMap(ItemRec));
        Root.WriteTo(JsonText);
        exit(JsonText);
    end;

    procedure BuildCatalogJson(): Text
    var
        ItemRec: Record Item;
        Root: JsonObject;
        Products: JsonArray;
        JsonText: Text;
        ItemCount: Integer;
    begin
        Root.Add('view', 'catalog');
        Root.Add('shopName', GetShopName());

        ItemRec.SetRange("PIM Published", true);
        if ItemRec.FindSet() then
            repeat
                ItemCount += 1;
                if ItemCount <= 48 then begin
                    ItemRec.CalcFields(Inventory);
                    Products.Add(BuildCatalogProduct(ItemRec));
                end;
            until (ItemRec.Next() = 0) or (ItemCount >= 48);

        Root.Add('productCount', ItemCount);
        Root.Add('products', Products);
        Root.WriteTo(JsonText);
        exit(JsonText);
    end;

    local procedure BuildCatalogProduct(ItemRec: Record Item): JsonObject
    var
        Product: JsonObject;
        PIMEnrichment: Codeunit "PIM Enrichment";
        Title: Text;
        CategoryName: Text;
    begin
        Title := PIMEnrichment.GetValue(ItemRec."No.", 'title');
        if Title = '' then
            Title := ItemRec.Description;
        CategoryName := GetCategoryName(ItemRec);

        Product.Add('no', ItemRec."No.");
        Product.Add('description', Title);
        Product.Add('description2', PIMEnrichment.GetValue(ItemRec."No.", 'short_desc'));
        Product.Add('itemCategory', ItemRec."PIM Category Code");
        Product.Add('categoryName', CategoryName);
        Product.Add('unitPrice', Format(ItemRec."Unit Price"));
        Product.Add('unitPriceValue', ItemRec."Unit Price");
        Product.Add('inventory', Format(ItemRec.Inventory));
        Product.Add('inventoryValue', ItemRec.Inventory);
        Product.Add('baseUom', ItemRec."Base Unit of Measure");
        Product.Add('type', Format(ItemRec.Type));
        Product.Add('picture', GetPictureDataUrl(ItemRec, 180000));
        exit(Product);
    end;

    local procedure BuildHeader(ItemRec: Record Item): JsonObject
    var
        PIMEnrichment: Codeunit "PIM Enrichment";
        Header: JsonObject;
        Title: Text;
        Brand: Text;
        Description: Text;
    begin
        Title := PIMEnrichment.GetValue(ItemRec."No.", 'title');
        if Title = '' then
            Title := ItemRec.Description;
        Brand := PIMEnrichment.GetValue(ItemRec."No.", 'brand');
        Description := PIMEnrichment.GetValue(ItemRec."No.", 'description');
        if Description = '' then
            Description := PIMEnrichment.GetValue(ItemRec."No.", 'short_desc');

        Header.Add('no', ItemRec."No.");
        Header.Add('description', Title);
        Header.Add('description2', PIMEnrichment.GetValue(ItemRec."No.", 'short_desc'));
        Header.Add('longDescription', Description);
        Header.Add('blocked', ItemRec.Blocked);
        Header.Add('type', Format(ItemRec.Type));
        Header.Add('baseUom', ItemRec."Base Unit of Measure");
        Header.Add('itemCategory', ItemRec."PIM Category Code");
        Header.Add('categoryName', GetCategoryName(ItemRec));
        Header.Add('unitPrice', Format(ItemRec."Unit Price"));
        Header.Add('unitCost', '');
        Header.Add('inventory', Format(ItemRec.Inventory));
        Header.Add('inventoryValue', ItemRec.Inventory);
        Header.Add('unitPriceValue', ItemRec."Unit Price");
        Header.Add('vendorNo', ItemRec."Vendor No.");
        Header.Add('vendorName', Brand);
        Header.Add('commonItemNo', ItemRec."Common Item No.");
        Header.Add('picture', GetPictureDataUrl(ItemRec, 900000));
        Header.Add('published', ItemRec."PIM Published");
        Header.Add('familyCode', ItemRec."PIM Family Code");
        Header.Add('completeness', PIMEnrichment.CompletenessPercent(ItemRec."No.", ItemRec."PIM Family Code"));
        exit(Header);
    end;

    local procedure GetPimAttributes(ItemNo: Code[20]): JsonArray
    var
        ProductValue: Record "PIM Product Value";
        Result: JsonArray;
        Row: JsonObject;
    begin
        ProductValue.SetRange("Item No.", ItemNo);
        if ProductValue.FindSet() then
            repeat
                ProductValue.CalcFields("Attribute Caption", "Group Code", "Attribute Type");
                if DelChr(ProductValue.Value, '<>', ' ') <> '' then begin
                    Clear(Row);
                    Row.Add('code', ProductValue."Attribute Code");
                    Row.Add('caption', ProductValue."Attribute Caption");
                    Row.Add('group', ProductValue."Group Code");
                    Row.Add('type', Format(ProductValue."Attribute Type"));
                    Row.Add('value', ProductValue.Value);
                    Result.Add(Row);
                end;
            until ProductValue.Next() = 0;
        exit(Result);
    end;

    local procedure GetShopifyMap(ItemRec: Record Item): JsonArray
    var
        Attr: Record "PIM Attribute";
        PIMEnrichment: Codeunit "PIM Enrichment";
        Result: JsonArray;
        Row: JsonObject;
        ValueText: Text;
    begin
        AddMapRow(Result, 'title', 'PIM title / Item Description', PIMEnrichment.GetValue(ItemRec."No.", 'title'));
        AddMapRow(Result, 'vendor', 'PIM brand', PIMEnrichment.GetValue(ItemRec."No.", 'brand'));
        AddMapRow(Result, 'product_type', 'PIM category', GetCategoryName(ItemRec));
        AddMapRow(Result, 'status', 'PIM Published', Format(ItemRec."PIM Published"));
        AddMapRow(Result, 'body_html', 'PIM description', PIMEnrichment.GetValue(ItemRec."No.", 'description'));
        AddMapRow(Result, 'variants[0].sku', 'Item No.', ItemRec."No.");
        AddMapRow(Result, 'variants[0].price', 'Item Unit Price', Format(ItemRec."Unit Price"));
        AddMapRow(Result, 'variants[0].inventory_quantity', 'Item Inventory', Format(ItemRec.Inventory));

        Attr.SetFilter("Shopify Field", '<>%1', '');
        if Attr.FindSet() then
            repeat
                ValueText := PIMEnrichment.GetValue(ItemRec."No.", Attr.Code);
                if ValueText <> '' then begin
                    Clear(Row);
                    Row.Add('shopify', Attr."Shopify Field");
                    Row.Add('source', Attr.Caption);
                    Row.Add('value', ValueText);
                    Result.Add(Row);
                end;
            until Attr.Next() = 0;
        exit(Result);
    end;

    local procedure AddMapRow(var Result: JsonArray; ShopifyField: Text; Source: Text; ValueText: Text)
    var
        Row: JsonObject;
    begin
        Row.Add('shopify', ShopifyField);
        Row.Add('source', Source);
        Row.Add('value', ValueText);
        Result.Add(Row);
    end;

    local procedure GetCategoryName(ItemRec: Record Item): Text
    var
        PIMCategory: Record "PIM Category";
    begin
        if ItemRec."PIM Category Code" = '' then
            exit('');
        if PIMCategory.Get(ItemRec."PIM Category Code") then
            if PIMCategory.Description <> '' then
                exit(PIMCategory.Description);
        exit(ItemRec."PIM Category Code");
    end;

    local procedure GetShopName(): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        if CompanyInformation.Get() and (CompanyInformation.Name <> '') then
            exit(CompanyInformation.Name);
        exit('Product Webshop');
    end;

    local procedure GetPictureDataUrl(ItemRec: Record Item; MaxBase64Len: Integer): Text
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
        if (Base64Text = '') or (StrLen(Base64Text) > MaxBase64Len) then
            exit('');
        if TenantMedia."Mime Type" = '' then
            exit('data:image/png;base64,' + Base64Text);
        exit('data:' + TenantMedia."Mime Type" + ';base64,' + Base64Text);
    end;

    local procedure GetMediaDataUrl(MediaId: Guid; MaxBase64Len: Integer): Text
    var
        TenantMedia: Record "Tenant Media";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
        Base64Text: Text;
    begin
        if IsNullGuid(MediaId) then
            exit('');
        if not TenantMedia.Get(MediaId) then
            exit('');
        TenantMedia.CalcFields(Content);
        if not TenantMedia.Content.HasValue then
            exit('');
        TenantMedia.Content.CreateInStream(InStr);
        Base64Text := Base64Convert.ToBase64(InStr);
        if (Base64Text = '') or (StrLen(Base64Text) > MaxBase64Len) then
            exit('');
        if TenantMedia."Mime Type" = '' then
            exit('data:image/png;base64,' + Base64Text);
        exit('data:' + TenantMedia."Mime Type" + ';base64,' + Base64Text);
    end;

    local procedure GetPictures(ItemRec: Record Item): JsonArray
    var
        Attachment: Record "Document Attachment";
        Result: JsonArray;
        Row: JsonObject;
        i: Integer;
        DataUrl: Text;
        Ext: Text;
    begin
        for i := 1 to ItemRec.Picture.Count do begin
            DataUrl := GetMediaDataUrl(ItemRec.Picture.Item(i), 400000);
            if DataUrl <> '' then begin
                Clear(Row);
                Row.Add('source', 'Item Picture');
                Row.Add('url', DataUrl);
                Result.Add(Row);
            end;
        end;

        Attachment.SetRange("Table ID", Database::Item);
        Attachment.SetRange("No.", ItemRec."No.");
        if Attachment.FindSet() then
            repeat
                Ext := LowerCase(Attachment."File Extension");
                if Ext in ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'] then begin
                    DataUrl := GetAttachmentUrl(Attachment, 300000);
                    if DataUrl <> '' then begin
                        Clear(Row);
                        Row.Add('source', Attachment."File Name");
                        Row.Add('url', DataUrl);
                        Result.Add(Row);
                    end;
                end;
            until Attachment.Next() = 0;
        exit(Result);
    end;

    local procedure GetDocuments(ItemNo: Code[20]): JsonArray
    var
        Attachment: Record "Document Attachment";
        Result: JsonArray;
        Row: JsonObject;
        Url: Text;
    begin
        Attachment.SetRange("Table ID", Database::Item);
        Attachment.SetRange("No.", ItemNo);
        if Attachment.FindSet() then
            repeat
                Clear(Row);
                Row.Add('fileName', Attachment."File Name");
                Row.Add('extension', Attachment."File Extension");
                Url := GetAttachmentUrl(Attachment, 0);
                Row.Add('url', Url);
                Result.Add(Row);
            until Attachment.Next() = 0;
        exit(Result);
    end;

    local procedure GetAttachmentUrl(Attachment: Record "Document Attachment"; MaxBase64Len: Integer): Text
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        i: Integer;
        Name: Text;
        TextValue: Text;
    begin
        RecRef.GetTable(Attachment);
        for i := 1 to RecRef.FieldCount do begin
            FldRef := RecRef.FieldIndex(i);
            if FldRef.Class = FieldClass::Normal then begin
                Name := UpperCase(FldRef.Name);
                if (StrPos(Name, 'URL') > 0) or (StrPos(Name, 'URI') > 0) then begin
                    TextValue := Format(FldRef.Value);
                    if TextValue <> '' then
                        exit(TextValue);
                end;
            end;
        end;
        if MaxBase64Len = 0 then
            exit('');
        if Attachment."Document Reference ID".HasValue then
            exit(GetMediaDataUrl(Attachment."Document Reference ID".MediaId(), MaxBase64Len));
        exit('');
    end;

    local procedure GetVariants(ItemNo: Code[20]): JsonArray
    var
        ItemVariant: Record "Item Variant";
        Result: JsonArray;
        Row: JsonObject;
    begin
        ItemVariant.SetRange("Item No.", ItemNo);
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

    local procedure GetUnitsOfMeasure(ItemNo: Code[20]): JsonArray
    var
        ItemUOM: Record "Item Unit of Measure";
        Result: JsonArray;
        Row: JsonObject;
    begin
        ItemUOM.SetRange("Item No.", ItemNo);
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

    local procedure GetTranslations(ItemNo: Code[20]): JsonArray
    var
        ItemTranslation: Record "Item Translation";
        Result: JsonArray;
        Row: JsonObject;
    begin
        ItemTranslation.SetRange("Item No.", ItemNo);
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

    local procedure GetExtendedTexts(ItemNo: Code[20]): JsonArray
    var
        Header: Record "Extended Text Header";
        Line: Record "Extended Text Line";
        Result: JsonArray;
        Row: JsonObject;
        Builder: TextBuilder;
    begin
        Header.SetRange("Table Name", Header."Table Name"::Item);
        Header.SetRange("No.", ItemNo);
        if Header.FindSet() then
            repeat
                Clear(Builder);
                Line.SetRange("Table Name", Header."Table Name");
                Line.SetRange("No.", ItemNo);
                Line.SetRange("Language Code", Header."Language Code");
                Line.SetRange("Text No.", Header."Text No.");
                if Line.FindSet() then
                    repeat
                        if Builder.Length() > 0 then
                            Builder.Append(' ');
                        Builder.Append(Line.Text);
                    until Line.Next() = 0;
                Clear(Row);
                Row.Add('languageCode', Header."Language Code");
                Row.Add('textNo', Format(Header."Text No."));
                Row.Add('description', Header.Description);
                Row.Add('text', Builder.ToText());
                Result.Add(Row);
            until Header.Next() = 0;
        exit(Result);
    end;

    local procedure GetStandardItemAttributes(ItemNo: Code[20]): JsonArray
    var
        Mapping: Record "Item Attribute Value Mapping";
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValue: Record "Item Attribute Value";
        Result: JsonArray;
        Row: JsonObject;
    begin
        Mapping.SetRange("Table ID", Database::Item);
        Mapping.SetRange("No.", ItemNo);
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
}
