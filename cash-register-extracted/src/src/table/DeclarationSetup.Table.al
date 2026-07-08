table 1070548 "CCS CASH Declaration Setup"
{
    Caption = 'Tender Operation Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store No."; Code[20])
        {
            Caption = 'Store No.';
        }
        field(2; "Tender Type"; Code[20])
        {
            Caption = 'Payment Type';
            TableRelation = "CCS CASH Tender Type Setup".Code;
        }
        field(4; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(10; Type; enum "CCS CASH Decl. Option")
        {
            Caption = 'Type';
        }
        field(11; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(12; Description; Text[30])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Store No.", "Tender Type", "Currency Code", Type, Amount)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}