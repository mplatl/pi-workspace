namespace S_W.BilanzTool;

table 62004 "BT KPI Header"
{
    Caption = 'KPI Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[80])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
    }

    keys { key(PK; Code) { Clustered = true; } }
}
