report 1070553 "CCS CASH Voucher - POS Receipt"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Rep1070553.CCSCASHVoucherPOSReceipt.rdl';
    Caption = 'Voucher - POS';
    UsageCategory = None;

    dataset
    {
        dataitem("POS Transaction Header"; "CCS CASH POS Transaction Hdr.")
        {
            DataItemTableView = SORTING("Store No.", "POS Terminal No.", "Transaction No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Store No.", "POS Terminal No.", "Transaction No.";
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
            column(Text50010; Text50010)
            {
            }
            column(PostingDate; "Creation Date")
            {
            }
            column(PostingTime; Format("Creation Time", 0, '<Hours24,2><Filler Character,0>:<Minutes,2>'))
            {
            }
            column(TransNo; "Transaction No.")
            {
            }
            column(VATRegistrationNo_CompInfo; CompanyInfo."VAT Registration No.")
            {
            }
            column(CurrLbl; CurrLbl)
            {
            }
            column(Picture_Store; Store.Picture)
            {
            }
            column(TransactionType; "Transaction Type")
            {
            }
            dataitem("Voucher Entry"; "CCS CASH Voucher Entry")
            {
                DataItemLink = "Store No." = FIELD("Store No."), "POS Terminal No" = FIELD("POS Terminal No."), "Transaction No." = FIELD("Transaction No.");
                DataItemTableView = SORTING("Voucher No.", "Entry No.") WHERE("Entry Type" = FILTER(Issued));
                column(VoucherNo; "Voucher No.")
                {
                }
                column(VoucherCardNo; "Voucher Card No.")
                {
                }
                column(Amount; Amount)
                {
                }
                column(Barcode; Barcode)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Barcode := '*' + "Voucher No." + '*';
                end;

                trigger OnPreDataItem()
                begin
                    Clear(Barcode);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if Store.Get("POS Transaction Header"."Store No.") then
                    if Store."Logo Position on Documents" <> Store."Logo Position on Documents"::"No Logo" then
                        Store.CalcFields(Picture);
            end;
        }
    }

    requestpage
    {

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
        CompanyInfo: Record "Company Information";
        Store: Record "CCS CASH Store";
        Barcode: Code[22];
        StoreNo_Lbl: Label 'Store:';
        TerminalNo_Lbl: Label 'POS:';
        TransNo_Lbl: Label 'Transaction:';
        ReceiptNo_Lbl: Label 'Receipt No.:';
        Time_Lbl: Label 'Date:';
        Text50011: Label 'Cashier:';
        Text50010: Label 'Voucher';
        CurrLbl: Label 'EUR';
}

