page 1070548 "CCS CASH Staff -  POS Terminal"
{
    Caption = 'Staff - POS Terminal';
    DelayedInsert = true;
    PageType = ListPart;
    PopulateAllFields = true;
    SourceTable = "CCS CASH Retail User";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Staff ID"; Rec."Staff ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Staff ID field.';
                }
                field("Cashier Name"; Rec."Cashier Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cashier Name field.';
                }
                field("Store No"; Rec."Store No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store No. field.';
                }
                field("Store Name"; Rec."Store Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Name field.';
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Terminal No. field.';
                }
                field("POS Description"; Rec."POS Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Description field.';
                }
            }
        }
    }

    actions
    {
    }
}