table 1070544 "CCS CASH Retail User"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Staff ID"; Code[20])
        {
            Caption = 'Staff ID';
            TableRelation = "CCS CASH Staff".ID;
        }
        field(10; "Cashier Name"; Text[50])
        {
            CalcFormula = Lookup("CCS CASH Staff".Name WHERE(ID = FIELD("Staff ID")));
            Caption = 'Cashier Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Store No"; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "CCS CASH Store";
        }
        field(21; "Store Name"; Text[100])
        {
            CalcFormula = Lookup("CCS CASH Store".Name WHERE("No." = FIELD("Store No")));
            Caption = 'Store Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; "POS Terminal No."; Code[20])
        {
            Caption = 'POS Terminal No.';
            TableRelation = "CCS CASH POS Terminal"."No." WHERE("Store No" = FIELD("Store No"));
        }
        field(31; "POS Description"; Text[50])
        {
            CalcFormula = Lookup("CCS CASH POS Terminal".Description WHERE("Store No" = FIELD("Store No"),
                                                                   "No." = FIELD("POS Terminal No.")));
            Caption = 'POS Description';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Staff ID", "Store No", "POS Terminal No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}