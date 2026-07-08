namespace S_W.BilanzTool;

/// <summary>Tests for BT GlAcc Amount Management — G/L entry amount calculation.</summary>
codeunit 62022 "BT GlAcc Amount Mgt. Test"
{
    Subtype = Test;

    var
        GlAccAmtMgt: Codeunit "BT GlAcc Amount Management";

    [Test]
    procedure TestCalculateAmountsNonGLAccount()
    var
        Node: Record "BT Account Grouping";
    begin
        Node.Init();
        Node."Node Type" := Node."Node Type"::Total;
        Node."G/L Account No." := '1000';

        GlAccAmtMgt.CalculateAmounts(Node, 20260630D);

        if Node."Amt Curr" <> 0 then
            Error('Non-GL node should not get amounts');
    end;

    [Test]
    procedure TestCalculateAmountsEmptyAccount()
    var
        Node: Record "BT Account Grouping";
    begin
        Node.Init();
        Node."Node Type" := Node."Node Type"::"G/L Account";
        Node."G/L Account No." := '';

        GlAccAmtMgt.CalculateAmounts(Node, 20260630D);

        if Node."Amt Curr" <> 0 then
            Error('Empty account should not get amounts');
    end;

    [Test]
    procedure TestCalculateAmountsValidAccount()
    var
        Node: Record "BT Account Grouping";
    begin
        Node.Init();
        Node."Node Type" := Node."Node Type"::"G/L Account";
        Node."G/L Account No." := '1000';

        GlAccAmtMgt.CalculateAmounts(Node, 20260630D);
        // In a test environment with no G/L data, amount should be 0
        // The test simply verifies no runtime error occurs
    end;
}
