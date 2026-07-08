page 1070545 "CCS CASH Staff"
{
    AdditionalSearchTerms = 'CASH Cashier', Locked = true;
    ApplicationArea = CCSCASH;
    Caption = 'Cashier - Cash Register';
    CardPageID = "CCS CASH Staff Card";
    Editable = false;
    PageType = List;
    SourceTable = "CCS CASH Staff";
    UsageCategory = Administration;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ID field.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field.';
                }
                field("Short Code"; Rec."Short Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Short Code field.';
                }
                field("Name on Receipt"; Rec."Name on Receipt")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name on Receipt field.';
                }
            }
        }
    }

    actions
    {
    }
}