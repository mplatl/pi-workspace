table 1070553 "CCS CASH Trans. Cash Decl. E."
{
    Caption = 'Trans. Cash Tender Operation';
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
            TableRelation = "CCS CASH POS Transaction Hdr."."Transaction No.";
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; "Decl. Key"; Integer)
        {
            Caption = 'Decl. Key';
        }
        field(10; "Tender Type"; Code[20])
        {
            Caption = 'Payment Type';
            TableRelation = "CCS CASH Store Tender Type" WHERE("Store No" = FIELD("Store No."));
        }
        field(11; "Card No."; Code[20])
        {
            Caption = 'Card No.';
        }
        field(12; Quantity; Integer)
        {
            Caption = 'Quantity';

            trigger OnValidate()
            begin
                Amount := "Base Amount" * Quantity;
            end;
        }
        field(13; Type; enum "CCS CASH Decl. Option Entry")
        {
            Caption = 'Type';
        }
        field(14; "Base Amount"; Decimal)
        {
            Caption = 'Base Amount';
        }
        field(20; Amount; Decimal)
        {
            BlankZero = true;
            Caption = 'Amount';
        }
        field(100; "Creation Date"; Date)
        {
            Caption = 'Date';
        }
        field(101; "Creation Time"; Time)
        {
            Caption = 'Creation Time';
        }
        field(102; "Staff ID"; Code[20])
        {
            Caption = 'Staff ID';
        }
    }

    keys
    {
        key(Key1; "Store No.", "POS Terminal No.", "Transaction No.", "Decl. Key", "Line No.")
        {
            Clustered = true;
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
        TransHead: Record "CCS CASH POS Transaction Hdr.";
}