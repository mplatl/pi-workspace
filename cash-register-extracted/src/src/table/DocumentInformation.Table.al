table 1070567 "CCS CASH Document Information"
{
    DataClassification = CustomerContent;


    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Primary Key', Locked = true;
        }
        field(2; "Message Text"; Text[250])
        {
            Caption = 'Message Text';
        }
        field(3; "QR Code Left"; Blob)
        {
            Caption = 'QR-Code Left';
        }
        field(4; "QR Code Middle"; Blob)
        {
            Caption = 'QR-Code Middle';
        }
        field(5; "QR Code Right"; Blob)
        {
            Caption = 'QR-Code Right';
        }
        field(6; "Tag Label"; Text[250])
        {
            Caption = 'Receipt Message';
        }
    }

    keys
    {
        key(PK; "EntryNo")
        {
            Clustered = true;
        }
    }
}