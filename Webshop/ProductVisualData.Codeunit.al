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
}
