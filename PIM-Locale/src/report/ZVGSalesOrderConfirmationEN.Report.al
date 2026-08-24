// Report-only: all text/code dataset columns are Text[250]. Table field lengths are not changed.
report 50120 "ZVG Sales Order Conf. EN"
{
    Caption = 'ZVG Sales Order Confirmation EN';
    EnableHyperlinks = true;
    PreviewMode = PrintLayout;
    DefaultLayout = RDLC;
    RDLCLayout = 'src/report/ZVGSalesOrderConfirmation(EN).rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const(Order));
            RequestFilterFields = "No.", "Sell-to Customer No.", "No. Printed";
            RequestFilterHeading = 'Sales Order';

            column(OrderNo_; OrderNoOut) { }
            column(Document_Date; "Document Date") { }
            column(Order_Date; "Order Date") { }
            column(External_Document_No_; ExternalDocumentNoOut) { }
            column(Quote_No_; QuoteNoOut) { }
            column(Payment_Terms_Code; PaymentTermsCodeOut) { }
            column(Payment_Terms_Description; PaymentTermsDescription) { }
            column(Payment_Method_Code; PaymentMethodCodeOut) { }
            column(Payment_Method_Description; PaymentMethodDescription) { }
            column(Currency_Code; CurrencyCodeOut) { }
            column(Sell_to_Customer_No_; SellToCustomerNoOut) { }
            column(Sell_to_Customer_Name; SellToCustomerNameOut) { }
            column(Ship_to_Address; ShipToAddressOut) { }
            column(Ship_to_Address_2; ShipToAddress2Out) { }
            column(Ship_to_City; ShipToCityOut) { }
            column(Ship_to_Country_Region_Code; ShipToCountryOut) { }
            column(Ship_to_Post_Code; ShipToPostCodeOut) { }
            column(Ship_to_Contact; ShipToContactOut) { }
            column(Ship_to_Phone_No_; ShipToPhoneOut) { }
            column(Bill_to_Customer_No_; BillToCustomerNoOut) { }
            column(Bill_to_Name; BillToNameOut) { }
            column(Bill_to_Address; BillToAddressOut) { }
            column(Bill_to_Address_2; BillToAddress2Out) { }
            column(Bill_to_City; BillToCityOut) { }
            column(Bill_to_Post_Code; BillToPostCodeOut) { }
            column(Bill_to_Country_Region_Code; BillToCountryOut) { }
            column(Bill_to_Contact; BillToContactOut) { }
            column(Prices_Including_VAT; "Prices Including VAT") { }
            column(Amount; Amount) { }
            column(Amount_Including_VAT; "Amount Including VAT") { }
            column(Currency_Symbol; CurrencySymbolOut) { }
            column(OldSaleCustomerNo; OldSaleCustomerNo) { }
            column(OldBillCustomerNo; OldBillCustomerNo) { }

            dataitem("Company Information"; "Company Information")
            {
                DataItemTableView = sorting("Primary Key");
                MaxIteration = 1;

                column(Name; CompanyNameOut) { }
                column(Picture; Picture) { }
                column(CompanyAddress; CompanyAddressOut) { }
                column(CompanyAddress_2; CompanyAddress2Out) { }
                column(CompanyCity; CompanyCityOut) { }
                column(CompanyPost_Code; CompanyPostCodeOut) { }
                column(CompanyPhone_No_; CompanyPhoneOut) { }
                column(CompanyVAT_Registration_No_; CompanyVATRegOut) { }
                column(CompanyVAT_Representative; CompanyVATRepOut) { }
                column(CompanyContact_Person; CompanyContactOut) { }
                column(CompanyHome_Page; CompanyHomePageOut) { }
                column(CompanyE_Mail; CompanyEmailOut) { }
                column(CompanyFax_No_; CompanyFaxOut) { }
                column(CompanyCountry_Region_Code; CompanyCountryOut) { }

                trigger OnAfterGetRecord()
                begin
                    CompanyNameOut := ReportText.LimitTo250(Name);
                    CompanyAddressOut := ReportText.LimitTo250(Address);
                    CompanyAddress2Out := ReportText.LimitTo250("Address 2");
                    CompanyCityOut := ReportText.LimitTo250(City);
                    CompanyPostCodeOut := ReportText.LimitTo250("Post Code");
                    CompanyPhoneOut := ReportText.LimitTo250("Phone No.");
                    CompanyVATRegOut := ReportText.LimitTo250("VAT Registration No.");
                    CompanyVATRepOut := ReportText.LimitTo250("VAT Representative");
                    CompanyContactOut := ReportText.LimitTo250("Contact Person");
                    CompanyHomePageOut := ReportText.LimitTo250("Home Page");
                    CompanyEmailOut := ReportText.LimitTo250("E-Mail");
                    CompanyFaxOut := ReportText.LimitTo250("Fax No.");
                    CompanyCountryOut := ReportText.LimitTo250("Country/Region Code");
                end;
            }
            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLink = "Document No." = field("No."), "Document Type" = field("Document Type");

                column(No_; LineNoOut) { }
                column(Display_Item_No; DisplayItemNoOut) { }
                column(Description; LineDescriptionOut) { }
                column(Variant_Code; VariantCodeOut) { }
                column(Unit_Price; "Unit Price") { }
                column(Unit_of_Measure_Code; UnitOfMeasureOut) { }
                column(Line_Amount; "Line Amount") { }
                column(Quantity; Quantity) { }
                column(Base_Unit_Price_excl_VAT; "Base Unit Price excl VAT") { }
                column(Base_Unit_Price_incl_VAT; "Base Unit Price incl VAT") { }
                column(VAT_Bus__Posting_Group; VATBusPostingGroupOut) { }
                column(VAT_Prod__Posting_Group; VATProdPostingGroupOut) { }
                column(VAT__; "VAT %") { }

                trigger OnAfterGetRecord()
                begin
                    LineNoOut := ReportText.LimitTo250("No.");
                    DisplayItemNoOut := ReportText.LimitTo250(GetDisplayItemNo("No.", "Variant Code"));
                    LineDescriptionOut := ReportText.LimitTo250(Description);
                    VariantCodeOut := ReportText.LimitTo250("Variant Code");
                    UnitOfMeasureOut := ReportText.LimitTo250("Unit of Measure Code");
                    VATBusPostingGroupOut := ReportText.LimitTo250("VAT Bus. Posting Group");
                    VATProdPostingGroupOut := ReportText.LimitTo250("VAT Prod. Posting Group");
                end;
            }

            trigger OnAfterGetRecord()
            var
                PaymentTerms: Record "Payment Terms";
                Customer: Record Customer;
                PaymentMethod: Record "Payment Method";
            begin
                OrderNoOut := ReportText.LimitTo250("No.");
                ExternalDocumentNoOut := ReportText.LimitTo250("External Document No.");
                QuoteNoOut := ReportText.LimitTo250("Quote No.");
                PaymentTermsCodeOut := ReportText.LimitTo250("Payment Terms Code");
                PaymentMethodCodeOut := ReportText.LimitTo250("Payment Method Code");
                CurrencyCodeOut := ReportText.LimitTo250("Currency Code");
                SellToCustomerNoOut := ReportText.LimitTo250("Sell-to Customer No.");
                SellToCustomerNameOut := ReportText.LimitTo250("Sell-to Customer Name");
                ShipToAddressOut := ReportText.LimitTo250("Ship-to Address");
                ShipToAddress2Out := ReportText.LimitTo250("Ship-to Address 2");
                ShipToCityOut := ReportText.LimitTo250("Ship-to City");
                ShipToCountryOut := ReportText.LimitTo250("Ship-to Country/Region Code");
                ShipToPostCodeOut := ReportText.LimitTo250("Ship-to Post Code");
                ShipToContactOut := ReportText.LimitTo250("Ship-to Contact");
                ShipToPhoneOut := ReportText.LimitTo250("Ship-to Phone No.");
                BillToCustomerNoOut := ReportText.LimitTo250("Bill-to Customer No.");
                BillToNameOut := ReportText.LimitTo250("Bill-to Name");
                BillToAddressOut := ReportText.LimitTo250("Bill-to Address");
                BillToAddress2Out := ReportText.LimitTo250("Bill-to Address 2");
                BillToCityOut := ReportText.LimitTo250("Bill-to City");
                BillToPostCodeOut := ReportText.LimitTo250("Bill-to Post Code");
                BillToCountryOut := ReportText.LimitTo250("Bill-to Country/Region Code");
                BillToContactOut := ReportText.LimitTo250("Bill-to Contact");
                CurrencySymbolOut := ReportText.LimitTo250(GetCurrencySymbolValue("Currency Code"));

                OldSaleCustomerNo := '';
                Customer.Reset();
                if Customer.Get("Sales Header"."Sell-to Customer No.") then
                    OldSaleCustomerNo := ReportText.LimitTo250(Customer."Old Customer No.");

                OldBillCustomerNo := '';
                Customer.Reset();
                if Customer.Get("Sales Header"."Bill-to Customer No.") then
                    OldBillCustomerNo := ReportText.LimitTo250(Customer."Old Customer No.");

                PaymentTermsDescription := '';
                if PaymentTerms.Get("Payment Terms Code") then
                    PaymentTermsDescription := ReportText.LimitTo250(PaymentTerms.Description);

                PaymentMethodDescription := '';
                if PaymentMethod.Get("Payment Method Code") then
                    PaymentMethodDescription := ReportText.LimitTo250(PaymentMethod.Description);
            end;
        }
    }

    var
        ReportText: Codeunit "PIM Report Text";
        ItemVariant: Record "Item Variant";
        PaymentTermsDescription: Text[250];
        PaymentMethodDescription: Text[250];
        DisplayItemNo: Code[30];
        OldSaleCustomerNo: Text[250];
        OldBillCustomerNo: Text[250];
        OrderNoOut: Text[250];
        ExternalDocumentNoOut: Text[250];
        QuoteNoOut: Text[250];
        PaymentTermsCodeOut: Text[250];
        PaymentMethodCodeOut: Text[250];
        CurrencyCodeOut: Text[250];
        CurrencySymbolOut: Text[250];
        SellToCustomerNoOut: Text[250];
        SellToCustomerNameOut: Text[250];
        ShipToAddressOut: Text[250];
        ShipToAddress2Out: Text[250];
        ShipToCityOut: Text[250];
        ShipToCountryOut: Text[250];
        ShipToPostCodeOut: Text[250];
        ShipToContactOut: Text[250];
        ShipToPhoneOut: Text[250];
        BillToCustomerNoOut: Text[250];
        BillToNameOut: Text[250];
        BillToAddressOut: Text[250];
        BillToAddress2Out: Text[250];
        BillToCityOut: Text[250];
        BillToPostCodeOut: Text[250];
        BillToCountryOut: Text[250];
        BillToContactOut: Text[250];
        CompanyNameOut: Text[250];
        CompanyAddressOut: Text[250];
        CompanyAddress2Out: Text[250];
        CompanyCityOut: Text[250];
        CompanyPostCodeOut: Text[250];
        CompanyPhoneOut: Text[250];
        CompanyVATRegOut: Text[250];
        CompanyVATRepOut: Text[250];
        CompanyContactOut: Text[250];
        CompanyHomePageOut: Text[250];
        CompanyEmailOut: Text[250];
        CompanyFaxOut: Text[250];
        CompanyCountryOut: Text[250];
        LineNoOut: Text[250];
        DisplayItemNoOut: Text[250];
        LineDescriptionOut: Text[250];
        VariantCodeOut: Text[250];
        UnitOfMeasureOut: Text[250];
        VATBusPostingGroupOut: Text[250];
        VATProdPostingGroupOut: Text[250];

    local procedure GetDisplayItemNo(ItemNo: Code[20]; VariantCode: Code[10]): Code[30]
    var
        MasterSKU: Code[20];
        SKULength: Integer;
    begin
        DisplayItemNo := ItemNo;

        if VariantCode <> '' then
            if ItemVariant.Get(ItemNo, VariantCode) then begin
                MasterSKU := ItemVariant."Master SKU No.";
                SKULength := StrLen(MasterSKU);

                if SKULength > 4 then
                    DisplayItemNo := CopyStr(MasterSKU, 1, SKULength - 4) + '-' + CopyStr(MasterSKU, SKULength - 3, 4)
                else if MasterSKU <> '' then
                    DisplayItemNo := MasterSKU;
            end;

        exit(DisplayItemNo);
    end;

    local procedure GetCurrencySymbolValue(CurrencyCode: Code[10]): Text
    var
        CurrencyRec: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if CurrencyCode <> '' then
            if CurrencyRec.Get(CurrencyCode) then
                exit(CurrencyRec.GetCurrencySymbol());

        if GeneralLedgerSetup.Get() then
            exit(GeneralLedgerSetup.GetCurrencySymbol());

        exit(CurrencyCode);
    end;
}
