table 1070546 "CCS CASH Tender Type C. Setup"
{
    Caption = 'Payment Type Setup';
    DataClassification = CustomerContent;
    DataCaptionFields = "Store No", "Card No.";

    fields
    {
        field(1; "Card No."; Code[20])
        {
            Caption = 'Type';
        }
        field(2; "Tender Type"; Code[20])
        {
            Caption = 'Payment Type';
            TableRelation = "CCS CASH Store Tender Type".Code WHERE("Store No" = FIELD("Store No"));
        }
        field(3; "Store No"; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "CCS CASH Store";
        }
        field(11; Description; Text[50])
        {
            Caption = 'Description';
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

            trigger OnValidate()
            begin
                "Account Description" := '';
                case "Account Type" of
                    "Account Type"::"G/L Account":
                        if GLAcc.Get("Account No.") then
                            "Account Description" := GLAcc.Name;
                    "Account Type"::"Bank Account":
                        if BankAcc.Get("Account No.") then
                            "Account Description" := BankAcc.Name;
                end;
            end;
        }
        field(152; "Account Description"; Text[100])
        {
            Caption = 'Acc. Description';
            Editable = false;
        }
        field(155; "Diff. Acc. Type"; enum "CCS CASH Account Type")
        {
            Caption = 'Diff. Acc. Type';
        }
        field(156; "Diff. Account"; Code[20])
        {
            Caption = 'Diff. Account';
            TableRelation = IF ("Diff. Acc. Type" = CONST("G/L Account")) "G/L Account" WHERE("Account Type" = CONST(Posting))
            ELSE
            IF ("Diff. Acc. Type" = CONST("Bank Account")) "Bank Account";

            trigger OnValidate()
            begin
                "Diff Account Description" := '';
                case "Diff. Acc. Type" of
                    "Diff. Acc. Type"::"G/L Account":
                        if GLAcc.Get("Diff. Account") then
                            "Diff Account Description" := GLAcc.Name;
                    "Diff. Acc. Type"::"Bank Account":
                        if BankAcc.Get("Diff. Account") then
                            "Diff Account Description" := BankAcc.Name;
                end;
            end;
        }
        field(157; "Diff Account Description"; Text[100])
        {
            Caption = 'Diff. Account Description';
            Editable = false;
        }
        field(200; CountTransaction; Integer)
        {
            Caption = 'Transactions Count';
        }
    }

    keys
    {
        key(Key1; "Store No", "Tender Type", "Card No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Card No.", Description)
        {
        }
    }

    var
        GLAcc: Record "G/L Account";
        BankAcc: Record "Bank Account";
}