namespace S_W.BilanzTool;

/// <summary>Account Grouping Worksheet — edit financial statement structures.</summary>
page 62030 "BT Account Grouping"
{
    Caption = 'Account Grouping';
    PageType = Worksheet;
    SourceTable = "BT Account Grouping";
    SourceTableView = sorting(Grouping);
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                field(Grouping; Rec.Grouping) { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field("G/L Account No."; Rec."G/L Account No.") { ApplicationArea = All; }
                field("Node Type"; Rec."Node Type") { ApplicationArea = All; }
                field("Numbering Type"; Rec."Numbering Type") { ApplicationArea = All; }
                field("Balancing Type"; Rec."Balancing Type") { ApplicationArea = All; }
                field("Thereof Grouping"; Rec."Thereof Grouping") { ApplicationArea = All; }
                field("Reverse Sign"; Rec."Reverse Sign") { ApplicationArea = All; }
                field("Amt Curr"; Rec."Amt Curr") { ApplicationArea = All; }
                field("Amt Prev"; Rec."Amt Prev") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DrillDown)
            {
                Caption = 'G/L Entries';
                Image = Navigate;
                ApplicationArea = All;
            }
            action(NewLine)
            {
                Caption = 'New Line';
                Image = NewDocument;
                ApplicationArea = All;
            }
        }
    }
}
