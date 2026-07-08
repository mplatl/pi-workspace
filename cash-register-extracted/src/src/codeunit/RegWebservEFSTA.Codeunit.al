codeunit 1070546 "CCS CASH Reg. Webserv. EFSTA"
{
    TableNo = "CCS CASH POS Transaction Hdr.";
    Access = Internal;

    trigger OnRun()
    var
        TransHeader: Record "CCS CASH POS Transaction Hdr.";
    begin
        if TransHeader."Transaction Type" in [TransHeader."Transaction Type"::Logoff]
        then begin
            SendWebServiceEFSTA(true, Enum::"CCS CASH Sign. Request Type"::GetSignature, TransHeader);
        end;
    end;

    var
        BodyContentInputStreamRead: InStream;
        BodyContentJsonRead: JsonObject;
        EFSTALog: Record "CCS CASH Signa. Srv. Req. Log";
        SimpleReceipt: Boolean;
        EFSTASetup: Record "CCS CASH Signa. Service Setup";
        GlobLateSignature: Boolean;
        NFTrans: Boolean;
        Text002: Label 'Signature Service not available';
        Text003: Label 'Process is cancelled';
        Text004: Label 'Signature Service is interrupted since 48h';
        Text005: Label 'Signature interrupted.\Remaining time until postings will be cancelled: %1 Hours %2 Minutes', Comment = '%1=Hours,%2=Minutes';
        Text006: Label 'Signature interrupted since 48h.\Transactions will not be posted';
        Text009: Label 'Signed but not available';

    internal procedure SendTransToEFR(TransHeader: Record "CCS CASH POS Transaction Hdr.")
    begin
        if TransHeader."Receipt No." <> ''
        then begin
            SendWebServiceEFSTA(true, Enum::"CCS CASH Sign. Request Type"::GetSignature, TransHeader);
        end;
    end;

    internal procedure InitEFSTALog(RequestType: Enum "CCS CASH Sign. Request Type"; LocTransHeader: Record "CCS CASH POS Transaction Hdr.")
    begin
        EFSTALog.Init();
        EFSTALog."Store No." := LocTransHeader."Store No.";
        EFSTALog."POS Terminal No." := LocTransHeader."POS Terminal No.";
        EFSTALog."Transaction No." := LocTransHeader."Transaction No.";
        EFSTALog."Request Type" := RequestType;
        EFSTALog."Request Timestamp" := CurrentDateTime;
    end;

    internal procedure SendWebServiceEFSTA(ShowErrors: Boolean; RequestType: ENUM "CCS CASH Sign. Request Type"; TransHeader: Record "CCS CASH POS Transaction Hdr.")
    begin
        // Parameter for Value RequestType
        // 0 = GetSignature
        SimpleReceipt := false;

        GetEFSTASetup(TransHeader, true);

        InitEFSTALog(RequestType, TransHeader);

        SendRequestToEFSTAService(ShowErrors, RequestType, TransHeader);

        WriteResponsetoLog(RequestType);


        // ++ EFSTA2.05
        if EFSTASetup."QR Picture Save Option" = EFSTASetup."QR Picture Save Option"::"Save Picture in Log" then
            // -- EFSTA2.05
            if not EFSTALog."Response Error" then
                SendRequestToEFSTAService(ShowErrors, Enum::"CCS CASH Sign. Request Type"::GetQRCode, TransHeader);

        InsertEFSTAServiceLog(RequestType);
    end;

    local procedure SendRequestToEFSTAService(ShowErrors: Boolean; RequestType: Enum "CCS CASH Sign. Request Type"; LocTransHeader: Record "CCS CASH POS Transaction Hdr.")
    var
        WebServiceRequestMgt: Codeunit "CCS CASH Reg. Req.Mgt. EFSTA";
        ResponseInStream: InStream;
        InStream: InStream;
        ResponseOutStream: OutStream;
        Image: Codeunit Image;
    begin
        case RequestType of
            RequestType::GetSignature:
                begin
                    PrepareRequestBody(RequestType, LocTransHeader);
                    EFSTALog.Request.CreateInStream(InStream);
                end;
            RequestType::GetQRCode:
                begin
                    Clear(InStream);
                end;
            RequestType::State:
                begin
                    Clear(InStream);
                end;
        end;

        case RequestType of
            RequestType::GetSignature:
                WebServiceRequestMgt.SetGlobals(InStream, EFSTASetup."WebService Main Path",
                  '', '', 'POST');

            RequestType::GetQRCode:
                begin
                    WebServiceRequestMgt.SetGlobals(InStream, EFSTASetup."WebService QR Path" + EFSTALog."QR Code",
                      '', '', 'GET');
                end;

            RequestType::State:
                begin
                    WebServiceRequestMgt.SetGlobals(InStream, EFSTASetup."WebService State Path",
                      '', '', 'GET');
                end;
        end;

        WebServiceRequestMgt.SetNoBodyContentNeeded(false);
        WebServiceRequestMgt.DisableHttpsCheck();
        if EFSTASetup."Web Service Timeout ms" = 0 then
            EFSTASetup."Web Service Timeout ms" := 30000;
        WebServiceRequestMgt.SetTimeout(EFSTASetup."Web Service Timeout ms");

        if RequestType in [RequestType::GetQRCode, RequestType::State] then
            WebServiceRequestMgt.SetNoBodyContentNeeded(true);

        if WebServiceRequestMgt.RUNFunction() then begin
            case RequestType of
                RequestType::GetSignature:
                    begin
                        WebServiceRequestMgt.GetResponseContent(ResponseInStream);

                        EFSTALog.Response.CreateOutStream(ResponseOutStream);
                        CopyStream(ResponseOutStream, ResponseInStream);
                    end;
                RequestType::GetQRCode:
                    begin
                        WebServiceRequestMgt.GetResponseContent(ResponseInStream);
                        EFSTALog."QR Picture".CreateOutStream(ResponseOutStream);
                        //COPYSTREAM(ResponseOutStream,ResponseInStream);
                        Image.FromStream(ResponseInStream);
                        Image.SetFormat(Enum::"Image Format"::Bmp);
                        Image.Save(ResponseOutStream);

                        ResizeImage();
                    end;
                RequestType::State:
                    begin
                        WebServiceRequestMgt.GetResponseContent(ResponseInStream);
                        EFSTALog.Response.CreateOutStream(ResponseOutStream);
                        CopyStream(ResponseOutStream, ResponseInStream);
                    end;
            end;
        end else begin
            EFSTALog."Response Error" := true;
            EFSTALog."Response Text" := CopyStr(GetLastErrorText, 1, 250);
            EFSTALog."User Message" := Text002;
            if ShowErrors then begin
                //Message(Text002);
            end;
        end;
    end;

    local procedure PrepareRequestBody(RequestType: Enum "CCS CASH Sign. Request Type"; LocTransHeader: Record "CCS CASH POS Transaction Hdr.")
    var
        BodyContentInputStream: InStream;
        BodyContentOutputStream: OutStream;
        BodyContentJsonTra: JsonObject;
        BodyContentJsonESR: JsonObject;
        BodyContentJsonESRContent: JsonObject;


        BodyContentJsonPOSAArray: JsonArray;
        BodyContentJsonPOSAContent: JsonObject;
        BodyContentJsonPayAArray: JsonArray;
        BodyContentJsonPayAContent: JsonObject;
        BodyContentJsonTaxAArray: JsonArray;
        BodyContentJsonTaxAContent: JsonObject;
        BodyContentJsonCtmContent: JsonObject;

        SalesAmountVAT: array[5] of Decimal;
        VATPerc: array[5] of Decimal;
        VATAmount: array[5] of Decimal;
        VATCode: array[5] of Code[10];
        SalesEntry: Record "CCS CASH Trans. Sales Entry";
        IncExpEntry: Record "CCS CASH Trans. Expense Entry";
        GLAcc: Record "G/L Account";
        VATPostSetup: Record "VAT Posting Setup";
        Currency: Record Currency;
        i: Integer;
        j: Integer;
        IncExpAccount: Record "CCS CASH Store Tender Type";
        TransPayEntry: Record "CCS CASH Trans. Payment Entry";
        TenderType: Record "CCS CASH Store Tender Type";
        CompanyInformation: Record "Company Information";
        CCSCASHStaff: Record "CCS CASH Staff";
        CCSCASHStore: Record "CCS CASH Store";
        Customer: Record Customer;
        SumSalesAmountVAT: Decimal;
        PaymentDiscountAmount: Decimal;
        CalcDiscountAmount: Decimal;
    begin
        Clear(NFTrans);
        EFSTALog.Request.CreateInStream(BodyContentInputStream);

        case RequestType of
            RequestType::GetSignature:
                begin
                    // ++ Section for ESR Trans Header
                    if LocTransHeader."Staff ID" <> '' then begin
                        BodyContentJsonESRContent.Add('Opr', LocTransHeader."Staff ID");
                        CCSCASHStaff.SetLoadFields(Name, "Name on Receipt");
                        if CCSCASHStaff.Get(LocTransHeader."Staff ID") then
                            if CCSCASHStaff."Name on Receipt" <> '' then
                                BodyContentJsonESRContent.Add('OprN', CCSCASHStaff."Name on Receipt")
                            else
                                BodyContentJsonESRContent.Add('OprN', CCSCASHStaff.Name);
                    end;
                    CompanyInformation.SetLoadFields("VAT Registration No.");
                    CompanyInformation.Get();
                    BodyContentJsonESRContent.Add('TaxId', CompanyInformation."VAT Registration No.");
                    //IF LocTransHeader."Gross Amount" <> 0 THEN
                    //    BodyContentJsonESRContent.Add('T', FORMAT(LocTransHeader."Gross Amount"*-1,0,'<Precision,2:2><Standard Format,2>'))
                    LocTransHeader.CalcFields("Payment Amount");
                    if LocTransHeader."Payment Amount" <> 0 then
                        BodyContentJsonESRContent.Add('T', Format(LocTransHeader."Payment Amount", 0, '<Precision,2:2><Standard Format,2>'));
                    BodyContentJsonESRContent.Add('TN', Format(LocTransHeader."Receipt No."));
                    BodyContentJsonESRContent.Add('TT', LocTransHeader."Store No." + '/' + LocTransHeader."POS Terminal No.");
                    if GlobLateSignature then begin
                        BodyContentJsonESRContent.Add('D', Format(LocTransHeader."Creation Date", 0, '<Year4>-<Month,2>-<Day,2>') + 'T' +
                              Format(LocTransHeader."Creation Time", 0, '<Hours24,2>:<Minutes,2>:<Seconds,2>'));
                    end else begin
                        BodyContentJsonESRContent.Add('D', Format(CurrentDateTime, 0, '<Year4>-<Month,2>-<Day,2>') + 'T' +
                              Format(CurrentDateTime, 0, '<Hours24,2>:<Minutes,2>:<Seconds,2>'));
                    end;

                    IncExpEntry.SetRange("Store No.", LocTransHeader."Store No.");
                    IncExpEntry.SetRange("POS Terminal No.", LocTransHeader."POS Terminal No.");
                    IncExpEntry.SetRange("Transaction No.", LocTransHeader."Transaction No.");

                    if LocTransHeader."No. of Item Lines" = 0 then begin
                        IncExpEntry.SetRange(Type, IncExpEntry.Type::Expense);
                        if IncExpEntry.FindFirst() then begin
                            BodyContentJsonESRContent.Add('NFS', 'AUSZAHLUNG');
                            NFTrans := true;
                        end;
                    end;
                    IncExpEntry.Reset();

                    case LocTransHeader."Transaction Type" of
                        LocTransHeader."Transaction Type"::"Tender Decl.",
                        LocTransHeader."Transaction Type"::EndDay:
                            begin
                                BodyContentJsonESRContent.Add('NFS', 'GELDZÄHLUNG');
                                NFTrans := true;
                            end;
                        LocTransHeader."Transaction Type"::"Float Entry",
                        LocTransHeader."Transaction Type"::Startday:
                            begin
                                BodyContentJsonESRContent.Add('NFS', 'GELDEINLAGE');
                                NFTrans := true;
                            end;

                        LocTransHeader."Transaction Type"::"Remove Tender":
                            begin
                                BodyContentJsonESRContent.Add('NFS', 'GELDENTNAHME');
                                NFTrans := true;
                            end;
                        LocTransHeader."Transaction Type"::"Open Drawer":
                            begin
                                BodyContentJsonESRContent.Add('NFS', 'KASSENLADE');
                                NFTrans := true;
                            end;
                    end;

                    if GlobLateSignature then
                        BodyContentJsonESRContent.Add('NFS', 'NACHSIGNIERUNG');

                    //IF LocTransHeader."Entry Status" = LocTransHeader."Entry Status"::Training THEN
                    //  XMLDOMMgt.AddAttribute(EnvelopeXmlNode,'NFS', 'TRAINING');

                    //IF LocTransHeader."Entry Status" = LocTransHeader."Entry Status"::Voided THEN
                    //  XMLDOMMgt.AddAttribute(EnvelopeXmlNode,'NFS', 'TRAINING');
                    // -- Section for ESR Trans Header

                    // ++ Section for Sum Taxes
                    if LocTransHeader."Customer No." <> '' then begin
                        CCSCASHStore.SetLoadFields("Default Customer");
                        CCSCASHStore.Get(LocTransHeader."Store No.");
                        if CCSCASHStore."Default Customer" <> LocTransHeader."Customer No." then begin
                            Customer.SetLoadFields(Name, "Name 2", Address, "Address 2", "Post Code", City, "Country/Region Code", "VAT Registration No.", "No.", "E-Mail");
                            Customer.get(LocTransHeader."Customer No.");
                            Clear(BodyContentJsonCtmContent);
                            BodyContentJsonCtmContent.Add('Nam', Format(Customer.Name));
                            BodyContentJsonCtmContent.Add('Nam2', Format(Customer."Name 2"));
                            BodyContentJsonCtmContent.Add('Adr', Format(Customer.Address));
                            BodyContentJsonCtmContent.Add('Adr2', Format(Customer."Address 2"));
                            BodyContentJsonCtmContent.Add('Zip', Format(Customer."Post Code"));
                            BodyContentJsonCtmContent.Add('City', Format(Customer.City));
                            BodyContentJsonCtmContent.Add('Ctry', Format(Customer."Country/Region Code"));
                            BodyContentJsonCtmContent.Add('TaxId', Format(Customer."VAT Registration No."));
                            BodyContentJsonCtmContent.Add('CN', Format(Customer."No."));
                            BodyContentJsonCtmContent.Add('Mail', Format(Customer."E-Mail"));
                            //
                            BodyContentJsonESRContent.Add('Ctm', BodyContentJsonCtmContent);
                        end;
                    end;

                    // ++ Section for Sales Entries
                    SalesEntry.SetRange("Store No.", LocTransHeader."Store No.");
                    SalesEntry.SetRange("POS Terminal No.", LocTransHeader."POS Terminal No.");
                    SalesEntry.SetRange("Transaction No.", LocTransHeader."Transaction No.");

                    if SalesEntry.FindSet() then begin
                        repeat
                            Clear(BodyContentJsonPOSAContent);
                            if not SimpleReceipt then begin
                                BodyContentJsonPOSAContent.Add('_', 'Pos');
                                BodyContentJsonPOSAContent.Add('PN', Format(SalesEntry."Entry No."));
                                BodyContentJsonPOSAContent.Add('IN', DelChr(SalesEntry."No.", '=', '"<>&'));
                                BodyContentJsonPOSAContent.Add('Dsc', DelChr(SalesEntry.Description, '=', '"<>&'));
                                BodyContentJsonPOSAContent.Add('TaxG', Format(SalesEntry."VAT %") + '%');
                                if LocTransHeader."Creation Date" <= SalesEntry."Pmt. Discount Date" then
                                    BodyContentJsonPOSAContent.Add('Amt', Format((-SalesEntry."Amount incl. VAT") + SalesEntry."Remaining Pmt. Disc. Possible",
                        0, '<Precision,2:2><Standard Format,2>'))
                                else
                                    BodyContentJsonPOSAContent.Add('Amt', Format(-SalesEntry."Amount incl. VAT", 0, '<Precision,2:2><Standard Format,2>'));
                                BodyContentJsonPOSAContent.Add('Qty', Format(-SalesEntry.Quantity, 0, '<Precision,2:2><Standard Format,2>'));
                                BodyContentJsonPOSAArray.Add(BodyContentJsonPOSAContent);
                            end;
                            // ++ VAT Part
                            i := 0;
                            j := 0;
                            repeat
                                i := i + 1;
                                if j = 0 then
                                    if VATCode[i] = '' then
                                        j := i;
                            until (VATCode[i] = Format(SalesEntry."VAT %")) or (i >= 5);
                            if VATCode[i] <> Format(SalesEntry."VAT %") then begin
                                i := j;
                                VATPerc[i] := SalesEntry."VAT %";
                                VATCode[i] := Format(SalesEntry."VAT %");
                            end;
                            VATAmount[i] := VATAmount[i] + SalesEntry."VAT Amount";
                            if LocTransHeader."Creation Date" <= SalesEntry."Pmt. Discount Date" then begin
                                SalesAmountVAT[i] := SalesAmountVAT[i] + SalesEntry."Amount incl. VAT" - SalesEntry."Remaining Pmt. Disc. Possible";
                                SumSalesAmountVAT += SalesEntry."Amount incl. VAT" - SalesEntry."Remaining Pmt. Disc. Possible";
                            end else begin
                                SalesAmountVAT[i] := SalesAmountVAT[i] + SalesEntry."Amount incl. VAT";
                                SumSalesAmountVAT += SalesEntry."Amount incl. VAT";
                            end;
                        // -- VAT Part
                        until SalesEntry.Next() = 0;
                    end;
                    // -- Section for Sales Entries

                    // ++ Section for Inc. Exp. Entries
                    IncExpEntry.SetRange("Store No.", LocTransHeader."Store No.");
                    IncExpEntry.SetRange("POS Terminal No.", LocTransHeader."POS Terminal No.");
                    IncExpEntry.SetRange("Transaction No.", LocTransHeader."Transaction No.");

                    if IncExpEntry.FindSet() then begin
                        repeat
                            GLAcc.Get(IncExpEntry."Account No.");
                            if not VATPostSetup.Get(GLAcc."VAT Bus. Posting Group", GLAcc."VAT Prod. Posting Group") then
                                VATPostSetup.Init();

                            if not SimpleReceipt then begin
                                Clear(BodyContentJsonPOSAContent);
                                BodyContentJsonPOSAContent.Add('_', 'Pos');
                                BodyContentJsonPOSAContent.Add('PN', Format(IncExpEntry."Line No."));
                                BodyContentJsonPOSAContent.Add('IN', DelChr(IncExpEntry."No.", '=', '"<>&'));
                                IncExpAccount.Get(IncExpEntry."Store No.", IncExpEntry."No.");
                                BodyContentJsonPOSAContent.Add('Dsc', DelChr(IncExpAccount.Description, '=', '"<>&'));
                                BodyContentJsonPOSAContent.Add('TaxG', Format(VATPostSetup."VAT %") + '%');
                                BodyContentJsonPOSAContent.Add('Amt', Format(-IncExpEntry.Amount, 0, '<Precision,2:2><Standard Format,2>'));
                                if IncExpEntry.Amount < 0 then
                                    BodyContentJsonPOSAContent.Add('Qty', Format(1, 0, '<Precision,2:2><Standard Format,2>'))
                                else
                                    BodyContentJsonPOSAContent.Add('Qty', Format(-1, 0, '<Precision,2:2><Standard Format,2>'));
                                BodyContentJsonPOSAArray.Add(BodyContentJsonPOSAContent);
                            end;
                            // ++ VAT Part

                            i := 0;
                            j := 0;
                            repeat
                                i := i + 1;
                                if j = 0 then
                                    if VATCode[i] = '' then
                                        j := i;
                            until (VATCode[i] = Format(VATPostSetup."VAT %")) or (i >= 5);
                            if VATCode[i] <> Format(VATPostSetup."VAT %") then begin
                                i := j;
                                VATPerc[i] := VATPostSetup."VAT %";
                                VATCode[i] := Format(VATPostSetup."VAT %");
                            end;
                            Currency.InitRoundingPrecision();
                            VATAmount[i] := VATAmount[i] +
                              Round(IncExpEntry.Amount * VATPostSetup."VAT %" / (100 + VATPostSetup."VAT %"),
                              Currency."Amount Rounding Precision", Currency.VATRoundingDirection());
                            SalesAmountVAT[i] := SalesAmountVAT[i] + IncExpEntry.Amount;
                            SumSalesAmountVAT += IncExpEntry.Amount;
                        // -- VAT Part
                        until IncExpEntry.Next() = 0;
                    end;
                    // -- Section for Inc. Exp. Entries

                    if (Abs(SumSalesAmountVAT) <> Abs(LocTransHeader."Payment Amount")) then begin
                        PaymentDiscountAmount := LocTransHeader."Payment Amount" - (SumSalesAmountVAT * -1);
                        Clear(BodyContentJsonPOSAContent);
                        if not SimpleReceipt then begin
                            BodyContentJsonPOSAContent.Add('_', 'Mod');
                            BodyContentJsonPOSAContent.Add('PN', '*');
                            BodyContentJsonPOSAContent.Add('Dsc', 'Payment Discount');
                            BodyContentJsonPOSAContent.Add('Amt', Format((LocTransHeader."Payment Amount" - (SumSalesAmountVAT * -1)), 0, '<Precision,2:2><Standard Format,2>'));
                            BodyContentJsonPOSAArray.Add(BodyContentJsonPOSAContent);
                        end;
                    end;


                    if not SimpleReceipt then begin
                        if BodyContentJsonPOSAArray.Count > 0 then
                            BodyContentJsonESRContent.Add('PosA', BodyContentJsonPOSAArray);
                    end;

                    // ++ Section for Payment Entries
                    TransPayEntry.SetRange("Store No.", LocTransHeader."Store No.");
                    TransPayEntry.SetRange("POS Terminal No.", LocTransHeader."POS Terminal No.");
                    TransPayEntry.SetRange("Transaction No.", LocTransHeader."Transaction No.");

                    if TransPayEntry.FindSet() then begin
                        repeat
                            if not SimpleReceipt then begin
                                Clear(BodyContentJsonPayAContent);
                                BodyContentJsonPayAContent.Add('_', 'Pay');
                                TenderType.Get(LocTransHeader."Store No.", TransPayEntry."Tender Type");
                                BodyContentJsonPayAContent.Add('Dsc', DelChr(TenderType.Description, '=', '"<>&'));
                                BodyContentJsonPayAContent.Add('Amt', Format(TransPayEntry.Amount, 0, '<Precision,2:2><Standard Format,2>'));
                                IncExpAccount.Get(TransPayEntry."Store No.", TransPayEntry."Tender Type");
                                case IncExpAccount.TenderFunction of
                                    IncExpAccount.TenderFunction::Card:
                                        BodyContentJsonPayAContent.Add('PayG', 'creditcard');
                                    IncExpAccount.TenderFunction::Normal:
                                        if TenderType.Cash then
                                            BodyContentJsonPayAContent.Add('PayG', 'cash')
                                        else
                                            BodyContentJsonPayAContent.Add('PayG', 'creditcard');
                                    IncExpAccount.TenderFunction::Voucher:
                                        BodyContentJsonPayAContent.Add('PayG', 'voucher');
                                    else
                                        BodyContentJsonPayAContent.Add('PayG', 'cash');
                                end;
                                BodyContentJsonPayAArray.Add(BodyContentJsonPayAContent);
                            end;
                        until TransPayEntry.Next() = 0;
                        if not SimpleReceipt then begin
                            BodyContentJsonESRContent.Add('PayA', BodyContentJsonPayAArray)
                        end;
                    end;
                    // ++ Section for Payment Entries

                    if (PaymentDiscountAmount <> 0) then begin
                        for i := 1 to 5 do begin
                            if VATCode[i] <> '' then begin
                                CalcDiscountAmount := SalesAmountVAT[i] / 100 * LocTransHeader."Payment Discount %";
                                CalcDiscountAmount := Round(CalcDiscountAmount, 0.01);
                                SalesAmountVAT[i] -= CalcDiscountAmount;
                                if VATPerc[i] <> 0 then begin
                                    Currency.InitRoundingPrecision();
                                    VATAmount[i] := ROUND(SalesAmountVAT[i] * VATPerc[i] / (100 + VATPerc[i]),
                                      Currency."Amount Rounding Precision", Currency.VATRoundingDirection());
                                end;
                                PaymentDiscountAmount -= CalcDiscountAmount;
                            end;
                        end;
                        if (PaymentDiscountAmount <> 0) then begin
                            SalesAmountVAT[1] -= PaymentDiscountAmount;
                            if VATPerc[1] <> 0 then begin
                                Currency.InitRoundingPrecision();
                                VATAmount[1] := ROUND(SalesAmountVAT[1] * VATPerc[1] / (100 + VATPerc[1]),
                                    Currency."Amount Rounding Precision", Currency.VATRoundingDirection());
                            end;
                        end;
                    end;

                    // ++ Section for Sum Taxes
                    for i := 1 to 5 do begin
                        if VATCode[i] <> '' then begin
                            Clear(BodyContentJsonTaxAContent);
                            BodyContentJsonTaxAContent.Add('_', 'Tax');
                            BodyContentJsonTaxAContent.Add('Amt', Format(-SalesAmountVAT[i], 0, '<Precision,2:2><Standard Format,2>'));
                            BodyContentJsonTaxAContent.Add('TAmt', Format(-VATAmount[i], 0, '<Precision,2:2><Standard Format,2>'));
                            BodyContentJsonTaxAContent.Add('Net', Format(-SalesAmountVAT[i] + VATAmount[i], 0, '<Precision,2:2><Standard Format,2>'));
                            BodyContentJsonTaxAContent.Add('Prc', Format(VATPerc[i]));
                            BodyContentJsonTaxAContent.Add('TaxG', Format(VATPerc[i]) + '%');
                            BodyContentJsonTaxAArray.Add(BodyContentJsonTaxAContent);
                        end;
                    end;
                    if BodyContentJsonTaxAArray.Count > 0 then
                        BodyContentJsonESRContent.Add('TaxA', BodyContentJsonTaxAArray)

                    // -- Section for Sum Taxes
                end;
        end;
        BodyContentJsonESR.Add('ESR', BodyContentJsonESRContent);
        BodyContentJsonTra.Add('Tra', BodyContentJsonESR);

        Clear(EFSTALog.Request);
        EFSTALog.Request.CreateOutStream(BodyContentOutputStream);
        BodyContentJsonTra.WriteTo(BodyContentOutputStream);
    end;

    internal procedure GetWebServiceState(pStore: Code[20]; pTerminal: Code[20]; LocTransHeader: Record "CCS CASH POS Transaction Hdr."; PrePostCheck: Boolean; ErrorText: Text): Boolean
    var
        TempLocTransHeader: Record "CCS CASH POS Transaction Hdr." temporary;
        LocSCValue: Text[250];
    begin
        if LocTransHeader."Store No." = '' then begin
            TempLocTransHeader.Init();
            TempLocTransHeader."Store No." := pStore;
            TempLocTransHeader."POS Terminal No." := pTerminal;
        end else
            TempLocTransHeader := LocTransHeader;
        GetEFSTASetup(TempLocTransHeader, true);
        InitEFSTALog(Enum::"CCS CASH Sign. Request Type"::State, TempLocTransHeader);

        SendRequestToEFSTAService(true, Enum::"CCS CASH Sign. Request Type"::State, TempLocTransHeader);

        WriteResponsetoLog(Enum::"CCS CASH Sign. Request Type"::State);

        if LocTransHeader."Transaction No." <> 0 then begin
            InsertEFSTAServiceLog(Enum::"CCS CASH Sign. Request Type"::GetSignature);
        end;


        // ++ EFSTA2.01
        if EFSTALog."Response Error" then begin
            if EFSTALog."User Message" <> '' then
                ErrorText := EFSTALog."User Message"
            else
                ErrorText := EFSTALog."Response Text";

            if PrePostCheck then begin
                if ErrorText <> '' then
                    ErrorText := ErrorText + '\';
                ErrorText := ErrorText + Text003;
            end;
        end;

        LocSCValue := CopyStr(GetValueFromResponse('Recorder'), 1, MaxStrLen(LocSCValue));
        WriteStateToTerminal(LocSCValue);

        exit(EFSTALog."Response Error");
        // -- EFSTA2.01
    end;

    internal procedure WriteStateToTerminal(SCValue: Text[250])
    begin
        // ++ EFSTA2.01
        if SCValue <> 'online' then
            exit;

        if EFSTASetup."Signature Failure Timestamp" <> 0DT then begin
            EFSTASetup."Signature Failure Timestamp" := 0DT;
            EFSTASetup.Modify();
        end;
        // -- EFSTA2.01
    end;

    procedure "<<HelpFunctions>>"()
    begin
    end;



    internal procedure WriteResponsetoLog(RequestType: Enum "CCS CASH Sign. Request Type")
    var
        RespFieldValue: Text;
        JsonTok: JsonToken;
    begin
        InitReadResponse();

        case RequestType of
            RequestType::GetSignature:
                begin
                    EFSTALog."Request Type" := EFSTALog."Request Type"::GetSignature;
                    BodyContentJsonRead.Get('TraC', JsonTok);
                    BodyContentJsonRead := JsonTok.AsObject();
                    ReadResponseAttributeName('Result', 'RC', RespFieldValue);
                    if RespFieldValue in ['NO', 'BAD'] then begin
                        EFSTALog."Response Error" := true;
                        EFSTALog."Response Text" := CopyStr(RespFieldValue, 1, MaxStrLen(EFSTALog."Response Text"));
                    end;
                    ReadResponseAttributeName('Fis', 'Link', RespFieldValue);
                    if RespFieldValue <> '' then begin
                        EFSTALog."Response Text" := CopyStr(RespFieldValue, 1, MaxStrLen(EFSTALog."Response Text"));
                    end;
                    ReadResponseAttributeName('Fis', 'Code', RespFieldValue);
                    if RespFieldValue <> '' then begin
                        EFSTALog."QR Code" := CopyStr(RespFieldValue, 1, MaxStrLen(EFSTALog."QR Code"));
                        //WriteBase64Gif(RespFieldValue);
                    end;

                    //New Field ErrorCode, User Message and Tag Label
                    ReadResponseAttributeName('Result', 'ErrorCode', RespFieldValue);
                    if RespFieldValue <> '' then begin
                        EFSTALog."Error Code" := CopyStr(RespFieldValue, 1, MaxStrLen(EFSTALog."Error Code"));
                    end;
                    ReadResponseAttributeName('Result', 'UserMessage', RespFieldValue);
                    if RespFieldValue <> '' then begin
                        EFSTALog."User Message" := CopyStr(RespFieldValue, 1, MaxStrLen(EFSTALog."User Message"));
                    end;
                    ReadResponseAttributeName('Fis', 'Tag', 'Name', RespFieldValue);
                    if UpperCase(RespFieldValue) = 'INFO' then begin
                        ReadResponseAttributeName('Fis', 'Tag', 'Value', RespFieldValue);
                        if RespFieldValue <> '' then begin
                            EFSTALog."Tag Label" := CopyStr(RespFieldValue, 1, MaxStrLen(EFSTALog."Tag Label"));
                        end;
                    end;
                end;
            RequestType::State:
                begin
                    ReadResponseFieldName('ErrorCode', RespFieldValue);
                    if RespFieldValue <> '' then begin
                        EFSTALog."Error Code" := CopyStr(RespFieldValue, 1, MaxStrLen(EFSTALog."Error Code"));
                    end;
                    ReadResponseFieldName('UserMessage', RespFieldValue);
                    if RespFieldValue <> '' then begin
                        EFSTALog."User Message" := CopyStr(RespFieldValue, 1, MaxStrLen(EFSTALog."User Message"));
                    end;
                end;
        end;


        // ++ EFSTA2.01
        if RequestType = RequestType::GetSignature then begin
            if EFSTALog."Error Code" in ['#SIGNDEV_BROKEN', '#SIGNDEV_MISS'] then begin
                if EFSTASetup."Signature Failure Timestamp" = 0DT then begin
                    EFSTASetup."Signature Failure Timestamp" := CurrentDateTime;
                    EFSTASetup.Modify();
                end;
            end
            // ++ EFSTA2.02
            else begin
                if not EFSTALog."Response Error" and (EFSTALog."Error Code" = '') then begin
                    if EFSTASetup."Signature Failure Timestamp" <> 0DT then begin
                        EFSTASetup."Signature Failure Timestamp" := 0DT;
                        EFSTASetup.Modify();
                    end;
                end;
            end;
            // -- EFSTA2.02
        end;
        // -- EFSTA2.01
    end;

    internal procedure InsertEFSTAServiceLog(RequestType: Enum "CCS CASH Sign. Request Type")
    begin
        EFSTALog.Insert(true);
    end;

    internal procedure ResizeImage()
    var
        Bitmap1: Codeunit "Image";
        LocInstream: InStream;
        LocOutStream: OutStream;
        IntWidth: Integer;
        IntHeight: Integer;
    begin
        //Bitmap1 := Bitmap1.Bitmap('C:\Pepper\QRCode.bmp');
        EFSTALog."QR Picture".CreateInStream(LocInstream);
        Bitmap1.FromStream(LocInstream);

        IntWidth := Round(Bitmap1.GetWidth() / EFSTASetup."Picture Reduction Factor", 1);
        IntHeight := Round(Bitmap1.GetHeight() / EFSTASetup."Picture Reduction Factor", 1);

        Bitmap1.Resize(IntWidth, IntHeight);
        Bitmap1.SetFormat(Enum::"Image Format"::Bmp);

        EFSTALog."QR Picture Resized".CreateOutStream(LocOutStream);
        Bitmap1.Save(LocOutStream);

        if EFSTASetup."Picture Enlarge Factor" > 1 then begin
            EFSTALog."QR Picture Resized".CreateInStream(LocInstream);
            Bitmap1.FromStream(LocInstream);

            IntWidth := Bitmap1.GetWidth() * EFSTASetup."Picture Enlarge Factor";
            IntHeight := Bitmap1.GetHeight() * EFSTASetup."Picture Enlarge Factor";


            Bitmap1.Resize(IntWidth, IntHeight);
            Bitmap1.SetFormat(Enum::"Image Format"::Bmp);

            EFSTALog."QR Picture Resized".CreateOutStream(LocOutStream);
            Bitmap1.Save(LocOutStream);
        end;
    end;

    internal procedure GetEFSTASetup(LocTransHeader: Record "CCS CASH POS Transaction Hdr."; RaiseError: Boolean): Boolean
    begin
        EFSTASetup.Reset();
        EFSTASetup.SetRange("Store No.", LocTransHeader."Store No.");
        EFSTASetup.SetRange("POS Terminal No.", LocTransHeader."POS Terminal No.");
        if not EFSTASetup.Find('-') then begin
            EFSTASetup.SetRange("POS Terminal No.", '');
            if not EFSTASetup.Find('-') then
                if RaiseError then
                    EFSTASetup.Find('-')
                else
                    exit(false);
        end;

        if not EFSTASetup."WebService Active" then
            if RaiseError then
                EFSTASetup.TestField("WebService Active", true)
            else
                exit(false);
        exit(true);
    end;

    internal procedure GetEFSTASetupForPicture(LocTransHeader: Record "CCS CASH POS Transaction Hdr."; RaiseError: Boolean): Boolean
    begin
        // ++ EFSTA2.07
        EFSTASetup.Reset();
        EFSTASetup.SetRange("Store No.", LocTransHeader."Store No.");
        EFSTASetup.SetRange("POS Terminal No.", LocTransHeader."POS Terminal No.");
        if not EFSTASetup.Find('-') then begin
            EFSTASetup.SetRange("POS Terminal No.", '');
            if not EFSTASetup.Find('-') then
                if RaiseError then
                    EFSTASetup.Find('-')
                else
                    exit(false);
        end;

        exit(true);
        // -- EFSTA2.07
    end;

    internal procedure IsWebServiceEnabled(LocTransHeader: Record "CCS CASH POS Transaction Hdr."): Boolean
    begin
        exit(GetEFSTASetup(LocTransHeader, false));
    end;

    internal procedure GetUserMessage(LocTransHeader: Record "CCS CASH POS Transaction Hdr."): Text
    var
        locEFSTALog: Record "CCS CASH Signa. Srv. Req. Log";
    begin
        locEFSTALog.SetRange("Store No.", LocTransHeader."Store No.");
        locEFSTALog.SetRange("POS Terminal No.", LocTransHeader."POS Terminal No.");
        locEFSTALog.SetRange("Transaction No.", LocTransHeader."Transaction No.");

        if not locEFSTALog.FindLast() then
            exit('');

        exit(locEFSTALog."User Message");
    end;

    internal procedure GetReceiptMessage(LocTransHeader: Record "CCS CASH POS Transaction Hdr."): Text[250]
    var
        locEFSTALog: Record "CCS CASH Signa. Srv. Req. Log";
    begin
        locEFSTALog.SetRange("Store No.", LocTransHeader."Store No.");
        locEFSTALog.SetRange("POS Terminal No.", LocTransHeader."POS Terminal No.");
        locEFSTALog.SetRange("Transaction No.", LocTransHeader."Transaction No.");

        if not locEFSTALog.FindLast() then
            exit('');

        exit(locEFSTALog."Tag Label");
    end;

    internal procedure HasError(LocTransHeader: Record "CCS CASH POS Transaction Hdr."): Boolean
    var
        locEFSTALog: Record "CCS CASH Signa. Srv. Req. Log";
    begin
        // ++ EFSTA2.01
        locEFSTALog.SetRange("Store No.", LocTransHeader."Store No.");
        locEFSTALog.SetRange("POS Terminal No.", LocTransHeader."POS Terminal No.");
        locEFSTALog.SetRange("Transaction No.", LocTransHeader."Transaction No.");

        if not locEFSTALog.FindLast() then
            exit(false);

        exit(locEFSTALog."Response Error");
        // -- EFSTA2.01
    end;

    internal procedure GetValueFromResponse(XMLTag: Text[30]) RespFieldValue: Text
    begin
        // ++ EFSTA2.01
        InitReadResponse();
        ReadResponseFieldName(XMLTag, RespFieldValue);
        // -- EFSTA2.01
    end;

    internal procedure CheckTerminalSignDevOverdue(StoreNo: Code[20]; TerminalNo: Code[20]; var ErrorText: Text): Boolean
    var
        TempTransHeader: Record "CCS CASH POS Transaction Hdr." temporary;
    begin
        // ++ EFSTA2.01
        TempTransHeader.Init();
        TempTransHeader."Store No." := StoreNo;
        TempTransHeader."POS Terminal No." := TerminalNo;
        GetEFSTASetup(TempTransHeader, false);

        if EFSTASetup."Signature Failure Timestamp" = 0DT then
            exit(false);

        if (EFSTASetup."Signature Failure Timestamp" + (1000 * 60 * 60 * 24 * 2)) < CurrentDateTime then begin
            ErrorText := Text004 + '\' + Text003;
            exit(true);
        end;

        exit(false);
        // -- EFSTA2.01
    end;

    internal procedure GetMessageSignDevBroken(LocTransHeader: Record "CCS CASH POS Transaction Hdr."; var WarningMessage: Text): Boolean
    var
        RemDateTime: BigInteger;
        RemHours: BigInteger;
        RemMin: BigInteger;
    begin
        // ++ EFSTA2.01
        if not GetEFSTASetup(LocTransHeader, false) then
            exit(false);

        if EFSTASetup."Sign. Failure Message Type" = EFSTASetup."Sign. Failure Message Type"::"No Message" then
            exit(false);

        if EFSTASetup."Signature Failure Timestamp" = 0DT then
            exit(false);

        RemDateTime := (EFSTASetup."Signature Failure Timestamp" + (1000 * 60 * 60 * 24 * 2)) - CurrentDateTime;
        if RemDateTime < 0 then begin
            WarningMessage := Text006;
        end;

        RemHours := (RemDateTime / 1000 / 60 / 60) div 1;
        RemMin := (((RemDateTime / 1000 / 60 / 60) - RemHours) * 60) div 1;

        if ((EFSTASetup."Sign. Failure Message Type" = EFSTASetup."Sign. Failure Message Type"::"On Login") and
            (LocTransHeader."Transaction Type" = LocTransHeader."Transaction Type"::Logon)) or
           ((EFSTASetup."Sign. Failure Message Type" = EFSTASetup."Sign. Failure Message Type"::"Every Transaction") and
            (LocTransHeader."Transaction Type" in
            [LocTransHeader."Transaction Type"::Sales,
             LocTransHeader."Transaction Type"::Payment])) then begin
            if RemDateTime > 0 then
                WarningMessage := StrSubstNo(Text005, RemHours, RemMin);
            exit(true);
        end;

        exit(false);
        // -- EFSTA2.01
    end;

    internal procedure GetQRCode(var LocEFSTALog: Record "CCS CASH Signa. Srv. Req. Log"; var MessageText: Text)
    var
        WebServiceRequestMgt: Codeunit "CCS CASH Reg. Req.Mgt. EFSTA";
        InStream: InStream;
        ResponseInStream: InStream;
        ResponseOutStream: OutStream;
        Image: Codeunit Image;
    begin
        // ++ EFSTA2.05
        LocEFSTALog.CalcFields("QR Picture", "QR Picture Resized");
        if LocEFSTALog."QR Picture".HasValue and LocEFSTALog."QR Picture Resized".HasValue then
            exit;

        // ++ EFSTA2.07
        //GetEFSTASetupWithLog(LocEFSTALog,TRUE);
        GetEFSTASetupWithLog(LocEFSTALog, false);
        if not EFSTASetup."WebService Active" then begin
            if EFSTASetup."Print Picture" then
                MessageText := Text009;
            exit;
        end;
        // -- EFSTA2.07

        Clear(InStream);
        WebServiceRequestMgt.SetGlobals(InStream, EFSTASetup."WebService QR Path" + LocEFSTALog."QR Code", '', '', 'GET');
        WebServiceRequestMgt.SetNoBodyContentNeeded(true);
        WebServiceRequestMgt.DisableHttpsCheck();
        if EFSTASetup."Web Service Timeout ms" = 0 then
            EFSTASetup."Web Service Timeout ms" := 30000;
        WebServiceRequestMgt.SetTimeout(EFSTASetup."Web Service Timeout ms");

        if WebServiceRequestMgt.RUNFunction() then begin
            WebServiceRequestMgt.GetResponseContent(ResponseInStream);
            LocEFSTALog."QR Picture".CreateOutStream(ResponseOutStream);

            Image.FromStream(ResponseInStream);
            Image.SetFormat(Enum::"Image Format"::Bmp);
            Image.Save(ResponseOutStream);
            ResizeImageEFSTALog(LocEFSTALog);
        end else begin
            LocEFSTALog."Response Error" := true;
            LocEFSTALog."Response Text" := CopyStr(GetLastErrorText, 1, 250);
            LocEFSTALog."User Message" := Text002;
            // ++ EFSTA2.07
            MessageText := Text009;
            // -- EFSTA2.07
        end;

        // -- EFSTA2.05
    end;

    internal procedure GetEFSTASetupWithLog(LocEfstaLog: Record "CCS CASH Signa. Srv. Req. Log"; RaiseError: Boolean): Boolean
    begin
        // ++ EFSTA2.05
        EFSTASetup.Reset();
        EFSTASetup.SetRange("Store No.", LocEfstaLog."Store No.");
        EFSTASetup.SetRange("POS Terminal No.", LocEfstaLog."POS Terminal No.");
        if not EFSTASetup.Find('-') then begin
            EFSTASetup.SetRange("POS Terminal No.", '');
            if not EFSTASetup.Find('-') then
                if RaiseError then
                    EFSTASetup.Find('-')
                else
                    exit(false);
        end;

        if not EFSTASetup."WebService Active" then
            if RaiseError then
                EFSTASetup.TestField("WebService Active", true)
            else
                exit(false);
        exit(true);
        // -- EFSTA2.05
    end;

    internal procedure ResizeImageEFSTALog(var LocEFSTALog: Record "CCS CASH Signa. Srv. Req. Log")
    var
        Bitmap1: Codeunit Image;
        LocInstream: InStream;
        LocOutStream: OutStream;
        IntWidth: Integer;
        IntHeight: Integer;
    begin
        // ++ EFSTA2.05
        //Bitmap1 := Bitmap1.Bitmap('C:\Pepper\QRCode.bmp');
        LocEFSTALog."QR Picture".CreateInStream(LocInstream);
        Bitmap1.FromStream(LocInstream);

        IntWidth := Bitmap1.GetWidth() / EFSTASetup."Picture Reduction Factor";
        IntHeight := Bitmap1.GetHeight() / EFSTASetup."Picture Reduction Factor";

        Bitmap1.Resize(IntWidth, IntHeight);
        Bitmap1.SetFormat(Enum::"Image Format"::Bmp);


        LocEFSTALog."QR Picture Resized".CreateOutStream(LocOutStream);
        Bitmap1.Save(LocOutStream);

        if EFSTASetup."Picture Enlarge Factor" > 1 then begin
            LocEFSTALog."QR Picture Resized".CreateInStream(LocInstream);
            Bitmap1.FromStream(LocInstream);

            IntWidth := Bitmap1.GetWidth() * EFSTASetup."Picture Enlarge Factor";
            IntHeight := Bitmap1.GetHeight() * EFSTASetup."Picture Enlarge Factor";

            Bitmap1.Resize(IntWidth, IntHeight);
            Bitmap1.SetFormat(Enum::"Image Format"::Bmp);

            LocEFSTALog."QR Picture Resized".CreateOutStream(LocOutStream);
            Bitmap1.Save(LocOutStream);
        end;
        // -- EFSTA2.05
    end;

    internal procedure GetExportFile(SignServiceSetup: Record "CCS CASH Signa. Service Setup")
    var
        StartDate: Date;
        InputDialog: Page "CCS CASH General Input Dialog";
    begin
        // ++ EFSTA2.08
        SignServiceSetup.TestField("WebService Export Path");

        InputDialog.RunModal();
        StartDate := InputDialog.getInputDate();

        HyperLink(StrSubstNo(SignServiceSetup."WebService Export Path", Format(StartDate, 0, '<Year4>-<Month,2>-<Day,2>')));
        // -- EFSTA2.08
    end;

    internal procedure InitReadResponse()
    begin
        Clear(BodyContentInputStreamRead);
        Clear(BodyContentJsonRead);

        if not EFSTALog.Response.HasValue then exit;

        EFSTALog.Response.CreateInStream(BodyContentInputStreamRead);

        BodyContentJsonRead.ReadFrom(BodyContentInputStreamRead);
    end;

    internal procedure ReadResponseFieldName(FieldNameText: Text[50]; var FieldNameValue: Text)
    var
        JsonT: JsonToken;
    begin
        Clear(FieldNameValue);
        if BodyContentJsonRead.Get(FieldNameText, JsonT) then begin
            if JsonT.IsValue then begin
                FieldNameValue := JsonT.AsValue().AsText();
            end;
        end;
    end;

    internal procedure ReadResponseAttributeName(FieldNameText: Text[50]; AttText: Text[50]; var FieldNameValue: Text)
    var
        JsonT: JsonToken;
        JsonT2: JsonToken;
    begin
        Clear(FieldNameValue);
        if BodyContentJsonRead.Get(FieldNameText, JsonT) then begin
            if JsonT.IsObject then begin
                if JsonT.AsObject().Get(AttText, JsonT2) then begin
                    if JsonT2.IsValue then begin
                        FieldNameValue := JsonT2.AsValue().AsText();
                    end;
                end;
            end;
        end;
    end;

    internal procedure ReadResponseAttributeName(FieldNameText: Text[50]; FieldNameText2: Text[50]; AttText: Text[50]; var FieldNameValue: Text)
    var
        JsonT: JsonToken;
        JsonT2: JsonToken;
        JsonT3: JsonToken;
        JsonTA: JsonToken;
    begin
        Clear(FieldNameValue);
        if BodyContentJsonRead.Get(FieldNameText, JsonT) then begin
            if JsonT.IsObject then begin
                if JsonT.AsObject().Get(FieldNameText2, JsonT2) then begin
                    if JsonT2.IsArray then begin
                        JsonT2.AsArray().Get(0, JsonTA);
                        if JsonTA.IsObject then begin
                            if JsonTA.AsObject().Get(AttText, JsonT3) then begin
                                if JsonT3.IsValue then begin
                                    FieldNameValue := JsonT3.AsValue().AsText();
                                end;
                            end;
                        end;
                    end;

                end;
            end;
        end;
    end;
}

