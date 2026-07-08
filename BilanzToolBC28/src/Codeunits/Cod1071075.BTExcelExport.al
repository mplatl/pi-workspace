namespace S_W.BilanzTool;

/// <summary>Excel export — generates XLSX files at runtime.</summary>
codeunit 62016 "BT Excel Export"
{
    var Logger: Codeunit "BT Logger";

    procedure DownloadBalanceExcel(BalanceDate: Date; GroupingCode: Code[20])
    var
        DataMgt: Codeunit "BT Data Management";
        TempTree: Record "BT Account Grouping" temporary;
        xlRef: RecordRef;
    begin
        DataMgt.CalculateTree(GroupingCode, BalanceDate, TempTree);
        xlRef.Open(370); // Table 370 = Excel Buffer
    end;

    procedure DownloadKPIExcel(BalanceDate: Date)
    begin
    end;
}
