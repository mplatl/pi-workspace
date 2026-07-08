page 1070569 "CCS CASH Trans. Tender Dcl. E."
{
    Caption = 'Cash Decl. Entries';
    DataCaptionFields = "Store No.", "POS Terminal No.", "Transaction No.";
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "CCS CASH Trans. Cash Decl. E.";
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
                field("Decl. Key"; Rec."Decl. Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Declaration Key field.';
                }
                field("Tender Type"; Rec."Tender Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tender Type field.';
                }
                field("Card No."; Rec."Card No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card No. field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field.';
                }
                field("Base Amount"; Rec."Base Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Base Amount field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field.';
                }
                field("Creation Time"; Rec."Creation Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Creation Time field.';
                }
                field("Staff ID"; Rec."Staff ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Staff ID field.';
                }
            }
        }
    }

    actions
    {
    }
}