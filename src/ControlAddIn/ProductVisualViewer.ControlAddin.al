controladdin ProductVisualViewer
{
    Scripts = 'src/ControlAddIn/scripts/productViewer.js';
    StartupScript = 'src/ControlAddIn/scripts/startup.js';
    StyleSheets = 'src/ControlAddIn/styles/productViewer.css';

    HorizontalStretch = true;
    VerticalStretch = true;
    HorizontalShrink = true;
    VerticalShrink = true;
    RequestedHeight = 820;
    MinimumHeight = 520;
    RequestedWidth = 960;
    MinimumWidth = 480;

    event ControlReady();
    procedure SetProductData(JsonData: Text);
}
