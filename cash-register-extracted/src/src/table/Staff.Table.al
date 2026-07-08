table 1070543 "CCS CASH Staff"
{
    Caption = 'Cashier';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Code[20])
        {
            Caption = 'ID';
        }
        field(10; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(11; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
        }
        field(15; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(50; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(51; "Short Code"; Code[4])
        {
            Caption = 'Short Code';
        }
        field(52; "Name on Receipt"; Text[50])
        {
            Caption = 'Name on Receipt';
        }
        field(60; Password; Text[2048])
        {
            Caption = 'Password';
            ExtendedDatatype = Masked;
        }
        field(62; "Need Password Change"; Boolean)
        {
            Caption = 'Need Password Change';
        }
        field(100; "Max Disc. per Transaction"; Decimal)
        {
            Caption = 'Max. Invoice Discount';
            DecimalPlaces = 1 : 1;
        }
        field(102; "Returns allowed"; Boolean)
        {
            Caption = 'Returns allowed';
        }
        field(103; "Expenses allowed"; Boolean)
        {
            Caption = 'Expenses allowed';
        }
        field(104; "Price Change allowed"; Boolean)
        {
            Caption = 'Price Change allowed';
        }
        field(105; "Deposits allowed"; Boolean)
        {
            Caption = 'Deposits allowed';
        }
        field(106; "Remaining Pmt. Disc. allowed"; Boolean)
        {
            Caption = 'Remaining Payment Discount Possible changing allowed';
        }
        field(110; "Max. Cash Amt. Diff %"; Decimal)
        {
            Caption = 'Max. Cash Amount Diff. %';
        }
        field(111; "Max Cash Amt. Diff."; Decimal)
        {
            Caption = 'Max. Cash Amount Diff.';
        }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        TransH: Record "CCS CASH POS Transaction Hdr.";
    begin
        TransH.SetRange("Staff ID", ID);
        if not TransH.IsEmpty then
            Error(Text003, ID, Name);
    end;

    trigger OnInsert()
    var
        "No.SeriesCode": Code[20];
    begin
        if ID = '' then begin
            RetailSetup.Get();
            RetailSetup.TestField("Staff Nos.");
            NoSeriesMgt.InitSeries(RetailSetup."Staff Nos.", "No.SeriesCode", 0D, ID, "No.SeriesCode");
        end;
    end;

    var
        RetailSetup: Record "CCS CASH Cash Sales Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Text002: Label 'Staff %1 already exists.', Comment = '%1=Value 1';
        Text003: Label 'Staff %1 %2 can not be deleted, transactions are available.\Use block instead.', Comment = '%1=Value 1,%2=Value 2';

    internal procedure AssistEdit(): Boolean
    var
        Staff: Record "CCS CASH Staff";
        Staff2: Record "CCS CASH Staff";
        "No.SeriesCode": Code[20];
    begin
        Staff.Copy(Rec);
        RetailSetup.Get();
        RetailSetup.TestField("Staff Nos.");
        "No.SeriesCode" := RetailSetup."Staff Nos.";
        if NoSeriesMgt.SelectSeries("No.SeriesCode", RetailSetup."Staff Nos.", "No.SeriesCode") then begin
            NoSeriesMgt.SetSeries(Staff.ID);
            if Staff2.Get(Staff.ID) then
                Error(Text002, Staff.ID);
            Rec := Staff;
            exit(true);
        end;
    end;

    internal procedure GeStaffPassword(): Text[2048]
    var
        PosRegFunctions: Codeunit "CCS CASH POS Register Func";
    begin
        if System.EncryptionEnabled() and System.EncryptionKeyExists() then
            if PosRegFunctions.isBase64(Rec.Password) then
                exit(CopyStr(System.Decrypt(Rec.Password), 1, MaxStrLen(Rec.Password)));
        exit(Rec.Password);
    end;

    internal procedure SetStaffNewPassword(NewPassword: Text[2048])
    begin
        if (System.EncryptionEnabled() and System.EncryptionKeyExists()) and (NewPassword <> '') then
            Rec.Password := CopyStr(System.Encrypt(NewPassword), 1, MaxStrLen(Rec.Password))
        else
            Rec.Password := NewPassword;
    end;
}