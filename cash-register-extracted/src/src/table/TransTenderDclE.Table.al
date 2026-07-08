table 1070560 "CCS CASH Trans. Tender Dcl. E."
{
    Caption = 'Tender Operation';
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
            TableRelation = "CCS CASH Tender Type Setup".Code;
        }
        field(11; "Card No."; Code[20])
        {
            Caption = 'Card No.';
        }
        field(12; "Tender Type Text"; Text[50])
        {
            Caption = 'Payment Type Text';
        }
        field(20; "Bank Amount"; Decimal)
        {
            Caption = 'Bank Amount';

            trigger OnValidate()
            begin
                "Total Amount" := "Bank Amount" + "Fixed Amount";
                "Diff. Amount" := "Total Amount" - "Cash Amount";
                TransH.Get("Store No.", "POS Terminal No.", "Transaction No.");
                if not (TransH."Transaction Type" in [TransH."Transaction Type"::EndDay, TransH."Transaction Type"::Startday]) then
                    "Diff. Amount" := 0;
            end;
        }
        field(21; "Fixed Amount"; Decimal)
        {
            Caption = 'Cash Counted';

            trigger OnValidate()
            begin
                "Total Amount" := "Bank Amount" + "Fixed Amount";
                "Diff. Amount" := "Total Amount" - "Cash Amount";
            end;
        }
        field(22; "Cash Amount"; Decimal)
        {
            Caption = 'POS Amount';

            trigger OnValidate()
            begin
                Validate("Bank Amount");
            end;
        }
        field(50; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            Editable = false;
        }
        field(51; "Diff. Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Diff. Amount';
            Editable = false;
        }
        field(110; "Counting Required"; Boolean)
        {
            Caption = 'Counting Required';
        }
        field(200; "Fiskal Zero Document"; Boolean)
        {
            Caption = 'Zero Document';
        }
    }

    keys
    {
        key(Key1; "Store No.", "POS Terminal No.", "Transaction No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        TransH: Record "CCS CASH POS Transaction Hdr.";
}