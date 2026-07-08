page 1070577 "CCS CASH Cash Sales Cr. Memo"
{
    Caption = 'Cash Sales Credit Memo';
    DataCaptionExpression = DataCaption();
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Document;
    PopulateAllFields = true;
    PromotedActionCategories = 'New,Process,Report,Approve,Release,Posting,Prepare,Credit Memo,Request Approval';
    RefreshOnActivate = true;
    SourceTable = "Sales Header";
    SourceTableView = WHERE("Document Type" = FILTER("Credit Memo"));
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Visible = DocNoVisible;
                    ToolTip = 'Specifies the number of the estimate.';
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the number of the customer who will receive the products and be billed by default.';

                    trigger OnValidate()
                    begin
                        SelltoCustomerNoOnAfterValidat();
                    end;
                }
                field("Sell-to Contact No."; Rec."Sell-to Contact No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the contact no. of the contact person at the customer.';

                    trigger OnValidate()
                    begin
                        if Rec.GetFilter("Sell-to Contact No.") = xRec."Sell-to Contact No." then
                            if Rec."Sell-to Contact No." <> xRec."Sell-to Contact No." then
                                Rec.SetRange("Sell-to Contact No.");
                    end;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s name.';
                }
                field("Sell-to Address"; Rec."Sell-to Address")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the address where the customer is located.';
                }
                field("Sell-to Address 2"; Rec."Sell-to Address 2")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies additional address information.';
                }
                field("Sell-to Post Code"; Rec."Sell-to Post Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the postal code.';
                }
                field("Sell-to City"; Rec."Sell-to City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the address city.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date when the posting of the sales document will be recorded.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the sales invoice was created.';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the salesperson who is assigned to the customer.';

                    trigger OnValidate()
                    begin
                        SalespersonCodeOnAfterValidate();
                    end;
                }
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the Unit Price and Line Amount fields on document lines should be shown with or without VAT.';

                    trigger OnValidate()
                    begin
                        PricesIncludingVATOnAfterValid();
                    end;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = ExternalDocNoMandatory;
                    ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Registration No. field.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the VAT specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies whether the document is open, waiting to be approved, has been invoiced for prepayment, or has been released to the next stage of processing.';
                }
                field("Transaction Date"; TransHeader."Creation Date")
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Date';
                    ToolTip = 'Specifies the value of the Transaction Date field.';

                    trigger OnValidate()
                    begin
                        //++POS0008
                        OnAfterValidateTransactionDate();
                        //--POS0008
                    end;
                }
                field("Transaction Time"; TransHeader."Creation Time")
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Time';
                    ToolTip = 'Specifies the value of the Transaction Time field.';

                    trigger OnValidate()
                    begin
                        //++POS0008
                        OnAfterValidateTransactionTime();
                        //--POS0008
                    end;
                }
            }
            part(SalesLines; "CCS CASH Sales Cr. Memo Sf")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = FIELD("No.");
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(PromotedGroup)
            {
                action(Returnpayment)
                {
                    ApplicationArea = All;
                    Caption = 'Post (F9)';
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ShortCutKey = 'F9';
                    ToolTip = 'Executes the Post action.';

                    trigger OnAction()
                    var
                        PaymentPage: Page "CCS CASH Payment";
                        CSLTrigger: Codeunit "CCS CASH POS Reg. Sales Trg.";
                        ReleaseSalesDoc: Codeunit "Release Sales Document";
                    begin
                        // ++ POS0012
                        CurrPage.SaveRecord();
                        // -- POS0012
                        // + POS0024
                        ReleaseSalesDoc.PerformManualRelease(Rec);
                        ReleaseSalesDoc.PerformManualReopen(Rec);
                        // - POS0024
                        // + POS0015
                        CSLTrigger."Sync. SalesDocument"(Rec);
                        // - POS0015
                        TransHeader.Get(Rec."CCS CASH CSL Store No.", Rec."CCS CASH CSL POS Terminal No.", Rec."CCS CASH CSL Transaction No.");
                        TransHeader.SetRecFilter();
                        PaymentPage.SetTransactionHeader(TransHeader);
                        // ++ POS0012
                        Commit();
                        // -- POS0012
                        PaymentPage.RunModal();
                        if PaymentPage.GetPostingStatus() then
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
                        if not Confirm(Text001, false) then
                            exit;

                        if TransHeader.Get(Rec."CCS CASH CSL Store No.", Rec."CCS CASH CSL POS Terminal No.", Rec."CCS CASH CSL Transaction No.") then begin
                            TransHeader.Status := TransHeader.Status::Voided;
                            TransHeader.Modify();
                        end;

                        Rec.Delete(true);
                        CurrPage.Close();
                    end;
                }
            }
            action(GetPostedDocumentLinesToReverse)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Get Posted Doc&ument Lines to Reverse';
                Image = ReverseLines;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Copy one or more posted sales document lines in order to reverse the original order.';

                trigger OnAction()
                begin
                    Rec.GetPstdDocLinesToReverse();
                end;
            }
            action(CalculateInvoiceDiscount)
            {
                ApplicationArea = All;
                AccessByPermission = TableData "Cust. Invoice Disc." = R;
                Caption = 'Calculate &Invoice Discount';
                Image = CalculateInvoiceDiscount;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Executes the Calculate &Invoice Discount action.';

                trigger OnAction()
                begin
                    ApproveCalcInvDisc();
                    SalesCalcDiscByType.ResetRecalculateInvoiceDisc(Rec);
                end;
            }
        }
        area(Reporting)
        {
            group("&Credit Memo")
            {
                Visible = false;
            }
            group("F&unctions")
            {
                Visible = false;
            }
            group("P&osting")
            {
                Visible = false;
            }
            action(Statistics)
            {
                ApplicationArea = All;
                Caption = 'Statistics (F7)';
                Image = Statistics;
                ShortCutKey = 'F7';
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Executes the Statistics action.';

                trigger OnAction()
                begin
                    Rec.CalcInvDiscForHeader();
                    Commit();
                    PAGE.RunModal(PAGE::"Sales Statistics", Rec);
                    SalesCalcDiscByType.ResetRecalculateInvoiceDisc(Rec);
                end;
            }
            action(Dimensions)
            {
                ApplicationArea = All;
                AccessByPermission = TableData Dimension = R;
                Caption = 'Dimensions';
                Image = Dimensions;
                Promoted = true;
                PromotedOnly = true;
                ShortCutKey = 'Shift+Ctrl+D';
                ToolTip = 'Executes the Dimensions action.';

                trigger OnAction()
                begin
                    Rec.ShowDocDim();
                    CurrPage.SaveRecord();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetControlAppearance();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.SaveRecord();
        exit(Rec.ConfirmDeletion());
    end;

    trigger OnInit()
    begin
        SetExtDocNoMandatoryCondition();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Responsibility Center" := UserMgt.GetSalesFilter();
    end;

    trigger OnOpenPage()
    begin
        if UserMgt.GetSalesFilter() <> '' then begin
            Rec.FilterGroup(2);
            Rec.SetRange("Responsibility Center", UserMgt.GetSalesFilter());
            Rec.FilterGroup(0);
        end;

        SetDocNoVisible();

        //++POS0008
        TransHeader.Get(Rec."CCS CASH CSL Store No.", Rec."CCS CASH CSL POS Terminal No.", Rec."CCS CASH CSL Transaction No.");
        //--POS0008
    end;

    var
        UserMgt: Codeunit "User Setup Management";
        SalesCalcDiscByType: Codeunit "Sales - Calc Discount By Type";
        DocNoVisible: Boolean;
        ExternalDocNoMandatory: Boolean;
        RetailUser: Record "CCS CASH Retail User";
        POSTerm: Record "CCS CASH POS Terminal";
        TransHeader: Record "CCS CASH POS Transaction Hdr.";
        Text001: Label 'Do you really want to abort the Transaction?';
        CSLFunctions: Codeunit "CCS CASH POS Register Func";

    local procedure ApproveCalcInvDisc()
    begin
        CurrPage.SalesLines.PAGE.ApproveCalcInvDisc();
    end;

    local procedure SelltoCustomerNoOnAfterValidat()
    begin
        if Rec.GetFilter("Sell-to Customer No.") = xRec."Sell-to Customer No." then
            if Rec."Sell-to Customer No." <> xRec."Sell-to Customer No." then
                Rec.SetRange("Sell-to Customer No.");
        CurrPage.Update();
    end;

    local procedure SalespersonCodeOnAfterValidate()
    begin
        CurrPage.SalesLines.PAGE.UpdateForm(true);
    end;

    local procedure PricesIncludingVATOnAfterValid()
    begin
        CurrPage.Update();
    end;

    local procedure SetDocNoVisible()
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
        DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",Reminder,FinChMemo;
    begin
        DocNoVisible := DocumentNoVisibility.SalesDocumentNoIsVisible(DocType::"Credit Memo", Rec."No.");
    end;

    local procedure SetExtDocNoMandatoryCondition()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        ExternalDocNoMandatory := SalesReceivablesSetup."Ext. Doc. No. Mandatory"
    end;

    local procedure SetControlAppearance()
    begin
        if Rec."CCS CASH CSL Document" then begin
            RetailUser.Get(Rec."CCS CASH CSL Staff ID", Rec."CCS CASH CSL Store No.", Rec."CCS CASH CSL POS Terminal No.");
            POSTerm.Get(RetailUser."Store No", RetailUser."POS Terminal No.");
            CurrPage.SalesLines.PAGE.SetRetailUser(RetailUser);
        end;
    end;

    local procedure DataCaption(): Text
    begin
        exit(StrSubstNo(Rec."No."));
    end;

    local procedure OnAfterValidateTransactionDate()
    begin
        //++POS0008
        CSLFunctions.ChangeTransactionDateTime(TransHeader,
          TransHeader."Creation Date", TransHeader."Creation Time");
        //--POS0008
    end;

    local procedure OnAfterValidateTransactionTime()
    begin
        //++POS0008
        CSLFunctions.ChangeTransactionDateTime(TransHeader,
          TransHeader."Creation Date", TransHeader."Creation Time");
        //--POS0008
    end;
}