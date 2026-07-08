table 1070547 "CCS CASH Tender Type Setup"
{
    Caption = 'Payment Type Setup';
    LookupPageID = "CCS CASH Tender Type Setup";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(4; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(10; TenderFunction; Enum "CCS CASH TenderFunction")
        {
            Caption = 'Function';
        }
        field(11; Description; Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Code", "Currency Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}