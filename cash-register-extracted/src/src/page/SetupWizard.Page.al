page 1070586 "CCS CASH Setup Wizard"
{
    ApplicationArea = All;
    Caption = 'Setup Wizard - Cash Register';
    PageType = NavigatePage;
    SourceTable = "CCS CASH Cash Sales Setup";
    UsageCategory = None; //Wizard not ready yet

    layout
    {
        area(Content)
        {
            group(Step1)
            {
                Caption = 'Store';
                InstructionalText = 'Provide store information';
                Visible = CurrentStep = 1;

                field(Store_Name; Store.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field(Store_Address; Store.Address)
                {
                    ApplicationArea = All;
                    Caption = 'Address';
                    ToolTip = 'Specifies the value of the Address field.';
                }
                field(Store_PostCode; Store."Post Code")
                {
                    ApplicationArea = All;
                    Caption = 'Post Code';
                    ToolTip = 'Specifies the value of the Post Code field.';
                }

                field(Store_Email; Store."E-Mail")
                {
                    ApplicationArea = All;
                    Caption = 'E-mail';
                    ToolTip = 'Specifies the value of the E-mail field.';
                }

                field(Store_Homepage; Store."Home Page")
                {
                    ApplicationArea = All;
                    Caption = 'Homepage';
                    ToolTip = 'Specifies the value of the Homepage field.';
                }
                field(Store_PhoneNo; Store."Phone No.")
                {
                    ApplicationArea = All;
                    Caption = 'Phone No.';
                    ToolTip = 'Specifies the value of the Phone No. field.';
                }
            }
            group(Step2)
            {
                Caption = 'Cash Register';
                InstructionalText = 'Provide Cash Register information';
                Visible = CurrentStep = 2;

                field(Terminal_Desc; Terminal.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Terminal_ReceiptNos; Terminal."Receipt Nos.")
                {
                    ApplicationArea = All;
                    Caption = 'POS Receipt No. Series';
                    ToolTip = 'Specifies the value of the POS Receipt No. Series field.';
                }
                field(Terminal_PostedReceiptNos; Terminal."Posted Receipt Nos.")
                {
                    ApplicationArea = All;
                    Caption = 'Posted POS Receipt No. Series';
                    ToolTip = 'Specifies the value of the Posted POS Receipt No. Series field.';
                }
            }

            group(Step3)
            {
                Caption = 'Retail user';
                InstructionalText = 'Provide retail user information';
                Visible = CurrentStep = 3;
                field(Staff_ID; Staff.ID)
                {
                    ApplicationArea = All;
                    Caption = 'ID';
                    ToolTip = 'Specifies the value of the ID field.';
                }
                field(Staff_Name; Staff.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field(Staff_NameReceipt; Staff."Name on Receipt")
                {
                    ApplicationArea = All;
                    Caption = 'Name on receipt';
                    ToolTip = 'Specifies the value of the Name on receipt field.';
                }
                field(Staff_Password; StaffPassword)
                {
                    ApplicationArea = All;
                    Caption = 'Password';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Password field.';
                    trigger OnValidate()
                    begin
                        Staff.SetStaffNewPassword(StaffPassword);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = ActionBackAllowed;
                Image = PreviousRecord;
                InFooterBar = true;
                ToolTip = 'Executes the Back action.';
                trigger OnAction()
                begin
                    TakeStep(-1);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = ActionNextAllowed;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Executes the Next action.';
                trigger OnAction()
                begin
                    TakeStep(1);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = ActionFinishAllowed;
                Image = Approve;
                InFooterBar = true;
                ToolTip = 'Executes the Finish action.';
                trigger OnAction()
                begin
                    InsertPageWizardValues();
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        CurrentStep: Integer;
        ActionBackAllowed: boolean;
        ActionNextAllowed: boolean;
        ActionFinishAllowed: boolean;
        [NonDebuggable]
        StaffPassword: Text[2048];

        Store: Record "CCS CASH Store";
        Terminal: Record "CCS CASH POS Terminal";
        Staff: Record "CCS CASH Staff";


    local procedure SetControls()
    begin
        ActionBackAllowed := CurrentStep > 1;
        ActionNextAllowed := CurrentStep < 3;
        ActionFinishAllowed := CurrentStep = 3;
    end;

    local procedure TakeStep(Step: Integer)
    begin
        CurrentStep += Step;
        SetControls();
    end;

    trigger OnOpenPage()
    begin
        CurrentStep := 1;
        SetControls();
    end;

    local procedure InsertPageWizardValues()
    var
        RetailUser: Record "CCS CASH Retail User";
    begin
#pragma warning disable AA0205
        Store.Insert(true);

        Terminal."Store No" := Store."No.";
        Terminal.Insert(true);

        Staff.Insert(true);
#pragma warning restore AA0205

        RetailUser.Init();
        RetailUser.Validate("Store No", Store."No.");
        RetailUser.Validate("Staff ID", Staff.ID);
        RetailUser.Validate("POS Terminal No.", Terminal."No.");
        RetailUser.Insert(true);
    end;
}