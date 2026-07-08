namespace S_W.BilanzTool;

/// <summary>Account grouping header defines financial statement structures.</summary>
table 62002 "BT Acc. Grouping Header"
{
    Caption = 'Account Grouping Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(4; Type; Enum "BT Statement Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(5; Editable; Boolean)
        {
            Caption = 'Editable';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(6; "Style Grouping"; Text[30])
        {
            Caption = 'Style Grouping';
            DataClassification = CustomerContent;
        }
        field(7; "Style Total"; Text[30])
        {
            Caption = 'Style Total';
            DataClassification = CustomerContent;
        }
        field(8; "Style Account"; Text[30])
        {
            Caption = 'Style Account';
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
        fieldgroup(DropDown; Code, Name)
        {
        }
    }

    procedure IsBalance(): Boolean
    begin exit(Type = Type::Balance); end;

    procedure IsPL(): Boolean
    begin exit(Type = Type::PL); end;

    procedure IsCashflow(): Boolean
    begin exit(Type = Type::Cashflow); end;
}
