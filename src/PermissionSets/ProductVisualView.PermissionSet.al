permissionset 50100 "Product Visual View"
{
    Assignable = true;
    Caption = 'Visual Product View';
    Permissions =
        tabledata Item = R,
        tabledata "Item Variant" = R,
        tabledata "Item Unit of Measure" = R,
        tabledata "Item Reference" = R,
        tabledata "Item Translation" = R,
        tabledata "Item Attribute" = R,
        tabledata "Item Attribute Value" = R,
        tabledata "Item Attribute Value Mapping" = R,
        tabledata "Extended Text Header" = R,
        tabledata "Stockkeeping Unit" = R,
        tabledata "Default Dimension" = R,
        tabledata Location = R,
        tabledata "Tenant Media" = R,
        page "Product Visual Card" = X,
        codeunit "Product Visual Data" = X;
}
