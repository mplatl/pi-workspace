enum 1070547 "CCS CASH Zero Receipt Type"
{
    Extensible = true;

    value(0; ZeroReceipt)
    {
        Caption = 'Zero Amount Receipt';
    }

    value(1; MonthlyReceipt)
    {
        Caption = 'Monthly Receipt';
    }
    value(2; StartReceipt)
    {
        Caption = 'Start Receipt';
    }
    value(3; StopReceipt)
    {
        Caption = 'Stop Receipt';
    }
}