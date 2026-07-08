pageextension 1070540 "CCS CASH User Setup" extends "User Setup"
{
    layout
    {
        addafter(PhoneNo)
        {
#pragma warning disable AL0432
            field("CCS CASH Op. Pmt. aft. Post"; Rec."CCS CASH Op. Pmt. aft. Post")
#pragma warning restore AL0432
            {
                ApplicationArea = CCSCASH;
                Visible = false;
                ToolTip = 'Specifies the value of the Open Payment after Posting field.';
            }
            field("CCS CASH Store No."; Rec."CCS CASH Store No.")
            {
                ApplicationArea = CCSCASH;
                ToolTip = 'Specifies the value of the Store No. field.';
            }
            field("CCS CASH POS No."; Rec."CCS CASH POS No.")
            {
                ApplicationArea = CCSCASH;
                ToolTip = 'Specifies the value of the POS No. field.';
            }
            field("CCS CASH Staff ID"; Rec."CCS CASH Staff ID")
            {
                ApplicationArea = CCSCASH;
                ToolTip = 'Specifies the value of the Staff ID field.';
            }
        }
    }

    actions
    {
    }
}