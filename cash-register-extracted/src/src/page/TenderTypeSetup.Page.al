page 1070550 "CCS CASH Tender Type Setup"
{
    AdditionalSearchTerms = 'CASH Tender Type List', Locked = true;
    ApplicationArea = CCSCASH;
    Caption = 'Payment Types List - Cash Register';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "CCS CASH Tender Type Setup";
    UsageCategory = Administration;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Editable = CurrencyEnabled;
                    ToolTip = 'Specifies the value of the Currency Code field.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(TenderFunction; Rec.TenderFunction)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Function field.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        CurrencyEnabled := Rec.TenderFunction = Rec.TenderFunction::Normal;
    end;

    var
        CurrencyEnabled: Boolean;
}