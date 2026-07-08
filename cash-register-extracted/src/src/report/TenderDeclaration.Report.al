report 1070543 "CCS CASH Tender Declaration"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Rep1070543.CCSCASHTenderDeclaration.rdl';
    Caption = 'Tender Operation';
    UsageCategory = None;

    dataset
    {
        dataitem("POS Transaction Header"; "CCS CASH POS Transaction Hdr.")
        {
            DataItemTableView = SORTING("Store No.", "POS Terminal No.", "Transaction No.");
            RequestFilterFields = "Store No.", "POS Terminal No.", "Transaction No.";
            column(CompanyName; CompanyName)
            {
            }
            column(TenderDeclarationCaption; TenderDeclarationCaptionLbl)
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
            column(TransNo; "Transaction No.")
            {
            }
            column(TotalAmount; TotalAmount)
            {
            }
            column("Date"; "Creation Date")
            {
            }
            column(TransTime; "Creation Time")
            {
            }
            column(Staff; "Staff ID")
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
            dataitem("Trans. Cash Declaration Entry"; "CCS CASH Trans. Cash Decl. E.")
            {
                DataItemLink = "Store No." = FIELD("Store No."), "POS Terminal No." = FIELD("POS Terminal No."), "Transaction No." = FIELD("Transaction No.");
                DataItemTableView = SORTING("Store No.", "POS Terminal No.", "Transaction No.", "Decl. Key", "Line No.") WHERE(Quantity = FILTER(<> 0));
                column(Quantity; Quantity)
                {
                }
                column(BaseAmount; "Base Amount")
                {
                }
                column(Amount; Amount)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    TotalAmount := TotalAmount + Amount;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if Store.Get("POS Transaction Header"."Store No.") then;
                Clear(TotalAmount);
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
        DateLbl = 'Date';
        TimeLbl = 'Time';
        CashierLbl = 'Cashier';
        TotalLbl = 'Base Amount';
        CashLbl = 'Amount';
        QuantityLbl = 'Quantity';
        TotalAmountLbl = 'Total';
    }

    var
        Store: Record "CCS CASH Store";
        TenderDeclarationCaptionLbl: Label 'Tender Operation';
        CurrReportPageNoCaptionLbl: Label 'Page';
        TransactionFilter: Text;
        TotalAmount: Decimal;
}