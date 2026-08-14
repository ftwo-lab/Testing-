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

    // Paths are relative to app.json. This matches Webshop living under src/.
    Scripts = 'src/Webshop/scripts/productViewer.js';
    StartupScript = 'src/Webshop/scripts/startup.js';
    RecreateScript = 'src/Webshop/scripts/startup.js';
    StyleSheets = 'src/Webshop/styles/productViewer.css';

    event ControlReady();
    event ProductSelected(ItemNo: Text);
    event BackToCatalog();
    event OpenItemCard(ItemNo: Text);

    procedure SetProductData(JsonData: Text);
}
