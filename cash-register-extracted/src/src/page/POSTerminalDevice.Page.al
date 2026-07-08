page 1070560 "CCS CASH POS Terminal Device"
{
    // POS0013 18.08.16 AP changed call of EnterSession
    // POS0025 17.01.17 MK Added Functionality for Zero-Amount Receipt
    // POS0029 07.02.17 FS Changed Object Name and Object Caption, minor code changes
    // POS0035 13.06.17 MK Added Code to Call POS from Outside after Inv. Posting
    // POS0036 01.07.17 FS include orderposting and call cash dialog
    // 
    // EFSTA2.03  06.02.2017 MK Changed Code because of different Zero Receipt Types

    AdditionalSearchTerms = 'CASH POS Terminal Device', Locked = true;
    Caption = 'POS Terminal Device - Cash Register';
    DataCaptionExpression = GetPageCaption();
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = ListPlus;
    PromotedActionCategories = 'New,Process,Reports,Money Transactions';
    ShowFilter = false;
    UsageCategory = Tasks;
    ApplicationArea = CCSCASH;

    actions
    {
        area(processing)
        {
            group("Cash Sales")
            {
                Caption = 'Cash Sales';
                Image = "Order";
                action(CashInvoice)
                {
                    ApplicationArea = All;
                    Caption = 'New Cash Document';
                    Image = CalculateCost;
                    Promoted = true;
                    PromotedCategory = New;
                    PromotedOnly = true;
                    ToolTip = 'Executes the New Cash Document action.';

                    trigger OnAction()
                    var
                        CashInvoice: Page "CCS CASH Cash Sales Invoice";
                    begin
                        CreateDocument(false);
                        Clear(CashInvoice);
                        CashInvoice.SetRecord(SalesHeader);
                        CashInvoice.RunModal();
                    end;
                }
                action(Return)
                {
                    ApplicationArea = All;
                    Caption = 'Cash Return';
                    Image = ReturnOrder;
                    Promoted = true;
                    PromotedCategory = New;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Cash Return action.';

                    trigger OnAction()
                    var
                        CashCrMem: Page "CCS CASH Cash Sales Cr. Memo";
                    begin
                        if not Staff."Returns allowed" then
                            Error(Text003);
                        CreateDocument(true);
                        Clear(CashCrMem);
                        CashCrMem.SetRecord(SalesHeader);
                        CashCrMem.RunModal();
                    end;
                }
                action("Customer Payment")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Payment';
                    Image = Payment;
                    Promoted = true;
                    PromotedOnly = true;
                    ToolTip = 'Invoice issued';

                    trigger OnAction()
                    begin
                        if CSLCustLib.SelectCustomerEntry(RetailUser, TransHead, true) then;
                    end;
                }
            }
            group("Money Transaction")
            {
                Caption = 'Money Transaction';
                Image = CashFlow;
                action(Dayend)
                {
                    ApplicationArea = All;
                    Caption = 'Day End';
                    Image = TransferToGeneralJournal;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Day End action.';

                    trigger OnAction()
                    begin
                        // ++ EFSTA2.03
                        //++POS0029
                        //IF CONFIRM(EFSTA001,TRUE) THEN BEGIN
                        //  CSLFunc.ZeroTransaction(RetailUser,1);
                        //END;
                        //--POS0029
                        // -- EFSTA2.03
                        CSLFunc.DayEnd(RetailUser, false);
                        if POSTerm.Status() = 0 then
                            CurrPage.Close();
                    end;
                }
                action(Expenses)
                {
                    ApplicationArea = All;
                    Caption = 'Expenses';
                    Image = ProjectExpense;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Expenses action.';

                    trigger OnAction()
                    begin
                        if not Staff."Expenses allowed" then
                            Error(Text004);

                        CSLFunc.Expense(RetailUser);
                    end;
                }
                action(Deposits)
                {
                    ApplicationArea = All;
                    Caption = 'Deposits';
                    Image = ProjectExpense;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Deposits action.';

                    trigger OnAction()
                    begin
                        if not Staff."Deposits allowed" then
                            Error(Text006);

                        CSLFunc.Deposit(RetailUser);
                    end;
                }
                action(FloatEntry)
                {
                    ApplicationArea = All;
                    Caption = 'Change Entry';
                    Image = Sales;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Change Entry action.';

                    trigger OnAction()
                    begin
                        CSLFunc.FloatEntry(RetailUser);
                    end;
                }
                action(RemoveTender)
                {
                    ApplicationArea = All;
                    Caption = 'Equalisation Levy';
                    Image = ApplyEntries;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Equalisation Levy action.';

                    trigger OnAction()
                    begin
                        CSLFunc.RemoveTender(RetailUser);
                    end;
                }
            }
            action(TransactionJournal)
            {
                ApplicationArea = All;
                Caption = 'Print Trans. Log';
                Image = Print;
                ToolTip = 'Prints the Transaction Log.';

                trigger OnAction()
                begin
                    Transhead2.SetRange("Store No.", RetailUser."Store No");
                    Transhead2.SetRange("POS Terminal No.", RetailUser."POS Terminal No.");
                    Transhead2.SetRange("Creation Date", Today);
                    CSLFunc.PrintReport(Print_OP::Journal, Transhead2, true);
                end;
            }
            action("Create Zero Document")
            {
                ApplicationArea = All;
                Caption = 'Create Zero Document';
                Image = SendElectronicDocument;
                ToolTip = 'Executes the Create Zero Document action.';

                trigger OnAction()
                begin
                    // ++ EFSTA2.03
                    //CSLFunc.ZeroTransaction(RetailUser);
                    CSLFunc.ZeroTransaction(RetailUser, Enum::"CCS CASH Zero Receipt Type"::ZeroReceipt);
                    // -- EFSTA2.03
                end;
            }
            action("Cash Drawer")
            {
                ApplicationArea = All;
                Caption = 'Open Cash Drawer';
                Image = Debug;
                ToolTip = 'Opens the Cash Drawer';
                Visible = CashDrawerExist;

                trigger OnAction()
                begin
                    POSTerm.OpenCashDrawer(false);
                end;
            }
        }
        area(Reporting)
        {
            action(PostedCashInvoice)
            {
                ApplicationArea = All;
                Caption = 'Posted Cash Invoices';
                Image = Invoice;
                ToolTip = 'Executes the Posted Cash Invoices action.';

                trigger OnAction()
                begin
                    CashInv.SetCurrentKey("CCS CASH CSL Store No.", "CCS CASH CSL POS Terminal No.");
                    CashInv.SetRange("CCS CASH CSL Store No.", RetailUser."Store No");
                    CashInv.SetRange("CCS CASH CSL POS Terminal No.", RetailUser."POS Terminal No.");
                    PAGE.RunModal(PAGE::"CCS CASH Posted Cash Invoices", CashInv);
                end;
            }
            action(PostedCashReturn)
            {
                ApplicationArea = All;
                Caption = 'Posted Cr. Memos';
                Image = CreditMemo;
                ToolTip = 'Executes the Posted Credit Memos action.';

                trigger OnAction()
                begin
                    CashReturn.SetCurrentKey("CCS CASH CSL Store No.", "CCS CASH CSL POS Terminal No.");
                    CashReturn.SetRange("CCS CASH CSL Store No.", RetailUser."Store No");
                    CashReturn.SetRange("CCS CASH CSL POS Terminal No.", RetailUser."POS Terminal No.");
                    PAGE.RunModal(PAGE::"CCS CASH Posted Cash Returns", CashReturn);
                end;
            }
            action(Transactions)
            {
                ApplicationArea = All;
                Caption = 'Trans. Log';
                Image = SettleOpenTransactions;
                ToolTip = 'Opens the Transaction Log.';

                trigger OnAction()
                begin
                    Transhead2.SetRange("Store No.", RetailUser."Store No");
                    Transhead2.SetRange("POS Terminal No.", RetailUser."POS Terminal No.");
                    Transhead2.SetRange("Creation Date", Today);
                    PAGE.RunModal(PAGE::"CCS CASH POS Transactions", Transhead2);
                end;
            }
        }
    }

    trigger OnClosePage()
    begin
        if UserIsValid then
            CSLFunc.CreateTransLog(RetailUser, TransHead."Transaction Type"::Logoff);

        CSLFunc.ExitSession(POSTerm);
    end;

    trigger OnOpenPage()
    begin
        CallLogin();
    end;

    protected var
        cslSetup: Record "CCS CASH Cash Sales Setup";
        RetailUser: Record "CCS CASH Retail User";
        TransHead: Record "CCS CASH POS Transaction Hdr.";

    var
        Staff: Record "CCS CASH Staff";
        Store: Record "CCS CASH Store";
        POSTerm: Record "CCS CASH POS Terminal";
        Error001: Label 'Stopped Processing';
        Error002: Label 'POS Terminal %1 was not opend.', Comment = '%1=Value 1';
        Transhead2: Record "CCS CASH POS Transaction Hdr.";
        SalesHeader: Record "Sales Header";
        CashInv: Record "Sales Invoice Header";
        CashReturn: Record "Sales Cr.Memo Header";
        CSLFunc: Codeunit "CCS CASH POS Register Func";
        CSLCustLib: Codeunit "CCS CASH POS Reg. Customer Lib";
        UserIsValid: Boolean;
        Print_OP: Option CashReceipt,CashInvoice,CustPayment,StartDay,EndDay,Journal,Tenderdecl;
        Text003: Label 'Returns are not allowed.';
        Text004: Label 'Expenses are not allowed.';
        Text006: Label 'Deposits are not allowed.';
        CashierLbl: Label 'Cashier';
        AutoOption: Option ,Payment,Sales;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CashDrawerExist: Boolean;

    local procedure CallLogin()
    begin
        //IF WORKDATE <> TODAY THEN
        //  ERROR(Text005);

        UserIsValid := CSLFunc.StaffLogin(RetailUser);
        if not UserIsValid then
            Error(Error001);
        Staff.Get(RetailUser."Staff ID");
        Store.Get(RetailUser."Store No");
        POSTerm.Get(RetailUser."Store No", RetailUser."POS Terminal No.");

        if POSTerm."Cash Drawer Connection Code" <> '' then
            CashDrawerExist := true;

        //++POS0013
        CSLFunc.EnterSession(POSTerm);
        //--POS0013

        CSLFunc.DayStart(RetailUser);
        if POSTerm.Status() <> 1 then
            Error(Error002, POSTerm."No.");

        //++POS0013
        //CSLFunc.EnterSession(POSTerm);
        //--POS0013
    end;

    local procedure GetPageCaption(): Text[80]
    var
        StaffInfo: Text[30];
    begin
        StaffInfo := Staff."Short Code";
        if Staff."Short Code" = '' then
            StaffInfo := Staff.ID;

        if Staff."Salesperson Code" <> '' then
            if StaffInfo <> Staff."Salesperson Code" then
#pragma warning disable AA0217
                StaffInfo := CopyStr(StrSubstNo('%1(%2)', StaffInfo, Staff."Salesperson Code"), 1, MaxStrLen(StaffInfo));
#pragma warning restore AA0217

#pragma warning disable AA0217
        exit(CopyStr(StrSubstNo('%1: %3, %4: %2', Store."No.", StaffInfo, RetailUser."POS Terminal No.", CashierLbl), 1, 80));
#pragma warning restore AA0217
    end;

    local procedure CreateDocument(ParamReturn: Boolean)
    begin
        cslSetup.Get();
        SalesHeader.Reset();
        SalesHeader.SetRange("CCS CASH CSL Document", true);
        SalesHeader.SetRange("CCS CASH CSL Store No.", RetailUser."Store No");
        SalesHeader.SetRange("CCS CASH CSL POS Terminal No.", RetailUser."POS Terminal No.");
        SalesHeader.SetRange("CCS CASH CSL Staff ID", RetailUser."Staff ID");
        if ParamReturn then
            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo")
        else
            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);

        if SalesHeader.FindFirst() then
            exit;

        CSLFunc.VoidOpenTransactions(RetailUser, cslSetup."Autovoid Open Transactions");

        SalesHeader.Init();
        SalesHeader."CCS CASH CSL Document" := true;
        SalesHeader."CCS CASH CSL Store No." := RetailUser."Store No";
        SalesHeader."CCS CASH CSL POS Terminal No." := RetailUser."POS Terminal No.";
        SalesHeader."CCS CASH CSL Staff ID" := RetailUser."Staff ID";
        if ParamReturn then
            SalesHeader."Document Type" := SalesHeader."Document Type"::"Credit Memo"
        else
            SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader."No." := '';
        //++POS0029
        //SalesHeader.INSERT(TRUE);
        //--POS0029
        if POSTerm."Default Customer at POS" <> '' then
            SalesHeader.Validate("Sell-to Customer No.", POSTerm."Default Customer at POS");

        if POSTerm."Location Code" <> '' then
            SalesHeader.Validate("Location Code", POSTerm."Location Code");

        if ParamReturn then
            SalesHeader."CCS CASH CSL Transaction No." := CSLFunc.CreateTransLog(RetailUser, TransHead."Transaction Type"::Return)
        else
            SalesHeader."CCS CASH CSL Transaction No." := CSLFunc.CreateTransLog(RetailUser, TransHead."Transaction Type"::Sales);

        //++POS0029
        SalesHeader.Insert(true);
        //SalesHeader.MODIFY(TRUE);
        //--POS0029
        Commit();
    end;

    internal procedure CallLoginOutside(pRetailUser: Record "CCS CASH Retail User")
    begin
        //++POS0035
        RetailUser := pRetailUser;
        Staff.Get(RetailUser."Staff ID");
        Store.Get(RetailUser."Store No");
        POSTerm.Get(RetailUser."Store No", RetailUser."POS Terminal No.");

        if POSTerm."Cash Drawer Connection Code" <> '' then
            CashDrawerExist := true;

        //++POS0013
        CSLFunc.EnterSession(POSTerm);
        //--POS0013

        CSLFunc.DayStart(RetailUser);
        if POSTerm.Status() <> 1 then
            Error(Error002, POSTerm."No.");
        //--POS0035
    end;

    internal procedure SetAutoOption(pAutoOption: Option ,Payment)
    begin
        //++POS0035
        AutoOption := pAutoOption;
        //--POS0035
    end;

    internal procedure SetCustLedgerEntry(pCustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        //++POS0035
        CustLedgerEntry := pCustLedgerEntry;
        //--POS0035
    end;

    internal procedure SetSalesHeader(NewSalesHeader: Record "Sales Header")
    begin
        //+POS0036
        SalesHeader := NewSalesHeader;
        //-POS0036
    end;

    internal procedure RunAutoOption()
    var
        locPaymentPage: Page "CCS CASH Cust. Pmt. Trans.";
        locCashInvoice: Page "CCS CASH Cash Sales Invoice";
        locCashCrMem: Page "CCS CASH Cash Sales Cr. Memo";
    begin
        //++POS0035
        if AutoOption = 0 then
            exit;

        case AutoOption of
            AutoOption::Payment:
                begin
                    // Looks never used and CustLedgerEntry is never initialised
                    if CSLCustLib.SetCustomerEntry(RetailUser, TransHead, CustLedgerEntry) then begin
                        locPaymentPage.SetTableView(TransHead);
                        locPaymentPage.SetRecord(TransHead);
                        locPaymentPage.CallPaymentPage();
                        CSLFunc.ExitSession(POSTerm);
                        CurrPage.Close();
                    end;
                end;
            //+POS0036
            AutoOption::Sales:
                begin
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice then begin
                        Clear(locCashInvoice);
                        locCashInvoice.SetRecord(SalesHeader);
                        locCashInvoice.RunModal();
                    end else begin
                        Clear(locCashCrMem);
                        locCashCrMem.SetRecord(SalesHeader);
                        locCashCrMem.RunModal();
                    end;
                    CSLFunc.ExitSession(POSTerm);
                    CurrPage.Close();
                end;
        //-POS0036
        end;
        //--POS0035
    end;
}