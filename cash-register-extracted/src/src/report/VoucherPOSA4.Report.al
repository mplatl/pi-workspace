report 1070552 "CCS CASH Voucher - POS A4"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Rep1070552.CCSCASHVoucherPOSA4.rdl';
    Caption = 'Voucher - POS A4';
    UsageCategory = None;

    dataset
    {
        dataitem("POS Transaction Header"; "CCS CASH POS Transaction Hdr.")
        {
            DataItemTableView = SORTING("Store No.", "POS Terminal No.", "Transaction No.");
            PrintOnlyIfDetail = true;
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
            column(Picture1_Store; Store1.Picture)
            {
            }
            column(Picture2_Store; Store2.Picture)
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
        Store1: Record "CCS CASH Store";
        Store2: Record "CCS CASH Store";
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