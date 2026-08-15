codeunit 50634 "PIM Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        SeedPIM();
    end;

    procedure SeedPIM()
    begin
        InsertGroup('IDENT', 'Identifiers', 1);
        InsertGroup('MARKETING', 'Marketing', 2);
        InsertGroup('SPECS', 'Characteristics', 3);
        InsertGroup('SEO', 'SEO', 4);

        InsertAttribute('title', 'Title', "PIM Attribute Type"::Text, 'MARKETING', 'title');
        InsertAttribute('brand', 'Brand / Vendor', "PIM Attribute Type"::Text, 'MARKETING', 'vendor');
        InsertAttribute('short_desc', 'Short description', "PIM Attribute Type"::Text, 'MARKETING', '');
        InsertAttribute('description', 'Description', "PIM Attribute Type"::Text, 'MARKETING', 'body_html');
        InsertAttribute('color', 'Color', "PIM Attribute Type"::Option, 'SPECS', 'metafields.color');
        InsertAttribute('material', 'Material', "PIM Attribute Type"::Text, 'SPECS', 'metafields.material');
        InsertAttribute('size', 'Size', "PIM Attribute Type"::Text, 'SPECS', 'metafields.size');
        InsertAttribute('seo_title', 'SEO title', "PIM Attribute Type"::Text, 'SEO', 'metafields.seo_title');
        InsertAttribute('seo_desc', 'SEO description', "PIM Attribute Type"::Text, 'SEO', 'metafields.seo_description');

        InsertOption('color', 'BLACK', 'Black', 1);
        InsertOption('color', 'WHITE', 'White', 2);
        InsertOption('color', 'GREY', 'Grey', 3);
        InsertOption('color', 'BLUE', 'Blue', 4);
        InsertOption('color', 'RED', 'Red', 5);

        InsertFamily('DEFAULT', 'Default product family');
        AddFamilyAttr('DEFAULT', 'title', true);
        AddFamilyAttr('DEFAULT', 'brand', false);
        AddFamilyAttr('DEFAULT', 'short_desc', false);
        AddFamilyAttr('DEFAULT', 'description', true);
        AddFamilyAttr('DEFAULT', 'color', false);
        AddFamilyAttr('DEFAULT', 'material', false);
        AddFamilyAttr('DEFAULT', 'size', false);
        AddFamilyAttr('DEFAULT', 'seo_title', false);
        AddFamilyAttr('DEFAULT', 'seo_desc', false);

        InsertCategory('MASTER', 'Master catalog', '');
        InsertCategory('CARE', 'Care & hygiene', 'MASTER');
        InsertCategory('MEDICAL', 'Medical', 'MASTER');

        InsertMarketplace('DE', 'Germany', 'DE');
        InsertMarketplace('AT', 'Austria', 'AT');
        InsertMarketplace('ES', 'Spain', 'ES');
        InsertMarketplace('CH', 'Switzerland', 'CH');
        InsertMarketplace('NP', 'Nonpa', '');
        InsertMarketplace('CZ', 'Czech Republic', 'CZ');

        InsertChannel('WEBSHOP', 'Internal webshop', 'Webshop', true, 1, '', 'MASTER');
        InsertChannel('B2B', 'B2B catalog', 'B2B', false, 2, '', 'MASTER');
        InsertChannel('DE', 'Germany storefront', 'Country', false, 10, 'DE', 'MASTER');
        InsertChannel('AT', 'Austria storefront', 'Country', false, 11, 'AT', 'MASTER');
        InsertChannel('ES', 'Spain storefront', 'Country', false, 12, 'ES', 'MASTER');
        InsertChannel('CH', 'Switzerland storefront', 'Country', false, 13, 'CH', 'MASTER');
        InsertChannel('NP', 'Nonpa storefront', 'Country', false, 14, 'NP', 'MASTER');
        InsertChannel('CZ', 'Czech Republic storefront', 'Country', false, 15, 'CZ', 'MASTER');
    end;

    local procedure InsertGroup(CodeValue: Code[20]; DescriptionValue: Text[100]; SortOrder: Integer)
    var
        Group: Record "PIM Attribute Group";
    begin
        if Group.Get(CodeValue) then
            exit;
        Group.Init();
        Group.Code := CodeValue;
        Group.Description := DescriptionValue;
        Group."Sort Order" := SortOrder;
        Group.Insert();
    end;

    local procedure InsertAttribute(CodeValue: Code[20]; CaptionValue: Text[100]; TypeValue: Enum "PIM Attribute Type"; GroupCode: Code[20]; ShopifyField: Text[50])
    var
        Attr: Record "PIM Attribute";
    begin
        if Attr.Get(CodeValue) then
            exit;
        Attr.Init();
        Attr.Code := CodeValue;
        Attr.Caption := CaptionValue;
        Attr.Type := TypeValue;
        Attr."Group Code" := GroupCode;
        Attr."Shopify Field" := ShopifyField;
        Attr.Insert();
    end;

    local procedure InsertOption(AttributeCode: Code[20]; CodeValue: Code[20]; CaptionValue: Text[100]; SortOrder: Integer)
    var
        Opt: Record "PIM Attribute Option";
    begin
        if Opt.Get(AttributeCode, CodeValue) then
            exit;
        Opt.Init();
        Opt."Attribute Code" := AttributeCode;
        Opt.Code := CodeValue;
        Opt.Caption := CaptionValue;
        Opt."Sort Order" := SortOrder;
        Opt.Insert();
    end;

    local procedure InsertFamily(CodeValue: Code[20]; DescriptionValue: Text[100])
    var
        Family: Record "PIM Family";
    begin
        if Family.Get(CodeValue) then
            exit;
        Family.Init();
        Family.Code := CodeValue;
        Family.Description := DescriptionValue;
        Family.Insert();
    end;

    local procedure AddFamilyAttr(FamilyCode: Code[20]; AttributeCode: Code[20]; Required: Boolean)
    var
        FamilyAttribute: Record "PIM Family Attribute";
    begin
        if FamilyAttribute.Get(FamilyCode, AttributeCode) then
            exit;
        FamilyAttribute.Init();
        FamilyAttribute."Family Code" := FamilyCode;
        FamilyAttribute."Attribute Code" := AttributeCode;
        FamilyAttribute.Required := Required;
        FamilyAttribute.Insert();
    end;

    local procedure InsertCategory(CodeValue: Code[20]; DescriptionValue: Text[100]; ParentCode: Code[20])
    var
        Category: Record "PIM Category";
    begin
        if Category.Get(CodeValue) then
            exit;
        Category.Init();
        Category.Code := CodeValue;
        Category.Description := DescriptionValue;
        Category."Parent Code" := ParentCode;
        Category.Insert();
    end;

    local procedure InsertMarketplace(CodeValue: Code[20]; DescriptionValue: Text[100]; CountryCode: Code[10])
    var
        Marketplace: Record "PIM Marketplace";
    begin
        if Marketplace.Get(CodeValue) then
            exit;
        Marketplace.Init();
        Marketplace.Code := CodeValue;
        Marketplace.Description := DescriptionValue;
        Marketplace."Country/Region Code" := CountryCode;
        Marketplace.Enabled := false;
        Marketplace."Copy Unit Price" := true;
        Marketplace.Insert();
    end;

    local procedure InsertChannel(CodeValue: Code[20]; DescriptionValue: Text[100]; ChannelType: Text[30]; ShowInWebshop: Boolean; SortOrder: Integer; MarketplaceCode: Code[20]; CategoryTree: Code[20])
    var
        Channel: Record "PIM Channel";
    begin
        if Channel.Get(CodeValue) then
            exit;
        Channel.Init();
        Channel.Code := CodeValue;
        Channel.Description := DescriptionValue;
        Channel."Channel Type" := ChannelType;
        Channel.Enabled := true;
        Channel."Show in Webshop" := ShowInWebshop;
        Channel."Marketplace Code" := MarketplaceCode;
        Channel."Category Tree Code" := CategoryTree;
        Channel."Sort Order" := SortOrder;
        Channel.Insert();
    end;
}
