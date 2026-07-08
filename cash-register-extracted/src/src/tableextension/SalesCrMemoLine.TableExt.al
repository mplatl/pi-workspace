tableextension 1070547 "CCS CASH Sales Cr.Memo Line" extends "Sales Cr.Memo Line"
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