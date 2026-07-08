namespace S_W.BilanzTool;

/// <summary>Word template definitions for financial reports.</summary>
table 62001 "BT Word Template"
{
    Caption = 'BilanzTool Word Template';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; Type; Enum "BT Template Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(4; "BC Template Code"; Code[30])
        {
            Caption = 'BC Word Template Code';
            // BC Word Template reference
            DataClassification = CustomerContent;
        }
        field(20; "Template Data"; Blob)
        {
            Caption = 'Template Data';
            Compressed = true;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, Name, Type)
        {
        }
    }
}
