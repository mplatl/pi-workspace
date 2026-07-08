table 1070550 "CCS CASH POS Transaction Hdr."
{
    Caption = 'POS Transaction Header';
    DataCaptionFields = "Store No.", "POS Terminal No.", "Transaction No.";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store No."; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "CCS CASH Store";
        }
        field(2; "POS Terminal No."; Code[20])
        {
            Caption = 'POS Terminal No.';
            TableRelation = "CCS CASH POS Terminal"."No." WHERE("Store No" = FIELD("Store No."));
        }
        field(3; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
        }
        field(4; "Transaction Type"; enum "CCS CASH Transaction Type")
        {
            Caption = 'Transaction Type';
            Description = 'EFSTA2.03';
        }
        field(6; "Creation Date"; Date)
        {
            Caption = 'Date';
        }
        field(7; "Creation Time"; Time)
        {
            Caption = 'Time';
        }
        field(8; "System Created"; Boolean)
        {
            Caption = 'System Created';
        }
        field(9; Status; enum "CCS CASH Transaction Option")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(10; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(20; "Staff ID"; Code[20])
        {
            Caption = 'Staff ID';
            TableRelation = "CCS CASH Staff";
        }
        field(30; "Gen. Bus. Post. Group"; Code[20])
        {
            Caption = 'Gen. Bus. Post. Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(31; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(32; "Cust. Posting Group"; Code[20])
        {
            Caption = 'Cust. Posting Group';
            TableRelation = "Customer Posting Group";
        }
        field(40; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(41; "Payment Discount %"; Decimal)
        {
            Caption = 'Payment Discount %';
        }
        field(42; "Payment Discount Amount"; Decimal)
        {
            Caption = 'Payment Discount';
            Editable = false;
        }
        field(50; "Amount excl. VAT"; Decimal)
        {
            CalcFormula = Sum("CCS CASH Trans. Sales Entry".Amount WHERE("Store No." = FIELD("Store No."),
                                                                 "POS Terminal No." = FIELD("POS Terminal No."),
                                                                 "Transaction No." = FIELD("Transaction No.")));
            Caption = 'Amount excl. VAT';
            Editable = false;
            FieldClass = FlowField;
        }
        field(51; "Amount incl. VAT"; Decimal)
        {
            CalcFormula = Sum("CCS CASH Trans. Sales Entry"."Amount incl. VAT" WHERE("Store No." = FIELD("Store No."),
                                                                             "POS Terminal No." = FIELD("POS Terminal No."),
                                                                             "Transaction No." = FIELD("Transaction No.")));
            Caption = 'Amount inkl. VAT';
            Editable = false;
            FieldClass = FlowField;
        }
        field(52; "Payment Amount"; Decimal)
        {
            CalcFormula = Sum("CCS CASH Trans. Payment Entry".Amount WHERE("Store No." = FIELD("Store No."),
                                                                   "POS Terminal No." = FIELD("POS Terminal No."),
                                                                   "Transaction No." = FIELD("Transaction No."),
                                                                   "Safe Type" = CONST("Normal")));
            Caption = 'Payment Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(53; "Sales Amount"; Decimal)
        {
            CalcFormula = Sum("CCS CASH Trans. Sales Entry"."Amount incl. VAT" WHERE("Store No." = FIELD("Store No."),
                                                                             "POS Terminal No." = FIELD("POS Terminal No."),
                                                                             "Transaction No." = FIELD("Transaction No."),
                                                                             Type = FILTER("G/L Account" .. Resource)));
            Caption = 'Sales Amount';
            FieldClass = FlowField;
        }
        field(56; "Inv. Disc. Amount"; Decimal)
        {
            CalcFormula = Sum("CCS CASH Trans. Sales Entry"."Invoice Discount Amt." WHERE("Store No." = FIELD("Store No."),
                                                                                  "POS Terminal No." = FIELD("POS Terminal No."),
                                                                                  "Transaction No." = FIELD("Transaction No."),
                                                                                  Type = FILTER(<> "CCS CASH Customer Ledger Entry")));
            Caption = 'Inv. Disc. Amount';
            FieldClass = FlowField;
        }
        field(60; "No. of Item Lines"; Integer)
        {
            CalcFormula = Count("CCS CASH Trans. Sales Entry" WHERE("Store No." = FIELD("Store No."),
                                                            "POS Terminal No." = FIELD("POS Terminal No."),
                                                            "Transaction No." = FIELD("Transaction No.")));
            Caption = 'No. of Item Lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(61; "No. of Payment Lines"; Integer)
        {
            CalcFormula = Count("CCS CASH Trans. Payment Entry" WHERE("Store No." = FIELD("Store No."),
                                                              "POS Terminal No." = FIELD("POS Terminal No."),
                                                              "Transaction No." = FIELD("Transaction No.")));
            Caption = 'No. of Payment Lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(90; "Signatur Code"; Code[60])
        {
            Caption = 'Signatur Code';
        }
        field(100; Starttime; DateTime)
        {
            Caption = 'Start Time';
        }
        field(101; Endtime; DateTime)
        {
            Caption = 'End Time';
        }
        field(102; Reasoncode; Code[10])
        {
            Caption = 'Reason Code';
        }
        field(103; "Zero Receipt Type"; enum "CCS CASH Zero Receipt Type")
        {
            Caption = 'Zero Receipt Type';
            Description = 'EFSTA2.03';
        }
        field(104; "Posting Description"; Text[100])
        {
            Caption = 'Posting Description';
        }
        field(105; "Is Advance Payment"; Boolean)
        {
            Caption = 'Is Advance Payment';
        }
    }

    keys
    {
        key(Key1; "Store No.", "POS Terminal No.", "Transaction No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        TransSales: Record "CCS CASH Trans. Sales Entry";
        TransPayment: Record "CCS CASH Trans. Payment Entry";
        TransDecl: Record "CCS CASH Trans. Cash Decl. E.";
        TransExpense: Record "CCS CASH Trans. Expense Entry";
        TransSalesVoided: Record "CCS CASH Trans Sales E. Voided";
        TransPmtVoided: Record "CCS CASH Trans. Pmt. E. Voided";
        TransTDecl: Record "CCS CASH Trans. Tender Dcl. E.";
        TransSafe: Record "CCS CASH Trans. Depot Entry";
    begin
        TransSales.SetRange("Store No.", "Store No.");
        TransSales.SetRange("POS Terminal No.", "POS Terminal No.");
        TransSales.SetRange("Transaction No.", "Transaction No.");
        TransSales.DeleteAll(true);

        TransPayment.SetRange("Store No.", "Store No.");
        TransPayment.SetRange("POS Terminal No.", "POS Terminal No.");
        TransPayment.SetRange("Transaction No.", "Transaction No.");
        TransPayment.DeleteAll(true);

        TransDecl.SetRange("Store No.", "Store No.");
        TransDecl.SetRange("POS Terminal No.", "POS Terminal No.");
        TransDecl.SetRange("Transaction No.", "Transaction No.");
        TransDecl.DeleteAll(true);

        TransSalesVoided.SetRange("Store No.", "Store No.");
        TransSalesVoided.SetRange("POS Terminal No.", "POS Terminal No.");
        TransSalesVoided.SetRange("Transaction No.", "Transaction No.");
        TransSalesVoided.DeleteAll(true);

        TransPmtVoided.SetRange("Store No.", "Store No.");
        TransPmtVoided.SetRange("POS Terminal No.", "POS Terminal No.");
        TransPmtVoided.SetRange("Transaction No.", "Transaction No.");
        TransPmtVoided.DeleteAll(true);

        TransExpense.SetRange("Store No.", "Store No.");
        TransExpense.SetRange("POS Terminal No.", "POS Terminal No.");
        TransExpense.SetRange("Transaction No.", "Transaction No.");
        TransExpense.DeleteAll(true);

        TransTDecl.SetRange("Store No.", "Store No.");
        TransTDecl.SetRange("POS Terminal No.", "POS Terminal No.");
        TransTDecl.SetRange("Transaction No.", "Transaction No.");
        TransTDecl.DeleteAll(true);

        TransSafe.SetRange("Store No.", "Store No.");
        TransSafe.SetRange("POS Terminal No.", "POS Terminal No.");
        TransSafe.SetRange("Transaction No.", "Transaction No.");
        TransSafe.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        TransHead: Record "CCS CASH POS Transaction Hdr.";
    begin
        if "Transaction No." = 0 then begin
            TransHead.SetRange("Store No.", "Store No.");
            TransHead.SetRange("POS Terminal No.", "POS Terminal No.");
            if TransHead.FindLast() then
                "Transaction No." := TransHead."Transaction No.";
            "Transaction No." += 1;
        end;
    end;

    trigger OnModify()
    begin
        UpdateReceiptNoTransPaymentEntry();
    end;

    internal procedure RemainingPayment(): Decimal
    begin
        CalcFields("Amount incl. VAT", "Payment Amount");
        exit(Abs("Amount incl. VAT") - Abs("Payment Amount") - Abs("Payment Discount Amount"));
    end;

    internal procedure VoidTransaction(pRetailUser: Record "CCS CASH Retail User")
    var
        cslDocument: Record "Sales Header";
    begin
        Status := Status::Voided;
        "Staff ID" := pRetailUser."Staff ID";
        Modify(true);

        if "Transaction Type" in ["Transaction Type"::Sales, "Transaction Type"::Return] then begin
            cslDocument.SetRange("CCS CASH CSL Store No.", "Store No.");
            cslDocument.SetRange("CCS CASH CSL POS Terminal No.", "POS Terminal No.");
            cslDocument.SetRange("CCS CASH CSL Transaction No.", "Transaction No.");
            if cslDocument.FindFirst() then
                cslDocument.Delete(true);
        end;

        DeleteTransSales(Rec);
        DeleteTransPayment(Rec);
    end;

    local procedure DeleteTransSales(var pTransH: Record "CCS CASH POS Transaction Hdr.")
    var
        TransSales: Record "CCS CASH Trans. Sales Entry";
        TransSalesVoid: Record "CCS CASH Trans Sales E. Voided";
        NextEntryNo: Integer;
    begin
        TransSales.SetRange("Store No.", pTransH."Store No.");
        TransSales.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
        TransSales.SetRange("Transaction No.", pTransH."Transaction No.");

        TransSalesVoid.SetRange("Store No.", pTransH."Store No.");
        TransSalesVoid.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
        TransSalesVoid.SetRange("Transaction No.", pTransH."Transaction No.");
        if TransSalesVoid.FindLast() then
            NextEntryNo := TransSalesVoid."Line No.";

        if TransSales.FindSet() then
            repeat
                TransSalesVoid.TransferFields(TransSales);
                NextEntryNo += 1;
                TransSalesVoid."Line No." := NextEntryNo;
                TransSalesVoid.Insert();
            until TransSales.Next() = 0;
        TransSales.DeleteAll(true);
    end;

    local procedure DeleteTransPayment(var pTransH: Record "CCS CASH POS Transaction Hdr.")
    var
        TransPmt: Record "CCS CASH Trans. Payment Entry";
        TransPmtVoid: Record "CCS CASH Trans. Pmt. E. Voided";
        NextEntryNo: Integer;
    begin
        TransPmt.SetRange("Store No.", pTransH."Store No.");
        TransPmt.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
        TransPmt.SetRange("Transaction No.", pTransH."Transaction No.");

        TransPmtVoid.SetRange("Store No.", pTransH."Store No.");
        TransPmtVoid.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
        TransPmtVoid.SetRange("Transaction No.", pTransH."Transaction No.");
        if TransPmtVoid.FindLast() then
            NextEntryNo := TransPmtVoid."Line No.";

        if TransPmt.FindSet() then
            repeat
                TransPmtVoid.TransferFields(TransPmt);
                NextEntryNo += 1;
                TransPmtVoid."Line No." := NextEntryNo;
                TransPmtVoid.Insert();
            until TransPmt.Next() = 0;
        TransPmt.DeleteAll(true);
    end;

    internal procedure UpdateReceiptNoTransPaymentEntry()
    var
        TransPaymentEntry: Record "CCS CASH Trans. Payment Entry";
    begin
        if ("Receipt No." <> '') and (Status = Status::Normal) and not Rec.IsTemporary then begin
            TransPaymentEntry.SetRange("Store No.", "Store No.");
            TransPaymentEntry.SetRange("POS Terminal No.", "POS Terminal No.");
            TransPaymentEntry.SetRange("Transaction No.", "Transaction No.");
            TransPaymentEntry.SetRange("Receipt No.", '');
            if not TransPaymentEntry.IsEmpty() then
                TransPaymentEntry.ModifyAll("Receipt No.", "Receipt No.");
        end;
    end;
}