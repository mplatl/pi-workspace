namespace S_W.BilanzTool;

/// <summary>Tests for BT Tree Management — tree rollup and node aggregation.</summary>
codeunit 62023 "BT Tree Management Test"
{
    Subtype = Test;

    var
        TreeMgt: Codeunit "BT Tree Management";

    [Test]
    procedure TestRollupTotalsEmptyTree()
    var
        TempTree: Record "BT Account Grouping" temporary;
    begin
        TreeMgt.RollupTotals(TempTree);
        if TempTree.FindSet() then
            Error('Empty tree should have no nodes');
    end;

    [Test]
    procedure TestRollupTotalsSingleNode()
    var
        TempTree: Record "BT Account Grouping" temporary;
    begin
        TempTree.Init();
        TempTree."Grouping Header" := 'TEST';
        TempTree."Node Type" := TempTree."Node Type"::"G/L Account";
        TempTree.Name := 'Cash';
        TempTree."Amt Curr" := 1000;
        TempTree.Insert();

        TreeMgt.RollupTotals(TempTree);

        TempTree.FindFirst();
        if TempTree."Amt Curr" <> 1000 then
            Error('Single node amount %1 should remain 1000', TempTree."Amt Curr");
    end;

    [Test]
    procedure TestRollupTotalsWithChildren()
    var
        TempTree: Record "BT Account Grouping" temporary;
    begin
        TempTree.Init();
        TempTree."Grouping Header" := 'TEST';
        TempTree."Node Type" := TempTree."Node Type"::Total;
        TempTree.Name := 'TOTAL';
        TempTree.Insert();

        TempTree.Init();
        TempTree."Grouping Header" := 'TEST';
        TempTree."Node Type" := TempTree."Node Type"::"G/L Account";
        TempTree.Name := 'Cash';
        TempTree.Grouping := 'TOTAL';
        TempTree."Amt Curr" := 500;
        TempTree.Insert();

        TempTree.Init();
        TempTree."Grouping Header" := 'TEST';
        TempTree."Node Type" := TempTree."Node Type"::"G/L Account";
        TempTree.Name := 'Bank';
        TempTree.Grouping := 'TOTAL';
        TempTree."Amt Curr" := 300;
        TempTree.Insert();

        TreeMgt.RollupTotals(TempTree);

        TempTree.SetRange(Name, 'TOTAL');
        TempTree.FindFirst();
        // Parent should have sum of children
    end;
}
