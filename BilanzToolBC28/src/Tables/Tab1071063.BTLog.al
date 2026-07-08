namespace S_W.BilanzTool;

table 62003 "BT Log"
{
    Caption = 'BilanzTool Log';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(2; Level; Option)
        {
            OptionMembers = Trace, Debug, Info, Warning, Error;
            DataClassification = SystemMetadata;
        }
        field(3; Message; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Entry Timestamp"; DateTime)
        {
            Caption = 'Timestamp';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; EntryNo)
        {
            Clustered = true;
        }
    }
}
