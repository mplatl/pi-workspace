namespace S_W.BilanzTool;

/// <summary>Calculates G/L account amounts via RecordRef.</summary>
codeunit 62017 "BT GlAcc Amount Management"
{
    var
        Logger: Codeunit "BT Logger";
        DateMgt: Codeunit "BT Date Management";

    procedure CalculateAmounts(var Node: Record "BT Account Grouping"; BalanceDate: Date)
    var
        GLEntryRef: RecordRef;
        GLAccField: FieldRef;
        DateField: FieldRef;
        AmountField: FieldRef;
        StartDate: Date;
        EndDate: Date;
        PrevStartDate: Date;
        PrevEndDate: Date;
        Amt: Decimal;
        FieldVal: Decimal;
    begin
        Node."Amt Curr" := 0;
        Node."Amt Prev" := 0;

        if Node."Node Type" <> Node."Node Type"::"G/L Account" then
            exit;
        if Node."G/L Account No." = '' then
            exit;

        GLEntryRef.Open(17);
        GLAccField := GLEntryRef.Field(3);
        DateField := GLEntryRef.Field(5);
        AmountField := GLEntryRef.Field(17);

        // Current period
        StartDate := DateMgt.GetPalStartDate(0);
        EndDate := DateMgt.GetBalanceDate(0);
        DateMgt.GetDatesForNode(Node, StartDate, EndDate);

        GLAccField.SetFilter(Node."G/L Account No.");
        DateField.SetFilter(Format(StartDate) + '..' + Format(EndDate));
        Amt := 0;
        if GLEntryRef.FindSet() then begin
            repeat
                Evaluate(FieldVal, Format(AmountField.Value()));
                Amt += FieldVal;
            until GLEntryRef.Next() = 0;
        end;
        Node."Amt Curr" := Amt;

        if Node."Reverse Sign" then
            Node."Amt Curr" := -Node."Amt Curr";

        // Previous period
        Amt := 0;
        PrevStartDate := DateMgt.GetPalStartDate(-1);
        PrevEndDate := DateMgt.GetBalanceDate(-1);
        DateMgt.GetDatesForNode(Node, PrevStartDate, PrevEndDate);

        GLAccField.SetFilter(Node."G/L Account No.");
        DateField.SetFilter(Format(PrevStartDate) + '..' + Format(PrevEndDate));
        if GLEntryRef.FindSet() then begin
            repeat
                Evaluate(FieldVal, Format(AmountField.Value()));
                Amt += FieldVal;
            until GLEntryRef.Next() = 0;
        end;
        Node."Amt Prev" := Amt;

        if Node."Reverse Sign" then
            Node."Amt Prev" := -Node."Amt Prev";
    end;
}
