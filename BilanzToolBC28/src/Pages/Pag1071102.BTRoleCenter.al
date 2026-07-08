namespace S_W.BilanzTool;

/// <summary>BilanzTool Role Center.</summary>
page 62037 "BT Role Center"
{
    Caption = 'BilanzTool';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part(Headline; "BT Navigation Pane")
            {
                Caption = '';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Setup)
            {
                Caption = 'Setup';
                Image = Setup;

                action(Groupings)
                {
                    Caption = 'Account Groupings';
                    Image = List;
                    RunObject = Page "BT Grouping Headers";
                }
                action(WordTemplates)
                {
                    Caption = 'Word Templates';
                    Image = Document;
                    RunObject = Page "BT Word Templates";
                }
                action(KPIs)
                {
                    Caption = 'KPIs';
                    Image = Ledger;
                    RunObject = Page "BT KPI List";
                }
                action(AppSetup)
                {
                    Caption = 'BilanzTool Setup';
                    Image = Setup;
                    RunObject = Page "BT Setup Card";
                }
            }
        }
        area(Reporting)
        {
            group(FinancialReports)
            {
                Caption = 'Financial Reports';
                Image = Report;

                action(BalanceSheet)
                {
                    Caption = 'Balance Sheet';
                    Image = Report;
                    RunObject = Report "BT Print Balance";
                }
                action(ProfitLoss)
                {
                    Caption = 'Profit & Loss';
                    Image = Report;
                    RunObject = Report "BT Print PL";
                }
                action(ExportExcel)
                {
                    Caption = 'Export to Excel';
                    Image = Export;
                    RunObject = Report "BT Export Balance";
                }
            }
        }
        area(Embedding)
        {
            action(Groupings2)
            {
                Caption = 'Account Groupings';
                Image = List;
                RunObject = Page "BT Grouping Headers";
            }
            action(Setup2)
            {
                Caption = 'BilanzTool Setup';
                Image = Setup;
                RunObject = Page "BT Setup Card";
            }
        }
    }
}
