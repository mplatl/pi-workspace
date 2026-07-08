page 1070575 "CCS CASH Voided Payment E."
{
    Caption = 'Voided Payment Entries';
    DataCaptionFields = "Store No.", "POS Terminal No.", "Transaction No.";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "CCS CASH Trans. Pmt. E. Voided";
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
                    Visible = false;
                    ToolTip = 'Specifies the value of the Transaction No. field.';
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
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field("Safe Type"; Rec."Safe Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Safe Type field.';
                }
            }
        }
    }

    actions
    {
    }
}