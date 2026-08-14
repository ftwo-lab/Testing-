permissionset 50355 "Product Visual View"
{
    Assignable = true;
    Caption = 'PIM and Webshop';
    Permissions =
        tabledata Item = RIM,
        tabledata "PIM Attribute Group" = RIMD,
        tabledata "PIM Attribute" = RIMD,
        tabledata "PIM Attribute Option" = RIMD,
        tabledata "PIM Family" = RIMD,
        tabledata "PIM Family Attribute" = RIMD,
        tabledata "PIM Category" = RIMD,
        tabledata "PIM Product Value" = RIMD,
        tabledata "Company Information" = R,
        tabledata "Tenant Media" = R,
        page "PIM Attribute Groups" = X,
        page "PIM Attributes" = X,
        page "PIM Attribute Card" = X,
        page "PIM Attribute Options" = X,
        page "PIM Families" = X,
        page "PIM Family Card" = X,
        page "PIM Family Attributes" = X,
        page "PIM Categories" = X,
        page "PIM Product Values" = X,
        page "PIM Product Enrichment" = X,
        page "Product Visual Card" = X,
        page "Product Webshop" = X,
        codeunit "Product Visual Data" = X,
        codeunit "PIM Enrichment" = X,
        codeunit "PIM Install" = X;
}
