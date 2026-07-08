page 1070565 "CCS CASH Cust Payment Sub"
{
    // POS0004 28.06.16
    //   Calculate Payment Discount Amount and Changes for User
    // POS0006 08.07.16
    //   Changed Field Amount because of editable

    AutoSplitKey = true;
    Caption = 'Cust. Ledger Entries';
    InsertAllowed = false;
    PageType = ListPart;
    PopulateAllFields = true;
    SourceTable = "CCS CASH Trans. Sales Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'Document No.';
                    Editable = false;
                    StyleExpr = MyStyleExpr;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    Editable = EntryEditable;
                    StyleExpr = MyStyleExpr;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(ChangedAmount; ChangedAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Remaining Amount';
                    Editable = EntryEditable;
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'Specifies the value of the Remaining Amount field.';

                    trigger OnValidate()
                    begin
                        Rec."Amount incl. VAT" := -ChangedAmount;
                        //IF "Amount incl. VAT" > 0 THEN
                        //  "Amount incl. VAT" := -"Amount incl. VAT";
                        CurrPage.Update(true);
                    end;
                }
                field("-Amount"; -Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Original Amount';
                    Editable = false;
                    StyleExpr = MyStyleExpr;
                    ToolTip = 'Specifies the value of the Original Amount field.';
                }
                field("Remaining Pmt. Disc. Possible"; Rec."Remaining Pmt. Disc. Possible")
                {
                    ApplicationArea = All;
                    Editable = RemPmtDiscEditable;
                    StyleExpr = MyStyleExpr;
                    ToolTip = 'Specifies the value of the Remaining Payment Discount Possible field.';

                    trigger OnValidate()
                    begin
                        PaymentDiscountAmount := CalculatePaymentDiscAmount();
                        CurrPage.Update(true);
                    end;
                }
                field("Pmt. Discount Date"; Rec."Pmt. Discount Date")
                {
                    ApplicationArea = All;
                    StyleExpr = MyStyleExpr;
                    ToolTip = 'Specifies the value of the Payment Discount Date field.';

                    trigger OnValidate()
                    begin
                        PaymentDiscountAmount := CalculatePaymentDiscAmount();
                        CurrPage.Update(true);
                    end;
                }
                field("Pmt. Disc. Tolerance Date"; Rec."Pmt. Disc. Tolerance Date")
                {
                    ApplicationArea = All;
                    StyleExpr = MyStyleExpr;
                    Visible = PmtDiscTolDateVisible;
                    ToolTip = 'Specifies the value of the Pmt. Disc. Tolerance Date field.';

                    trigger OnValidate()
                    begin
                        PaymentDiscountAmount := CalculatePaymentDiscAmount();
                        CurrPage.Update(true);
                    end;
                }
            }
            group(Control1100004006)
            {
                ShowCaption = false;
                group(Control1100004008)
                {
                    ShowCaption = false;
                    field(AmountInclVAT; -TransHead."Amount incl. VAT")
                    {
                        ApplicationArea = All;
                        Caption = 'Total Amount';
                        Editable = false;
                        Enabled = false;
                        Style = Strong;
                        StyleExpr = true;
                        ToolTip = 'Specifies the value of the Total Amount field.';
                    }
                    field(PaymentDiscountAmount; PaymentDiscountAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Payment Discount';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Payment Discount field.';
                    }
                    field(AmountinclVATPaymentDiscountAmount; -TransHead."Amount incl. VAT" + PaymentDiscountAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Total';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Total field.';
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        CCSCASHCashSalesSetup.Get();
        PmtDiscTolDateVisible := CCSCASHCashSalesSetup."Pmt. Disc. Tolerance Date";
    end;

    trigger OnAfterGetRecord()
    begin
        OnAfterGetRec();
        SetStyle();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        OnAfterGetRec();
    end;

    var
        TransHead: Record "CCS CASH POS Transaction Hdr.";
        PaymentDiscountAmount: Decimal;
        ChangedAmount: Decimal;
        CCSCASHCashSalesSetup: Record "CCS CASH Cash Sales Setup";
        CCSCASHStaff: Record "CCS CASH Staff";
        PmtDiscTolDateVisible: Boolean;
        RemPmtDiscEditable: Boolean;
        EntryEditable: Boolean;
        MyStyleExpr: Text;

    local procedure OnAfterGetRec()
    begin
        if (Rec."Store No." <> TransHead."Store No.") or (Rec."POS Terminal No." <> TransHead."POS Terminal No.") or (Rec."Transaction No." <> TransHead."Transaction No.") then
            TransHead.Get(Rec."Store No.", Rec."POS Terminal No.", Rec."Transaction No.");
        TransHead.CalcFields("Amount incl. VAT");
        ChangedAmount := -Rec."Amount incl. VAT";
        EntryEditable := Rec.Type = Rec.Type::"CCS CASH Payment";
        PaymentDiscountAmount := CalculatePaymentDiscAmount();
        if CCSCASHStaff.ID <> TransHead."Staff ID" then
            CCSCASHStaff.Get(TransHead."Staff ID");
        RemPmtDiscEditable := CCSCASHStaff."Remaining Pmt. Disc. allowed";
        //Amount := -Amount;
        //"Amount incl. VAT" := -"Amount incl. VAT";
    end;

    local procedure CalculatePaymentDiscAmount() PaymentDiscAmount: Decimal
    var
        TransHead2: Record "CCS CASH POS Transaction Hdr.";
        TransSales: Record "CCS CASH Trans. Sales Entry";
    begin
        Clear(PaymentDiscAmount);
        TransHead2.Get(Rec."Store No.", Rec."POS Terminal No.", Rec."Transaction No.");
        TransSales.SetRange("Store No.", Rec."Store No.");
        TransSales.SetRange("POS Terminal No.", Rec."POS Terminal No.");
        TransSales.SetRange("Transaction No.", Rec."Transaction No.");
        if TransSales.FindSet() then
            repeat
                if TransSales."Entry No." = Rec."Entry No." then
                    TransSales := Rec;
                if TransHead2."Creation Date" <= TransSales."Pmt. Discount Date" then
                    PaymentDiscAmount := PaymentDiscAmount + TransSales."Remaining Pmt. Disc. Possible"
                else begin
                    if CCSCASHCashSalesSetup."Pmt. Disc. Tolerance Date" then
                        if TransHead2."Creation Date" <= TransSales."Pmt. Disc. Tolerance Date" then
                            PaymentDiscAmount := PaymentDiscAmount + TransSales."Remaining Pmt. Disc. Possible";
                end;
            until TransSales.Next() = 0;
        exit(PaymentDiscAmount);
    end;

    local procedure SetStyle()
    begin
        if (Rec."Store No." <> TransHead."Store No.") or (Rec."POS Terminal No." <> TransHead."POS Terminal No.") or (Rec."Transaction No." <> TransHead."Transaction No.") then
            TransHead.Get(Rec."Store No.", Rec."POS Terminal No.", Rec."Transaction No.");

        if CCSCASHCashSalesSetup."Pmt. Disc. Tolerance Date" then begin
            if (TransHead."Creation Date" <= Rec."Pmt. Discount Date") OR (TransHead."Creation Date" <= Rec."Pmt. Disc. Tolerance Date") then
                MyStyleExpr := 'None'
            else
                MyStyleExpr := 'AttentionAccent';
        end else begin
            if TransHead."Creation Date" <= Rec."Pmt. Discount Date" then
                MyStyleExpr := 'None'
            else
                MyStyleExpr := 'AttentionAccent';
        end;
    end;
}