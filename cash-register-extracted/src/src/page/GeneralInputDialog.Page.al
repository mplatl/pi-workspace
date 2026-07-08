page 1070597 "CCS CASH General Input Dialog"
{
    ApplicationArea = CCSCASH;
    PageType = Card;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(inputDate; inputDate)
                {
                    ApplicationArea = All;
                    Caption = 'Input Date';
                    ToolTip = 'Specifies the value of the Input Date field.';
                }
            }
        }
    }

    actions
    {
    }

    var
        inputDate: Date;

    internal procedure getInputDate(): Date

    begin
        exit(inputDate);
    end;
}