report 1070545 "CCS CASH End Day - POS"
{
    // POS0002 28.06.16
    //   Transaction No. 4 -> 10 Length
    // POS0011 21.07.16
    //   Split Sales Into Sales and Payment
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/Rep1070545.CCSCASHEndDayPOS.rdl';

    Caption = 'Day End - POS';
    UsageCategory = None;

    dataset
    {
        dataitem("POS Transaction Header"; "CCS CASH POS Transaction Hdr.")
        {

            trigger OnAfterGetRecord()
            begin
                EndTransactionNo := "Transaction No.";
                HelpTime := "Creation Time";
                HelpPosTrans.SetRange("Store No.", GStoreFilter);
                HelpPosTrans.SetRange("POS Terminal No.", GTerminalFilter);
                HelpPosTrans.SetFilter("Transaction No.", '..%1', "Transaction No.");
                HelpPosTrans.SetRange("Transaction Type", "Transaction Type"::Startday);
                if HelpPosTrans.FindLast() then
                    StartTransactionNo := HelpPosTrans."Transaction No.";
                Terminal.Get(GStoreFilter, GTerminalFilter);
                Terminal.SetFilter("Transaction No. Filter", '..%1', StartTransactionNo - 1);
                Terminal.CalcFields("Balance at Transaction");
                TotalStart := Terminal."Balance at Transaction";
                Terminal.SetFilter("Transaction No. Filter", '..%1', EndTransactionNo);
                Terminal.CalcFields("Balance at Transaction");
                TotalEnd := Terminal."Balance at Transaction";
                TotalStartDayEnd := TotalStart;

                if GDateFilter = 0D then
                    GDateFilter := "Creation Date";
            end;

            trigger OnPreDataItem()
            begin
                GStoreFilter := CopyStr(GetFilter("Store No."), 1, MaxStrLen(GStoreFilter));
                GTerminalFilter := CopyStr(GetFilter("POS Terminal No."), 1, MaxStrLen(GTerminalFilter));
                if GetFilter("Creation Date") <> '' then
                    GDateFilter := GetRangeMax("Creation Date");
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = sorting(Number);
            MaxIteration = 1;
            column(HelpTime; HelpTime)
            {
            }
            column(EndTransactionNo; EndTransactionNo)
            {
            }
            column(StoreFilter; GStoreFilter)
            {
            }
            column(TerminalFilter; GTerminalFilter)
            {
            }
            column(DateFilter; GDateFilter)
            {
            }
            column(POSStartAmount; TotalStart)
            {
            }
            column(POSEndDayAmount; TotalEndDayEnd)
            {
            }
            column(POSStartDayAmount; TotalStartDayEnd)
            {
            }
            column(POSEndAmount; TotalEnd)
            {
            }
            column(CompanyName; CompanyName)
            {
            }
            column(EoDCaption; EoDCaptionLbl)
            {
            }
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
            {
            }
            column(ReceiptNoCaption; ReceiptLbl)
            {
            }
            column(ReceiptNo; "POS Transaction Header"."Receipt No.")
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
            column(Signature_Loaded; SignatureLoaded)
            {
            }
            dataitem(StartDay; "CCS CASH POS Transaction Hdr.")
            {
                DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.");
                dataitem("StartDay Entry"; "CCS CASH Trans. Payment Entry")
                {
                    DataItemLink = "Store No." = field("Store No."), "POS Terminal No." = field("POS Terminal No."), "Transaction No." = field("Transaction No.");
                    DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.", "Line No.") WHERE("Cash entry" = FILTER(true));
                    column(Description_StartDay; "Tender Description")
                    {
                    }
                    column(Amount_StartDay; Amount)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        TotalStartDayEnd := TotalStartDayEnd + Amount;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if "Transaction Type" <> "Transaction Type"::Startday then
                        CurrReport.Skip();
                end;

                trigger OnPostDataItem()
                begin
                    TotalEndDayEnd := TotalStartDayEnd;
                end;

                trigger OnPreDataItem()
                begin
                    SetFilter("Store No.", GStoreFilter);
                    SetFilter("POS Terminal No.", GTerminalFilter);
                    SetFilter("Transaction No.", '%1..%2', StartTransactionNo, EndTransactionNo);
                    Clear(TotalFloat);
                end;
            }
            dataitem(Sales; "CCS CASH POS Transaction Hdr.")
            {
                DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.");
                dataitem("Sales Entry"; "CCS CASH Trans. Payment Entry")
                {
                    DataItemLink = "Store No." = field("Store No."), "POS Terminal No." = field("POS Terminal No."), "Transaction No." = field("Transaction No.");
                    DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.", "Line No.") WHERE("Cash entry" = FILTER(true));
                    column(TotalSales; TotalSales)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        TotalSales := TotalSales + Amount;
                        TotalEndDayEnd := TotalEndDayEnd + Amount;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if not ("Transaction Type" in ["Transaction Type"::Sales, "Transaction Type"::Return]) then
                        CurrReport.Skip();
                end;

                trigger OnPreDataItem()
                begin
                    SetFilter("Store No.", GStoreFilter);
                    SetFilter("POS Terminal No.", GTerminalFilter);
                    SetFilter("Transaction No.", '%1..%2', StartTransactionNo, EndTransactionNo);
                    Clear(TotalSales);
                end;
            }
            dataitem(Payment; "CCS CASH POS Transaction Hdr.")
            {
                DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.");
                dataitem("Payment Entry"; "CCS CASH Trans. Payment Entry")
                {
                    DataItemLink = "Store No." = field("Store No."), "POS Terminal No." = field("POS Terminal No."), "Transaction No." = field("Transaction No.");
                    DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.", "Line No.") WHERE("Cash entry" = FILTER(true));
                    column(TotalPayment; TotalPayment)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        TotalPayment := TotalPayment + Amount;
                        TotalEndDayEnd := TotalEndDayEnd + Amount;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if not ("Transaction Type" in ["Transaction Type"::Payment]) then
                        CurrReport.Skip();
                end;

                trigger OnPreDataItem()
                begin
                    SetFilter("Store No.", GStoreFilter);
                    SetFilter("POS Terminal No.", GTerminalFilter);
                    SetFilter("Transaction No.", '%1..%2', StartTransactionNo, EndTransactionNo);
                    Clear(TotalPayment);
                end;
            }
            dataitem(Expense; "CCS CASH POS Transaction Hdr.")
            {
                DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.");
                dataitem("Expense Entry"; "CCS CASH Trans. Payment Entry")
                {
                    DataItemLink = "Store No." = field("Store No."), "POS Terminal No." = field("POS Terminal No."), "Transaction No." = field("Transaction No.");
                    DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.", "Line No.") WHERE("Cash entry" = FILTER(true));
                    column(TotalExpense; TotalExpense)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        TotalExpense := TotalExpense + Amount;
                        TotalEndDayEnd := TotalEndDayEnd + Amount;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if "Transaction Type" <> "Transaction Type"::Expense then
                        CurrReport.Skip();
                end;

                trigger OnPreDataItem()
                begin
                    SetFilter("Store No.", GStoreFilter);
                    SetFilter("POS Terminal No.", GTerminalFilter);
                    SetFilter("Transaction No.", '%1..%2', StartTransactionNo, EndTransactionNo);
                    Clear(TotalExpense);
                end;
            }
            dataitem(Deposit; "CCS CASH POS Transaction Hdr.")
            {
                DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.");
                dataitem("Deposit Entry"; "CCS CASH Trans. Payment Entry")
                {
                    DataItemLink = "Store No." = field("Store No."), "POS Terminal No." = field("POS Terminal No."), "Transaction No." = field("Transaction No.");
                    DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.", "Line No.") WHERE("Cash entry" = FILTER(true));
                    column(TotalDeposit; TotalDeposit)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        TotalDeposit := TotalDeposit + Amount;
                        TotalEndDayEnd := TotalEndDayEnd + Amount;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if "Transaction Type" <> "Transaction Type"::Deposit then
                        CurrReport.Skip();
                end;

                trigger OnPreDataItem()
                begin
                    SetFilter("Store No.", GStoreFilter);
                    SetFilter("POS Terminal No.", GTerminalFilter);
                    SetFilter("Transaction No.", '%1..%2', StartTransactionNo, EndTransactionNo);
                    Clear(TotalDeposit);
                end;
            }
            dataitem(Remove; "CCS CASH POS Transaction Hdr.")
            {
                DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.");
                dataitem("Remove Entry"; "CCS CASH Trans. Payment Entry")
                {
                    DataItemLink = "Store No." = field("Store No."), "POS Terminal No." = field("POS Terminal No."), "Transaction No." = field("Transaction No.");
                    DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.", "Line No.") WHERE("Cash entry" = FILTER(true));
                    column(TotalRemove; TotalRemove)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        TotalRemove := TotalRemove + Amount;
                        TotalEndDayEnd := TotalEndDayEnd + Amount;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if "Transaction Type" <> "Transaction Type"::"Remove Tender" then
                        CurrReport.Skip();
                end;

                trigger OnPreDataItem()
                begin
                    SetFilter("Store No.", GStoreFilter);
                    SetFilter("POS Terminal No.", GTerminalFilter);
                    SetFilter("Transaction No.", '%1..%2', StartTransactionNo, EndTransactionNo);
                    Clear(TotalRemove);
                end;
            }
            dataitem(Float; "CCS CASH POS Transaction Hdr.")
            {
                DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.");
                dataitem("Float Entry"; "CCS CASH Trans. Payment Entry")
                {
                    DataItemLink = "Store No." = field("Store No."), "POS Terminal No." = field("POS Terminal No."), "Transaction No." = field("Transaction No.");
                    DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.", "Line No.") WHERE("Cash entry" = FILTER(true));
                    column(TotalFloat; TotalFloat)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        TotalFloat := TotalFloat + Amount;
                        TotalEndDayEnd := TotalEndDayEnd + Amount;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if "Transaction Type" <> "Transaction Type"::"Float Entry" then
                        CurrReport.Skip();
                end;

                trigger OnPreDataItem()
                begin
                    SetFilter("Store No.", GStoreFilter);
                    SetFilter("POS Terminal No.", GTerminalFilter);
                    SetFilter("Transaction No.", '%1..%2', StartTransactionNo, EndTransactionNo);
                    Clear(TotalFloat);
                end;
            }
            dataitem(EndDay; "CCS CASH POS Transaction Hdr.")
            {
                DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.");
                dataitem("EndDay Entry"; "CCS CASH Trans. Payment Entry")
                {
                    DataItemLink = "Store No." = field("Store No."), "POS Terminal No." = field("POS Terminal No."), "Transaction No." = field("Transaction No.");
                    DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.", "Line No.") WHERE("Cash entry" = FILTER(true));
                    column(Description_EndDay; "Tender Description")
                    {
                    }
                    column(Amount_EndDay; Amount)
                    {
                    }
                }

                trigger OnAfterGetRecord()
                var
                    PosRegFunc: Codeunit "CCS CASH POS Register Func";
                begin
                    if "Transaction Type" <> "Transaction Type"::EndDay then
                        CurrReport.Skip();

                    PosRegFunc.GetDocumentQRCode("Store No.", "POS Terminal No.", "Transaction No.", tempCASHDocumentInformation);
                    SignatureLoaded := true;
                end;

                trigger OnPreDataItem()
                begin
                    SetFilter("Store No.", GStoreFilter);
                    SetFilter("POS Terminal No.", GTerminalFilter);
                    SetFilter("Transaction No.", '%1..%2', StartTransactionNo, EndTransactionNo);
                    Clear(TotalFloat);
                end;
            }
            dataitem(NotCash; "CCS CASH POS Transaction Hdr.")
            {
                DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.");
                dataitem("NotCash Entry"; "CCS CASH Trans. Payment Entry")
                {
                    DataItemLink = "Store No." = field("Store No."), "POS Terminal No." = field("POS Terminal No."), "Transaction No." = field("Transaction No.");
                    DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.", "Line No.") WHERE("Cash entry" = FILTER(false));
                    column(TenderType_NotCash; "Tender Type")
                    {
                    }
                    column(Amount_NotCash; Amount)
                    {
                    }
                    column(TotalNotCash; TotalNotCash)
                    {
                    }
                    column(CardNoNotCash; "Card No.")
                    {
                    }
                    column(DescriptionNotCash; TempTenderTypeCardSetup.Description)
                    {
                    }
                    column(CountTransaction; TempTenderTypeCardSetup.CountTransaction)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if ("Tender Type" = '09') or ("Tender Type" = '9') then
                            CurrReport.Skip();
                        if TenderTypeCardSetup.Get(GStoreFilter, "Tender Type", "Card No.") then
                            TenderDescription := TenderTypeCardSetup.Description
                        else
                            Clear(TenderDescription);
                        TempTenderTypeCardSetup."Store No" := GStoreFilter;
                        TempTenderTypeCardSetup."Tender Type" := "Tender Type";
                        TempTenderTypeCardSetup."Card No." := "Card No.";
                        TempTenderTypeCardSetup.Description := TenderDescription;
                        TempTenderTypeCardSetup.CountTransaction := 1;
                        if not TempTenderTypeCardSetup.Insert() then begin
                            TempTenderTypeCardSetup.CountTransaction += 1;
                            TempTenderTypeCardSetup.Modify();
                        end;
                        TotalNotCash := TotalNotCash + Amount;
                    end;
                }

                trigger OnPreDataItem()
                begin
                    SetFilter("Store No.", GStoreFilter);
                    SetFilter("POS Terminal No.", GTerminalFilter);
                    SetFilter("Transaction No.", '%1..%2', StartTransactionNo, EndTransactionNo);
                    Clear(TotalNotCash);
                    Clear(TenderTypeCardSetup);
                end;
            }
            dataitem(VAT; "CCS CASH POS Transaction Hdr.")
            {
                DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.");
                dataitem("VAT Entry"; "CCS CASH Trans. Sales Entry")
                {
                    DataItemLink = "Store No." = field("Store No."), "POS Terminal No." = field("POS Terminal No."), "Transaction No." = field("Transaction No.");
                    DataItemTableView = sorting("Store No.", "POS Terminal No.", "Transaction No.", "Entry No.");
                    column(TotalVat; TotalVat)
                    {
                    }
                    column(TotalAmount; -TotalAmount)
                    {
                    }
                    column(TotalAmountinclVat; -TotalAmountinclVat)
                    {
                    }
                    column(VatPercent_Vat; HelpIdentifier)
                    {
                    }
                    column(Amount_Vat; -Amount)
                    {
                    }
                    column(AmountinclVat_Vat; -"Amount incl. VAT")
                    {
                    }
                    column(VatAmount_Vat; "VAT Amount")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        TotalVat := TotalVat + "VAT Amount";
                        TotalAmount := TotalAmount + Amount;
                        TotalAmountinclVat := TotalAmountinclVat + "Amount incl. VAT";
                        if Amount = "Amount incl. VAT" then
                            HelpIdentifier := 0
                        else
                            HelpIdentifier := "VAT %";
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if not ("Transaction Type" in ["Transaction Type"::Sales, "Transaction Type"::Return]) then
                        CurrReport.Skip();
                end;

                trigger OnPreDataItem()
                begin
                    SetFilter("Store No.", GStoreFilter);
                    SetFilter("POS Terminal No.", GTerminalFilter);
                    SetFilter("Transaction No.", '%1..%2', StartTransactionNo, EndTransactionNo);
                    SetFilter("Receipt No.", '<>%1', '');
                    Clear(TotalVat);
                    Clear(TotalAmount);
                    Clear(TotalAmountinclVat);
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    Visible = false;
                    field(StoreFilter; GStoreFilter)
                    {
                        Caption = 'Store';
                        TableRelation = "CCS CASH Store"."No.";
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Store field.';
                    }
                    field(TerminalFilter; GTerminalFilter)
                    {
                        Caption = 'Terminal No.';
                        TableRelation = "CCS CASH POS Terminal"."No.";
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Terminal No. field.';
                    }
                    field(DateFilter; GDateFilter)
                    {
                        Caption = 'Date';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Date field.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        StoreLbl = 'Store';
        TerminalLbl = 'POS';
        DateLbl = 'Date';
        TerminalStartAmountLbl = 'POS Start Amount';
        TerminalEndAmountLbl = 'POS End Amount';
        SalesLbl = 'Sales Revenue';
        ExpenseLbl = 'Expenses';
        DepositLbl = 'Deposits';
        RemoveLbl = 'Equalisation Levy';
        FloatLbl = 'Change Entry';
        DifferenceLbl = 'Deviation';
        POSEndAmountLbl = 'POS Amount before end of day';
        NotCashLbl = 'Non-Cash Revenue';
        AmountLbl = 'Net Amount';
        AmountinclVatLbl = 'Gross Amount';
        VatPercentLbl = 'VAT %';
        Vat = 'VAT Amount';
        POSStartAmountLbl = 'POS Amount after end of day';
        CashStartLbl = 'Start Cash';
        CashEndLbl = 'End Cash';
        SalesVATLbl = 'Sales';
        NotCashLbl2 = 'Payment Type/Card No.';
        NotCashLbl3 = '# Trans.';
        NotCashLbl4 = 'Amount';
        TransNoLbl = 'Trans. No.';
        PaymentLbl = 'Revenue Payments';
    }

    trigger OnPreReport()
    begin
        /*
        Terminal.GET(StoreFilter,TerminalFilter);
        Terminal.SETFILTER("Date Filter",'..%1',DateFilter-1);
        Terminal.CalcFields("Balance at Date");
        TotalStart := Terminal."Balance at Date";
        Terminal.SETFILTER("Date Filter",'..%1',DateFilter);
        Terminal.CalcFields("Balance at Date");
        TotalEnd := Terminal."Balance at Date";
        TotalEndDayEnd := TotalStart;
        */

    end;

    var
        GStoreFilter: Code[20];
        GTerminalFilter: Code[20];
        GDateFilter: Date;
        Terminal: Record "CCS CASH POS Terminal";
        EoDCaptionLbl: Label 'Day End';
        CurrReportPageNoCaptionLbl: Label 'Page';
        TotalSales: Decimal;
        TotalPayment: Decimal;
        TotalRemove: Decimal;
        TotalExpense: Decimal;
        TotalDeposit: Decimal;
        TotalFloat: Decimal;
        TotalStart: Decimal;
        TotalEnd: Decimal;
        TotalStartDayEnd: Decimal;
        TotalEndDayEnd: Decimal;
        TotalNotCash: Decimal;
        TotalAmount: Decimal;
        TotalAmountinclVat: Decimal;
        TotalVat: Decimal;
        HelpIdentifier: Decimal;
        TenderTypeCardSetup: Record "CCS CASH Tender Type C. Setup";
        TenderDescription: Text[50];
        TempTenderTypeCardSetup: Record "CCS CASH Tender Type C. Setup" temporary;
        HelpPosTrans: Record "CCS CASH POS Transaction Hdr.";
        StartTransactionNo: Integer;
        EndTransactionNo: Integer;
        HelpTime: Time;
        ReceiptLbl: Label 'Receipt No.';
        tempCASHDocumentInformation: Record "CCS CASH Document Information" temporary;
        SignatureLoaded: Boolean;
}