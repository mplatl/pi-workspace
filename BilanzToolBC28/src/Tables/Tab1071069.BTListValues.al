namespace S_W.BilanzTool;

table 62009 "BT List Values"
{
    Caption = 'List Values';
    DataClassification = CustomerContent;

    fields
    {
        field(1; No; Integer)
        {
            Caption = 'No.';
            Editable = false;
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            OptionMembers = Caption, Posting;
            DataClassification = CustomerContent;
        }
        field(3; "List Value Type"; Option)
        {
            Caption = 'List Value Type';
            OptionMembers = " ", "Fixed Assets", Receivables, Liabilities, Accruals, Loans, Other;
            DataClassification = CustomerContent;
        }
        field(4; Grouping; Text[100])
        {
            Caption = 'Grouping';
            DataClassification = CustomerContent;
        }
        field(5; "Grouping Header"; Code[20])
        {
            Caption = 'Grouping Header';
            TableRelation = "BT Acc. Grouping Header".Code;
            DataClassification = CustomerContent;
        }
        field(6; "Entry Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(7; "Column No."; Integer)
        {
            Caption = 'Column No.';
            DataClassification = CustomerContent;
        }
        field(8; Name; Text[30])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(9; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(10; "Amount Prev"; Decimal)
        {
            Caption = 'Previous Year Amount';
            DataClassification = CustomerContent;
        }
    }

    keys { key(PK; No) { Clustered = true; } }
}
