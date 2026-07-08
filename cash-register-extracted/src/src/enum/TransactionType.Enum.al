enum 1070545 "CCS CASH Transaction Type"
{
    Extensible = true;

    value(0; Logon)
    {
        Caption = 'Logon';
    }
    value(1; Logoff)
    {
        caption = 'Logoff';
    }
    value(5; Sales)
    {
        caption = 'Sales';
    }
    value(6; Payment)
    {
        caption = 'Payment';
    }
    value(7; Expense)
    {
        caption = 'Expense';
    }
    value(8; Return)
    {
        caption = 'Return';
    }
    value(13; "Remove Tender")
    {
        caption = 'Equalisation Levy';
    }
    value(14; "Float Entry")
    {
        caption = 'Change Entry';
    }
    value(15; "Tender Decl.")
    {
        caption = 'Tender Operation';
    }
    value(16; Startday)
    {
        caption = 'Day Start';
    }
    value(17; EndDay)
    {
        caption = 'Day End';
    }
    value(18; Deposit)
    {
        caption = 'Deposit';
    }
    value(20; "Open Drawer")
    {
        caption = 'Open Drawer';
    }
    value(21; Zero)
    {
        caption = 'Zero';
    }
}