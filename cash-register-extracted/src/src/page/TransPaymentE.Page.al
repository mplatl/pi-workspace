page 1070568 "CCS CASH Trans. Payment E."
{
    // POS0029 07.02.17 FS Added Fields "Transaction Type","ReceiptNo","Creation Date","Creation Time","Change Line"

    Caption = 'Trans. Payment Entries';
    DataCaptionFields = "Store No.", "POS Terminal No.", "Transaction No.";
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "CCS CASH Trans. Payment Entry";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction No. field.';
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Type field.';
                }
                field(ReceiptNo; Rec.ReceiptNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field.';
                }
                field("Creation Time"; Rec."Creation Time")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Time field.';
                }
                field("Tender Type"; Rec."Tender Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tender Type field.';
                }
                field("Tender Description"; Rec."Tender Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tender Description field.';
                }
                field("Card No."; Rec."Card No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card No. field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field("Safe Type"; Rec."Safe Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Safe Type field.';
                }
                field("CardNo. Select"; Rec."CardNo. Select")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card No. Select field.';
                }
                field("Change Line"; Rec."Change Line")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Change Line field.';
                }
            }
        }
    }

    actions
    {
    }
}