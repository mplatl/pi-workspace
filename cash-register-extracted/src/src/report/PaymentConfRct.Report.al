report 1070546 "CCS CASH Payment Conf Rct"
{
    // fs-soft(small changes)
    // 
    // Vers. Date       ID Description
    // _____________________________________________________________________
    // A0200 19.01.2016 GT (Object created):
    // 
    // POS0006 08.07.16
    //   Changed Format und Sumfields
    // POS0029 07.02.17 FS Field Name Change "Print QR Position" -> EfstaSetup."Picture Print Position"
    //                     Field Name Change "Picture for Print" -> EfstaSetup."Picture PrintOption"
    // EFSTA2.00  30.11.2016 MK QR Code added
    // EFSTA2.05  22.02.2017 MK Added Code to Recreate QR Picture if needed
    // EFSTA2.07  30.03.2017 MK Changes because Printing with no active WebService Setup was not possible
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Rep1070546.CCSCASHPaymentConfRct.rdl';

    Caption = 'Payment Confirmation - POS';
    Permissions = TableData "Sales Shipment Buffer" = rimd;
    UsageCategory = None;

    dataset
    {
        dataitem("POS Transaction Header"; "CCS CASH POS Transaction Hdr.")
        {
            CalcFields = "Amount excl. VAT", "Amount incl. VAT";
            column(Picture_Store; Store.Picture)
            {
            }
            column(LogoPosition; LogoPosition)
            {
            }

            column(TransNo; "Transaction No.")
            {
            }
            column(Sales_Invoice_Header___Bill_to_Customer_No__; "Customer No.")
            {
            }
            column(Sales_Invoice_Header___Bill_to_Customer_No__Caption; CustNo_Lbl)
            {
            }
            column(Text50011; Text50011)
            {
            }
            column(HelpID; HelpID)
            {
            }
            column(Text50010; Text50010)
            {
            }
            column(Time_Lbl; Time_Lbl)
            {
            }
            column(PostingDate; "Creation Date")
            {
            }
            column(PostingTime; Format("Creation Time", 0, '<Hours24,2><Filler Character,0>:<Minutes,2>'))
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            column(TotalCaption2; TotalCaption2Lbl)
            {
            }
            column(GrossTotal; CrossAmount)
            {
            }
            column(StaffID; "Staff ID")
            {
            }
            column(NameOnReceipt; Staff."Name on Receipt")
            {
            }
            column(TransNoCaption; TransNo_Lbl)
            {
            }
            column(ReceiptNo; "Receipt No.")
            {
            }
            column(TerminalNoCaption; TerminalNo_Lbl)
            {
            }
            column(TerminalNo; "POS Terminal No.")
            {
            }
            column(VATRegistrationNo_CompInfo; CompanyInfo."VAT Registration No.")
            {
            }
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
            column(Discount; DiscountAmount)
            {
            }
            column(DiscountCaption; DiscountLbl)
            {
            }
            column(TotalCap2; Total2Lbl)
            {
            }
            column(TotalCap; TotalLbl)
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
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(OutputNo; OutputNo)
                {
                }

                dataitem("Trans. Sales Entry"; "CCS CASH Trans. Sales Entry")
                {
                    DataItemLinkReference = "POS Transaction Header";
                    DataItemLink = "Transaction No." = FIELD("Transaction No."), "Store No." = FIELD("Store No."), "POS Terminal No." = FIELD("POS Terminal No.");
                    DataItemTableView = SORTING("Store No.", "POS Terminal No.", "Transaction No.", "Entry No.");
                    column(Sales_LineNo; "Entry No.")
                    {
                    }
                    column(Sales_ItemDescription; Description)
                    {
                    }
                    column(Sales_ItemNo; "No.")
                    {
                    }
                    column(OpenAmount; OpenAmount)
                    {
                    }
                    column(NetDiscountAmount; "Line Discount Amt.")
                    {
                    }
                    column(Item_Description_Lbl; Item_Description_Lbl)
                    {
                    }
                    column(Item_Quantity_Lbl; Item_Quantity_Lbl)
                    {
                    }
                    column(Price_Lbl; Price_Lbl)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Clear(OpenAmount);
                        //CustLedg.GET("Entry No.");
                        //CustLedg.CALCFIELDS("Remaining Amount");
                        OpenAmount := -"Amount incl. VAT";
                        OpenAmountTotal := OpenAmountTotal + OpenAmount;
                    end;
                }
                dataitem("Trans. Payment Entry"; "CCS CASH Trans. Payment Entry")
                {
                    DataItemLinkReference = "POS Transaction Header";
                    DataItemLink = "Transaction No." = FIELD("Transaction No."), "Store No." = FIELD("Store No."), "POS Terminal No." = FIELD("POS Terminal No.");
                    DataItemTableView = SORTING("Store No.", "POS Terminal No.", "Transaction No.", "Line No.");
                    column(OpenAmountTotal; OpenAmountTotal)
                    {
                    }
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
                    begin
                        Clear(TenderDescription);
                        TenderDescription := "Tender Description";
                        if TenderTypeCardSetup.Get("POS Transaction Header"."Store No.", "Tender Type", "Card No.") then
                            TenderDescription := TenderTypeCardSetup.Description;
                        OpenAmountTotal := OpenAmountTotal - Amount;
                    end;

                    trigger OnPreDataItem()
                    begin
                        OpenAmountTotal := OpenAmountTotal + "POS Transaction Header"."Payment Discount Amount";
                    end;
                }
                dataitem(AfterText; "Extended Text Line")
                {
                    DataItemLinkReference = "POS Transaction Header";
                    DataItemTableView = SORTING("Table Name", "No.", "Language Code", "Text No.", "Line No.") ORDER(Ascending);
                    column(Text_AfterText; Text)
                    {
                    }

                    trigger OnPreDataItem()
                    var
                        locStore: Record "CCS CASH Store";
                    begin
                        if locStore.Get("POS Transaction Header"."Store No.") then
                            if locStore."Aftertext Payment Conf." <> '' then
                                SetRange("No.", locStore."Aftertext Payment Conf.")
                            else
                                CurrReport.Break();
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if Number > 1 then begin
                        OutputNo += 1;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(GNoOfCopies) + 1;
                    SetRange(Number, 1, NoOfLoops);
                    OutputNo := 1;
                end;
            }
            trigger OnAfterGetRecord()
            begin
                CrossAmount := -"Amount incl. VAT";
                HelpID := CopyStr(UserId, 1, MaxStrLen(HelpID));

                if Staff.Get("POS Transaction Header"."Staff ID") then;
                //IF Cust.GET("POS Transaction Header"."Customer No.") THEN
                CSLFunc.GetFormattedBonAdress("POS Transaction Header", CustAddr);
                //ELSE
                //  CustAddr[1] := 'BARVERKAUF';

                if Store.Get("POS Transaction Header"."Store No.") then
                    if Store."Logo Position on Documents" <> Store."Logo Position on Documents"::"No Logo" then
                        Store.CalcFields(Picture);
                LogoPosition := Store."Logo Position on Documents";

                Staff.SetLoadFields("Name on Receipt");
                if not Staff.Get("POS Transaction Header"."Staff ID") then
                    Staff."Name on Receipt" := "POS Transaction Header"."Staff ID";
                if Staff."Name on Receipt" = '' then
                    Staff."Name on Receipt" := "POS Transaction Header"."Staff ID";

                Clear(OpenAmountTotal);
                DiscountAmount := DiscountAmount + "Payment Discount Amount";

                GLSetup.TestField("LCY Code");
                Total2Lbl := StrSubstNo(Text000, GLSetup."LCY Code");

                CSLFunc.GetDocumentQRCode("Store No.", "POS Terminal No.", "Transaction No.", tempCASHDocumentInformation);
            end;

            trigger OnPreDataItem()
            begin
                CompanyInfo.CalcFields(Picture);
                Clear(DiscountAmount);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
        GLSetup.Get();
        CCSCashSalesSetup.Get();
        GNoOfCopies := CCSCashSalesSetup."Cust. Payment Copies";
    end;

    var
        Text000: Label 'Payment Amount %1', Comment = '%1=Currency Code';
        GLSetup: Record "General Ledger Setup";
        Item_Description_Lbl: Label 'Description';
        Item_Quantity_Lbl: Label 'Qty.';
        TerminalNo_Lbl: Label 'POS:';
        TransNo_Lbl: Label 'Transaction:';
        Time_Lbl: Label 'Date/Time:';
        CustNo_Lbl: Label 'Customer No.:';
        Price_Lbl: Label 'Balance';
        Tender_Lbl: Label 'Payments:';
        TotalCaptionLbl: Label 'Total';
        CompanyInfo: Record "Company Information";
        Staff: Record "CCS CASH Staff";
        CCSCashSalesSetup: Record "CCS CASH Cash Sales Setup";
        GNoOfCopies: Integer;
        NoOfLoops: Integer;
        CustAddr: array[8] of Text[50];
        LogoPosition: Enum "CCS CASH Logo Position on Doc.";
        Store: Record "CCS CASH Store";
        TenderDescription: Text[50];
        TotalCaption2Lbl: Label 'outstanding balance from the assets above';
        Text50011: Label 'Cashier';
        HelpID: Text[50];
        Text50010: Label 'Payment Confirmation: ';
        CrossAmount: Decimal;
        TenderTypeCardSetup: Record "CCS CASH Tender Type C. Setup";
        OpenAmount: Decimal;
        OpenAmountTotal: Decimal;
        DiscountAmount: Decimal;
        OutputNo: Integer;
        DiscountLbl: Label '-less Cash Discount';
        Total2Lbl: Text[50];
        TotalLbl: Label 'Total Balance';
        CSLFunc: Codeunit "CCS CASH POS Register Func";
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
}