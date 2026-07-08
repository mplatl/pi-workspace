table 1070561 "CCS CASH Trans. Depot Entry"
{
    Caption = 'Trans. Depot Entry';
    DataCaptionFields = "Store No.", "POS Terminal No.", "Transaction No.";
    DrillDownPageID = "CCS CASH Trans. Safe List";
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
            TableRelation = "CCS CASH Store Tender Type".Code WHERE("Store No" = FIELD("Store No."),
                                                            TenderFunction = FILTER(Normal | Card));
        }
        field(20; Amount; Decimal)
        {
            Caption = 'Amount';

            trigger OnValidate()
            begin
            end;
        }
        field(21; "Change Line"; Decimal)
        {
            Caption = 'Change Line';
        }
        field(50; "Depot Type"; Option)
        {
            Caption = 'Depot Type';
            OptionCaption = ' ,Bank,Fixed Float';
            OptionMembers = " ",Bank,"Fixed Float";
        }
        field(51; Description; Text[50])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(100; "Creation Date"; Date)
        {
            Caption = 'Date';
            Editable = false;
        }
        field(101; "Creation Time"; Time)
        {
            Caption = 'Time';
            Editable = false;
        }
        field(102; "Staff ID"; Code[20])
        {
            Caption = 'Staff ID';
            TableRelation = "CCS CASH Staff";
        }
        field(150; "Account Type"; enum "CCS CASH Account Type")
        {
            Caption = 'Account Type';
        }
        field(151; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = IF ("Account Type" = CONST("G/L Account")) "G/L Account"."No." WHERE("Account Type" = CONST(Posting))
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account"."No.";
        }
        field(200; "Tender Decl. Key"; Integer)
        {
            Caption = 'Decl. Key';
        }
    }

    keys
    {
        key(Key1; "Store No.", "POS Terminal No.", "Transaction No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = Amount;
        }
        key(Key2; "Store No.", "POS Terminal No.", "Tender Type", "Depot Type", "Creation Date")
        {
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        TransHead.Get("Store No.", "POS Terminal No.", "Transaction No.");
        "Staff ID" := TransHead."Staff ID";
        "Creation Date" := Today;
        "Creation Time" := Time;
    end;

    var
        TransHead: Record "CCS CASH POS Transaction Hdr.";
}