report 1070550 "CCS CASH Sales Cr. Memo - POS"
{
    // POS0003 28.06.16
    //   Split Invoice / Credit Memo Report
    // POS0007 08.07.16 FS
    // EFSTA2.00  30.11.2016 MK QR Code added
    // POS0029 07.02.17 FS Field Name Change "Print QR Position" -> EfstaSetup."Picture Print Position"
    //                     Field Name Change "Picture for Print" -> EfstaSetup."Picture PrintOption"
    // EFSTA2.05  22.02.2017 MK Added Code to Recreate QR Picture if needed
    // EFSTA2.07  30.03.2017 MK Changes because Printing with no active WebService Setup was not possible
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Rep1070550.CCSCASHSalesCrMemoPOS.rdl';

    Caption = 'Sales Cr. Memo - Cash';
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
            column(TransactionType; "Transaction Type")
            {
            }
            dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
            {
                //DataItemLink = "No." = FIELD("Receipt No.");
                DataItemLink = "CCS CASH CSL Transaction No." = field("Transaction No."), "CCS CASH CSL Store No." = field("Store No."), "CCS CASH CSL POS Terminal No." = field("POS Terminal No.");
                DataItemTableView = SORTING("No.");
                RequestFilterFields = "No.", "Sell-to Customer No.", "No. Printed";
                RequestFilterHeading = 'Posted Sales Credit Memo';
                column(No_SalesCrMemoHeader; "No.")
                {
                }
                column(EMailCaption; EMailCaptionLbl)
                {
                }
                column(HomePageCaption; HomePageCaptionLbl)
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
                        column(DocCaptnCopyTxt; StrSubstNo(DocumentCaption(), CopyText))
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
                        column(Picture_Store; Store.Picture)
                        {
                        }
                        column(Picture1_Store; Store1.Picture)
                        {
                        }
                        column(Picture2_Store; Store2.Picture)
                        {
                        }
                        column(HomePage; CompanyInfo."Home Page")
                        {
                        }
                        column(EMail; CompanyInfo."E-Mail")
                        {
                        }
                        column(CompanyInfoFaxNo; CompanyInfo."Fax No.")
                        {
                        }
                        column(CompanyInfoVATRegistrationNo; CompanyInfo."VAT Registration No.")
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
                        column(BilltoCustNo_SalesCrMemoHeader; "Sales Cr.Memo Header"."Bill-to Customer No.")
                        {
                        }
                        column(PostingDate_SalesCrMemoHeader; Format("Sales Cr.Memo Header"."Posting Date", 0, 4))
                        {
                        }
                        column(VATNoText; VATNoText)
                        {
                        }
                        column(VATRegNo_SalesCrMemoHeader; "Sales Cr.Memo Header"."VAT Registration No.")
                        {
                        }
                        column(No1_SalesCrMemoHeader; "Sales Cr.Memo Header"."No.")
                        {
                        }
                        column(SalesPersonText; SalesPersonText)
                        {
                        }
                        column(SalesPurchPersonName; SalesPurchPerson.Name)
                        {
                        }
                        column(AppliedToText; AppliedToText)
                        {
                        }
                        column(ReferenceText; ReferenceText)
                        {
                        }
                        column(YourRef_SalesCrMemoHeader; "Sales Cr.Memo Header"."Your Reference")
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
                        column(Date_SalesCrMemoHeader; Format("Sales Cr.Memo Header"."Document Date", 0, 4))
                        {
                        }
                        column(PricesIncVAT_SalesCrMemoHeader; "Sales Cr.Memo Header"."Prices Including VAT")
                        {
                        }
                        column(ReturnOrderNoText; ReturnOrderNoText)
                        {
                        }
                        column(ReturnOrderNo_SalesCrMemoHeader; "Sales Cr.Memo Header"."Return Order No.")
                        {
                        }
                        column(PageCaption; PageCaptionCap)
                        {
                        }
                        column(OutputNo; OutputNo)
                        {
                        }
                        column(PricesInclVATYesNo; Format("Sales Cr.Memo Header"."Prices Including VAT"))
                        {
                        }
                        column(VATBaseDiscPercentage; "Sales Cr.Memo Header"."VAT Base Discount %")
                        {
                        }
                        column(CompanyInfoRegNo; CompanyInfo.GetRegistrationNumber())
                        {
                        }
                        column(CompanyInfoPhoneNoCaption; CompanyInfoPhoneNoCaptionLbl)
                        {
                        }
                        column(CompanyInfoFaxNoCaption; CompanyInfoFaxNoCaptionLbl)
                        {
                        }
                        column(CompanyInfoVATRegNoCaption; CompanyInfoVATRegNoCaptionLbl)
                        {
                        }
                        column(CompanyInfoGiroNoCaption; CompanyInfoGiroNoCaptionLbl)
                        {
                        }
                        column(CompanyInfoBankNameCaption; CompanyInfoBankNameCaptionLbl)
                        {
                        }
                        column(CompanyInfoBankAccNoCaption; CompanyInfoBankAccNoCaptionLbl)
                        {
                        }
                        column(SalesCrMemoHeaderNoCaption; SalesCrMemoHeaderNoCaptionLbl)
                        {
                        }
                        column(PostingDateCaption; PostingDateCaptionLbl)
                        {
                        }
                        column(CompanyInfoRegNoCaption; CompanyInfo.GetRegistrationNumberLbl())
                        {
                        }
                        column(BilltoCustNo_SalesCrMemoHeaderCaption; "Sales Cr.Memo Header".FieldCaption("Bill-to Customer No."))
                        {
                        }
                        column(PricesIncVAT_SalesCrMemoHeaderCaption; "Sales Cr.Memo Header".FieldCaption("Prices Including VAT"))
                        {
                        }
                        dataitem(DimensionLoop1; "Integer")
                        {
                            DataItemLinkReference = "Sales Cr.Memo Header";
                            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                            column(DimText; DimText)
                            {
                            }
                            column(DimLoop1No; DimensionLoop1.Number)
                            {
                            }
                            column(HeaderDimCaption; HeaderDimCaptionLbl)
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
                                        DimText :=
                                          CopyStr(StrSubstNo(
                                            '%1, %2 %3', DimText,
                                            DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code"), 1, MaxStrLen(DimText));
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
                        dataitem("Sales Cr.Memo Line"; "Sales Cr.Memo Line")
                        {
                            DataItemLink = "Document No." = FIELD("No.");
                            DataItemLinkReference = "Sales Cr.Memo Header";
                            DataItemTableView = SORTING("Document No.", "Line No.");
                            column(LineAmt_SalesCrMemoLine; "Line Amount")
                            {
                                AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                                AutoFormatType = 1;
                            }
                            column(Desc_SalesCrMemoLine; Description)
                            {
                            }
                            column(No_SalesCrMemoLine; "No.")
                            {
                            }
                            column(Qty_SalesCrMemoLine; Quantity)
                            {
                            }
                            column(umo_SalesCrMemoLine; "Unit of Measure")
                            {
                            }
                            column(UnitPrice_SalesCrMemoLine; "Unit Price")
                            {
                                AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                                AutoFormatType = 2;
                            }
                            column(LineDis_SalesCrMemoLine; "Line Discount %")
                            {
                            }
                            column(VATId_SalesCrMemoLine; "VAT Identifier")
                            {
                            }
                            column(PostedReceiptDate; Format(PostedReceiptDate))
                            {
                            }
                            column(Type_SalesCrMemoLine; Format(Type))
                            {
                            }
                            column(NNCTotalLineAmt; NNC_TotalLineAmount)
                            {
                                AutoFormatExpression = GetCurrencyCode();
                                AutoFormatType = 1;
                            }
                            column(NNCTotalAmtInclVat; NNC_TotalAmountInclVat)
                            {
                                AutoFormatExpression = GetCurrencyCode();
                                AutoFormatType = 1;
                            }
                            column(NNCTotalInvDiscAmt; NNC_TotalInvDiscAmount)
                            {
                                AutoFormatExpression = GetCurrencyCode();
                                AutoFormatType = 1;
                            }
                            column(NNCTotalAmt; NNC_TotalAmount)
                            {
                                AutoFormatExpression = GetCurrencyCode();
                                AutoFormatType = 1;
                            }
                            column(TotalText; TotalText)
                            {
                            }
                            column(SalesCrMemoLineAmt; Amount)
                            {
                                AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                                AutoFormatType = 1;
                            }
                            column(TotalExclVATText; TotalExclVATText)
                            {
                            }
                            column(TotalInclVATText; TotalInclVATText)
                            {
                            }
                            column(AmtInclVAT_SalesCrMemoLine; "Amount Including VAT")
                            {
                                AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                                AutoFormatType = 1;
                            }
                            column(AmtInclVATAmt; "Amount Including VAT" - Amount)
                            {
                                AutoFormatExpression = "Sales Cr.Memo Line".GetCurrencyCode();
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineVATAmtText; TempVATAmountLine.VATAmountText())
                            {
                            }
                            column(DocNo_SalesCrMemoLine; "Document No.")
                            {
                            }
                            column(SalesCrMemoLineLineNo; "Line No.")
                            {
                            }
                            column(UnitPriceCaption; UnitPriceCaptionLbl)
                            {
                            }
                            column(DiscountCaption; DiscountCaptionLbl)
                            {
                            }
                            column(AmountCaption; AmountCaptionLbl)
                            {
                            }
                            column(PostedReceiptDateCaption; PostedReceiptDateCaptionLbl)
                            {
                            }
                            column(ContinuedCaption; ContinuedCaptionLbl)
                            {
                            }
                            column(InvDiscAmtCaption; InvDiscAmtCaptionLbl)
                            {
                            }
                            column(SubtotalCaption; SubtotalCaptionLbl)
                            {
                            }
                            column(PaymentDiscountVATCaption; PaymentDiscountVATCaptionLbl)
                            {
                            }
                            column(Desc_SalesCrMemoLineCaption; FieldCaption(Description))
                            {
                            }
                            column(No_SalesCrMemoLineCaption; FieldCaption("No."))
                            {
                            }
                            column(Qty_SalesCrMemoLineCaption; FieldCaption(Quantity))
                            {
                            }
                            column(umo_SalesCrMemoLineCaption; FieldCaption("Unit of Measure"))
                            {
                            }
                            column(VATId_SalesCrMemoLineCaption; VATIdentifierCaptionLbl)
                            {
                            }
                            dataitem("Sales Shipment Buffer"; "Integer")
                            {
                                DataItemTableView = SORTING(Number);
                                column(SalesShipmentBufferQuantity; TempSalesShipmentBuffer.Quantity)
                                {
                                    DecimalPlaces = 0 : 5;
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
                                    SetRange(Number, 1, TempSalesShipmentBuffer.Count);
                                end;
                            }
                            dataitem(DimensionLoop2; "Integer")
                            {
                                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                                column(DimText1; DimText)
                                {
                                }
                                column(LineDimensionsCaption; LineDimensionsCaptionLbl)
                                {
                                }

                                trigger OnAfterGetRecord()
                                begin
                                    if Number = 1 then begin
                                        if not DimSetEntry2.Find('-') then
                                            CurrReport.Break();
                                    end else
                                        if not Continue then
                                            CurrReport.Break();

                                    Clear(DimText);
                                    Continue := false;
                                    repeat
                                        OldDimText := CopyStr(DimText, 1, MaxStrLen(OldDimText));
                                        if DimText = '' then
#pragma warning disable AA0217
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

                                    DimSetEntry2.SetRange("Dimension Set ID", "Sales Cr.Memo Line"."Dimension Set ID");
                                end;
                            }

                            trigger OnAfterGetRecord()
                            begin
                                NNC_TotalLineAmount += "Line Amount";
                                NNC_TotalAmountInclVat += "Amount Including VAT";
                                NNC_TotalInvDiscAmount += "Inv. Discount Amount";
                                NNC_TotalAmount += Amount;

                                TempSalesShipmentBuffer.DeleteAll();
                                PostedReceiptDate := 0D;
                                if Quantity <> 0 then
                                    PostedReceiptDate := FindPostedShipmentDate();

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
                                //CurrReport.CreateTotals(Amount, "Amount Including VAT", "Inv. Discount Amount");
                            end;
                        }
                        dataitem(VATCounter; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            column(VATAmtLineVATBase; TempVATAmountLine."VAT Base")
                            {
                                AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineVATAmt; TempVATAmountLine."VAT Amount")
                            {
                                AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineLineAmt; TempVATAmountLine."Line Amount")
                            {
                                AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineInvDiscBaseAmt; TempVATAmountLine."Inv. Disc. Base Amount")
                            {
                                AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineInvoiceDiscAmt; TempVATAmountLine."Invoice Discount Amount")
                            {
                                AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineVAT; TempVATAmountLine."VAT %")
                            {
                                DecimalPlaces = 0 : 5;
                            }
                            column(VATAmtLineVATIdentifier; TempVATAmountLine."VAT Identifier")
                            {
                            }
                            column(VATAmtLineVATCaption; VATAmtLineVATCaptionLbl)
                            {
                            }
                            column(VATBaseCaption; VATBaseCaptionLbl)
                            {
                            }
                            column(VATAmountCaption; VATAmountCaptionLbl)
                            {
                            }
                            column(VATAmtSpecificationCaption; VATAmtSpecificationCaptionLbl)
                            {
                            }
                            column(VATIdentifierCaption; VATIdentifierCaptionLbl)
                            {
                            }
                            column(InvDiscBaseAmtCaption; InvDiscBaseAmtCaptionLbl)
                            {
                            }
                            column(LineAmtCaption; LineAmtCaptionLbl)
                            {
                            }
                            column(InvoiceDiscoutAmountCaption; InvoiceDiscoutAmountCaptionLbl)
                            {
                            }
                            column(TotalCaption; TotalCaptionLbl)
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
                                AutoFormatExpression = "Sales Cr.Memo Header"."Currency Code";
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
                                VATClause.TranslateDescription("Sales Cr.Memo Header"."Language Code");
                            end;

                            trigger OnPreDataItem()
                            begin
                                Clear(VATClause);
                                SetRange(Number, 1, TempVATAmountLine.Count);
                                // CurrReport.CreateTotals(VATAmountLine."VAT Amount");
                            end;
                        }
                        dataitem(VATCounterLCY; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            column(VALSpecLCYHeader; VALSpecLCYHeader)
                            {
                            }
                            column(VALExchRate; VALExchRate)
                            {
                            }
                            column(VALVATAmtLCY; VALVATAmountLCY)
                            {
                                AutoFormatType = 1;
                            }
                            column(VALVATBaseLCY; VALVATBaseLCY)
                            {
                                AutoFormatType = 1;
                            }
                            column(VATAmtLineVATPercentage; TempVATAmountLine."VAT %")
                            {
                                DecimalPlaces = 0 : 5;
                            }
                            column(VATAmtLineVATIdr; TempVATAmountLine."VAT Identifier")
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                TempVATAmountLine.GetLine(Number);
                                VALVATBaseLCY :=
                                  TempVATAmountLine.GetBaseLCY(
                                    "Sales Cr.Memo Header"."Posting Date", "Sales Cr.Memo Header"."Currency Code",
                                    "Sales Cr.Memo Header"."Currency Factor");
                                VALVATAmountLCY :=
                                  TempVATAmountLine.GetAmountLCY(
                                    "Sales Cr.Memo Header"."Posting Date", "Sales Cr.Memo Header"."Currency Code",
                                    "Sales Cr.Memo Header"."Currency Factor");
                            end;

                            trigger OnPreDataItem()
                            begin
                                if (not GLSetup."Print VAT specification in LCY") or
                                   ("Sales Cr.Memo Header"."Currency Code" = '')
                                then
                                    CurrReport.Break();

                                SetRange(Number, 1, TempVATAmountLine.Count);
                                // CurrReport.CreateTotals(VALVATBaseLCY, VALVATAmountLCY);

                                if GLSetup."LCY Code" = '' then
                                    VALSpecLCYHeader := Text008 + Text009
                                else
                                    VALSpecLCYHeader := Text008 + Format(GLSetup."LCY Code");

                                CurrExchRate.FindCurrency("Sales Cr.Memo Header"."Posting Date", "Sales Cr.Memo Header"."Currency Code", 1);
                                CalculatedExchRate := Round(1 / "Sales Cr.Memo Header"."Currency Factor" * CurrExchRate."Exchange Rate Amount", 0.000001);
                                VALExchRate := StrSubstNo(Text010, CalculatedExchRate, CurrExchRate."Exchange Rate Amount");
                            end;
                        }
                        dataitem(Total; "Integer")
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                        }
                        dataitem(Total2; "Integer")
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                            column(SelltoCustNo_SalesCrMemoHeader; "Sales Cr.Memo Header"."Sell-to Customer No.")
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
                            column(ShiptoAddressCaption; ShiptoAddressCaptionLbl)
                            {
                            }
                            column(SelltoCustNo_SalesCrMemoHeaderCaption; "Sales Cr.Memo Header".FieldCaption("Sell-to Customer No."))
                            {
                            }

                            trigger OnPreDataItem()
                            begin
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
                                TenderType: Record "CCS CASH Store Tender Type";
                            begin
                                Clear(TenderDescription);
                                TenderDescription := "Tender Description";
                                if "POS Transaction Header"."Transaction Type" = "POS Transaction Header"."Transaction Type"::Return then
                                    Amount := -Amount;
                                if TenderType.Get("Store No.", "Tender Type") then
                                    case TenderType.TenderFunction of
                                        TenderType.TenderFunction::Card:
                                            if TenderTypeCardSetup.Get("POS Transaction Header"."Store No.", "Tender Type", "Card No.") then
                                                TenderDescription := TenderTypeCardSetup.Description;
                                        TenderType.TenderFunction::Voucher:
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
                        //CurrReport.PageNo := 1;
                        if Number > 1 then begin
                            CopyText := Text004;
                            OutputNo += 1;
                        end;

                        NNC_TotalLineAmount := 0;
                        NNC_TotalAmountInclVat := 0;
                        NNC_TotalInvDiscAmount := 0;
                        NNC_TotalAmount := 0;
                    end;

                    trigger OnPostDataItem()
                    begin
                        if not CurrReport.Preview then
                            SalesCrMemoCountPrinted.Run("Sales Cr.Memo Header");
                    end;

                    trigger OnPreDataItem()
                    begin
                        NoOfLoops := Abs(GNoOfCopies) + 1;
                        CopyText := '';
                        SetRange(Number, 1, NoOfLoops);
                        OutputNo := 1;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    CurrReport.Language := RepLanguage.GetLanguageIdOrDefault("Language Code");

                    CompanyInfo.Get();

                    if RespCenter.Get("Responsibility Center") then begin
                        FormatAddr.RespCenter(CompanyAddr, RespCenter);
                        CompanyInfo."Phone No." := RespCenter."Phone No.";
                        CompanyInfo."Fax No." := RespCenter."Fax No.";
                    end else
                        FormatAddr.Company(CompanyAddr, CompanyInfo);

                    DimSetEntry1.SetRange("Dimension Set ID", "Dimension Set ID");

                    if "Return Order No." = '' then
                        ReturnOrderNoText := ''
                    else
                        ReturnOrderNoText := CopyStr(FieldCaption("Return Order No."), 1, MaxStrLen(ReturnOrderNoText));
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
                        TotalExclVATText := StrSubstNo(Text007, GLSetup."LCY Code");
                    end else begin
                        TotalText := StrSubstNo(Text001, "Currency Code");
                        TotalInclVATText := StrSubstNo(Text002, "Currency Code");
                        TotalExclVATText := StrSubstNo(Text007, "Currency Code");
                    end;
                    FormatAddr.SalesCrMemoSellTo(CustAddr, "Sales Cr.Memo Header");
                    if not Cust.Get("Bill-to Customer No.") then
                        Clear(Cust);
                    if "Applies-to Doc. No." = '' then
                        AppliedToText := ''
                    else
                        AppliedToText := StrSubstNo(Text003, "Applies-to Doc. Type", "Applies-to Doc. No.");

                    FormatAddr.SalesCrMemoShipTo(ShipToAddr, CustAddr, "Sales Cr.Memo Header");

                    if GLogInteraction then
                        if not CurrReport.Preview then
                            if "Bill-to Contact No." <> '' then
                                SegManagement.LogDocument(
                                  6, "No.", 0, 0, DATABASE::Contact, "Bill-to Contact No.", "Salesperson Code",
                                  "Campaign No.", "Posting Description", '')
                            else
                                SegManagement.LogDocument(
                                  6, "No.", 0, 0, DATABASE::Customer, "Sell-to Customer No.", "Salesperson Code",
                                  "Campaign No.", "Posting Description", '');
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

                if Store.Get("POS Transaction Header"."Store No.") then;
                case Store."Logo Position on Documents" of
                    Store."Logo Position on Documents"::Left:
                        Store.CalcFields(Picture);
                    Store."Logo Position on Documents"::Center:
                        begin
                            if Store1.Get("POS Transaction Header"."Store No.") then
                                Store1.CalcFields(Picture);
                        end;
                    Store."Logo Position on Documents"::Right:
                        begin
                            if Store2.Get("POS Transaction Header"."Store No.") then
                                Store2.CalcFields(Picture);
                        end;
                end;

                if "Payment Discount %" <> 0 then
                    PrintPaymentText := true
                else
                    PrintPaymentText := false;

                // >> AL-Umstellung
                PosRegFunc.GetDocumentQRCode("Store No.", "POS Terminal No.", "Transaction No.", tempCASHDocumentInformation);
                // ++ EFSTA2.00
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
            GLogInteraction := SegManagement.FindInteractionTemplateCode(Enum::"Interaction Log Entry Document Type"::"Sales Cr. Memo") <> '';
            LogInteractionEnable := GLogInteraction;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        GLSetup.Get();
        SalesSetup.Get();
        CCSCashSalesSetup.Get();
        GNoOfCopies := CCSCashSalesSetup."Cash CrMemo Copies";
        /*CASE SalesSetup."Logo Position on Documents" OF
          SalesSetup."Logo Position on Documents"::"No Logo":;
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

    var
        Text000: Label 'Salesperson';
        Text001: Label 'Total %1', Comment = '%1=Value 1';
        Text002: Label 'Total %1 Incl. VAT', Comment = '%1=Value 1';
        Text003: Label '(Applies to %1 %2)', Comment = '%1=Value 1,%2=Value 2';
        Text004: Label 'COPY';
        Text005: Label 'Sales - Credit Memo %1', Comment = '%1=Value 1';
        PageCaptionCap: Label 'Page %1 of %2', Comment = '%1=Value 1,%2=Value 2';
        Text007: Label 'Total %1 Excl. VAT', Comment = '%1=Value 1';
        GLSetup: Record "General Ledger Setup";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        CompanyInfo: Record "Company Information";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        VATClause: Record "VAT Clause";
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        RepLanguage: Codeunit Language;
        TempSalesShipmentBuffer: Record "Sales Shipment Buffer" temporary;
        CurrExchRate: Record "Currency Exchange Rate";
        SalesSetup: Record "Sales & Receivables Setup";
        CCSCashSalesSetup: Record "CCS CASH Cash Sales Setup";
        SalesCrMemoCountPrinted: Codeunit "Sales Cr. Memo-Printed";
        FormatAddr: Codeunit "Format Address";
        SegManagement: Codeunit SegManagement;
        RespCenter: Record "Responsibility Center";
        CustAddr: array[8] of Text[50];
        ShipToAddr: array[8] of Text[50];
        CompanyAddr: array[8] of Text[50];
        ReturnOrderNoText: Text[80];
        SalesPersonText: Text[30];
        VATNoText: Text[80];
        ReferenceText: Text[80];
        AppliedToText: Text;
        TotalText: Text[50];
        TotalExclVATText: Text[50];
        TotalInclVATText: Text[50];
        MoreLines: Boolean;
        GNoOfCopies: Integer;
        NoOfLoops: Integer;
        CopyText: Text[30];
        DimText: Text[120];
        OldDimText: Text[75];
        GShowInternalInfo: Boolean;
        Continue: Boolean;
        GLogInteraction: Boolean;
        FirstValueEntryNo: Integer;
        PostedReceiptDate: Date;
        NextEntryNo: Integer;
        VALVATBaseLCY: Decimal;
        VALVATAmountLCY: Decimal;
        Text008: Label 'VAT Amount Specification in ';
        Text009: Label 'Local Currency';
        Text010: Label 'Exchange rate: %1/%2', Comment = '%1=Value 1,%2=Value 2';
        VALSpecLCYHeader: Text[80];
        VALExchRate: Text[50];
        CalculatedExchRate: Decimal;
        Text011: Label 'Sales - Prepmt. Credit Memo %1', Comment = '%1=Value 1';
        OutputNo: Integer;
        NNC_TotalLineAmount: Decimal;
        NNC_TotalAmountInclVat: Decimal;
        NNC_TotalInvDiscAmount: Decimal;
        NNC_TotalAmount: Decimal;
        LogInteractionEnable: Boolean;
        CompanyInfoPhoneNoCaptionLbl: Label 'Phone No.';
        CompanyInfoFaxNoCaptionLbl: Label 'Fax No.';
        CompanyInfoVATRegNoCaptionLbl: Label 'VAT Reg. No.';
        CompanyInfoGiroNoCaptionLbl: Label 'Giro No.';
        CompanyInfoBankNameCaptionLbl: Label 'Bank';
        CompanyInfoBankAccNoCaptionLbl: Label 'Account No.';
        SalesCrMemoHeaderNoCaptionLbl: Label 'Credit Memo No.';
        PostingDateCaptionLbl: Label 'Posting Date';
        HeaderDimCaptionLbl: Label 'Header Dimensions';
        UnitPriceCaptionLbl: Label 'Unit Price';
        DiscountCaptionLbl: Label 'Discount %';
        AmountCaptionLbl: Label 'Amount';
        PostedReceiptDateCaptionLbl: Label 'Posted Return Receipt Date';
        ContinuedCaptionLbl: Label 'Continued';
        InvDiscAmtCaptionLbl: Label 'Invoice Discount Amount';
        SubtotalCaptionLbl: Label 'Subtotal';
        PaymentDiscountVATCaptionLbl: Label 'Payment Discount on VAT';
        VATClausesCap: Label 'VAT Clause';
        LineDimensionsCaptionLbl: Label 'Line Dimensions';
        VATAmtLineVATCaptionLbl: Label 'VAT %';
        VATBaseCaptionLbl: Label 'VAT Base';
        VATAmountCaptionLbl: Label 'VAT Amount';
        VATAmtSpecificationCaptionLbl: Label 'VAT Amount Specification';
        VATIdentifierCaptionLbl: Label 'VAT Identifier';
        InvDiscBaseAmtCaptionLbl: Label 'Invoice Discount Base Amount';
        LineAmtCaptionLbl: Label 'Line Amount';
        InvoiceDiscoutAmountCaptionLbl: Label 'Invoice Discount Amount';
        TotalCaptionLbl: Label 'Total';
        ShiptoAddressCaptionLbl: Label 'Ship-to Address';
        EMailCaptionLbl: Label 'E-Mail';
        HomePageCaptionLbl: Label 'Home Page';
        DocumentDateCaptionLbl: Label 'Document Date';
        TenderDescription: Text[50];
        TenderTypeCardSetup: Record "CCS CASH Tender Type C. Setup";
        Store: Record "CCS CASH Store";
        HeaderText: Text[50];
        Store1: Record "CCS CASH Store";
        Store2: Record "CCS CASH Store";
        PrintPaymentText: Boolean;
        Tender_Lbl: Label 'Zahlungen:';
        StoreNo_Lbl: Label 'Store:';
        TerminalNo_Lbl: Label 'POS:';
        TransNo_Lbl: Label 'Transaction:';
        ReceiptNo_Lbl: Label 'Receipt No.:';
        Time_Lbl: Label 'Date:';
        CustVATNo_Lbl: Label 'VAT Registration No.:';
        Text50011: Label 'Cashier:';
        Text50010: Label 'Invoice';
        Text50012: Label 'Invoice';
        PaymentDiscVATCaptionLbl2: Label 'Payment Discount calculated.';
        CustNo_Lbl: Label 'Customer No.:';
        Cust: Record Customer;
        // >> AL-Umstellung
        // "<EFSTA>": Integer;
        // EfstaLog: Record "Sign. Service Request Log";
        // EfstaSetup: Record "Sign. Service Setup";
        // EfstaLogLeft: Record "Sign. Service Request Log";
        // EfstaLogMiddle: Record "Sign. Service Request Log";
        // EfstaLogRight: Record "Sign. Service Request Log";
        // EFSTAWebService: Codeunit "POS Register Web Service EFSTA";
        // EFSTAMessageText: Text;
        tempCASHDocumentInformation: Record "CCS CASH Document Information" temporary;
    // << AL-Umstellung


    local procedure InitLogInteraction()
    begin
        GLogInteraction := SegManagement.FindInteractionTemplateCode(Enum::"Interaction Log Entry Document Type"::"Sales Cr. Memo") <> '';
    end;

    local procedure FindPostedShipmentDate(): Date
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        TempSalesShipmentBuffer2: Record "Sales Shipment Buffer" temporary;
    begin
        NextEntryNo := 1;
        if "Sales Cr.Memo Line"."Return Receipt No." <> '' then
            if ReturnReceiptHeader.Get("Sales Cr.Memo Line"."Return Receipt No.") then
                exit(ReturnReceiptHeader."Posting Date");
        if "Sales Cr.Memo Header"."Return Order No." = '' then
            exit("Sales Cr.Memo Header"."Posting Date");

        case "Sales Cr.Memo Line".Type of
            "Sales Cr.Memo Line".Type::Item:
                GenerateBufferFromValueEntry("Sales Cr.Memo Line");
            "Sales Cr.Memo Line".Type::"G/L Account", "Sales Cr.Memo Line".Type::Resource,
          "Sales Cr.Memo Line".Type::"Charge (Item)", "Sales Cr.Memo Line".Type::"Fixed Asset":
                GenerateBufferFromShipment("Sales Cr.Memo Line");
            "Sales Cr.Memo Line".Type::" ":
                exit(0D);
        end;

        TempSalesShipmentBuffer.Reset();
        TempSalesShipmentBuffer.SetRange("Document No.", "Sales Cr.Memo Line"."Document No.");
        TempSalesShipmentBuffer.SetRange("Line No.", "Sales Cr.Memo Line"."Line No.");

        if TempSalesShipmentBuffer.Find('-') then begin
            TempSalesShipmentBuffer2 := TempSalesShipmentBuffer;
            if TempSalesShipmentBuffer.Next() = 0 then begin
                TempSalesShipmentBuffer.Get(TempSalesShipmentBuffer2."Document No.", TempSalesShipmentBuffer2."Line No.", TempSalesShipmentBuffer2."Entry No.");
                TempSalesShipmentBuffer.Delete();
                exit(TempSalesShipmentBuffer2."Posting Date");
            end;
            TempSalesShipmentBuffer.CalcSums(Quantity);
            if TempSalesShipmentBuffer.Quantity <> "Sales Cr.Memo Line".Quantity then begin
                TempSalesShipmentBuffer.DeleteAll();
                exit("Sales Cr.Memo Header"."Posting Date");
            end;
        end else
            exit("Sales Cr.Memo Header"."Posting Date");
    end;

    local procedure GenerateBufferFromValueEntry(SalesCrMemoLine2: Record "Sales Cr.Memo Line")
    var
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        TotalQuantity: Decimal;
        Quantity: Decimal;
    begin
        TotalQuantity := SalesCrMemoLine2."Quantity (Base)";
        ValueEntry.SetCurrentKey("Document No.");
        ValueEntry.SetRange("Document No.", SalesCrMemoLine2."Document No.");
        ValueEntry.SetRange("Posting Date", "Sales Cr.Memo Header"."Posting Date");
        ValueEntry.SetRange("Item Charge No.", '');
        ValueEntry.SetFilter("Entry No.", '%1..', FirstValueEntryNo);
        if ValueEntry.Find('-') then
            repeat
                if ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then begin
                    if SalesCrMemoLine2."Qty. per Unit of Measure" <> 0 then
                        Quantity := ValueEntry."Invoiced Quantity" / SalesCrMemoLine2."Qty. per Unit of Measure"
                    else
                        Quantity := ValueEntry."Invoiced Quantity";
                    AddBufferEntry(
                      SalesCrMemoLine2,
                      -Quantity,
                      ItemLedgerEntry."Posting Date");
                    TotalQuantity := TotalQuantity - ValueEntry."Invoiced Quantity";
                end;
                FirstValueEntryNo := ValueEntry."Entry No." + 1;
            until (ValueEntry.Next() = 0) or (TotalQuantity = 0);
    end;

    local procedure GenerateBufferFromShipment(SalesCrMemoLine: Record "Sales Cr.Memo Line")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine2: Record "Sales Cr.Memo Line";
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReturnReceiptLine: Record "Return Receipt Line";
        TotalQuantity: Decimal;
        Quantity: Decimal;
    begin
        TotalQuantity := 0;
        SalesCrMemoHeader.SetCurrentKey("Return Order No.");
        SalesCrMemoHeader.SetFilter("No.", '..%1', "Sales Cr.Memo Header"."No.");
        SalesCrMemoHeader.SetRange("Return Order No.", "Sales Cr.Memo Header"."Return Order No.");
        if SalesCrMemoHeader.Find('-') then
            repeat
                SalesCrMemoLine2.SetRange("Document No.", SalesCrMemoHeader."No.");
                SalesCrMemoLine2.SetRange("Line No.", SalesCrMemoLine."Line No.");
                SalesCrMemoLine2.SetRange(Type, SalesCrMemoLine.Type);
                SalesCrMemoLine2.SetRange("No.", SalesCrMemoLine."No.");
                SalesCrMemoLine2.SetRange("Unit of Measure Code", SalesCrMemoLine."Unit of Measure Code");
                if SalesCrMemoLine2.Find('-') then
                    repeat
                        TotalQuantity := TotalQuantity + SalesCrMemoLine2.Quantity;
                    until SalesCrMemoLine2.Next() = 0;
            until SalesCrMemoHeader.Next() = 0;

        ReturnReceiptLine.SetCurrentKey("Return Order No.", "Return Order Line No.");
        ReturnReceiptLine.SetRange("Return Order No.", "Sales Cr.Memo Header"."Return Order No.");
        ReturnReceiptLine.SetRange("Return Order Line No.", SalesCrMemoLine."Line No.");
        ReturnReceiptLine.SetRange("Line No.", SalesCrMemoLine."Line No.");
        ReturnReceiptLine.SetRange(Type, SalesCrMemoLine.Type);
        ReturnReceiptLine.SetRange("No.", SalesCrMemoLine."No.");
        ReturnReceiptLine.SetRange("Unit of Measure Code", SalesCrMemoLine."Unit of Measure Code");
        ReturnReceiptLine.SetFilter(Quantity, '<>%1', 0);

        if ReturnReceiptLine.Find('-') then
            repeat
                if "Sales Cr.Memo Header"."Get Return Receipt Used" then
                    CorrectShipment(ReturnReceiptLine);
                if Abs(ReturnReceiptLine.Quantity) <= Abs(TotalQuantity - SalesCrMemoLine.Quantity) then
                    TotalQuantity := TotalQuantity - ReturnReceiptLine.Quantity
                else begin
                    if Abs(ReturnReceiptLine.Quantity) > Abs(TotalQuantity) then
                        ReturnReceiptLine.Quantity := TotalQuantity;
                    Quantity :=
                      ReturnReceiptLine.Quantity - (TotalQuantity - SalesCrMemoLine.Quantity);

                    SalesCrMemoLine.Quantity := SalesCrMemoLine.Quantity - Quantity;
                    TotalQuantity := TotalQuantity - ReturnReceiptLine.Quantity;

                    if ReturnReceiptHeader.Get(ReturnReceiptLine."Document No.") then begin
                        AddBufferEntry(
                          SalesCrMemoLine,
                          -Quantity,
                          ReturnReceiptHeader."Posting Date");
                    end;
                end;
            until (ReturnReceiptLine.Next() = 0) or (TotalQuantity = 0);
    end;

    local procedure CorrectShipment(var ReturnReceiptLine: Record "Return Receipt Line")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        SalesCrMemoLine.SetCurrentKey("Return Receipt No.", "Return Receipt Line No.");
        SalesCrMemoLine.SetRange("Return Receipt No.", ReturnReceiptLine."Document No.");
        SalesCrMemoLine.SetRange("Return Receipt Line No.", ReturnReceiptLine."Line No.");
        if SalesCrMemoLine.Find('-') then
            repeat
                ReturnReceiptLine.Quantity := ReturnReceiptLine.Quantity - SalesCrMemoLine.Quantity;
            until SalesCrMemoLine.Next() = 0;
    end;

    local procedure AddBufferEntry(SalesCrMemoLine: Record "Sales Cr.Memo Line"; QtyOnShipment: Decimal; PostingDate: Date)
    begin
        TempSalesShipmentBuffer.SetRange("Document No.", SalesCrMemoLine."Document No.");
        TempSalesShipmentBuffer.SetRange("Line No.", SalesCrMemoLine."Line No.");
        TempSalesShipmentBuffer.SetRange("Posting Date", PostingDate);
        if TempSalesShipmentBuffer.Find('-') then begin
            TempSalesShipmentBuffer.Quantity := TempSalesShipmentBuffer.Quantity - QtyOnShipment;
            TempSalesShipmentBuffer.Modify();
            exit;
        end;

        TempSalesShipmentBuffer.Init();
        TempSalesShipmentBuffer."Document No." := SalesCrMemoLine."Document No.";
        TempSalesShipmentBuffer."Line No." := SalesCrMemoLine."Line No.";
        TempSalesShipmentBuffer."Entry No." := NextEntryNo;
        TempSalesShipmentBuffer.Type := SalesCrMemoLine.Type;
        TempSalesShipmentBuffer."No." := SalesCrMemoLine."No.";
        TempSalesShipmentBuffer.Quantity := -QtyOnShipment;
        TempSalesShipmentBuffer."Posting Date" := PostingDate;
        TempSalesShipmentBuffer.Insert();
        NextEntryNo := NextEntryNo + 1
    end;

    local procedure DocumentCaption(): Text[250]
    begin
        if "Sales Cr.Memo Header"."Prepayment Credit Memo" then
            exit(Text011);
        exit(Text005);
    end;
}

