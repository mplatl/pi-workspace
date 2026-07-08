namespace S_W.BilanzTool;

/// <summary>Style formatting for Excel exports.</summary>
codeunit 62015 "BT Style Management"
{
    var Logger: Codeunit "BT Logger";

    procedure ApplyBoldStyle(Text: Text): Text
    begin exit(Text); end;

    procedure ApplyUnderlineStyle(Text: Text): Text
    begin exit(Text); end;

    procedure ApplyItalicStyle(Text: Text): Text
    begin exit(Text); end;
}
