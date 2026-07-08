codeunit 1070541 "CCS CASH POS Reg. Sales Trg."
{
    Access = Internal;

    var
        POSTerminal: Record "CCS CASH POS Terminal";
        Text001: Label 'Cash Sale %1-%2-%3', Comment = '%1=Value 1,%2=Value 2,%3=Value 3';
        Text002: Label 'Not allowed';
        Text003: Label 'If Voucher Card No. is mandatory, the maximum quantity to be sold must be 1.';

    internal procedure TestNoSeries(var pSalesHeader: Record "Sales Header")
    begin
        GetPOSTerm(pSalesHeader);
    end;

    internal procedure GetNoSeriesCode(var pSalesHeader: Record "Sales Header"): Code[20]
    begin
        if GetPOSTerm(pSalesHeader) then
            exit(POSTerminal."Receipt Nos.");
    end;

    internal procedure GetPostedNoSeriesCode(var pSalesHeader: Record "Sales Header"): Code[20]
    begin
        if GetPOSTerm(pSalesHeader) then
            exit(POSTerminal."Posted Receipt Nos.");
    end;

    internal procedure NoSeriesEQUALPosteNoSeries(var pSalesheader: Record "Sales Header"): Boolean
    begin
        if GetPOSTerm(pSalesheader) then
            exit(POSTerminal."Receipt Nos." = POSTerminal."Posted Receipt Nos.");
    end;

    internal procedure InitRecord(var pSalesHeader: Record "Sales Header")
    begin
        if not GetPOSTerm(pSalesHeader) then
            exit;

        pSalesHeader.Validate("Location Code", POSTerminal."Location Code");
        pSalesHeader.Validate("Posting Date", WorkDate());
        pSalesHeader."Posting Description" :=
          StrSubstNo(Text001, pSalesHeader."CCS CASH CSL Store No.", pSalesHeader."CCS CASH CSL POS Terminal No.", Format(pSalesHeader."CCS CASH CSL Transaction No."));
    end;

    internal procedure SyncSalesHeader(var pSalesHeader: Record "Sales Header"; UpdateAction: Option InsertUA,ModifyUA,DeleteUA)
    var
        TransH: Record "CCS CASH POS Transaction Hdr.";
    begin
        TransH.Get(pSalesHeader."CCS CASH CSL Store No.", pSalesHeader."CCS CASH CSL POS Terminal No.", pSalesHeader."CCS CASH CSL Transaction No.");
        if UpdateAction = UpdateAction::DeleteUA then begin
            TransH.Status := TransH.Status::Voided;
        end else begin
            if pSalesHeader."Bill-to Customer No." <> TransH."Customer No." then
                TransH."Customer No." := pSalesHeader."Bill-to Customer No.";
            TransH."Payment Discount %" := pSalesHeader."Payment Discount %";
            TransH."Payment Discount Amount" := 0;
        end;
        TransH.Modify(true);
    end;

    internal procedure "Sync. SalesLine"(var pSalesline: Record "Sales Line"; UpdateAction: Option InsertUA,ModifyUA,DeleteUA)
    var
        SalesHeader: Record "Sales Header";
        TransSales: Record "CCS CASH Trans. Sales Entry";
        Res: Record Resource;
    begin
        if UpdateAction = UpdateAction::DeleteUA then
            VoidSalesLine(pSalesline)
        else begin
            SalesHeader.Get(pSalesline."Document Type", pSalesline."Document No.");
            // >> CC01
            /*orig.
            IF "No." = '' THEN
              EXIT;
            */
            if pSalesline."No." = '' then
                VoidSalesLine(pSalesline);
            // << CC01
            if not TransSales.Get(pSalesline."CCS CASH CSL Store No.", pSalesline."CCS CASH CSL POS Terminal No.", pSalesline."CCS CASH CSL Transaction No.", pSalesline."Line No.") then begin
                TransSales.Init();
                TransSales."Store No." := pSalesline."CCS CASH CSL Store No.";
                TransSales."POS Terminal No." := pSalesline."CCS CASH CSL POS Terminal No.";
                TransSales."Transaction No." := pSalesline."CCS CASH CSL Transaction No.";
                TransSales."Entry No." := pSalesline."Line No.";
                TransSales."Creation Date" := WorkDate();
                TransSales."Creation Time" := Time;
                TransSales.Insert(true);
            end;
            if not (pSalesline.Type in [pSalesline.Type::" ", pSalesline.Type::"G/L Account", pSalesline.Type::Item, pSalesline.Type::Resource]) then
                pSalesline.FieldError(Type, Text002);

            // + POS0007
            if (pSalesline.Type = pSalesline.Type::Resource) and pSalesline."CCS CASH IsVoucher" then begin
                Res.Get(pSalesline."No.");
                Res.TestField("CCS CASH Voucher No. Series");
                if Res."CCS CASH Voucher C. No. Mand." then
                    if pSalesline.Quantity > 1 then
                        Error(Text003);
            end;
            TransSales.IsVoucher := pSalesline."CCS CASH IsVoucher";
            TransSales."Voucher Card No." := pSalesline."CCS CASH Voucher No.";
            TransSales."Voucher Serial No." := pSalesline."CCS CASH Voucher SerialNo.";
            // - POS0007

            TransSales.Type := pSalesline.Type;
            TransSales."No." := pSalesline."No.";
            TransSales."Variant Code" := pSalesline."Variant Code";
            TransSales.Description := pSalesline.Description;
            TransSales."Gen. Prod.Posting Group" := pSalesline."Gen. Prod. Posting Group";
            TransSales."VAT Prod. Posting Group" := pSalesline."VAT Prod. Posting Group";
            TransSales."VAT %" := pSalesline."VAT %";
            if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" then
                TransSales.Quantity := pSalesline.Quantity
            else
                TransSales.Quantity := -pSalesline.Quantity;

            if SalesHeader."Prices Including VAT" then begin
                TransSales."Unit Price incl. VAT" := pSalesline."Unit Price";
                TransSales."Unit Price" := pSalesline."Unit Price" / (100 + pSalesline."VAT %") * 100;
            end else begin
                TransSales."Unit Price" := pSalesline."Unit Price";
                TransSales."Unit Price incl. VAT" := pSalesline."Unit Price" * (100 + pSalesline."VAT %") / 100;
            end;
            if TransSales."Original Unit Price" = 0 then
                TransSales."Original Unit Price" := TransSales."Unit Price";
            TransSales."Price Changed" := TransSales."Unit Price" <> TransSales."Original Unit Price";

            if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" then begin
                //++POS0012
                if pSalesline.Amount = 0 then begin
                    if SalesHeader."Prices Including VAT" then begin
                        TransSales.Amount := pSalesline."Line Amount" / (100 + pSalesline."VAT %") * 100;
                        TransSales."Amount incl. VAT" := pSalesline."Line Amount";
                    end
                    else begin
                        TransSales.Amount := pSalesline."Line Amount";
                        TransSales."Amount incl. VAT" := pSalesline."Line Amount" * (100 + pSalesline."VAT %") / 100;
                    end;
                    TransSales."Line Discount Amt." := pSalesline."Line Discount Amount";
                    TransSales."Invoice Discount Amt." := -pSalesline."Inv. Discount Amount";
                end
                else begin
                    TransSales.Amount := pSalesline.Amount;
                    TransSales."Amount incl. VAT" := pSalesline."Amount Including VAT";
                    TransSales."Line Discount Amt." := pSalesline."Line Discount Amount";
                    TransSales."Invoice Discount Amt." := -pSalesline."Inv. Discount Amount";
                end;
            end else begin
                if pSalesline.Amount = 0 then begin
                    if SalesHeader."Prices Including VAT" then begin
                        TransSales.Amount := -pSalesline."Line Amount" / (100 + pSalesline."VAT %") * 100;
                        TransSales."Amount incl. VAT" := -pSalesline."Line Amount";
                    end
                    else begin
                        TransSales.Amount := -pSalesline."Line Amount";
                        TransSales."Amount incl. VAT" := -pSalesline."Line Amount" * (100 + pSalesline."VAT %") / 100;
                    end;
                    TransSales."Line Discount Amt." := -pSalesline."Line Discount Amount";
                    TransSales."Invoice Discount Amt." := pSalesline."Inv. Discount Amount";
                end
                else begin
                    TransSales.Amount := -pSalesline.Amount;
                    TransSales."Amount incl. VAT" := -pSalesline."Amount Including VAT";
                    TransSales."Line Discount Amt." := -pSalesline."Line Discount Amount";
                    TransSales."Invoice Discount Amt." := pSalesline."Inv. Discount Amount";
                end;
            end;

            //++POS00019
            TransSales.Amount := Round(TransSales.Amount, 0.01);
            TransSales."Amount incl. VAT" := Round(TransSales."Amount incl. VAT", 0.01);
            TransSales."Line Discount Amt." := Round(TransSales."Line Discount Amt.", 0.01);
            TransSales."Invoice Discount Amt." := Round(TransSales."Invoice Discount Amt.", 0.01);
            //--POS00019

            TransSales."VAT Amount" := TransSales."Amount incl. VAT" - TransSales.Amount;
            //--POS0012
            TransSales.Modify(true);
        end;

    end;

    internal procedure SyncSalesDocument(var pSalesHeader: Record "Sales Header"; var TransactionHeader: Record "CCS CASH POS Transaction Hdr."; RetailUser: Record "CCS CASH Retail User")
    var
        UpdAction: Option InsertUA,ModifyUA,DeleteUA;
        SalesPost: Codeunit "Sales-Post";
        tempSalesLine: Record "Sales Line" temporary;
    begin
        UpdAction := UpdAction::ModifyUA;

        TransactionHeader."Customer No." := pSalesHeader."Bill-to Customer No.";
        TransactionHeader."Payment Discount %" := pSalesHeader."Payment Discount %";
        TransactionHeader."Payment Discount Amount" := 0;
        TransactionHeader.Modify(true);
        Clear(SalesPost);
        SalesPost.GetSalesLines(pSalesHeader, tempSalesLine, 1, true);
        tempSalesLine.SetRange("Document Type", pSalesHeader."Document Type");
        tempSalesLine.SetRange("Document No.", pSalesHeader."No.");
        tempSalesLine.SetFilter(Quantity, '<>%1', 0);
        if tempSalesLine.FindSet() then
            repeat
                tempSalesLine."CCS CASH CSL Document" := true;
                tempSalesLine."CCS CASH CSL POS Terminal No." := RetailUser."POS Terminal No.";
                tempSalesLine."CCS CASH CSL Staff ID" := RetailUser."Staff ID";
                tempSalesLine."CCS CASH CSL Transaction No." := TransactionHeader."Transaction No.";
                tempSalesLine."CCS CASH CSL Store No." := RetailUser."Store No";

                "Sync. SalesLine"(tempSalesLine, UpdAction);
            until tempSalesLine.Next() = 0;
    end;

    internal procedure "Sync. SalesDocument"(var pSalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        UpdAction: Option InsertUA,ModifyUA,DeleteUA;
        TransSales: Record "CCS CASH Trans. Sales Entry";
    begin
        // + POS0015
        if not pSalesHeader."CCS CASH CSL Document" then
            exit;

        UpdAction := UpdAction::ModifyUA;

        SyncSalesHeader(pSalesHeader, UpdAction);
        SalesLine.SetRange("Document Type", pSalesHeader."Document Type");
        SalesLine.SetRange("Document No.", pSalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                //+POS0034
                SalesLine."CCS CASH CSL Document" := pSalesHeader."CCS CASH CSL Document";
                SalesLine."CCS CASH CSL POS Terminal No." := pSalesHeader."CCS CASH CSL POS Terminal No.";
                SalesLine."CCS CASH CSL Staff ID" := pSalesHeader."CCS CASH CSL Staff ID";
                SalesLine."CCS CASH CSL Transaction No." := pSalesHeader."CCS CASH CSL Transaction No.";
                SalesLine."CCS CASH CSL Store No." := pSalesHeader."CCS CASH CSL Store No.";
                //-POS0034
                "Sync. SalesLine"(SalesLine, UpdAction);
            until SalesLine.Next() = 0;
        // - POS0015

        // >> CC01
        TransSales.Reset();
        TransSales.SetRange("Store No.", pSalesHeader."CCS CASH CSL Store No.");
        TransSales.SetRange("POS Terminal No.", pSalesHeader."CCS CASH CSL POS Terminal No.");
        TransSales.SetRange("Transaction No.", pSalesHeader."CCS CASH CSL Transaction No.");
        if TransSales.FindSet() then
            repeat
                SalesLine.Reset();
                SalesLine.SetRange("Document Type", pSalesHeader."Document Type");
                SalesLine.SetRange("Document No.", pSalesHeader."No.");
                SalesLine.SetRange("Line No.", TransSales."Entry No.");
                if SalesLine.FindFirst() then begin
                    if SalesLine."No." = '' then
                        TransSales.Delete();
                end else begin
                    TransSales.Delete();
                end;
            until TransSales.Next() = 0;
        // << CC01
    end;

    local procedure VoidSalesLine(pSalesLine: Record "Sales Line")
    var
        TransSales: Record "CCS CASH Trans. Sales Entry";
        TransSalesVoid: Record "CCS CASH Trans Sales E. Voided";
        NextEntryNo: Integer;
    begin
        if not TransSales.Get(pSalesLine."CCS CASH CSL Store No.", pSalesLine."CCS CASH CSL POS Terminal No.", pSalesLine."CCS CASH CSL Transaction No.", pSalesLine."Line No.") then
            exit;
        TransSalesVoid.SetRange("Store No.", pSalesLine."CCS CASH CSL Store No.");
        TransSalesVoid.SetRange("POS Terminal No.", pSalesLine."CCS CASH CSL POS Terminal No.");
        TransSalesVoid.SetRange("Transaction No.", pSalesLine."CCS CASH CSL Transaction No.");
        if TransSalesVoid.FindLast() then
            NextEntryNo := TransSalesVoid."Line No.";
        NextEntryNo += 1;
        TransSalesVoid.TransferFields(TransSales);
        TransSalesVoid."Line No." := NextEntryNo;
        TransSalesVoid.Insert(true);
        TransSales.Delete(true);
    end;

    local procedure GetPOSTerm(pSalesHead: Record "Sales Header"): Boolean
    var
        Store: Record "CCS CASH Store";
    begin
        if not pSalesHead."CCS CASH CSL Document" then
            exit(false);
        POSTerminal.Get(pSalesHead."CCS CASH CSL Store No.", pSalesHead."CCS CASH CSL POS Terminal No.");
        Store.Get(pSalesHead."CCS CASH CSL Store No.");

        if POSTerminal."Posted Receipt Nos." = '' then
            POSTerminal."Posted Receipt Nos." := Store."Posted Receipt Nos.";
        if POSTerminal."Receipt Nos." = '' then
            POSTerminal."Receipt Nos." := Store."Receipt Nos.";

        POSTerminal.TestField("Posted Receipt Nos.");
        POSTerminal.TestField("Receipt Nos.");
        exit(true);
    end;
}