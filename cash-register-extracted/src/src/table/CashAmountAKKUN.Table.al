table 1070559 "CCS CASH Cash Amount AKKU N"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "POS Terminal No."; Code[20])
        {
            NotBlank = true;

            trigger OnValidate()
            begin
                GetNextEntry();
            end;
        }
        field(2; "Entry No."; Integer)
        {
        }
        field(5; "Entry Type"; Enum "CCS CASH AKKU Entry Type")
        {

            trigger OnValidate()
            begin
                InitPositions();
            end;
        }
        field(6; "Staff ID"; Code[20])
        {
        }
        field(10; "Receipt No."; Code[20])
        {
        }
        field(11; "Posting Date"; Date)
        {
        }
        field(12; "VAT Identifier"; Code[10])
        {
        }
        field(13; "VAT %"; Decimal)
        {
        }
        field(20; "Transaction No."; Integer)
        {
        }
        field(50; "Date filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(51; "VAT Identifier Filter"; Code[10])
        {
            FieldClass = FlowFilter;
        }
        field(52; "Prev Amt. Filter"; Text[30])
        {
            Caption = 'Prev. Amount Filter';
        }
        field(101; Amount; Decimal)
        {
        }
        field(102; "VAT Amount"; Decimal)
        {
        }
        field(111; "Net Amount"; Decimal)
        {

            trigger OnValidate()
            begin
                InitPositions();
            end;
        }
        field(200; MStart; Integer)
        {
        }
        field(201; MFilter; Text[30])
        {
        }
        field(202; "MFilter-1"; Text[30])
        {
        }
        field(211; "Month Sum"; Decimal)
        {
            CalcFormula = Sum("CCS CASH Cash Amount AKKU N".Amount WHERE("POS Terminal No." = FIELD("POS Terminal No."),
                                                                 "Entry No." = FIELD(FILTER(MFilter)),
                                                                 "VAT Identifier" = FIELD(FILTER("VAT Identifier Filter"))));
            FieldClass = FlowField;
        }
        field(212; "Prev. Month Sum"; Decimal)
        {
            CalcFormula = Sum("CCS CASH Cash Amount AKKU N".Amount WHERE("POS Terminal No." = FIELD("POS Terminal No."),
                                                                 "Entry No." = FIELD(FILTER("MFilter-1")),
                                                                 "VAT Identifier" = FIELD("VAT Identifier Filter")));
            FieldClass = FlowField;
        }
        field(300; YStart; Integer)
        {
        }
        field(301; YFilter; Text[30])
        {
        }
        field(302; "YFilter-1"; Text[30])
        {
        }
        field(311; "Year Sum"; Decimal)
        {
            CalcFormula = Sum("CCS CASH Cash Amount AKKU N".Amount WHERE("POS Terminal No." = FIELD("POS Terminal No."),
                                                                 "Entry No." = FIELD(FILTER(YFilter)),
                                                                 "VAT Identifier" = FIELD("VAT Identifier Filter")));
            FieldClass = FlowField;
        }
        field(312; "Prev. Year Sum"; Decimal)
        {
            CalcFormula = Sum("CCS CASH Cash Amount AKKU N".Amount WHERE("POS Terminal No." = FIELD("POS Terminal No."),
                                                                 "Entry No." = FIELD(FILTER("YFilter-1")),
                                                                 "VAT Identifier" = FIELD("VAT Identifier Filter")));
            FieldClass = FlowField;
        }
        field(411; "Amount Total"; Decimal)
        {
            CalcFormula = Sum("CCS CASH Cash Amount AKKU N".Amount WHERE("POS Terminal No." = FIELD("POS Terminal No."),
                                                                 "Posting Date" = FIELD("Date filter"),
                                                                 "VAT Identifier" = FIELD("VAT Identifier Filter")));
            FieldClass = FlowField;
        }
        field(412; "Prev Amount Total"; Decimal)
        {
            CalcFormula = Sum("CCS CASH Cash Amount AKKU N".Amount WHERE("POS Terminal No." = FIELD("POS Terminal No."),
                                                                 "Entry No." = FIELD(FILTER("Prev Amt. Filter"))));
            Caption = 'Prev. Amount Total';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "POS Terminal No.", "Entry No.")
        {
            Clustered = true;
            SumIndexFields = Amount;
        }
        key(Key2; "VAT Identifier", "POS Terminal No.", "Entry No.")
        {
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Entry No." = 0 then
            GetNextEntry();
    end;

    trigger OnRename()
    begin
        Error(Text003);
    end;

    var
        CSLAkku: Record "CCS CASH Cash Amount AKKU N";
        Text003: Label 'Rename not allowed.';
        Text004: Label 'Must not be empty.';

    local procedure InitPositions()
    begin
        if YStart <> 0 then
            exit;
        if "Entry No." = 0 then
            GetNextEntry();

        case "Entry Type" of
            "Entry Type"::MSUM,
          "Entry Type"::YSUM,
          "Entry Type"::IO:
                InsertIOPosition();
            "Entry Type"::MSTART:
                InsertMPosition();
            "Entry Type"::YSTART:
                InsertYPosition();
        end;
    end;

    local procedure GetNextEntry()
    begin
        if "Entry No." <> 0 then
            exit;
        if "POS Terminal No." = '' then
            FieldError("POS Terminal No.", Text004);

        CSLAkku.SetRange("POS Terminal No.", "POS Terminal No.");
        if CSLAkku.FindLast() then
            "Entry No." := CSLAkku."Entry No.";
        "Entry No." += 1;
    end;

    local procedure InsertIOPosition()
    begin
        CSLAkku.Reset();
        CSLAkku.Get("POS Terminal No.", "Entry No." - 1);
        YStart := CSLAkku.YStart;
        MStart := CSLAkku.MStart;
        CreateFilters();
    end;

    local procedure InsertYPosition()
    begin
        YStart := "Entry No.";
        MStart := "Entry No.";
        CreateFilters();
    end;

    local procedure InsertMPosition()
    begin
        CSLAkku.Reset();
        CSLAkku.Get("POS Terminal No.", "Entry No." - 1);
        YStart := CSLAkku.YStart;
        MStart := "Entry No.";
        CreateFilters();
    end;

    local procedure CreateFilters()
    begin
#pragma warning disable AA0217
        if (YStart = 0) or (YStart = "Entry No.") then begin
            YFilter := '0';
            "YFilter-1" := '0';
        end else begin
            YFilter := StrSubstNo('%1..%2', Format(YStart), Format("Entry No."));
            "YFilter-1" := StrSubstNo('%1..%2', Format(YStart), Format("Entry No." - 1));
        end;
        if (MStart = 0) or (MStart = "Entry No.") then begin
            MFilter := '0';
            "MFilter-1" := '0';
        end else begin
            MFilter := StrSubstNo('%1..%2', Format(MStart), Format("Entry No."));
            "MFilter-1" := StrSubstNo('%1..%2', Format(MStart), Format("Entry No." - 1));
        end;

        "Prev Amt. Filter" := StrSubstNo('..%1', "Entry No." - 1);
#pragma warning restore AA0217
    end;

}