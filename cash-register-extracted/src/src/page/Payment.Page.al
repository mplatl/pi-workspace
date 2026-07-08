page 1070562 "CCS CASH Payment"
{
    // POS0007 08.07.16 FS
    //   Voucher handling
    // POS0029 07.02.17 FS Added Variable IsRefund and Changed Functions GetCaptionClass, SetTransactionHeader, Added SuggestPayment

    AutoSplitKey = true;
    Caption = 'Payment';
    DataCaptionExpression = GetPageCaption();
    DelayedInsert = true;
    PageType = ListPlus;
    PopulateAllFields = true;
    SourceTable = "CCS CASH Trans. Payment Entry";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Control1100004014)
                {
                    ShowCaption = false;
                    field(TransHeadStoreNo; TransHead."Store No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Store';
                        Enabled = false;
                        ToolTip = 'Specifies the value of the Store field.';
                    }
                    field(TransHeadPOSTerminalNo; TransHead."POS Terminal No.")
                    {
                        ApplicationArea = All;
                        Caption = 'POS Terminal No.';
                        Enabled = false;
                        ToolTip = 'Specifies the value of the POS Terminal No. field.';
                    }
                    field(TransHeadTransactionNo; TransHead."Transaction No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Transaction';
                        Enabled = false;
                        ToolTip = 'Specifies the value of the Transaction field.';
                    }
                }
            }
#pragma warning disable AW0008
            repeater(Lines)
#pragma warning restore AW0008
            {
                Caption = 'Payments';
                field("Tender Type"; Rec."Tender Type")
                {
                    Caption = 'Payment Code';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Code field.';

                    trigger OnValidate()
                    begin
                        OnTTValidate();
                    end;
                }
                field("Tender Description"; Rec."Tender Description")
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Card No."; Rec."Card No.")
                {
                    ApplicationArea = All;
                    Editable = "No.Editable";
                    ToolTip = 'Specifies the value of the Card No. field.';

                    trigger OnValidate()
                    begin
                        OnNoValidate();
                    end;
                }
                field(PmtAmount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                    ToolTip = 'Specifies the value of the Amount field.';

                    trigger OnAssistEdit()
                    begin
                        SuggestPayment();
                    end;

                    trigger OnValidate()
                    begin
                        UserModified := true;
                        UpdatePayment();
                    end;
                }
            }
            group(Sumtab)
            {
                Caption = 'Totals';
                group(Control1100004015)
                {
                    ShowCaption = false;
                    field(TransHeadAmountinclVAT; TransHead."Amount incl. VAT")
                    {
                        ApplicationArea = All;
                        CaptionClass = GetCaptionClass(70000);
                        Caption = 'Amount';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Amount field.';
                    }
                    field(TransHeadPaymentDiscountAmount; TransHead."Payment Discount Amount")
                    {
                        ApplicationArea = All;
                        Caption = 'Paym. Disc. Amount';
                        Editable = false;
                        Visible = ShowPmtDiscount;
                        ToolTip = 'Specifies the value of the Payment Discount Amount field.';
                    }
                    field(TransHeadPaymentAmount; TransHead."Payment Amount")
                    {
                        ApplicationArea = All;
                        CaptionClass = GetCaptionClass(70001);
                        Caption = 'Payment';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Payment field.';
                    }
                    field(TransHeadRemainingPayment; TransHead.RemainingPayment())
                    {
                        ApplicationArea = All;
                        CaptionClass = GetCaptionClass(70002);
                        Caption = 'Remaining';
                        Editable = false;
                        StyleExpr = RemAmtColor;
                        ToolTip = 'Specifies the value of the Remaining field.';
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Post)
            {
                ApplicationArea = All;
                Caption = 'Post (F9)';
                Image = PostOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ShortCutKey = 'F9';
                ToolTip = 'Executes the Post action.';

                trigger OnAction()
                begin
                    DoPostPayment();
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
        OnAfterGetCurrRec();
    end;

    trigger OnAfterGetRecord()
    begin
        "No.Editable" := Rec."Voucher Info required" or Rec."CardNo. Select";
        UpdateEditableFields();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        OnAfterGetCurrRec();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if PaymentPosted then
            exit(true);

        if TransHead."Transaction No." <> 0 then begin
            TransPmt.SetRange("Store No.", TransHead."Store No.");
            TransPmt.SetRange("POS Terminal No.", TransHead."POS Terminal No.");
            TransPmt.SetRange("Transaction No.", TransHead."Transaction No.");
            if not TransPmt.IsEmpty then begin
                if not Confirm(cErrorCancel, false) then
                    exit(false);
                TransPmt.DeleteAll(true);
            end;
        end;

        exit(true);
    end;

    var
        TransHead: Record "CCS CASH POS Transaction Hdr.";
        TransPmt: Record "CCS CASH Trans. Payment Entry";
        TType: Record "CCS CASH Store Tender Type";
        TTCard: Record "CCS CASH Tender Type C. Setup";
        PosTerm: Record "CCS CASH POS Terminal";
        CSLFunction: Codeunit "CCS CASH POS Register Func";
        cTotalSalesAmtCaption: Label 'Amount to pay';
        cTotalReturnAmtCaption: Label 'Amount to return';
        cTotalPmtCaption: Label 'Payment Amount';
        cTotalRtPmtCaption: Label 'Amount returned';
        cRemAmtCaption: Label 'Remaining Amount';
        cReturnAmtCaption: Label 'Returning Amount';
        RemAmtText: Text[70];
        RemAmtColor: Text[50];
        "No.Editable": Boolean;
        cErrorCancel: Label 'Closing the payment Form will delete all payments so far\Do you want to continue?';
        Text001: Label 'POS';
        CanPost: Boolean;
        UserModified: Boolean;
        Text003: Label 'Cash Transaction is not ready for posting';
        PaymentPosted: Boolean;
        ShowPmtDiscount: Boolean;
        IsRefund: Boolean;
        DelayedPostingMode: Boolean;
        CashDrawerExist: Boolean;

    local procedure GetPageCaption(): Text[80]
    begin
#pragma warning disable AA0217
        exit(StrSubstNo('%1: %2, %3 %4', Text001, TransHead."POS Terminal No.", Format(TransHead."Transaction Type"), TransHead."Transaction No."));
#pragma warning restore AA0217
    end;

    local procedure GetCaptionClass(pFieldNo: Integer): Text[80]
    begin
        //--POS0029
        /*
        IF TransHead."Transaction Type" IN [TransHead."Transaction Type"::Sales,TransHead."Transaction Type"::Payment] THEN
          CASE pFieldNo OF
            70000: EXIT('3,' + cTotalSalesAmtCaption);
            70001: EXIT('3,' + cTotalPmtCaption);
            70002: EXIT('3,' + RemAmtText);
          END
        ELSE
          CASE pFieldNo OF
            70000: EXIT('3,' + cTotalReturnAmtCaption);
            70001: EXIT('3,' + cTotalRtPmtCaption);
            70002: EXIT('3,' + RemAmtText);
          END;
        */
        if IsRefund then
            case pFieldNo of
                70000:
                    exit('3,' + cTotalReturnAmtCaption);
                70001:
                    exit('3,' + cTotalRtPmtCaption);
                70002:
                    exit('3,' + RemAmtText);
            end
        else
            case pFieldNo of
                70000:
                    exit('3,' + cTotalSalesAmtCaption);
                70001:
                    exit('3,' + cTotalPmtCaption);
                70002:
                    exit('3,' + RemAmtText);
            end;
        //++POS0029

    end;

    internal procedure SetTransactionHeader(pTransHead: Record "CCS CASH POS Transaction Hdr.")
    begin
        TransHead := pTransHead;
        // + POS0007
        CSLFunction.TestVoucher(TransHead);
        // - POS0007
        TransHead.CalcFields("Amount incl. VAT", TransHead."Payment Amount");

        if TransHead."Payment Discount %" <> 0 then begin
            TransHead."Payment Discount Amount" := Round(TransHead."Amount incl. VAT" * TransHead."Payment Discount %" / 100, 0.01);
            TransHead.Modify(true);
        end;

        if POSTerm.Get(pTransHead."Store No.", pTransHead."POS Terminal No.") then
            if POSTerm."Cash Drawer Connection Code" <> '' then begin
                CashDrawerExist := true;
            end;

        ShowPmtDiscount := (TransHead."Transaction Type" in [TransHead."Transaction Type"::Sales, TransHead."Transaction Type"::Payment]) and
                              (TransHead."Payment Discount Amount" <> 0);

        RemAmtText := cRemAmtCaption;
        RemAmtColor := 'Strong';
        "No.Editable" := false;
        Rec.SetRange("Store No.", TransHead."Store No.");
        Rec.SetRange("POS Terminal No.", TransHead."POS Terminal No.");
        Rec.SetRange("Transaction No.", TransHead."Transaction No.");
        //--PSO0029
        IsRefund := (TransHead."Transaction Type" = TransHead."Transaction Type"::Return) or
                    ((TransHead."Transaction Type" = TransHead."Transaction Type"::Payment) and (TransHead."Amount incl. VAT" > 0));
        //++POS0029
    end;

    internal procedure GetPostingStatus(): Boolean
    begin
        exit(PaymentPosted);
    end;

    local procedure OnTTValidate()
    begin
        UserModified := true;
        UpdateEditableFields();
        UpdatePayment();
    end;

    local procedure OnNoValidate()
    begin
        UserModified := true;
        CurrPage.SaveRecord();
        UpdatePayment();
    end;

    local procedure OnAfterGetCurrRec()
    begin
        TransHead."Amount incl. VAT" := Abs(TransHead."Amount incl. VAT");
        TransHead."Payment Amount" := -Abs(TransHead."Payment Amount");

        if TransHead."Transaction Type" = TransHead."Transaction Type"::Payment then
            if TransHead."Payment Amount" <> 0 then
                CanPost := true;
    end;

    local procedure DoPostPayment()
    var
        OpenDrawer: Boolean;
        DoubleCashPaymentErr: Label 'It is not allowed to have two cash payment lines. Please change the %1 to a non-cash alternative.', Comment = '%1 = Field Caption';
    begin
        if not CanPost then
            Error(Text003);

        if IsDoubleCashPayment() then
            Error(DoubleCashPaymentErr, Rec.FieldCaption("Tender Type"));

        Rec."Payment Ready"(TransHead, true);
        if CashDrawerExist then begin
            if Rec.FindSet() then
                repeat
                    if Rec."Tender Type" <> '' then begin
                        TType.Get(TransHead."Store No.", Rec."Tender Type");
                        if TType."Cash Drawer Opens" then
                            OpenDrawer := true;
                    end;
                until Rec.Next() = 0;

            if OpenDrawer then begin
                POSTerm.OpenCashDrawer(true);
            end;
        end;
        if not DelayedPostingMode then begin
            Commit();
            TransHead.Find();
            CSLFunction.PostTransaction(TransHead);
        end;
        PaymentPosted := true;

        CurrPage.Close();
    end;

    local procedure IsDoubleCashPayment(): Boolean
    var
        TransPaymentEntry: Record "CCS CASH Trans. Payment Entry";
    begin
        TransPaymentEntry.SetRange("Store No.", Rec."Store No.");
        TransPaymentEntry.SetRange("POS Terminal No.", Rec."POS Terminal No.");
        TransPaymentEntry.SetRange("Transaction No.", Rec."Transaction No.");
        TransPaymentEntry.SetRange("Cash entry", true);

        if TransPaymentEntry.Count() > 1 then
            exit(true);
    end;

    local procedure UpdatePayment()
    begin
        CurrPage.SaveRecord();
        if not Rec."Payment Ready"(TransHead, false) then begin
            RemAmtText := cRemAmtCaption;
            RemAmtColor := 'Strong';
            CanPost := false;
        end else begin
            RemAmtText := cReturnAmtCaption;
            RemAmtColor := 'UnFavorable';
            CanPost := true and UserModified;
        end;
        CurrPage.Update(false);
    end;

    local procedure SuggestPayment()
    var
        TendDeclSetup: Record "CCS CASH Declaration Setup";
        TempCashSugg: Record "CCS CASH Cash Pmt. Suggestion" temporary;
        NextAmt: Decimal;
    begin
        if TransHead.RemainingPayment() <= 0 then
            exit;

        TendDeclSetup.SetRange("Store No.", TransHead."Store No.");
        TendDeclSetup.SetRange("Tender Type", Rec."Tender Type");
        if not TendDeclSetup.Find('-') then
            exit;

        TempCashSugg.Init();
        TempCashSugg.Code := '01';
        TempCashSugg."Cash Amount" := TransHead.RemainingPayment();
        TempCashSugg.Insert();

        repeat
            NextAmt := Round(TransHead.RemainingPayment(), TendDeclSetup.Amount, '>');
            if NextAmt > TempCashSugg."Cash Amount" then begin
                TempCashSugg.Code := IncStr(TempCashSugg.Code);
                TempCashSugg."Cash Amount" := NextAmt;
                TempCashSugg.Insert();
            end;
        until TendDeclSetup.Next() = 0;
        if not TempCashSugg.IsEmpty then
            if PAGE.RunModal(1070585, TempCashSugg) = ACTION::LookupOK then begin
                Rec.Validate(Amount, TempCashSugg."Cash Amount");
                CurrPage.Update(true);
            end;
    end;

    local procedure UpdateEditableFields()
    begin
        if Rec."Tender Type" <> '' then begin
            TType.Get(TransHead."Store No.", Rec."Tender Type");
            TTCard.SetRange("Store No", TType."Store No");
            TTCard.SetRange("Tender Type", TType.Code);
            "No.Editable" := TType."Voucher Info required" or not TTCard.IsEmpty;
        end;

    end;

    internal procedure SetDelayedPostingMode(newDelayedPostingMode: Boolean)
    begin
        DelayedPostingMode := newDelayedPostingMode;
    end;
}