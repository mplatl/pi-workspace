namespace S_W.BilanzTool;

report 62050 "BT Print Balance"
{
    Caption = 'Balance Sheet';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(GroupingHdr; "BT Acc. Grouping Header")
        {
            column(HdrCode; Code) { }
            column(HdrName; Name) { }

            dataitem(Node; "BT Account Grouping")
            {
                DataItemLink = "Grouping Header" = field("Code");
                DataItemLinkReference = GroupingHdr;
                column(NodeGrouping; Grouping) { }
                column(NodeName; Name) { }
                column(NodeAmtCurr; "Amt Curr") { }
                column(NodeAmtPrev; "Amt Prev") { }
                column(NodeNodeType; "Node Type") { }
            }

            trigger OnPreDataItem()
            begin
                SetRange(Type, Type::Balance);
            end;
        }
    }

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
                }
            }
        }
    }

    var
        BalanceDate: Date;
        GroupingCode: Code[10];
}
