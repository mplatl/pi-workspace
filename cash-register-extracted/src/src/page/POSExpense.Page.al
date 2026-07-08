page 1070570 "CCS CASH POS Expense"
{
    Caption = 'POS Expense';
    DataCaptionFields = "Store No.", "POS Terminal No.", "Transaction No.";
    PageType = Card;
    SourceTable = "CCS CASH POS Transaction Hdr.";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            field("POSTerm.Balance"; POSTerm.Balance)
            {
                ApplicationArea = All;
                Caption = 'Cash Balance';
                Enabled = false;
                QuickEntry = false;
                ToolTip = 'Specifies the value of the Cash Balance field.';
            }
            part(Ausgaben; "CCS CASH Pos Expense Sub")
            {
                ApplicationArea = All;
                Caption = 'Expenses';
                SubPageLink = "Store No." = FIELD("Store No."),
                              "POS Terminal No." = FIELD("POS Terminal No."),
                              "Transaction No." = FIELD("Transaction No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(PostTenderop)
            {
                ApplicationArea = All;
                Caption = 'Post (F9)';
                Image = PostDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ShortCutKey = 'F9';
                ToolTip = 'Executes the Post action.';

                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    cslFunc.PostTransaction(Rec);
                    CurrPage.Update(false);
                    Rec.Status := Rec.Status::Normal;
                    CurrPage.SaveRecord();
                    TransactionPosted := true;
                    CurrPage.Close();
                end;
            }
            action("Abort Transaction")
            {
                ApplicationArea = All;
                Caption = 'Void Transaction';
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Executes the Void Transaction action.';

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
            action("Cash Drawer")
            {
                ApplicationArea = All;
                Caption = 'Open Cash Drawer';
                Image = Debug;
                ToolTip = 'Opens the Cash Drawer';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Visible = CashDrawerExist;

                trigger OnAction()
                begin
                    POSTerm.OpenCashDrawer(false);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        POSTerm.Get(Rec."Store No.", Rec."POS Terminal No.");
        POSTerm.CalcFields(Balance);


        if POSTerm."Cash Drawer Connection Code" <> '' then begin
            CashDrawerExist := true;
            POSTerm.OpenCashDrawer(true, true, false);
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if TransactionPosted then begin
            if POSTerm."Cash Drawer Connection Code" <> '' then begin
                POSTerm.OpenCashDrawer(true, true, true);
            end;
            exit(true);
        end;

        //++POS0013
        if Rec."Receipt No." <> '' then begin
            Rec.Status := Rec.Status::Normal;
            Rec.Modify(true);
            exit(true);
        end;
        //--POS0013

        if not Confirm(Text001, false) then
            exit(false);

        Rec.Status := Rec.Status::Voided;
        Rec.Modify(true);
    end;

    trigger OnOpenPage()
    begin
        PreFill();
    end;

    local procedure PreFill()
    var
        StoreTenderType: Record "CCS CASH Store Tender Type";
        TransExpenseEntry: Record "CCS CASH Trans. Expense Entry";
    begin
        // exit if there are entries
        TransExpenseEntry.SetRange("Store No.", Rec."Store No.");
        TransExpenseEntry.SetRange("POS Terminal No.", Rec."POS Terminal No.");
        TransExpenseEntry.SetRange("Transaction No.", Rec."Transaction No.");
        if not TransExpenseEntry.IsEmpty() then
            exit;

        // exit if there is not exactely one Tender Type
        StoreTenderType.SetRange("Store No", Rec."Store No.");
        StoreTenderType.SetRange(TenderFunction, StoreTenderType.TenderFunction::Expense);
        if not (StoreTenderType.Count() = 1) then
            exit;

        if not StoreTenderType.FindFirst() then
            exit;

        // create Trans. Expense Entry 
        TransExpenseEntry.Init();
        TransExpenseEntry.Validate("Store No.", Rec."Store No.");
        TransExpenseEntry.Validate("POS Terminal No.", Rec."POS Terminal No.");
        TransExpenseEntry.Validate("Transaction No.", Rec."Transaction No.");
        TransExpenseEntry.Validate("Line No.", 10000);
        TransExpenseEntry.Insert();

        TransExpenseEntry.Validate(Type, TransExpenseEntry.Type::Expense);
        TransExpenseEntry.Validate("No.", StoreTenderType.Code);
        TransExpenseEntry.Modify();
    end;

    var
        POSTerm: Record "CCS CASH POS Terminal";
        cslFunc: Codeunit "CCS CASH POS Register Func";
        TransactionPosted: Boolean;
        Text001: Label 'Do you want to abort this transaction?';
        CashDrawerExist: Boolean;
}