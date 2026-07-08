namespace S_W.BilanzTool;

/// <summary>Filter helpers for G/L data selection.</summary>
codeunit 62019 "BT Filter Management"
{
    var Logger: Codeunit "BT Logger";

    procedure ApplyGLAccountFilter(AccountNo: Code[20]): Text
    begin
        exit('');
    end;

    procedure BuildDateFilter(StartDate: Date; EndDate: Date): Text
    begin
        exit(Format(StartDate) + '..' + Format(EndDate));
    end;
}
