table 1070566 "CCS CASH Sign Service Helper"
{
    DataClassification = CustomerContent;
    Caption = 'Sign Service Helper';

    fields
    {
        field(1; "Store No."; Code[20])
        {
            Caption = 'Store No.';
        }
        field(2; "POS Terminal No."; Code[20])
        {
            Caption = 'POS Terminal No.';
        }
        field(10; "WebService Active"; Boolean)
        {
            Caption = '"WebService Active"';
            Editable = false;
        }

    }

    keys
    {
        key(PK; "Store No.", "POS Terminal No.")
        {
            Clustered = true;
        }
    }
}