namespace S_W.BilanzTool;

/// <summary>BilanzTool Setup Card.</summary>
page 62033 "BT Setup Card"
{
    Caption = 'BilanzTool Setup';
    PageType = Card;
    SourceTable = "BT Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';
                field("Default Balance Grouping"; Rec."Default Balance Grouping") { ApplicationArea = All; }
                field("Default PL Grouping"; Rec."Default PL Grouping") { ApplicationArea = All; }
                field("Default Cashflow Grouping"; Rec."Default Cashflow Grouping") { ApplicationArea = All; }
                field("Retained Earnings Acc."; Rec."Retained Earnings Acc.") { ApplicationArea = All; }
                field("Default Depr. Book"; Rec."Default Depr. Book") { ApplicationArea = All; }
            }
            group(Journal)
            {
                Caption = 'Journal Settings';
                field("Gen. Journal Template"; Rec."Gen. Journal Template") { ApplicationArea = All; }
                field("Gen. Journal Batch"; Rec."Gen. Journal Batch") { ApplicationArea = All; }
            }
            group(Word)
            {
                Caption = 'Word Templates';
                field("Default Word Template Code"; Rec."Default Word Template Code") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SetupWizard)
            {
                Caption = 'Setup Wizard';
                ApplicationArea = All;
                RunObject = Page "BT Setup Wizard";
            }
        }
    }
}
