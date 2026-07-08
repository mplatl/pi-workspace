namespace S_W.BilanzTool;

table 62007 "BT Fixed Asset Grouping"
{
    Caption = 'Fixed Asset Grouping';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Grouping Header"; Code[20])
        {
            Caption = 'Grouping Header';
            DataClassification = CustomerContent;
        }
        field(2; Grouping; Text[100])
        {
            Caption = 'Grouping';
            DataClassification = CustomerContent;
        }
        field(3; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(4; "Node Type"; Enum "BT FA Node Type")
        {
            Caption = 'Node Type';
            DataClassification = CustomerContent;
        }
        field(5; "Fixed Asset No."; Code[20])
        {
            Caption = 'Fixed Asset No.';
            // Fixed Asset reference
            DataClassification = CustomerContent;
        }
        field(20; Amount1; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(21; Amount2; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount Previous';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys { key(PK; "Grouping Header", Grouping) { Clustered = true; } }
}
