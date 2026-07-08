namespace S_W.BilanzTool;

/// <summary>Tests for BT Date Management — period calculation and date handling.</summary>
codeunit 62024 "BT Date Management Test"
{
    Subtype = Test;

    var
        DateMgt: Codeunit "BT Date Management";

    [Test]
    procedure TestSetManualDatesValidDate()
    begin
        DateMgt.SetManualDates(20260630D);
        // Should not throw
    end;

    [Test]
    procedure TestSetManualDatesZeroDate()
    begin
        DateMgt.SetManualDates(0D);
        // Should exit early without error
    end;

    [Test]
    procedure TestInitAccountingPeriods()
    var
        Count: Integer;
    begin
        Count := DateMgt.InitAccountingPeriods();
        if Count < 0 then
            Error('Period count should be non-negative');
    end;

    [Test]
    procedure TestGetBalanceDateNoPeriods()
    var
        BalanceDate: Date;
    begin
        BalanceDate := DateMgt.GetBalanceDate(0);
        if BalanceDate = 0D then
            Error('Balance date should not be zero');
    end;
}
