table 1070541 "CCS CASH Store"
{
    Caption = 'Store';
    DataClassification = CustomerContent;
    LookupPageId = "CCS CASH Store List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'Store No.';

            trigger OnValidate()
            begin
                RetailSetup.Get();
                if "No." <> xRec."No." then
                    NoSeriesMgt.TestManual(RetailSetup."Store Nos.");

                "Default Customer" := RetailSetup."Default Customer";
                "Default Qty. at POS" := RetailSetup."Default Quantity at POS";
                "Receipt Nos." := RetailSetup."Receipt Nos.";
                "Posted Receipt Nos." := RetailSetup."Posted Receipt Nos.";
            end;
        }
        field(2; "Respons. Center Code"; Code[10])
        {
            Caption = 'Respons. Center Code';
            TableRelation = "Responsibility Center";

            trigger OnValidate()
            var
                RespCent: Record "Responsibility Center";
            begin
                if RespCent.Get("Respons. Center Code") then
                    "Name 2" := RespCent.Name;
            end;
        }
        field(10; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(11; "Name 2"; Text[100])
        {
            Caption = 'Name 2';
        }
        field(12; Address; Text[50])
        {
            Caption = 'Address';
        }
        field(13; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(14; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code"
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                locCity: Text[30];
            begin
                locCity := CopyStr(Rec.City, 1, MaxStrLen(locCity));
                PostCode.ValidatePostCode(locCity, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
                Rec.City := locCity;
            end;
        }
        field(15; City; Text[50])
        {
            Caption = 'City';
        }
        field(16; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(17; County; Text[30])
        {
            Caption = 'County';
        }
        field(20; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(25; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(26; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            ExtendedDatatype = EMail;
        }
        field(27; "Home Page"; Text[80])
        {
            Caption = 'Home Page';
            ExtendedDatatype = URL;
        }
        field(100; "Default Customer"; Code[20])
        {
            Caption = 'Default Customer';
            TableRelation = Customer;
        }
        field(102; "Default Qty. at POS"; Decimal)
        {
            Caption = 'Default Qty. at POS';
            DecimalPlaces = 0 : 4;
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
        field(205; "Z-Report Nos."; Code[20])
        {
            Caption = 'Z-Report Nos.';
            Enabled = false;
            TableRelation = "No. Series";
        }
        field(301; "Daily Statement necessary"; Boolean)
        {
            Caption = 'Daily Statement necessary';
        }
        field(500; Picture; BLOB)
        {
            Caption = 'Logo', Locked = true;
        }
        field(501; "Logo Position on Documents"; enum "CCS CASH Logo Position on Doc.")
        {
            Caption = 'Logo Position on Documents';
        }
        field(502; Logo; Media)
        {
            Caption = 'Logo', Locked = true;
        }
        field(1000; "Aftertext Invoice"; Code[20])
        {
            Caption = 'Invoice Aftertext';
            TableRelation = "Standard Text";
        }
        field(1001; "Aftertext Payment Conf."; Code[20])
        {
            Caption = 'Payment Confirmation Aftertext';
            TableRelation = "Standard Text";
        }
        field(1002; "Pre-Text Person in Charge"; Text[100])
        {
            Caption = 'Pre Text Person in Charge';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        POSTerm.SetRange("Store No", "No.");
        if POSTerm.FindFirst() then
            Error(Text001, POSTerm."No.");
    end;

    trigger OnInsert()
    var
        "No. Series": Code[20];
    begin
        if "No." = '' then begin
            RetailSetup.Get();
            RetailSetup.TestField("Store Nos.");
            NoSeriesMgt.InitSeries(RetailSetup."Store Nos.", "No. Series", 0D, "No.", "No. Series");
            "Default Customer" := RetailSetup."Default Customer";
            "Default Qty. at POS" := RetailSetup."Default Quantity at POS";
            "Receipt Nos." := RetailSetup."Receipt Nos.";
            "Posted Receipt Nos." := RetailSetup."Posted Receipt Nos.";
        end;
    end;

    trigger OnRename()
    begin
        Error(Text000, TableCaption);
    end;

    var
        RetailSetup: Record "CCS CASH Cash Sales Setup";
        PostCode: Record "Post Code";
        POSTerm: Record "CCS CASH POS Terminal";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Text000: Label 'Rename a %1 is not allowed.', Comment = '%1=Value 1';
        Text001: Label 'POS Terminals are connected: %1', Comment = '%1=Value 1';
        Text002: Label 'Store %1 already exists.', Comment = '%1=Value 1';

    internal procedure AssistEdit(): Boolean
    var
        Store: Record "CCS CASH Store";
        Store2: Record "CCS CASH Store";
        "No.SeriesCode": Code[20];
    begin
        Store.Copy(Rec);
        RetailSetup.Get();
        RetailSetup.TestField("Store Nos.");
        "No.SeriesCode" := RetailSetup."Store Nos.";
        if NoSeriesMgt.SelectSeries("No.SeriesCode", RetailSetup."Store Nos.", "No.SeriesCode") then begin
            NoSeriesMgt.SetSeries(Store."No.");
            if Store2.Get(Store."No.") then
                Error(Text002, Store."No.");
            Rec := Store;
            exit(true);
        end;
    end;

    internal procedure ImportPicture()
    var
        FromFileName: Text;
        InStreamPic: InStream;
        OutStreamPic: OutStream;
    begin
        if UploadIntoStream('Import', '', 'Picture (*.bmp;*.jpg;*.jpeg;*.png)|*.bmp;*.jpg;*.jpeg;*.png', FromFileName, InStreamPic) then begin
            Rec.Logo.ImportStream(InStreamPic, FromFileName);
            Rec.Picture.CreateOutStream(OutStreamPic);
            CopyStream(OutStreamPic, InStreamPic);
            Rec.Modify();
        end;
    end;

    internal procedure DeletePicture()
    begin
        Clear(Rec.Logo);
        Rec.CalcFields(Picture);
        Clear(Rec.Picture);
        Rec.Modify();
    end;
}