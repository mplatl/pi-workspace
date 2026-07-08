page 1070556 "CCS CASH Cash Sales Invoice"
{
    Caption = 'Cash Sales Invoice';
    DataCaptionExpression = DataCaption();
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Document;
    PopulateAllFields = true;
    PromotedActionCategories = 'New,Process,Report,Approve,Release,Posting,Prepare,Invoice,Request Approval';
    RefreshOnActivate = true;
    SourceTable = "Sales Header";
    SourceTableView = WHERE("Document Type" = FILTER(Invoice),
                            "CCS CASH CSL Document" = CONST(true));
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
                    Editable = false;
                    Importance = Additional;
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
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s name.';
                }
                field("Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Sell-to Customer Name 2 field.';
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
                    Visible = false;
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
                    Importance = Additional;
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
                    Visible = false;
                    ToolTip = 'Specifies when the sales invoice was created.';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the name of the salesperson who is assigned to the customer.';

                    trigger OnValidate()
                    begin
                        SalespersonCodeOnAfterValidate();
                    end;
                }
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies if the Unit Price and Line Amount fields on document lines should be shown with or without VAT.';
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the VAT Registration No. field.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the VAT specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("Payment Discount %"; Rec."Payment Discount %")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the payment discount percentage that is granted if the customer pays on or before the date entered in the Pmt. Discount Date field. The discount percentage is specified in the Payment Terms Code field.';
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
                field("Posting Description";Rec."Posting Description")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Posting Description field.';
                }
            }
            part(SalesLines; "CCS CASH Cash Sales Inv. Sf")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = FIELD("No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(PromotedGroup)
            {
                action(Payment)
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
                        CurrPage.SaveRecord();
                        // + POS0015
                        CSLTrigger."Sync. SalesDocument"(Rec);
                        // - POS0015
                        // + POS0024
                        ReleaseSalesDoc.PerformManualRelease(Rec);
                        ReleaseSalesDoc.PerformManualReopen(Rec);
                        // - POS0024
                        TransHeader.Get(Rec."CCS CASH CSL Store No.", Rec."CCS CASH CSL POS Terminal No.", Rec."CCS CASH CSL Transaction No.");
                        TransHeader.SetRecFilter();
                        PaymentPage.SetTransactionHeader(TransHeader);
                        Commit();

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
            action(CalculateInvoiceDiscount)
            {
                ApplicationArea = All;
                AccessByPermission = TableData "Cust. Invoice Disc." = R;
                Caption = 'Calculate &Invoice Discount';
                Image = CalculateInvoiceDiscount;
                Visible = false;
                ToolTip = 'Executes the Calculate &Invoice Discount action.';

                trigger OnAction()
                begin
                    ApproveCalcInvDisc();
                    SalesCalcDiscountByType.ResetRecalculateInvoiceDisc(Rec);
                end;
            }
            action("Copy Document")
            {
                ApplicationArea = All;
                Caption = 'Copy Document';
                Image = CopyDocument;
                ToolTip = 'Executes the Copy Document action.';

                trigger OnAction()
                var
                    SalesLine: Record "Sales Line";
                begin
                    CopySalesDoc.SetSalesHeader(Rec);
                    CopySalesDoc.RunModal();
                    Clear(CopySalesDoc);

                    SalesLine.SetRange("Document Type", Rec."Document Type");
                    SalesLine.SetRange("Document No.", Rec."No.");
                    if SalesLine.FindSet() then
                        repeat
                            cslSalesTrigger."Sync. SalesLine"(SalesLine, 1);
                        until SalesLine.Next() = 0;

                    cslSalesTrigger.SyncSalesHeader(Rec, 1);
                end;
            }
            action(Preview)
            {
                ApplicationArea = All;
                Caption = 'Preview Posting';
                Image = ViewPostedOrder;
                ToolTip = 'Executes the Preview Posting action.';

                trigger OnAction()
                begin
                    ShowPreview();
                end;
            }
        }
        area(Reporting)
        {
            action(Statistics)
            {
                ApplicationArea = All;
                Caption = 'Statistics (F7)';
                Image = Statistics;
                ShortCutKey = 'F7';
                ToolTip = 'Executes the Statistics action.';

                trigger OnAction()
                begin
                    Rec.CalcInvDiscForHeader();
                    Commit();
                    PAGE.RunModal(PAGE::"Sales Statistics", Rec);
                    SalesCalcDiscountByType.ResetRecalculateInvoiceDisc(Rec);
                end;
            }
            action(Dimensions)
            {
                ApplicationArea = All;
                AccessByPermission = TableData Dimension = R;
                Caption = 'Dimensions';
                Image = Dimensions;
                ShortCutKey = 'Shift+Ctrl+D';
                Visible = false;
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
        CopySalesDoc: Report "Copy Sales Document";
        UserMgt: Codeunit "User Setup Management";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
        cslSalesTrigger: Codeunit "CCS CASH POS Reg. Sales Trg.";
        DocNoVisible: Boolean;
        RetailUser: Record "CCS CASH Retail User";
        Text001: Label 'Do you really want to abort the Transaction?';
        POSTerm: Record "CCS CASH POS Terminal";
        TransHeader: Record "CCS CASH POS Transaction Hdr.";
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

    local procedure SetDocNoVisible()
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
        DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",Reminder,FinChMemo;
    begin
        DocNoVisible := DocumentNoVisibility.SalesDocumentNoIsVisible(DocType::Invoice, Rec."No.");
    end;

    local procedure ShowPreview()
    var
        SalesPostYesNo: Codeunit "Sales-Post (Yes/No)";
    begin
        SalesPostYesNo.Preview(Rec);
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