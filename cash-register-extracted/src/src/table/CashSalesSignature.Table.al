table 1070562 "CCS CASH Cash Sales Signature"
{
    Caption = 'Cash Sales Signature';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Prim. Key"; Code[20])
        {
            Caption = 'Prim. Key';
        }
    }

    keys
    {
        key(Key1; "Prim. Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}