namespace S_W.BilanzTool;

table 62008 "BT Checklist"
{
    Caption = 'Checklist';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Line Type"; Option)
        {
            Caption = 'Line Type';
            OptionMembers = Header, Line;
            DataClassification = CustomerContent;
        }
        field(2; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(3; Template; Boolean)
        {
            Caption = 'Template';
            DataClassification = CustomerContent;
        }
        field(4; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; No; Integer)
        {
            Caption = 'No.';
            Editable = false;
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(6; Task; Text[250])
        {
            Caption = 'Task';
            DataClassification = CustomerContent;
        }
        field(7; Finished; Boolean)
        {
            Caption = 'Finished';
            DataClassification = CustomerContent;
        }
    }

    keys { key(PK; "Line Type", Code, No) { Clustered = true; } }
}
