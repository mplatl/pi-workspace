namespace S_W.BilanzTool;

/// <summary>Financial statement type.</summary>
enum 62060 "BT Statement Type"
{
    Extensible = false;
    value(0; " ") { Caption = ' '; }
    value(1; Balance) { Caption = 'Balance'; }
    value(2; PL) { Caption = 'Profit and Loss'; }
    value(3; Cashflow) { Caption = 'Cashflow'; }
}
