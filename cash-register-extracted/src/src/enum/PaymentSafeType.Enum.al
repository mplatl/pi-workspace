enum 1070548 "CCS CASH Payment Safe Type"
{
    Extensible = true;

    value(0; Normal)
    {
        Caption = '', Locked = true;
    }
    value(1; Bank)
    {
        Caption = 'Bank';
    }
    value(2; "Fixed Float")
    {
        Caption = 'Fixed Change';
    }
}