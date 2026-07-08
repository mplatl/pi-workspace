codeunit 1070542 "CCS CASH POS Reg. Customer Lib"
{
    Permissions = TableData "Cust. Ledger Entry" = rm;

    var
        cslFunction: Codeunit "CCS CASH POS Register Func";
        CCSCASHCashSalesSetup: Record "CCS CASH Cash Sales Setup";
        CashSalesSetupLoaded: Boolean;
        Text002: Label 'Reason for Payment';
        Text003: Label 'Do you want to receive a payment?  ';
        Text004: Label 'For Customer %1 %2 are no Open Invoices,\ ', Comment = '%1=Customer No.,%2=Customer Name';

    internal procedure SelectCustomerEntry(pRetailUser: Record "CCS CASH Retail User"; var pTransHead: Record "CCS CASH POS Transaction Hdr."; OpenCustPmtTransPage: Boolean): Boolean
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        Cust: Record Customer;
        SelectPage: Page "CCS CASH Customer E. Selection";
        CustSelected: Boolean;
    begin
        LoadCashSalesSetup();

        repeat
            if PAGE.RunModal(0, Cust) = ACTION::LookupOK then begin
                CustLedgEntry.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
                CustLedgEntry.SetRange("Customer No.", Cust."No.");
                CustLedgEntry.SetRange(Open, true);
                if CustLedgEntry.IsEmpty then begin
                    if not Confirm(Text004 + Text003, false, Cust."No.", Cust.Name) then
                        exit(false);
                    CustSelected := true;
                end else begin
                    Clear(SelectPage);
                    SelectPage.LookupMode(true);
                    SelectPage.SetTableView(CustLedgEntry);
                    if SelectPage.RunModal() = ACTION::LookupOK then begin
                        SelectPage.GetSelectedEntries(CustLedgEntry);
                        if not CustLedgEntry.FindSet() then
                            exit(false);
                    end else
                        if Confirm(Text003, false) then
                            CustSelected := true
                        else
                            exit(false);
                end;
            end else
                exit(false);

            if CustSelected then
                CreateTransForCustPmt(Cust, pTransHead, pRetailUser)
            else
                if not CreateTansHeaderForCust(pRetailUser, pTransHead, CustLedgEntry) then
                    exit(false);

            if OpenCustPmtTransPage then
                PAGE.RunModal(Page::"CCS CASH Cust. Pmt. Trans.", pTransHead);

        until false;
    end;

    procedure CreateTransForCustPmt(Cust: Record Customer; var pTransHead: Record "CCS CASH POS Transaction Hdr."; pRetailUser: Record "CCS CASH Retail User")
    var
        TransSales: Record "CCS CASH Trans. Sales Entry";
        TransHeaderPtr: Integer;
    begin
        TransHeaderPtr := cslFunction.CreateTransLog(pRetailUser, pTransHead."Transaction Type"::Payment);
        pTransHead.Get(pRetailUser."Store No", pRetailUser."POS Terminal No.", TransHeaderPtr);
        pTransHead."Customer No." := Cust."No.";
        pTransHead.Modify();

        TransSales.Init();
        TransSales."Store No." := pTransHead."Store No.";
        TransSales."POS Terminal No." := pTransHead."POS Terminal No.";
        TransSales."Transaction No." := pTransHead."Transaction No.";
        TransSales.Type := TransSales.Type::"CCS CASH Payment";
        TransSales.Description := Text002;
        TransSales.Quantity := 1;
        TransSales."Creation Date" := WorkDate();
        TransSales."Creation Time" := Time;
        TransSales."Staff ID" := pRetailUser."Staff ID";
        TransSales.Insert();
        Commit();
    end;

    procedure CreateTansHeaderForCust(pRetailUser: Record "CCS CASH Retail User"; var pTransHead: Record "CCS CASH POS Transaction Hdr."; var CustLedgEntry: Record "Cust. Ledger Entry"): Boolean
    var
        TransSales: Record "CCS CASH Trans. Sales Entry";
        RecRef: RecordRef;
        FRef: FieldRef;
        TransHeaderPtr: Integer;
        CustLedgerCount: Integer;
        AdvPaymentExist: Boolean;
        ApplyAdvPmtRequestsErr: Label 'You cannot assign more than one entry for applying advance payment requests.';
    begin
        LoadCashSalesSetup();

        if CustLedgEntry.FindSet() then begin
            TransHeaderPtr := cslFunction.CreateTransLog(pRetailUser, pTransHead."Transaction Type"::Payment);
            pTransHead.Get(pRetailUser."Store No", pRetailUser."POS Terminal No.", TransHeaderPtr);
            pTransHead."Customer No." := CustLedgEntry."Customer No.";
            if CCSCASHCashSalesSetup."Use Posting Descr. on Pmt" then
                pTransHead."Posting Description" := Text002
            else
                pTransHead."Posting Description" := CopyStr(cslFunction.GetDefaultPostingDescription(pTransHead), 1, MaxStrLen(pTransHead."Posting Description"));
            pTransHead.Modify();
            repeat
                RecRef.GetTable(CustLedgEntry);
                CustLedgerCount += 1;
                if RecRef.FieldExist(5013500) then begin // "CCS APT Advance Payment No."
                    FRef := RecRef.Field(5013500); // "CCS APT Advance Payment No."
                    if Format(FRef.Value) <> '' then
                        AdvPaymentExist := true;
                end;
                CustLedgEntry.CalcFields("Amount (LCY)", "Remaining Amt. (LCY)");
                TransSales.Init();
                TransSales."Store No." := pTransHead."Store No.";
                TransSales."POS Terminal No." := pTransHead."POS Terminal No.";
                TransSales."Transaction No." := pTransHead."Transaction No.";
                TransSales."Entry No." := CustLedgEntry."Entry No.";
                TransSales.Type := TransSales.Type::"CCS CASH Customer Ledger Entry";
                TransSales."No." := CustLedgEntry."Document No.";
                TransSales.Description := CustLedgEntry.Description;
                TransSales.Quantity := 1;
                TransSales.Amount := -CustLedgEntry."Amount (LCY)";
                TransSales."Amount incl. VAT" := -CustLedgEntry."Remaining Amt. (LCY)";
                TransSales."Creation Date" := WorkDate();
                TransSales."Creation Time" := Time;
                TransSales."Staff ID" := pRetailUser."Staff ID";
                TransSales."Source Entry No." := CustLedgEntry."Entry No.";
                //--POS0004
                TransSales."Pmt. Discount Date" := CustLedgEntry."Pmt. Discount Date";
                TransSales."Remaining Pmt. Disc. Possible" := -CustLedgEntry."Remaining Pmt. Disc. Possible";
                TransSales."Pmt. Disc. Tolerance Date" := CustLedgEntry."Pmt. Disc. Tolerance Date";
                TransSales."Original Pmt. Disc. Possible" := CustLedgEntry."Original Pmt. Disc. Possible";
                //++POS0004
                if (CustLedgEntry."Pmt. Discount Date" >= pTransHead."Creation Date") then begin
                    if CustLedgEntry."Remaining Pmt. Disc. Possible" <> 0 then
                        pTransHead."Payment Discount Amount" := Round(pTransHead."Payment Discount Amount" - CustLedgEntry."Remaining Pmt. Disc. Possible", 0.01);
                end else begin
                    if CCSCASHCashSalesSetup."Pmt. Disc. Tolerance Date" then
                        if (CustLedgEntry."Pmt. Disc. Tolerance Date" >= pTransHead."Creation Date") then
                            if CustLedgEntry."Remaining Pmt. Disc. Possible" <> 0 then begin
                                pTransHead."Payment Discount Amount" := Round(pTransHead."Payment Discount Amount" - CustLedgEntry."Remaining Pmt. Disc. Possible", 0.01);
                                CustLedgEntry."Accepted Pmt. Disc. Tolerance" := true;
                                CustLedgEntry.Modify();
                            end;
                end;
                TransSales.Insert();
            until CustLedgEntry.Next() = 0;

            if (CustLedgerCount > 1) and AdvPaymentExist then
                Error(ApplyAdvPmtRequestsErr);

            if AdvPaymentExist then
                pTransHead."Is Advance Payment" := true;

            pTransHead.Modify();
            Commit();

            exit(true);
        end;
        exit(false);

    end;

    // never used
    internal procedure SetCustomerEntry(pRetailUser: Record "CCS CASH Retail User"; var pTransHead: Record "CCS CASH POS Transaction Hdr."; var pCustLedgerEntry: Record "Cust. Ledger Entry"): Boolean
    var
        TransSales: Record "CCS CASH Trans. Sales Entry";
        TransHeaderPtr: Integer;
    begin
        //++POS0035
        if pCustLedgerEntry."Entry No." = 0 then
            exit(false);
        LoadCashSalesSetup();
        TransHeaderPtr := cslFunction.CreateTransLog(pRetailUser, pTransHead."Transaction Type"::Payment);
        pTransHead.Get(pRetailUser."Store No", pRetailUser."POS Terminal No.", TransHeaderPtr);
        pTransHead."Customer No." := pCustLedgerEntry."Customer No.";
        if CCSCASHCashSalesSetup."Use Posting Descr. on Pmt" then
            pTransHead."Posting Description" := Text002
        else
            pTransHead."Posting Description" := CopyStr(cslFunction.GetDefaultPostingDescription(pTransHead), 1, MaxStrLen(pTransHead."Posting Description"));
        pTransHead.Modify();

        pCustLedgerEntry.CalcFields("Amount (LCY)", "Remaining Amt. (LCY)");
        TransSales.Init();
        TransSales."Store No." := pTransHead."Store No.";
        TransSales."POS Terminal No." := pTransHead."POS Terminal No.";
        TransSales."Transaction No." := pTransHead."Transaction No.";
        TransSales."Entry No." := pCustLedgerEntry."Entry No.";
        TransSales.Type := TransSales.Type::"CCS CASH Customer Ledger Entry";
        TransSales."No." := pCustLedgerEntry."Document No.";
        TransSales.Description := pCustLedgerEntry.Description;
        TransSales.Quantity := 1;
        TransSales.Amount := -pCustLedgerEntry."Amount (LCY)";
        TransSales."Amount incl. VAT" := -pCustLedgerEntry."Remaining Amt. (LCY)";
        TransSales."Creation Date" := WorkDate();
        TransSales."Creation Time" := Time;
        TransSales."Staff ID" := pRetailUser."Staff ID";
        TransSales."Source Entry No." := pCustLedgerEntry."Entry No.";
        //--POS0004
        TransSales."Pmt. Discount Date" := pCustLedgerEntry."Pmt. Discount Date";
        TransSales."Remaining Pmt. Disc. Possible" := -pCustLedgerEntry."Remaining Pmt. Disc. Possible";
        //++POS0004
        if (pCustLedgerEntry."Pmt. Discount Date" >= pTransHead."Creation Date") then begin
            if pCustLedgerEntry."Remaining Pmt. Disc. Possible" <> 0 then
                pTransHead."Payment Discount Amount" := Round(pTransHead."Payment Discount Amount" - pCustLedgerEntry."Remaining Pmt. Disc. Possible", 0.01)
        end else begin
            if CCSCASHCashSalesSetup."Pmt. Disc. Tolerance Date" then
                if (pCustLedgerEntry."Pmt. Disc. Tolerance Date" >= pTransHead."Creation Date") then
                    if pCustLedgerEntry."Remaining Pmt. Disc. Possible" <> 0 then begin
                        pTransHead."Payment Discount Amount" := Round(pTransHead."Payment Discount Amount" - pCustLedgerEntry."Remaining Pmt. Disc. Possible", 0.01);
                        pCustLedgerEntry."Accepted Pmt. Disc. Tolerance" := true;
                        pCustLedgerEntry.Modify();
                    end;
        end;
        TransSales.Insert();

        pTransHead.Modify();
        Commit();
        exit(true);
        //--POS0025
    end;

    internal procedure GetDefaultReasonforPayment(): Text
    begin
        exit(Text002);
    end;

    local procedure LoadCashSalesSetup()
    begin
        if not CashSalesSetupLoaded then begin
            CCSCASHCashSalesSetup.Get();
            CashSalesSetupLoaded := true;
        end;
    end;
}