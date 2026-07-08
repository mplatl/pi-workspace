table 1070568 "CCS CASH Signa. Srv. Req. Log"
{
    // fs-soft
    // 
    // Vers.      Date       ID Description
    // _____________________________________________________________________
    // EFSTA2.00  12.04.2016 MK Object created
    // EFSTA2.03  07.02.2017 MK Changed Object Name and Object Caption, Changed Fieldname Field 4 Counter -> "Entry No.",
    //                       MK Changed FieldCaption 100,101,200
    // EFSTA2.05  22.02.2017 MK Changed Caption

    Caption = 'Signature Service Request Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store No."; Code[20])
        {
            Caption = 'Store No.';
        }
        field(2; "POS Terminal No."; Code[20])
        {
            Caption = 'POS Terminal No.';
            //This property is currently not supported
            //TestTableRelation = false;
            //The property 'ValidateTableRelation' can only be set if the property 'TableRelation' is set
            //ValidateTableRelation = false;
        }
        field(3; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
        }
        field(4; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(5; "Request Type"; enum "CCS CASH Sign. Request Type")
        {
            Caption = 'Request Type';
        }
        field(10; "Package No."; Code[20])
        {
            Caption = 'Package No.';
        }
        field(50; "Response Error"; Boolean)
        {
            Caption = 'Response Error';
        }
        field(51; "Response Text"; Text[1024])
        {
            Caption = 'Response Text';
        }
        field(60; "QR Code"; Text[1024])
        {
            Caption = 'QR-Code';
        }
        field(61; "QR Picture"; BLOB)
        {
            Caption = 'QR-Picture';
            SubType = Bitmap;
        }
        field(62; "QR Picture Resized"; BLOB)
        {
            Caption = 'QR-Picture Resized';
            SubType = Bitmap;
        }
        field(70; "Error Code"; Code[250])
        {
            Caption = 'Error Code';
        }
        field(71; "User Message"; Text[1024])
        {
            Caption = 'User Message';
        }
        field(72; "Tag Label"; Text[250])
        {
            Caption = 'Tag Label';
        }
        field(100; Request; BLOB)
        {
            Caption = 'Request Sequence';
        }
        field(101; Response; BLOB)
        {
            Caption = 'Response Sequence';
            Description = 'EFSTA2.05';
        }
        field(200; "Request Timestamp"; DateTime)
        {
            Caption = 'Request Timestamp';
        }
        field(1000; "Replication Counter"; Integer)
        {
            Caption = 'Replication Counter';

            trigger OnValidate()
            var
                LocEFSTALog: Record "CCS CASH Signa. Srv. Req. Log";
            begin
                LocEFSTALog.SetCurrentKey("Replication Counter");
                if LocEFSTALog.FindLast() then
                    "Replication Counter" := LocEFSTALog."Replication Counter" + 1
                else
                    "Replication Counter" := 1;
            end;
        }
    }

    keys
    {
        key(Key1; "Store No.", "POS Terminal No.", "Transaction No.", "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Replication Counter")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        EFSTALog.SetRange("Store No.", "Store No.");
        EFSTALog.SetRange("POS Terminal No.", "POS Terminal No.");
        EFSTALog.SetRange("Transaction No.", "Transaction No.");
        if EFSTALog.FindLast() then
            "Entry No." := EFSTALog."Entry No." + 1
        else
            "Entry No." := 1;

        Validate("Replication Counter");
    end;

    trigger OnModify()
    begin
        Validate("Replication Counter");
    end;

    var
        EFSTALog: Record "CCS CASH Signa. Srv. Req. Log";
}