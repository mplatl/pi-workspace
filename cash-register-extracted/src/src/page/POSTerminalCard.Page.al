page 1070544 "CCS CASH POS Terminal Card"
{
    // POS0025 17.01.17 MK Added Functionality for Zero-Amount Receipt (But not visible)
    // POS0029 07.02.17 FS Added Start-/Stop Receipt Functionality
    // EFSTA2.03  06.02.2017 MK Changed Code because of different Zero Receipt Types

    Caption = 'POS Terminal';
    DelayedInsert = true;
    PageType = Card;
    PopulateAllFields = true;
    SourceTable = "CCS CASH POS Terminal";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Store No"; Rec."Store No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store No. field.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Terminal No. field.';
                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit() then
                            CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Balance at Date"; Rec."Balance at Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balance at Date field.';
                }
                field("Open in Session"; Rec."Open in Session")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Open in Session field.';
                }
                field("Cash Drawer Connection Code"; Rec."Cash Drawer Connection Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the COSMO Core Library AT setup to open the cash drawer. AzureServiceBus Relay is required.';
                }
                field("Open Cash Drawer Automatic"; Rec."Open Cash Drawer Automatic")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open Cash Drawer Automatic field.';
                }
                field("Open Cash Drawer After Post"; Rec."Open Cash Drawer After Post")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open Cash Drawer Automatic after Post field.';
                }
            }
            group(Default)
            {
                Caption = 'Default Setup';
                field("Default Customer at POS"; Rec."Default Customer at POS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Customer at POS field.';
                }
                field("Default Qty. at POS"; Rec."Default Qty. at POS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Quantity on POS field.';
                }
                field("Daily Statement necessary"; Rec."Daily Statement necessary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Daily Statement necessary field.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field.';
                }
            }
            group("No.Series")
            {
                Caption = 'No. Series';
                field("Receipt Nos."; Rec."Receipt Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Receipt No. Series field.';
                }
                field("Posted Receipt Nos."; Rec."Posted Receipt Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posted POS Receipt No. Series field.';
                }
            }
            group("BMF Signierung")
            {
                Caption = 'Auth. Signature';
                Visible = false;
                field("Fiskalisation Initialized"; Rec."Fiskalisation Initialized")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fiscalization Activated field.';
                }
                group(Control1103308010)
                {
                    ShowCaption = false;
                    field("Initialization Date"; Rec."Initialization Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Initialization Date field.';
                    }
                    field("Initialization Date Voided"; Rec."Initialization Date Voided")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Initialization Date Voided field.';
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(StartFiscalisation)
            {
                ApplicationArea = All;
                Caption = 'Start Fiscalization';
                Enabled = StartFiskalisationEnabled;
                Image = AuthorizeCreditCard;
                ToolTip = 'Executes the Start Fiscalization action.';

                trigger OnAction()
                var
                    RetailUser: Record "CCS CASH Retail User";
                    // >> AL-Umstellung:
                    //SigSetup: Record "CCS CASH Sign. Service Setup";
                    IsHandled: Boolean;
                    PosRegFunc: Codeunit "CCS CASH POS Register Func";
                // << AL-Umstellung
                begin
                    //++POS0029
                    if not Confirm(Text001, false, Rec."Store No", Rec."No.") then
                        exit;
                    // >> AL-Umstellung:
                    //SigSetup.Get("Store No", "No.");
                    // << AL-Umstellung
                    if CallLogin(RetailUser) then begin
                        // >> AL-Umstellung:
                        //SigSetup."WebService Active" := true;
                        //SigSetup.Modify(true);                        
                        OnStartFiscalisation(Rec."Store No", Rec."No.", IsHandled);
                        PosRegFunc.HandleSignatureServiceResponse(IsHandled);
                        // << AL-Umstellung:
                        cslFunc.ZeroTransaction(RetailUser, Enum::"CCS CASH Zero Receipt Type"::StartReceipt);
                        cslFunc.ExitSession(POSTerm);
                        POSTerm.Validate("Initialization Date", CurrentDateTime);
                        POSTerm.Modify(true);
                        Message(Text003, Text004, Text005);
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(StopFiskalisation)
            {
                ApplicationArea = All;
                Caption = 'Stop Fiscalization';
                Enabled = StopFiskalisationEnabled;
                Image = VoidCreditCard;
                ToolTip = 'Executes the Stop Fiscalization action.';

                trigger OnAction()
                var
                    RetailUser: Record "CCS CASH Retail User";
                    // >> AL-Umstellung:
                    //SigSetup: Record "CCS CASH Sign. Service Setup";
                    IsHandled: Boolean;
                    PosRegFunc: Codeunit "CCS CASH POS Register Func";
                // << AL-Umstellung
                begin
                    //++POS0029
                    if not Confirm(Text002, false, Rec."Store No", Rec."No.") then
                        exit;
                    // >> AL-Umstellung:
                    //SigSetup.Get("Store No", "No.");
                    // << AL-Umstellung:
                    if CallLogin(RetailUser) then begin
                        cslFunc.ZeroTransaction(RetailUser, Enum::"CCS CASH Zero Receipt Type"::StopReceipt);
                        cslFunc.ExitSession(POSTerm);
                        // >> AL-Umstellung:
                        //SigSetup."WebService Active" := false;
                        //SigSetup.Modify(true);
                        OnStopFiscalisation(Rec."Store No", Rec."No.", IsHandled);
                        PosRegFunc.HandleSignatureServiceResponse(IsHandled);
                        // << AL-Umstellung:
                        POSTerm.Validate("Initialization Date Voided", CurrentDateTime);
                        POSTerm.Modify(true);
                        Message(Text003, Text006, Text007);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
        area(Navigation)
        {
            action("Create Zero Document")
            {
                ApplicationArea = All;
                Caption = 'Create Zero Document';
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Executes the Create Zero Document action.';

                trigger OnAction()
                var
                    RetailUser: Record "CCS CASH Retail User";
                begin
                    if CallLogin(RetailUser) then begin
                        // ++ EFSTA2.03
                        //cslFunc.ZeroTransaction(RetailUser);
                        cslFunc.ZeroTransaction(RetailUser, Enum::"CCS CASH Zero Receipt Type"::ZeroReceipt);
                        // -- EFSTA2.03
                        cslFunc.ExitSession(POSTerm);
                    end;
                end;
            }
            action(Transactions)
            {
                ApplicationArea = All;
                Caption = 'Transactions';
                Image = SettleOpenTransactions;
                RunObject = Page "CCS CASH POS Transactions";
                RunPageLink = "Store No." = FIELD("Store No"),
                                  "POS Terminal No." = FIELD("No.");
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Executes the Transactions action.';
            }

        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        StartFiskalisationEnabled := not Rec."Fiskalisation Initialized";
        StopFiskalisationEnabled := Rec."Fiskalisation Initialized" and (Rec."Initialization Date Voided" = 0DT);
    end;

    var
        cslFunc: Codeunit "CCS CASH POS Register Func";
        Text001: Label 'This function activates fiscalization for POS Terminal %1 %2\To proceed please enter "Yes" ', Comment = '%1=Value 1,%2=Value 2';
        Text002: Label 'This function deactivates the fiscalization for POS Terminal %1 %2\To proceed enter "Yes"', Comment = '%1=Value 1,%2=Value 2';
        Text003: Label 'The fiscalization is now %1\You may need to manually %2 the POS Terminal at "Finanz Online" ', Comment = '%1=Value 1,%2=Value 2';
        Text004: Label 'activated';
        Text005: Label 'activate';
        Text006: Label 'deactivated';
        Text007: Label 'deactivate';
        Err001: Label 'Login for POS %1, Store %2 failed.', Comment = '%1=Value 1,%2=Value 2';
        POSTerm: Record "CCS CASH POS Terminal";
        StartFiskalisationEnabled: Boolean;
        StopFiskalisationEnabled: Boolean;

    local procedure CallLogin(var pRetailUser: Record "CCS CASH Retail User"): Boolean
    var
        CSLLogin: Page "CCS CASH Cash Sales Login";
    begin
        if (CSLLogin.RunModal() = ACTION::OK) or (CSLLogin.GetExitMode()) then
            if CSLLogin.GetStaffSetup(pRetailUser) then
                if (pRetailUser."Store No" = Rec."Store No") and (pRetailUser."POS Terminal No." = Rec."No.") then begin
                    POSTerm.Get(pRetailUser."Store No", pRetailUser."POS Terminal No.");
                    cslFunc.EnterSession(POSTerm);
                    exit(true);
                end;
        Error(Err001, Rec."No.", Rec."Store No");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnStartFiscalisation(StoreNo: Code[20]; No: Code[20]; VAR IsHandled: boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnStopFiscalisation(StoreNo: Code[20]; No: Code[20]; VAR IsHandled: boolean)
    begin
    end;
}