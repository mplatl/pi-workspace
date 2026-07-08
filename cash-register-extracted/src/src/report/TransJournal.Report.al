report 1070542 "CCS CASH Trans. Journal"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Rep1070542.CCSCASHTransJournal.rdl';
    Caption = 'Transaction Log';
    UsageCategory = None;

    dataset
    {
        dataitem("POS Transaction Header"; "CCS CASH POS Transaction Hdr.")
        {
            DataItemTableView = SORTING("Store No.", "POS Terminal No.", "Transaction No.") WHERE("Transaction Type" = FILTER(Sales | Return | Expense | Payment | "Remove Tender" | "Float Entry" | Startday | EndDay));
            RequestFilterFields = "Store No.", "POS Terminal No.", "Creation Date", "Transaction No.";
            column(CompanyName; CompanyName)
            {
            }
            column(EndOfDayCaption; EndOfDayCaptionLbl)
            {
            }
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
            {
            }
            column(TransactionFilter; TransactionFilter)
            {
            }
            column(StoreNo; "Store No.")
            {
            }
            column(TerminalNo; "POS Terminal No.")
            {
            }
            column("Date"; "Creation Date")
            {
            }
            column(TransNo; "Transaction No.")
            {
            }
            column(TransTime; "Creation Time")
            {
            }
            column(ReceiptNo; "Receipt No.")
            {
            }
            column(Type; "Transaction Type")
            {
            }
            column(Staff; "Staff ID")
            {
            }
            column(Amount; "Sales Amount")
            {
            }
            column(TotalAmount; TotalAmount)
            {
            }
            column(TotalCashAmount; TotalCashAmount)
            {
            }
            column(TotalTrans; TotalTrans)
            {
            }
            column(TotalPayment; TotalPayment)
            {
            }
            column(TotalReturn; TotalReturn)
            {
            }
            column(TotalExpense; TotalExpense)
            {
            }
            column(TotalRemove; TotalRemove)
            {
            }
            column(CashAmount; CashAmount)
            {
            }
            column(TransactionType; "Transaction Type")
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
            dataitem("Trans. Payment Entry"; "CCS CASH Trans. Payment Entry")
            {
                DataItemLink = "Store No." = FIELD("Store No."), "POS Terminal No." = FIELD("POS Terminal No."), "Transaction No." = FIELD("Transaction No.");
                DataItemTableView = SORTING("Store No.", "POS Terminal No.", "Transaction No.", "Line No.");

                trigger OnAfterGetRecord()
                begin
                    if "Cash entry" then begin
                        CashAmount += Amount;
                        TotalCashAmount += Amount;
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if Store.Get("POS Transaction Header"."Store No.") then;
                if (OldStoreNo <> "Store No.") or (OldTerminalNo <> "POS Terminal No.") or (OldDate <> "Creation Date") then begin
                    Clear(TotalTrans);
                    Clear(TotalPayment);
                    Clear(TotalReturn);
                    Clear(TotalExpense);
                    Clear(TotalRemove);
                    Clear(TotalAmount);
                    Clear(TotalCashAmount);
                end;

                Clear(CashAmount);

                TotalAmount := TotalAmount + "Amount incl. VAT";
                OldStoreNo := "Store No.";
                OldTerminalNo := "POS Terminal No.";
                OldDate := "Creation Date";

                if "Transaction Type" = "Transaction Type"::Sales then
                    TotalTrans := TotalTrans + 1;
                if "Transaction Type" = "Transaction Type"::Payment then
                    TotalPayment := TotalPayment + 1;
                if "Transaction Type" = "Transaction Type"::Return then
                    TotalReturn := TotalReturn + 1;
                if "Transaction Type" = "Transaction Type"::Expense then
                    TotalExpense := TotalExpense + 1;
                if ("Transaction Type" = "Transaction Type"::"Remove Tender") or ("Transaction Type" = "Transaction Type"::"Float Entry") then
                    TotalRemove := TotalRemove + 1;
            end;

            trigger OnPreDataItem()
            begin
                TransactionFilter := GetFilters;
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
        TransNoLbl = 'Trans. No.';
        TimeLbl = 'Time';
        NoLbl = 'KB No.';
        TypeLbl = 'Type';
        CashierLbl = 'Cashier';
        TotalLbl = 'Sales Revenue';
        CashLbl = 'Cash Amount';
        TotalTransLbl = 'Qty. Sales Trans.';
        TotalPaymentLbl = 'Qty. Payments';
        ReturnLbl = 'Qty. Returns';
        ExpenseLbl = 'Qty. Expenses';
        RemoveLbl = 'Qty. Levy / Deposits';
        TotalAmountLbl = 'Total';
    }

    var
        Store: Record "CCS CASH Store";
        EndOfDayCaptionLbl: Label 'Day Journal';
        CurrReportPageNoCaptionLbl: Label 'Page';
        TransactionFilter: Text;
        TotalTrans: Integer;
        TotalPayment: Integer;
        TotalReturn: Integer;
        TotalExpense: Integer;
        TotalRemove: Integer;
        TotalAmount: Decimal;
        TotalCashAmount: Decimal;
        OldStoreNo: Code[20];
        OldTerminalNo: Code[20];
        OldDate: Date;
        CashAmount: Decimal;
}