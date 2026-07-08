table 1070542 "CCS CASH POS Terminal"
{
    Caption = 'POS Setup';
    LookupPageID = "CCS CASH POS Terminals";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store No"; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "CCS CASH Store"."No.";

            trigger OnValidate()
            begin
                if ("Store No" <> xRec."Store No") and ("Store No" <> '') then begin
                    Store.Get("Store No");
                    "Receipt Nos." := Store."Receipt Nos.";
                    "Posted Receipt Nos." := Store."Posted Receipt Nos.";
                    "Default Qty. at POS" := Store."Default Qty. at POS";
                    "Default Customer at POS" := Store."Default Customer";
                    "Location Code" := Store."Location Code";
                    "Daily Statement necessary" := Store."Daily Statement necessary";
                end else
                    if "Store No" = '' then begin
                        RetailSetup.Get();
                        "Default Customer at POS" := RetailSetup."Default Customer";
                        "Default Qty. at POS" := RetailSetup."Default Quantity at POS";
                    end;
            end;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'POS Terminal No.';

            trigger OnValidate()
            begin
                RetailSetup.Get();
                if "No." <> xRec."No." then
                    NoSeriesMgt.TestManual(RetailSetup."POS Terminal Nos.");
            end;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(11; "Sig initialized"; Boolean)
        {
            Caption = 'Fiskal Sign. Init.';
            Description = 'Deaktivated';
            Editable = false;
        }
        field(12; "Initialization Date"; DateTime)
        {
            Caption = 'Initialization Date';
            Editable = false;

            trigger OnValidate()
            begin
                if "Initialization Date" <> 0DT then
                    "Initialization Date Voided" := 0DT;
            end;
        }
        field(13; "Initialization Date Voided"; DateTime)
        {
            Caption = 'Initialization Date Voided';
            Editable = false;
        }
        field(14; "Fiskalisation Initialized"; Boolean)
        {
            CalcFormula = lookup("CCS CASH Sign Service Helper"."WebService Active" WHERE("Store No." = FIELD("Store No"),
                                                                                  "POS Terminal No." = FIELD("No.")));
            Caption = 'Fiscalization Activated';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Cash Drawer Connection Code"; Code[20])
        {
            Caption = 'Cash Drawer Connection Code';
            TableRelation = "CCS COLI Direct Connection";
            DataClassification = CustomerContent;
        }
        field(21; "Open Cash Drawer Automatic"; Boolean)
        {
            Caption = 'Open Cash Drawer Automatic';
        }
        field(22; "Open Cash Drawer After Post"; Boolean)
        {
            Caption = 'Open Cash Drawer Only After Post';
        }
        field(99; "Open in Session"; Integer)
        {
            Caption = 'Open in Session';
        }
        field(101; "Default Customer at POS"; Code[20])
        {
            Caption = 'Default Customer at POS';
            TableRelation = Customer;
        }
        field(102; "Default Qty. at POS"; Decimal)
        {
            Caption = 'Default Qty. on POS';
            DecimalPlaces = 0 : 4;
        }
        field(103; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(150; "Fixed Tender Cash Amount"; Decimal)
        {
            Caption = 'Fixed Change Amount';
            DecimalPlaces = 2 : 2;
        }
        field(151; "Remove Tender Rounding Prec."; Code[10])
        {
            Caption = 'Levy Rounding Prec.';
            TableRelation = "Rounding Method";
        }
        field(152; "Daily Statement necessary"; Boolean)
        {
            Caption = 'Daily Statement necessary';
        }
        field(160; "Last Z-Report"; Code[20])
        {
            Caption = 'Last Z-Report';
            Editable = false;
        }
        field(170; "Exit After Each Transaction"; Boolean)
        {
            Caption = 'Exit After Each Transaction';
        }
        field(171; "Auto Log Off after (Min.)"; Integer)
        {
            Caption = 'Auto Log Off after (Min.)';
        }
        field(172; "EFT Terminal Profile"; Code[10])
        {
            Caption = 'EFT Terminal Profile';
            //TableRelation = "EFT Terminal Profile";
        }
        field(200; "Posted Receipt Nos."; Code[20])
        {
            Caption = 'Posted POS Receipt Nos.';
            TableRelation = "No. Series";
        }
        field(201; "Expense Nos."; Code[20])
        {
            Caption = 'Expense Nos.';
            Enabled = false;
            TableRelation = "No. Series";
        }
        field(202; "Day End Nos."; Code[20])
        {
            Caption = 'Day End Nos.';
            Enabled = false;
            TableRelation = "No. Series";
        }
        field(203; "Posted Day End Nos."; Code[20])
        {
            Caption = 'Posted Day End Nos.';
            Enabled = false;
            TableRelation = "No. Series";
        }
        field(204; "Receipt Nos."; Code[20])
        {
            Caption = 'POS Receipt Nos.';
            TableRelation = "No. Series";
        }
        field(300; "Drawer Opener Funcrion"; Integer)
        {
            Caption = 'Cash Drawer Opener';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));
        }
        field(301; "Drawer Opener Parameter"; Text[50])
        {
            Caption = 'Drawer Opener Parameter';
        }
        field(450; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(451; "Trans. No. Filter"; Integer)
        {
            Caption = 'Trans.-No. Filter';
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with Transaction No. Filter field';
            ObsoleteTag = 'CCS CASH 20.3.7.0';
        }
        field(452; "Transaction No. Filter"; Integer)
        {
            Caption = 'Trans.-No. Filter';
            FieldClass = FlowFilter;
        }
        field(500; "Balance at Date"; Decimal)
        {
            CalcFormula = Sum("CCS CASH Trans. Payment Entry".Amount WHERE("Store No." = FIELD("Store No"),
                                                                   "POS Terminal No." = FIELD("No."),
                                                                   "Creation Date" = FIELD("Date Filter"),
                                                                   "Cash entry" = CONST(true),
                                                                   "Receipt No." = filter(<> '')));
            Caption = 'Balance at Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(501; Balance; Decimal)
        {
            CalcFormula = Sum("CCS CASH Trans. Payment Entry".Amount WHERE("Store No." = FIELD("Store No"),
                                                                   "POS Terminal No." = FIELD("No."),
                                                                   "Cash entry" = CONST(true),
                                                                   "Receipt No." = filter(<> '')));
            Caption = 'Balance';
            FieldClass = FlowField;
        }
        field(502; "Safe Amount"; Decimal)
        {
            CalcFormula = Sum("CCS CASH Trans. Depot Entry".Amount WHERE("Store No." = FIELD("Store No"),
                                                                 "POS Terminal No." = FIELD("No."),
                                                                 "Depot Type" = CONST("Fixed Float")));
            Caption = 'Safe Content';
            FieldClass = FlowField;
        }
        field(503; "Balance at Transaction"; Decimal)
        {
            CalcFormula = Sum("CCS CASH Trans. Payment Entry".Amount WHERE("Store No." = FIELD("Store No"),
                                                                   "POS Terminal No." = FIELD("No."),
                                                                   "Transaction No." = FIELD("Transaction No. Filter"),
                                                                   "Cash entry" = CONST(true),
                                                                   "Receipt No." = filter(<> '')));
            Caption = 'Balance at Transaction';
            Editable = false;
            FieldClass = FlowField;
        }
        field(510; "Open in Server Instance ID"; Integer)
        {
            Caption = 'Server Instance ID';
        }
    }

    keys
    {
        key(Key1; "Store No", "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        POSTrans.SetRange("POS Terminal No.", "No.");
        if not POSTrans.IsEmpty then
            Error(Text001);
    end;

    trigger OnInsert()
    var
        "No. Series": Code[20];
    begin
        if "No." = '' then begin
            RetailSetup.Get();
            RetailSetup.TestField("POS Terminal Nos.");
            NoSeriesMgt.InitSeries(RetailSetup."POS Terminal Nos.", "No. Series", 0D, "No.", "No. Series");
        end;
    end;

    trigger OnRename()
    begin
        Error(Text000, TableCaption);
    end;

    var
        RetailSetup: Record "CCS CASH Cash Sales Setup";
        Store: Record "CCS CASH Store";
        POSTrans: Record "CCS CASH POS Transaction Hdr.";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Text000: Label 'Rename a %1 is not allowed.', Comment = '%1=Value 1';
        Text001: Label 'You can not delete a POS Terminal with transactions.';
        Text002: Label 'POS Terminal %1 alredy exists at Store %2.', Comment = '%1=Value 1,%2=Value 2';

    internal procedure Status(): Integer
    var
        TransHead: Record "CCS CASH POS Transaction Hdr.";
    begin
        // Return Type:
        // 0: Closed;
        // 1: Open;
        // 99: Open, "dayend" missing

        TransHead.SetRange("Store No.", "Store No");
        TransHead.SetRange("POS Terminal No.", "No.");
        TransHead.SetFilter("Transaction Type", '%1|%2', TransHead."Transaction Type"::Startday, TransHead."Transaction Type"::EndDay);
        if not TransHead.FindLast() then
            exit(0);
        if TransHead."Transaction Type" = TransHead."Transaction Type"::EndDay then
            exit(0);
        if TransHead."Creation Date" < Today then
            exit(99);
        exit(1);
    end;

    internal procedure AssistEdit(): Boolean
    var
        POSTerm: Record "CCS CASH POS Terminal";
        POSTerm2: Record "CCS CASH POS Terminal";
        "No.SeriesCode": Code[20];
    begin
        POSTerm.Copy(Rec);
        RetailSetup.Get();
        POSTerm.TestField("Store No");
        RetailSetup.TestField("POS Terminal Nos.");
        "No.SeriesCode" := RetailSetup."POS Terminal Nos.";
        if NoSeriesMgt.SelectSeries("No.SeriesCode", RetailSetup."POS Terminal Nos.", "No.SeriesCode") then begin
            NoSeriesMgt.SetSeries(POSTerm."No.");
            if POSTerm2.Get(POSTerm."Store No", POSTerm."No.") then
                Error(Text002, POSTerm2."No.", POSTerm2."Store No");
            Rec := POSTerm;
            exit(true);
        end;
    end;

    internal procedure OpenCashDrawer(CheckAutomaticOpen: Boolean)
    begin
        OpenCashDrawer(CheckAutomaticOpen, false, false);
    end;

    internal procedure OpenCashDrawer(CheckAutomaticOpen: Boolean; CheckAfterPost: Boolean; IsAfterPost: Boolean)
    var
        CCSCOLIDirectConnExecute: Codeunit "CCS COLI Direct Conn. Execute";
        PayLoad: JsonObject;
    // response: Text;
    begin
        if Rec."Cash Drawer Connection Code" <> '' then begin
            if CheckAutomaticOpen then
                if not Rec."Open Cash Drawer Automatic" then
                    exit;

            if CheckAfterPost and not IsAfterPost and Rec."Open Cash Drawer After Post" then
                exit;
            if CheckAfterPost and IsAfterPost and not Rec."Open Cash Drawer After Post" then
                exit;

            if not CCSCOLIDirectConnExecute.TryExecute(Rec."Cash Drawer Connection Code", PayLoad) then
                Message(ErrCashDrawerNotOpened + '\' + GetLastErrorText());
            // if PayLoad.WriteTo(response) then
            //     Message(response);
        end;
    end;

    var
        ErrCashDrawerNotOpened: Label 'The cash drawer could not be opened.';
}