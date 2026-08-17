enum 50100 "PIM Translation Status"
{
    Extensible = true;
    Caption = 'PIM Translation Status';

    value(0; "Not Translated")
    {
        Caption = 'Not Translated';
    }
    value(1; Draft)
    {
        Caption = 'Draft';
    }
    value(2; "AI Generated")
    {
        Caption = 'AI Generated';
    }
    value(3; Reviewed)
    {
        Caption = 'Reviewed';
    }
    value(4; Published)
    {
        Caption = 'Published';
    }
}
