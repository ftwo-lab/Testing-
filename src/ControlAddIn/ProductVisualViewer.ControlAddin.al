controladdin ProductVisualViewer
{
    Scripts = 'src/ControlAddIn/scripts/productViewer.js';
    StartupScript = 'src/ControlAddIn/scripts/startup.js';
    StyleSheets = 'src/ControlAddIn/styles/productViewer.css';

    HorizontalStretch = true;
    VerticalStretch = true;
    HorizontalShrink = true;
    VerticalShrink = true;
    RequestedHeight = 860;
    MinimumHeight = 560;
    RequestedWidth = 1100;
    MinimumWidth = 480;

    event ControlReady();
    event ProductSelected(ItemNo: Text);
    event BackToCatalog();
    event OpenItemCard(ItemNo: Text);

    procedure SetProductData(JsonData: Text);
}
