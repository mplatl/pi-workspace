namespace S_W.BilanzTool;

/// <summary>Account grouping node type.</summary>
enum 62061 "BT Node Type"
{
    Extensible = false;
    value(0; " ") { Caption = ' '; }
    value(1; "G/L Account") { Caption = 'G/L Account'; }
    value(2; Formula) { Caption = 'Formula'; }
    value(3; Total) { Caption = 'Total'; }
    value(4; Text) { Caption = 'Text'; }
}
