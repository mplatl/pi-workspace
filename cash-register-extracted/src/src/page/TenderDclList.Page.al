page 1070572 "CCS CASH Tender Dcl. List"
{
    Caption = 'Tender Operation';
    DataCaptionFields = "Store No.", "POS Terminal No.", "Transaction No.";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ObsoleteReason = 'Not used';
    ObsoleteState = Pending;
    ObsoleteTag = 'CCS CASH 22.0.10.0';
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "CCS CASH Trans. Tender Dcl. E.";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Tender Type"; Rec."Tender Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tender Type field.';
                }
                field("Card No."; Rec."Card No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Card No. field.';
                }
                field("Tender Type Text"; Rec."Tender Type Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tender Type field.';
                }
                field("Bank Amount"; Rec."Bank Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bank Amount field.';
                }
                field("Fixed Amount"; Rec."Fixed Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Counted field.';
                }
                field("Cash Amount"; Rec."Cash Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Amount field.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Amount field.';
                }
                field("Diff. Amount"; Rec."Diff. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Difference Amount field.';
                }
            }
        }
    }
}