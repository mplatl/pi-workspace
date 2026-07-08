report 1070548 "CCS CASH Payment Conf A4"
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
    RDLCLayout = './src/report/Rep1070548.CCSCASHPaymentConfA4.rdl';

    Caption = 'Payment Confirmation A4';
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
            column(Picture1_Store; Store1.Picture)
            {
            }
            column(Picture2_Store; Store2.Picture)
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
            dataitem("Trans. Sales Entry"; "CCS CASH Trans. Sales Entry")
            {
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
                CrossAmount := -"Amount incl. VAT";
                HelpID := CopyStr(UserId, 1, MaxStrLen(HelpID));

                if Staff.Get("POS Transaction Header"."Staff ID") then;
                //IF Cust.GET("POS Transaction Header"."Customer No.") THEN
                CSLFunc.GetFormattedBonAdress("POS Transaction Header", CustAddr);
                //ELSE
                //  CustAddr[1] := 'BARVERKAUF';
                if Store.Get("POS Transaction Header"."Store No.") then
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

                Clear(OpenAmountTotal);
                DiscountAmount := DiscountAmount + "Payment Discount Amount";
                // >> AL-Umstellung
                CSLFunc.GetDocumentQRCode("Store No.", "POS Terminal No.", "Transaction No.", tempCASHDocumentInformation);
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
    end;

    var
        Item_Description_Lbl: Label 'Description';
        Item_Quantity_Lbl: Label 'Qty.';
        TerminalNo_Lbl: Label 'POS:';
        TransNo_Lbl: Label 'Transaction:';
        Time_Lbl: Label 'Date:';
        CustNo_Lbl: Label 'Customer No.:';
        Price_Lbl: Label 'Balance';
        Tender_Lbl: Label 'Payments:';
        TotalCaptionLbl: Label 'Total';
        CompanyInfo: Record "Company Information";
        Staff: Record "CCS CASH Staff";
        CustAddr: array[8] of Text[50];
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
        DiscountLbl: Label '-less Cash Discount';
        Total2Lbl: Label 'Payment Amount';
        TotalLbl: Label 'Total Balance';
        Store1: Record "CCS CASH Store";
        Store2: Record "CCS CASH Store";
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