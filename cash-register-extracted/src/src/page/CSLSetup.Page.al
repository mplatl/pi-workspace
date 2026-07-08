page 1070540 "CCS CASH CSL Setup"
{
    AdditionalSearchTerms = 'CASH Cash Sales Setup', Locked = true;
    ApplicationArea = All;
    Caption = 'Cash Sales Setup - Cash Register';
    PageType = Card;
    SourceTable = "CCS CASH Cash Sales Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Default Customer"; Rec."Default Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Customer field.';
                }
                field("Default Quantity at POS"; Rec."Default Quantity at POS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Quantity at POS field.';
                }
                field("Journale Template Name"; Rec."Journale Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Template Name field.';
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Journal Batch Name field.';
                }
                field("Merge Pmt to Document"; Rec."Merge Pmt to Document")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merge Payment to Document field.';
                }
                field("Autovoid Open Transactions"; Rec."Autovoid Open Transactions")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Autovoid Open Transactions field.';
                }
                field("No Dialog on Receipt Print"; Rec."No Dialog on Receipt Print")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No Dialog on Receipt Print field.';
                }
                field("No Display on Standard Pages"; Rec."No Display on Standard Pages")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No Display on Standard Pages field.';
                }
                field("Deposit VAT Bus. Posting Group"; Rec."Deposit VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deposit VAT Business Posting Group field.';
                }
                field("Expense VAT Bus. Posting Group"; Rec."Expense VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Expense VAT Business Posting Group field.';
                }
                field("Use Document No. As Pst Desc."; Rec."Use Document No. As Pst Desc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if Receipt No. of the POS transaction should be used as Posting Description on payment posting.';
                }
                field("Use Posting Descr. on Pmt"; Rec."Use Posting Descr. on Pmt")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if posting description of the POS transaction should be used on payment posting.';
                }
                field(CSLDialogPosting; Rec.CSLDialogPosting)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Cash Dialog on Order Posting field.';
                }
                field("Signature Service"; Rec."Signature Service")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Signature Service field.';
                }
                field("Payment Method in Description of Receipt"; Rec."PMT. Meth. in Descr. of Rct.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Prints Payment Method in Description of Receipt.';
                }
                field("Pmt. Disc. Tolerance Date"; Rec."Pmt. Disc. Tolerance Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Adds the Payment Discount Tolerance Date field to the Customer Payment transactions.';
                }
            }
            group("No. Series")
            {
                field("Store Nos."; Rec."Store Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store No. Series field.';
                }
                field("POS Terminal Nos."; Rec."POS Terminal Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Terminal No. Series field.';
                }
                field("Staff Nos."; Rec."Staff Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Staff No. Series field.';
                }
                group(Control1103308009)
                {
                    ShowCaption = false;
                    field("Receipt Nos."; Rec."Receipt Nos.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the POS Receipt No. Series field.';
                    }
                    field("Posted Receipt Nos."; Rec."Posted Receipt Nos.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Posted POS Receipt No. Series field.';
                    }
                }
            }
            group(Report)
            {
                Caption = 'Reporting';
                group(Control1100004026)
                {
                    ShowCaption = false;
                    field("Cash Receipt Invoice Report ID"; Rec."Cash Receipt Invoice Report ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cash Receipt Invoice Report-ID field.';
                    }
                    field("Cash Invoice Report ID"; Rec."Cash Invoice Report ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cash Invoice Report-ID field.';
                    }
                    field("Cash Receipt CrMemo Report ID"; Rec."Cash Receipt CrMemo Report ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cash Receipt Credit Memo Report-ID field.';
                    }
                    field("Cash CrMemo Report ID"; Rec."Cash CrMemo Report ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cash Credit Memo Report-ID field.';
                    }
                    field("Cust. Payment Report ID"; Rec."Cust. Payment Report ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Payment Report-ID field.';
                    }
                    field("Daystart Report ID"; Rec."Daystart Report ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Daystart Report-ID field.';
                    }
                    field("Dayend Report ID"; Rec."Dayend Report ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Dayend Report-ID field.';
                    }
                    field("Cash Journal Report ID"; Rec."Cash Journal Report ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the POS Log Report-ID field.';
                    }
                    field("TenderDecl Report ID"; Rec."TenderDecl Report ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Tender Operation Report-ID field.';
                    }
                    field("Voucher Report ID"; Rec."Voucher Report ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Voucher Report-ID field.';
                    }
                }
                group(Control1100004027)
                {
                    ShowCaption = false;
                    field("Cash Receipt Inv. Report Cap"; Rec."Cash Receipt Inv. Report Cap")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cash Receipt Invoice Report Caption field.';
                    }
                    field("Cash Invoice Report Caption"; Rec."Cash Invoice Report Caption")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cash Invoice Report Caption field.';
                    }
                    field("Cash Receipt CrMem Report Cap"; Rec."Cash Receipt CrMem Report Cap")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cash Receipt Credit Memo Report Caption field.';
                    }
                    field("Cash CrMemo Report Caption"; Rec."Cash CrMemo Report Caption")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cash Credit Memo Report Caption field.';
                    }
                    field("Cust. Payment Report Caption"; Rec."Cust. Payment Report Caption")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Payment Report Caption field.';
                    }
                    field("Daystart Report Caption"; Rec."Daystart Report Caption")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Daystart Report Caption field.';
                    }
                    field("Dayend Report Caption"; Rec."Dayend Report Caption")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Dayend Report Caption field.';
                    }
                    field("Cash Journal Report Caption"; Rec."Cash Journal Report Caption")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the POS Log Report Caption field.';
                    }
                    field("TenderDecl Report Caption"; Rec."TenderDecl Report Caption")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Tender Operation Report Caption field.';
                    }
                    field("Voucher Report Caption"; Rec."Voucher Report Caption")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Voucher Report Caption field.';
                    }
                }
                group(Control1100004028)
                {
                    ShowCaption = false;
                    field("Cash Receipt Invoice Copies"; Rec."Cash Receipt Invoice Copies")
                    {
                        ToolTip = 'Specifies the value of the Cash Receipt Invoice Copies field.';
                    }
                    field("Cash Invoice Copies"; Rec."Cash Invoice Copies")
                    {
                        ToolTip = 'Specifies the value of the Cash Invoice Copies field.';
                    }
                    field("Cash Receipt CrMemo Copies"; Rec."Cash Receipt CrMemo Copies")
                    {
                        ToolTip = 'Specifies the value of the Cash Receipt Credit Memo Copies field.';
                    }
                    field("Cash CrMemo Copies"; Rec."Cash CrMemo Copies")
                    {
                        ToolTip = 'Specifies the value of the Cash Credit Memo Copies field.';
                    }
                    field("Cust. Payment Copies"; Rec."Cust. Payment Copies")
                    {
                        ToolTip = 'Specifies the value of the Customer Payment Copies field.';
                    }
                }
            }
            group("App. Version")
            {
                Caption = 'Application Version';
                Visible = false;
                field(GetVersion; Rec.GetVersion())
                {
                    ApplicationArea = All;
                    Caption = 'Version';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Version field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(GroupApplicationArea)
            {
                Visible = false;
            }
            action("Payment Method")
            {
                ApplicationArea = All;
                Caption = 'Payment Type List';
                Image = Payment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "CCS CASH Tender Type Setup";
                ToolTip = 'Executes the Payment Type List action.';
            }
            action(ActionRefreshApplicationArea)
            {
                ApplicationArea = All;
                Caption = 'Refresh Cache';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'If you have issues finding additional COSMO Cash Register Pages, choose Refresh Cache to refresh the application areas from Dynamics 365 Business Central.';

                trigger OnAction()
                begin
                    Rec.RefreshApplicationArea();
                end;
            }
        }
    }


    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            AppInit.InitSetup();
            Rec.Get();
        end;

        if Rec.Version = '' then begin
            Rec.Version := '90';
            Rec."Version Build" := 1;
            Rec.Modify();
        end;
    end;

    var
        AppInit: Codeunit "CCS CASH POS Register Init";
}