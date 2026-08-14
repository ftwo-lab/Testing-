controladdin ProductVisualViewer
{
    RequestedHeight = 1800;
    MinimumHeight = 800;
    RequestedWidth = 1100;
    MinimumWidth = 480;
    VerticalStretch = true;
    VerticalShrink = false;
    HorizontalStretch = true;
    HorizontalShrink = true;

    Scripts = 'Webshop/scripts/productViewer.js';
    StartupScript = 'Webshop/scripts/startup.js';
    RecreateScript = 'Webshop/scripts/startup.js';
    StyleSheets = 'Webshop/styles/productViewer.css';

    event ControlReady();
    event ProductSelected(ItemNo: Text);
    event BackToCatalog();
    event OpenItemCard(ItemNo: Text);

    procedure SetProductData(JsonData: Text);
}
