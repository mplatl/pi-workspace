namespace S_W.BilanzTool;

enum 62062 "BT Numbering Type"
{
    Extensible = false;
    value(0; " ") { Caption = ' '; }
    value(1; "A-Z") { Caption = 'A. - Z.'; }
    value(2; Roman) { Caption = 'I. - V.'; }
    value(3; Numeric) { Caption = '1. - 9.'; }
    value(4; Lowercase) { Caption = 'a. - z.'; }
    value(5; Manual) { Caption = 'Manual'; }
}
