report 1070549 "CCS CASH Start Day - POS A4"
{
    // fs-soft(small changes)
    // 
    // Vers. Date       ID Description
    // _____________________________________________________________________
    // A0200 19.01.2016 GT (Object created):
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Rep1070549.CCSCASHStartDayPOSA4.rdl';

    Caption = 'Money Transfer POS A4';
    Permissions = TableData "Sales Shipment Buffer" = rimd;
    UsageCategory = None;

    dataset
    {
        dataitem("POS Transaction Header"; "CCS CASH POS Transaction Hdr.")
        {
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
            column(Text50011; Text50011)
            {
            }
            column(Text50010; HeaderText)
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
            column(NetTotal; "Amount excl. VAT")
            {
            }
            column(VATTotal; "Amount incl. VAT" - "Amount excl. VAT")
            {
            }
            column(GrossTotal; "Amount incl. VAT")
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
            column(SignatureCaption; Signature_Lbl)
            {
            }
            column(TotalMoney; TotalMoney)
            {
            }
            column(ActualAmountCaption; ActualAmountLbl)
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
            column(TransactionType; "Transaction Type")
            {
            }
            dataitem("Trans. Payment Entry"; "CCS CASH Trans. Payment Entry")
            {
                DataItemLink = "Transaction No." = FIELD("Transaction No."), "Store No." = FIELD("Store No."), "POS Terminal No." = FIELD("POS Terminal No.");
                DataItemTableView = SORTING("Store No.", "POS Terminal No.", "Transaction No.", "Line No.") WHERE("Cash entry" = FILTER(true));
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
                column(TP_AmountLbl; Amount_Lbl)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(TenderDescription);
                    if TenderType.Get("POS Transaction Header"."Store No.", "Tender Type") then
                        TenderDescription := TenderType.Description;
                    TenderDescription := "Tender Description";
                end;
            }

            trigger OnAfterGetRecord()
            begin
                POSTerminal.Get("Store No.", "POS Terminal No.");
                POSTerminal.CalcFields(Balance);
                TotalMoney := POSTerminal.Balance;

                if Staff.Get("POS Transaction Header"."Staff ID") then;
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

                HeaderText := Text50010;

                if "Transaction Type" = "Transaction Type"::"Remove Tender" then
                    HeaderText := Text50012;
                if "Transaction Type" = "Transaction Type"::"Float Entry" then
                    HeaderText := Text50013;
                if "Transaction Type" = "Transaction Type"::Expense then
                    HeaderText := Text50014;
            end;

            trigger OnPreDataItem()
            begin
                Clear(TotalMoney);
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

    protected var
        HeaderText: Text[50];

    var
        TerminalNo_Lbl: Label 'POS:';
        TransNo_Lbl: Label 'Transaction:';
        Time_Lbl: Label 'Date:';
        TotalCaptionLbl: Label 'Total';
        Staff: Record "CCS CASH Staff";
        Store: Record "CCS CASH Store";
        TenderDescription: Text[50];
        TenderType: Record "CCS CASH Store Tender Type";
        Text50011: Label 'Cashier';
        Text50010: Label 'Deposit';
        Text50012: Label 'Equalisation Levy';
        Text50013: Label 'Change Entry';
        Text50014: Label 'Expenditure';
        Tender_Lbl: Label 'Payment Method';
        Amount_Lbl: Label 'Amount';
        Signature_Lbl: Label 'Signature';
        POSTerminal: Record "CCS CASH POS Terminal";
        TotalMoney: Decimal;
        ActualAmountLbl: Label 'Current POS Amount:';
        CompanyInfo: Record "Company Information";
        Store1: Record "CCS CASH Store";
        Store2: Record "CCS CASH Store";
}