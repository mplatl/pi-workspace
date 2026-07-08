codeunit 1070550 "CCS CASH POS Register Events"
{

    var
        CSLFunc: Codeunit "CCS CASH POS Register Func";
        CSLSalesTrigger: Codeunit "CCS CASH POS Reg. Sales Trg.";
    //EverythingInvoiced: Boolean;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterInsertEvent', '', true, true)]
    local procedure T36_OnAfterInsert(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if Rec."CCS CASH CSL Document" then
            CSLSalesTrigger.SyncSalesHeader(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterModifyEvent', '', true, true)]
    local procedure T36_OnAfterModify(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if Rec."CCS CASH CSL Document" then
            CSLSalesTrigger.SyncSalesHeader(Rec, 1);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterDeleteEvent', '', true, true)]
    local procedure T36_OnAfterDelete(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if Rec."CCS CASH CSL Document" then
            CSLSalesTrigger.SyncSalesHeader(Rec, 2);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Sell-to Customer No.', true, true)]
    local procedure T36_OnBeforeValidate_SellToCustomerNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterValidateEvent', 'Sell-to Customer No.', true, true)]
    local procedure T36_OnAfterValidate_SellToCustomerNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        POSTerm: Record "CCS CASH POS Terminal";
        POSTrans: Record "CCS CASH POS Transaction Hdr.";
    begin
        if Rec."CCS CASH CSL Document" then begin
            POSTerm.Get(Rec."CCS CASH CSL Store No.", Rec."CCS CASH CSL POS Terminal No.");
            if Rec."Sell-to Customer No." <> Rec."Bill-to Customer No." then
                Rec.Validate("Bill-to Customer No.", Rec."Sell-to Customer No.");
            if (POSTerm."Location Code" <> '') and (POSTerm."Location Code" <> Rec."Location Code") then
                Rec.Validate("Location Code", POSTerm."Location Code");
            if POSTrans.Get(Rec."CCS CASH CSL Store No.", Rec."CCS CASH CSL POS Terminal No.", Rec."CCS CASH CSL Transaction No.") then
                if POSTrans."Customer No." <> Rec."Sell-to Customer No." then begin
                    POSTrans."Customer No." := Rec."Sell-to Customer No.";
                    POSTrans.Modify();
                end;
            Rec.Validate("Payment Method Code", '');
            Rec.Validate("Prepayment %", 0);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Bill-to Customer No.', true, true)]
    local procedure T36_OnBeforeValidate_BillToCustomerNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterSetFieldsBilltoCustomer', '', true, true)]
    local procedure T36_OnAfterSetFieldsBilltoCustomer(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    var
        Staff: Record "CCS CASH Staff";
    begin
        if SalesHeader."CCS CASH CSL Document" then
            if Staff.Get(SalesHeader."CCS CASH CSL Staff ID") then
                if Staff."Salesperson Code" <> '' then
                    SalesHeader."Salesperson Code" := Staff."Salesperson Code";
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterValidateEvent', 'Invoice Discount Calculation', true, true)]
    local procedure T36_OnAfterValidate_InvoiceDiscountCalculation(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            if Rec."Invoice Discount Calculation" = Rec."Invoice Discount Calculation"::None then
                Rec."Invoice Discount Value" := 0;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterValidateEvent', 'Invoice Discount Value', true, true)]
    local procedure T36_OnAfterValidate_InvoiceDiscountValue(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            if Rec."Invoice Discount Value" <> 0 then begin
                if Rec."Invoice Discount Calculation" = Rec."Invoice Discount Calculation"::None then
                    Rec."Invoice Discount Calculation" := Rec."Invoice Discount Calculation"::"%";
            end;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Sell-to Customer Templ. Code', true, true)]
    local procedure T36_OnBeforeValidate_SellToCustomerTemplateCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Sell-to Contact No.', true, true)]
    local procedure T36_OnBeforeValidate_SellToContactNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Bill-to Contact No.', true, true)]
    local procedure T36_OnBeforeValidate_BillToContactNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Bill-to Customer Templ. Code', true, true)]
    local procedure T36_OnBeforeValidate_BillToCustomerTemplateCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeInitInsert', '', true, true)]
    local procedure T36_OnBeforeInitInsert(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
        if (SalesHeader."No." = '') and SalesHeader."CCS CASH CSL Document" then
            CSLSalesTrigger.TestNoSeries(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterInitRecord', '', true, true)]
    local procedure T36_OnAfterInitRecord(var SalesHeader: Record "Sales Header")
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if SalesHeader."CCS CASH CSL Document" then begin
            if (SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) then begin
                if (SalesHeader."No. Series" <> '') and
                    CSLSalesTrigger.NoSeriesEQUALPosteNoSeries(SalesHeader)
                then
                    SalesHeader."Posting No. Series" := SalesHeader."No. Series"
                else
                    NoSeriesMgt.SetDefaultSeries(SalesHeader."Posting No. Series", CSLSalesTrigger.GetPostedNoSeriesCode(SalesHeader));
            end;
            if (SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo") then begin
                if (SalesHeader."No. Series" <> '') and
                    CSLSalesTrigger.NoSeriesEQUALPosteNoSeries(SalesHeader)
                then
                    SalesHeader."Posting No. Series" := SalesHeader."No. Series"
                else
                    NoSeriesMgt.SetDefaultSeries(SalesHeader."Posting No. Series", CSLSalesTrigger.GetPostedNoSeriesCode(SalesHeader));
            end;
            CSLSalesTrigger.InitRecord(SalesHeader);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeTestNoSeries', '', true, true)]
    local procedure T36_OnBeforeTestNoSeries(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
        if SalesHeader."CCS CASH CSL Document" then begin
            if (SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) or
               (SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo") then begin
                CSLSalesTrigger.TestNoSeries(SalesHeader);
                IsHandled := true;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterGetNoSeriesCode', '', true, true)]
    local procedure T36_OnAfterGetNoSeriesCode(var SalesHeader: Record "Sales Header"; SalesReceivablesSetup: Record "Sales & Receivables Setup"; var NoSeriesCode: Code[20])
    begin
        if SalesHeader."CCS CASH CSL Document" then begin
            NoSeriesCode := CSLSalesTrigger.GetNoSeriesCode(SalesHeader);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeGetPostingNoSeriesCode', '', true, true)]
    local procedure T36_OnBeforeGetPostingNoSeriesCode(var SalesHeader: Record "Sales Header"; SalesSetup: Record "Sales & Receivables Setup"; var NoSeriesCode: Code[20]; var IsHandled: Boolean)
    begin
        if SalesHeader."CCS CASH CSL Document" then begin
            NoSeriesCode := CSLSalesTrigger.GetPostedNoSeriesCode(SalesHeader);
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnRecreateSalesLinesOnBeforeConfirm', '', true, true)]
    local procedure T36_OnRecreateSalesLinesOnBeforeConfirm(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; ChangedFieldName: Text[100]; HideValidationDialog: Boolean; var Confirmed: Boolean; var IsHandled: Boolean)
    begin
        if SalesHeader."CCS CASH CSL Document" then
            SalesHeader.SetHideValidationDialog(SalesHeader."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Ship-to Code', true, true)]
    local procedure T36_OnBeforeValidate_ShiptoCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Order Date', true, true)]
    local procedure T36_OnBeforeValidate_OrderDate(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Posting Date', true, true)]
    local procedure T36_OnBeforeValidate_PostingDate(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Location Code', true, true)]
    local procedure T36_OnBeforeValidate_LocationCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Customer Price Group', true, true)]
    local procedure T36_OnBeforeValidate_CustomerPriceGroup(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Invoice Disc. Code', true, true)]
    local procedure T36_OnBeforeValidate_InvoiceDiscCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Customer Disc. Group', true, true)]
    local procedure T36_OnBeforeValidate_CustomerDiscGroup(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Language Code', true, true)]
    local procedure T36_OnBeforeValidate_LanguageCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Tax Area Code', true, true)]
    local procedure T36_OnBeforeValidate_TaxAreaCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Tax Liable', true, true)]
    local procedure T36_OnBeforeValidate_TaxLiable(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Allow Line Disc.', true, true)]
    local procedure T36_OnBeforeValidate_AllowLineDisc(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterInsertEvent', '', true, true)]
    local procedure T37_OnAfterInsert(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if Rec."CCS CASH CSL Document" and (Rec.Type <> Rec.Type::" ") then
            CSLSalesTrigger."Sync. SalesLine"(Rec, 0);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterModifyEvent', '', true, true)]
    local procedure T37_OnAfterModify(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if Rec."CCS CASH CSL Document" and (Rec.Type <> Rec.Type::" ") then
            CSLSalesTrigger."Sync. SalesLine"(Rec, 1);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterDeleteEvent', '', true, true)]
    local procedure T37_OnAfterDelete(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if Rec."CCS CASH CSL Document" and (Rec.Type <> Rec.Type::" ") then
            CSLSalesTrigger."Sync. SalesLine"(Rec, 2);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeValidateEvent', 'Shipment Date', true, true)]
    local procedure T37_OnBeforeValidate_ShipmentDate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec."CCS CASH CSL Document" then
            Rec.SetHideValidationDialog(Rec."CCS CASH CSL Document");
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterAssignResourceValues', '', true, true)]
    local procedure T37_OnAfterAssignResourceValues(var SalesLine: Record "Sales Line"; Resource: Record Resource)
    begin
        SalesLine."CCS CASH IsVoucher" := Resource."CCS CASH IsVoucher";
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterGetSalesHeader', '', true, true)]
    local procedure T37_OnAfterGetSalesHeader(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var Currency: Record Currency)
    begin
        SalesLine."CCS CASH CSL Document" := SalesHeader."CCS CASH CSL Document";
        SalesLine."CCS CASH CSL Staff ID" := SalesHeader."CCS CASH CSL Staff ID";
        SalesLine."CCS CASH CSL Store No." := SalesHeader."CCS CASH CSL Store No.";
        SalesLine."CCS CASH CSL POS Terminal No." := SalesHeader."CCS CASH CSL POS Terminal No.";
        SalesLine."CCS CASH CSL Transaction No." := SalesHeader."CCS CASH CSL Transaction No.";
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterInitHeaderDefaults', '', true, true)]
    local procedure T37_OnAfterInitHeaderDefaults(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
        SalesLine."CCS CASH CSL Document" := SalesHeader."CCS CASH CSL Document";
        SalesLine."CCS CASH CSL Staff ID" := SalesHeader."CCS CASH CSL Staff ID";
        SalesLine."CCS CASH CSL Store No." := SalesHeader."CCS CASH CSL Store No.";
        SalesLine."CCS CASH CSL POS Terminal No." := SalesHeader."CCS CASH CSL POS Terminal No.";
        SalesLine."CCS CASH CSL Transaction No." := SalesHeader."CCS CASH CSL Transaction No.";
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterUpdateVATOnLines', '', true, true)]
    local procedure T37_OnAfterUpdateVATOnLines(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line"; QtyType: Option General,Invoicing,Shipping)
    begin
        if SalesHeader."CCS CASH CSL Document" then begin
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.FindSet() then
                repeat
                    if not SalesLine.ZeroAmountLine(QtyType) then begin
                        VATAmountLine.Get(SalesLine."VAT Identifier", SalesLine."VAT Calculation Type", SalesLine."Tax Group Code", false, SalesLine."Line Amount" >= 0);
                        if VATAmountLine.Modified then begin
                            CSLSalesTrigger."Sync. SalesLine"(SalesLine, 1);
                        end;
                    end;
                until SalesLine.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 111, 'OnAfterInsertInvLineFromShptLine', '', true, true)]
    local procedure T111_OnAfterInsertInvLineFromShptLine(var SalesLine: Record "Sales Line"; SalesOrderLine: Record "Sales Line"; NextLineNo: Integer)
    begin
        if SalesLine."CCS CASH CSL Document" and (SalesLine.Type <> SalesLine.Type::" ") then
            CSLSalesTrigger."Sync. SalesLine"(SalesLine, 0);
    end;

    [EventSubscriber(ObjectType::Table, 289, 'OnAfterValidateEvent', 'Bal. Account No.', true, true)]
    local procedure T289_OnAfterValidate_BalAccountNo(var Rec: Record "Payment Method"; var xRec: Record "Payment Method"; CurrFieldNo: Integer)
    begin
        if Rec."Bal. Account No." <> '' then
            Rec.TestField("CCS CASH CSL Tender Type", '');
    end;

    [EventSubscriber(ObjectType::Table, 289, 'OnAfterValidateEvent', 'Direct Debit', true, true)]
    local procedure T289_OnAfterValidate_DirectDebit(var Rec: Record "Payment Method"; var xRec: Record "Payment Method"; CurrFieldNo: Integer)
    begin
        if Rec."Direct Debit" then
            Rec.TestField("CCS CASH CSL Tender Type", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, 60, 'OnAfterCalcSalesDiscount', '', true, true)]
    local procedure C60_OnAfterCalcSalesDiscount(var SalesHeader: Record "Sales Header")
    var
        CustInvDisc: Record "Cust. Invoice Disc.";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        SalesSetup: Record "Sales & Receivables Setup";
        SalesLine2: Record "Sales Line";
    begin
        SalesSetup.Get();
        CustInvDisc.SetRange(Code, SalesHeader."Invoice Disc. Code");
        if CustInvDisc.IsEmpty then begin
            if SalesHeader."CCS CASH CSL Document" then begin
                // >> CCxx
                SalesLine2.Reset();
                SalesLine2.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine2.SetRange("Document No.", SalesHeader."No.");
                SalesLine2.SetFilter(Type, '<>0');
                if SalesLine2.FindFirst() then;
                SalesLine2.CalcVATAmountLines(0, SalesHeader, SalesLine2, TempVATAmountLine);
                // << CCxx
                case SalesHeader."Invoice Discount Calculation" of
                    SalesHeader."Invoice Discount Calculation"::None,
                    SalesHeader."Invoice Discount Calculation"::"%":
                        begin
                            if SalesHeader."Invoice Discount Calculation" = SalesHeader."Invoice Discount Calculation"::None
                            then begin
                                SalesHeader."Invoice Discount Value" := 0;
                                //IF NOT UpdateHeader THEN
                                SalesHeader.Modify();
                            end;
                            TempVATAmountLine.SetInvoiceDiscountPercent(
                              SalesHeader."Invoice Discount Value", SalesHeader."Currency Code",
                              SalesHeader."Prices Including VAT", SalesSetup."Calc. Inv. Disc. per VAT ID",
                              SalesHeader."VAT Base Discount %");
                        end;

                    SalesHeader."Invoice Discount Calculation"::Amount:
                        TempVATAmountLine.SetInvoiceDiscountAmount(
                          SalesHeader."Invoice Discount Value", SalesHeader."Currency Code",
                          SalesHeader."Prices Including VAT", SalesHeader."VAT Base Discount %");
                end;
                SalesLine2.SetSalesHeader(SalesHeader);
                SalesLine2.UpdateVATOnLines(0, SalesHeader, SalesLine2, TempVATAmountLine);
                SalesCalcDiscountByType.ResetRecalculateInvoiceDisc(SalesHeader);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostSalesDoc', '', true, true)]
    local procedure C80_OnBeforePostSalesDoc(var Sender: Codeunit "Sales-Post"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean)
    var
        AbortCashPosting: Boolean;
    begin
        if not PreviewMode then begin
            AbortCashPosting := CSLFunc.OnBeforeCSLPosting(SalesHeader);
            if AbortCashPosting then
                IsHandled := true;
        end;
        /*  locEverythingInvoiced := true;
            SalesLine.SetCurrentKey("Document Type", "Document No.", "Line No.");
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.FindSet() then
                repeat
                    if SalesLine."Quantity Invoiced" <> SalesLine.Quantity then
                        locEverythingInvoiced := false;
                until SalesLine.Next() = 0;
            if locEverythingInvoiced then begin
                DeleteAfterPosting(SalesHeader);
            end;*/
    end;

    /*local procedure DeleteAfterPosting(var SalesHeader: Record "Sales Header")
    var
        SalesCommentLine: Record "Sales Comment Line";
        SalesLine: Record "Sales Line";
        WarehouseRequest: Record "Warehouse Request";
        SalesLineReserve: Codeunit "Sales Line-Reserve";
        DeferralUtilities: Codeunit "Deferral Utilities";
    begin
        if SalesHeader.HasLinks() then
            SalesHeader.DeleteLinks();
        WarehouseRequest.DeleteRequest(DATABASE::"Sales Line", SalesHeader."Document Type".AsInteger(), SalesHeader."No.");

        SalesLineReserve.DeleteInvoiceSpecFromHeader(SalesHeader);
        DeleteATOLinks(SalesHeader);

        SalesLine.SetCurrentKey("Document Type", "Document No.", "Line No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                if SalesLine."Deferral Code" <> '' then
                    DeferralUtilities.RemoveOrSetDeferralSchedule(
                        '', "Deferral Document Type"::Sales.AsInteger(), '', '', SalesLine."Document Type".AsInteger(),
                        SalesLine."Document No.", SalesLine."Line No.", 0, 0D, SalesLine.Description, '', true);
                if SalesLine.HasLinks() then
                    SalesLine.DeleteLinks();
            until SalesLine.Next() = 0;

        SalesLine.SetCurrentKey("Document Type", "Document No.", "Line No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.DeleteAll();

        DeleteItemChargeAssgnt(SalesHeader);
        SalesCommentLine.DeleteComments(SalesHeader."Document Type".AsInteger(), SalesHeader."No.");
        if SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.") then
            SalesHeader.Delete();
    end;

    local procedure DeleteATOLinks(SalesHeader: Record "Sales Header")
    var
        ATOLink: Record "Assemble-to-Order Link";
    begin
        ATOLink.SetCurrentKey(ATOLink.Type, ATOLink."Document Type", ATOLink."Document No.");
        ATOLink.SetRange(ATOLink.Type, ATOLink.Type::Sale);
        ATOLink.SetRange(ATOLink."Document Type", SalesHeader."Document Type");
        ATOLink.SetRange(ATOLink."Document No.", SalesHeader."No.");
        if not ATOLink.IsEmpty() then
            ATOLink.DeleteAll();
    end;

    local procedure DeleteItemChargeAssgnt(SalesHeader: Record "Sales Header")
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
    begin
        ItemChargeAssgntSales.SetRange("Document Type", SalesHeader."Document Type");
        ItemChargeAssgntSales.SetRange("Document No.", SalesHeader."No.");
        if not ItemChargeAssgntSales.IsEmpty() then
            ItemChargeAssgntSales.DeleteAll();
    end;*/

    /*[EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    local procedure C80_OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if SalesInvoiceHeader.Get(SalesInvHdrNo) then
            CSLFunc.CSLPayMethodPaymentAfterPost(SalesInvoiceHeader);
    end;*/

    /* [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterFinalizePostingOnBeforeCommit', '', true, true)]
     local procedure C80_OnAfterFinalizePostingOnBeforeCommit(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
     var
         SalesLine: Record "Sales Line";
     begin
         EverythingInvoiced := true;
         SalesLine.Reset();
         SalesLine.SetRange("Document Type", SalesHeader."Document Type");
         SalesLine.SetRange("Document No.", SalesHeader."No.");
         if SalesLine.FindSet() then
             repeat
                 if SalesLine."Qty. to Invoice" + SalesLine."Quantity Invoiced" <> SalesLine.Quantity then
                     EverythingInvoiced := false;
             until SalesLine.Next() = 0;

         if (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order"]) and (not EverythingInvoiced) then begin
             if SalesHeader.Invoice then begin
                 CSLFunc.CSLPayMethodPayment(SalesHeader, SalesInvoiceHeader);
             end;
         end else begin
             CSLFunc.CSLPayMethodPayment(SalesHeader, SalesInvoiceHeader);
             if SalesHeader."CCS CASH CSL Document" then
                 CSLFunc.FinalizeCSLPosting(SalesHeader, GenJnlPostLine);
             MakeInventoryAdjustment();
         end;
     end;*/


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure SalesPost_OnAfterFinalizePostingOnBeforeCommit(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; WhseShip: Boolean; WhseReceive: Boolean; var EverythingInvoiced: Boolean)
    begin
        if (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order"]) and (not EverythingInvoiced) then begin
            if SalesHeader.Invoice then begin
                CSLFunc.CSLPayMethodPayment(SalesHeader, SalesInvoiceHeader);
            end;
        end else begin
            CSLFunc.CSLPayMethodPayment(SalesHeader, SalesInvoiceHeader);
            if SalesHeader."CCS CASH CSL Document" then
                CSLFunc.FinalizeCSLPosting(SalesHeader, GenJnlPostLine);
            MakeInventoryAdjustment();
        end;

        if (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) and SalesHeader."CCS CASH CSL Do Cash Posting" then
            CSLFunc.PostSalesDocumentTenderPayment(SalesHeader, SalesInvoiceHeader, SalesCrMemoHeader, EverythingInvoiced);
    end;


    local procedure MakeInventoryAdjustment()
    var
        InvtSetup: Record "Inventory Setup";
        InvtAdjmt: Codeunit "Inventory Adjustment";
    begin
        InvtSetup.Get();
        IF InvtSetup."Automatic Cost Adjustment" <>
           InvtSetup."Automatic Cost Adjustment"::Never
        THEN BEGIN
            InvtAdjmt.SetProperties(TRUE, InvtSetup."Automatic Cost Posting");
            InvtAdjmt.SetJobUpdateProperties(TRUE);
            InvtAdjmt.MakeMultiLevelAdjmt();
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, 1380, 'OnVerifyRecord', '', true, true)]
    local procedure C1380_OnVerifyRecord(var RecRef: RecordRef; var Result: Boolean)
    var
        FldRef: FieldRef;
        PayMethod: Record "Payment Method";
        HelpVar: Code[20];
    begin
        FldRef := RecRef.Field(104);
        Clear(HelpVar);
        HelpVar := FldRef.Value;
        if HelpVar <> '' then
            if PayMethod.Get(HelpVar) and (PayMethod."CCS CASH CSL Tender Type" <> '') then
                Result := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6620, 'OnAfterCopySalesDocument', '', true, true)]
    local procedure C6620_OnAfterCopySalesDocument(FromDocumentType: Option; FromDocumentNo: Code[20]; var ToSalesHeader: Record "Sales Header"; FromDocOccurenceNo: Integer; FromDocVersionNo: Integer; IncludeHeader: Boolean)
    var
        OldSalesHeader: Record "Sales Header";
    begin
        if OldSalesHeader.Get(FromDocumentType, FromDocumentNo) then begin
            if OldSalesHeader."CCS CASH CSL Document" then begin
                if OldSalesHeader."Prices Including VAT" <> ToSalesHeader."Prices Including VAT" then begin
                    ToSalesHeader.Validate("Prices Including VAT", OldSalesHeader."Prices Including VAT");
                end;

                if ToSalesHeader."Posting Date" <> OldSalesHeader."Posting Date" then
                    ToSalesHeader.Validate("Posting Date", OldSalesHeader."Posting Date");
                ToSalesHeader.Modify(true);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6620, 'OnBeforeInsertToSalesLine', '', true, true)]
    local procedure C6620_OnBeforeInsertToSalesLine(var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line"; FromDocType: Option; RecalcLines: Boolean; var ToSalesHeader: Record "Sales Header")
    begin
        if ToSalesHeader."CCS CASH CSL Document" then begin
            ToSalesLine."CCS CASH CSL Document" := true;
            ToSalesLine."CCS CASH CSL POS Terminal No." := ToSalesHeader."CCS CASH CSL POS Terminal No.";
            ToSalesLine."CCS CASH CSL Staff ID" := ToSalesHeader."CCS CASH CSL Staff ID";
            ToSalesLine."CCS CASH CSL Store No." := ToSalesHeader."CCS CASH CSL Store No.";
            ToSalesLine."CCS CASH CSL Transaction No." := ToSalesHeader."CCS CASH CSL Transaction No.";
            ToSalesLine.Validate("Location Code", ToSalesHeader."Location Code");
            CSLSalesTrigger."Sync. SalesLine"(ToSalesLine, 0);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6620, 'OnCopyArchSalesLineOnBeforeToSalesLineInsert', '', true, true)]
    local procedure C6620_OnCopyArchSalesLineOnBeforeToSalesLineInsert(var ToSalesLine: Record "Sales Line"; FromSalesLineArchive: Record "Sales Line Archive"; RecalculateLines: Boolean)
    var
        ToSalesHeader: Record "Sales Header";
    begin
        if ToSalesHeader.Get(ToSalesLine."Document Type", ToSalesLine."Document No.") then begin
            if ToSalesHeader."CCS CASH CSL Document" then
                CSLSalesTrigger."Sync. SalesLine"(ToSalesLine, 0);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6620, 'OnAfterCopyFieldsFromOldSalesHeader', '', true, true)]
    local procedure C6620_OnAfterCopyFieldsFromOldSalesHeader(var ToSalesHeader: Record "Sales Header"; OldSalesHeader: Record "Sales Header"; MoveNegLines: Boolean; IncludeHeader: Boolean)
    begin
        ToSalesHeader."CCS CASH CSL Document" := OldSalesHeader."CCS CASH CSL Document";
        ToSalesHeader."CCS CASH CSL POS Terminal No." := OldSalesHeader."CCS CASH CSL POS Terminal No.";
        ToSalesHeader."CCS CASH CSL Staff ID" := OldSalesHeader."CCS CASH CSL Staff ID";
        ToSalesHeader."CCS CASH CSL Store No." := OldSalesHeader."CCS CASH CSL Store No.";
        ToSalesHeader."CCS CASH CSL Transaction No." := OldSalesHeader."CCS CASH CSL Transaction No.";
        ToSalesHeader."Location Code" := OldSalesHeader."Location Code";
    end;

    [EventSubscriber(ObjectType::Page, 43, 'OnOpenPageEvent', '', true, true)]
    local procedure P43_OnOpenPage(var Rec: Record "Sales Header")
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("CCS CASH CSL Document", false);
        Rec.FilterGroup(0);
    end;

    [EventSubscriber(ObjectType::Page, 44, 'OnOpenPageEvent', '', true, true)]
    local procedure P44_OnOpenPage(var Rec: Record "Sales Header")
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("CCS CASH CSL Document", false);
        Rec.FilterGroup(0);
    end;

    [EventSubscriber(ObjectType::Page, 143, 'OnOpenPageEvent', '', true, true)]
    local procedure P143_OnOpenPage(var Rec: Record "Sales Invoice Header")
    var
        cslSetup: Record "CCS CASH Cash Sales Setup";
    begin
        if cslSetup.Get() then
            if cslSetup."No Display on Standard Pages" then begin
                Rec.FilterGroup(2);
                Rec.SetRange("CCS CASH CSL Document", false);
                Rec.FilterGroup(0);
            end;
    end;

    [EventSubscriber(ObjectType::Page, 344, 'OnAfterNavigateFindRecords', '', true, true)]
    local procedure P344_OnAfterNavigateFindRecords(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
    begin
        if IsPOSLicense() then
            InsertPOSNavigate(DocumentEntry, DocNoFilter, PostingDateFilter);
    end;

    [EventSubscriber(ObjectType::Page, 344, 'OnAfterNavigateShowRecords', '', true, true)]
    local procedure P344_OnAfterNavigateShowRecords(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; ItemTrackingSearch: Boolean; var TempDocumentEntry: Record "Document Entry" temporary)
    begin
        ShowRecordsPOS(TableID, DocNoFilter, PostingDateFilter);
    end;

    [EventSubscriber(ObjectType::Page, 9301, 'OnOpenPageEvent', '', true, true)]
    local procedure P9301_OnOpenPage(var Rec: Record "Sales Header")
    var
        cslSetup: Record "CCS CASH Cash Sales Setup";
    begin
        if cslSetup.Get() then
            if cslSetup."No Display on Standard Pages" then begin
                Rec.FilterGroup(2);
                Rec.SetRange("CCS CASH CSL Document", false);
                Rec.FilterGroup(0);
            end;
    end;

    [EventSubscriber(ObjectType::Page, 9302, 'OnOpenPageEvent', '', true, true)]
    local procedure P9302_OnOpenPage(var Rec: Record "Sales Header")
    var
        cslSetup: Record "CCS CASH Cash Sales Setup";
    begin
        if cslSetup.Get() then
            if cslSetup."No Display on Standard Pages" then begin
                Rec.FilterGroup(2);
                Rec.SetRange("CCS CASH CSL Document", false);
                Rec.FilterGroup(0);
            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Amount Line", 'OnAfterVATAmountText', '', false, false)]
    local procedure OnAfterVATAmountText(VATPercentage: Decimal; FullCount: Integer; var Result: Text[30]);
    var
        Text000: Label '%1% VAT', Comment = '%1=VATPercentage';
        Text001: Label 'VAT Amount';
    begin
        if VATPercentage = 0 then
            Result := Text001
        else
            Result := StrSubstNo(Text000, VATPercentage);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Role Center Notification Mgt.", 'OnBeforeShowNotifications', '', false, false)]
    local procedure "Role Center Notification Mgt._OnBeforeShowNotifications"();
    var
        CCSCASHCashSalesSetup: Record "CCS CASH Cash Sales Setup";
        CCSLICLicensing: Codeunit "CCS LIC Licensing";
        LicenseValidUntil: DateTime;
    begin
        LicenseValidUntil := CCSLICLicensing.GetValidUntil("CCS LIC App Granule"::"CCS CASH Base");
        IF LicenseValidUntil <> 0DT then begin
            CCSCASHCashSalesSetup.SetLoadFields("Automatic Demo License");
            if CCSCASHCashSalesSetup.Get() and CCSCASHCashSalesSetup."Automatic Demo License" then begin
                SendRegistrationNotification(CCSLICLicensing.GetAppId("CCS LIC App Granule"::"CCS CASH Base"));
            end;
        end;
    end;

    local procedure SendRegistrationNotification(AppId: Guid) // 
    var
        AppInfo: ModuleInfo;
        RegistrationNotification: Notification;
        AppRegistrationNotificationLbl: Label '%1 was automatic updated with a demo license, please activate.', Comment = '%1 = app name';
        RegistrationActionLbl: Label 'Click here to register';
        LicenseOverviewActionLbl: Label 'Open License Overview';
    begin
        NavApp.GetModuleInfo(AppId, AppInfo);

        RegistrationNotification.Id := AppId;
        RegistrationNotification.Message(StrSubstNo(AppRegistrationNotificationLbl, AppInfo.Name));
        RegistrationNotification.SetData('AppId', Format(AppId));
        RegistrationNotification.AddAction(RegistrationActionLbl, Codeunit::"CCS CASH POS Register Func", 'ShowRegistrationWizard');
        RegistrationNotification.AddAction(LicenseOverviewActionLbl, Codeunit::"CCS CASH POS Register Func", 'OpenLicenseOverview');
        RegistrationNotification.Scope(NotificationScope::LocalScope);

        RegistrationNotification.Send();
    end;

    local procedure IsPOSLicense(): Boolean
    var
        licPer: Record "License Permission";
    begin
        //-POS001
        Clear(licPer);
        licPer.Reset();
        licPer.SetRange("Object Type", licPer."Object Type"::Codeunit);
        licPer.SetRange("Object Number", 1070540);
        if licPer.FindFirst() and (licPer."Execute Permission" <> licPer."Execute Permission"::" ") then
            exit(true)
        else
            exit(false);
        //+POS001
    end;

    local procedure InsertPOSNavigate(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
    var
        posTransFound: Boolean;
        hFiliale: Text;
        hKasse: Text;
        hTrans: Text;
        DocNoFilter2: Text;
        iTrans: Integer;
        POSTransHeader: Record "CCS CASH POS Transaction Hdr.";
        TransSalesEntry: Record "CCS CASH Trans. Sales Entry";
        TransExpenseEntry: Record "CCS CASH Trans. Expense Entry";
        TransPaymentEntry: Record "CCS CASH Trans. Payment Entry";
        TransTenderDeclEntry: Record "CCS CASH Trans. Tender Dcl. E.";
        TransSafeEntry: Record "CCS CASH Trans. Depot Entry";
        TransCashDeclarationEntry: Record "CCS CASH Trans. Cash Decl. E.";
        TransSalesEntryVoided: Record "CCS CASH Trans Sales E. Voided";
        TransPaymentEntryVoided: Record "CCS CASH Trans. Pmt. E. Voided";
    begin
        //-POS001

        Clear(POSTransHeader);
        Clear(TransSalesEntry);
        Clear(TransExpenseEntry);
        Clear(TransPaymentEntry);
        Clear(TransTenderDeclEntry);
        Clear(TransSafeEntry);
        Clear(TransCashDeclarationEntry);
        Clear(TransSalesEntryVoided);
        Clear(TransPaymentEntryVoided);

        POSTransHeader.Reset();
        POSTransHeader.SetFilter("Receipt No.", DocNoFilter);
        POSTransHeader.SetFilter(POSTransHeader."Creation Date", PostingDateFilter);

        if not POSTransHeader.IsEmpty then begin
            posTransFound := true;
            InsertIntoDocEntry(DocumentEntry, DATABASE::"CCS CASH POS Transaction Hdr.", Enum::"Document Entry Document Type"::Quote, POSTransHeader.TableCaption, POSTransHeader.Count);
        end else begin
            DocNoFilter2 := DocNoFilter;
            if StrPos(DocNoFilter2, '|') <> 0 then
                DocNoFilter2 := CopyStr(DocNoFilter2, StrPos(DocNoFilter2, '|') + 1, StrLen(DocNoFilter2));
            if SelectStringC(1, '-', DocNoFilter2, hFiliale) then
                if SelectStringC(2, '-', DocNoFilter2, hKasse) then
                    if SelectStringC(3, '-', DocNoFilter2, hTrans) then
                        if Evaluate(iTrans, hTrans) then begin
                            POSTransHeader.SetRange("Receipt No.");
                            POSTransHeader.SetRange("Store No.", hFiliale);
                            POSTransHeader.SetRange("POS Terminal No.", hKasse);
                            POSTransHeader.SetRange("Transaction No.", iTrans);

                            if not POSTransHeader.IsEmpty then begin
                                posTransFound := true;
                                InsertIntoDocEntry(DocumentEntry, DATABASE::"CCS CASH POS Transaction Hdr.", Enum::"Document Entry Document Type"::Quote, POSTransHeader.TableCaption, POSTransHeader.Count);
                            end;
                        end;
        end;

        if posTransFound then begin
            if POSTransHeader.FindSet() then
                repeat
                    TransSalesEntry.SetRange("Store No.", POSTransHeader."Store No.");
                    TransSalesEntry.SetRange("POS Terminal No.", POSTransHeader."POS Terminal No.");
                    TransSalesEntry.SetRange("Transaction No.", POSTransHeader."Transaction No.");
                    if TransSalesEntry.FindSet() then
                        repeat
                            TransSalesEntry.Mark(true);
                        until TransSalesEntry.Next() = 0;

                    TransExpenseEntry.SetRange("Store No.", POSTransHeader."Store No.");
                    TransExpenseEntry.SetRange("POS Terminal No.", POSTransHeader."POS Terminal No.");
                    TransExpenseEntry.SetRange("Transaction No.", POSTransHeader."Transaction No.");
                    if TransExpenseEntry.FindSet() then
                        repeat
                            TransExpenseEntry.Mark(true);
                        until TransExpenseEntry.Next() = 0;

                    TransPaymentEntry.SetRange("Store No.", POSTransHeader."Store No.");
                    TransPaymentEntry.SetRange("POS Terminal No.", POSTransHeader."POS Terminal No.");
                    TransPaymentEntry.SetRange("Transaction No.", POSTransHeader."Transaction No.");
                    if TransPaymentEntry.FindSet() then
                        repeat
                            TransPaymentEntry.Mark(true);
                        until TransPaymentEntry.Next() = 0;

                    TransTenderDeclEntry.SetRange("Store No.", POSTransHeader."Store No.");
                    TransTenderDeclEntry.SetRange("POS Terminal No.", POSTransHeader."POS Terminal No.");
                    TransTenderDeclEntry.SetRange("Transaction No.", POSTransHeader."Transaction No.");
                    if TransTenderDeclEntry.FindSet() then
                        repeat
                            TransTenderDeclEntry.Mark(true);
                        until TransTenderDeclEntry.Next() = 0;

                    TransSafeEntry.SetRange("Store No.", POSTransHeader."Store No.");
                    TransSafeEntry.SetRange("POS Terminal No.", POSTransHeader."POS Terminal No.");
                    TransSafeEntry.SetRange("Transaction No.", POSTransHeader."Transaction No.");
                    if TransSafeEntry.FindSet() then
                        repeat
                            TransSafeEntry.Mark(true);
                        until TransSafeEntry.Next() = 0;

                    TransCashDeclarationEntry.SetRange("Store No.", POSTransHeader."Store No.");
                    TransCashDeclarationEntry.SetRange("POS Terminal No.", POSTransHeader."POS Terminal No.");
                    TransCashDeclarationEntry.SetRange("Transaction No.", POSTransHeader."Transaction No.");
                    if TransCashDeclarationEntry.FindSet() then
                        repeat
                            TransCashDeclarationEntry.Mark(true);
                        until TransCashDeclarationEntry.Next() = 0;

                    TransSalesEntryVoided.SetRange("Store No.", POSTransHeader."Store No.");
                    TransSalesEntryVoided.SetRange("POS Terminal No.", POSTransHeader."POS Terminal No.");
                    TransSalesEntryVoided.SetRange("Transaction No.", POSTransHeader."Transaction No.");
                    if TransSalesEntryVoided.FindSet() then
                        repeat
                            TransSalesEntryVoided.Mark(true);
                        until TransSalesEntryVoided.Next() = 0;

                    TransPaymentEntryVoided.SetRange("Store No.", POSTransHeader."Store No.");
                    TransPaymentEntryVoided.SetRange("POS Terminal No.", POSTransHeader."POS Terminal No.");
                    TransPaymentEntryVoided.SetRange("Transaction No.", POSTransHeader."Transaction No.");
                    if TransPaymentEntryVoided.FindSet() then
                        repeat
                            TransPaymentEntryVoided.Mark(true);
                        until TransPaymentEntryVoided.Next() = 0;
                until POSTransHeader.Next() = 0;

            TransSalesEntry.SetRange("Store No.");
            TransSalesEntry.SetRange("POS Terminal No.");
            TransSalesEntry.SetRange("Transaction No.");
            TransSalesEntry.MarkedOnly(true);
            if not TransSalesEntry.IsEmpty then
                InsertIntoDocEntry(DocumentEntry, DATABASE::"CCS CASH Trans. Sales Entry", Enum::"Document Entry Document Type"::Quote, TransSalesEntry.TableCaption, TransSalesEntry.Count);

            TransExpenseEntry.SetRange("Store No.");
            TransExpenseEntry.SetRange("POS Terminal No.");
            TransExpenseEntry.SetRange("Transaction No.");
            TransExpenseEntry.MarkedOnly(true);
            if not TransExpenseEntry.IsEmpty then
                InsertIntoDocEntry(DocumentEntry, DATABASE::"CCS CASH Trans. Expense Entry", Enum::"Document Entry Document Type"::Quote, TransExpenseEntry.TableCaption, TransExpenseEntry.Count);

            TransPaymentEntry.SetRange("Store No.");
            TransPaymentEntry.SetRange("POS Terminal No.");
            TransPaymentEntry.SetRange("Transaction No.");
            TransPaymentEntry.MarkedOnly(true);
            if not TransPaymentEntry.IsEmpty then
                InsertIntoDocEntry(DocumentEntry, DATABASE::"CCS CASH Trans. Payment Entry", Enum::"Document Entry Document Type"::Quote, TransPaymentEntry.TableCaption, TransPaymentEntry.Count);

            TransTenderDeclEntry.SetRange("Store No.");
            TransTenderDeclEntry.SetRange("POS Terminal No.");
            TransTenderDeclEntry.SetRange("Transaction No.");
            TransTenderDeclEntry.MarkedOnly(true);
            if not TransTenderDeclEntry.IsEmpty then
                InsertIntoDocEntry(DocumentEntry, DATABASE::"CCS CASH Trans. Tender Dcl. E.", Enum::"Document Entry Document Type"::Quote, TransTenderDeclEntry.TableCaption, TransTenderDeclEntry.Count);

            TransSafeEntry.SetRange("Store No.");
            TransSafeEntry.SetRange("POS Terminal No.");
            TransSafeEntry.SetRange("Transaction No.");
            TransSafeEntry.MarkedOnly(true);
            if not TransSafeEntry.IsEmpty then
                InsertIntoDocEntry(DocumentEntry, DATABASE::"CCS CASH Trans. Depot Entry", Enum::"Document Entry Document Type"::Quote, TransSafeEntry.TableCaption, TransSafeEntry.Count);

            TransCashDeclarationEntry.SetRange("Store No.");
            TransCashDeclarationEntry.SetRange("POS Terminal No.");
            TransCashDeclarationEntry.SetRange("Transaction No.");
            TransCashDeclarationEntry.MarkedOnly(true);
            if not TransCashDeclarationEntry.IsEmpty then
                InsertIntoDocEntry(DocumentEntry, DATABASE::"CCS CASH Trans. Cash Decl. E.", Enum::"Document Entry Document Type"::Quote, TransCashDeclarationEntry.TableCaption, TransCashDeclarationEntry.Count);

            TransSalesEntryVoided.SetRange("Store No.");
            TransSalesEntryVoided.SetRange("POS Terminal No.");
            TransSalesEntryVoided.SetRange("Transaction No.");
            TransSalesEntryVoided.MarkedOnly(true);
            if not TransSalesEntryVoided.IsEmpty then
                InsertIntoDocEntry(DocumentEntry, DATABASE::"CCS CASH Trans Sales E. Voided", Enum::"Document Entry Document Type"::Quote, TransSalesEntryVoided.TableCaption, TransSalesEntryVoided.Count);

            TransPaymentEntryVoided.SetRange("Store No.");
            TransPaymentEntryVoided.SetRange("POS Terminal No.");
            TransPaymentEntryVoided.SetRange("Transaction No.");
            TransPaymentEntryVoided.MarkedOnly(true);
            if not TransPaymentEntryVoided.IsEmpty then
                InsertIntoDocEntry(DocumentEntry, DATABASE::"CCS CASH Trans. Pmt. E. Voided", Enum::"Document Entry Document Type"::Quote, TransPaymentEntryVoided.TableCaption, TransPaymentEntryVoided.Count);
        end;
        //+POS001
    end;

    local procedure InsertIntoDocEntry(var DocumentEntry: Record "Document Entry"; DocTableID: Integer; DocType: Enum "Document Entry Document Type"; DocTableName: Text; DocNoOfRecords: Integer)
    begin
        if DocNoOfRecords = 0 then
            exit;
        DocumentEntry.Init();
        DocumentEntry."Entry No." := DocumentEntry."Entry No." + 1;
        DocumentEntry."Table ID" := DocTableID;
        DocumentEntry."Document Type" := DocType;
        DocumentEntry."Table Name" := CopyStr(DocTableName, 1, MaxStrLen(DocumentEntry."Table Name"));
        DocumentEntry."No. of Records" := DocNoOfRecords;
        DocumentEntry.Insert();
    end;

    local procedure ShowRecordsPOS(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text)
    var
        POSTransHeader: Record "CCS CASH POS Transaction Hdr.";
        TransSalesEntry: Record "CCS CASH Trans. Sales Entry";
        TransExpenseEntry: Record "CCS CASH Trans. Expense Entry";
        TransPaymentEntry: Record "CCS CASH Trans. Payment Entry";
        TransTenderDeclEntry: Record "CCS CASH Trans. Tender Dcl. E.";
        TransSafeEntry: Record "CCS CASH Trans. Depot Entry";
        TransCashDeclarationEntry: Record "CCS CASH Trans. Cash Decl. E.";
        TransSalesEntryVoided: Record "CCS CASH Trans Sales E. Voided";
        TransPaymentEntryVoided: Record "CCS CASH Trans. Pmt. E. Voided";
        hFiliale: Text;
        hKasse: Text;
        hTrans: Text;
        DocNoFilter2: Text;
        iTrans: Integer;
    begin
        //-POS001
        POSTransHeader.Reset();
        POSTransHeader.SetFilter("Receipt No.", DocNoFilter);
        POSTransHeader.SetFilter(POSTransHeader."Creation Date", PostingDateFilter);
        if not POSTransHeader.FindFirst() then begin
            DocNoFilter2 := DocNoFilter;
            if StrPos(DocNoFilter2, '|') <> 0 then
                DocNoFilter2 := CopyStr(DocNoFilter2, StrPos(DocNoFilter2, '|') + 1, StrLen(DocNoFilter2));
            if SelectStringC(1, '-', DocNoFilter2, hFiliale) then
                if SelectStringC(2, '-', DocNoFilter2, hKasse) then
                    if SelectStringC(3, '-', DocNoFilter2, hTrans) then
                        if Evaluate(iTrans, hTrans) then begin
                            POSTransHeader.SetRange("Receipt No.");
                            POSTransHeader.SetRange("Store No.", hFiliale);
                            POSTransHeader.SetRange("POS Terminal No.", hKasse);
                            POSTransHeader.SetRange("Transaction No.", iTrans);
                        end;
        end;
        //
        case TableID of
            DATABASE::"CCS CASH POS Transaction Hdr.":
                begin
                    PAGE.Run(1070566, POSTransHeader);
                end;
            DATABASE::"CCS CASH Trans. Sales Entry":
                begin
                    TransSalesEntry.Reset();
                    TransSalesEntry.SetRange("Store No.", POSTransHeader."Store No.");
                    TransSalesEntry.SetRange("POS Terminal No.", POSTransHeader."POS Terminal No.");
                    TransSalesEntry.SetRange("Transaction No.", POSTransHeader."Transaction No.");
                    PAGE.Run(1070567, TransSalesEntry);
                end;
            DATABASE::"CCS CASH Trans. Expense Entry":
                begin
                    TransExpenseEntry.Reset();
                    TransExpenseEntry.SetRange("Store No.", POSTransHeader."Store No.");
                    TransExpenseEntry.SetRange("POS Terminal No.", POSTransHeader."POS Terminal No.");
                    TransExpenseEntry.SetRange("Transaction No.", POSTransHeader."Transaction No.");
                    PAGE.Run(1070576, TransExpenseEntry);
                end;
            DATABASE::"CCS CASH Trans. Payment Entry":
                begin
                    TransPaymentEntry.Reset();
                    TransPaymentEntry.SetRange("Store No.", POSTransHeader."Store No.");
                    TransPaymentEntry.SetRange("POS Terminal No.", POSTransHeader."POS Terminal No.");
                    TransPaymentEntry.SetRange("Transaction No.", POSTransHeader."Transaction No.");
                    PAGE.Run(1070568, TransPaymentEntry);
                end;
            DATABASE::"CCS CASH Trans. Tender Dcl. E.":
                begin
                    TransTenderDeclEntry.Reset();
                    TransTenderDeclEntry.SetRange("Store No.", POSTransHeader."Store No.");
                    TransTenderDeclEntry.SetRange("POS Terminal No.", POSTransHeader."POS Terminal No.");
                    TransTenderDeclEntry.SetRange("Transaction No.", POSTransHeader."Transaction No.");
                    PAGE.Run(1070572, TransTenderDeclEntry);
                end;
            DATABASE::"CCS CASH Trans. Depot Entry":
                begin
                    TransSafeEntry.Reset();
                    TransSafeEntry.SetRange("Store No.", POSTransHeader."Store No.");
                    TransSafeEntry.SetRange("POS Terminal No.", POSTransHeader."POS Terminal No.");
                    TransSafeEntry.SetRange("Transaction No.", POSTransHeader."Transaction No.");
                    PAGE.Run(1070573, TransSafeEntry);
                end;
            DATABASE::"CCS CASH Trans. Cash Decl. E.":
                begin
                    TransCashDeclarationEntry.Reset();
                    TransCashDeclarationEntry.SetRange("Store No.", POSTransHeader."Store No.");
                    TransCashDeclarationEntry.SetRange("POS Terminal No.", POSTransHeader."POS Terminal No.");
                    TransCashDeclarationEntry.SetRange("Transaction No.", POSTransHeader."Transaction No.");
                    PAGE.Run(1070569, TransCashDeclarationEntry);
                end;
            DATABASE::"CCS CASH Trans Sales E. Voided":
                begin
                    TransSalesEntryVoided.Reset();
                    TransSalesEntryVoided.SetRange("Store No.", POSTransHeader."Store No.");
                    TransSalesEntryVoided.SetRange("POS Terminal No.", POSTransHeader."POS Terminal No.");
                    TransSalesEntryVoided.SetRange("Transaction No.", POSTransHeader."Transaction No.");
                    PAGE.Run(1070574, TransSalesEntryVoided);
                end;
            DATABASE::"CCS CASH Trans. Pmt. E. Voided":
                begin
                    TransPaymentEntryVoided.Reset();
                    TransPaymentEntryVoided.SetRange("Store No.", POSTransHeader."Store No.");
                    TransPaymentEntryVoided.SetRange("POS Terminal No.", POSTransHeader."POS Terminal No.");
                    TransPaymentEntryVoided.SetRange("Transaction No.", POSTransHeader."Transaction No.");
                    PAGE.Run(1070575, TransPaymentEntryVoided);
                end;
        end;
        //+POS001
    end;

    local procedure SelectStringC(nNumber: Integer; trenn: Char; sInput: Text; var sOutput: Text): Boolean
    var
        i: Integer;
        nStart: Integer;
        nEnd: Integer;
        nLen: Integer;
    begin
        //-POS001
        i := 1;
        nStart := 1;
        nLen := StrLen(sInput);

        while nStart <= nLen do begin
            nEnd := CharPos(sInput, trenn, nStart);

            if i = nNumber then begin
                sOutput := '';

                if nEnd = 0 then
                    nEnd := nLen + 1;
                if nStart < nEnd then
                    sOutput := CopyStr(sInput, nStart, nEnd - nStart);

                exit(true);
            end;

            if nEnd <> 0 then
                nStart := nEnd + 1
            else
                nStart := nLen + 1;

            i += 1;
        end;

        exit(false);
        //+POS001
    end;

    local procedure CharPos(sInput: Text; c: Char; nStartAt: Integer): Integer
    var
        i: Integer;
    begin
        //-POS001
        if nStartAt = 0 then nStartAt := 1;

        for i := nStartAt to StrLen(sInput) do
            if sInput[i] = c then exit(i);

        exit(0);
        //+POS001
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", 'OnAfterCopyEnvironmentToSandbox', '', false, false)]
    local procedure OnAfterCopyEnvironmentToSandbox()
    begin
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", 'OnAfterCopyEnvironmentToSandboxPerCompany', '', false, false)]
    local procedure OnAfterCopyEnvironmentToSandboxPerCompany()
    var
        SignatureServiceSetup: Record "CCS CASH Signa. Service Setup";
    begin
        if SignatureServiceSetup.FindSet(true) then
            repeat
                SignatureServiceSetup."WebService Main Path" := '';
                SignatureServiceSetup."WebService QR Path" := '';
                SignatureServiceSetup."WebService State Path" := '';
                SignatureServiceSetup."WebService Export Path" := '';
                SignatureServiceSetup."WebService Active" := false;
                SignatureServiceSetup.Modify();
            until SignatureServiceSetup.Next() = 0;
    end;


    [EventSubscriber(ObjectType::Page, Page::"Navigate", 'OnFindRecordsOnOpenOnAfterSetDocuentFilters', '', false, false)]
    local procedure Navigate_OnFindRecordsOnOpenOnAfterSetDocuentFilters(var Rec: Record "Document Entry"; var DocNoFilter: Text; var PostingDateFilter: Text; ExtDocNo: Code[250]; NewSourceRecVar: Variant)
    var
        RecRef: RecordRef;
        POSTransactionHdr: Record "CCS CASH POS Transaction Hdr.";
    begin
        if not NewSourceRecVar.IsRecord then
            exit;
        RecRef.GetTable(NewSourceRecVar);
        if RecRef.Number = Database::"CCS CASH POS Transaction Hdr." then begin
            RecRef.SetTable(POSTransactionHdr);
            if POSTransactionHdr."Receipt No." <> '' then
                DocNoFilter := POSTransactionHdr."Receipt No." + '|' + StrSubstNo('%1-%2-%3', POSTransactionHdr."Store No.", POSTransactionHdr."POS Terminal No.", POSTransactionHdr."Transaction No.")
            else
                DocNoFilter := StrSubstNo('%1-%2-%3', POSTransactionHdr."Store No.", POSTransactionHdr."POS Terminal No.", POSTransactionHdr."Transaction No.");
        end
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterAssignHeaderValues, '', false, false)]
    local procedure SalesLine_OnAfterAssignHeaderValues(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    var
        POSTerm: Record "CCS CASH POS Terminal";
    begin
        if SalesHeader."CCS CASH CSL Document" then begin // Fix for COSMO AMP changing default location  
            POSTerm.SetLoadFields("Location Code");
            POSTerm.Get(SalesHeader."CCS CASH CSL Store No.", SalesHeader."CCS CASH CSL POS Terminal No.");
            if (POSTerm."Location Code" <> '') and (POSTerm."Location Code" <> SalesLine."Location Code") then begin
                SalesLine."Location Code" := POSTerm."Location Code";
                SalesLine."Outbound Whse. Handling Time" := SalesHeader."Outbound Whse. Handling Time";
                SalesLine.UpdateDates();
            end;
        end;
    end;



}