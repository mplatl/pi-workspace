page 1070549 "CCS CASH Store Terminals"
{
    Caption = 'POS Terminals';
    DelayedInsert = true;
    Editable = true;
    PageType = ListPart;
    PopulateAllFields = true;
    SourceTable = "CCS CASH POS Terminal";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store No"; Rec."Store No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store No. field.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Terminal No. field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Balance at Date"; Rec."Balance at Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balance at Date field.';
                }
                field("Last Z-Report"; Rec."Last Z-Report")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Z-Report field.';
                }
            }
        }
    }

    actions
    {
    }
}