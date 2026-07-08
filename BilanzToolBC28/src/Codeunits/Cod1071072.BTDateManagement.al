namespace S_W.BilanzTool;

codeunit 62014 "BT Date Management"
{
    var
        Logger: Codeunit "BT Logger";
        Setup: Record "BT Setup";
        PeriodsCount: Integer;
        CurrentPeriod: Integer;
        PeriodStart: array[100] of Date;
        PeriodEnd: array[100] of Date;
        UseManualDate: Boolean;
        ManualDates: array[6] of Date;
        AccountGroupingHeader: Record "BT Acc. Grouping Header";
        NO_ACCOUNTING_PERIOD: Label 'No accounting period for date %1.';

    procedure InitAccountingPeriods(): Integer
    var
        AccPeriodRef: RecordRef;
        NewFiscalField: FieldRef;
    begin
        PeriodsCount := 0;
        AccPeriodRef.Open(80);
        NewFiscalField := AccPeriodRef.Field(4);
        NewFiscalField.SetFilter('true');
        if AccPeriodRef.FindSet() then
            PeriodsCount := AccPeriodRef.Count();
        CurrentPeriod := 1;
        exit(PeriodsCount);
    end;

    procedure GetBalanceDate(AddPeriod: Integer): Date
    var returnDate: Date;
    begin
        if UseManualDate then begin
            if AddPeriod = -1 then exit(GetManualDate(4));
            if AddPeriod = 0 then exit(GetManualDate(2));
        end;
        if (CurrentPeriod + AddPeriod >= 1) and (CurrentPeriod + AddPeriod <= PeriodsCount) then
            returnDate := PeriodEnd[CurrentPeriod + AddPeriod]
        else
            returnDate := CalcDate('<-1Y>', WorkDate());
        exit(GetEndDate(returnDate));
    end;

    procedure GetPalStartDate(AddPeriod: Integer): Date
    var returnDate: Date;
    begin
        if UseManualDate then begin
            if AddPeriod = -1 then exit(GetManualDate(3));
            if AddPeriod = 0 then exit(GetManualDate(1));
        end;
        if (CurrentPeriod + AddPeriod >= 1) and (CurrentPeriod + AddPeriod <= PeriodsCount) then
            returnDate := PeriodStart[CurrentPeriod + AddPeriod]
        else
            returnDate := CalcDate('<-1Y>', WorkDate());
        exit(GetStartDate(returnDate));
    end;

    procedure SetCurrentPeriodFromDate(BalanceDate: Date)
    var i: Integer;
    begin
        CurrentPeriod := 0;
        if BalanceDate = 0D then BalanceDate := WorkDate();
        for i := 1 to PeriodsCount do
            if (BalanceDate >= PeriodStart[i]) and (BalanceDate <= PeriodEnd[i]) then
                CurrentPeriod := i;
        if CurrentPeriod = 0 then Error(NO_ACCOUNTING_PERIOD, BalanceDate);
    end;

    procedure GetCurrentPeriod(): Integer
    begin exit(CurrentPeriod); end;
    procedure SetCurrentPeriod(Period: Integer)
    begin CurrentPeriod := Period; end;
    procedure SetAccountingHeaderCode(Code: Code[20])
    begin AccountGroupingHeader.Get(Code); end;
    procedure GetAccountingHeaderCode(): Text
    begin exit(AccountGroupingHeader.Code); end;
    procedure SetUseManualDate(manual: Boolean)
    begin UseManualDate := manual; end;
    procedure SetManualDate(Date: Date; Type: Integer)
    begin UseManualDate := true; ManualDates[Type] := Date; end;

    procedure SetManualDates(BalanceDate: Date)
    var PrevDate: Date;
    begin
        if BalanceDate = 0D then exit;
        PrevDate := CalcDate('<-1Y>', BalanceDate);
        UseManualDate := true;
        ManualDates[2] := BalanceDate;
        ManualDates[4] := PrevDate;
        ManualDates[1] := GetPalStartDate(0);
        ManualDates[3] := GetPalStartDate(-1);
    end;

    procedure GetManualDate(Type: Integer): Date
    var returnDate: Date;
    begin
        returnDate := ManualDates[Type];
        if Type in [1, 3] then exit(GetStartDate(returnDate));
        exit(GetEndDate(returnDate));
    end;

    procedure HasNextPeriod(): Boolean
    begin exit(CurrentPeriod < PeriodsCount); end;

    local procedure GetStartDate(ADate: Date): Date
    begin
        if ADate = 0D then exit(0D);
        if AccountGroupingHeader.IsBalance() then exit(0D);
        exit(NormalDate(ADate));
    end;

    local procedure GetEndDate(ADate: Date): Date
    begin
        if ADate = 0D then exit(0D);
        if AccountGroupingHeader.IsBalance() then exit(ClosingDate(ADate));
        exit(NormalDate(ADate));
    end;

    procedure GetDatesForNode(var Node: Record "BT Account Grouping"; var StartDate: Date; var EndDate: Date)
    begin
        if AccountGroupingHeader.Code = '' then SetAccountingHeaderCode(Node."Grouping Header");
        if (AccountGroupingHeader.IsPL()) and (Node."G/L Account No." = Setup."Retained Earnings Acc.") then begin
            EndDate := StartDate;
            StartDate := 0D;
        end else if AccountGroupingHeader.IsCashflow() then begin
            if Node."Balance at Period Start" then begin
                if StartDate <> 0D then EndDate := ClosingDate(CalcDate('<-1D>', StartDate));
                StartDate := 0D;
            end;
            if Node."Use Balance" then begin EndDate := ClosingDate(EndDate); StartDate := 0D; end;
        end else begin
            if Node."Balance at Period Start" then begin EndDate := CalcDate('<-1D>', StartDate); StartDate := 0D; end;
            if Node."Use Balance" then StartDate := 0D;
        end;
    end;
}
