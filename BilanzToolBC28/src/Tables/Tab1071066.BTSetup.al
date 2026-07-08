namespace S_W.BilanzTool;

/// <summary>BilanzTool setup — singleton configuration table.</summary>
table 62006 "BT Setup"
{
    Caption = 'BilanzTool Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; PrimaryKey; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Default Balance Grouping"; Code[20])
        {
            Caption = 'Default Balance Grouping';
            TableRelation = "BT Acc. Grouping Header".Code where (Type = const(Balance));
            DataClassification = CustomerContent;
        }
        field(3; "Default PL Grouping"; Code[20])
        {
            Caption = 'Default P&L Grouping';
            TableRelation = "BT Acc. Grouping Header".Code where (Type = const(PL));
            DataClassification = CustomerContent;
        }
        field(4; "Default Cashflow Grouping"; Code[20])
        {
            Caption = 'Default Cashflow Grouping';
            TableRelation = "BT Acc. Grouping Header".Code where (Type = const(Cashflow));
            DataClassification = CustomerContent;
        }
        field(5; "Retained Earnings Acc."; Code[20])
        {
            Caption = 'Retained Earnings Account';
            DataClassification = CustomerContent;
        }
        field(6; "Default Depr. Book"; Code[10])
        {
            Caption = 'Default Depreciation Book';
            DataClassification = CustomerContent;
        }
        field(7; "Gen. Journal Template"; Code[10])
        {
            Caption = 'Gen. Journal Template Name';
            DataClassification = CustomerContent;
        }
        field(8; "Gen. Journal Batch"; Code[10])
        {
            Caption = 'Gen. Journal Batch Name';
            DataClassification = CustomerContent;
        }
        field(20; "Default Word Template Code"; Code[30])
        {
            Caption = 'Default Word Template';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = true;
        }
    }

    procedure Get(): Boolean
    begin
        PrimaryKey := '';
        if not FindFirst() then begin
            PrimaryKey := 'PRIMARY';
            Initialize();
            Insert(true);
        end;
        exit(true);
    end;

    local procedure Initialize()
    begin
    end;
}
