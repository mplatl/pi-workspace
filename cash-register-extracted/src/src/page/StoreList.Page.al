page 1070541 "CCS CASH Store List"
{
    AdditionalSearchTerms = 'CASH Stores', Locked = true;
    ApplicationArea = CCSCASH;
    Caption = 'Stores - Cash Register';
    CardPageID = "CCS CASH Store Card";
    Editable = false;
    PageType = List;
    SourceTable = "CCS CASH Store";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store No. field.';
                }
                field("Respons. Center Code"; Rec."Respons. Center Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Responsibility Center Code field.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Tender Type Management")
            {
                Visible = false;
            }
        }
        area(Processing)
        {
                action("Tender Types")
                {
                    ApplicationArea = All;
                    Caption = 'Payment Types Setup';
                    Image = CashFlowSetup;
                    RunObject = Page "CCS CASH Tender Type List";
                    RunPageLink = "Store No" = FIELD("No.");
                    ToolTip = 'Opens the Payment Types Setup page.';
                }
                action("Cash Declaration Setup")
                {
                    ApplicationArea = All;
                    Caption = 'Tender Operation Setup';
                    Image = CashFlowSetup;
                    RunObject = Page "CCS CASH Cash Decl. Setup";
                    RunPageLink = "Store No." = FIELD("No.");
                    ToolTip = 'Opens the Tender Operation Setup page.';
                }
                action("Copy Tender Types")
                {
                    ApplicationArea = All;
                    Caption = 'Copy Payment Types';
                    Image = CopyToTask;
                    RunObject = Report "CCS CASH Copy Tendertypes";
                    ToolTip = 'Copies the Payment Types from one store to another.';
            }
        }
    }
}