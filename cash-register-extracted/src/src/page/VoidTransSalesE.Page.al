page 1070574 "CCS CASH Void Trans. Sales E."
{
    Caption = 'Void Sales Entries';
    DataCaptionFields = "Store No.", "POS Terminal No.", "Transaction No.";
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "CCS CASH Trans Sales E. Voided";
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
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Variant Code field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field.';
                }
                field("Unit Price incl. VAT"; Rec."Unit Price incl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price incl. VAT field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field("Amount incl. VAT"; Rec."Amount incl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount incl. VAT field.';
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Amount field.';
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the VAT % field.';
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
                field("Gen. Prod.Posting Group"; Rec."Gen. Prod.Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the General Product Posting Group field.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the VAT Product Posting Group field.';
                }
            }
        }
    }

    actions
    {
    }
}