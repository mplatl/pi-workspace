report 1070541 "CCS CASH Sales Invoice POS Rct"
{
    // POS0003 28.06.16
    //   Split Invoice / Credit Memo Report
    // POS0007 08.07.16 FS
    // EFSTA2.00  30.11.2016 MK QR Code added
    // POS0025 17.01.17 GT
    //   Added HeaderText for Zero Amount Receipt and PictureStore now in DataItem POS Transaction Header
    // POS0029 07.02.17 FS Field Name Change "Print QR Position" -> EfstaSetup."Picture Print Position"
    // EFSTA2.00  30.11.2016 MK Changed Zero Amount Text
    // EFSTA2.03  07.02.2017 MK Changed Zero Amount Text
    // EFSTA2.05  22.02.2017 MK Added Code to Recreate QR Picture if needed
    // EFSTA2.07  30.03.2017 MK Changes because Printing with no active WebService Setup was not possible
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Rep1070541.CCSCASHSalesInvoicePOSReceipt.rdl';

    Caption = 'Sales Invoice - Cash Receipt';
    Permissions = TableData "Sales Shipment Buffer" = rimd;
    PreviewMode = PrintLayout;
    UsageCategory = None;

    dataset
    {
        dataitem("POS Transaction Header"; "CCS CASH POS Transaction Hdr.")
        {
            column(Name_Store; Store.Name)
            {
            }
            column(Adress_Store; Store.Address)
            {
            }
            column(PostCode_Store; Store."Post Code")
            {
            }
            column(City_Store; Store.City)
            {
            }
            column(Country_Store; Store."Country/Region Code")
            {
            }
            column(PhoneNo_Store; Store."Phone No.")
            {
            }
            column(EMail_Store; Store."E-Mail")
            {
            }
            column(Homepage_Store; Store."Home Page")
            {
            }
            column(PaymentDiscVATCaption2; PaymentDiscVATCaptionLbl2)
            {
            }
            column(StaffID; "Staff ID")
            {
            }
            column(NameOnReceipt; Staff."Name on Receipt")
            {
            }
            column(Pre_Text_Person_In_Charge; PreTextPersonInCharge)
            {
            }
            column(StoreNo_Lbl; StoreNo_Lbl)
            {
            }
            column(TerminalNo_Lbl; TerminalNo_Lbl)
            {
            }
            column(TransNo_Lbl; TransNo_Lbl)
            {
            }
            column(ReceiptNo_Lbl; ReceiptNo_Lbl)
            {
            }
            column(Time_Lbl; Time_Lbl)
            {
            }
            column(StoreNo; "Store No.")
            {
            }
            column(TerminalNo; "POS Terminal No.")
            {
            }
            column(ReceiptNo; "Receipt No.")
            {
            }
            column(Text50011; Text50011)
            {
            }
            column(Text50010; HeaderText)
            {
            }
            column(PostingDate; "Creation Date")
            {
            }
            column(PostingTime; Format("Creation Time", 0, '<Hours24,2><Filler Character,0>:<Minutes,2>'))
            {
            }
            column(Cust_VATNo; Cust."VAT Registration No.")
            {
            }
            column(Cust_VATNo_Lbl; CustVATNo_Lbl)
            {
            }
            column(Sales_Invoice_Header___Bill_to_Customer_No__; "Customer No.")
            {
            }
            column(Sales_Invoice_Header___Bill_to_Customer_No__Caption; CustNo_Lbl)
            {
            }
            column(TransNo; "Transaction No.")
            {
            }
            column(VATRegistrationNo_CompInfo; CompanyInfo."VAT Registration No.")
            {
            }
            column(PrintPaymentText; PrintPaymentText)
            {
            }
            column(PaymentDiscountAmount; PaymentDiscAmount)
            {
            }
            column(PaymentDiscountAmountCaption; PaymentDiscountAmountLbl)
            {
            }
            column(Signature_Pictureleft; tempCASHDocumentInformation."QR Code Left")
            {
            }
            column(Signature_Picturemiddle; tempCASHDocumentInformation."QR Code Middle")
            {
            }
            column(Signature_Pictureright; tempCASHDocumentInformation."QR Code Right")
            {
            }
            column(Signature_Text; tempCASHDocumentInformation."Tag Label")
            {
            }
            column(Signature_MessageText; tempCASHDocumentInformation."Message Text")
            {
            }
            column(Picture_Store; Store.Picture)
            {
            }
            column(LogoPosition; LogoPosition)
            {
            }
            column(TransactionType; "Transaction Type")
            {
            }
            dataitem("Sales Invoice Header"; "Sales Invoice Header")
            {
                //DataItemLink = "No." = FIELD("Receipt No.");
                DataItemLink = "CCS CASH CSL Transaction No." = field("Transaction No."), "CCS CASH CSL Store No." = field("Store No."), "CCS CASH CSL POS Terminal No." = field("POS Terminal No.");
                DataItemTableView = SORTING("No.");
                RequestFilterFields = "No.", "Sell-to Customer No.", "No. Printed";
                RequestFilterHeading = 'Posted Sales Invoice';
                column(No_SalesInvHdr; "No.")
                {
                }
                column(EMailCaption; EMailCaptionLbl)
                {
                }
                column(InvDiscountAmountCaption; InvDiscountAmountCaptionLbl)
                {
                }
                column(VATCaption; VATCaptionLbl)
                {
                }
                column(VATBaseCaption; VATBaseCaptionLbl)
                {
                }
                column(VATAmountCaption; VATAmountCaptionLbl)
                {
                }
                column(VATIdentifierCaption; VATIdentifierCaptionLbl)
                {
                }
                column(TotalCaption; TotalCaptionLbl)
                {
                }
                column(PaymentTermsCaption; PaymentTermsCaptionLbl)
                {
                }
                column(ShipmentMethodCaption; ShipmentMethodCaptionLbl)
                {
                }
                column(DisplayAdditionalFeeNote; GDisplayAdditionalFeeNote)
                {
                }
                column(DocumentDateCaption; DocumentDateCaptionLbl)
                {
                }
                dataitem(CopyLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    dataitem(PageLoop; "Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                        column(Picture1_Store; Store1.Picture)
                        {
                        }
                        column(Picture2_Store; Store2.Picture)
                        {
                        }
                        column(DocumentCaption; StrSubstNo(DocumentCaption(), CopyText))
                        {
                        }
                        column(CustAddr1; CustAddr[1])
                        {
                        }
                        column(CompanyAddr1; CompanyAddr[1])
                        {
                        }
                        column(CustAddr2; CustAddr[2])
                        {
                        }
                        column(CompanyAddr2; CompanyAddr[2])
                        {
                        }
                        column(CustAddr3; CustAddr[3])
                        {
                        }
                        column(CompanyAddr3; CompanyAddr[3])
                        {
                        }
                        column(CustAddr4; CustAddr[4])
                        {
                        }
                        column(CompanyAddr4; CompanyAddr[4])
                        {
                        }
                        column(CustAddr5; CustAddr[5])
                        {
                        }
                        column(CompanyInfoPhoneNo; CompanyInfo."Phone No.")
                        {
                        }
                        column(CustAddr6; CustAddr[6])
                        {
                        }
                        column(CompanyInfoHomePage; CompanyInfo."Home Page")
                        {
                        }
                        column(CompanyInfoEMail; CompanyInfo."E-Mail")
                        {
                        }
                        column(CompanyInfoVATRegNo; CompanyInfo."VAT Registration No.")
                        {
                        }
                        column(CompanyInfoGiroNo; CompanyInfo."Giro No.")
                        {
                        }
                        column(CompanyInfoBankName; CompanyInfo."Bank Name")
                        {
                        }
                        column(CompanyInfoBankAccountNo; CompanyInfo."Bank Account No.")
                        {
                        }
                        column(PaymentTermsDescription; PaymentTerms.Description)
                        {
                        }
                        column(ShipmentMethodDescription; ShipmentMethod.Description)
                        {
                        }
                        column(BillToCustNo_SalesInvHdr; "Sales Invoice Header"."Bill-to Customer No.")
                        {
                        }
                        column(PostingDate_SalesInvHdr; Format("Sales Invoice Header"."Posting Date", 0, 4))
                        {
                        }
                        column(VATNoText; VATNoText)
                        {
                        }
                        column(VATRegNo_SalesInvHeader; "Sales Invoice Header"."VAT Registration No.")
                        {
                        }
                        column(DueDate_SalesInvHeader; Format("Sales Invoice Header"."Due Date", 0, 4))
                        {
                        }
                        column(SalesPersonText; SalesPersonText)
                        {
                        }
                        column(SalesPurchPersonName; SalesPurchPerson.Name)
                        {
                        }
                        column(ReferenceText; ReferenceText)
                        {
                        }
                        column(YourReference_SalesInvHdr; "Sales Invoice Header"."Your Reference")
                        {
                        }
                        column(OrderNoText; OrderNoText)
                        {
                        }
                        column(OrderNo_SalesInvHeader; "Sales Invoice Header"."Order No.")
                        {
                        }
                        column(CustAddr7; CustAddr[7])
                        {
                        }
                        column(CustAddr8; CustAddr[8])
                        {
                        }
                        column(CompanyAddr5; CompanyAddr[5])
                        {
                        }
                        column(CompanyAddr6; CompanyAddr[6])
                        {
                        }
                        column(DocDate_SalesInvoiceHdr; Format("Sales Invoice Header"."Document Date", 0, 4))
                        {
                        }
                        column(PricesInclVAT_SalesInvHdr; "Sales Invoice Header"."Prices Including VAT")
                        {
                        }
                        column(OutputNo; OutputNo)
                        {
                        }
                        column(PricesInclVATYesNo; Format("Sales Invoice Header"."Prices Including VAT"))
                        {
                        }
                        column(PageCaption; PageCaptionCap)
                        {
                        }
                        column(CompanyInfoRegNo; CompanyInfo.GetRegistrationNumber())
                        {
                        }
                        column(PhoneNoCaption; PhoneNoCaptionLbl)
                        {
                        }
                        column(HomePageCaption; HomePageCaptionCap)
                        {
                        }
                        column(VATRegNoCaption; VATRegNoCaptionLbl)
                        {
                        }
                        column(GiroNoCaption; GiroNoCaptionLbl)
                        {
                        }
                        column(BankNameCaption; BankNameCaptionLbl)
                        {
                        }
                        column(BankAccountNoCaption; BankAccountNoCaptionLbl)
                        {
                        }
                        column(DueDateCaption; DueDateCaptionLbl)
                        {
                        }
                        column(InvoiceNoCaption; InvoiceNoCaptionLbl)
                        {
                        }
                        column(PostingDateCaption; PostingDateCaptionLbl)
                        {
                        }
                        column(RegNoCaption; CompanyInfo.GetRegistrationNumberLbl())
                        {
                        }
                        column(BillToCustNo_SalesInvHdrCaption; "Sales Invoice Header".FieldCaption("Bill-to Customer No."))
                        {
                        }
                        column(PricesInclVAT_SalesInvHdrCaption; "Sales Invoice Header".FieldCaption("Prices Including VAT"))
                        {
                        }
                        dataitem(DimensionLoop1; "Integer")
                        {
                            DataItemLinkReference = "Sales Invoice Header";
                            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                            column(DimText; DimText)
                            {
                            }
                            column(Number_Integer; DimensionLoop1.Number)
                            {
                            }
                            column(DimensionsCaption; DimensionsCaptionLbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if Number = 1 then begin
                                    if not DimSetEntry1.FindSet() then
                                        CurrReport.Break();
                                end else
                                    if not Continue then
                                        CurrReport.Break();

                                Clear(DimText);
                                Continue := false;
                                repeat
                                    OldDimText := CopyStr(DimText, 1, MaxStrLen(OldDimText));
#pragma warning disable AA0217
                                    if DimText = '' then
                                        DimText := StrSubstNo('%1 %2', DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code")
                                    else
                                        DimText := CopyStr(StrSubstNo('%1, %2 %3', DimText, DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code"), 1, MaxStrLen(DimText));
#pragma warning restore AA0217
                                    if StrLen(DimText) > MaxStrLen(OldDimText) then begin
                                        DimText := OldDimText;
                                        Continue := true;
                                        exit;
                                    end;
                                until DimSetEntry1.Next() = 0;
                            end;

                            trigger OnPreDataItem()
                            begin
                                if not GShowInternalInfo then
                                    CurrReport.Break();
                            end;
                        }
                        dataitem("Sales Invoice Line"; "Sales Invoice Line")
                        {
                            DataItemLink = "Document No." = FIELD("No.");
                            DataItemLinkReference = "Sales Invoice Header";
                            DataItemTableView = SORTING("Document No.", "Line No.");
                            column(LineAmt_SalesInvoiceLine; "Line Amount" + "Line Discount Amount")
                            {
                                AutoFormatExpression = "Sales Invoice Line".GetCurrencyCode();
                                AutoFormatType = 1;
                            }
                            column(Description_SalesInvLine; Description)
                            {
                            }
                            column(No_SalesInvoiceLine; "No.")
                            {
                            }
                            column(Quantity_SalesInvoiceLine; Quantity)
                            {
                            }
                            column(UOM_SalesInvoiceLine; "Unit of Measure")
                            {
                            }
                            column(UnitPrice_SalesInvLine; "Unit Price")
                            {
                                AutoFormatExpression = "Sales Invoice Line".GetCurrencyCode();
                                AutoFormatType = 2;
                            }
                            column(LineDisc_SalesInvoiceLine; StrSubstNo('%1%', "Line Discount %"))
                            {
                            }
                            column(VATIdent_SalesInvLine; "VAT Identifier")
                            {
                            }
                            column(PostedShipmentDate; Format(PostedShipmentDate))
                            {
                            }
                            column(SalesLineType; Format("Sales Invoice Line".Type))
                            {
                            }
                            column(InvDiscountAmount; -"Inv. Discount Amount")
                            {
                                AutoFormatExpression = "Sales Invoice Line".GetCurrencyCode();
                                AutoFormatType = 1;
                            }
                            column(LineDiscountAmount; -"Line Discount Amount")
                            {
                                AutoFormatExpression = "Sales Invoice Line".GetCurrencyCode();
                                AutoFormatType = 1;
                            }
                            column(TotalSubTotal; TotalSubTotal)
                            {
                                AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(TotalInvoiceDiscountAmt; TotalInvoiceDiscountAmt)
                            {
                                AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(TotalText; TotalText)
                            {
                            }
                            column(Amount_SalesInvoiceLine; Amount)
                            {
                                AutoFormatExpression = "Sales Invoice Line".GetCurrencyCode();
                                AutoFormatType = 1;
                            }
                            column(TotalAmount; TotalAmount)
                            {
                                AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(AmountIncludingVATAmount; "Amount Including VAT" - Amount)
                            {
                                AutoFormatExpression = "Sales Invoice Line".GetCurrencyCode();
                                AutoFormatType = 1;
                            }
                            column(AmtInclVAT_SalesInvLine; "Amount Including VAT")
                            {
                                AutoFormatExpression = "Sales Invoice Line".GetCurrencyCode();
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineVATAmtText; TempVATAmountLine.VATAmountText())
                            {
                            }
                            column(TotalExclVATText; TotalExclVATText)
                            {
                            }
                            column(TotalInclVATText; TotalInclVATText)
                            {
                            }
                            column(TotalAmountInclVAT; TotalAmountInclVAT)
                            {
                                AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(TotalAmountVAT; TotalAmountVAT)
                            {
                                AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATBaseDisc_SalesInvHdr; "Sales Invoice Header"."VAT Base Discount %")
                            {
                                AutoFormatType = 1;
                            }
                            column(TotalPaymentDiscountOnVAT; TotalPaymentDiscountOnVAT)
                            {
                                AutoFormatType = 1;
                            }
                            column(LineNo_SalesInvoiceLine; "Line No.")
                            {
                            }
                            column(UnitPriceCaption; UnitPriceCaptionLbl)
                            {
                            }
                            column(DiscountCaption; DiscountCaptionLbl)
                            {
                            }
                            column(LineDiscountCaption; LineDiscountCaptionLbl)
                            {
                            }
                            column(AmountCaption; AmountCaptionLbl)
                            {
                            }
                            column(PostedShipmentDateCaption; PostedShipmentDateCaptionLbl)
                            {
                            }
                            column(SubtotalCaption; SubtotalCaptionLbl)
                            {
                            }
                            column(PaymentDiscVATCaption; PaymentDiscVATCaptionLbl)
                            {
                            }
                            column(Description_SalesInvLineCaption; FieldCaption(Description))
                            {
                            }
                            column(No_SalesInvoiceLineCaption; FieldCaption("No."))
                            {
                            }
                            column(Quantity_SalesInvoiceLineCaption; Item_Quantity_Lbl)
                            {
                            }
                            column(UOM_SalesInvoiceLineCaption; FieldCaption("Unit of Measure"))
                            {
                            }
                            column(VATIdent_SalesInvLineCaption; FieldCaption("VAT Identifier"))
                            {
                            }
                            dataitem("Sales Shipment Buffer"; "Integer")
                            {
                                DataItemTableView = SORTING(Number);
                                column(SalesShpBufferPostingDate; Format(TempSalesShipmentBuffer."Posting Date"))
                                {
                                }
                                column(SalesShpBufferQuantity; TempSalesShipmentBuffer.Quantity)
                                {
                                    DecimalPlaces = 0 : 5;
                                }
                                column(ShipmentCaption; ShipmentCaptionLbl)
                                {
                                }

                                trigger OnAfterGetRecord()
                                begin
                                    if Number = 1 then
                                        TempSalesShipmentBuffer.Find('-')
                                    else
                                        TempSalesShipmentBuffer.Next();
                                end;

                                trigger OnPreDataItem()
                                begin
                                    TempSalesShipmentBuffer.SetRange("Document No.", "Sales Invoice Line"."Document No.");
                                    TempSalesShipmentBuffer.SetRange("Line No.", "Sales Invoice Line"."Line No.");

                                    SetRange(Number, 1, TempSalesShipmentBuffer.Count);
                                end;
                            }
                            dataitem(DimensionLoop2; "Integer")
                            {
                                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                                column(DimText_DimensionLoop2; DimText)
                                {
                                }
                                column(LineDimensionsCaption; LineDimensionsCaptionLbl)
                                {
                                }

                                trigger OnAfterGetRecord()
                                begin
                                    if Number = 1 then begin
                                        if not DimSetEntry2.FindSet() then
                                            CurrReport.Break();
                                    end else
                                        if not Continue then
                                            CurrReport.Break();

                                    Clear(DimText);
                                    Continue := false;
                                    repeat
                                        OldDimText := CopyStr(DimText, 1, MaxStrLen(OldDimText));
#pragma warning disable AA0217
                                        if DimText = '' then
                                            DimText := StrSubstNo('%1 %2', DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code")
                                        else
                                            DimText :=
                                              CopyStr(StrSubstNo(
                                                '%1, %2 %3', DimText,
                                                DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code"), 1, MaxStrLen(DimText));
#pragma warning restore AA0217
                                        if StrLen(DimText) > MaxStrLen(OldDimText) then begin
                                            DimText := OldDimText;
                                            Continue := true;
                                            exit;
                                        end;
                                    until DimSetEntry2.Next() = 0;
                                end;

                                trigger OnPreDataItem()
                                begin
                                    if not GShowInternalInfo then
                                        CurrReport.Break();

                                    DimSetEntry2.SetRange("Dimension Set ID", "Sales Invoice Line"."Dimension Set ID");
                                end;
                            }
                            dataitem(AsmLoop; "Integer")
                            {
                                column(TempPostedAsmLineUOMCode; GetUOMText(TempPostedAsmLine."Unit of Measure Code"))
                                {
                                    //DecimalPlaces = 0 : 5;
                                }
                                column(TempPostedAsmLineQuantity; TempPostedAsmLine.Quantity)
                                {
                                    DecimalPlaces = 0 : 5;
                                }
                                column(TempPostedAsmLineVariantCode; BlanksForIndent() + TempPostedAsmLine."Variant Code")
                                {
                                    //DecimalPlaces = 0 : 5;
                                }
                                column(TempPostedAsmLineDesc; BlanksForIndent() + TempPostedAsmLine.Description)
                                {
                                }
                                column(TempPostedAsmLineNo; BlanksForIndent() + TempPostedAsmLine."No.")
                                {
                                }

                                trigger OnAfterGetRecord()
                                var
                                    ItemTranslation: Record "Item Translation";
                                begin
                                    if Number = 1 then
                                        TempPostedAsmLine.FindSet()
                                    else
                                        TempPostedAsmLine.Next();

                                    if ItemTranslation.Get(TempPostedAsmLine."No.",
                                         TempPostedAsmLine."Variant Code",
                                         "Sales Invoice Header"."Language Code")
                                    then
                                        TempPostedAsmLine.Description := ItemTranslation.Description;
                                end;

                                trigger OnPreDataItem()
                                begin
                                    Clear(TempPostedAsmLine);
                                    if not DisplayAssemblyInformation then
                                        CurrReport.Break();
                                    CollectAsmInformation();
                                    Clear(TempPostedAsmLine);
                                    SetRange(Number, 1, TempPostedAsmLine.Count);
                                end;
                            }

                            trigger OnAfterGetRecord()
                            begin
                                PostedShipmentDate := 0D;
                                if Quantity <> 0 then
                                    PostedShipmentDate := FindPostedShipmentDate();

                                if (Type = Type::"G/L Account") and (not GShowInternalInfo) then
                                    "No." := '';

                                TempVATAmountLine.Init();
                                TempVATAmountLine."VAT Identifier" := "VAT Identifier";
                                TempVATAmountLine."VAT Calculation Type" := "VAT Calculation Type";
                                TempVATAmountLine."Tax Group Code" := "Tax Group Code";
                                TempVATAmountLine."VAT %" := "VAT %";
                                TempVATAmountLine."VAT Base" := Amount;
                                TempVATAmountLine."Amount Including VAT" := "Amount Including VAT";
                                TempVATAmountLine."Line Amount" := "Line Amount";
                                if "Allow Invoice Disc." then
                                    TempVATAmountLine."Inv. Disc. Base Amount" := "Line Amount";
                                TempVATAmountLine."Invoice Discount Amount" := "Inv. Discount Amount";
                                TempVATAmountLine."VAT Clause Code" := "VAT Clause Code";
                                TempVATAmountLine.InsertLine();

                                TotalSubTotal += "Line Amount";
                                TotalInvoiceDiscountAmt -= "Inv. Discount Amount";
                                TotalAmount += Amount;
                                TotalAmountVAT += "Amount Including VAT" - Amount;
                                TotalAmountInclVAT += "Amount Including VAT";
                                TotalPaymentDiscountOnVAT += -("Line Amount" - "Inv. Discount Amount" - "Amount Including VAT");
                            end;

                            trigger OnPreDataItem()
                            begin
                                TempVATAmountLine.DeleteAll();
                                TempSalesShipmentBuffer.Reset();
                                TempSalesShipmentBuffer.DeleteAll();
                                FirstValueEntryNo := 0;
                                MoreLines := Find('+');
                                while MoreLines and (Description = '') and ("No." = '') and (Quantity = 0) and (Amount = 0) do
                                    MoreLines := Next(-1) <> 0;
                                if not MoreLines then
                                    CurrReport.Break();
                                SetRange("Line No.", 0, "Line No.");

                                if not CCSCashSalesSetup."PMT. Meth. in Descr. of Rct." then begin
                                    SetRange("CCS CASH CSL PaymentText", false)
                                end;

                                // CurrReport.CreateTotals("Line Amount", Amount, "Amount Including VAT", "Inv. Discount Amount");
                            end;
                        }
                        dataitem(VATCounter; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            column(VATAmountLineVATBase; TempVATAmountLine."VAT Base")
                            {
                                AutoFormatExpression = "Sales Invoice Line".GetCurrencyCode();
                                AutoFormatType = 1;
                            }
                            column(VATAmountLineVATAmount; TempVATAmountLine."VAT Amount")
                            {
                                AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmountLineLineAmount; TempVATAmountLine."Line Amount")
                            {
                                AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineInvDiscBaseAmt; TempVATAmountLine."Inv. Disc. Base Amount")
                            {
                                AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineInvDiscountAmt; TempVATAmountLine."Invoice Discount Amount")
                            {
                                AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmountLineVAT; TempVATAmountLine."VAT %")
                            {
                                DecimalPlaces = 0 : 5;
                            }
                            column(VATAmtLineVATIdentifier; TempVATAmountLine."VAT Identifier")
                            {
                            }
                            column(VATAmntSpecificCaption; VATAmntSpecificCaptionLbl)
                            {
                            }
                            column(InvDiscBaseAmtCaption; InvDiscBaseAmtCaptionLbl)
                            {
                            }
                            column(LineAmountCaption; LineAmountCaptionLbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                TempVATAmountLine.GetLine(Number);
                            end;

                            trigger OnPreDataItem()
                            begin
                                TempVATAmountLine.VATAmountText();

                                if TempVATAmountLine.GetTotalVATAmount() = 0 then
                                    CurrReport.Break();

                                if TempVATAmountLine.Count < 2 then
                                    CurrReport.Break();

                                SetRange(Number, 1, TempVATAmountLine.Count);
                                // CurrReport.CreateTotals(
                                //   VATAmountLine."Line Amount", VATAmountLine."Inv. Disc. Base Amount",
                                //   VATAmountLine."Invoice Discount Amount", VATAmountLine."VAT Base", VATAmountLine."VAT Amount");
                            end;
                        }
                        dataitem(VATClauseEntryCounter; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            column(VATClauseVATIdentifier; TempVATAmountLine."VAT Identifier")
                            {
                            }
                            column(VATClauseCode; TempVATAmountLine."VAT Clause Code")
                            {
                            }
                            column(VATClauseDescription; VATClause.Description)
                            {
                            }
                            column(VATClauseDescription2; VATClause."Description 2")
                            {
                            }
                            column(VATClauseAmount; TempVATAmountLine."VAT Amount")
                            {
                                AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATClausesCaption; VATClausesCap)
                            {
                            }
                            column(VATClauseVATIdentifierCaption; VATIdentifierCaptionLbl)
                            {
                            }
                            column(VATClauseVATAmtCaption; VATAmountCaptionLbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                TempVATAmountLine.GetLine(Number);
                                if not VATClause.Get(TempVATAmountLine."VAT Clause Code") then
                                    CurrReport.Skip();
                                VATClause.TranslateDescription("Sales Invoice Header"."Language Code");
                            end;

                            trigger OnPreDataItem()
                            begin
                                Clear(VATClause);
                                SetRange(Number, 1, TempVATAmountLine.Count);
                                // CurrReport.CreateTotals(VATAmountLine."VAT Amount");
                            end;
                        }
                        dataitem(VatCounterLCY; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            column(VALSpecLCYHeader; VALSpecLCYHeader)
                            {
                            }
                            column(VALExchRate; VALExchRate)
                            {
                            }
                            column(VALVATBaseLCY; VALVATBaseLCY)
                            {
                                AutoFormatType = 1;
                            }
                            column(VALVATAmountLCY; VALVATAmountLCY)
                            {
                                AutoFormatType = 1;
                            }
                            column(VATAmountLineVAT_VatCounterLCY; TempVATAmountLine."VAT %")
                            {
                                DecimalPlaces = 0 : 5;
                            }
                            column(VATAmtLineVATIdentifier_VatCounterLCY; TempVATAmountLine."VAT Identifier")
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                TempVATAmountLine.GetLine(Number);
                                VALVATBaseLCY :=
                                  TempVATAmountLine.GetBaseLCY(
                                    "Sales Invoice Header"."Posting Date", "Sales Invoice Header"."Currency Code",
                                    "Sales Invoice Header"."Currency Factor");
                                VALVATAmountLCY :=
                                  TempVATAmountLine.GetAmountLCY(
                                    "Sales Invoice Header"."Posting Date", "Sales Invoice Header"."Currency Code",
                                    "Sales Invoice Header"."Currency Factor");
                            end;

                            trigger OnPreDataItem()
                            begin
                                if (not GLSetup."Print VAT specification in LCY") or
                                   ("Sales Invoice Header"."Currency Code" = '')
                                then
                                    CurrReport.Break();

                                SetRange(Number, 1, TempVATAmountLine.Count);
                                // CurrReport.CreateTotals(VALVATBaseLCY, VALVATAmountLCY);

                                if GLSetup."LCY Code" = '' then
                                    VALSpecLCYHeader := Text007 + Text008
                                else
                                    VALSpecLCYHeader := Text007 + Format(GLSetup."LCY Code");

                                CurrExchRate.FindCurrency("Sales Invoice Header"."Posting Date", "Sales Invoice Header"."Currency Code", 1);
                                CalculatedExchRate := Round(1 / "Sales Invoice Header"."Currency Factor" * CurrExchRate."Exchange Rate Amount", 0.000001);
                                VALExchRate := StrSubstNo(Text009, CalculatedExchRate, CurrExchRate."Exchange Rate Amount");
                            end;
                        }
                        dataitem(Total; "Integer")
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                        }
                        dataitem(Total2; "Integer")
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                            column(SellToCustNo_SalesInvHdr; "Sales Invoice Header"."Sell-to Customer No.")
                            {
                            }
                            column(ShipToAddr1; ShipToAddr[1])
                            {
                            }
                            column(ShipToAddr2; ShipToAddr[2])
                            {
                            }
                            column(ShipToAddr3; ShipToAddr[3])
                            {
                            }
                            column(ShipToAddr4; ShipToAddr[4])
                            {
                            }
                            column(ShipToAddr5; ShipToAddr[5])
                            {
                            }
                            column(ShipToAddr6; ShipToAddr[6])
                            {
                            }
                            column(ShipToAddr7; ShipToAddr[7])
                            {
                            }
                            column(ShipToAddr8; ShipToAddr[8])
                            {
                            }
                            column(ShipToAddressCaption; ShipToAddressCaptionLbl)
                            {
                            }
                            column(SellToCustNo_SalesInvHdrCaption; "Sales Invoice Header".FieldCaption("Sell-to Customer No."))
                            {
                            }

                            trigger OnPreDataItem()
                            begin
                                CurrReport.Break();
                            end;
                        }
                        dataitem(LineFee; "Integer")
                        {
                            DataItemTableView = SORTING(Number) ORDER(Ascending) WHERE(Number = FILTER(1 ..));
                            column(LineFeeCaptionLbl; TempLineFeeNoteOnReportHist.ReportText)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if not GDisplayAdditionalFeeNote then
                                    CurrReport.Break();

                                if Number = 1 then begin
                                    if not TempLineFeeNoteOnReportHist.FindSet() then
                                        CurrReport.Break()
                                end else
                                    if TempLineFeeNoteOnReportHist.Next() = 0 then
                                        CurrReport.Break();
                            end;
                        }
                        dataitem("Trans. Payment Entry"; "CCS CASH Trans. Payment Entry")
                        {
                            DataItemLink = "Transaction No." = FIELD("Transaction No."), "Store No." = FIELD("Store No."), "POS Terminal No." = FIELD("POS Terminal No.");
                            DataItemLinkReference = "POS Transaction Header";
                            DataItemTableView = SORTING("Store No.", "POS Terminal No.", "Transaction No.", "Line No.");
                            column(TP_LineNo; "Line No.")
                            {
                            }
                            column(TP_TransactionType; "Tender Type")
                            {
                            }
                            column(TP_Amount; Amount)
                            {
                            }
                            column(TP_Description; TenderDescription)
                            {
                            }
                            column(TP_TenderLbl; Tender_Lbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            var
                                Tendertype: Record "CCS CASH Store Tender Type";
                            begin
                                Clear(TenderDescription);
                                TenderDescription := "Tender Description";
                                if "POS Transaction Header"."Transaction Type" = "POS Transaction Header"."Transaction Type"::Return then
                                    Amount := -Amount;

                                if Tendertype.Get("Store No.", "Tender Type") then
                                    case Tendertype.TenderFunction of
                                        Tendertype.TenderFunction::Card:
                                            if TenderTypeCardSetup.Get("POS Transaction Header"."Store No.", "Tender Type", "Card No.") then
                                                TenderDescription := TenderTypeCardSetup.Description;
                                        Tendertype.TenderFunction::Voucher:
                                            TenderDescription := CopyStr(TenderDescription + ' ' + "Card No.", 1, MaxStrLen(TenderDescription));
                                    end;
                            end;
                        }
                        dataitem(AfterText; "Extended Text Line")
                        {
                            DataItemTableView = SORTING("Table Name", "No.", "Language Code", "Text No.", "Line No.") ORDER(Ascending);
                            column(Text_AfterText; Text)
                            {
                            }

                            trigger OnPreDataItem()
                            var
                                locStore: Record "CCS CASH Store";
                            begin
                                if locStore.Get("POS Transaction Header"."Store No.") then
                                    if locStore."Aftertext Invoice" <> '' then
                                        SetRange("No.", locStore."Aftertext Invoice")
                                    else
                                        CurrReport.Break();
                            end;
                        }
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Number > 1 then begin
                            CopyText := Text003;
                            OutputNo += 1;
                        end;
                        // CurrReport.PageNo := 1;

                        TotalSubTotal := 0;
                        TotalInvoiceDiscountAmt := 0;
                        TotalAmount := 0;
                        TotalAmountVAT := 0;
                        TotalAmountInclVAT := 0;
                        TotalPaymentDiscountOnVAT := 0;
                    end;

                    trigger OnPostDataItem()
                    begin
                        if not CurrReport.Preview then
                            SalesInvCountPrinted.Run("Sales Invoice Header");
                    end;

                    trigger OnPreDataItem()
                    begin
                        NoOfLoops := Abs(GNoOfCopies) + Cust."Invoice Copies" + 1;
                        if NoOfLoops <= 0 then
                            NoOfLoops := 1;
                        CopyText := '';
                        SetRange(Number, 1, NoOfLoops);
                        OutputNo := 1;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    CurrReport.Language := CodeunitLanguage.GetLanguageIdOrDefault("Language Code");

                    if RespCenter.Get("Responsibility Center") then begin
                        FormatAddr.RespCenter(CompanyAddr, RespCenter);
                        CompanyInfo."Phone No." := RespCenter."Phone No.";
                        CompanyInfo."Fax No." := RespCenter."Fax No.";
                    end else begin
                        FormatAddr.Company(CompanyAddr, CompanyInfo);
                    end;

                    DimSetEntry1.SetRange("Dimension Set ID", "Dimension Set ID");

                    if "Order No." = '' then
                        OrderNoText := ''
                    else
                        OrderNoText := CopyStr(FieldCaption("Order No."), 1, MaxStrLen(OrderNoText));
                    if "Salesperson Code" = '' then begin
                        SalesPurchPerson.Init();
                        SalesPersonText := '';
                    end else begin
                        SalesPurchPerson.Get("Salesperson Code");
                        SalesPersonText := Text000;
                    end;
                    if "Your Reference" = '' then
                        ReferenceText := ''
                    else
                        ReferenceText := CopyStr(FieldCaption("Your Reference"), 1, MaxStrLen(ReferenceText));
                    if "VAT Registration No." = '' then
                        VATNoText := ''
                    else
                        VATNoText := CopyStr(FieldCaption("VAT Registration No."), 1, MaxStrLen(VATNoText));
                    if "Currency Code" = '' then begin
                        GLSetup.TestField("LCY Code");
                        TotalText := StrSubstNo(Text001, GLSetup."LCY Code");
                        TotalInclVATText := StrSubstNo(Text002, GLSetup."LCY Code");
                        TotalExclVATText := StrSubstNo(Text006, GLSetup."LCY Code");
                    end else begin
                        TotalText := StrSubstNo(Text001, "Currency Code");
                        TotalInclVATText := StrSubstNo(Text002, "Currency Code");
                        TotalExclVATText := StrSubstNo(Text006, "Currency Code");
                    end;
                    FormatAddr.SalesInvSellTo(CustAddr, "Sales Invoice Header");
                    if not Cust.Get("Bill-to Customer No.") then
                        Clear(Cust);

                    if "Payment Terms Code" = '' then
                        PaymentTerms.Init()
                    else begin
                        PaymentTerms.Get("Payment Terms Code");
                        PaymentTerms.TranslateDescription(PaymentTerms, "Language Code");
                    end;
                    if "Shipment Method Code" = '' then
                        ShipmentMethod.Init()
                    else begin
                        ShipmentMethod.Get("Shipment Method Code");
                        ShipmentMethod.TranslateDescription(ShipmentMethod, "Language Code");
                    end;
                    FormatAddr.SalesInvShipTo(ShipToAddr, CustAddr, "Sales Invoice Header");

                    GetLineFeeNoteOnReportHist("No.");

                    if GLogInteraction then
                        if not CurrReport.Preview then begin
                            if "Bill-to Contact No." <> '' then
                                SegManagement.LogDocument(
                                  4, "No.", 0, 0, DATABASE::Contact, "Bill-to Contact No.", "Salesperson Code",
                                  "Campaign No.", "Posting Description", '')
                            else
                                SegManagement.LogDocument(
                                  4, "No.", 0, 0, DATABASE::Customer, "Bill-to Customer No.", "Salesperson Code",
                                  "Campaign No.", "Posting Description", '');
                        end;
                end;
            }

            trigger OnAfterGetRecord()
            // >> AL-Umstellung
            var
                PosRegFunc: Codeunit "CCS CASH POS Register Func";
            // << AL-Umstellung            
            begin
                Clear(HeaderText);
                if "Transaction Type" = "Transaction Type"::Return then begin
                    HeaderText := Text50012;
                end else begin
                    HeaderText := Text50010;
                end;
                if "Transaction Type" = "Transaction Type"::Zero then
                    // ++ EFSTA2.03
                    case "Zero Receipt Type" of
                        "POS Transaction Header"."Zero Receipt Type"::ZeroReceipt:
                            // -- EFSTA2.03
                            HeaderText := txtReceiptZeroAmount;
                        // ++ EFSTA2.03
                        "POS Transaction Header"."Zero Receipt Type"::MonthlyReceipt:
                            HeaderText := txtReceiptMonthly;
                        "POS Transaction Header"."Zero Receipt Type"::StartReceipt:
                            HeaderText := txtReceiptStart;
                        "POS Transaction Header"."Zero Receipt Type"::StopReceipt:
                            HeaderText := txtReceiptEnd;
                    end;
                // -- EFSTA2.03

                if Store.Get("POS Transaction Header"."Store No.") then
                    if Store."Logo Position on Documents" <> Store."Logo Position on Documents"::"No Logo" then
                        Store.CalcFields(Picture);
                LogoPosition := Store."Logo Position on Documents";

                Staff.SetLoadFields("Name on Receipt");
                if not Staff.Get("POS Transaction Header"."Staff ID") then
                    Staff."Name on Receipt" := "POS Transaction Header"."Staff ID";
                if Staff."Name on Receipt" = '' then
                    Staff."Name on Receipt" := "POS Transaction Header"."Staff ID";

                Clear(PreTextPersonInCharge);
                if Store."Pre-Text Person in Charge" <> '' then
                    PreTextPersonInCharge := Store."Pre-Text Person in Charge" + Staff."Name on Receipt";

                if "Payment Discount %" <> 0 then begin
                    CalcFields("Amount incl. VAT");
                    PaymentDiscAmount := "Amount incl. VAT" * "Payment Discount %" / 100;
                    PrintPaymentText := true;
                end else begin
                    Clear(PaymentDiscAmount);
                    PrintPaymentText := false;
                end;

                // >> AL-Umstellung
                PosRegFunc.GetDocumentQRCode("Store No.", "POS Terminal No.", "Transaction No.", tempCASHDocumentInformation);
                // // ++ EFSTA2.00
                // if not EfstaSetup.Get("Store No.", "POS Terminal No.") then
                //     if EfstaSetup.Get("Store No.", '') then;
                // if EfstaSetup."Store No." <> '' then begin
                //     EfstaLog.SetRange("Store No.", "Store No.");
                //     EfstaLog.SetRange("POS Terminal No.", "POS Terminal No.");
                //     EfstaLog.SetRange("Transaction No.", "Transaction No.");
                //     if EfstaLog.FindLast() then begin
                //         // ++ EFSTA2.05
                //         // ++ EFSTA2.07
                //         //EFSTAWebService.GetQRCode(EfstaLog);
                //         EFSTAWebService.GetQRCode(EfstaLog, EFSTAMessageText);
                //         // -- EFSTA2.07
                //         // -- EFSTA2.05
                //         EfstaLog.CalcFields("QR Picture");
                //         EfstaLog.CalcFields("QR Picture Resized");
                //     end;
                //     case EfstaSetup."Picture Print Position" of
                //         EfstaSetup."Picture Print Position"::Left:
                //             begin
                //                 if EfstaSetup."Picture Print Option" = EfstaSetup."Picture Print Option"::Original then
                //                     EfstaLogLeft."QR Picture" := EfstaLog."QR Picture"
                //                 else
                //                     EfstaLogLeft."QR Picture" := EfstaLog."QR Picture Resized"
                //             end;
                //         EfstaSetup."Picture Print Position"::Middle:
                //             begin
                //                 if EfstaSetup."Picture Print Option" = EfstaSetup."Picture Print Option"::Original then
                //                     EfstaLogMiddle."QR Picture" := EfstaLog."QR Picture"
                //                 else
                //                     EfstaLogMiddle."QR Picture" := EfstaLog."QR Picture Resized"
                //             end;
                //         EfstaSetup."Picture Print Position"::Right:
                //             begin
                //                 if EfstaSetup."Picture Print Option" = EfstaSetup."Picture Print Option"::Original then
                //                     EfstaLogRight."QR Picture" := EfstaLog."QR Picture"
                //                 else
                //                     EfstaLogRight."QR Picture" := EfstaLog."QR Picture Resized"
                //             end;
                //     end;
                // end;
                // // -- EFSTA2.00
                // << AL-Umstellung
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NoOfCopies; GNoOfCopies)
                    {
                        Caption = 'No. of Copies';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the No. of Copies field.';
                    }
                    field(ShowInternalInfo; GShowInternalInfo)
                    {
                        Caption = 'Show Internal Information';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Internal Information field.';
                    }
                    field(LogInteraction; GLogInteraction)
                    {
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Log Interaction field.';
                    }
                    field(DisplayAsmInformation; DisplayAssemblyInformation)
                    {
                        Caption = 'Show Assembly Components';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Assembly Components field.';
                    }
                    field(DisplayAdditionalFeeNote; GDisplayAdditionalFeeNote)
                    {
                        Caption = 'Show Additional Fee Note';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Additional Fee Note field.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            LogInteractionEnable := true;
        end;

        trigger OnOpenPage()
        begin
            InitLogInteraction();
            LogInteractionEnable := GLogInteraction;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        GLSetup.Get();
        CompanyInfo.Get();
        SalesSetup.Get();
        CompanyInfo.VerifyAndSetPaymentInfo();
        CCSCashSalesSetup.Get();
        GNoOfCopies := CCSCashSalesSetup."Cash Receipt Invoice Copies";
        /*CASE SalesSetup."Logo Position on Documents" OF
          SalesSetup."Logo Position on Documents"::Left:
            BEGIN
              CompanyInfo3.Get();
              CompanyInfo3.CALCFIELDS(Picture);
            END;
          SalesSetup."Logo Position on Documents"::Center:
            BEGIN
              CompanyInfo1.Get();
              CompanyInfo1.CALCFIELDS(Picture);
            END;
          SalesSetup."Logo Position on Documents"::Right:
            BEGIN
              CompanyInfo2.Get();
              CompanyInfo2.CALCFIELDS(Picture);
            END;
        END;
        */

    end;

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            InitLogInteraction();
    end;

    protected var
        HeaderText: Text[50];

    var
        Text000: Label 'Salesperson';
        Text001: Label 'Total %1', Comment = '%1=Value 1';
        Text002: Label 'Total %1 Incl. VAT', Comment = '%1=Value 1';
        Text003: Label ' COPY';
        Text004: Label 'Sales - Invoice%1', Comment = '%1=Value 1';
        PageCaptionCap: Label 'Page %1 of %2', Comment = '%1=Value 1,%2=Value 2';
        Text006: Label 'Total %1 Excl. VAT', Comment = '%1=Value 1';
        GLSetup: Record "General Ledger Setup";
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        CompanyInfo: Record "Company Information";
        SalesSetup: Record "Sales & Receivables Setup";
        Cust: Record Customer;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        RespCenter: Record "Responsibility Center";
        CodeunitLanguage: Codeunit Language;
        CurrExchRate: Record "Currency Exchange Rate";
        TempPostedAsmLine: Record "Posted Assembly Line" temporary;
        VATClause: Record "VAT Clause";
        TempLineFeeNoteOnReportHist: Record "Line Fee Note on Report Hist." temporary;
        SalesInvCountPrinted: Codeunit "Sales Inv.-Printed";
        FormatAddr: Codeunit "Format Address";
        SegManagement: Codeunit SegManagement;
        TempSalesShipmentBuffer: Record "Sales Shipment Buffer" temporary;
        PostedShipmentDate: Date;
        CustAddr: array[8] of Text[50];
        ShipToAddr: array[8] of Text[50];
        CompanyAddr: array[8] of Text[50];
        OrderNoText: Text[80];
        SalesPersonText: Text[30];
        VATNoText: Text[80];
        ReferenceText: Text[80];
        TotalText: Text[50];
        TotalExclVATText: Text[50];
        TotalInclVATText: Text[50];
        MoreLines: Boolean;
        CCSCashSalesSetup: Record "CCS CASH Cash Sales Setup";
        GNoOfCopies: Integer;
        NoOfLoops: Integer;
        CopyText: Text[30];
        NextEntryNo: Integer;
        FirstValueEntryNo: Integer;
        DimText: Text[120];
        OldDimText: Text[75];
        GShowInternalInfo: Boolean;
        Continue: Boolean;
        GLogInteraction: Boolean;
        VALVATBaseLCY: Decimal;
        VALVATAmountLCY: Decimal;
        VALSpecLCYHeader: Text[80];
        Text007: Label 'VAT Amount Specification in ';
        Text008: Label 'Local Currency';
        VALExchRate: Text[50];
        Text009: Label 'Exchange rate: %1/%2', Comment = '%1=Value 1,%2=Value 2';
        CalculatedExchRate: Decimal;
        Text010: Label 'Sales - Prepayment Invoice %1', Comment = '%1=Value 1';
        OutputNo: Integer;
        TotalSubTotal: Decimal;
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalAmountVAT: Decimal;
        TotalInvoiceDiscountAmt: Decimal;
        TotalPaymentDiscountOnVAT: Decimal;
        LogInteractionEnable: Boolean;
        DisplayAssemblyInformation: Boolean;
        PhoneNoCaptionLbl: Label 'Phone No.';
        HomePageCaptionCap: Label 'Home Page';
        VATRegNoCaptionLbl: Label 'VAT Registration No.';
        GiroNoCaptionLbl: Label 'Giro No.';
        BankNameCaptionLbl: Label 'Bank';
        BankAccountNoCaptionLbl: Label 'Account No.';
        DueDateCaptionLbl: Label 'Due Date';
        InvoiceNoCaptionLbl: Label 'Invoice No.';
        PostingDateCaptionLbl: Label 'Posting Date';
        DimensionsCaptionLbl: Label 'Header Dimensions';
        UnitPriceCaptionLbl: Label 'Unit Price';
        DiscountCaptionLbl: Label 'Discount %';
        LineDiscountCaptionLbl: Label 'Line Discount';
        AmountCaptionLbl: Label 'Amount';
        VATClausesCap: Label 'VAT Clause';
        PostedShipmentDateCaptionLbl: Label 'Posted Shipment Date';
        SubtotalCaptionLbl: Label 'Subtotal';
        PaymentDiscVATCaptionLbl: Label 'Payment Discount on VAT';
        ShipmentCaptionLbl: Label 'Shipment';
        LineDimensionsCaptionLbl: Label 'Line Dimensions';
        VATAmntSpecificCaptionLbl: Label 'VAT Amount Specification';
        InvDiscBaseAmtCaptionLbl: Label 'Invoice Discount Base Amount';
        LineAmountCaptionLbl: Label 'Line Amount';
        ShipToAddressCaptionLbl: Label 'Ship-to Address';
        EMailCaptionLbl: Label 'E-Mail';
        InvDiscountAmountCaptionLbl: Label 'Invoice Discount Amount';
        VATCaptionLbl: Label 'VAT %';
        VATBaseCaptionLbl: Label 'VAT Base';
        VATAmountCaptionLbl: Label 'VAT Amount';
        VATIdentifierCaptionLbl: Label 'VAT Identifier';
        TotalCaptionLbl: Label 'Total';
        PaymentTermsCaptionLbl: Label 'Payment Terms';
        ShipmentMethodCaptionLbl: Label 'Shipment Method';
        DocumentDateCaptionLbl: Label 'Document Date';
        GDisplayAdditionalFeeNote: Boolean;
        TenderDescription: Text[50];
        TenderTypeCardSetup: Record "CCS CASH Tender Type C. Setup";
        Tender_Lbl: Label 'Payments:';
        StoreNo_Lbl: Label 'Store:';
        TerminalNo_Lbl: Label 'POS:';
        TransNo_Lbl: Label 'Transaction:';
        ReceiptNo_Lbl: Label 'Receipt No.:';
        Time_Lbl: Label 'Date/Time:';
        CustVATNo_Lbl: Label 'VAT Registration No.:';
        Text50011: Label 'Cashier:';
        Text50010: Label 'Invoice';
        Text50012: Label 'Equalisation Levy';
        PaymentDiscVATCaptionLbl2: Label 'Payment Discount calculated.';
        Staff: Record "CCS CASH Staff";
        LogoPosition: Enum "CCS CASH Logo Position on Doc.";
        PreTextPersonInCharge: Text;
        Store: Record "CCS CASH Store";
        Store1: Record "CCS CASH Store";
        Store2: Record "CCS CASH Store";
        CustNo_Lbl: Label 'Customer No.:';
        PrintPaymentText: Boolean;
        Item_Quantity_Lbl: Label 'Qty.';
        PaymentDiscAmount: Decimal;
        PaymentDiscountAmountLbl: Label 'Payment Discount';
        // >> AL-Umstellung          
        // "<EFSTA>": Integer;
        // EfstaLog: Record "Sign. Service Request Log";
        // EfstaSetup: Record "Sign. Service Setup";
        // EfstaLogLeft: Record "Sign. Service Request Log";
        // EfstaLogMiddle: Record "Sign. Service Request Log";
        // EfstaLogRight: Record "Sign. Service Request Log";
        // Text50013: Label 'Zero Amount Receipt';
        // EFSTA002: Label 'Monthly Receipt';
        // EFSTA003: Label 'Start Receipt';
        // EFSTA004: Label 'Stop Receipt';
        // EFSTAWebService: Codeunit "POS Register Web Service EFSTA";
        // EFSTAMessageText: Text;
        tempCASHDocumentInformation: Record "CCS CASH Document Information" temporary;
        txtReceiptZeroAmount: Label 'Zero Amount Receipt';
        txtReceiptMonthly: Label 'Monthly Receipt';
        txtReceiptStart: Label 'Start Receipt';
        txtReceiptEnd: Label 'Stop Receipt';
    // << AL-Umstellung        

    local procedure InitLogInteraction()
    begin
        GLogInteraction := SegManagement.FindInteractionTemplateCode(Enum::"Interaction Log Entry Document Type"::"Sales Inv.") <> '';
    end;

    local procedure FindPostedShipmentDate(): Date
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        TempSalesShipmentBuffer2: Record "Sales Shipment Buffer" temporary;
    begin
        NextEntryNo := 1;
        if "Sales Invoice Line"."Shipment No." <> '' then
            if SalesShipmentHeader.Get("Sales Invoice Line"."Shipment No.") then
                exit(SalesShipmentHeader."Posting Date");

        if "Sales Invoice Header"."Order No." = '' then
            exit("Sales Invoice Header"."Posting Date");

        case "Sales Invoice Line".Type of
            "Sales Invoice Line".Type::Item:
                GenerateBufferFromValueEntry("Sales Invoice Line");
            "Sales Invoice Line".Type::"G/L Account", "Sales Invoice Line".Type::Resource,
          "Sales Invoice Line".Type::"Charge (Item)", "Sales Invoice Line".Type::"Fixed Asset":
                GenerateBufferFromShipment("Sales Invoice Line");
            "Sales Invoice Line".Type::" ":
                exit(0D);
        end;

        TempSalesShipmentBuffer.Reset();
        TempSalesShipmentBuffer.SetRange("Document No.", "Sales Invoice Line"."Document No.");
        TempSalesShipmentBuffer.SetRange("Line No.", "Sales Invoice Line"."Line No.");
        if TempSalesShipmentBuffer.Find('-') then begin
            TempSalesShipmentBuffer2 := TempSalesShipmentBuffer;
            if TempSalesShipmentBuffer.Next() = 0 then begin
                TempSalesShipmentBuffer.Get(
                  TempSalesShipmentBuffer2."Document No.", TempSalesShipmentBuffer2."Line No.", TempSalesShipmentBuffer2."Entry No.");
                TempSalesShipmentBuffer.Delete();
                exit(TempSalesShipmentBuffer2."Posting Date");
            end;
            TempSalesShipmentBuffer.CalcSums(Quantity);
            if TempSalesShipmentBuffer.Quantity <> "Sales Invoice Line".Quantity then begin
                TempSalesShipmentBuffer.DeleteAll();
                exit("Sales Invoice Header"."Posting Date");
            end;
        end else
            exit("Sales Invoice Header"."Posting Date");
    end;

    local procedure GenerateBufferFromValueEntry(SalesInvoiceLine2: Record "Sales Invoice Line")
    var
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        TotalQuantity: Decimal;
        Quantity: Decimal;
    begin
        TotalQuantity := SalesInvoiceLine2."Quantity (Base)";
        ValueEntry.SetCurrentKey("Document No.");
        ValueEntry.SetRange("Document No.", SalesInvoiceLine2."Document No.");
        ValueEntry.SetRange("Posting Date", "Sales Invoice Header"."Posting Date");
        ValueEntry.SetRange("Item Charge No.", '');
        ValueEntry.SetFilter("Entry No.", '%1..', FirstValueEntryNo);
        if ValueEntry.Find('-') then
            repeat
                if ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then begin
                    if SalesInvoiceLine2."Qty. per Unit of Measure" <> 0 then
                        Quantity := ValueEntry."Invoiced Quantity" / SalesInvoiceLine2."Qty. per Unit of Measure"
                    else
                        Quantity := ValueEntry."Invoiced Quantity";
                    AddBufferEntry(
                      SalesInvoiceLine2,
                      -Quantity,
                      ItemLedgerEntry."Posting Date");
                    TotalQuantity := TotalQuantity + ValueEntry."Invoiced Quantity";
                end;
                FirstValueEntryNo := ValueEntry."Entry No." + 1;
            until (ValueEntry.Next() = 0) or (TotalQuantity = 0);
    end;

    local procedure GenerateBufferFromShipment(SalesInvoiceLine: Record "Sales Invoice Line")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine2: Record "Sales Invoice Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        TotalQuantity: Decimal;
        Quantity: Decimal;
    begin
        TotalQuantity := 0;
        SalesInvoiceHeader.SetCurrentKey("Order No.");
        SalesInvoiceHeader.SetFilter("No.", '..%1', "Sales Invoice Header"."No.");
        SalesInvoiceHeader.SetRange("Order No.", "Sales Invoice Header"."Order No.");
        if SalesInvoiceHeader.Find('-') then
            repeat
                SalesInvoiceLine2.SetRange("Document No.", SalesInvoiceHeader."No.");
                SalesInvoiceLine2.SetRange("Line No.", SalesInvoiceLine."Line No.");
                SalesInvoiceLine2.SetRange(Type, SalesInvoiceLine.Type);
                SalesInvoiceLine2.SetRange("No.", SalesInvoiceLine."No.");
                SalesInvoiceLine2.SetRange("Unit of Measure Code", SalesInvoiceLine."Unit of Measure Code");
                if SalesInvoiceLine2.Find('-') then
                    repeat
                        TotalQuantity := TotalQuantity + SalesInvoiceLine2.Quantity;
                    until SalesInvoiceLine2.Next() = 0;
            until SalesInvoiceHeader.Next() = 0;

        SalesShipmentLine.SetCurrentKey("Order No.", "Order Line No.");
        SalesShipmentLine.SetRange("Order No.", "Sales Invoice Header"."Order No.");
        SalesShipmentLine.SetRange("Order Line No.", SalesInvoiceLine."Line No.");
        SalesShipmentLine.SetRange("Line No.", SalesInvoiceLine."Line No.");
        SalesShipmentLine.SetRange(Type, SalesInvoiceLine.Type);
        SalesShipmentLine.SetRange("No.", SalesInvoiceLine."No.");
        SalesShipmentLine.SetRange("Unit of Measure Code", SalesInvoiceLine."Unit of Measure Code");
        SalesShipmentLine.SetFilter(Quantity, '<>%1', 0);

        if SalesShipmentLine.Find('-') then
            repeat
                if "Sales Invoice Header"."Get Shipment Used" then
                    CorrectShipment(SalesShipmentLine);
                if Abs(SalesShipmentLine.Quantity) <= Abs(TotalQuantity - SalesInvoiceLine.Quantity) then
                    TotalQuantity := TotalQuantity - SalesShipmentLine.Quantity
                else begin
                    if Abs(SalesShipmentLine.Quantity) > Abs(TotalQuantity) then
                        SalesShipmentLine.Quantity := TotalQuantity;
                    Quantity :=
                      SalesShipmentLine.Quantity - (TotalQuantity - SalesInvoiceLine.Quantity);

                    TotalQuantity := TotalQuantity - SalesShipmentLine.Quantity;
                    SalesInvoiceLine.Quantity := SalesInvoiceLine.Quantity - Quantity;

                    if SalesShipmentHeader.Get(SalesShipmentLine."Document No.") then begin
                        AddBufferEntry(
                          SalesInvoiceLine,
                          Quantity,
                          SalesShipmentHeader."Posting Date");
                    end;
                end;
            until (SalesShipmentLine.Next() = 0) or (TotalQuantity = 0);
    end;

    local procedure CorrectShipment(var SalesShipmentLine: Record "Sales Shipment Line")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.SetCurrentKey("Shipment No.", "Shipment Line No.");
        SalesInvoiceLine.SetRange("Shipment No.", SalesShipmentLine."Document No.");
        SalesInvoiceLine.SetRange("Shipment Line No.", SalesShipmentLine."Line No.");
        if SalesInvoiceLine.Find('-') then
            repeat
                SalesShipmentLine.Quantity := SalesShipmentLine.Quantity - SalesInvoiceLine.Quantity;
            until SalesInvoiceLine.Next() = 0;
    end;

    local procedure AddBufferEntry(SalesInvoiceLine: Record "Sales Invoice Line"; QtyOnShipment: Decimal; PostingDate: Date)
    begin
        TempSalesShipmentBuffer.SetRange("Document No.", SalesInvoiceLine."Document No.");
        TempSalesShipmentBuffer.SetRange("Line No.", SalesInvoiceLine."Line No.");
        TempSalesShipmentBuffer.SetRange("Posting Date", PostingDate);
        if TempSalesShipmentBuffer.Find('-') then begin
            TempSalesShipmentBuffer.Quantity := TempSalesShipmentBuffer.Quantity + QtyOnShipment;
            TempSalesShipmentBuffer.Modify();
            exit;
        end;

        TempSalesShipmentBuffer."Document No." := SalesInvoiceLine."Document No.";
        TempSalesShipmentBuffer."Line No." := SalesInvoiceLine."Line No.";
        TempSalesShipmentBuffer."Entry No." := NextEntryNo;
        TempSalesShipmentBuffer.Type := SalesInvoiceLine.Type;
        TempSalesShipmentBuffer."No." := SalesInvoiceLine."No.";
        TempSalesShipmentBuffer.Quantity := QtyOnShipment;
        TempSalesShipmentBuffer."Posting Date" := PostingDate;
        TempSalesShipmentBuffer.Insert();
        NextEntryNo := NextEntryNo + 1
    end;

    local procedure DocumentCaption(): Text[250]
    begin
        if "Sales Invoice Header"."Prepayment Invoice" then
            exit(Text010);
        exit(Text004);
    end;

    local procedure CollectAsmInformation()
    var
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        PostedAsmHeader: Record "Posted Assembly Header";
        PostedAsmLine: Record "Posted Assembly Line";
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        TempPostedAsmLine.DeleteAll();
        if "Sales Invoice Line".Type <> "Sales Invoice Line".Type::Item then
            exit;
        ValueEntry.SetCurrentKey("Document No.");
        ValueEntry.SetRange("Document No.", "Sales Invoice Line"."Document No.");
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
        ValueEntry.SetRange("Document Line No.", "Sales Invoice Line"."Line No.");
        ValueEntry.SetRange(Adjustment, false);
        if not ValueEntry.FindSet() then
            exit;
        repeat
            if ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then begin
                if ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Shipment" then begin
                    SalesShipmentLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.");
                    if SalesShipmentLine.AsmToShipmentExists(PostedAsmHeader) then begin
                        PostedAsmLine.SetRange("Document No.", PostedAsmHeader."No.");
                        if PostedAsmLine.FindSet() then
                            repeat
                                TreatAsmLineBuffer(PostedAsmLine);
                            until PostedAsmLine.Next() = 0;
                    end;
                end;
            end;
        until ValueEntry.Next() = 0;
    end;

    local procedure TreatAsmLineBuffer(PostedAsmLine: Record "Posted Assembly Line")
    begin
        Clear(TempPostedAsmLine);
        TempPostedAsmLine.SetRange(Type, PostedAsmLine.Type);
        TempPostedAsmLine.SetRange("No.", PostedAsmLine."No.");
        TempPostedAsmLine.SetRange("Variant Code", PostedAsmLine."Variant Code");
        TempPostedAsmLine.SetRange(Description, PostedAsmLine.Description);
        TempPostedAsmLine.SetRange("Unit of Measure Code", PostedAsmLine."Unit of Measure Code");
        if TempPostedAsmLine.FindFirst() then begin
            TempPostedAsmLine.Quantity += PostedAsmLine.Quantity;
            TempPostedAsmLine.Modify();
        end else begin
            Clear(TempPostedAsmLine);
            TempPostedAsmLine := PostedAsmLine;
            TempPostedAsmLine.Insert();
        end;
    end;

    local procedure GetUOMText(UOMCode: Code[10]): Text[10]
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if not UnitOfMeasure.Get(UOMCode) then
            exit(UOMCode);
        exit(CopyStr(UnitOfMeasure.Description, 1, 10));
    end;

    local procedure BlanksForIndent(): Text[10]
    begin
        exit(PadStr('', 2, ' '));
    end;

    local procedure GetLineFeeNoteOnReportHist(SalesInvoiceHeaderNo: Code[20])
    var
        LineFeeNoteOnReportHist: Record "Line Fee Note on Report Hist.";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
    begin
        TempLineFeeNoteOnReportHist.DeleteAll();
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", SalesInvoiceHeaderNo);
        if not CustLedgerEntry.FindFirst() then
            exit;

        if not Customer.Get(CustLedgerEntry."Customer No.") then
            exit;

        LineFeeNoteOnReportHist.SetRange("Cust. Ledger Entry No", CustLedgerEntry."Entry No.");
        LineFeeNoteOnReportHist.SetRange("Language Code", Customer."Language Code");
        if LineFeeNoteOnReportHist.FindSet() then begin
            repeat
                TempLineFeeNoteOnReportHist.Init();
                TempLineFeeNoteOnReportHist.Copy(LineFeeNoteOnReportHist);
                TempLineFeeNoteOnReportHist.Insert();
            until LineFeeNoteOnReportHist.Next() = 0;
        end
        // >> AL-Umstellung
        // Uncomment if multiple languages are needed        
        // else begin
        //     LineFeeNoteOnReportHist.SetRange("Language Code", Language.GetUserLanguage);
        //     if LineFeeNoteOnReportHist.FindSet() then
        //         repeat
        //             TempLineFeeNoteOnReportHist.Init();
        //             TempLineFeeNoteOnReportHist.Copy(LineFeeNoteOnReportHist);
        //             TempLineFeeNoteOnReportHist.Insert();
        //         until LineFeeNoteOnReportHist.Next() = 0;
        // end;
        // << AL-Umstellung
    end;
}