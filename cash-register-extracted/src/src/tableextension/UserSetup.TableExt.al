tableextension 1070543 "CCS CASH User Setup" extends "User Setup"
{
    fields
    {
        field(1070540; "CCS CASH Store No."; Code[20])
        {
            Caption = 'Store No.';
            DataClassification = CustomerContent;
            TableRelation = "CCS CASH Store";
        }
        field(1070541; "CCS CASH POS No."; Code[20])
        {
            Caption = 'POS No.';
            DataClassification = CustomerContent;
            TableRelation = "CCS CASH POS Terminal"."No." WHERE("Store No" = FIELD("CCS CASH Store No."));
        }
        field(1070542; "CCS CASH Staff ID"; Code[20])
        {
            Caption = 'Staff ID';
            DataClassification = CustomerContent;
            TableRelation = "CCS CASH Staff";
        }
        field(1070543; "CCS CASH Op. Pmt. aft. Post"; Boolean)
        {
            Caption = 'Open Payment after Posting';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with Use Cashdialog on Order Posting field in Cash Sales Setup';
            ObsoleteTag = 'CCS CASH 20.3.5.0';

        }
    }

}