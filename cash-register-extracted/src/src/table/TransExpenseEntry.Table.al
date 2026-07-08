table 1070554 "CCS CASH Trans. Expense Entry"
{
    Caption = 'Trans. Expense Entry';
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
            TableRelation = "CCS CASH POS Transaction Hdr."."Transaction No.";
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; Type; enum "CCS CASH Expense Type")
        {
            Caption = 'Type';
        }
        field(6; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = "CCS CASH Store Tender Type".Code WHERE(TenderFunction = CONST(Expense),
                                                            "Store No" = FIELD("Store No."));

            trigger OnValidate()
            begin
                if TenderType.Get("Store No.", "No.") then begin
                    TenderType.TestField("Account No.");
                    Description := TenderType.Description;
                    "Account Type" := TenderType."Account Type";
                    Validate("Account No.", TenderType."Account No.");
                end;
            end;
        }
        field(9; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(10; "Account Type"; enum "CCS CASH Account Type")
        {
            Caption = 'Account Type';
        }
        field(11; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = IF ("Account Type" = CONST("Bank Account")) "Bank Account"
            ELSE
            IF ("Account Type" = CONST("G/L Account")) "G/L Account";

            trigger OnValidate()
            begin
                //--POS0030
                if "Account Type" = "Account Type"::"G/L Account" then begin
                    GLAccount.Get("Account No.");
                    "VAT Bus. Posting Group" := GLAccount."VAT Bus. Posting Group";
                    "VAT Prod. Posting Group" := GLAccount."VAT Prod. Posting Group";
                    //++POS0033
                    CreateDim();
                end;

                if "VAT Bus. Posting Group" = '' then begin
                    CSLSetup.Get();
                    "VAT Bus. Posting Group" := CSLSetup."Expense VAT Bus. Posting Group";
                end;

                Validate(Amount);
                //++POS0030
            end;
        }
        field(12; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(20; Amount; Decimal)
        {
            Caption = 'Amount';

            trigger OnValidate()
            begin
                //--POS0030
                if Amount = 0 then
                    "VAT Amount" := 0
                else begin
                    TestField("Account No.");
                    TestField("VAT Bus. Posting Group");
                    TestField("VAT Prod. Posting Group");
                    VATPostSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group");
                    "VAT Amount" := Round(Amount / (100 + VATPostSetup."VAT %") * VATPostSetup."VAT %", 0.01);
                end;
                //++POS0030
            end;
        }
        field(21; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            Editable = false;
        }
        field(24; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            Description = 'POS0030';
            TableRelation = "VAT Business Posting Group";

            trigger OnValidate()
            begin
                //--POS0030
                Validate(Amount);
                //++POS0030
            end;
        }
        field(25; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            Description = 'POS0030';
            TableRelation = "VAT Product Posting Group";

            trigger OnValidate()
            begin
                //--POS0030
                Validate(Amount);
                //++POS0030
            end;
        }
        field(26; "Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 1 Code';
            CaptionClass = '1,2,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(27; "Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 2 Code';
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(100; "Creation Date"; Date)
        {
            Caption = 'Date';
        }
        field(101; "Creation Time"; Time)
        {
            Caption = 'Time';
        }
        field(102; "Staff ID"; Code[20])
        {
            Caption = 'Staff ID';
            TableRelation = "CCS CASH Staff";
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
    }

    keys
    {
        key(Key1; "Store No.", "POS Terminal No.", "Transaction No.", "Line No.")
        {
            Clustered = true;
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
        TenderType: Record "CCS CASH Store Tender Type";
        TransHead: Record "CCS CASH POS Transaction Hdr.";
        CSLSetup: Record "CCS CASH Cash Sales Setup";
        GLAccount: Record "G/L Account";
        VATPostSetup: Record "VAT Posting Setup";
        DimMgt: Codeunit DimensionManagement;
        cExpenseDocument: Label 'Expenses';

    local procedure CreateDim()
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        ShortDim1: Code[20];
        ShortDim2: Code[20];
    begin
        DimMgt.AddDimSource(DefaultDimSource, DATABASE::"G/L Account", "Account No.");
        "Dimension Set ID" :=
          DimMgt.GetDefaultDimID(
            DefaultDimSource, ''/*SourceCodeSetup."Cash Sales"*/,
            ShortDim1, ShortDim2,
            0, 0);
    end;

    internal procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
#pragma warning disable AA0217
          DimMgt.EditDimensionSet("Dimension Set ID", StrSubstNo('%1 %2 %3', cExpenseDocument, "Transaction No.", "Line No."), "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
#pragma warning restore AA0217
    end;

    internal procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;
}