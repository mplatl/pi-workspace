page 1070546 "CCS CASH Staff Card"
{
    Caption = 'Cashier Card';
    PageType = Card;
    SourceTable = "CCS CASH Staff";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ID field.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit() then
                            CurrPage.Update();
                    end;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Name 2"; Rec."Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name 2 field.';
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
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field.';
                }
            }
            group(Personal)
            {
                Caption = 'Personal';
                field(Password; StaffPassword)
                {
                    ApplicationArea = All;
                    Caption = 'Password';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Password field.';

                    trigger OnValidate()
                    begin
                        if Rec.GeStaffPassword() <> StaffPassword then
                            if (StaffPassword = '') then begin
                                if not Confirm(Text003, false) then
                                    Error('')
                                else
                                    Rec.SetStaffNewPassword(StaffPassword);
                            end else
                                NeedPWRetype := true;
                    end;
                }
                field(PasswordTest; PasswordTest)
                {
                    ApplicationArea = All;
                    Caption = 'Retype Password';
                    Editable = NeedPWRetype;
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Retype Password field.';

                    trigger OnValidate()
                    begin
                        if PasswordTest = StaffPassword then begin
                            NeedPWRetype := false;
                            Rec.SetStaffNewPassword(StaffPassword);
                            CurrPage.Update(true);
                        end else
                            Error(Text001);
                    end;
                }
                field("Max Disc. per Transaction"; Rec."Max Disc. per Transaction")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Maximum Invoice Discount field.';
                }
                field("Max. Cash Amt. Diff %"; Rec."Max. Cash Amt. Diff %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Maximum Cash Amount Difference % field.';
                }
                field("Max Cash Amt. Diff."; Rec."Max Cash Amt. Diff.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Maximum Cash Amount Difference field.';
                }
                field("Price Change allowed"; Rec."Price Change allowed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price Change allowed field.';
                }
                field("Returns allowed"; Rec."Returns allowed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Returns allowed field.';
                }
                field("Expenses allowed"; Rec."Expenses allowed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Expenses allowed field.';
                }
                field("Deposits allowed"; Rec."Deposits allowed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deposits allowed field.';
                }
                field("Remaining Pmt. Disc. allowed"; Rec."Remaining Pmt. Disc. allowed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enables changing the Remaining Payment Discounts in Customer Payment transactions.';
                }
            }
            part("POS Terminals"; "CCS CASH Staff -  POS Terminal")
            {
                ApplicationArea = All;
                Caption = 'POS Terminals';
                SubPageLink = "Staff ID" = FIELD(ID);
            }
        }
    }

    actions
    {
    }

    trigger OnModifyRecord(): Boolean
    begin
        if NeedPWRetype then
            Error(Text002);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if NeedPWRetype then begin
            Message(Text002);
            exit(false)
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        StaffPassword := Rec.GeStaffPassword();
    end;

    var
        [NonDebuggable]
        PasswordTest, StaffPassword : Text[2048];
        NeedPWRetype: Boolean;
        Text001: Label 'Passwords do not match';
        Text002: Label 'Type in your password again';
        Text003: Label 'The password has been deleted. Do you want to set a new password?';
}