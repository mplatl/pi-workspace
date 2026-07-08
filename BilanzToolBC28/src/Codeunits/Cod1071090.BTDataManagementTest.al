namespace S_W.BilanzTool;

/// <summary>Tests for BT Data Management — core tree calculation.</summary>
codeunit 62021 "BT Data Management Test"
{
    Subtype = Test;

    var
        DataMgt: Codeunit "BT Data Management";
        AccGroupingHdr: Record "BT Acc. Grouping Header";
        AccGrouping: Record "BT Account Grouping";

    [Test]
    procedure TestCalculateTreeEmptyGrouping()
    var
        TempTree: Record "BT Account Grouping" temporary;
    begin
        DataMgt.CalculateTree('NONEXISTENT', 20260630D, TempTree);
        if TempTree.FindFirst() then
            Error('Empty grouping should produce no rows');
    end;

    [Test]
    procedure TestCalculateTreeWithData()
    var
        TempTree: Record "BT Account Grouping" temporary;
    begin
        AccGroupingHdr.Init();
        AccGroupingHdr.Code := 'TEST_BAL';
        AccGroupingHdr.Name := 'Test Balance';
        AccGroupingHdr.Type := AccGroupingHdr.Type::Balance;
        AccGroupingHdr.Insert(true);

        AccGrouping.Init();
        AccGrouping."Grouping Header" := 'TEST_BAL';
        AccGrouping."Node Type" := AccGrouping."Node Type"::"G/L Account";
        AccGrouping."G/L Account No." := '9999';
        AccGrouping.Name := 'Test Account';
        AccGrouping.Insert(true);

        DataMgt.CalculateTree('TEST_BAL', 20260630D, TempTree);

        if not TempTree.FindFirst() then
            Error('Tree should contain nodes');
    end;

    [Test]
    procedure TestCalculateTreeRollup()
    var
        TempTree: Record "BT Account Grouping" temporary;
    begin
        AccGroupingHdr.Init();
        AccGroupingHdr.Code := 'TEST_ROLL';
        AccGroupingHdr.Name := 'Test Rollup';
        AccGroupingHdr.Type := AccGroupingHdr.Type::Balance;
        AccGroupingHdr.Insert(true);

        AccGrouping.Init();
        AccGrouping."Grouping Header" := 'TEST_ROLL';
        AccGrouping."Node Type" := AccGrouping."Node Type"::Total;
        AccGrouping.Name := 'TOTAL';
        AccGrouping.Insert(true);

        AccGrouping.Init();
        AccGrouping."Grouping Header" := 'TEST_ROLL';
        AccGrouping."Node Type" := AccGrouping."Node Type"::"G/L Account";
        AccGrouping."G/L Account No." := '1000';
        AccGrouping.Name := 'Cash';
        AccGrouping.Grouping := 'TOTAL';
        AccGrouping.Insert(true);

        DataMgt.CalculateTree('TEST_ROLL', 20260630D, TempTree);

        TempTree.SetRange("Grouping Header", 'TEST_ROLL');
        if TempTree.Count() < 1 then
            Error('Tree should contain nodes');
    end;
}
