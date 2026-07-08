page 1070543 "CCS CASH POS Terminals"
{
    AdditionalSearchTerms = 'CASH POS Terminals', Locked = true;
    ApplicationArea = CCSCASH;
    Caption = 'POS Terminals - Cash Register';
    CardPageID = "CCS CASH POS Terminal Card";
    Editable = false;
    PageType = List;
    SourceTable = "CCS CASH POS Terminal";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store No"; Rec."Store No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store No. field.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Terminal No. field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Balance at Date"; Rec."Balance at Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balance at Date field.';
                }
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balance field.';
                }
                field("Safe Amount"; Rec."Safe Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Safe Content field.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Zero Document")
            {
                ApplicationArea = All;
                Caption = 'Create Zero Document';
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
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
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page "CCS CASH POS Transactions";
                RunPageLink = "Store No." = FIELD("Store No"),
                                  "POS Terminal No." = FIELD("No.");
                ToolTip = 'Executes the Transactions action.';
            }
            group(PromotedGroup)
            {
            }
            group(Transaction)
            {
            }
        }
    }

    var
        Err001: Label 'Login for POS:%1, Store %2 failed', Comment = '%1=Value 1,%2=Value 2';
        POSTerm: Record "CCS CASH POS Terminal";
        cslFunc: Codeunit "CCS CASH POS Register Func";

    local procedure CallLogin(var pRetailUser: Record "CCS CASH Retail User"): Boolean
    var
        CSLLogin: Page "CCS CASH Cash Sales Login";
    begin
        if (CSLLogin.RunModal() = ACTION::OK) or CSLLogin.GetExitMode() then
            if CSLLogin.GetStaffSetup(pRetailUser) then
                if (pRetailUser."Store No" = Rec."Store No") and (pRetailUser."POS Terminal No." = Rec."No.") then begin
                    POSTerm.Get(pRetailUser."Store No", pRetailUser."POS Terminal No.");
                    cslFunc.EnterSession(POSTerm);
                    exit(true);
                end;
        Error(Err001, Rec."No.", Rec."Store No");
    end;
}