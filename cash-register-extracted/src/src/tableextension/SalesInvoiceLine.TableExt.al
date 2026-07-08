tableextension 1070545 "CCS CASH Sales Invoice Line" extends "Sales Invoice Line"
{
    fields
    {
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
    }

}