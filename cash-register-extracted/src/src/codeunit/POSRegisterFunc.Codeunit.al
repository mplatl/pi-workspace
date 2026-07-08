codeunit 1070540 "CCS CASH POS Register Func"
{
    Permissions = TableData "Sales Invoice Header" = rimd,
                  Tabledata "Sales Invoice Line" = rimd,
                  TableData "Sales Cr.Memo Header" = rimd,
                  TableData "Cust. Ledger Entry" = rm;

    var
        CSLSetup: Record "CCS CASH Cash Sales Setup";
        TransHead: Record "CCS CASH POS Transaction Hdr.";
        POSTerm: Record "CCS CASH POS Terminal";
        TempPmtBuffer: Record "CCS CASH Trans. Payment Entry" temporary;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Tender_OP: Option Remove,Float,POSStart,POSEnd;
        Error001: Label 'No Staff selected';
        Error002: Label 'Process canceled';
        Error003: Label 'Cash Amount in Drawer must not be less than %1.', Comment = '%1=Lower Value';
        Error004: Label 'POS Terminal %1 not Open.', Comment = '%1=POS Terminal Name';
        Error005: Label '%1 not allowed in Post Payment.', Comment = '%1=Value';
        Error006: Label '%1 Amount %2 does not balance %3 Amount %4.', Comment = '%1=Param1,%2=Param2,%3=Param3,%4=Param4';
        Error007: Label 'Amount combined (%1) does not match expected amount (%2).', Comment = '%1=Value 1,%2=Value 2';
        Error008: Label 'A Workdate other than aktual Date ist not allowed at cash desk.';
        Error009: Label 'Empty request / amount - Nothing to do';
        Error010: Label 'Amount must not be %1', Comment = '%1=Value';
        Error011: Label 'Total Expenses (%1) exceed cash register balance (%2).', Comment = '%1=Value 1,%2=Value 2';
        RefundError: Label 'Total Returns (%1) exceed cash register balance (%2).', Comment = '%1=Return Amount, %2=Cash Balance';
        Error012: Label 'If Voucher Card No. is mandatory, the maximum quantity to be sold must be 1.';
        Text001: Label 'If Transaction Type is %1 then %2 Amount %3 is not allowed.', Comment = '%1=Transaction Type, %2=Value 1, %3=Value 3';
        Text002: Label 'less than 0';
        Text003: Label 'greater than 0';
        Text004: Label 'Difference %1', Comment = '%1=Value';
        Text005: Label 'Change Entry';
        Text006: Label 'Money Entry';
        Print_OP: Option CashReceipt,CashInvoice,CustPayment,StartDay,EndDay,Journal,Tenderdecl,Voucher;
        Text011: Label 'POS Terminal was left open (%1), Autoclose in progress.', Comment = '%1=Value';
        Text012: Label '%1 counted (to Safe)', Comment = '%1=Value';
        Text013: Label '%1 removal to Bank', Comment = '%1=Value';
        Text014: Label 'Holdings / Counting';
        Text015: Label 'The POS Transaction %1 (%2) is not completed.\Do you want to Cancel the Transaction?', Comment = '%1=Value 1,%2=Value 2';
        Text016: Label 'Payment';
        Text017: Label 'Return';
        Text018: Label 'Invoice';
        Text019: Label 'Cr. Memo';
        Text020: Label 'Transaction %1', Comment = '%1=Value';
        Text021: Label 'The Customer Payment was posted, but during appliance an error occured:\ %1 \Please complete the application for Payment Transaction %2 manualy.', Comment = '%1=Value,%2=Value 2';
        Text022: Label 'Positiv';
        Text023: Label 'Negativ';
        Text024: Label 'Zero';
        Text025: Label 'POS Terminal already active at %1 by %2.', Comment = '%1=Value 1,%2=Value 2';
        ReasonCode: Label 'Cash Trans';
        Text027: Label 'Return Order / Cr. Memo not allowed with Payment Methods.';
        Text028: Label 'Customer Ledger Entry not found for Invoice %1.', Comment = '%1=Value 1';
        Text029: Label 'If you want to post a Cash Invoice using dialog, please run the "POS Terminal Device".';
        Text030: Label 'No %1 found, nothing to do.', Comment = '%1=Value 1';

    internal procedure CreateTransLog(var pRetailUser: Record "CCS CASH Retail User"; Reason: enum "CCS CASH Transaction Type"): Integer
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        if Reason = Reason::Logoff then
            exit;
        if not CompanyInformationMgt.IsDemoCompany() then
            if WorkDate() <> Today then
                Error(Error008);
        TransHead.Init();
        TransHead."Store No." := pRetailUser."Store No";
        TransHead."POS Terminal No." := pRetailUser."POS Terminal No.";
        TransHead."Transaction No." := 0;
        TransHead."Transaction Type" := Reason;
        TransHead."Staff ID" := pRetailUser."Staff ID";
        TransHead.Starttime := CurrentDateTime;
        TransHead."Creation Date" := DT2Date(TransHead.Starttime);
        TransHead."Creation Time" := DT2Time(TransHead.Starttime);

        if Reason in [Reason::Logon, Reason::Logoff, Reason::"Open Drawer", Reason::Zero, Reason::EndDay, Reason::Startday] then
            TransHead.Status := TransHead.Status::Normal;
        TransHead.Insert(true);
        exit(TransHead."Transaction No.");
    end;

    internal procedure DayStart(var pRetailUser: Record "CCS CASH Retail User")
    var
        DayStartText: Label 'Day Start';
    begin
        POSTerm.Get(pRetailUser."Store No", pRetailUser."POS Terminal No.");
        if POSTerm.Status() = 99 then
            //+POS0035
            if NeedDailyPOSClose(POSTerm) then
                //-POS0035
                DayEnd(pRetailUser, true);

        if POSTerm.Status() = 0 then begin
            CreateTransLog(pRetailUser, TransHead."Transaction Type"::Startday);
            if TenderOperation(pRetailUser, DayStartText, Tender_OP::POSStart) then
                PrintReport(Print_OP::StartDay, TransHead, true);
        end;
    end;

    internal procedure DayEnd(var pRetailUser: Record "CCS CASH Retail User"; SystemEnd: Boolean)
    var
        DayEndText: Label 'Day End Count';
        POSStatus: Integer;
        TransH: Record "CCS CASH POS Transaction Hdr.";
        TransH2: Record "CCS CASH POS Transaction Hdr.";
        TDecl: Record "CCS CASH Trans. Tender Dcl. E.";
        TenderOpPage: Page "CCS CASH Tender Operation";
    begin
        GetPOSTerm(pRetailUser."Store No", pRetailUser."POS Terminal No.");
        POSStatus := POSTerm.Status();
        if POSStatus = 0 then
            exit;
        case POSStatus of
            99:
                begin
                    TransH.SetRange("Store No.", pRetailUser."Store No");
                    TransH.SetRange("POS Terminal No.", pRetailUser."POS Terminal No.");
                    TransH.SetRange("Transaction Type", TransH."Transaction Type"::Startday);
                    TransH.FindLast();

                    if GuiAllowed then
                        Message(Text011, TransH."Creation Date");

                    // Autoclode POS Term
                    CreateTransLog(pRetailUser, TransHead."Transaction Type"::EndDay);
                    TransHead."Creation Date" := TransH."Creation Date";
                    TransHead."Creation Time" := 235959T;
                    TransHead."System Created" := true;
                    if TransHead."Receipt No." = '' then
                        TransHead."Receipt No." := NoSeriesMgt.GetNextNo(POSTerm."Posted Receipt Nos.", WorkDate(), true);
                    TransHead.Modify(true);

                    Clear(TenderOpPage);
                    TenderOpPage.SetTerminalOption(pRetailUser, TransHead, Tender_OP::POSEnd, '');
                    TDecl.SetRange("Store No.", TransHead."Store No.");
                    TDecl.SetRange("POS Terminal No.", TransHead."POS Terminal No.");
                    TDecl.SetRange("Transaction No.", TransHead."Transaction No.");
                    if TDecl.FindSet(true) then
                        repeat
                            TDecl.Validate("Fixed Amount", TDecl."Cash Amount");
                            TDecl.Modify(true);
                        until TDecl.Next() = 0;

                    PostTenderOperation(TransHead);

                    // reset counting
                    if TDecl.FindSet(true) then
                        repeat
                            TDecl."Fixed Amount" := 0;
                            TDecl.Modify(true);
                        until TDecl.Next() = 0;
                end;
            1:
                begin
                    CreateTransLog(pRetailUser, TransHead."Transaction Type"::EndDay);
                    if TenderOperation(pRetailUser, DayEndText, Tender_OP::POSEnd) then
                        PrintReport(Print_OP::EndDay, TransHead, not SystemEnd);
                end;
        end;

        // void all open Transactions
        TransH.SetRange("Transaction Type");
        //--POS0021
        TransH.SetRange("Store No.", pRetailUser."Store No");
        TransH.SetRange("POS Terminal No.", pRetailUser."POS Terminal No.");
        //++POS0021
        TransH.SetRange(Status, TransH.Status::Logging);
        if TransH.FindSet(true) then
            repeat
                TransH2.Copy(TransH);
                TransH2.VoidTransaction(pRetailUser);
            until TransH.Next() = 0
    end;

    internal procedure FloatEntry(var pRetailUser: Record "CCS CASH Retail User")
    begin
        POSTerm.Get(pRetailUser."Store No", pRetailUser."POS Terminal No.");
        if POSTerm.Status() <> 1 then
            Error(Error004, POSTerm."Store No" + ' ' + POSTerm."No.");
        CreateTransLog(pRetailUser, TransHead."Transaction Type"::"Float Entry");
        TenderOperation(pRetailUser,/*FloatEntryText*/'', Tender_OP::Float);

    end;

    internal procedure RemoveTender(var pRetailUser: Record "CCS CASH Retail User")
    var
        TenderRemoveText: Label 'Equalisation Levy';
    begin
        POSTerm.Get(pRetailUser."Store No", pRetailUser."POS Terminal No.");
        if POSTerm.Status() <> 1 then
            Error(Error004, POSTerm."Store No" + ' ' + POSTerm."No.");
        CreateTransLog(pRetailUser, TransHead."Transaction Type"::"Remove Tender");
        TenderOperation(pRetailUser, TenderRemoveText, Tender_OP::Remove);
    end;

    internal procedure Expense(pRetailUser: Record "CCS CASH Retail User")
    begin
        POSTerm.Get(pRetailUser."Store No", pRetailUser."POS Terminal No.");
        if POSTerm.Status() <> 1 then
            Error(Error004, POSTerm."Store No" + ' ' + POSTerm."No.");
        CreateTransLog(pRetailUser, TransHead."Transaction Type"::Expense);
        Commit();
        TransHead.SetRecFilter();
        PAGE.RunModal(PAGE::"CCS CASH POS Expense", TransHead);
    end;

    internal procedure Deposit(pRetailUser: Record "CCS CASH Retail User")
    begin
        POSTerm.Get(pRetailUser."Store No", pRetailUser."POS Terminal No.");
        if POSTerm.Status() <> 1 then
            Error(Error004, POSTerm."Store No" + ' ' + POSTerm."No.");
        CreateTransLog(pRetailUser, TransHead."Transaction Type"::Deposit);
        Commit();
        TransHead.SetRecFilter();
        PAGE.RunModal(PAGE::"CCS CASH POS Deposit", TransHead);
    end;

    internal procedure PostTenderOperation(var pTransHeader: Record "CCS CASH POS Transaction Hdr."): Boolean
    var
        TenderType: Record "CCS CASH Store Tender Type";
        Tendertype2: Record "CCS CASH Store Tender Type";
        TPmt: Record "CCS CASH Trans. Payment Entry";
        TTDecl: Record "CCS CASH Trans. Tender Dcl. E.";
        TSafe: Record "CCS CASH Trans. Depot Entry";
        Desc: Text[50];
        FixDesc: Text;
        BankDesc: Text;
        DiffDesc: Text;
        NextLineNo: Integer;
    begin
        // ++ EFSTA2.01
        if IsSignatureServiceDown(pTransHeader."Store No.", pTransHeader."POS Terminal No.", '') then
            exit(false);
        // -- EFSTA2.01

        GetPOSTerm(pTransHeader."Store No.", pTransHeader."POS Terminal No.");
        // + POS0016
        if pTransHeader."Receipt No." = '' then
            // - POS0016
            pTransHeader."Receipt No." := NoSeriesMgt.GetNextNo(POSTerm."Posted Receipt Nos.", WorkDate(), true);

        TTDecl.SetRange("Store No.", pTransHeader."Store No.");
        TTDecl.SetRange("POS Terminal No.", pTransHeader."POS Terminal No.");
        TTDecl.SetRange("Transaction No.", pTransHeader."Transaction No.");
        if TTDecl.FindSet() then
            repeat
                TenderType.Get(TTDecl."Store No.", TTDecl."Tender Type");
                TenderType.TestField("Account No.");
                case pTransHeader."Transaction Type" of
                    pTransHeader."Transaction Type"::"Float Entry":
                        begin
                            if TTDecl."Fixed Amount" <> 0 then
                                Error(Text001, Format(pTransHeader."Transaction Type"), TTDecl.FieldCaption("Fixed Amount"), '');

                            if TTDecl."Bank Amount" < 0 then
                                Error(Text001, Format(pTransHeader."Transaction Type"), TTDecl.FieldCaption("Bank Amount"), Text002);
                            Desc := Text005;
                        end;
                    pTransHeader."Transaction Type"::"Remove Tender":
                        begin
                            if TTDecl."Fixed Amount" <> 0 then
                                Error(Text001, Format(pTransHeader."Transaction Type"), TTDecl.FieldCaption("Fixed Amount"), '');

                            if TTDecl."Bank Amount" < 0 then
                                Error(Text001, Format(pTransHeader."Transaction Type"), TTDecl.FieldCaption("Bank Amount"), Text003);

                            if TTDecl."Cash Amount" < TTDecl."Bank Amount" then
                                Error(Error003, FormatDec(TTDecl."Bank Amount", 2, false));
                            TTDecl."Bank Amount" := -TTDecl."Bank Amount";
                        end;
                    pTransHeader."Transaction Type"::Startday:
                        begin
                            if TTDecl."Bank Amount" <> 0 then
                                Error(Text001, Format(pTransHeader."Transaction Type"), TTDecl.FieldCaption("Bank Amount"), '');

                            if TTDecl."Fixed Amount" < 0 then
                                Error(Text001, Format(pTransHeader."Transaction Type"), TTDecl.FieldCaption("Fixed Amount"), Text002);
                            Desc := Text006;
                            DiffDesc := Text014;
                        end;
                    pTransHeader."Transaction Type"::EndDay:
                        begin
                            if (TTDecl."Fixed Amount" < 0) or (TTDecl."Bank Amount" < 0) then
                                Error(Text001, Format(pTransHeader."Transaction Type"),
                                      TTDecl.FieldCaption("Bank Amount") + '/' + TTDecl.FieldCaption("Fixed Amount"), Text002);

                            //--POS0002
                            if (TTDecl."Bank Amount" > 0) and
                               (-TTDecl."Cash Amount" + TTDecl."Fixed Amount" + TTDecl."Bank Amount" < TTDecl."Diff. Amount") then
                                Error(Error003, FormatDec(TTDecl."Bank Amount", 2, false));
                            //++POS0002
                            TTDecl."Bank Amount" := -TTDecl."Bank Amount";
                            TTDecl."Fixed Amount" := -TTDecl."Fixed Amount";
                            FixDesc := Text012;
                            BankDesc := Text013;
                        end;
                end;

                TPmt.Init();
                TPmt."Store No." := pTransHeader."Store No.";
                TPmt."POS Terminal No." := pTransHeader."POS Terminal No.";
                TPmt."Transaction No." := pTransHeader."Transaction No.";
                TPmt."Receipt No." := pTransHeader."Receipt No.";
                TPmt."Staff ID" := pTransHeader."Staff ID";
                TPmt."Creation Date" := WorkDate();
                TPmt."Creation Time" := Time;

                TSafe.Init();
                TSafe."Store No." := pTransHeader."Store No.";
                TSafe."POS Terminal No." := pTransHeader."POS Terminal No.";
                TSafe."Transaction No." := pTransHeader."Transaction No.";
                TSafe."Receipt No." := pTransHeader."Receipt No.";
                TSafe."Staff ID" := pTransHeader."Staff ID";
                TSafe."Creation Date" := WorkDate();
                TSafe."Creation Time" := Time;

                if TTDecl."Fixed Amount" <> 0 then begin
                    NextLineNo += 10000;
                    TPmt."Line No." := NextLineNo;
                    TPmt.Validate("Tender Type", TTDecl."Tender Type");
                    TPmt."Safe Type" := TPmt."Safe Type"::"Fixed Float";
                    if pTransHeader."Transaction Type" = pTransHeader."Transaction Type"::Startday then
                        TPmt.Amount := TTDecl."Fixed Amount" - TTDecl."Diff. Amount"
                    else
                        TPmt.Amount := TTDecl."Fixed Amount";
                    Clear(TPmt."Account Type");
                    Clear(TPmt."Account No.");
                    if TPmt.Amount > 0 then begin
                        TPmt."Account Type" := GetAccountType_Payment(TenderType."Account Type");
                        TPmt."Account No." := TenderType."Account No.";
                    end;

                    if FixDesc <> '' then
                        TPmt."Tender Description" := StrSubstNo(FixDesc, TenderType.Description)
                    else
                        if Desc <> '' then
                            TPmt."Tender Description" := Desc
                        else
                            TPmt."Tender Description" := TenderType.Description;

                    TPmt.Insert(true);

                    if pTransHeader."Transaction Type" = pTransHeader."Transaction Type"::"Float Entry" then begin
                        TenderType.TestField("Bank Account No.");
                        //++POS0033
                        //PostGenJnl(pTransHeader,TPmt,TenderType."Bank Account Type",TenderType."Bank Account No."=;
                        PostGenJnl(pTransHeader, TPmt, TenderType."Bank Account Type", TenderType."Bank Account No.", 0)
                        //--POS0033
                    end else begin
                        // Insert Safe Entry;
                        TSafe."Line No." := NextLineNo;
                        TSafe."Tender Type" := TTDecl."Tender Type";
                        if pTransHeader."Transaction Type" = pTransHeader."Transaction Type"::Startday then
                            TSafe.Amount := -TTDecl."Fixed Amount" + TTDecl."Diff. Amount"
                        else
                            TSafe.Amount := -TTDecl."Fixed Amount";
                        TSafe."Account Type" := TenderType."Account Type";
                        TSafe."Account No." := TenderType."Account No.";
                        TSafe."Depot Type" := TSafe."Depot Type"::"Fixed Float";
                        TSafe.Insert(true);
                    end;
                end;

                //--POS0006

                if (TTDecl."Fixed Amount" = 0) and
                  (pTransHeader."Transaction Type" = pTransHeader."Transaction Type"::Startday) then begin
                    NextLineNo += 10000;
                    TPmt."Line No." := NextLineNo;
                    TPmt.Validate("Tender Type", TTDecl."Tender Type");
                    TPmt."Safe Type" := TPmt."Safe Type"::"Fixed Float";
                    if pTransHeader."Transaction Type" = pTransHeader."Transaction Type"::Startday then
                        TPmt.Amount := TTDecl."Fixed Amount" - TTDecl."Diff. Amount"
                    else
                        TPmt.Amount := TTDecl."Fixed Amount";
                    Clear(TPmt."Account Type");
                    Clear(TPmt."Account No.");
                    if TPmt.Amount > 0 then begin
                        TPmt."Account Type" := GetAccountType_Payment(TenderType."Account Type");
                        TPmt."Account No." := TenderType."Account No.";
                    end;

                    if FixDesc <> '' then
                        TPmt."Tender Description" := StrSubstNo(FixDesc, TenderType.Description)
                    else
                        if Desc <> '' then
                            TPmt."Tender Description" := Desc
                        else
                            TPmt."Tender Description" := TenderType.Description;

                    TPmt.Insert(true);

                    if pTransHeader."Transaction Type" = pTransHeader."Transaction Type"::"Float Entry" then begin
                        TenderType.TestField("Bank Account No.");
                        //++POS0033
                        //PostGenJnl(pTransHeader,TPmt,TenderType."Bank Account Type",TenderType."Bank Account No.");
                        PostGenJnl(pTransHeader, TPmt, TenderType."Bank Account Type", TenderType."Bank Account No.", 0)
                        //--POS0033
                    end else begin
                        // Insert Safe Entry;
                        TSafe."Line No." := NextLineNo;
                        TSafe."Tender Type" := TTDecl."Tender Type";
                        if pTransHeader."Transaction Type" = pTransHeader."Transaction Type"::Startday then
                            TSafe.Amount := -TTDecl."Fixed Amount" + TTDecl."Diff. Amount"
                        else
                            TSafe.Amount := -TTDecl."Fixed Amount";
                        TSafe."Account Type" := TenderType."Account Type";
                        TSafe."Account No." := TenderType."Account No.";
                        TSafe."Depot Type" := TSafe."Depot Type"::"Fixed Float";
                        TSafe.Insert(true);
                    end;
                end;

                //++POS0006

                if TTDecl."Bank Amount" <> 0 then begin
                    NextLineNo += 10000;
                    TPmt."Line No." := NextLineNo;
                    TPmt.Validate("Tender Type", TTDecl."Tender Type");
                    // is the cash transaction therefore no safe type
                    // TPmt."Safe Type" := TPmt."Safe Type"::Bank;
                    TPmt.Amount := TTDecl."Bank Amount";
                    TPmt."Account Type" := GetAccountType_Payment(TenderType."Account Type");
                    TPmt."Account No." := TenderType."Account No.";

                    if BankDesc <> '' then
                        TPmt."Tender Description" := StrSubstNo(BankDesc, TenderType.Description)
                    else
                        if Desc <> '' then
                            TPmt."Tender Description" := Desc
                        else
                            TPmt."Tender Description" := TenderType.Description;
                    TPmt.Insert(true);

                    Tendertype2.Get(pTransHeader."Store No.", TenderType."Tender Remove");
                    Tendertype2.TestField("Account No.");
                    //++POS0033
                    //PostGenJnl(pTransHeader,TPmt,Tendertype2."Account Type",Tendertype2."Account No.");
                    PostGenJnl(pTransHeader, TPmt, Tendertype2."Account Type", Tendertype2."Account No.", 0);
                    //--POS0033

                    // Remove Tender in Cash Tables
                    NextLineNo += 10000;
                    TPmt."Line No." := NextLineNo;
                    TPmt.Validate("Tender Type", Tendertype2.Code);
                    TPmt."Safe Type" := TPmt."Safe Type"::Bank;
                    TPmt.Amount := TTDecl."Bank Amount";
                    TPmt."Account Type" := GetAccountType_Payment(TenderType."Account Type");
                    TPmt."Account No." := TenderType."Account No.";
                    if BankDesc <> '' then
                        TPmt."Tender Description" := StrSubstNo(BankDesc, TenderType.Description)
                    else
                        if Desc <> '' then
                            TPmt."Tender Description" := Desc
                        else
                            TPmt."Tender Description" := TenderType.Description;
                    TPmt.Insert(true);

                    TSafe."Line No." := NextLineNo;
                    TSafe.Amount := -TTDecl."Bank Amount";
                    TSafe."Tender Type" := Tendertype2.Code;
                    TSafe."Account Type" := Tendertype2."Account Type";
                    TSafe."Account No." := Tendertype2."Account No.";
                    TSafe."Depot Type" := TSafe."Depot Type"::Bank;
                    TSafe.Insert(true);
                end;

                if TTDecl."Diff. Amount" <> 0 then begin
                    TenderType.TestField("Diff. Account");
                    NextLineNo += 10000;
                    TPmt."Line No." := NextLineNo;
                    TPmt.Validate("Tender Type", TTDecl."Tender Type");
                    TPmt."Safe Type" := TPmt."Safe Type"::"Normal";
                    TPmt.Amount := TTDecl."Diff. Amount";
                    TPmt."Account Type" := GetAccountType_Payment(TenderType."Account Type");
                    TPmt."Account No." := TenderType."Account No.";
                    if DiffDesc <> '' then
                        TPmt."Tender Description" := StrSubstNo(Text004, DiffDesc)
                    else
                        if Desc <> '' then
                            TPmt."Tender Description" := StrSubstNo(Text004, Desc)
                        else
                            TPmt."Tender Description" := StrSubstNo(Text004, TenderType.Description);
                    TPmt.Insert(true);

                    //++POS0033
                    //PostGenJnl(pTransHeader,TPmt,TenderType."Diff. Acc. Type",TenderType."Diff. Account");
                    PostGenJnl(pTransHeader, TPmt, TenderType."Diff. Acc. Type", TenderType."Diff. Account", 0);
                    //--POS0033
                end;
            until TTDecl.Next() = 0;

        // ++ EFSTA2.00
        // Insert EFR Functions here
        CallSignatureService(pTransHeader);
        // -- EFSTA2.00

        pTransHeader.Status := pTransHeader.Status::Normal;
        pTransHeader.Modify(true);
        exit(true);
    end;

    internal procedure PostTransaction(var pTransHead: Record "CCS CASH POS Transaction Hdr.")
    var
        TransH: Record "CCS CASH POS Transaction Hdr.";
    begin
        TransH.Get(pTransHead."Store No.", pTransHead."POS Terminal No.", pTransHead."Transaction No.");

        case pTransHead."Transaction Type" of
            pTransHead."Transaction Type"::Return,
          pTransHead."Transaction Type"::Sales:
                DoPostSales(TransH);
            pTransHead."Transaction Type"::Payment:
                DoPostCustPayment(TransH);
            pTransHead."Transaction Type"::Deposit:
                DoPostDeposit(TransH);
            pTransHead."Transaction Type"::Expense:
                DoPostExpense(TransH);
            else
                Error('Dont know how to Post %1', Format(TransH."Transaction Type"));
        end;
        pTransHead := TransH;
    end;

    internal procedure VoidOpenTransactions(var pRetailuser: Record "CCS CASH Retail User"; pHideDialog: Boolean)
    var
        TransH: Record "CCS CASH POS Transaction Hdr.";
        Confirmed: Boolean;
    begin
        TransH.SetRange("Store No.", pRetailuser."Store No");
        TransH.SetRange("POS Terminal No.", pRetailuser."POS Terminal No.");
        TransH.SetRange(Status, TransH.Status::Logging);
        if TransH.FindSet() then
            repeat
                Confirmed := pHideDialog;
                if not Confirmed then
                    Confirmed := Confirm(Text015, false, TransH."Transaction No.", Format(TransH."Transaction Type"));
                if not Confirmed then
                    Error('');
                TransHead := TransH;
                TransHead.VoidTransaction(pRetailuser);
            until TransH.Next() = 0;
    end;

    internal procedure FormatDec(Value: Decimal; Places: Integer; BlankZero: Boolean) Result: Text
    var
        V: Decimal;
        f: Integer;
    begin
        f := Power(10, Places);
        V := Round(Value * f, 1) / f;
        if Places = 0 then
            exit(Format(V));

        if BlankZero and (V = 0) then
            exit('');

        f := Power(10, Places + 1);
        V := V + (1 / f);
        Result := Format(V);
        exit(CopyStr(Result, 1, StrLen(Result) - 1));
    end;

    internal procedure StaffLogin(var pRetailUser: Record "CCS CASH Retail User"): Boolean
    var
        CSLLogin: Page "CCS CASH Cash Sales Login";
    begin
        if (CSLLogin.RunModal() = ACTION::OK) or CSLLogin.GetExitMode() then begin
            if CSLLogin.GetStaffSetup(pRetailUser) then begin
                POSTerm.Get(pRetailUser."Store No", pRetailUser."POS Terminal No.");
                if POSTerm.Status() = 99 then
                    DayEnd(pRetailUser, true);
                CreateTransLog(pRetailUser, TransHead."Transaction Type"::Logon);
                exit(true);
            end else
                Error(Error001);
        end;
        Error(Error002);
    end;

    internal procedure PrintReport(pPrintOption: Option CashReceipt,CashInvoice,CustPayment,StartDay,EndDay,Journal,Tenderdecl,Voucher; var pTransH: Record "CCS CASH POS Transaction Hdr."; pShowDialog: Boolean)
    var
        LText: Label 'Printing %1... (not defined)', Comment = '%1=Value 1';
        TransH: Record "CCS CASH POS Transaction Hdr.";
        MsgShown: array[10] of Boolean;
    begin
        CSLSetup.Get();
        Clear(MsgShown);
        TransH := pTransH;
        TransH.SetRecFilter();
        case pPrintOption of
            pPrintOption::CashInvoice:
                begin
                    //--POS0003
                    if (TransH."Transaction Type" = TransH."Transaction Type"::Sales)
                      // + POS0025
                      or
                       (TransH."Transaction Type" = TransH."Transaction Type"::Zero)
                       // - POS0025
                       then
                        if CSLSetup."Cash Invoice Report ID" <> 0 then
                            REPORT.RunModal(CSLSetup."Cash Invoice Report ID", pShowDialog, true, TransH)
                        else begin
                            if not MsgShown[1] then
                                Message(LText, CSLSetup.FieldCaption("Cash Invoice Report ID"));
                            MsgShown[1] := true;
                        end;
                    if (TransH."Transaction Type" = TransH."Transaction Type"::Return) then
                        if CSLSetup."Cash CrMemo Report ID" <> 0 then
                            REPORT.RunModal(CSLSetup."Cash CrMemo Report ID", pShowDialog, true, TransH)
                        else begin
                            if not MsgShown[1] then
                                Message(LText, CSLSetup.FieldCaption("Cash CrMemo Report ID"));
                            MsgShown[1] := true;
                        end;
                end;
            pPrintOption::CashReceipt:
                begin
                    case TransH."Transaction Type" of
                        TransH."Transaction Type"::Sales,
                      // + POS0025
                      TransH."Transaction Type"::Zero:
                            // - POS0025
                            if CSLSetup."Cash Receipt Invoice Report ID" = 0 then begin
                                if not MsgShown[2] then
                                    Message(LText, CSLSetup.FieldCaption("Cash Receipt Invoice Report ID"));
                                MsgShown[2] := true;
                            end else begin
                                if CSLSetup."No Dialog on Receipt Print" then
                                    pShowDialog := false;
                                REPORT.RunModal(CSLSetup."Cash Receipt Invoice Report ID", pShowDialog, true, TransH)
                            end;
                        TransH."Transaction Type"::Return:
                            if CSLSetup."Cash Receipt CrMemo Report ID" = 0 then begin
                                if not MsgShown[2] then
                                    Message(LText, CSLSetup.FieldCaption("Cash Receipt CrMemo Report ID"));
                                MsgShown[2] := true;
                            end else begin
                                if CSLSetup."No Dialog on Receipt Print" then
                                    pShowDialog := false;
                                REPORT.RunModal(CSLSetup."Cash Receipt CrMemo Report ID", pShowDialog, true, TransH)
                            end;
                        TransH."Transaction Type"::"Remove Tender",
                      TransH."Transaction Type"::"Float Entry",
                      TransH."Transaction Type"::Expense:
                            if CSLSetup."Daystart Report ID" = 0 then begin
                                if not MsgShown[2] then
                                    Message(LText, CSLSetup.FieldCaption("Daystart Report ID"));
                                MsgShown[2] := true;
                            end else begin
                                if CSLSetup."No Dialog on Receipt Print" then
                                    pShowDialog := false;
                                REPORT.RunModal(CSLSetup."Daystart Report ID", pShowDialog, true, TransH)
                            end;
                        TransH."Transaction Type"::Deposit:
                            if CSLSetup."Daystart Report ID" = 0 then begin
                                if not MsgShown[2] then
                                    Message(LText, CSLSetup.FieldCaption("Daystart Report ID"));
                                MsgShown[2] := true;
                            end else begin
                                if CSLSetup."No Dialog on Receipt Print" then
                                    pShowDialog := false;
                                REPORT.RunModal(CSLSetup."Daystart Report ID", pShowDialog, true, TransH)
                            end;
                    end;
                    //++POS0003
                end;

            pPrintOption::CustPayment:
                if TransH."Transaction Type" = TransH."Transaction Type"::Payment then
                    if CSLSetup."Cust. Payment Report ID" <> 0 then begin
                        if CSLSetup."No Dialog on Receipt Print" then
                            pShowDialog := false;
                        REPORT.RunModal(CSLSetup."Cust. Payment Report ID", pShowDialog, true, TransH)
                    end else begin
                        if not MsgShown[7] then
                            Message(LText, CSLSetup.FieldCaption("Cust. Payment Report ID"));
                        MsgShown[7] := true;
                    end;

            pPrintOption::EndDay:
                if TransH."Transaction Type" = TransH."Transaction Type"::EndDay then begin
                    TransH.SetRecFilter();
                    //TransH.SETRANGE("Transaction No.");
                    //TransH.SETRANGE("Creation Date",TransH."Creation Date");
                    if CSLSetup."Dayend Report ID" <> 0 then
                        REPORT.RunModal(CSLSetup."Dayend Report ID", pShowDialog, true, TransH)
                    else begin
                        if not MsgShown[3] then
                            Message(LText, CSLSetup.FieldCaption("Dayend Report ID"));
                        MsgShown[3] := true;
                    end;
                end;

            pPrintOption::StartDay:
                if TransH."Transaction Type" = TransH."Transaction Type"::Startday then
                    if CSLSetup."Daystart Report ID" <> 0 then
                        REPORT.RunModal(CSLSetup."Daystart Report ID", pShowDialog, true, TransH)
                    else begin
                        if not MsgShown[4] then
                            Message(LText, CSLSetup.FieldCaption("Daystart Report ID"));
                        MsgShown[4] := true;
                    end;

            pPrintOption::Journal:
                if CSLSetup."Cash Journal Report ID" <> 0 then begin
                    TransH.CopyFilters(pTransH);
                    REPORT.RunModal(CSLSetup."Cash Journal Report ID", pShowDialog, true, TransH)
                end else begin
                    if not MsgShown[5] then
                        Message(LText, CSLSetup.FieldCaption("Cash Journal Report ID"));
                    MsgShown[5] := true;
                end;

            pPrintOption::Tenderdecl:
                if CSLSetup."TenderDecl Report ID" <> 0 then
                    REPORT.RunModal(CSLSetup."TenderDecl Report ID", pShowDialog, true, TransH)
                else begin
                    if not MsgShown[6] then
                        Message(LText, CSLSetup.FieldCaption("TenderDecl Report ID"));
                    MsgShown[6] := true;
                end;
            // + POS0007
            pPrintOption::Voucher:
                if CSLSetup."Voucher Report ID" <> 0 then
                    REPORT.RunModal(CSLSetup."Voucher Report ID", pShowDialog, true, TransH)
                else begin
                    if not MsgShown[8] then
                        Message(LText, CSLSetup.FieldCaption("Voucher Report ID"));
                    MsgShown[8] := true;
                end;
        // - POS0007
        end;
    end;

    internal procedure GetFormattedBonAdress(var pTransH: Record "CCS CASH POS Transaction Hdr."; var CustAddress: array[8] of Text[50]): Boolean
    var
        TranssalesEntry: Record "CCS CASH Trans. Sales Entry";
        SalesInv: Record "Sales Invoice Header";
        SalesInv2: Record "Sales Invoice Header";
        SalesCrMem: Record "Sales Cr.Memo Header";
        FormatAddr: Codeunit "Format Address";
    begin
        Clear(CustAddress);
        if pTransH.Status <> pTransH.Status::Normal then
            exit;

        case pTransH."Transaction Type" of
            pTransH."Transaction Type"::Payment:
                begin
                    TranssalesEntry.SetRange("Store No.", pTransH."Store No.");
                    TranssalesEntry.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
                    TranssalesEntry.SetRange("Transaction No.", pTransH."Transaction No.");
                    if TranssalesEntry.FindSet() then
                        repeat
                            if SalesInv2.Get(TranssalesEntry."No.") and (SalesInv."Posting Date" < SalesInv2."Posting Date") then
                                SalesInv := SalesInv2;
                        until TranssalesEntry.Next() = 0;
                end;
            pTransH."Transaction Type"::Sales:
                begin
                    SalesInv.Setrange("CCS CASH CSL Transaction No.", pTransH."Transaction No.");
                    SalesInv.SetRange("CCS CASH CSL Store No.", pTransH."Store No.");
                    SalesInv.SetRange("CCS CASH CSL POS Terminal No.", pTransH."POS Terminal No.");
                    if not SalesInv.FindFirst() then
                        //if not SalesInv.Get(pTransH."Receipt No.") then
                        Clear(SalesInv);
                end;
            pTransH."Transaction Type"::Return:
                begin
                    SalesCrMem.Setrange("CCS CASH CSL Transaction No.", pTransH."Transaction No.");
                    SalesCrMem.SetRange("CCS CASH CSL Store No.", pTransH."Store No.");
                    SalesCrMem.SetRange("CCS CASH CSL POS Terminal No.", pTransH."POS Terminal No.");
                    if not SalesCrMem.FindFirst() then
                        //if not SalesCrMem.Get(pTransH."Receipt No.") then
                        Clear(SalesCrMem);
                end;
            else
                exit;
        end;

        if SalesInv."No." <> '' then begin
            FormatAddr.SalesInvSellTo(CustAddress, SalesInv);
            exit(true);
        end;

        if SalesCrMem."No." <> '' then begin
            FormatAddr.SalesCrMemoSellTo(CustAddress, SalesCrMem);
            exit(true);
        end;
    end;

    internal procedure EnterSession(var pPOSTerm: Record "CCS CASH POS Terminal")
    var
        Session: Record "Active Session";
    begin
        if pPOSTerm."Open in Session" <> 0 then begin
            //--POS0020
            //Session.SETRANGE("Session ID",pPOSTerm."Open in Session");
            //IF NOT Session.FindFirst() THEN BEGIN
            //++POS0035
            //IF NOT Session.GET(POSTerm."Open in Server Instance ID",pPOSTerm."Open in Session") THEN BEGIN

            //Geändert, kann man im WebClient nicht machen weil da die Sessions ewig hängen bleiben:
            //if not Session.Get(pPOSTerm."Open in Server Instance ID", pPOSTerm."Open in Session") then begin            
            pPOSTerm."Open in Server Instance ID" := 0;
            pPOSTerm."Open in Session" := 0;
            pPOSTerm.Modify();
            //end;
            Session.Reset();
        end;

        if pPOSTerm."Open in Session" = 0 then begin
            pPOSTerm."Open in Session" := SessionId();
            //--POS0020
            pPOSTerm."Open in Server Instance ID" := ServiceInstanceId();
            //++POS0020
            pPOSTerm.Modify();
            exit;
        end;

        ExitSession(pPOSTerm); //Wird das nicht gemacht, dann kommt man nicht mehr in die Session rein.
        Error(Text025, Session."Client Computer Name", Session."User ID");
    end;

    internal procedure ExitSession(var pPOSTerm: Record "CCS CASH POS Terminal")
    begin
        //--POS0027
        pPOSTerm.Get(pPOSTerm."Store No", pPOSTerm."No.");
        //++POS0027

        if pPOSTerm."Open in Session" = 0 then
            exit;

        //--POS0020
        /*
        IF pPOSTerm."Open in Session" = SESSIONID THEN BEGIN
          pPOSTerm."Open in Session" := 0;
          pPOSTerm.Modify();
        END;
        */
        if (pPOSTerm."Open in Session" = SessionId()) and
           (pPOSTerm."Open in Server Instance ID" = ServiceInstanceId()) then begin
            pPOSTerm."Open in Session" := 0;
            pPOSTerm."Open in Server Instance ID" := 0;
            pPOSTerm.Modify();
        end;
        //++POS0020

    end;

    internal procedure TestVoucher(var pTransH: Record "CCS CASH POS Transaction Hdr.")
    var
        Res: Record Resource;
        TransSales: Record "CCS CASH Trans. Sales Entry";
    begin
        TransSales.SetRange("Store No.", pTransH."Store No.");
        TransSales.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
        TransSales.SetRange("Transaction No.", pTransH."Transaction No.");
        TransSales.SetRange(IsVoucher, true);
        if not TransSales.Find('-') then
            exit;

        repeat
            Res.Get(TransSales."No.");
            Res.TestField("CCS CASH Voucher No. Series");
            if Res."CCS CASH Voucher C. No. Mand." then begin
                if Abs(TransSales.Quantity) > 1 then
                    Error(Error012);
                if Abs(TransSales.Quantity) > 0 then
                    TransSales.TestField("Voucher Card No.");
            end;
        until TransSales.Next() = 0;
    end;

    internal procedure ChangeTransactionDateTime(var pTransHeader: Record "CCS CASH POS Transaction Hdr."; DateToSet: Date; TimeToSet: Time)
    var
        TransHeader: Record "CCS CASH POS Transaction Hdr.";
        DateTimeToSet: DateTime;
        TransHDateTime: DateTime;
    begin
        //++POS0008

        TransHeader.SetRange("Store No.", pTransHeader."Store No.");
        TransHeader.SetRange("POS Terminal No.", pTransHeader."POS Terminal No.");
        TransHeader.SetRange("Transaction Type", TransHeader."Transaction Type"::EndDay);

        if TransHeader.FindFirst() then begin

            TransHDateTime := CreateDateTime(TransHeader."Creation Date",
              TransHeader."Creation Time");
            DateTimeToSet := CreateDateTime(DateToSet, TimeToSet);

            if (DateTimeToSet > TransHDateTime) then begin

                pTransHeader."Creation Date" := DateToSet;
                pTransHeader."Creation Time" := TimeToSet;
                pTransHeader.Modify();
            end
            else
                Error(Error011, Format(DateToSet), Format(TransHeader."Creation Date"));

        end;

        //--POS0008
    end;

    internal procedure ZeroTransaction(var pRetailUser: Record "CCS CASH Retail User"; pTransType: enum "CCS CASH Zero Receipt Type")
    var
        EFSTA001: Label 'Signatur Setup is not active.';
    begin
        // ++ EFSTA2.06
        if not IsSignatureSetupActive(pRetailUser."Store No", pRetailUser."POS Terminal No.") then begin
            Message(EFSTA001);
            exit;
        end;
        // -- EFSTA2.06
        // ++ EFSTA2.01
        if IsSignatureServiceDown(pRetailUser."Store No", pRetailUser."POS Terminal No.", '') then
            exit;
        // -- EFSTA2.01

        // + POS0025
        GetPOSTerm(pRetailUser."Store No", pRetailUser."POS Terminal No.");
        CreateTransLog(pRetailUser, TransHead."Transaction Type"::Zero);
        if TransHead."Receipt No." = '' then
            TransHead."Receipt No." := NoSeriesMgt.GetNextNo(POSTerm."Posted Receipt Nos.", WorkDate(), true);
        // ++ EFSTA2.03
        TransHead."Zero Receipt Type" := pTransType;
        // -- EFSTA2.03
        TransHead.Modify(true);
        CallSignatureService(TransHead);
        //Print Zero Document
        Commit();
        PrintReport(Print_OP::CashReceipt, TransHead, true);
        // - POS0025
    end;

    internal procedure DoOrderPosting2(var pSalesHeader: Record "Sales Header"): Boolean
    var
        UserSetup: Record "User Setup";
        RetailUser: Record "CCS CASH Retail User";
        Staff: Record "CCS CASH Staff";
        Store: Record "CCS CASH Store";
        PaymentPage: Page "CCS CASH Payment";
        POSRegSalesTrg: Codeunit "CCS CASH POS Reg. Sales Trg.";
        ReturnDoc: boolean;
        TransactionPosted: Boolean;
        PosTerminalNotOpenedErr: Label 'POS Terminal %1 was not opened.', Comment = '%1=Value 1';
    begin
        if pSalesHeader."CCS CASH CSL Do Cash Posting" then begin
            pSalesHeader."CCS CASH CSL Transaction No." := 0;
            pSalesHeader."CCS CASH CSL Do Cash Posting" := false;
            pSalesHeader."CCS CASH CSL Document" := false;
            pSalesHeader."CCS CASH CSL Store No." := '';
            pSalesHeader."CCS CASH CSL POS Terminal No." := '';
            pSalesHeader."CCS CASH CSL Staff ID" := '';
            pSalesHeader.Modify();
            Commit();
        end;

        UserSetup.Get(UserId);
        UserSetup.TestField("CCS CASH POS No.");
        UserSetup.TestField("CCS CASH Staff ID");
        UserSetup.TestField("CCS CASH Store No.");

        RetailUser.Get(UserSetup."CCS CASH Staff ID", UserSetup."CCS CASH Store No.", UserSetup."CCS CASH POS No.");

        CSLSetup.Get();
        VoidOpenTransactions(RetailUser, CSLSetup."Autovoid Open Transactions");
        ReturnDoc := pSalesHeader."Document Type" = pSalesHeader."Document Type"::"Return Order";

        if ReturnDoc then
            CreateTransLog(RetailUser, TransHead."Transaction Type"::Return)
        else
            CreateTransLog(RetailUser, TransHead."Transaction Type"::Sales);

        POSRegSalesTrg.SyncSalesDocument(pSalesHeader, TransHead, RetailUser);

        TransHead.SetRecFilter();

        Staff.Get(RetailUser."Staff ID");
        Store.Get(RetailUser."Store No");
        DayStart(RetailUser);
        if POSTerm.Status() <> 1 then
            Error(PosTerminalNotOpenedErr, POSTerm."No.");
        PaymentPage.SetTransactionHeader(TransHead);
        PaymentPage.SetDelayedPostingMode(true);
        Commit();
        PaymentPage.RunModal();
        TransactionPosted := PaymentPage.GetPostingStatus();
        if TransactionPosted then begin
            pSalesHeader."CCS CASH CSL Transaction No." := TransHead."Transaction No.";
            pSalesHeader."CCS CASH CSL Do Cash Posting" := true;
            pSalesHeader."CCS CASH CSL Document" := true;
            pSalesHeader."CCS CASH CSL Store No." := RetailUser."Store No";
            pSalesHeader."CCS CASH CSL POS Terminal No." := RetailUser."POS Terminal No.";
            pSalesHeader."CCS CASH CSL Staff ID" := RetailUser."Staff ID";
            exit(true);
        end else begin
            if TransHead.Get(TransHead."Store No.", TransHead."POS Terminal No.", TransHead."Transaction No.") then
                TransHead.VoidTransaction(RetailUser);
            exit(false);
        end;

    end;

    internal procedure DoOrderPosting(var pSalesHeader: Record "Sales Header"): Boolean
    var
        UserSetup: Record "User Setup";
        RetailUser: Record "CCS CASH Retail User";
        NewSalesHeader: Record "Sales Header";
        SalesShptLine: Record "Sales Shipment Line";
        ReturnRcptLine: Record "Return Receipt Line";
        SalesPost: Codeunit "Sales-Post";
        SalesGetShpt: Codeunit "Sales-Get Shipment";
        SalesGetRcpt: Codeunit "Sales-Get Return Receipts";
        POSTerminalDevice: Page "CCS CASH POS Terminal Device";
        ReturnDoc: Boolean;
    begin
        //+POS0036
        if pSalesHeader."Document Type" in [pSalesHeader."Document Type"::Invoice, pSalesHeader."Document Type"::"Credit Memo"] then
            Error(Text029);

        if pSalesHeader.Invoice then begin
            pSalesHeader.Invoice := false;
            pSalesHeader.Modify(true);
        end;

        if (pSalesHeader.Ship or pSalesHeader.Receive) then begin
            SalesPost.SetSuppressCommit(true);
            SalesPost.Run(pSalesHeader);
        end;

        UserSetup.Get(UserId);
        UserSetup.TestField("CCS CASH POS No.");
        UserSetup.TestField("CCS CASH Staff ID");
        UserSetup.TestField("CCS CASH Store No.");

        POSTerm.Get(UserSetup."CCS CASH Store No.", UserSetup."CCS CASH POS No.");
        if POSTerm.Status() = 0 then
            Error(Error004, POSTerm."No.");
        RetailUser.Get(UserSetup."CCS CASH Staff ID", UserSetup."CCS CASH Store No.", UserSetup."CCS CASH POS No.");
        if IsSignatureServiceDown(UserSetup."CCS CASH Store No.", UserSetup."CCS CASH POS No.", '') then
            exit;

        CSLSetup.Get();
        VoidOpenTransactions(RetailUser, CSLSetup."Autovoid Open Transactions");

        ReturnDoc := pSalesHeader."Document Type" = pSalesHeader."Document Type"::"Return Order";
        if ReturnDoc then begin
            //IF pSalesHeader."Last Return Receipt No." = '' THEN
            //  pSalesHeader.FIELDERROR("Last Return Receipt No.");
            ReturnRcptLine.SetRange("Return Order No.", pSalesHeader."No.");
            if ReturnRcptLine.IsEmpty then
                Error(Text030, ReturnRcptLine.TableCaption);
        end else begin
            //IF pSalesHeader."Last Shipping No." = '' THEN
            //  pSalesHeader.FIELDERROR("Shipping No.");
            SalesShptLine.SetRange("Order No.", pSalesHeader."No.");
            if SalesShptLine.IsEmpty then
                Error(Text030, SalesShptLine.TableCaption);
        end;

        NewSalesHeader.Init();
        NewSalesHeader.SetHideValidationDialog(true);
        NewSalesHeader."CCS CASH CSL Document" := true;
        NewSalesHeader."CCS CASH CSL Store No." := RetailUser."Store No";
        NewSalesHeader."CCS CASH CSL POS Terminal No." := RetailUser."POS Terminal No.";
        NewSalesHeader."CCS CASH CSL Staff ID" := RetailUser."Staff ID";
        if ReturnDoc then
            NewSalesHeader."Document Type" := NewSalesHeader."Document Type"::"Credit Memo"
        else
            NewSalesHeader."Document Type" := NewSalesHeader."Document Type"::Invoice;
        NewSalesHeader."No." := '';
        NewSalesHeader.Validate("Sell-to Customer No.", pSalesHeader."Bill-to Customer No.");
        if pSalesHeader."Location Code" <> '' then
            NewSalesHeader.Validate("Location Code", pSalesHeader."Location Code");

        if ReturnDoc then
            NewSalesHeader."CCS CASH CSL Transaction No." := CreateTransLog(RetailUser, TransHead."Transaction Type"::Return)
        else
            NewSalesHeader."CCS CASH CSL Transaction No." := CreateTransLog(RetailUser, TransHead."Transaction Type"::Sales);
        NewSalesHeader.Insert(true);
        Commit();

        if ReturnDoc then begin
            SalesGetRcpt.SetSalesHeader(NewSalesHeader);
            SalesGetRcpt.CreateInvLines(ReturnRcptLine);
        end else begin
            SalesGetShpt.SetSalesHeader(NewSalesHeader);
            SalesGetShpt.CreateInvLines(SalesShptLine);
        end;

        POSTerminalDevice.CallLoginOutside(RetailUser);
        POSTerminalDevice.SetSalesHeader(NewSalesHeader);
        POSTerminalDevice.SetAutoOption(2);
        Commit();
        POSTerminalDevice.RunAutoOption();
        Commit();
        exit(true);
        //-POS0036
    end;

    /*local procedure DoWhseShptPosting(pWhseShptLine: Record "Warehouse Shipment Line"; pInvoice: Boolean; pPrint: Boolean; var pCountDocsPosted: Integer): Boolean
    var
        SalesHeader: Record "Sales Header";
        PayMethod: Record "Payment Method";
        RetailSetup: Record "CCS CASH Cash Sales Setup";
        WhseShipPost: Codeunit "Whse.-Post Shipment";
    begin
        //+POS0036
        if not pInvoice or not (pWhseShptLine."Source Document" in [pWhseShptLine."Source Document"::"Sales Order", pWhseShptLine."Source Document"::"Sales Return Order"]) then
            exit;

        RetailSetup.Get();
        if not RetailSetup.CSLDialogPosting then
            exit;

        if pWhseShptLine."Source Document" = pWhseShptLine."Source Document"::"Sales Order" then
            SalesHeader.Get(SalesHeader."Document Type"::Order, pWhseShptLine."Source No.")
        else
            SalesHeader.Get(SalesHeader."Document Type"::"Return Order", pWhseShptLine."Source No.");
        Clear(PayMethod);
        if SalesHeader."Payment Method Code" <> '' then
            if not PayMethod.Get(SalesHeader."Payment Method Code") then
                PayMethod.Init();
        if PayMethod."CCS CASH CSL Tender Type" = '' then
            exit;


        WhseShipPost.SetPrint(pPrint);
        // >> CCXX
        //WhseShipPost.RUN(pWhseShptLine);
        //WhseShipPost.GetCounterSorceDocOK(pCountDocsPosted);
        if not DoWhseShptPosting(pWhseShptLine, false, pPrint, pCountDocsPosted) then begin
            WhseShipPost.Run(pWhseShptLine);
        end;
        // << CCxx

        SalesHeader.Find();
        SalesHeader.Ship := false;
        SalesHeader.Receive := false;
        SalesHeader.Modify();
        Commit();
        DoOrderPosting(SalesHeader);
        Commit();
        exit(true);
        //-POS0036
    end;*/

    local procedure NeedDailyPOSClose(POSTerminal: Record "CCS CASH POS Terminal"): Boolean
    var
        Store: Record "CCS CASH Store";
    begin
        if POSTerminal."Daily Statement necessary" then
            exit(true);

        Store.Get(POSTerminal."Store No");
        if Store."Daily Statement necessary" then
            exit(true);

        exit(false);
    end;

    internal procedure PostSalesDocumentTenderPayment(var pSalesHeader: Record "Sales Header"; SalesInvoice: Record "Sales Invoice Header"; SalesCrMemo: Record "Sales Cr.Memo Header"; EverythingInvoiced: Boolean)
    var
        TransHeader: Record "CCS CASH POS Transaction Hdr.";
        TransPaymentBuffer: Record "CCS CASH Trans. Payment Entry";
        RetailUser: Record "CCS CASH Retail User";
        SalesInvoiceLine: Record "Sales Invoice Line";
        TPmt: Record "CCS CASH Trans. Payment Entry";
        Txt: Text[100];
        PaymentTotalAmout: Decimal;
        HasVoucher: Boolean;
        NextLineNo: Integer;
    begin
        if not pSalesHeader."CCS CASH CSL Do Cash Posting" then
            exit;

        if (SalesInvoice."No." = '') and (SalesCrMemo."No." = '') then
            exit;

        TransHeader.Get(pSalesHeader."CCS CASH CSL Store No.", pSalesHeader."CCS CASH CSL POS Terminal No.", pSalesHeader."CCS CASH CSL Transaction No.");

        POSTerm.Get(pSalesHeader."CCS CASH CSL Store No.", pSalesHeader."CCS CASH CSL POS Terminal No.");
        if POSTerm.Status() = 0 then
            Error(Error004, POSTerm."No.");

        CSLSetup.Get();

        if not EverythingInvoiced then begin
            pSalesHeader."CCS CASH CSL Transaction No." := 0;
            pSalesHeader."CCS CASH CSL Do Cash Posting" := false;
            pSalesHeader."CCS CASH CSL Document" := false;
            pSalesHeader."CCS CASH CSL Store No." := '';
            pSalesHeader."CCS CASH CSL POS Terminal No." := '';
            pSalesHeader."CCS CASH CSL Staff ID" := '';
            pSalesHeader.Modify();
        end;

        if IsSignatureServiceDown(TransHeader."Store No.", TransHeader."POS Terminal No.", '') then
            exit;

        RetailUser.Get(TransHeader."Staff ID", TransHeader."Store No.", TransHeader."POS Terminal No.");
        //EnterSession(POSTerm);
        TestVoucher(TransHeader);

        // check if return value exceeds cash register balance

        if TransHeader."Transaction Type" = TransHeader."Transaction Type"::Return then begin
            GetPOSTerm(TransHeader."Store No.", TransHeader."POS Terminal No.");
            POSTerm.CalcFields(Balance);
            TransPaymentBuffer.SetRange("Store No.", TransHeader."Store No.");
            TransPaymentBuffer.SetRange("POS Terminal No.", TransHeader."POS Terminal No.");
            TransPaymentBuffer.SetRange("Transaction No.", TransHeader."Transaction No.");
            if TransPaymentBuffer.FindSet() then
                repeat
                    if TransPaymentBuffer."Cash entry" then
                        PaymentTotalAmout += TransPaymentBuffer.Amount;
                until TransPaymentBuffer.Next() = 0;
            if Abs(PaymentTotalAmout) > POSTerm.Balance then
                Error(Error011, Abs(PaymentTotalAmout), POSTerm.Balance);
        end;

        if TransHeader."Customer No." = '' then
            TransHeader."Customer No." := pSalesHeader."Bill-to Customer No.";
        TransHeader.Reasoncode := ReasonCode;
        TransHeader.Status := TransHeader.Status::Normal;
        PostPayment(TransHeader, pSalesHeader, true);
        TransHeader.Modify(true);

        if CSLSetup."Merge Pmt to Document" then begin
            if SalesInvoice."No." <> '' then begin
                SalesInvoiceLine.SetRange("Document No.", SalesInvoice."No.");
                if SalesInvoiceLine.FindLast() then
                    NextLineNo := SalesInvoiceLine."Line No.";
            end;
            TPmt.SetRange("Store No.", TransHeader."Store No.");
            TPmt.SetRange("POS Terminal No.", TransHeader."POS Terminal No.");
            TPmt.SetRange("Transaction No.", TransHeader."Transaction No.");
            if TPmt.FindSet() then
                repeat
                    NextLineNo += 10000;
                    if TPmt."Card No." <> '' then
#pragma warning disable AA0217
                    Txt := StrSubstNo('%1(%2): %3', TPmt."Tender Type", TPmt."Card No.", TPmt."Tender Description")
#pragma warning restore AA0217
                    else
#pragma warning disable AA0217
                    Txt := StrSubstNo('%1: %2', TPmt."Tender Type", TPmt."Tender Description");
#pragma warning restore AA0217
                    if SalesInvoice."No." <> '' then begin
                        SalesInvoiceLine.Init();
                        SalesInvoiceLine."Document No." := SalesInvoice."No.";
                        SalesInvoiceLine."Line No." := NextLineNo;
                        SalesInvoiceLine.Validate(Type, SalesInvoiceLine.Type::" ");
                        SalesInvoiceLine.Description := CopyStr(Txt, 1, MaxStrLen(SalesInvoiceLine.Description));
                        SalesInvoiceLine."CCS CASH CSL Payment Amount" := TPmt.Amount;
                        SalesInvoiceLine."CCS CASH CSL PaymentText" := true;
                        SalesInvoiceLine.Insert();
                    end;
                until TPmt.Next() = 0;

        end;

        CallSignatureService(TransHeader);

        HasVoucher := CreateVoucher(TransHeader) or CreateFollowupVoucher(TransHeader);

        //ExitSession(POSTerm);
        Commit();
        PrintReport(Print_OP::CashReceipt, TransHeader, true);

        if HasVoucher then begin
            CSLSetup.Get();
            PrintReport(Print_OP::Voucher, TransHeader, not CSLSetup."No Dialog on Receipt Print");
        end;
    end;

    local procedure DoPostSales(var pTransH: Record "CCS CASH POS Transaction Hdr.")
    var
        CashInv: Record "Sales Header";
        TransH: Record "CCS CASH POS Transaction Hdr.";
        PostSales: Codeunit "Sales-Post";
        TransPaymentBuffer: Record "CCS CASH Trans. Payment Entry";
        PaymentTotalAmout: Decimal;
        HasVoucher: Boolean;
    begin
        // ++ EFSTA2.01
        if IsSignatureServiceDown(pTransH."Store No.", pTransH."POS Terminal No.", '') then
            exit;
        // -- EFSTA2.01

        CSLSetup.Get();
        TransH := pTransH;

        // + POS0007
        TestVoucher(pTransH);
        // - POS0007

        //--POS0006

        // check if return value exceeds cash register balance

        if TransH."Transaction Type" = TransH."Transaction Type"::Return then begin

            GetPOSTerm(TransH."Store No.", TransH."POS Terminal No.");
            POSTerm.CalcFields(Balance);
            TransPaymentBuffer.SetRange("Store No.", TransH."Store No.");
            TransPaymentBuffer.SetRange("POS Terminal No.", TransH."POS Terminal No.");
            TransPaymentBuffer.SetRange("Transaction No.", TransH."Transaction No.");
            if TransPaymentBuffer.FindSet() then
                repeat
                    if TransPaymentBuffer."Cash entry" then
                        PaymentTotalAmout += TransPaymentBuffer.Amount;
                until TransPaymentBuffer.Next() = 0;
            if Abs(PaymentTotalAmout) > POSTerm.Balance then
                Error(Error011, Abs(PaymentTotalAmout), POSTerm.Balance);

        end;

        //++POS0006

        if pTransH."Customer No." = '' then
            pTransH."Customer No." := CashInv."Bill-to Customer No.";
        pTransH.Reasoncode := ReasonCode;
        pTransH.Status := pTransH.Status::Normal;

        CashInv.SetRange("CCS CASH CSL Store No.", pTransH."Store No.");
        CashInv.SetRange("CCS CASH CSL POS Terminal No.", pTransH."POS Terminal No.");
        CashInv.SetRange("CCS CASH CSL Transaction No.", pTransH."Transaction No.");
        CashInv.FindFirst();

        PostPayment(TransH, CashInv, true);
        pTransH.Modify(true);


        CashInv.SetRecFilter();

        if CSLSetup."Merge Pmt to Document" then
            MergePmtLines(pTransH, CashInv);

        CashInv.Invoice := true;

        //++POS0008

        //IF CashInv."Posting Date" <> WORKDATE THEN BEGIN
        //  CashInv."Posting Date" := WorkDate();
        //  CashInv."Document Date" := WorkDate();
        //  CashInv.VALIDATE("Payment Discount %");
        //END;

        if CashInv."Posting Date" <> pTransH."Creation Date" then begin
            CashInv."Posting Date" := pTransH."Creation Date";
            CashInv."Document Date" := pTransH."Creation Date";
            CashInv.Validate("Payment Discount %");
        end;

        //--POS0008

        CashInv.Modify();

        Clear(PostSales);
        // TODO CCxx PostSales.PrepareCSLPosting(TempPmtBuffer);
        PostSales.SetSuppressCommit(true);
        PostSales.Run(CashInv);
        pTransH.Find();

        // ++ EFSTA2.00
        // Insert EFR Functions here
        CallSignatureService(pTransH);
        // -- EFSTA2.00



        HasVoucher := CreateVoucher(pTransH) or CreateFollowupVoucher(pTransH);
        // - POS0007

        Commit();
        PrintReport(Print_OP::CashReceipt, pTransH, true);

        // + POS0007
        if HasVoucher then begin
            CSLSetup.Get();
            PrintReport(Print_OP::Voucher, pTransH, not CSLSetup."No Dialog on Receipt Print");
        end;
        // - POS0007
    end;

    local procedure CreateVoucher(var pTransH: Record "CCS CASH POS Transaction Hdr."): Boolean
    var
        TransSales: Record "CCS CASH Trans. Sales Entry";
        Res: Record Resource;
        VoucherEntry: Record "CCS CASH Voucher Entry";
    begin
        TransSales.SetRange("Store No.", pTransH."Store No.");
        TransSales.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
        TransSales.SetRange("Transaction No.", pTransH."Transaction No.");
        TransSales.SetRange("IsVoucher", true);
        if not TransSales.Find('-') then
            exit(false);

        repeat
            Res.Get(TransSales."No.");
            TransSales."Voucher Serial No." := NoSeriesMgt.GetNextNo(Res."CCS CASH Voucher No. Series", Today, true);
            if TransSales."Voucher Card No." = '' then
                TransSales."Voucher Card No." := TransSales."Voucher Serial No.";
            TransSales.Modify();
            VoucherEntry.Init();
            VoucherEntry."Voucher No." := TransSales."Voucher Serial No.";
            VoucherEntry."Entry No." := 0;
            VoucherEntry."Store No." := pTransH."Store No.";
            VoucherEntry."POS Terminal No" := pTransH."POS Terminal No.";
            VoucherEntry."Transaction No." := pTransH."Transaction No.";
            VoucherEntry."Transact. Line No." := TransSales."Entry No.";
            VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::Issued;
            VoucherEntry."Receipt No." := pTransH."Receipt No.";
            VoucherEntry.Amount := -TransSales."Amount incl. VAT";
            VoucherEntry."Voucher Card No." := TransSales."Voucher Card No.";
            VoucherEntry."Voucher No. Series" := Res."CCS CASH Voucher No. Series";
            VoucherEntry.Date := Today;
            VoucherEntry.Time := Time;
            VoucherEntry.Insert(true);
        until TransSales.Next() = 0;
        exit(true);
    end;

    local procedure CreateFollowupVoucher(var pTransH: Record "CCS CASH POS Transaction Hdr.") NewVoucherCreated: Boolean
    var
        TransPmt: Record "CCS CASH Trans. Payment Entry";
        TenderType: Record "CCS CASH Store Tender Type";
        VoucherEntry: Record "CCS CASH Voucher Entry";
        VoucherPmt: Record "CCS CASH Voucher Entry";
    begin
        TransPmt.SetRange("Store No.", pTransH."Store No.");
        TransPmt.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
        TransPmt.SetRange("Transaction No.", pTransH."Transaction No.");

        if TransPmt.FindSet() then
            repeat
                TenderType.Get(pTransH."Store No.", TransPmt."Tender Type");
                if (TenderType.TenderFunction = TenderType.TenderFunction::Voucher) and TenderType."Voucher Info required" then begin
                    VoucherEntry.Get(TransPmt."Card No.", 0);
                    VoucherEntry.TestField(Voided, false);
                    VoucherPmt := VoucherEntry;
                    VoucherPmt."Entry No." := 1;
                    VoucherPmt."Entry Type" := VoucherPmt."Entry Type"::Redemption;
                    VoucherPmt."Store No." := pTransH."Store No.";
                    VoucherPmt."POS Terminal No" := pTransH."POS Terminal No.";
                    VoucherPmt."Transaction No." := pTransH."Transaction No.";
                    VoucherPmt."Transact. Line No." := TransPmt."Line No.";
                    VoucherPmt."Receipt No." := pTransH."Receipt No.";
                    VoucherPmt.Amount := -TransPmt.Amount;
                    VoucherPmt.Date := Today;
                    VoucherPmt.Time := Time;
                    VoucherPmt.Insert(true);

                    VoucherEntry.CalcFields("Remaining Amount");
                    if VoucherEntry."Remaining Amount" > 0 then begin
                        NewVoucherCreated := true;
                        // void old voucher:
                        VoucherPmt."Entry No." := 2;
                        VoucherPmt."Entry Type" := VoucherPmt."Entry Type"::Followup;
                        VoucherPmt."Followup Voucher No." := NoSeriesMgt.GetNextNo(VoucherEntry."Voucher No. Series", Today, true);
                        VoucherPmt.Amount := -VoucherEntry."Remaining Amount";
                        VoucherPmt.Insert(true);

                        VoucherEntry.Voided := true;

                        VoucherEntry."Voucher No." := VoucherPmt."Followup Voucher No.";
                        VoucherEntry.Voided := false;
                        VoucherEntry."Store No." := pTransH."Store No.";
                        VoucherEntry."POS Terminal No" := pTransH."POS Terminal No.";
                        VoucherEntry."Transaction No." := pTransH."Transaction No.";
                        VoucherEntry."Transact. Line No." := 0;
                        VoucherEntry."Receipt No." := pTransH."Receipt No.";
                        VoucherEntry.Amount := -VoucherPmt.Amount;
                        VoucherEntry.Date := Today;
                        VoucherEntry.Time := Time;
                        VoucherEntry."Followup Voucher No." := VoucherPmt."Voucher No.";
                        VoucherEntry.Insert(true);
                    end;
                end;
            until TransPmt.Next() = 0;
    end;

    local procedure DoPostCustPayment(var pTransH: Record "CCS CASH POS Transaction Hdr.")
    var
        dummySalesHeader: Record "Sales Header";
        HasVoucher: Boolean;
        TransPaymentEntry: Record "CCS CASH Trans. Payment Entry";
        CashPaymentAmt: Decimal;
    begin
        // ++ EFSTA2.01
        if IsSignatureServiceDown(pTransH."Store No.", pTransH."POS Terminal No.", '') then
            exit;
        // -- EFSTA2.01

        GetPOSTerm(pTransH."Store No.", pTransH."POS Terminal No.");

        // if negative payments are made out of cash register, check if negative payment exceed cash register balance
        TransPaymentEntry.SetRange("Store No.", pTransH."Store No.");
        TransPaymentEntry.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
        TransPaymentEntry.SetRange("Transaction No.", pTransH."Transaction No.");
        TransPaymentEntry.SetRange("Cash entry", true);
        TransPaymentEntry.CalcSums(Amount);
        CashPaymentAmt := TransPaymentEntry.Amount;

        if CashPaymentAmt < 0 then begin
            POSTerm.CalcFields("Balance");
            if (abs(CashPaymentAmt) > POSTerm.Balance) or (POSTerm.Balance < 0) then
                Error(RefundError, FormatDec(abs(CashPaymentAmt), 2, false), FormatDec(abs(POSTerm.Balance), 2, false));
        end;

        pTransH.TestField("Transaction Type", pTransH."Transaction Type"::Payment);
        if pTransH."Receipt No." = '' then
            pTransH."Receipt No." := NoSeriesMgt.GetNextNo(POSTerm."Posted Receipt Nos.", WorkDate(), true);
        pTransH.Reasoncode := ReasonCode;
        pTransH.Status := pTransH.Status::Normal;
        PostPayment(pTransH, dummySalesHeader, false);
        pTransH.Modify(true);

        // + POS0007
        HasVoucher := CreateFollowupVoucher(pTransH);
        // - POS0007

        // ++ EFSTA2.00
        // Insert EFR Functions here
        CallSignatureService(pTransH);
        // -- EFSTA2.00

        Commit();
        PrintReport(Print_OP::CustPayment, pTransH, true);
        // + POS0007
        if HasVoucher then begin
            CSLSetup.Get();
            PrintReport(Print_OP::Voucher, pTransH, not CSLSetup."No Dialog on Receipt Print");
        end;
        // - POS0007
    end;

    local procedure DoPostDeposit(var pTransH: Record "CCS CASH POS Transaction Hdr.")
    var
        TransDeposit: Record "CCS CASH Trans. Deposit Entry";
        Tendertype: Record "CCS CASH Store Tender Type";
        TransPmt: Record "CCS CASH Trans. Payment Entry";
        Posted: Boolean;
    begin
        if IsSignatureServiceDown(pTransH."Store No.", pTransH."POS Terminal No.", '') then
            exit;

        GetPOSTerm(pTransH."Store No.", pTransH."POS Terminal No.");

        if pTransH."Receipt No." = '' then
            pTransH."Receipt No." := NoSeriesMgt.GetNextNo(POSTerm."Posted Receipt Nos.", WorkDate(), true);
        //--POS0022
        pTransH.Status := pTransH.Status::Normal;
        //++POS0022
        pTransH.Modify();
        TransDeposit.SetRange("Store No.", pTransH."Store No.");
        TransDeposit.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
        TransDeposit.SetRange("Transaction No.", pTransH."Transaction No.");
        TransDeposit.SetFilter(Amount, '<>0');
        Tendertype.SetRange(Cash, true);
        Tendertype.SetRange("Store No", pTransH."Store No.");
        Tendertype.FindFirst();
        // Test empty
        TransDeposit.SetFilter(Amount, '<>0');
        if TransDeposit.IsEmpty then
            Error(Error009);

        if TransDeposit.FindSet() then
            repeat
                TransPmt.Init();
                TransPmt."Store No." := pTransH."Store No.";
                TransPmt."POS Terminal No." := pTransH."POS Terminal No.";
                TransPmt."Transaction No." := pTransH."Transaction No.";
                TransPmt."Line No." := TransDeposit."Line No.";
                TransPmt."Safe Type" := TransPmt."Safe Type"::"Normal";
                TransPmt.Validate("Tender Type", Tendertype.Code);
                TransPmt."Tender Description" := TransDeposit.Description;
                TransPmt."Account Type" := GetAccountType_Payment(Tendertype."Account Type");
                TransPmt."Account No." := Tendertype."Account No.";
                TransPmt."Creation Date" := WorkDate();
                TransPmt."Creation Time" := Time;
                TransPmt."Staff ID" := pTransH."Staff ID";
                TransPmt.Amount := TransDeposit.Amount;
                TransPmt."VAT Bus. Posting Group" := TransDeposit."VAT Bus. Posting Group";
                TransPmt."VAT Prod. Posting Group" := TransDeposit."VAT Prod. Posting Group";
                TransPmt."Receipt No." := pTransH."Receipt No.";
                TransPmt.Insert(true);
                PostGenJnl(pTransH, TransPmt, TransDeposit."Account Type", TransDeposit."Account No.", TransDeposit."Dimension Set ID");
                Posted := true;
            until TransDeposit.Next() = 0;
        if Posted then begin
            // ++ EFSTA2.00
            // Insert EFR Functions here
            CallSignatureService(pTransH);
            // -- EFSTA2.00
            Commit();
            PrintReport(Print_OP::CashReceipt, pTransH, true);
        end;
    end;

    local procedure DoPostExpense(var pTransH: Record "CCS CASH POS Transaction Hdr.")
    var
        TransExpense: Record "CCS CASH Trans. Expense Entry";
        Tendertype: Record "CCS CASH Store Tender Type";
        TransPmt: Record "CCS CASH Trans. Payment Entry";
        Posted: Boolean;
        TotalExpense: Decimal;
    begin
        // ++ EFSTA2.01
        if IsSignatureServiceDown(pTransH."Store No.", pTransH."POS Terminal No.", '') then
            exit;
        // -- EFSTA2.01

        GetPOSTerm(pTransH."Store No.", pTransH."POS Terminal No.");

        //--POS0006

        // check if recorded expenses exceed cash register balance

        POSTerm.CalcFields(Balance);

        TransExpense.SetRange("Store No.", pTransH."Store No.");
        TransExpense.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
        TransExpense.SetRange("Transaction No.", pTransH."Transaction No.");

        if TransExpense.FindSet() then
            repeat
                TotalExpense += TransExpense.Amount;
            until TransExpense.Next() = 0;

        if TotalExpense > POSTerm.Balance then
            Error(Error011, FormatDec(TotalExpense, 2, false), FormatDec(POSTerm.Balance, 2, false));

        //++POS0006
        if pTransH."Receipt No." = '' then
            pTransH."Receipt No." := NoSeriesMgt.GetNextNo(POSTerm."Posted Receipt Nos.", WorkDate(), true);
        //--POS0022
        pTransH.Status := pTransH.Status::Normal;
        //++POS0022
        pTransH.Modify();
        TransExpense.SetRange("Store No.", pTransH."Store No.");
        TransExpense.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
        TransExpense.SetRange("Transaction No.", pTransH."Transaction No.");
        TransExpense.SetFilter(Amount, '<>0');
        Tendertype.SetRange(Cash, true);
        Tendertype.SetRange("Store No", pTransH."Store No.");
        Tendertype.FindFirst();
        // Test empty
        TransExpense.SetFilter(Amount, '<>0');
        if TransExpense.IsEmpty then
            Error(Error009);

        if TransExpense.FindSet() then
            repeat
                TransPmt.Init();
                TransPmt."Store No." := pTransH."Store No.";
                TransPmt."POS Terminal No." := pTransH."POS Terminal No.";
                TransPmt."Transaction No." := pTransH."Transaction No.";
                TransPmt."Line No." := TransExpense."Line No.";
                TransPmt."Safe Type" := TransPmt."Safe Type"::"Normal";
                TransPmt.Validate("Tender Type", Tendertype.Code);
                TransPmt."Tender Description" := TransExpense.Description;
                TransPmt."Account Type" := GetAccountType_Payment(Tendertype."Account Type");
                TransPmt."Account No." := Tendertype."Account No.";
                TransPmt."Creation Date" := WorkDate();
                TransPmt."Creation Time" := Time;
                TransPmt."Staff ID" := pTransH."Staff ID";
                TransPmt.Amount := -TransExpense.Amount;
                TransPmt."VAT Bus. Posting Group" := TransExpense."VAT Bus. Posting Group";
                TransPmt."VAT Prod. Posting Group" := TransExpense."VAT Prod. Posting Group";
                TransPmt."Receipt No." := pTransH."Receipt No.";
                TransPmt.Insert(true);
                //++POS0033
                //PostGenJnl(pTransH,TransPmt,TransExpense."Account Type",TransExpense."Account No.");
                PostGenJnl(pTransH, TransPmt, TransExpense."Account Type", TransExpense."Account No.", TransExpense."Dimension Set ID");
                //--POS0033
                Posted := true;
            until TransExpense.Next() = 0;
        if Posted then begin
            // ++ EFSTA2.00
            // Insert EFR Functions here
            CallSignatureService(pTransH);
            // -- EFSTA2.00
            Commit();
            PrintReport(Print_OP::CashReceipt, pTransH, true);
        end;
    end;

    local procedure TenderOperation(var pRetailUser: Record "CCS CASH Retail User"; HdrText: Text; pTender_OP: Option Remove,Float,TermStart,TermEnd): Boolean
    var
        TenderOpPage: Page "CCS CASH Tender Operation";
    begin
        Clear(TenderOpPage);
        TenderOpPage.SetTerminalOption(pRetailUser, TransHead, pTender_OP, HdrText);
        Commit();
        TenderOpPage.RunModal();
        exit(TenderOpPage.TenderOpStatus());
    end;

    local procedure PostPayment(var pTransH: Record "CCS CASH POS Transaction Hdr."; var pSalesHeader: Record "Sales Header"; IsSalesPosting: Boolean)
    var
        POSSetup: Record "CCS CASH Cash Sales Setup";
        TransPmt: Record "CCS CASH Trans. Payment Entry";
        Tendertype: Record "CCS CASH Store Tender Type";
        TTCard: Record "CCS CASH Tender Type C. Setup";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlLineAccount: Record "Gen. Journal Line";
        TransSalesEntry: Record "CCS CASH Trans. Sales Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        POSRegCustomerLib: Codeunit "CCS CASH POS Reg. Customer Lib";
        TotalAmt: Decimal;
        DocNo: Code[20];
        IsRefund: Boolean;
        RecRef, RecRef2, RecRef3 : RecordRef;
        FRef, FRef2, FRef3 : FieldRef;
        MoreGenJnlLinesError: Label 'There are lines in %1 %2 and %3 %4.', Comment = '%1=Template Name,%2=Template Value,%3=Batch Name,%4=Batch Value';
    begin
        POSSetup.Get();
        CSLSetup.Get();
        if not(pTransH."Transaction Type" in [pTransH."Transaction Type"::Sales, pTransH."Transaction Type"::Return, pTransH."Transaction Type"::Payment]) then
            Error(Error005, Format(pTransH."Transaction Type"));

        if not IsSalesPosting then begin
            IF pTransH."Receipt No." = '' THEN BEGIN
                IF POSTerm.GET(pTransH."Store No.", pTransH."POS Terminal No.") THEN BEGIN
                    pTransH."Receipt No." := NoSeriesMgt.GetNextNo(POSTerm."Posted Receipt Nos.", WorkDate(), TRUE);
                END;
            END;
        end;

        pTransH.TestField("Customer No.");
        if IsSalesPosting then
            DocNo := CreateDocumentNo(pTransH)
        else begin
            pTransH.TestField("Receipt No.");
            DocNo := pTransH."Receipt No.";
        end;

        pTransH.CalcFields("Payment Amount", "Amount incl. VAT");
        if pTransH."Payment Discount %" <> 0 then
            pTransH."Payment Discount Amount" := Round(pTransH."Amount incl. VAT" * pTransH."Payment Discount %" / 100, 0.01);

        if Abs(pTransH."Amount incl. VAT") <> Abs(pTransH."Payment Amount") + Abs(pTransH."Payment Discount Amount") then
            case pTransH."Transaction Type" of
                pTransH."Transaction Type"::Sales:
                    Error(Error006,
                       Text016, FormatDec(Abs(pTransH."Amount incl. VAT"), 2, false),
                       Text018, FormatDec(Abs(pTransH."Payment Amount") + Abs(pTransH."Payment Discount Amount"), 2, false));
                pTransH."Transaction Type"::Return:
                    Error(Error006,
                       Text017, FormatDec(Abs(pTransH."Amount incl. VAT"), 2, false),
                       Text019, FormatDec(Abs(pTransH."Payment Amount") + Abs(pTransH."Payment Discount Amount"), 2, false));
            end;

        //--POS0029
        IsRefund := (pTransH."Transaction Type" = pTransH."Transaction Type"::Return) or
                    ((pTransH."Transaction Type" = pTransH."Transaction Type"::Payment) and (pTransH."Amount incl. VAT" > 0));
        //++POS0029

        // prepare payment (combine tendertype, and test Account)
        TempPmtBuffer.DeleteAll();
        TransPmt.SetRange("Store No.", pTransH."Store No.");
        TransPmt.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
        TransPmt.SetRange("Transaction No.", pTransH."Transaction No.");

        if TransPmt.FindSet() then
            repeat
                Tendertype.Get(pTransH."Store No.", TransPmt."Tender Type");
                if (Tendertype.TenderFunction <> Tendertype.TenderFunction::Voucher) and (TransPmt."Card No." <> '') then begin
                    TTCard.Get(pTransH."Store No.", TransPmt."Tender Type", TransPmt."Card No.");
                    Tendertype."Account Type" := TTCard."Account Type";
                    Tendertype."Account No." := TTCard."Account No.";
                end;
                Tendertype.TestField("Account No.");
                TransPmt."Account Type" := GetAccountType_Payment(Tendertype."Account Type");
                TransPmt."Account No." := Tendertype."Account No.";
                TransPmt."Tender Description" := CopyStr(
#pragma warning disable AA0217
                      StrSubstNo(Text020, CreateDocumentNo(pTransH)) + StrSubstNo(' (%1 %2)', Tendertype.Code, Tendertype.Description), 1, 50);
#pragma warning restore AA0217
                UpdatePaymentBuffer(TransPmt, DocNo, pTransH."Creation Date", pTransH."Customer No.");
                TotalAmt += TransPmt.Amount;
            until TransPmt.Next() = 0;

        // Update Customer Posting Buffer
        TempPmtBuffer.Get('', '', 0, 1);

        // Test Amount
        if (TempPmtBuffer.Amount <> -TotalAmt) or
           (Abs(pTransH."Payment Amount") <> Abs(TotalAmt))
        then
            Error(Error007, FormatDec(Abs(TotalAmt), 2, false), FormatDec(Abs(pTransH."Payment Amount"), 2, false));

        if TotalAmt = 0 then
            Error(Error010, Text024);

        //--POS0029
        //IF pTransH."Transaction Type" = pTransH."Transaction Type"::Return THEN BEGIN
        if IsRefund then begin
            //++POS0029
            if TotalAmt > 0 then
                Error(Error010, Text022);
        end else
            if TotalAmt < 0 then
                Error(Error010, Text023);

        // Post / Test G/L Postings:
        TempPmtBuffer.Reset();
        if TempPmtBuffer.Find('-') then
            repeat
                GenJnlLine.Init();
                //--POS0002
                if pTransH."Is Advance Payment" then begin
                    GenJnlLine."Journal Template Name" := CSLSetup."Journale Template Name";
                    GenJnlLine."Journal Batch Name" := CSLSetup."Journal Batch Name";
                    GenJnlLine."Line No." := GenJnlLine.GetNewLineNo(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
                end;
                //++POS0002
                GenJnlLine."Posting Date" := TempPmtBuffer."Creation Date";
                GenJnlLine."Document Date" := TempPmtBuffer."Creation Date";

                //--POS0029
                //IF pTransH."Transaction Type" = pTransH."Transaction Type"::Return THEN
                if IsRefund then
                    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Refund)
                else
                    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Payment);
                GenJnlLine."Document No." := DocNo;
                if TempPmtBuffer."Line No." = 1 then begin
                    GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::Customer);
                    GenJnlLine.Validate("Account No.", pTransH."Customer No.");
                    if (pTransH."Receipt No." <> '') and (pTransH."Transaction Type" <> pTransH."Transaction Type"::Payment) then begin
                        if GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment then
                            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice
                        else
                            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";
                        if pSalesHeader."CCS CASH CSL Do Cash Posting" and (pSalesHeader."Last Posting No." <> '') then
                            GenJnlLine.Validate("Applies-to Doc. No.", pSalesHeader."Last Posting No.")
                        else
                            GenJnlLine.Validate("Applies-to Doc. No.", pTransH."Receipt No.");
                    end;

                    if POSSetup."Use Posting Descr. on Pmt" then begin
                        TransSalesEntry.SetRange("Store No.", pTransH."Store No.");
                        TransSalesEntry.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
                        TransSalesEntry.SetRange("Transaction No.", pTransH."Transaction No.");
                        TransSalesEntry.SetRange(Type, TransSalesEntry.Type::"CCS CASH Payment");
                        if TransSalesEntry.FindFirst() then
                            GenJnlLine.Description := TransSalesEntry.Description
                        else
                            if (POSRegCustomerLib.GetDefaultReasonforPayment() <> pTransH."Posting Description") then
                                GenJnlLine.Description := pTransH."Posting Description"
                            else
                                GenJnlLine.Description := CopyStr(GetDefaultPostingDescription(pTransH), 1, MaxStrLen(GenJnlLine.Description));
                    end else
                        GenJnlLine.Description := CopyStr(GetDefaultPostingDescription(pTransH), 1, MaxStrLen(GenJnlLine.Description));
                end else begin
                    if TempPmtBuffer."Account Type" = TempPmtBuffer."Account Type"::"Bank Account" then
                        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"Bank Account")
                    else
                        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                    GenJnlLine.Validate("Account No.", TempPmtBuffer."Account No.");
                    GenJnlLine.Description := TempPmtBuffer."Tender Description";
                end;
                GenJnlLine."Reason Code" := pTransH.Reasoncode;

                if GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account" then begin
                    GenJnlLine."Gen. Bus. Posting Group" := '';
                    GenJnlLine."Gen. Posting Type" := Enum::"General Posting Type"::" ";
                    GenJnlLine."Gen. Prod. Posting Group" := '';
                    GenJnlLine."VAT %" := 0;
                    GenJnlLine."VAT Bus. Posting Group" := '';
                    GenJnlLine."VAT Prod. Posting Group" := '';
                end;

                GenJnlLine."Currency Code" := '';
                //--POS0005
                // correction to avoid commit: GenJnlLine.VALIDATE(Amount,TempPmtBuffer.Amount);
                GenJnlLine.Amount := TempPmtBuffer.Amount;
                //++POS0005
                GenJnlLine."Source Currency Code" := '';
                GenJnlLine."Amount (LCY)" := GenJnlLine.Amount;
                GenJnlLine."Currency Factor" := 1;
                GenJnlLine."Allow Application" := true;
                GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
                GenJnlLine."Source No." := pTransH."Customer No.";
                GenJnlLine."Allow Zero-Amount Posting" := true;
                OnPostPayment_BeforeCheckLines(pTransH, GenJnlLine, IsSalesPosting);
                if IsSalesPosting then
                    GenJnlCheckLine.Run(GenJnlLine)
                else begin
                    if pTransH."Is Advance Payment" then
                        GenJnlLine.insert(true)
                    else
                        GenJnlPostLine.RunWithCheck(GenJnlLine);
                end;
            until TempPmtBuffer.Next() = 0;
        if pTransH."Is Advance Payment" then begin
            GenJnlLine.SetRange("Journal Template Name", CSLSetup."Journale Template Name");
            GenJnlLine.SetRange("Journal Batch Name", CSLSetup."Journal Batch Name");
            GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::"Customer");
            GenJnlLine.SetRange("Document No.", DocNo);
            if GenJnlLine.FindFirst() then begin
                TransSalesEntry.SetRange("Store No.", pTransH."Store No.");
                TransSalesEntry.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
                TransSalesEntry.SetRange("Transaction No.", pTransH."Transaction No.");
                TransSalesEntry.SetRange("Type", TransSalesEntry.Type::"CCS CASH Customer Ledger Entry");
                if TransSalesEntry.FindFirst() then begin
                    if CustLedgerEntry.Get(TransSalesEntry."Entry No.") then begin
                        GenJnlLine.Validate("Applies-to Doc. Type", CustLedgerEntry."Document Type");
                        GenJnlLine.Validate("Applies-to Doc. No.", CustLedgerEntry."Document No.");
                        RecRef.GetTable(CustLedgerEntry);
                        RecRef2.GetTable(GenJnlLine);
                        if RecRef.FieldExist(5013500) then begin // "CCS APT Advance Payment No."
                            RecRef3.Open(5013508); // "CCS APT Adv. Pmt. Entry Sale"
                            FRef3 := RecRef3.Field(2); // "Entry Type"
                            FRef3.SetRange(0); //Invoice
                            FRef := RecRef.Field(5013500); // "CCS APT Advance Payment No."
                            FRef3 := RecRef3.Field(3); // "CCS APT Advance Payment No."
                            FRef3.SetRange(FRef.Value);
                            FRef3 := RecRef3.Field(4); // "CCS APT Apply Adv. Pmt. Inv."
                            FRef3.SetRange(CustLedgerEntry."Document No.");
                            if not RecRef3.IsEmpty then begin
                                FRef := RecRef.Field(5013500); // "CCS APT Advance Payment No."
                                FRef2 := RecRef2.Field(5013500); // "CCS APT Advance Payment No."
                                FRef2.Value := FRef.Value;
                                FRef2 := RecRef2.Field(5013501); // "CCS APT Apply Adv. Pmt. Inv."
                                FRef2.Value := CustLedgerEntry."Document No.";
                            end;
                        end;
                        RecRef2.SetTable(GenJnlLine);
                    end;
                end;
                GenJnlLine.Modify(true);

                GenJnlLineAccount.SetRange("Journal Template Name", CSLSetup."Journale Template Name");
                GenJnlLineAccount.SetRange("Journal Batch Name", CSLSetup."Journal Batch Name");
                GenJnlLineAccount.SetRange("Account Type", GenJnlLine."Account Type"::"G/L Account");
                if GenJnlLineAccount.Count() > 1 then
                    Error(MoreGenJnlLinesError, CSLSetup.FieldCaption("Journale Template Name"), CSLSetup."Journale Template Name", CSLSetup.FieldCaption("Journal Batch Name"), CSLSetup."Journal Batch Name");


                if GenJnlLineAccount.FindFirst() then begin
                    GenJnlLine."Bal. Account No." := GenJnlLineAccount."Account No.";
                    GenJnlLine.Modify();
                    GenJnlLineAccount.Delete();
                end;
            end;

            GenJnlPostBatch.Run(GenJnlLine);
        end else
            if pTransH."Transaction Type" = pTransH."Transaction Type"::Payment then
                ApplyCustEntries(pTransH);
    end;

    local procedure PostGenJnl(var pTransH: Record "CCS CASH POS Transaction Hdr."; var pTransPmt: Record "CCS CASH Trans. Payment Entry"; pBalAccType: enum "CCS CASH Account Type"; pBalAccNo: Code[20]; pDimSetID: Integer)
    var
        GenJnlLine: Record "Gen. Journal Line";
        POSSetup: Record "CCS CASH Cash Sales Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DimMgt: Codeunit DimensionManagement;
        Txt: Text;
    begin
        //++POS0033 new Parameter pDimSetID
        if pTransPmt."Account No." = '' then
            exit;
        POSSetup.Get();
        GenJnlLine.Init();
        GenJnlLine.Validate("Posting Date", pTransPmt."Creation Date");
        GenJnlLine."Document No." := CreateDocumentNo(pTransH);
        GenJnlLine."CCS CASH CSL Staff ID" := pTransPmt."Staff ID";
        GenJnlLine."CCS CASH CSL Store No." := pTransPmt."Store No.";
        GenJnlLine."CCS CASH CSL POS Terminal No." := pTransPmt."POS Terminal No.";
        GenJnlLine."CCS CASH CSL Transaction No." := pTransPmt."Transaction No.";

        case pTransPmt."Account Type" of
            pTransPmt."Account Type"::"G/L Account":
                GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
            pTransPmt."Account Type"::"Bank Account":
                GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"Bank Account")
        end;
        GenJnlLine.Validate("Account No.", pTransPmt."Account No.");

        case pBalAccType of
            pBalAccType::"G/L Account":
                GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
            pBalAccType::"Bank Account":
                GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"Bank Account");
        end;
        GenJnlLine.Validate("Bal. Account No.", pBalAccNo);

        //--POS0030
        if (pTransH."Transaction Type" = pTransH."Transaction Type"::Expense) and (pBalAccType = pBalAccType::"G/L Account") then begin
            GenJnlLine.Validate("Bal. Gen. Posting Type", GenJnlLine."Gen. Posting Type"::Purchase);
            if (pTransPmt."VAT Bus. Posting Group" <> '') and (pTransPmt."VAT Bus. Posting Group" <> GenJnlLine."Bal. VAT Bus. Posting Group") then
                GenJnlLine."Bal. VAT Bus. Posting Group" := pTransPmt."VAT Bus. Posting Group";
            if (pTransPmt."VAT Prod. Posting Group" <> '') and (pTransPmt."VAT Prod. Posting Group" <> GenJnlLine."Bal. VAT Prod. Posting Group") then
                GenJnlLine."Bal. VAT Prod. Posting Group" := pTransPmt."VAT Prod. Posting Group";
            GenJnlLine.Validate("Bal. VAT Prod. Posting Group");
        end;

        if (pTransH."Transaction Type" = pTransH."Transaction Type"::Deposit) and (pBalAccType = pBalAccType::"G/L Account") then begin
            GenJnlLine.Validate("Gen. Posting Type", GenJnlLine."Gen. Posting Type"::Sale);
            GenJnlLine.Validate("Bal. Gen. Posting Type", GenJnlLine."Gen. Posting Type"::Sale);
            if (pTransPmt."VAT Bus. Posting Group" <> '') and (pTransPmt."VAT Bus. Posting Group" <> GenJnlLine."Bal. VAT Bus. Posting Group") then
                GenJnlLine."Bal. VAT Bus. Posting Group" := pTransPmt."VAT Bus. Posting Group";
            if (pTransPmt."VAT Prod. Posting Group" <> '') and (pTransPmt."VAT Prod. Posting Group" <> GenJnlLine."Bal. VAT Prod. Posting Group") then
                GenJnlLine."Bal. VAT Prod. Posting Group" := pTransPmt."VAT Prod. Posting Group";
            GenJnlLine.Validate("Bal. VAT Prod. Posting Group");
        end;
        //++POS0030
#pragma warning disable AA0217
        Txt := StrSubstNo('%1:%2 %3', Format(pTransH."Transaction Type"), pTransPmt."Tender Type", pTransPmt."Tender Description");
#pragma warning restore AA0217
        if pTransH."Transaction Type" = pTransH."Transaction Type"::Expense then
            Txt := pTransPmt."Tender Description";

        //STRSUBSTNO('%1: %2 %3',FORMAT(pTransH."Transaction Type"),pTransH.FIELDCAPTION("Receipt No."),pTransPmt."Tender Description");
        GenJnlLine.Description := CopyStr(Txt, 1, MaxStrLen(GenJnlLine.Description));

        //GenJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
        //GenJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";

        GenJnlLine.Validate(Amount, pTransPmt.Amount);

        GenJnlLine."Currency Factor" := 1;
        GenJnlLine."Allow Zero-Amount Posting" := true;
        //++POS0032,POS0033
        if pDimSetID <> 0 then begin
            GenJnlLine."Dimension Set ID" := pDimSetID;
            DimMgt.UpdateGlobalDimFromDimSetID(pDimSetID, GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code");
        end;
        //--POS0032,POS0033
        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    local procedure MergePmtLines(pTransH: Record "CCS CASH POS Transaction Hdr."; CashRec: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        TPmt: Record "CCS CASH Trans. Payment Entry";
        NextLineNo: Integer;
        Txt: Text[100];
    begin
        SalesLine.SetRange("Document Type", CashRec."Document Type");
        SalesLine.SetRange("Document No.", CashRec."No.");
        SalesLine.SetRange("CCS CASH CSL PaymentText", true);
        if not SalesLine.IsEmpty then
            SalesLine.DeleteAll();
        SalesLine.SetRange("CCS CASH CSL PaymentText");
        if SalesLine.FindLast() then
            NextLineNo := SalesLine."Line No.";

        TPmt.SetRange("Store No.", pTransH."Store No.");
        TPmt.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
        TPmt.SetRange("Transaction No.", pTransH."Transaction No.");
        if TPmt.FindSet() then
            repeat
                NextLineNo += 10000;
                SalesLine.Init();
                SalesLine."Document Type" := CashRec."Document Type";
                SalesLine.Validate("Document No.", CashRec."No.");
                SalesLine."Line No." := NextLineNo;
                SalesLine.Validate(Type, SalesLine.Type::" ");
                if TPmt."Card No." <> '' then
#pragma warning disable AA0217
                    Txt := StrSubstNo('%1(%2): %3', TPmt."Tender Type", TPmt."Card No.", TPmt."Tender Description")
#pragma warning restore AA0217
                else
#pragma warning disable AA0217
                    Txt := StrSubstNo('%1: %2', TPmt."Tender Type", TPmt."Tender Description");
#pragma warning restore AA0217
                SalesLine.Description := CopyStr(Txt, 1, MaxStrLen(SalesLine.Description));
                SalesLine."CCS CASH CSL Payment Amount" := TPmt.Amount;
                SalesLine."CCS CASH CSL PaymentText" := true;
                SalesLine.Insert();
            until TPmt.Next() = 0;
    end;

    internal procedure CreateDocumentNo(var pTransH: Record "CCS CASH POS Transaction Hdr."): Code[20]
    var
        POSSetup: Record "CCS CASH Cash Sales Setup";
    begin
        POSSetup.Get();
        IF (POSSetup."Use Document No. As Pst Desc.") and (pTransH."Receipt No." <> '') then begin
#pragma warning disable AA0217
            EXIT(STRSUBSTNO('%1', pTransH."Receipt No."));
#pragma warning restore AA0217
        end
        else begin
#pragma warning disable AA0217
            exit(CopyStr(StrSubstNo('%1-%2-%3',
            pTransH."Store No.", pTransH."POS Terminal No.", Format(pTransH."Transaction No.")), 1, 20));
#pragma warning restore AA0217
        end;
    end;

    local procedure GetPOSTerm("StoreNo.": Code[20]; "POSNo.": Code[20])
    var
        Store: Record "CCS CASH Store";
    begin
        if (POSTerm."Store No" <> "StoreNo.") or (POSTerm."No." <> "POSNo.") then
            POSTerm.Get("StoreNo.", "POSNo.");
        if POSTerm."Posted Receipt Nos." = '' then begin
            Store.Get("StoreNo.");
            POSTerm."Posted Receipt Nos." := Store."Posted Receipt Nos.";
        end;
        POSTerm.TestField("Posted Receipt Nos.");
    end;

    local procedure ApplyCustEntries(pTransH: Record "CCS CASH POS Transaction Hdr."): Integer
    var
        TSales: Record "CCS CASH Trans. Sales Entry";
        ApplyingCustLedgEntry: Record "Cust. Ledger Entry";
        ApplyCustLedgEntry: Record "Cust. Ledger Entry";
        CustEntryApplID: Code[20];
        CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        CanApply: Boolean;
        CCSCASHCashSalesSetup: Record "CCS CASH Cash Sales Setup";
        Customer: Record Customer;
    begin
        CCSCASHCashSalesSetup.SetLoadFields("Pmt. Disc. Tolerance Date");
        CCSCASHCashSalesSetup.Get();
        pTransH.TestField("Receipt No.");
        pTransH.CalcFields("Payment Amount");
        CustEntryApplID := pTransH."Receipt No.";

        Customer.SetLoadFields("Block Payment Tolerance");
        Customer.Get(pTransH."Customer No.");

        // Test Entries and exit if nothing to apply or error
        TSales.SetRange("Store No.", pTransH."Store No.");
        TSales.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
        TSales.SetRange("Transaction No.", pTransH."Transaction No.");
        TSales.SetRange(Type, TSales.Type::"CCS CASH Customer Ledger Entry");
        if TSales.FindSet() then
            repeat
                if TSales.Type = TSales.Type::"CCS CASH Customer Ledger Entry" then begin
                    TSales.TestField("Source Entry No.");
                    ApplyCustLedgEntry.Get(TSales."Source Entry No.");
                    ApplyCustLedgEntry.TestField("Customer No.", pTransH."Customer No.");
                    SetDiscountPayable(pTransH, ApplyCustLedgEntry, CCSCASHCashSalesSetup, Customer);
                    CanApply := true;
                end;
            until TSales.Next() = 0;
        if not CanApply then
            exit;

        // To Apply, Posting need to be committed
        Commit();

        //Find Customer Payment Entry just posted and set "applying entry"
        // ApplyingCustLedgEntry.SetRange("Customer No.", pTransH."Customer No.");
        // ApplyingCustLedgEntry.SetRange("Document No.", pTransH."Receipt No.");
        ApplyingCustLedgEntry.FindLast();
        ApplyingCustLedgEntry.TestField("Customer No.", pTransH."Customer No.");
        ApplyingCustLedgEntry.TestField("Document No.", pTransH."Receipt No.");
        ApplyingCustLedgEntry.CalcFields("Remaining Amount");
        ApplyingCustLedgEntry."Applying Entry" := true;
        ApplyingCustLedgEntry."Applies-to ID" := CustEntryApplID;
        ApplyingCustLedgEntry."Amount to Apply" := ApplyingCustLedgEntry."Remaining Amount";
        CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", ApplyingCustLedgEntry);
        Commit();



        if TSales.FindSet() then
            repeat
                if TSales.Type = TSales.Type::"CCS CASH Customer Ledger Entry" then begin
                    ApplyCustLedgEntry.Get(TSales."Source Entry No.");
                    ApplyCustLedgEntry.Mark(true);
                end;
            until TSales.Next() = 0;

        ApplyCustLedgEntry.MarkedOnly(true);
        CustEntrySetApplID.SetApplId(ApplyCustLedgEntry, ApplyingCustLedgEntry, CustEntryApplID);
        Commit();

        if not CustEntryApplyPostedEntries.Run(ApplyingCustLedgEntry) then
            Message(Text021, GetLastErrorText, pTransH."Receipt No.");
    end;

    local procedure UpdatePaymentBuffer(var TPmt: Record "CCS CASH Trans. Payment Entry"; DocumentNo: Code[20]; TransDate: Date; CustomerNo: Code[20])
    begin
        if TransDate = 0D then
            TransDate := Today;

        TempPmtBuffer.Reset();
        TempPmtBuffer.SetRange("Tender Type", TPmt."Tender Type");
        TempPmtBuffer.SetRange("Card No.", TPmt."Card No.");
        if not TempPmtBuffer.Find('-') then begin
            TempPmtBuffer.Reset();
            TempPmtBuffer.Init();
            TempPmtBuffer."Receipt No." := DocumentNo;
            TempPmtBuffer."Creation Date" := TransDate;
            TempPmtBuffer."Tender Type" := TPmt."Tender Type";
            TempPmtBuffer."Card No." := TPmt."Card No.";
            TempPmtBuffer."Line No." := TPmt."Line No.";
            TempPmtBuffer."Account Type" := TPmt."Account Type";
            TempPmtBuffer."Account No." := TPmt."Account No.";
            TempPmtBuffer."Tender Description" := TPmt."Tender Description";
            TempPmtBuffer.Insert();
        end;
        TempPmtBuffer.Amount += TPmt.Amount;
        TempPmtBuffer.Modify();

        TempPmtBuffer.Reset();

        // Fill/Update Customer Posting Buffer
        if not TempPmtBuffer.Get('', '', 0, 1) then begin
            TempPmtBuffer.Init();
            TempPmtBuffer."Receipt No." := DocumentNo;
            TempPmtBuffer."Line No." := 1;
            TempPmtBuffer."Creation Date" := TransDate;
            TempPmtBuffer."Account Type" := TempPmtBuffer."Account Type"::Customer;
            TempPmtBuffer."Account No." := CustomerNo;
            TempPmtBuffer.Insert();
        end;
        TempPmtBuffer.Amount += -TPmt.Amount;
        TempPmtBuffer.Modify();
    end;

    internal procedure CSLPayMethodPayment(var pSalesHeader: Record "Sales Header"; var pSalesInv: Record "Sales Invoice Header")
    var
        PayMethod: Record "Payment Method";
        UserSetup: Record "User Setup";
        RetailUser: Record "CCS CASH Retail User";
        CustLedgEntry: Record "Cust. Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        TransPmt: Record "CCS CASH Trans. Payment Entry";
        TenderType: Record "CCS CASH Store Tender Type";
        PaymentAmt: Decimal;
        TransSalesEntry: Record "CCS CASH Trans. Sales Entry";
        RetailSetup: Record "CCS CASH Cash Sales Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        if pSalesInv."No." = '' then
            exit;
        //+POS0034
        RetailSetup.Get();

        //+POS0036
        if RetailSetup.CSLDialogPosting then
            exit;
        //-POS0036

        if not (pSalesHeader."Document Type" in [pSalesHeader."Document Type"::Invoice, pSalesHeader."Document Type"::Order, pSalesHeader."Document Type"::"Return Order"]) or
               (pSalesHeader."Payment Method Code" = '') or
               (pSalesHeader."CCS CASH CSL Document") then
            exit;
        //IF (pSalesHeader."Payment Method Code" = '') OR (pSalesHeader."CSL Document") THEN
        //  EXIT;


        //IF (pSalesHeader."Document Type" = pSalesHeader."Document Type"::Order) THEN EXIT;
        //IF ((pSalesHeader."Document Type" <> pSalesHeader."Document Type"::Invoice) AND NOT pSalesHeader.Invoice) OR
        //   (pSalesHeader."Payment Method Code" = '') OR (pSalesHeader."CSL Document") THEN
        //  EXIT;

        if not PayMethod.Get(pSalesHeader."Payment Method Code") then
            PayMethod.Init();
        if PayMethod."CCS CASH CSL Tender Type" = '' then
            exit;

        if pSalesHeader."Document Type" in [pSalesHeader."Document Type"::"Return Order", pSalesHeader."Document Type"::"Credit Memo"] then
            Error(Text027);

        UserSetup.Get(UserId);
        UserSetup.TestField("CCS CASH POS No.");
        UserSetup.TestField("CCS CASH Staff ID");
        UserSetup.TestField("CCS CASH Store No.");
        //++POS0035
        //if UserSetup."CCS CASH Op. Pmt. aft. Post" then
        //    exit;
        //--POS0035
        POSTerm.Get(UserSetup."CCS CASH Store No.", UserSetup."CCS CASH POS No.");
        if POSTerm.Status() = 0 then
            Error(Error004, POSTerm."No.");

        TenderType.Get(UserSetup."CCS CASH Store No.", PayMethod."CCS CASH CSL Tender Type", '');
        TenderType.TestField("Account No.");

        RetailUser.Get(UserSetup."CCS CASH Staff ID", UserSetup."CCS CASH Store No.", UserSetup."CCS CASH POS No.");

        if IsSignatureServiceDown(UserSetup."CCS CASH Store No.", UserSetup."CCS CASH POS No.", '') then
            exit;

        CustLedgEntry.FindLast();
        if (CustLedgEntry."Customer No." <> pSalesHeader."Bill-to Customer No.") or
           ((CustLedgEntry."Document Type" <> CustLedgEntry."Document Type"::Invoice) and (CustLedgEntry."Document No." <> pSalesInv."No."))
          then
            Error(Text028, pSalesInv."No.");

        //CustLedgEntry.CALCFIELDS("Amount (LCY)","Remaining Pmt. Disc. Possible");
        CustLedgEntry.CalcFields("Amount (LCY)");
        //pSalesHeader."CSL Transaction No." :=
        CreateTransLog(RetailUser, TransHead."Transaction Type"::Payment);
        if TransHead."Receipt No." = '' then
            TransHead."Receipt No." := NoSeriesMgt.GetNextNo(POSTerm."Posted Receipt Nos.", WorkDate(), true);

        // create Trans Sales Entry
        TransSalesEntry.Init();
        TransSalesEntry."Store No." := UserSetup."CCS CASH Store No.";
        TransSalesEntry."POS Terminal No." := UserSetup."CCS CASH POS No.";
        TransSalesEntry."Transaction No." := TransHead."Transaction No.";
        TransSalesEntry."Entry No." := CustLedgEntry."Entry No.";
        TransSalesEntry."Receipt No." := TransHead."Receipt No.";
        TransSalesEntry.Type := TransSalesEntry.Type::"CCS CASH Customer Ledger Entry";
        TransSalesEntry."No." := CustLedgEntry."Document No.";
        TransSalesEntry.Description := CustLedgEntry.Description;
        TransSalesEntry.Amount := -CustLedgEntry."Amount (LCY)";
        TransSalesEntry."Amount incl. VAT" := -CustLedgEntry."Amount (LCY)";
        TransSalesEntry.Quantity := 1;
        TransSalesEntry."Source Entry No." := CustLedgEntry."Entry No.";
        if CustLedgEntry."Pmt. Discount Date" >= WorkDate() then begin
            TransSalesEntry."Pmt. Discount Date" := CustLedgEntry."Pmt. Discount Date";
            TransSalesEntry."Remaining Pmt. Disc. Possible" := -CustLedgEntry."Remaining Pmt. Disc. Possible";
            TransHead."Payment Discount Amount" := -CustLedgEntry."Remaining Pmt. Disc. Possible";
        end;
        TransSalesEntry.Insert();

        TransHead."Customer No." := CustLedgEntry."Customer No.";
        TransHead.Status := TransHead.Status::Normal;
        TransHead.Reasoncode := ReasonCode;
        TransHead.Modify();

        PaymentAmt := CustLedgEntry."Amount (LCY)" - CustLedgEntry."Remaining Pmt. Disc. Possible";

        //Create Trans Payment
        TransPmt.Init();
        TransPmt."Store No." := UserSetup."CCS CASH Store No.";
        TransPmt."POS Terminal No." := UserSetup."CCS CASH POS No.";
        TransPmt."Transaction No." := TransHead."Transaction No.";
        TransPmt."Line No." := 10000;
        TransPmt."Receipt No." := TransHead."Receipt No.";
        TransPmt.Validate("Tender Type", TenderType.Code);
        TransPmt."CardNo. Select" := false;
        TransPmt.Validate(Amount, PaymentAmt);
        //TransPmt.VALIDATE(Amount,CustLedgEntry."Amount (LCY)");
        TransPmt.Validate("Account Type", GetAccountType_Payment(TenderType."Account Type"));
        TransPmt.Validate("Account No.", TenderType."Account No.");
        TransPmt."Transaction Type" := TransHead."Transaction Type";
        TransPmt."Tender Description" := CopyStr(
#pragma warning disable AA0217
          StrSubstNo(Text020, CreateDocumentNo(TransHead)) + StrSubstNo(' (%1 %2)', TenderType.Code, TenderType.Description), 1, 50);
#pragma warning restore AA0217
        TransPmt.Insert(true);
        UpdatePaymentBuffer(TransPmt, CustLedgEntry."Document No.", TransHead."Creation Date", CustLedgEntry."Customer No.");

        TempPmtBuffer.Find('-');
        repeat
            GenJnlLine.Init();

            GenJnlLine."Journal Template Name" := RetailSetup."Journale Template Name";

            GenJnlLine."Posting Date" := TempPmtBuffer."Creation Date";
            GenJnlLine."Document Date" := TempPmtBuffer."Creation Date";

            GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Payment);
            GenJnlLine."Document No." := TransHead."Receipt No.";

            if TempPmtBuffer."Line No." = 1 then begin
                GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::Customer);
                GenJnlLine.Validate("Account No.", TransHead."Customer No.");
                GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;
                //GenJnlLine.VALIDATE("Applies-to Doc. No.",TransHead."Receipt No.");
                GenJnlLine.Validate("Applies-to Doc. No.", pSalesInv."No.");
                if RetailSetup."Use Posting Descr. on Pmt" then
                    GenJnlLine.Description := pSalesHeader."Posting Description"
                else
                    GenJnlLine.Description := CopyStr(GetDefaultPostingDescription(TransHead), 1, MaxStrLen(GenJnlLine.Description));

            end else begin
                if TempPmtBuffer."Account Type" = TempPmtBuffer."Account Type"::"Bank Account" then
                    GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"Bank Account")
                else
                    GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                GenJnlLine.Validate("Account No.", TempPmtBuffer."Account No.");
                GenJnlLine.Description := TempPmtBuffer."Tender Description";
            end;
            GenJnlLine."Reason Code" := TransHead.Reasoncode;

            if GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account" then begin
                GenJnlLine."Gen. Bus. Posting Group" := '';
                GenJnlLine."Gen. Posting Type" := Enum::"General Posting Type"::" ";
                GenJnlLine."Gen. Prod. Posting Group" := '';
                GenJnlLine."VAT %" := 0;
                GenJnlLine."VAT Bus. Posting Group" := '';
                GenJnlLine."VAT Prod. Posting Group" := '';
            end;

            GenJnlLine."Currency Code" := '';
            GenJnlLine.Amount := TempPmtBuffer.Amount;
            GenJnlLine."Source Currency Code" := '';
            GenJnlLine."Amount (LCY)" := GenJnlLine.Amount;
            GenJnlLine."Currency Factor" := 1;
            GenJnlLine."Allow Application" := true;
            GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
            GenJnlLine."Source No." := TransHead."Customer No.";
            GenJnlLine."Allow Zero-Amount Posting" := true;
            GenJnlPostLine.RunWithCheck(GenJnlLine);
        until TempPmtBuffer.Next() = 0;
        CallSignatureService(TransHead);
        //-POS0034
    end;

    /*internal procedure CSLPayMethodPaymentAfterPost(var pSalesInv: Record "Sales Invoice Header")
    var
        PayMethod: Record "Payment Method";
        UserSetup: Record "User Setup";
        RetailUser: Record "CCS CASH Retail User";
        CustLedgEntry: Record "Cust. Ledger Entry";
        TenderType: Record "CCS CASH Store Tender Type";
        RetailSetup: Record "CCS CASH Cash Sales Setup";
        POSTerminalDevice: Page "CCS CASH POS Terminal Device";
    begin
        //++POS0035
        if pSalesInv."No." = '' then
            exit;

        RetailSetup.Get();

        //+POS0036
        if RetailSetup.CSLDialogPosting then
            exit;
        //-POS0036

        if (pSalesInv."Payment Method Code" = '') or
           (pSalesInv."CCS CASH CSL Document") then
            exit;

        if not PayMethod.Get(pSalesInv."Payment Method Code") then
            PayMethod.Init();
        if PayMethod."CCS CASH CSL Tender Type" = '' then
            exit;

        UserSetup.Get(UserId);
        UserSetup.TestField("CCS CASH POS No.");
        UserSetup.TestField("CCS CASH Staff ID");
        UserSetup.TestField("CCS CASH Store No.");
        if not UserSetup."CCS CASH Op. Pmt. aft. Post" then
            exit;
        POSTerm.Get(UserSetup."CCS CASH Store No.", UserSetup."CCS CASH POS No.");
        if POSTerm.Status() = 0 then
            Error(Error004, POSTerm."No.");

        TenderType.Get(UserSetup."CCS CASH Store No.", PayMethod."CCS CASH CSL Tender Type", '');
        TenderType.TestField("Account No.");

        RetailUser.Get(UserSetup."CCS CASH Staff ID", UserSetup."CCS CASH Store No.", UserSetup."CCS CASH POS No.");

        if IsSignatureServiceDown(UserSetup."CCS CASH Store No.", UserSetup."CCS CASH POS No.", '') then
            exit;

        CustLedgEntry.FindLast();
        if (CustLedgEntry."Customer No." <> pSalesInv."Bill-to Customer No.") or
           ((CustLedgEntry."Document Type" <> CustLedgEntry."Document Type"::Invoice) and (CustLedgEntry."Document No." <> pSalesInv."No."))
          then
            Error(Text028, pSalesInv."No.");

        POSTerminalDevice.CallLoginOutside(RetailUser);
        POSTerminalDevice.SetAutoOption(1);
        POSTerminalDevice.SetCustLedgerEntry(CustLedgEntry);
        Commit();
        POSTerminalDevice.RunAutoOption();
        //--POS0035
    end;*/

    internal procedure CallSignatureService(pTransHeader: Record "CCS CASH POS Transaction Hdr.")
    //früher: CallEfsta
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnCallSignatureService(pTransHeader, IsHandled);
        HandleSignatureServiceResponse(IsHandled);
    end;

    internal procedure IsSignatureServiceDown(StoreNo: Code[20]; POSTerminalNo: Code[20]; ReceiptNo: Code[20]): Boolean
    //früher: EfstaWebServiceDown
    var
        IsHandled: Boolean;
        IsDown: Boolean;
    begin
        IsHandled := false;
        IsDown := false;
        OnIsSignatureServiceDown(StoreNo, POSTerminalNo, ReceiptNo, IsDown, IsHandled);
        HandleSignatureServiceResponse(IsHandled);

        exit(IsDown);
    end;

    internal procedure IsSignatureSetupActive(StoreNo: Code[20]; POSTerminalNo: Code[20]): Boolean
    //früher: IsSignatureSetupActive
    var
        IsHandled: Boolean;
        IsActive: Boolean;
        CashSalesSetup: Record "CCS CASH Cash Sales Setup";
    begin
        IsHandled := false;
        IsActive := false;
        OnIsSignatureSetupActive(StoreNo, POSTerminalNo, IsActive, IsHandled);

        IF CashSalesSetup.Get() THEN
            IF not CashSalesSetup."Signature Service" THEN
                exit(true); //wenn Signaturservice nicht benötigt wird, soll die Prüfung OK zurück geben

        HandleSignatureServiceResponse(IsHandled);

        exit(IsActive);
    end;

    internal procedure HandleSignatureServiceResponse(IsHandled: Boolean)
    var
        CashSalesSetup: Record "CCS CASH Cash Sales Setup";
        txtSignatureError: Label 'Signature service not found';
    begin
        IF CashSalesSetup.Get() THEN
            IF CashSalesSetup."Signature Service" THEN
                IF not IsHandled then
                    error(txtSignatureError);
    end;

    internal procedure FinalizeCSLPosting(CashDocument: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        TransH: Record "CCS CASH POS Transaction Hdr.";
        RetailSetup: Record "CCS CASH Cash Sales Setup";
        TempPaymentBuffer: Record "CCS CASH Trans. Payment Entry" temporary;
        GenJnlLine: Record "Gen. Journal Line";
    begin
        //-POS001
        //Post CSL Payment
        RetailSetup.Get();
        TransH.Get(CashDocument."CCS CASH CSL Store No.", CashDocument."CCS CASH CSL POS Terminal No.", CashDocument."CCS CASH CSL Transaction No.");
        if CashDocument."CCS CASH CSL Do Cash Posting" then begin
            POSTerm.Get(CashDocument."CCS CASH CSL Store No.", CashDocument."CCS CASH CSL POS Terminal No.");
            if TransH."Receipt No." = '' then
                TransH."Receipt No." := NoSeriesMgt.GetNextNo(POSTerm."Posted Receipt Nos.", WorkDate(), true)
        end else
            TransH."Receipt No." := CashDocument."Last Posting No.";
        TransH.Modify(true);
        TransH.TestField("Receipt No.");
        GetPaymentBuffer(TransH, TempPaymentBuffer);
        TempPaymentBuffer.Find('-');
        repeat
            GenJnlLine.Init();

            GenJnlLine."Journal Template Name" := RetailSetup."Journale Template Name";

            GenJnlLine."Posting Date" := TempPaymentBuffer."Creation Date";
            GenJnlLine."Document Date" := TempPaymentBuffer."Creation Date";

            if TransH."Transaction Type" = TransH."Transaction Type"::Return then
                GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Refund)
            else
                GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Payment);
            GenJnlLine."Document No." := TransH."Receipt No.";

            if TempPaymentBuffer."Line No." = 1 then begin
                GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::Customer);
                GenJnlLine.Validate("Account No.", TransH."Customer No.");
                if GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment then
                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice
                else
                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";
                if CashDocument."CCS CASH CSL Do Cash Posting" and (CashDocument."Last Posting No." <> '') then
                    GenJnlLine.Validate("Applies-to Doc. No.", CashDocument."Last Posting No.")
                else
                    GenJnlLine.Validate("Applies-to Doc. No.", TransH."Receipt No.");
            end else begin
                if TempPaymentBuffer."Account Type" = TempPaymentBuffer."Account Type"::"Bank Account" then
                    GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"Bank Account")
                else
                    GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                GenJnlLine.Validate("Account No.", TempPaymentBuffer."Account No.");
            end;
            GenJnlLine.Description := TempPaymentBuffer."Tender Description";
            GenJnlLine."Reason Code" := TransH.Reasoncode;

            // + POS0007
            if GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account" then begin
                GenJnlLine."Gen. Bus. Posting Group" := '';
                GenJnlLine."Gen. Posting Type" := Enum::"General Posting Type"::" ";
                GenJnlLine."Gen. Prod. Posting Group" := '';
                GenJnlLine."VAT %" := 0;
                GenJnlLine."VAT Bus. Posting Group" := '';
                GenJnlLine."VAT Prod. Posting Group" := '';
            end;
            // - POS0007

            GenJnlLine."Currency Code" := '';
            //--POS0002
            // correction to avoid commit: GenJnlLine.VALIDATE(Amount,TempPaymentBuffer.Amount);
            GenJnlLine.Amount := TempPaymentBuffer.Amount;
            //++POS0002
            GenJnlLine."Source Currency Code" := '';
            GenJnlLine."Amount (LCY)" := GenJnlLine.Amount;
            GenJnlLine."Currency Factor" := 1;
            GenJnlLine."Allow Application" := true;
            GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
            GenJnlLine."Source No." := TransH."Customer No.";
            GenJnlLine."Allow Zero-Amount Posting" := true;
            GenJnlPostLine.RunWithCheck(GenJnlLine);
        until TempPaymentBuffer.Next() = 0;
        //+POS001
    end;

    local procedure GetPaymentBuffer(var pTransH: Record "CCS CASH POS Transaction Hdr."; var pTempPmtBuffer: Record "CCS CASH Trans. Payment Entry" temporary)
    var
        TransPmt: Record "CCS CASH Trans. Payment Entry";
        Tendertype: Record "CCS CASH Store Tender Type";
        TTCard: Record "CCS CASH Tender Type C. Setup";
    begin
        TempPmtBuffer.DeleteAll();
        TransPmt.SetRange("Store No.", pTransH."Store No.");
        TransPmt.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
        TransPmt.SetRange("Transaction No.", pTransH."Transaction No.");

        if TransPmt.FindSet() then
            repeat
                Tendertype.Get(pTransH."Store No.", TransPmt."Tender Type");
                if (Tendertype.TenderFunction <> Tendertype.TenderFunction::Voucher) and (TransPmt."Card No." <> '') then begin
                    TTCard.Get(pTransH."Store No.", TransPmt."Tender Type", TransPmt."Card No.");
                    Tendertype."Account Type" := TTCard."Account Type";
                    Tendertype."Account No." := TTCard."Account No.";
                end;
                Tendertype.TestField("Account No.");
                TransPmt."Account Type" := GetAccountType_Payment(Tendertype."Account Type");
                TransPmt."Account No." := Tendertype."Account No.";
                TransPmt."Tender Description" := CopyStr(
#pragma warning disable AA0217
                  StrSubstNo(Text020, StrSubstNo('%1-%2-%3',
                pTransH."Store No.", pTransH."POS Terminal No.", Format(pTransH."Transaction No."))) + StrSubstNo(' (%1 %2)', Tendertype.Code, Tendertype.Description), 1, 50);
#pragma warning restore AA0217
#pragma warning disable AA0217
                UpdatePaymentBuffer(TransPmt, CopyStr(StrSubstNo('%1-%2-%3',
                                    pTransH."Store No.", pTransH."POS Terminal No.", Format(pTransH."Transaction No.")), 1, 20),
#pragma warning restore AA0217
                                    pTransH."Creation Date", pTransH."Customer No.");
            until TransPmt.Next() = 0;

        // Update Customer Posting Buffer
        TempPmtBuffer.Get('', '', 0, 1);
        TempPmtBuffer."Tender Description" := CopyStr(GetDefaultPostingDescription(pTransH), 1, MaxStrLen(TempPmtBuffer."Tender Description"));
        TempPmtBuffer.Modify();

        if TempPmtBuffer.FindSet() then
            repeat
                pTempPmtBuffer := TempPmtBuffer;
                pTempPmtBuffer.Insert();
            until TempPmtBuffer.Next() = 0;
    end;

    local procedure SetDiscountPayable(var pTransH: Record "CCS CASH POS Transaction Hdr."; var ApplyCustLedgEntry: Record "Cust. Ledger Entry"; var CCSCASHCashSalesSetup: Record "CCS CASH Cash Sales Setup"; var Customer: Record Customer)
    begin
        if (ApplyCustLedgEntry."Pmt. Discount Date" >= pTransH."Creation Date") then
            exit;
        if (ApplyCustLedgEntry."Pmt. Disc. Tolerance Date" >= pTransH."Creation Date") then begin
            If (CCSCASHCashSalesSetup."Pmt. Disc. Tolerance Date") and (not Customer."Block Payment Tolerance") then begin
                exit;
            end;
        end;
        if (ApplyCustLedgEntry."Remaining Pmt. Disc. Possible" <> 0) then begin
            ApplyCustLedgEntry."Remaining Pmt. Disc. Possible" := 0;
            ApplyCustLedgEntry.Modify();
        end;
    end;

    internal procedure OnBeforeCSLPosting(var pSalesHeader: Record "Sales Header"): Boolean
    var
        PaymentMethod: Record "Payment Method";
        UserSetup: Record "User Setup";
        RetailSetup: Record "CCS CASH Cash Sales Setup";
        Text1070540: Label 'POS Terminal %1 at Store %2 closed.', Comment = '%1=Value 1,%2=Value 2';
        Text1070541: Label 'A Posting Date other than the aktual date ist not allowed at cash desk.';
        TenderType: Record "CCS CASH Store Tender Type";
        Session: Record "Active Session";
        CSLFunc: Codeunit "CCS CASH POS Register Func";
        Text1070542: Label 'POS Termoinal already active at %1 by %2.', Comment = '%1=Value 1,%2=Value 2';
        PostingAbortedMsg: Label 'Cash posting aborted.';
    begin
        //-POS0034
        //+POS0036  Returns true, if posting should handover to cash functions
        //IF ((pSalesHeader."Document Type" <> pSalesHeader."Document Type"::Invoice) AND NOT pSalesHeader.Invoice) OR
        //   (pSalesHeader."Payment Method Code" = '') OR (pSalesHeader."CSL Document") THEN
        //  EXIT;
        if pSalesHeader."Document Type" <> pSalesHeader."Document Type"::Order then
            exit;

        if pSalesHeader."CCS CASH CSL Do Cash Posting" then begin
            if not pSalesHeader.Invoice or (pSalesHeader."Payment Method Code" = '') then
                exit
        end else
            if pSalesHeader."CCS CASH CSL Document" or not pSalesHeader.Invoice or (pSalesHeader."Payment Method Code" = '') then
                exit;

        RetailSetup.Get();
        //-POS0036

        if not PaymentMethod.Get(pSalesHeader."Payment Method Code") then
            PaymentMethod.Init();
        if PaymentMethod."CCS CASH CSL Tender Type" = '' then
            exit;

        UserSetup.Get(UserId);
        UserSetup.TestField("CCS CASH Store No.");
        UserSetup.TestField("CCS CASH POS No.");
        UserSetup.TestField("CCS CASH Staff ID");
        if pSalesHeader."Posting Date" <> Today then
            Error(Text1070541);

        TenderType.Get(UserSetup."CCS CASH Store No.", PaymentMethod."CCS CASH CSL Tender Type", '');
        TenderType.TestField("Account No.");

        POSTerm.Get(UserSetup."CCS CASH Store No.", UserSetup."CCS CASH POS No.");
        if POSTerm.Status() = 0 then
            Error(Text1070540, POSTerm."No.", POSTerm."Store No");
        CSLFunc.IsSignatureServiceDown(UserSetup."CCS CASH Store No.", UserSetup."CCS CASH POS No.", '');
        //+POS0034

        //+POS0036
        if POSTerm."Open in Session" <> 0 then begin
            if not Session.Get(POSTerm."Open in Server Instance ID", POSTerm."Open in Session") then begin
                POSTerm."Open in Server Instance ID" := 0;
                POSTerm."Open in Session" := 0;
                POSTerm.Modify();
            end else
                Error(Text1070542, Session."Client Computer Name", Session."User ID");
        end;

        if RetailSetup.CSLDialogPosting then begin
            if not CSLFunc.DoOrderPosting2(pSalesHeader) then begin
                Message(PostingAbortedMsg);
                exit(true);
            end else
                exit(false);
            //exit(CSLFunc.DoOrderPosting(pSalesHeader))
        end;
        //-POS0036
    end;

    internal procedure GetAccountType(AccType_Payment: Enum "CCS CASH Account Type Payment"): Enum "CCS CASH Account Type"
    var
        AccType: enum "CCS CASH Account Type";
    begin
        case AccType_Payment of
            AccType_Payment::"Bank Account":
                exit(AccType::"Bank Account");
            AccType_Payment::"G/L Account":
                exit(AccType::"G/L Account");
        end;
    end;

    internal procedure GetAccountType_Payment(AccType: Enum "CCS CASH Account Type"): Enum "CCS CASH Account Type Payment"
    var
        AccType_Payment: enum "CCS CASH Account Type Payment";
    begin
        case AccType of
            AccType::"Bank Account":
                exit(AccType_Payment::"Bank Account");
            AccType::"G/L Account":
                exit(AccType_Payment::"G/L Account");
        end;
    end;

    procedure GetDocumentQRCode(StoreNo: Code[20]; PosTerminalNo: Code[20]; TransactionNo: Integer; VAR DocumentInformation: Record "CCS CASH Document Information")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnGetDocumentQRCode(StoreNo, PosTerminalNo, TransactionNo, DocumentInformation, IsHandled);
        HandleSignatureServiceResponse(IsHandled);
    end;

    internal procedure OpenCosmoLicensing(pNotification: Notification)
    var
        CCSLICLicenseOverview: Page "CCS LIC License Overview";
    begin
        CCSLICLicenseOverview.Run();
    end;

    // #region notification actions
    procedure ShowRegistrationWizard(RegistrationNotification: Notification)
    var
        RegistrationWizard: Page "CCS LIC License Reg. Wizard";
    begin
        if RegistrationNotification.HasData('AppId') then
            RegistrationWizard.SetAppGranuleFilter(RegistrationNotification.GetData('AppId'), '');
        RegistrationWizard.RunModal();
    end;

    procedure OpenLicenseOverview(RegistrationNotification: Notification)
    var
        LicenseOverview: Page "CCS LIC License Overview";
    begin
        LicenseOverview.Run();
    end;
    // #endregion

    internal procedure GetDefaultPostingDescription(POSTransactionHeader: record "CCS CASH POS Transaction Hdr."): Text
    begin
        exit(StrSubstNo(Text020, CreateDocumentNo(POSTransactionHeader)));
    end;

    internal procedure isBase64(base64text: Text): Boolean;
    var
        i: Integer;
    begin
        // check if the length is a multiple of 4
        if (StrLen(Format(base64text, 0, 9)) / 4 mod 1) <> 0 then
            exit(false);
        // check each character if allowed
        for i := 1 to StrLen(Format(base64text, 0, 9)) do
            if not (CopyStr(Format(base64text, 0, 9), i, 1) in ['A' .. 'Z', 'a' .. 'z', '0' .. '9', '+', '/']) then begin
                // if not allowed character found, check if already at end of string (and check for '=')
                if (i = StrLen(Format(base64text, 0, 9)) - 1) or
                   (i = StrLen(Format(base64text, 0, 9)))
                then begin
                    if CopyStr(Format(base64text, 0, 9), i, 1) <> '=' then
                        exit(false);
                end
                else
                    exit(false);
            end;
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCallSignatureService(pTransHeader: Record "CCS CASH POS Transaction Hdr."; VAR IsHandled: boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsSignatureServiceDown(StoreNo: Code[20]; POSTerminalNo: Code[20]; ReceiptNo: Code[20]; VAR IsServiceDown: boolean; VAR IsHandled: boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsSignatureSetupActive(StoreNo: Code[20]; POSTerminalNo: Code[20]; VAR IsActive: boolean; VAR IsHandled: boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDocumentQRCode(StoreNo: Code[20]; PosTerminalNo: Code[20]; TransactionNo: Integer; VAR DocumentInformation: Record "CCS CASH Document Information"; VAR IsHandled: boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostPayment_BeforeCheckLines(var CCSCASHPOSTransactionHdr: Record "CCS CASH POS Transaction Hdr."; var GenJnlLine: Record "Gen. Journal Line"; var CheckOnly: boolean)
    begin
    end;

}

