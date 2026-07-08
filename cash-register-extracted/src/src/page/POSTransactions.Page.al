page 1070566 "CCS CASH POS Transactions"
{
    // POS001 05.12.16
    //   Navigate für POS
    // POS0029 07.02.17 FS Added Action Sig. Service Request Log, Caption changes

    AdditionalSearchTerms = 'CASH POS Transactions', Locked = true;
    Caption = 'POS Transactions - Cash Register';
    DataCaptionExpression = DataCaption();
    DataCaptionFields = "Store No.", "POS Terminal No.", "Transaction No.";
    Editable = false;
    PageType = List;
    SourceTable = "CCS CASH POS Transaction Hdr.";
    UsageCategory = Lists;
    ApplicationArea = CCSCASH;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = "Transaction No.";
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                    Visible = ShowField;
                    ToolTip = 'Specifies the value of the Store No. field.';
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ApplicationArea = All;
                    Visible = ShowField;
                    ToolTip = 'Specifies the value of the POS Terminal No. field.';
                }
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = All;
                    Caption = 'Trans. No.';
                    ToolTip = 'Specifies the value of the Transaction No. field.';
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Type field.';
                }
                field("System Created"; Rec."System Created")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the System Created field.';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field.';
                }
                field("Creation Time"; Rec."Creation Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time field.';
                }
                field("Staff ID"; Rec."Staff ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Staff ID field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field("Sales Amount"; Rec."Sales Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Amount field.';
                }
                field("Amount incl. VAT"; Rec."Amount incl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount inkl. VAT field.';
                }
                field("Payment Amount"; Rec."Payment Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Amount field.';
                }
                field("Inv. Disc. Amount"; Rec."Inv. Disc. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoice Discount Amount field.';
                }
                field("No. of Item Lines"; Rec."No. of Item Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Item Lines field.';
                }
                field("No. of Payment Lines"; Rec."No. of Payment Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Payment Lines field.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("&Navigate")
            {
                ApplicationArea = All;
                Caption = '&Navigate';
                Image = Navigate;
                ToolTip = 'Executes the Navigate action.';

                trigger OnAction()
                var
                    navigate: Page Navigate;
                    documentNo: Text;
                begin
                    //-POS001
                    if not (Rec.Status in [Rec.Status::Normal, Rec.Status::Voided]) then
                        exit;

                    documentNo := Rec."Receipt No.";
                    navigate.SetDoc(Rec."Creation Date", CopyStr(documentNo, 1, 20));
                    navigate.SetRec(Rec);
                    navigate.Run();
                    //+POS001
                end;
            }
            action(SalesEntries)
            {
                ApplicationArea = All;
                Caption = 'Sales Entries';
                Image = EntriesList;
                RunObject = Page "CCS CASH Trans. Sales Entries";
                RunPageLink = "Store No." = FIELD("Store No."),
                              "POS Terminal No." = FIELD("POS Terminal No."),
                              "Transaction No." = FIELD("Transaction No.");
                ToolTip = 'Executes the Sales Entries action.';
            }
            action(Expense)
            {
                ApplicationArea = All;
                Caption = 'Expense';
                Image = CostEntries;
                RunObject = Page "CCS CASH Expense List";
                RunPageLink = "Store No." = FIELD("Store No."),
                              "POS Terminal No." = FIELD("POS Terminal No."),
                              "Transaction No." = FIELD("Transaction No.");
                ToolTip = 'Executes the Expense action.';
            }
            action(PaymentEntries)
            {
                ApplicationArea = All;
                Caption = 'Payment Entries';
                Image = Register;
                RunObject = Page "CCS CASH Trans. Payment E.";
                RunPageLink = "Store No." = FIELD("Store No."),
                              "POS Terminal No." = FIELD("POS Terminal No."),
                              "Transaction No." = FIELD("Transaction No.");
                ToolTip = 'Executes the Payment Entries action.';
            }
            action("Sig. Service Request Log")
            {
                ApplicationArea = All;
                Caption = 'Sig. Service Request Log';
                Image = CreditCardLog;
                ToolTip = 'Executes the Signature Service Request Log action.';
                // >> AL-Umstellung
                //RunObject = Page "Sign. Service Request Log";
                //RunPageLink = "Store No." = FIELD("Store No."),
                //              "POS Terminal No." = FIELD("POS Terminal No."),
                //              "Transaction No." = FIELD("Transaction No.");
                trigger OnAction()
                var
                    IsHandled: Boolean;
                    PosRegFunc: Codeunit "CCS CASH POS Register Func";
                begin
                    OnOpenPageSigServiceRequestLog(Rec."Store No.", Rec."POS Terminal No.", Rec."Transaction No.", IsHandled);
                    PosRegFunc.HandleSignatureServiceResponse(IsHandled);
                end;
                // << AL-Umstellung
            }
            action("Tender Declaration")
            {
                ApplicationArea = All;
                Caption = 'Tender Operation';
                Image = CalculateBalanceAccount;
                RunObject = Page "CCS CASH Tender Declaration";
                RunPageLink = "Store No." = FIELD("Store No."),
                              "POS Terminal No." = FIELD("POS Terminal No."),
                              "Transaction No." = FIELD("Transaction No.");
                ToolTip = 'Executes the Tender Operation action.';
            }
            action(SafeEntries)
            {
                ApplicationArea = All;
                Caption = 'Safe Entries';
                Image = Bank;
                RunObject = Page "CCS CASH Trans. Safe List";
                RunPageLink = "Store No." = FIELD("Store No."),
                              "POS Terminal No." = FIELD("POS Terminal No."),
                              "Transaction No." = FIELD("Transaction No.");
                ToolTip = 'Executes the Safe Entries action.';
            }
            action("Cash Declaration")
            {
                ApplicationArea = All;
                Caption = 'Cash Tender Operation';
                Image = CashFlowSetup;
                RunObject = Page "CCS CASH Trans. Tender Dcl. E.";
                RunPageLink = "Store No." = FIELD("Store No."),
                              "POS Terminal No." = FIELD("POS Terminal No."),
                              "Transaction No." = FIELD("Transaction No.");
                ToolTip = 'Executes the Cash Tender Operation action.';
            }
            action(VoidedEntries)
            {
                ApplicationArea = All;
                Caption = 'Voided Sales Entries';
                Image = CancelledEntries;
                RunObject = Page "CCS CASH Void Trans. Sales E.";
                RunPageLink = "Store No." = FIELD("Store No."),
                              "POS Terminal No." = FIELD("POS Terminal No."),
                              "Transaction No." = FIELD("Transaction No.");
                ToolTip = 'Executes the Voided Sales Entries action.';
            }
            action("VoidedPayment Entries")
            {
                ApplicationArea = All;
                Caption = 'Voided Payment Entries';
                Image = VoidRegister;
                RunObject = Page "CCS CASH Voided Payment E.";
                RunPageLink = "Store No." = FIELD("Store No."),
                              "POS Terminal No." = FIELD("POS Terminal No."),
                              "Transaction No." = FIELD("Transaction No.");
                ToolTip = 'Executes the Voided Payment Entries action.';
            }
        }
        area(reporting)
        {
            action(Receipt)
            {
                ApplicationArea = All;
                Caption = 'Print POS Receipt';
                ToolTip = 'Prints the POS Receipt.';
                Image = Report;

                trigger OnAction()
                begin
                    TransH := Rec;
                    TransH.SetRecFilter();
                    cslFunc.PrintReport(Print_OP::CashReceipt, TransH, true);
                end;
            }
            action(Invoice)
            {
                ApplicationArea = All;
                Caption = 'Print Invoice';
                Image = "Report";
                ToolTip = 'Prints the Invoice.';

                trigger OnAction()
                begin
                    TransH := Rec;
                    TransH.SetRecFilter();
                    cslFunc.PrintReport(Print_OP::CashInvoice, TransH, true);
                end;
            }
            action(Journal)
            {
                ApplicationArea = All;
                Caption = 'Print Trans. Log';
                Image = "Report";
                ToolTip = 'Prints the Transaction Log.';

                trigger OnAction()
                begin
                    TransH.SetRange("Store No.", Rec."Store No.");
                    TransH.SetRange("POS Terminal No.", Rec."POS Terminal No.");
                    cslFunc.PrintReport(Print_OP::Journal, TransH, true);
                end;
            }
            action(DayStart)
            {
                ApplicationArea = All;
                Caption = 'Day Start';
                Image = "Report";
                ToolTip = 'Executes the Day Start action.';

                trigger OnAction()
                begin
                    TransH := Rec;
                    TransH.SetRecFilter();
                    cslFunc.PrintReport(Print_OP::StartDay, TransH, true);
                end;
            }
            action(DayEnd)
            {
                ApplicationArea = All;
                Caption = 'Day End';
                Image = "Report";
                ToolTip = 'Executes the Day End action.';

                trigger OnAction()
                begin
                    TransH := Rec;
                    TransH.SetRecFilter();
                    cslFunc.PrintReport(Print_OP::EndDay, TransH, true);
                end;
            }
            action(Payment)
            {
                ApplicationArea = All;
                Caption = 'Print Payment';
                Image = "Report";
                ToolTip = 'Prints the Payment.';

                trigger OnAction()
                begin
                    TransH := Rec;
                    TransH.SetRecFilter();
                    cslFunc.PrintReport(Print_OP::CustPayment, TransH, true);
                end;
            }
            action(Money)
            {
                ApplicationArea = All;
                Caption = 'Money Transfer';
                Image = "Report";
                ToolTip = 'Executes the Money Transfer action.';
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";

                trigger OnAction()
                begin
                    TransH := Rec;
                    TransH.SetRecFilter();
                    cslFunc.PrintReport(Print_OP::CashReceipt, TransH, true);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetTransactionFieldsVisible();
    end;

    var
        TransH: Record "CCS CASH POS Transaction Hdr.";
        cslFunc: Codeunit "CCS CASH POS Register Func";
        Print_OP: Option CashReceipt,CashInvoice,CustPayment,StartDay,EndDay,Journal,Tenderdecl;
        ShowField: Boolean;

    local procedure SetTransactionFieldsVisible()
    begin
        if (Rec.GetFilter("Store No.") = '') or (Rec.GetFilter("POS Terminal No.") = '') then begin
            ShowField := true;
            exit;
        end;
    end;

    local procedure DataCaption(): Text
    begin
#pragma warning disable AA0217
        exit(StrSubstNo('%1-%2-%3', Rec."Store No.", Rec."POS Terminal No.", Rec."Transaction No."));
#pragma warning restore AA0217
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOpenPageSigServiceRequestLog(StoreNo: Code[20]; PosTerminalNo: Code[20]; TransactionNo: Integer; VAR IsHandled: boolean)
    begin
    end;
}