namespace S_W.BilanzTool;

/// <summary>Core tree structure for account groupings. Stores hierarchical financial statement line items.</summary>
table 62000 "BT Account Grouping"
{
    Caption = 'Account Grouping';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Grouping Header"; Code[20])
        {
            Caption = 'Grouping Header';
            Editable = false;
            TableRelation = "BT Acc. Grouping Header".Code;
            DataClassification = CustomerContent;
        }
        field(2; Grouping; Text[100])
        {
            Caption = 'Grouping';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(3; Name; Text[250])
        {
            Caption = 'Name';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(4; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account';
            // G/L Account reference (runtime)
            DataClassification = CustomerContent;
        }
        field(6; "Node Type"; Enum "BT Node Type")
        {
            Caption = 'Node Type';
            DataClassification = CustomerContent;
        }
        field(7; "Numbering Type"; Enum "BT Numbering Type")
        {
            Caption = 'Numbering Type';
            DataClassification = CustomerContent;
        }
        field(8; "Balancing Type"; Enum "BT Balancing Type")
        {
            Caption = 'Balancing Type';
            DataClassification = CustomerContent;
        }
        field(9; "Thereof Grouping"; Boolean)
        {
            Caption = 'Thereof Grouping';
            DataClassification = CustomerContent;
        }
        field(10; "Balance at Period Start"; Boolean)
        {
            Caption = 'Balance at Period Start';
            DataClassification = CustomerContent;
        }
        field(11; "Use Balance"; Boolean)
        {
            Caption = 'Use Balance';
            DataClassification = CustomerContent;
        }
        field(12; "Corresponding Grouping"; Text[100])
        {
            Caption = 'Corresponding Grouping';
            DataClassification = CustomerContent;
        }
        field(13; "GL Acc. Filter"; Text[250])
        {
            Caption = 'G/L Account Filter';
            DataClassification = CustomerContent;
        }
        field(14; "Business Unit Filter"; Code[10])
        {
            Caption = 'Business Unit Filter';
            DataClassification = CustomerContent;
        }
        field(15; "Dimension Filter"; Text[250])
        {
            Caption = 'Dimension Filter';
            DataClassification = CustomerContent;
        }
        field(20; "Amt Curr"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount Current';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(21; "Amt Prev"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount Previous';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(22; "Amt Prev2"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount Year-2';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(23; "Amt Budget"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount Budget';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(30; "KPI Code"; Code[10])
        {
            Caption = 'KPI Code';
            DataClassification = CustomerContent;
        }
        field(31; "Reverse Sign"; Boolean)
        {
            Caption = 'Reverse Sign';
            DataClassification = CustomerContent;
        }
        field(32; Indent; Integer)
        {
            Caption = 'Indent';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Grouping Header", Grouping)
        {
            Clustered = true;
        }
    }
}
