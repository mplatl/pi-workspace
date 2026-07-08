table 1070557 "CCS CASH Trans. Pmt. E. Voided"
{
    Caption = 'Payment Voided';
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
        field(10; "Tender Type"; Code[20])
        {
            Caption = 'Payment Type';
            TableRelation = "CCS CASH Store Tender Type".Code WHERE("Store No" = FIELD("Store No."),
                                                            TenderFunction = FILTER(Normal | Card | Voucher | "Tender Remove/Float"));

            trigger OnValidate()
            begin
                if TenderType.Get("Store No.", "Tender Type") then begin
                    if not TenderType.Usable then
                        TenderType.FieldError(Usable, Text001);
                    "Voucher Info required" := TenderType."Voucher Info required";
                    "Account Type" := TenderType."Account Type";
                    "Account No." := TenderType."Account No.";
                    TTCard.SetRange("Store No", TenderType."Store No");
                    TTCard.SetRange("Tender Type", TenderType.Code);
                    "CardNo. Select" := not TTCard.IsEmpty;
                    "Tender Description" := TenderType.Description;
                    "Overtender Allowed" := TenderType."Overtender allowed";
                end else begin
                    Clear("Voucher Info required");
                    Clear("Account Type");
                    Clear("Account No.");
                    Clear("CardNo. Select");
                    Clear(Amount);
                    Clear("Tender Description");
                end;
            end;
        }
        field(11; "Card No."; Code[20])
        {
            Caption = 'Card No.';
            Description = 'POS0007';
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
                RemAmt := TransHead."Amount incl. VAT" + TransHead."Payment Amount";
                if "Voucher Info required" then begin
                    Voucher.Get("Card No.", 0);
                    Voucher.CalcFields("Remaining Amount");
                    if RemAmt >= Voucher."Remaining Amount" then
                        Amount := -Voucher."Remaining Amount"
                    else
                        Amount := -RemAmt;
                end else
                    if "CardNo. Select" then begin
                        Amount := -RemAmt;
                    end else
                        FieldError("Card No.");
            end;
        }
        field(20; Amount; Decimal)
        {
            Caption = 'Amount';

            trigger OnValidate()
            var
                RemAmt: Decimal;
            begin
                TransHead.Get("Store No.", "POS Terminal No.", "Transaction No.");
                TransHead.CalcFields("Amount incl. VAT", "Payment Amount");
                RemAmt := Abs(TransHead."Amount incl. VAT") - Abs(TransHead."Payment Amount");
                if ("Voucher Info required" or "CardNo. Select") and ("Card No." = '') then
                    Error(Text003);

                if "Voucher Info required" then begin
                    Voucher.Get("Card No.", 0);
                    Voucher.CalcFields("Remaining Amount");
                    if -Amount > Voucher."Remaining Amount" then
                        Error(Text004, CSLFunction.FormatDec(Voucher."Remaining Amount", 2, false));
                end;

                if "CardNo. Select" or not "Overtender Allowed" then begin
                    if Abs(Amount) > RemAmt then
                        Error(Text004, CSLFunction.FormatDec(RemAmt - xRec.Amount, 2, false));
                end;
            end;
        }
        field(21; "Change Line"; Boolean)
        {
        }
        field(50; "Safe Type"; Enum "CCS CASH Payment Safe Type")
        {
            Caption = 'Safe Type';
        }
        field(51; "Tender Description"; Text[50])
        {
            Caption = 'Payment Description';
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
            Caption = 'Overtender allowed';
        }
        field(150; "Account Type"; enum "CCS CASH Account Type")
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
    }

    keys
    {
        key(Key1; "Store No.", "POS Terminal No.", "Transaction No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = Amount;
        }
        key(Key2; "Store No.", "POS Terminal No.", "Creation Date", "Safe Type")
        {
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
    }

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
        Voucher: Record "CCS CASH Voucher Entry";
        Text003: Label 'Must not be used.';
        TransHead: Record "CCS CASH POS Transaction Hdr.";
        Text004: Label 'The Payment Amount must not be higher than %1.', Comment = '%1=Value 1';
        CSLFunction: Codeunit "CCS CASH POS Register Func";
}