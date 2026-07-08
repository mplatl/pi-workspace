tableextension 1070549 "CCS CASH Payment Method" extends "Payment Method"
{
    fields
    {
        field(1070540; "CCS CASH CSL Tender Type"; Code[20])
        {
            Caption = 'POS Tender Type';
            DataClassification = CustomerContent;
            TableRelation = "CCS CASH Tender Type Setup";

            trigger OnValidate()
            begin
                if Rec."CCS CASH CSL Tender Type" <> '' then
                    Rec.TestField("Bal. Account No.", '');
            end;
        }
        field(1070541; "CCS CASH CSL Tender Type Desc."; Text[50])
        {
            CalcFormula = Lookup("CCS CASH Tender Type Setup".Description WHERE(Code = FIELD("CCS CASH CSL Tender Type")));
            Caption = 'POS Tender Type Description';
            Editable = false;
            FieldClass = FlowField;
        }
    }

}