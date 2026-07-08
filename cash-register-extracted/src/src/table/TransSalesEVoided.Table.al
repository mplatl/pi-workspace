table 1070556 "CCS CASH Trans Sales E. Voided"
{
    Caption = 'Trans. Sales Entry Voided';
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
        field(10; Type; enum "CCS CASH Trans Sales Entry Typ")
        {
            Caption = 'Type';
        }
        field(11; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST("Normal")) "Standard Text".Code
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account"."No."
            ELSE
            IF (Type = CONST(Item)) Item."No."
            ELSE
            IF (Type = CONST(Resource)) Resource."No.";
        }
        field(12; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(30; "Gen. Prod.Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod.Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(31; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(35; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
        }
        field(50; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
        }
        field(51; "Unit Price incl. VAT"; Decimal)
        {
            Caption = 'Unit Price incl. VAT';
        }
        field(52; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(60; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(61; "Amount incl. VAT"; Decimal)
        {
            Caption = 'Amount incl. VAT';
        }
        field(62; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
        }
        field(100; "Price Changed"; Boolean)
        {
            Caption = 'Price Changed';
        }
        field(101; "Original Unit Price"; Decimal)
        {
            Caption = 'Original Unit Price';
        }
        field(110; "Line discount"; Decimal)
        {
            Caption = 'Line discount';
        }
        field(111; "Invoice Discount"; Decimal)
        {
            Caption = 'Invoice Discount';
        }
        field(200; "Creation Date"; Date)
        {
            Caption = 'Date';
        }
        field(201; "Creation Time"; Time)
        {
            Caption = 'Creation Time';
        }
        field(202; "Staff ID"; Code[20])
        {
            Caption = 'Staff ID';
            TableRelation = "CCS CASH Staff";
        }
    }

    keys
    {
        key(Key1; "Store No.", "POS Terminal No.", "Transaction No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = Amount, "Amount incl. VAT", "VAT Amount";
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