namespace S_W.BilanzTool;

table 62005 "BT KPI"
{
    Caption = 'KPI';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "KPI Header Code"; Code[10])
        {
            Caption = 'KPI Header';
            TableRelation = "BT KPI Header".Code;
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; Code; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(4; Name; Text[80])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(5; Formula; Text[50])
        {
            Caption = 'Formula';
            DataClassification = CustomerContent;
        }
        field(6; Totaling; Text[50])
        {
            Caption = 'Totaling';
            DataClassification = CustomerContent;
        }
        field(7; "Reverse Sign"; Boolean)
        {
            Caption = 'Reverse Sign';
            DataClassification = CustomerContent;
        }
        field(20; Amount1; Decimal)
        {
            Caption = 'Current Value';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(21; Amount2; Decimal)
        {
            Caption = 'Previous Value';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "KPI Header Code", "Line No.") { Clustered = true; }
        key(CodeIdx; Code) { }
    }
}
