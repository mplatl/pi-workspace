page 1070551 "CCS CASH Tender Type List"
{
    // POS0029 07.02.17 Added Field "Currency Code", Field TenderFunction Visible false

    Caption = 'Payment Types Setup';
    CardPageID = "CCS CASH Store Tender Type C.";
    DelayedInsert = true;
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "CCS CASH Store Tender Type";
    UsageCategory = None;

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
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field(TenderFunction; Rec.TenderFunction)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Function field.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Usable; Rec.Usable)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the May be Used field.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Tender Types")
            {
                action("Card Setup")//TODO Remove action
                {
                    ApplicationArea = All;
                    Caption = 'Card Setup';
                    Image = Setup;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    RunObject = Page "CCS CASH Tendertype Cardsetup";
                    RunPageLink = "Store No" = FIELD("Store No"), "Tender Type" = FIELD(Code);
                    ToolTip = 'Executes the Card Setup action.';
                    Visible = false;
                }
            }
        }
    }
}