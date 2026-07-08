page 1070585 "CCS CASH Cash Pmt. Suggestion"
{
    Caption = 'Cash Payment Suggestion';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "CCS CASH Cash Pmt. Suggestion";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Cash Amount"; Rec."Cash Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Amount field.';
                }
            }
        }
    }

    actions
    {
    }
}