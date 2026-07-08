tableextension 1070544 "CCS CASH Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        field(1070540; "CCS CASH CSL Document"; Boolean)
        {
            Caption = 'Cash Document';
            DataClassification = CustomerContent;
        }
        field(1070541; "CCS CASH CSL Staff ID"; Code[20])
        {
            Caption = 'Staff ID';
            DataClassification = CustomerContent;
        }
        field(1070542; "CCS CASH CSL Store No."; Code[20])
        {
            Caption = 'Store No.';
            DataClassification = CustomerContent;
        }
        field(1070543; "CCS CASH CSL POS Terminal No."; Code[20])
        {
            Caption = 'PPOS Term. No.';
            DataClassification = CustomerContent;
        }
        field(1070544; "CCS CASH CSL Transaction No."; Integer)
        {
            Caption = 'CS Trans. No.';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key("CCS CASH_StoreTerminal"; "CCS CASH CSL Store No.", "CCS CASH CSL POS Terminal No.")
        {
        }
    }

}