pageextension 1070541 "CCS CASH Payment Methods" extends "Payment Methods"
{
    layout
    {
        addlast(Control1)
        {

            field("CCS CASH CSL Tender Type"; Rec."CCS CASH CSL Tender Type")
            {
                ApplicationArea = CCSCASH;
                ToolTip = 'Specifies the value of the POS Tender Type field.';
            }
            field("CCS CASH CSL Tender Type Desc."; Rec."CCS CASH CSL Tender Type Desc.")
            {
                ApplicationArea = CCSCASH;
                ToolTip = 'Specifies the value of the POS Tendertype Description field.';
            }
        }
    }
}