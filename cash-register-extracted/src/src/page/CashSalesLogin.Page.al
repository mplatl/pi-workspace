page 1070559 "CCS CASH Cash Sales Login"
{
    Caption = 'Cash Sales Login';
    InstructionalText = 'Test';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(Allgemein)
            {
                Caption = 'General';
                field(MessageText; MessageText)
                {
                    ApplicationArea = All;
                    Caption = 'CASH SALES POS LOGIN';
                    Editable = false;
                    Enabled = false;
                    //Image = Cash;
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'Specifies the value of the CASH SALES POS LOGIN field.';
                }
                field(StaffID; StaffID)
                {
                    ApplicationArea = All;
                    Caption = 'Staff ID';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Staff ID field.';

                    trigger OnValidate()
                    begin
                        UserInput := StaffID <> '';
                        InputComplete();
                    end;
                }
                field(Password; Password)
                {
                    ApplicationArea = All;
                    Caption = 'Password';
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Password field.';

                    trigger OnValidate()
                    begin
                        PasswordInput := Password <> '';
                        InputComplete();
                    end;
                }
                field(StaffName; StaffName)
                {
                    ApplicationArea = All;
                    Caption = 'Staff Name';
                    Enabled = false;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Staff Name field.';
                }
                field(POSTerminalCode; POSTerminalCode)
                {
                    ApplicationArea = All;
                    Caption = 'POS Terminal';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS Terminal field.';
                    TableRelation = "CCS CASH POS Terminal"."No.";

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        POSTerminal.Reset();
                        POSTerminal.MarkedOnly(false);
                        POSTerminal.ClearMarks();
                        if ValidUser then begin
                            RetailUser.Reset();
                            RetailUser.SetRange("Staff ID", StaffID);
                            if RetailUser.FindSet() then
                                repeat
                                    POSTerminal.Get(RetailUser."Store No", RetailUser."POS Terminal No.");
                                    POSTerminal.Mark(true);
                                until RetailUser.Next() = 0;
                            POSTerminal.MarkedOnly(true);
                        end;

                        if ACTION::LookupOK = PAGE.RunModal(0, POSTerminal) then begin
                            Text := POSTerminal."No.";
                            StoreNo := POSTerminal."Store No";
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        POSTermInput := POSTerminalCode <> '';
                        InputComplete();
                    end;
                }
                field(StoreNo; StoreNo)
                {
                    ApplicationArea = All;
                    Caption = 'Store';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Store field.';
                    TableRelation = "CCS CASH Store"."No.";

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CCSCASHStore: Record "CCS CASH Store";
                    begin
                        CCSCASHStore.Reset();
                        if ValidUser then begin
                            RetailUser.SetRange("Staff ID", StaffID);
                            if POSTerminalCode <> '' then
                                RetailUser.SetRange("POS Terminal No.", POSTerminalCode);
                            if RetailUser.FindSet() then
                                repeat
                                    CCSCASHStore.Get(RetailUser."Store No");
                                    CCSCASHStore.Mark(true);
                                until RetailUser.Next() = 0;
                            CCSCASHStore.MarkedOnly(true);
                        end;

                        if ACTION::LookupOK = PAGE.RunModal(0, CCSCASHStore) then begin
                            Text := CCSCASHStore."No.";
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        POSTermInput := POSTerminalCode <> '';
                        InputComplete();
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        MessageText := Text002;
        CurrPage.LookupMode(true);
    end;

    var
        Text001: Label 'Invalid / Misentry';
        Staff: Record "CCS CASH Staff";
        RetailUser: Record "CCS CASH Retail User";
        POSTerminal: Record "CCS CASH POS Terminal";
        StaffID: Code[20];
        StoreNo: Code[20];
        POSTerminalCode: Code[20];
        [NonDebuggable]
        Password: Text[50];
        StaffName: Text[100];
        ValidUser: Boolean;
        MessageText: Text;
        Text002: Label 'Enter credentials and POS Terminal';
        Text003: Label 'Staff ID or Password wrong';
        Text004: Label 'No valid POS';
        UserInput: Boolean;
        PasswordInput: Boolean;
        POSTermInput: Boolean;
        Text005: Label 'Staff %1 Blocked', Comment = '%1=Value 1';

    local procedure Errormsg(MsgText: Text[80])
    begin
        Clear(UserInput);
        Clear(PasswordInput);
        Clear(POSTermInput);
        Clear(POSTerminalCode);
        Clear(StoreNo);
        Clear(StaffID);
        Clear(Password);
        Clear(ValidUser);
        Staff.Reset();
        Clear(Staff);
        RetailUser.Reset();
        Clear(RetailUser);
        POSTerminal.Reset();
        Clear(POSTerminal);

        if MsgText = '' then
            MessageText := Text001
        else
            MessageText := MsgText;

        CurrPage.Update(false);
    end;

    internal procedure GetStaffSetup(var pRetailuser: Record "CCS CASH Retail User"): Boolean
    begin
        pRetailuser := RetailUser;
        exit(ValidUser);
    end;

    internal procedure GetExitMode(): Boolean
    begin
        exit(UserInput and PasswordInput and POSTermInput);
    end;

    local procedure InputComplete()
    var
        UserOK: Boolean;
        Msg: Text;
        [NonDebuggable]
        StaffPassword : Text;
    //PageClosed: Boolean;
    begin
        StaffName := '';
        //PageClosed := false;
        if UserInput then begin
            if not Staff.Get(StaffID) then begin
                if PasswordInput then
                    Errormsg(Text003);
            end else begin 
                //++POS0029
                //UserOK := (Staff.Password + Password = '') OR (Password = Staff.Password);
                StaffPassword := Staff.GeStaffPassword();
                UserOK := ((StaffPassword + Password = '') or (Password = StaffPassword)) and not Staff.Blocked;
            end;
            //--POS0029
            if UserOK then begin
                StaffName := Staff.Name;
                PasswordInput := true;
                POSTerminal.Reset();
                POSTerminal.MarkedOnly(false);
                POSTerminal.ClearMarks();
                RetailUser.SetRange("Staff ID", StaffID);
                ValidUser := true;
                if POSTerminalCode <> '' then begin
                    if StoreNo <> '' then
                        RetailUser.SetRange("Store No", StoreNo);
                    RetailUser.SetRange("POS Terminal No.", POSTerminalCode);
                    if RetailUser.FindFirst() then begin
                        StoreNo := RetailUser."Store No";
                        //CurrPage.Close();
                        //PageClosed := true;
                    end;
                end else begin
                    if not RetailUser.Find('-') then
                        Errormsg(Text004)
                    else begin
                        if RetailUser.Count = 1 then begin
                            POSTerminalCode := RetailUser."POS Terminal No.";
                            StoreNo := RetailUser."Store No";
                            POSTermInput := true;
                            //CurrPage.Close();
                            //PageClosed := true;
                        end;
                    end;
                end;
            end else
                if PasswordInput then
                    Errormsg(Text003);
            // + POS0007
            //++POS0029
            if Staff.Blocked then begin
                Msg := StrSubstNo(Text005, Staff.ID);
                Clear(Staff);
                Clear(StaffID);
                Error(Msg);
            end;
            //--POS0029
            // - POS0007
        end;
        //IF NOT PageClosed then
        //    CurrPage.Update(false);
    end;
}