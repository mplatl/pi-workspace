table 1070558 "CCS CASH Temp Amount Tendered"
{
    Caption = 'Temp Amount Tendered';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            Caption = 'Primary Key', Locked = true;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
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
    }

    keys
    {
        key(Key1; "Primary Key", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}