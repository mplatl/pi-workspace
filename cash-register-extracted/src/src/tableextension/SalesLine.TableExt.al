tableextension 1070541 "CCS CASH Sales Line" extends "Sales Line"
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
        field(1070545; "CCS CASH CSL PaymentText"; Boolean)
        {
            Caption = 'Payment Text';
            DataClassification = CustomerContent;
        }
        field(1070546; "CCS CASH CSL Payment Amount"; Decimal)
        {
            Caption = 'Payment Amount';
            DataClassification = CustomerContent;
        }
        field(1070547; "CCS CASH Voucher No."; Code[20])
        {
            Caption = 'Voucher No.';
            DataClassification = CustomerContent;
        }
        field(1070548; "CCS CASH Voucher Amount"; Decimal)
        {
            Caption = 'Voucher Amount';
            DataClassification = CustomerContent;
        }
        field(1070549; "CCS CASH IsVoucher"; Boolean)
        {
            Caption = 'Is a Voucher';
            DataClassification = CustomerContent;
        }
        field(1070550; "CCS CASH Voucher SerialNo."; Code[20])
        {
            Caption = 'Voucher SerialNo.';
            DataClassification = CustomerContent;
        }
    }
}