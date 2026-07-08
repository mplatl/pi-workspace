table 1070549 "CCS CASH EFT Terminal Profile"
{
    DataClassification = CustomerContent;
    fields
    {
        field(3; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(4; Description; Text[50])
        {
            Caption = 'Description';
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