table 1070555 "CCS CASH Voucher Entry"
{
    Caption = 'Voucher Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Voucher No."; Code[20])
        {
            Caption = 'Voucher No.';
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(3; "Store No."; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "CCS CASH Store";
        }
        field(4; "POS Terminal No"; Code[20])
        {
            Caption = 'POS Terminal No';
            TableRelation = "CCS CASH POS Terminal"."No." WHERE("Store No" = FIELD("Store No."));
        }
        field(5; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            TableRelation = "CCS CASH POS Transaction Hdr."."Transaction No." WHERE("Store No." = FIELD("Store No."),
                                                                              "POS Terminal No." = FIELD("POS Terminal No"));
        }
        field(6; "Transact. Line No."; Integer)
        {
            Caption = 'Transact. Line No.';
        }
        field(8; "Entry Type"; enum "CCS CASH Voucher Entry Type")
        {
            Caption = 'Entry Type';
        }
        field(9; Voided; Boolean)
        {
            Caption = 'Voided';
        }
        field(10; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(60; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(61; "Remaining Amount"; Decimal)
        {
            CalcFormula = Sum("CCS CASH Voucher Entry".Amount WHERE("Voucher No." = FIELD("Voucher No."),
                                                            Voided = CONST(false)));
            Caption = 'Remaining Amount';
            FieldClass = FlowField;
        }
        field(70; "Voucher Card No."; Code[20])
        {
            Caption = 'Voucher Card No.';
            Description = 'POS0007';
        }
        field(71; "Voucher No. Series"; Code[20])
        {
            Caption = 'Voucher No. Series';
            Description = 'POS0007';
        }
        field(73; "Followup Voucher No."; Code[20])
        {
            Caption = 'Followup Voucher No.';
            Description = 'POS0007';
        }
        field(100; "Date"; Date)
        {
            Caption = 'Date';
        }
        field(101; "Time"; Time)
        {
            Caption = 'Time';
        }
    }

    keys
    {
        key(Key1; "Voucher No.", "Entry No.")
        {
            Clustered = true;
            SumIndexFields = Amount;
        }
        key(Key2; "Store No.", "POS Terminal No", "Transaction No.", "Voucher Card No.", "Entry Type")
        {
            SumIndexFields = Amount;
        }
        key(Key3; "Voucher No.", "Voided")
        {
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
    }
}