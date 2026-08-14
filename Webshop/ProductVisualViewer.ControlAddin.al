controladdin ProductVisualViewer
{
    Scripts = 'Webshop/scripts/productViewer.js';
    StartupScript = 'Webshop/scripts/startup.js';
    StyleSheets = 'Webshop/styles/productViewer.css';

    HorizontalStretch = true;
    VerticalStretch = true;
    HorizontalShrink = true;
    VerticalShrink = false;
    RequestedHeight = 1800;
    MinimumHeight = 800;
    RequestedWidth = 1100;
    MinimumWidth = 480;

    event ControlReady();
    event ProductSelected(ItemNo: Text);
    event BackToCatalog();
    event OpenItemCard(ItemNo: Text);

    procedure SetProductData(JsonData: Text);
}
