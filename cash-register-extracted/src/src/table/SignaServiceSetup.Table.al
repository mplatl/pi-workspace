table 1070569 "CCS CASH Signa. Service Setup"
{
    Caption = 'Signature Service Setup';
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
            TableRelation = "CCS CASH POS Terminal"."No." where("Store No" = FIELD("Store No."));
            //This property is currently not supported
            //TestTableRelation = false;
            //The property 'ValidateTableRelation' can only be set if the property 'TableRelation' is set
            //ValidateTableRelation = false;
        }
        field(20; "WebService Main Path"; Text[100])
        {
            Caption = 'Web Service Main Path';
            InitValue = 'http://localhost:5618/register';
        }
        field(21; "WebService QR Path"; Text[100])
        {
            Caption = 'Web Service QR-Path';
            InitValue = 'http://localhost:5618/qr?text=';
        }
        field(22; "WebService State Path"; Text[100])
        {
            Caption = 'Web Service State Path';
            InitValue = 'http://localhost:5618/state';
        }
        field(50; "WebService Active"; Boolean)
        {
            Caption = 'Web Service Active';
        }
        field(51; "Print Picture"; Boolean)
        {
            Caption = 'Print Picture';
        }
        field(52; "Picture Print Position"; enum "CCS CASH Pic. Print Position")
        {
            Caption = 'Picture Print Position';
            Description = 'EFSTA2.01';
        }
        field(53; "Picture Print Option"; enum "CCS CASH Pic. Print Option")
        {
            Caption = 'Picture for Print';
        }
        field(54; "Picture Reduction Factor"; Integer)
        {
            Caption = 'Picture Reduction Factor';
            InitValue = 5;
            MinValue = 1;
        }
        field(55; "Picture Enlarge Factor"; Integer)
        {
            Caption = 'Picture Enlarge Factor';
            InitValue = 1;
        }
        field(60; "QR Picture Save Option"; enum "CCS CASH QR Pic. Save Option")
        {
            Caption = 'QR-Picture Save Option';
            Description = 'EFSTA2.05';
        }
        field(100; "Web Service Timeout ms"; Integer)
        {
            Caption = 'Web Service Timeout (ms)';
        }
        field(200; "Sign. Failure Message Type"; Option)
        {
            Caption = 'Sign. Failure Message Type';
            Description = 'EFSTA2.01';
            OptionCaption = 'No Message, On Login, Every Transaction';
            OptionMembers = "No Message","On Login","Every Transaction";
        }
        field(201; "Signature Failure Timestamp"; DateTime)
        {
            Caption = 'Sign. Failure Timestamp';
            Description = 'EFSTA2.01';
        }
        field(210; "WebService Export Path"; Text[100])
        {
            Caption = 'Web Service Export Path';
            InitValue = 'http://localhost:5618/control/export?from=%1&RN=def';
        }
    }

    keys
    {
        key(Key1; "Store No.", "POS Terminal No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}