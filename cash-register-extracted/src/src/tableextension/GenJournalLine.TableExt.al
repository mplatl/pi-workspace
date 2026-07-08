tableextension 1070542 "CCS CASH Gen. Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        field(1070540; "CCS CASH CSL Staff ID"; Code[20])
        {
            Caption = 'Staff ID';
            DataClassification = CustomerContent;
        }
        field(1070541; "CCS CASH CSL Store No."; Code[20])
        {
            Caption = 'Store No.';
            DataClassification = CustomerContent;
        }
        field(1070542; "CCS CASH CSL POS Terminal No."; Code[20])
        {
            Caption = 'PPOS Term. No.';
            DataClassification = CustomerContent;
        }
        field(1070543; "CCS CASH CSL Transaction No."; Integer)
        {
            Caption = 'CS Trans. No.';
            DataClassification = CustomerContent;
        }
    }

}