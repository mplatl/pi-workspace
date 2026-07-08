page 1070554 "CCS CASH Tendertype Cardsetup"
{
    // POS0029 07.02.17 FS Changed Object Caption, Set Field "Diff. Acc. Type" and "Diff. Account" Visible false

    Caption = 'Type Setup';
    DelayedInsert = true;
    PageType = Card;
    PopulateAllFields = true;
    SourceTable = "CCS CASH Tender Type C. Setup";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(Generel)
            {
                field("Card No."; Rec."Card No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card No. field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
            }
            group(Post)
            {
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account Type field.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account No. field.';
                }
                field("Account Description"; Rec."Account Description")
                {
                    ApplicationArea = All;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Account Description field.';
                }
                field("Diff. Acc. Type"; Rec."Diff. Acc. Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Difference Account Type field.';
                }
                field("Diff. Account"; Rec."Diff. Account")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Difference Account field.';
                }
                field("Diff Account Description"; Rec."Diff Account Description")
                {
                    ApplicationArea = All;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Difference Account Description field.';
                }
            }
        }
    }
}