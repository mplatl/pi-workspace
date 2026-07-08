namespace S_W.BilanzTool;

report 62052 "BT Export Balance"
{
    Caption = 'Export Balance to Excel';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;
    UseRequestPage = true;

    dataset { }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(BalanceDate; BalanceDate) { Caption = 'Balance Date'; ApplicationArea = All; }
                    field(GroupingCode; GroupingCode)
                    {
                        Caption = 'Grouping';
                        ApplicationArea = All;
                        TableRelation = "BT Acc. Grouping Header".Code where (Type = const(Balance));
                    }
                    field(IncludePL; IncludePL) { Caption = 'Include P&L'; ApplicationArea = All; }
                }
            }
        }
    }

    var
        BalanceDate: Date;
        GroupingCode: Code[10];
        IncludePL: Boolean;

    trigger OnPreReport()
    var
        ExcelExport: Codeunit "BT Excel Export";
    begin
        ExcelExport.DownloadBalanceExcel(BalanceDate, GroupingCode);
    end;
}
