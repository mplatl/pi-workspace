page 1070564 "CCS CASH Cust. Pmt. Trans."
{
    // POS0004 28.06.16
    //   Hide Field Payment Discount Amount
    // POS0035 13.06.17 MK Added Function to Call Payment Form

    Caption = 'Customer Payment Transaction';
    DataCaptionFields = "Store No.", "POS Terminal No.", "Transaction No.";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "CCS CASH POS Transaction Hdr.";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Store No. field.';
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the POS Terminal No. field.';
                }
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Transaction No. field.';
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Transaction Type field.';
                }
                field("Posting Description"; Rec."Posting Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Description field.';
                    Editable = PostingDescriptionEditable;
                    StyleExpr = PostingDescriptionStyleExpr;
                    Visible = PostingDescriptionVisible;
                }
                field(PaymentDiscountAmount; TransHead."Payment Discount Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Pmt. Discount possible';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Payment Discount possible field.';
                }
                group(Control1100004012)
                {
                    ShowCaption = false;
                    field("Customer No."; Rec."Customer No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Customer No. field.';
                    }
                    field("Cust.Name"; Cust.Name)
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Name field.';
                    }
                    field("Cust.Address"; Cust.Address)
                    {
                        ApplicationArea = All;
                        Caption = 'Address';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Address field.';
                    }
                    field(CustPostCode; Cust."Post Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Post Code';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Post Code field.';
                    }
                    field("Cust.City"; Cust.City)
                    {
                        ApplicationArea = All;
                        Caption = 'City';
                        Editable = false;
                        ToolTip = 'Specifies the value of the City field.';
                    }
                    field(CustCountryRegionCode; Cust."Country/Region Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Country Code';
                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Country Code field.';
                    }
                }
            }
            part("Customer Entries"; "CCS CASH Cust Payment Sub")
            {
                ApplicationArea = All;
                Caption = 'Customer Entries';
                SubPageLink = "Store No." = FIELD("Store No."),
                              "POS Terminal No." = FIELD("POS Terminal No."),
                              "Transaction No." = FIELD("Transaction No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action(Payment)
                {
                    ApplicationArea = All;
                    Caption = 'Payment (F9)';
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ShortCutKey = 'F9';
                    ToolTip = 'Executes the Payment action.';

                    trigger OnAction()
                    var
                        PaymentPage: Page "CCS CASH Payment";
                    begin
                        CurrPage.SaveRecord();
                        TransHead := Rec;
                        TransHead.SetRecFilter();
                        PaymentPage.SetTransactionHeader(TransHead);
                        PaymentPage.RunModal();
                        TransactionPosted := PaymentPage.GetPostingStatus();
                        Rec.Find();
                        CurrPage.Update(false);
                        if TransactionPosted then
                            CurrPage.Close();
                    end;
                }
                action("Abort Transaction")
                {
                    ApplicationArea = All;
                    Caption = 'Void Transaction';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Void Transaction action.';

                    trigger OnAction()
                    begin
                        CurrPage.Close();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        CashSalesSetup: Record "CCS CASH Cash Sales Setup";
        TransSalesEntry: Record "CCS CASH Trans. Sales Entry";
    begin
        CashSalesSetup.Get();
        PostingDescriptionEditable := CashSalesSetup."Use Posting Descr. on Pmt";
        if PostingDescriptionEditable then
            PostingDescriptionStyleExpr := 'Attention'
        else
            PostingDescriptionStyleExpr := 'None';

        TransSalesEntry.SetRange("Store No.", Rec."Store No.");
        TransSalesEntry.SetRange("POS Terminal No.", Rec."POS Terminal No.");
        TransSalesEntry.SetRange("Transaction No.", Rec."Transaction No.");
        TransSalesEntry.SetRange(Type, TransSalesEntry.Type::"CCS CASH Payment");
        PostingDescriptionVisible := TransSalesEntry.IsEmpty();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if not Cust.Get(Rec."Customer No.") then
            Cust.Init();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        RetailUser: Record "CCS CASH Retail User";
    begin
        if TransactionPosted then begin
            Rec.Status := Rec.Status::Normal;
            Rec.Modify(true);
            exit(true);
        end;

        if not Confirm(Text001 + Text002, false) then
            exit(false);
        RetailUser.Get(Rec."Staff ID", Rec."Store No.", Rec."POS Terminal No.");
        Rec.VoidTransaction(RetailUser);
        exit(true);
    end;

    var
        Cust: Record Customer;
        TransHead: Record "CCS CASH POS Transaction Hdr.";
        Text001: Label 'Do you really want to abort the Transaction?';
        TransactionPosted: Boolean;
        PostingDescriptionStyleExpr: Text;
        PostingDescriptionEditable: Boolean;
        PostingDescriptionVisible: Boolean;
        Text002: Label '\Transaction is voided.';

    internal procedure CallPaymentPage()
    var
        PaymentPage: Page "CCS CASH Payment";
        RetailUser: Record "CCS CASH Retail User";
    begin
        //++POS0035
        TransHead := Rec;
        TransHead.SetRecFilter();
        PaymentPage.SetTransactionHeader(TransHead);
        PaymentPage.RunModal();
        TransactionPosted := PaymentPage.GetPostingStatus();
        Rec.Find();
        CurrPage.Update(false);
        if TransactionPosted then begin
            CurrPage.Close()
        end else begin
            RetailUser.Get(Rec."Staff ID", Rec."Store No.", Rec."POS Terminal No.");
            Rec.VoidTransaction(RetailUser);
        end;
        //--POS0035
    end;
}