table 1070551 "CCS CASH Trans. Sales Entry"
{
    Caption = 'Trans. Sales Entry';
    Permissions = TableData "Cust. Ledger Entry" = rm;
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
        field(4; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(9; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(10; Type; Enum "Sales Line Type")
        {
            Caption = 'Type';
        }
        field(11; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(" ")) "Standard Text".Code
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account"."No."
            ELSE
            IF (Type = CONST(Item)) Item."No."
            ELSE
            IF (Type = CONST(Resource)) Resource."No.";
        }
        field(12; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
            Description = 'CC 50>100';
        }
        field(30; "Gen. Prod.Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(31; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(35; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
        }
        field(50; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
        }
        field(51; "Unit Price incl. VAT"; Decimal)
        {
            Caption = 'Unit Price incl. VAT';
        }
        field(52; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(60; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(61; "Amount incl. VAT"; Decimal)
        {
            Caption = 'Amount incl. VAT';
        }
        field(62; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
        }
        field(90; "Source Entry No."; Integer)
        {
            Caption = 'Source Entry No.';
        }
        field(100; "Price Changed"; Boolean)
        {
            Caption = 'Price Changed';
        }
        field(101; "Original Unit Price"; Decimal)
        {
            Caption = 'Original Unit Price';
        }
        field(110; "Line Discount Amt."; Decimal)
        {
            Caption = 'Line Discount Amt.';
        }
        field(111; "Invoice Discount Amt."; Decimal)
        {
            Caption = 'Invoice Discount Amt.';
        }
        field(120; IsVoucher; Boolean)
        {
            Caption = 'Is a Voucher';
            Description = 'POS0007';
        }
        field(121; "Voucher Card No."; Code[20])
        {
            Caption = 'Voucher Card No.';
            Description = 'POS0007';
        }
        field(122; "Voucher Serial No."; Code[20])
        {
            Caption = 'Voucher Serial No.';
            Description = 'POS0007';
        }
        field(200; "Creation Date"; Date)
        {
            Caption = 'Date';
        }
        field(201; "Creation Time"; Time)
        {
            Caption = 'Creation Time';
        }
        field(202; "Staff ID"; Code[20])
        {
            Caption = 'Staff ID';
            TableRelation = "CCS CASH Staff";
        }
        field(300; "Pmt. Discount Date"; Date)
        {
            Caption = 'Payment Discount Date';
            Description = 'POS0004';

            trigger OnValidate()
            begin
                //--POS0004
                CustLedgEntry.Get("Source Entry No.");
                CustLedgEntry.TestField(Open, true);
                CustLedgEntry."Pmt. Discount Date" := "Pmt. Discount Date";
                SetTolerancePayment();
                CustLedgEntry.Modify(true);
                CalculatePaymentDiscAmount();
                //++POS0004
            end;
        }
        field(301; "Remaining Pmt. Disc. Possible"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Rem. Pmt. Disc. Possible';
            Description = 'POS0004';
            MaxValue = 0;

            trigger OnValidate()
            begin
                //--POS0004
                if "Remaining Pmt. Disc. Possible" * "Amount incl. VAT" < 0 then
                    FieldError("Remaining Pmt. Disc. Possible", StrSubstNo(Text000, FieldCaption("Amount incl. VAT")));

                if Abs("Remaining Pmt. Disc. Possible") > Abs(Amount) then
                    FieldError("Remaining Pmt. Disc. Possible", StrSubstNo(Text001, FieldCaption(Amount)));

                CustLedgEntry.Get("Source Entry No.");
                CustLedgEntry.TestField(Open, true);
                CustLedgEntry."Remaining Pmt. Disc. Possible" := -"Remaining Pmt. Disc. Possible";
                SetTolerancePayment();
                CustLedgEntry.Modify(true);
                CalculatePaymentDiscAmount();
                //++POS0004
            end;
        }
        field(302; "Pmt. Disc. Tolerance Date"; Date)
        {
            Caption = 'Pmt. Disc. Tolerance Date';

            trigger OnValidate()
            begin
                //--POS0004
                CustLedgEntry.Get("Source Entry No.");
                CustLedgEntry.TestField(Open, true);
                CustLedgEntry."Pmt. Disc. Tolerance Date" := "Pmt. Disc. Tolerance Date";
                SetTolerancePayment();
                CustLedgEntry.Modify(true);
                CalculatePaymentDiscAmount();
                //++POS0004
            end;
        }
        field(303; "Original Pmt. Disc. Possible"; Decimal)
        {
            Caption = 'Original Payment Discount';
        }
    }

    keys
    {
        key(Key1; "Store No.", "POS Terminal No.", "Transaction No.", "Entry No.")
        {
            Clustered = true;
            SumIndexFields = Amount, "Amount incl. VAT", "VAT Amount", "Invoice Discount Amt.";
        }
        key(Key2; "Store No.", "POS Terminal No.", "Transaction No.")
        {
            SumIndexFields = Amount, "Amount incl. VAT";
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
        TransHead: Record "CCS CASH POS Transaction Hdr.";
        Text000: Label 'must have the same sign as %1', Comment = '%1=Value 1';
        Text001: Label 'must not be larger than %1', Comment = '%1=Value 1';
        CustLedgEntry: Record "Cust. Ledger Entry";
        TransSales: Record "CCS CASH Trans. Sales Entry";
        PaymentDiscAmount: Decimal;
        TransHead2: Record "CCS CASH POS Transaction Hdr.";

    local procedure CalculatePaymentDiscAmount()
    var
        CCSCASHCashSalesSetup: Record "CCS CASH Cash Sales Setup";
    begin
        //--POS0004
        CCSCASHCashSalesSetup.Get();
        Clear(PaymentDiscAmount);
        TransHead2.Get("Store No.", "POS Terminal No.", "Transaction No.");
        TransSales.SetRange("Store No.", "Store No.");
        TransSales.SetRange("POS Terminal No.", "POS Terminal No.");
        TransSales.SetRange("Transaction No.", "Transaction No.");
        if TransSales.FindSet() then
            repeat
                if TransSales."Entry No." = "Entry No." then
                    TransSales := Rec;
                if TransHead2."Creation Date" <= TransSales."Pmt. Discount Date" then
                    PaymentDiscAmount := PaymentDiscAmount + TransSales."Remaining Pmt. Disc. Possible"
                else begin
                    if CCSCASHCashSalesSetup."Pmt. Disc. Tolerance Date" then
                        if TransHead2."Creation Date" <= TransSales."Pmt. Disc. Tolerance Date" then
                            PaymentDiscAmount := PaymentDiscAmount + TransSales."Remaining Pmt. Disc. Possible";
                end;
            until TransSales.Next() = 0;
        TransHead2."Payment Discount Amount" := Round(PaymentDiscAmount, 0.01);
        TransHead2.Modify();
        //++POS0004
    end;

    local procedure SetTolerancePayment()
    begin
        if (CustLedgEntry."Pmt. Disc. Tolerance Date" >= Rec."Creation Date") and
        (CustLedgEntry."Pmt. Discount Date" < Rec."Creation Date") and (Rec."Remaining Pmt. Disc. Possible" <> 0) then
            CustLedgEntry."Accepted Pmt. Disc. Tolerance" := true;
    end;
}