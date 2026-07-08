table 1070545 "CCS CASH Store Tender Type"
{
    Caption = 'Payment Type';
    LookupPageID = "CCS CASH Tender Type";
    DataClassification = CustomerContent;
    DataCaptionFields = "Store No", "Code";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = "CCS CASH Tender Type Setup";

            trigger OnValidate()
            begin
                if TenderType.Get(Code) then begin
                    TenderFunction := TenderType.TenderFunction;
                    //--POS0029
                    "Currency Code" := TenderType."Currency Code";
                    //++POS0029
                    Validate(Description, TenderType.Description);
                end;
            end;
        }
        field(2; "Store No"; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "CCS CASH Store";
        }
        field(3; "Search Description"; Code[50])
        {
            Caption = 'Search Description';
        }
        field(4; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(10; TenderFunction; enum "CCS CASH TenderFunction")
        {
            Caption = 'Function';

            trigger OnValidate()
            begin
                if xRec.TenderFunction <> Rec.TenderFunction then
                    ClearProperties();
            end;
        }
        field(11; Description; Text[50])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                if ("Search Description" = '') or ("Search Description" = UpperCase(xRec.Description)) then
                    "Search Description" := Description;
            end;
        }
        field(100; Usable; Boolean)
        {
            Caption = 'May be Used';
        }
        field(101; "Cash Drawer Opens"; Boolean)
        {
            Caption = 'Open Cash Drawer';
        }
        field(102; "Use in Returns"; Boolean)
        {
            Caption = 'Use in returns';
        }
        field(103; "Overtender allowed"; Boolean)
        {
            Caption = 'Overtender allowed';
        }
        field(110; "Counting Required"; Boolean)
        {
            Caption = 'Counting required';
        }
        field(111; "Float Allowed"; Boolean)
        {
            Caption = 'Change allowed';
        }
        field(112; "Voucher Info required"; Boolean)
        {
            Caption = 'Voucher Info required';
        }
        field(113; Cash; Boolean)
        {
            Caption = 'Cash Money';

            trigger OnValidate()
            var
                DoubleCashEntryErr: Label 'It is not allowed to have two Cash Money Payment Types.';
            begin
                if Rec.Cash = true then
                    if IsDoubleCashEntry() then
                        Error(DoubleCashEntryErr);
            end;
        }
        field(150; "Account Type"; enum "CCS CASH Account Type")
        {
            Caption = 'Account Type';

            trigger OnValidate()
            begin
                if "Account Type" <> xRec."Account Type" then
                    Validate("Account No.", '');
            end;
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

            trigger OnLookup()
            begin
                if "Diff. Acc. Type" <> xRec."Diff. Acc. Type" then
                    Validate("Diff. Account", '');
            end;
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
            Caption = 'Diff Account Description';
            Editable = false;
        }
        field(160; "Bank Account Type"; enum "CCS CASH Account Type")
        {
            Caption = 'Bank Account Type';

            trigger OnValidate()
            begin
                if "Bank Account Type" <> xRec."Bank Account Type" then
                    Validate("Bank Account No.", '');
            end;
        }
        field(161; "Bank Account No."; Code[20])
        {
            Caption = 'Bank Account No.';
            TableRelation = IF ("Bank Account Type" = CONST("G/L Account")) "G/L Account"."No." WHERE("Account Type" = CONST(Posting))
            ELSE
            IF ("Bank Account Type" = CONST("Bank Account")) "Bank Account"."No.";

            trigger OnValidate()
            begin
                "Account Description" := '';
                case "Bank Account Type" of
                    "Bank Account Type"::"G/L Account":
                        if GLAcc.Get("Bank Account No.") then
                            "Bank Account Description" := GLAcc.Name;
                    "Bank Account Type"::"Bank Account":
                        if BankAcc.Get("Bank Account No.") then
                            "Bank Account Description" := BankAcc.Name;
                end;
            end;
        }
        field(162; "Bank Account Description"; Text[100])
        {
            Caption = 'Bank Acc. Description';
            Editable = false;
        }
        field(170; "Tender Remove"; Code[20])
        {
            Caption = 'Tender Remove';
            TableRelation = "CCS CASH Tender Type Setup".Code;
        }
        field(171; "Tender Remove Description"; Text[50])
        {
            CalcFormula = Lookup("CCS CASH Tender Type Setup".Description WHERE(Code = FIELD("Tender Remove")));
            Caption = 'Tender Remove Description';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Store No", "Code", "Currency Code")
        {
            Clustered = true;
        }
        key(Key2; "Search Description")
        {
        }
        key(Key3; Cash, "Store No")
        { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description, "Search Description")
        {
            Caption = 'Payment Type';
        }
    }

    // check if there is another cash entry for this store
    local procedure IsDoubleCashEntry(): Boolean
    var
        StoreTenderType: Record "CCS CASH Store Tender Type";
    begin
        StoreTenderType.Reset();
        StoreTenderType.SetRange("Store No", Rec."Store No");
        StoreTenderType.SetRange(Cash, true);
        if not StoreTenderType.IsEmpty() then
            exit(true);
    end;


    local procedure ClearProperties()
    begin
        Rec.Validate(Cash, false);
        Rec.Validate("Counting Required", false);
        Rec.Validate("Overtender allowed", false);
        Rec.Validate("Float Allowed", false);
        Rec.Validate("Use in Returns", false);
        Rec.Validate("Voucher Info required", false);
        Rec.Validate("Tender Remove", '');
        Rec.Modify();
    end;

    var
        GLAcc: Record "G/L Account";
        BankAcc: Record "Bank Account";
        TenderType: Record "CCS CASH Tender Type Setup";
}