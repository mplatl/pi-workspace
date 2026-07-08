table 1070552 "CCS CASH Trans. Payment Entry"
{
    Caption = 'Trans. Payment';
    DrillDownPageID = "CCS CASH Trans. Payment E.";
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
            TableRelation = "CCS CASH POS Transaction Hdr."."Transaction No." WHERE("Store No." = FIELD("Store No."),
                                                                              "POS Terminal No." = FIELD("POS Terminal No."));
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(9; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(10; "Tender Type"; Code[20])
        {
            Caption = 'Payment Type';
            TableRelation = if ("Receipt No." = const('')) "CCS CASH Store Tender Type".Code where("Store No" = field("Store No."),
                                                            TenderFunction = filter(Normal | Card | Voucher))
            else
            "CCS CASH Store Tender Type".Code where("Store No" = field("Store No."),
                                                            TenderFunction = filter(Normal | Card | Voucher | "Tender Remove/Float"));




            trigger OnValidate()
            begin
                if TenderType.Get("Store No.", "Tender Type") then begin
                    if not TenderType.Usable then
                        TenderType.FieldError(Usable, Text001);
                    "Voucher Info required" := TenderType."Voucher Info required";
                    TTCard.SetRange("Store No", TenderType."Store No");
                    TTCard.SetRange("Tender Type", TenderType.Code);
                    "CardNo. Select" := not TTCard.IsEmpty;
                    "Tender Description" := TenderType.Description;
                    "Overtender Allowed" := TenderType."Overtender allowed";
                    "Cash entry" := TenderType.Cash;
                    "Float Allowed" := TenderType."Float Allowed";
                    if not "CardNo. Select" then begin
                        TenderType.TestField("Account No.");
                        case TenderType."Account Type" of
                            TenderType."Account Type"::"Bank Account":
                                "Account Type" := "Account Type"::"Bank Account";
                            TenderType."Account Type"::"G/L Account":
                                "Account Type" := "Account Type"::"G/L Account";
                        END;
                        "Account No." := TenderType."Account No.";
                    end;

                end else begin
                    Clear("Voucher Info required");
                    Clear("Account Type");
                    Clear("Account No.");
                    Clear("CardNo. Select");
                    Clear(Amount);
                    Clear("Tender Description");
                    Clear("Overtender Allowed");
                    Clear("Cash entry");
                    Clear("Float Allowed");
                end;
            end;
        }
        field(11; "Card No."; Code[20])
        {
            Caption = 'Card No.';
            TableRelation = IF ("Voucher Info required" = CONST(false)) "CCS CASH Tender Type C. Setup"."Card No." WHERE("Store No" = FIELD("Store No."),
                                                                                                                 "Tender Type" = FIELD("Tender Type"))
            ELSE
            IF ("Voucher Info required" = CONST(true)) "CCS CASH Voucher Entry"."Voucher No.";

            trigger OnValidate()
            var
                RemAmt: Decimal;
            begin
                if "Card No." = '' then begin
                    Clear(Amount);
                    exit;
                end;

                TransHead.Get("Store No.", "POS Terminal No.", "Transaction No.");
                TransHead.CalcFields("Amount incl. VAT", "Payment Amount");
                RemAmt := TransHead."Amount incl. VAT" + TransHead."Payment Amount" - TransHead."Payment Discount Amount";
                if "Voucher Info required" then begin
                    Voucher.Get("Card No.", 0);
                    Voucher.CalcFields("Remaining Amount");
                    if TransHead."Transaction Type" in [TransHead."Transaction Type"::Sales, TransHead."Transaction Type"::Payment] then
                        if Voucher.Voided or (Voucher."Remaining Amount" <= 0) then
                            Error(Text009, "Card No.");
                    //--POS0009
                    if Abs(RemAmt) >= Voucher."Remaining Amount" then
                        Amount := Voucher."Remaining Amount"
                    else
                        Amount := RemAmt;
                    //++POS0009
                end else
                    if "CardNo. Select" then begin
                        TTCard.Get("Store No.", "Tender Type", "Card No.");
                        TTCard.TestField("Account No.");
                        "Account No." := TTCard."Account No.";
                        case TTCard."Account Type" of
                            TTCard."Account Type"::"Bank Account":
                                "Account Type" := "Account Type"::"Bank Account";
                            TTCard."Account Type"::"G/L Account":
                                "Account Type" := "Account Type"::"G/L Account";
                        END;
                        Amount := -RemAmt;
                    end else
                        FieldError("Card No.");
            end;
        }
        field(12; "Cash entry"; Boolean)
        {
            Caption = 'Cash entry';
        }
        field(20; Amount; Decimal)
        {
            Caption = 'Amount';

            trigger OnValidate()
            begin
                if ("Voucher Info required") and ("Card No." = '') then
                    Error(Text005);
                if "CardNo. Select" and ("Card No." = '') then
                    Error(Text002);

                if "Voucher Info required" then begin
                    Voucher.Get("Card No.", 0);
                    Voucher.CalcFields("Remaining Amount");
                    if Abs(Amount) > Voucher."Remaining Amount" then
                        Error(Text004, CSLFunction.FormatDec(Voucher."Remaining Amount", 2, false));
                end;
            end;
        }
        field(21; "Change Line"; Boolean)
        {
        }
        field(24; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            Description = 'POS0030';
            TableRelation = "VAT Business Posting Group";
        }
        field(25; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            Description = 'POS0030';
            TableRelation = "VAT Product Posting Group";
        }
        field(50; "Safe Type"; enum "CCS CASH Payment Safe Type")
        {
            Caption = 'Safe Type';
        }
        field(51; "Tender Description"; Text[50])
        {
            Caption = 'Payment Type Description';
            Editable = false;
        }
        field(52; "Amount Tendered"; Decimal)
        {
            Caption = 'Amount Tendered';
        }
        field(100; "Creation Date"; Date)
        {
            Caption = 'Date';
            Editable = false;
        }
        field(101; "Creation Time"; Time)
        {
            Caption = 'Time';
            Editable = false;
        }
        field(102; "Staff ID"; Code[20])
        {
            Caption = 'Staff ID';
            TableRelation = "CCS CASH Staff";
        }
        field(111; "Float Allowed"; Boolean)
        {
            Caption = 'Change allowed';
        }
        field(112; "Voucher Info required"; Boolean)
        {
            Caption = 'Voucher Info required';
        }
        field(113; "CardNo. Select"; Boolean)
        {
            Caption = 'Card No. Select';
        }
        field(114; "Overtender Allowed"; Boolean)
        {
            Caption = 'Overtender Allowed';
        }
        field(150; "Account Type"; enum "CCS CASH Account Type Payment")
        {
            Caption = 'Account Type';
        }
        field(151; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = IF ("Account Type" = CONST("G/L Account")) "G/L Account"."No." WHERE("Account Type" = CONST(Posting))
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account"."No.";
        }
        field(1000; "Transaction Type"; enum "CCS CASH Transaction Type")
        {
            CalcFormula = Lookup("CCS CASH POS Transaction Hdr."."Transaction Type" WHERE("Store No." = FIELD("Store No."),
                                                                                    "POS Terminal No." = FIELD("POS Terminal No."),
                                                                                    "Transaction No." = FIELD("Transaction No.")));
            Caption = 'Transaction Type';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1001; ReceiptNo; Code[20])
        {
            CalcFormula = Lookup("CCS CASH POS Transaction Hdr."."Receipt No." WHERE("Store No." = FIELD("Store No."),
                                                                               "POS Terminal No." = FIELD("POS Terminal No."),
                                                                               "Transaction No." = FIELD("Transaction No.")));
            Caption = 'Receipt No.';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Store No.", "POS Terminal No.", "Transaction No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = Amount;
        }
        key(Key2; "Store No.", "POS Terminal No.", "Creation Date", "Cash entry", "Transaction No.", "Receipt No.")
        {
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        VoidTransPmt: Record "CCS CASH Trans. Pmt. E. Voided";
        NextEntryNo: Integer;
    begin
        VoidTransPmt.SetRange("Store No.", "Store No.");
        VoidTransPmt.SetRange("POS Terminal No.", "POS Terminal No.");
        VoidTransPmt.SetRange("Transaction No.", "Transaction No.");
        if VoidTransPmt.FindLast() then
            NextEntryNo := VoidTransPmt."Line No.";

        VoidTransPmt.TransferFields(Rec);
        VoidTransPmt."Line No." := NextEntryNo + 1;
        VoidTransPmt.Insert();
    end;

    trigger OnInsert()
    begin
        TransHead.Get("Store No.", "POS Terminal No.", "Transaction No.");
        "Staff ID" := TransHead."Staff ID";
        "Creation Date" := Today;
        "Creation Time" := Time;
    end;

    var
        TenderType: Record "CCS CASH Store Tender Type";
        Text001: Label 'Must be useable.';
        TTCard: Record "CCS CASH Tender Type C. Setup";
        Text002: Label 'Insert a Card No.';
        Voucher: Record "CCS CASH Voucher Entry";
        TransHead: Record "CCS CASH POS Transaction Hdr.";
        Text004: Label 'The Payment Amount must not be higher than %1.', Comment = '%1=Value 1';
        CSLFunction: Codeunit "CCS CASH POS Register Func";
        Text005: Label 'Enter a Voucher No.';
        Text006: Label 'Return Amount';
        Text007: Label 'Change is not allowed in Return Transactions';
        Text008: Label 'Not enough cash to change back.';
        Text009: Label 'Voucher %1 invalid', Comment = '%1=Value 1';

    internal procedure "Payment Ready"(var pTransH: Record "CCS CASH POS Transaction Hdr."; InsertChangeLine: Boolean) Result: Boolean
    var
        TPmt: Record "CCS CASH Trans. Payment Entry";
        AmountNeeded: Decimal;
        PaymentAmt: Decimal;
        RemAmt: Decimal;
        CashAmount: Decimal;
        NextLineNo: Integer;
        ChangeAllowed: Boolean;
    begin
        // TRUE:  Ready Posting
        // FALSE: Payment in progress

        pTransH.CalcFields("Amount incl. VAT", "Payment Amount");
        // + POS0014
        if pTransH."Transaction Type" = pTransH."Transaction Type"::Return then
            AmountNeeded := pTransH."Amount incl. VAT" - pTransH."Payment Discount Amount"
        else
            // - POS0014
            AmountNeeded := Abs(pTransH."Amount incl. VAT") + pTransH."Payment Discount Amount";
        ChangeAllowed := pTransH."Transaction Type" <> pTransH."Transaction Type"::Return;

        TPmt.SetRange("Store No.", pTransH."Store No.");
        TPmt.SetRange("POS Terminal No.", pTransH."POS Terminal No.");
        TPmt.SetRange("Transaction No.", pTransH."Transaction No.");

        TPmt.SetRange("Change Line", true);
        if not TPmt.IsEmpty then
            // + POS0028
            //TPmt.Delete();
            TPmt.DeleteAll();
        // - POS0028
        TPmt.SetRange("Change Line");

        if TPmt.FindSet() then
            repeat
                PaymentAmt += Abs(TPmt.Amount);
                if TPmt."Cash entry" then
                    CashAmount += Abs(TPmt.Amount);
                NextLineNo := TPmt."Line No.";
                if not ChangeAllowed then
                    if TPmt.Amount > 0 then begin
                        TPmt.Amount := -TPmt.Amount;
                        TPmt.Modify();
                    end;
            until TPmt.Next() = 0;

        //CashAmount := ABS(CashAmount);
        PaymentAmt := -PaymentAmt;
        RemAmt := AmountNeeded + PaymentAmt;
        if not ChangeAllowed and (RemAmt < 0) then
            Error(Text007);

        if ChangeAllowed then
            if RemAmt < 0 then
                if Abs(RemAmt) > Abs(CashAmount) then
                    Error(Text008);

        if (RemAmt < 0) then begin
            if not ChangeAllowed then
                Error(Text007);
            if InsertChangeLine then begin
                TenderType.SetRange("Store No", pTransH."Store No.");
                TenderType.SetRange(Cash, true);
                TenderType.FindFirst();
                TPmt.Init();
                TPmt."Store No." := pTransH."Store No.";
                TPmt."POS Terminal No." := pTransH."POS Terminal No.";
                TPmt."Transaction No." := pTransH."Transaction No.";
                TPmt."Line No." := NextLineNo + 10000;
                TPmt.Validate("Tender Type", TenderType.Code);
                TPmt."Tender Description" := Text006;
                TPmt."Change Line" := true;
                TPmt.Amount := RemAmt;
                TPmt.Insert(true);
            end;
        end;

        exit(RemAmt <= 0);
    end;
}