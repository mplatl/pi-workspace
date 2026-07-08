table 1070565 "CCS CASH Cash Pmt. Suggestion"
{
    Caption = 'Cash Amount Suggestion';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(2; "Cash Amount"; Decimal)
        {
            Caption = 'Cash Amount';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}