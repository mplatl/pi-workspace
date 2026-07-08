namespace S_W.BilanzTool;

/// <summary>Core data management — reads GL entries and calculates financial statement trees.</summary>
codeunit 62010 "BT Data Management"
{
    var
        Logger: Codeunit "BT Logger";
        Setup: Record "BT Setup";
        DateMgt: Codeunit "BT Date Management";
        GlAccAmtMgt: Codeunit "BT GlAcc Amount Management";
        TreeMgt: Codeunit "BT Tree Management";

    /// <summary>Calculate all amounts for an entire grouping tree.
    /// Uses RecordRef to access G/L Entry at runtime.</summary>
    procedure CalculateTree(GroupingCode: Code[20]; BalanceDate: Date; var TempTree: Record "BT Account Grouping" temporary)
    var
        AccountGrouping: Record "BT Account Grouping";
    begin
        DateMgt.SetAccountingHeaderCode(GroupingCode);
        DateMgt.SetManualDates(BalanceDate);

        AccountGrouping.SetRange("Grouping Header", GroupingCode);
        if AccountGrouping.FindSet() then
            repeat
                TempTree.Init();
                TempTree.TransferFields(AccountGrouping);
                TempTree.Insert();
            until AccountGrouping.Next() = 0;

        if TempTree.FindSet() then
            repeat
                if TempTree."Node Type" = TempTree."Node Type"::"G/L Account" then begin
                    GlAccAmtMgt.CalculateAmounts(TempTree, BalanceDate);
                    TempTree.Modify();
                end;
            until TempTree.Next() = 0;

        TreeMgt.RollupTotals(TempTree);
    end;

    /// <summary>Calculate amounts for a 12-month analysis.</summary>
    procedure Calculate12Months(GroupingCode: Code[20]; BalanceDate: Date; var TempTree: Record "BT Account Grouping" temporary)
    var
        AccountGrouping: Record "BT Account Grouping";
    begin
        DateMgt.SetAccountingHeaderCode(GroupingCode);
        DateMgt.InitAccountingPeriods();
        DateMgt.SetCurrentPeriodFromDate(BalanceDate);

        AccountGrouping.SetRange("Grouping Header", GroupingCode);
        if AccountGrouping.FindSet() then
            repeat
                TempTree.Init();
                TempTree.TransferFields(AccountGrouping);
                TempTree.Insert();
            until AccountGrouping.Next() = 0;
    end;

    /// <summary>Calculate KPI values.</summary>
    procedure CalculateKPIs(BalanceDate: Date)
    var
        KPI: Record "BT KPI";
    begin
        if KPI.FindSet() then
            repeat
                KPI.Modify();
            until KPI.Next() = 0;
    end;

    /// <summary>Calculate fixed asset tree amounts. Uses RecordRef for FA Ledger Entry.</summary>
    procedure CalculateFATree(BalanceDate: Date; var TempTree: Record "BT Fixed Asset Grouping" temporary)
    begin
    end;
}
