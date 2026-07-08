report 1070554 "CCS CASH Trans Pay Entry Cor."
{
    AdditionalSearchTerms = 'CASH Transaction Payment Correction', Locked = true;
    ApplicationArea = CCSCASH;
    Caption = 'Transaction Payment Correction - Cash Register';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(CASHPOSTransactionHdr; "CCS CASH POS Transaction Hdr.")
        {
            CalcFields = "Sales Amount", "Payment Amount";
            RequestFilterFields = "Transaction Type", "Sales Amount", "Payment Amount";

            trigger OnAfterGetRecord()
            var
                TransPmt: Record "CCS CASH Trans. Payment Entry";
                CCSCASHTransPmtEVoided: Record "CCS CASH Trans. Pmt. E. Voided";
                TenderType: Record "CCS CASH Store Tender Type";
                CCSCASHTransSalesEntry: Record "CCS CASH Trans. Sales Entry";
                CCSCASHPOSRegisterFunc: Codeunit "CCS CASH POS Register Func";
            begin
                If CASHPOSTransactionHdr.Status <> CASHPOSTransactionHdr.Status::Voided then begin
                    TransPmt.Reset();
                    TransPmt.SetRange("Store No.", CASHPOSTransactionHdr."Store No.");
                    TransPmt.SetRange("POS Terminal No.", CASHPOSTransactionHdr."POS Terminal No.");
                    TransPmt.SetRange("Transaction No.", CASHPOSTransactionHdr."Transaction No.");
                    if not TransPmt.IsEmpty() then
                        CurrReport.Skip();

                    CCSCASHTransPmtEVoided.Reset();
                    CCSCASHTransPmtEVoided.SetRange("Store No.", CASHPOSTransactionHdr."Store No.");
                    CCSCASHTransPmtEVoided.SetRange("POS Terminal No.", CASHPOSTransactionHdr."POS Terminal No.");
                    CCSCASHTransPmtEVoided.SetRange("Transaction No.", CASHPOSTransactionHdr."Transaction No.");
                    if CCSCASHTransPmtEVoided.IsEmpty() then
                        CurrReport.Skip();

                    CCSCASHTransPmtEVoided.FindFirst();

                    TenderType.Get(CCSCASHTransPmtEVoided."Store No.", CCSCASHTransPmtEVoided."Tender Type", '');

                    //Create Trans Payment
                    TransPmt.Init();
                    TransPmt."Store No." := CASHPOSTransactionHdr."Store No.";
                    TransPmt."POS Terminal No." := CASHPOSTransactionHdr."POS Terminal No.";
                    TransPmt."Transaction No." := CASHPOSTransactionHdr."Transaction No.";
                    TransPmt."Line No." := 10000;
                    TransPmt."Receipt No." := CASHPOSTransactionHdr."Receipt No.";
                    TransPmt.Validate("Tender Type", CCSCASHTransPmtEVoided."Tender Type");
                    TransPmt."CardNo. Select" := false;
                    TransPmt.Validate(Amount, CASHPOSTransactionHdr."Sales Amount");
                    TransPmt.Validate("Account Type", CCSCASHPOSRegisterFunc.GetAccountType_Payment(TenderType."Account Type"));
                    TransPmt.Validate("Account No.", TenderType."Account No.");
                    TransPmt."Transaction Type" := CASHPOSTransactionHdr."Transaction Type";
                    TransPmt."Tender Description" := CopyStr(
#pragma warning disable AA0217
                  StrSubstNo(Text020, CCSCASHPOSRegisterFunc.CreateDocumentNo(CASHPOSTransactionHdr)) + StrSubstNo(' (%1 %2)', TenderType.Code, TenderType.Description), 1, 50);
#pragma warning restore AA0217
                    TransPmt.Insert(true);
                end else begin
                    If (CASHPOSTransactionHdr."Sales Amount" <> 0) AND (CASHPOSTransactionHdr."Payment Amount" = 0) then begin
                        CCSCASHTransSalesEntry.Reset();
                        CCSCASHTransSalesEntry.SetRange("Store No.", CASHPOSTransactionHdr."Store No.");
                        CCSCASHTransSalesEntry.SetRange("POS Terminal No.", CASHPOSTransactionHdr."POS Terminal No.");
                        CCSCASHTransSalesEntry.SetRange("Transaction No.", CASHPOSTransactionHdr."Transaction No.");
                        if not CCSCASHTransSalesEntry.IsEmpty() then
                            CCSCASHTransSalesEntry.DeleteAll();
                    end;
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }

        trigger OnOpenPage()
        begin
            CASHPOSTransactionHdr.SetFilter("Sales Amount", '<>%1', 0);
            CASHPOSTransactionHdr.SetRange("Transaction Type", CASHPOSTransactionHdr."Transaction Type"::Sales);
            CASHPOSTransactionHdr.SetFilter("Payment Amount", '%1', 0);
        end;
    }


    var
        Text020: Label 'Transaction %1', Comment = '%1=Value 1';
}