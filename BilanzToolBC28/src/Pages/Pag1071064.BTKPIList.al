namespace S_W.BilanzTool;

/// <summary>KPI List.</summary>
page 62032 "BT KPI List"
{
    Caption = 'KPIs';
    PageType = List;
    SourceTable = "BT KPI";
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field(Formula; Rec.Formula) { ApplicationArea = All; }
                field("Reverse Sign"; Rec."Reverse Sign") { ApplicationArea = All; }
                field(Amount1; Rec.Amount1) { ApplicationArea = All; }
                field(Amount2; Rec.Amount2) { ApplicationArea = All; }
            }
        }
    }
}
