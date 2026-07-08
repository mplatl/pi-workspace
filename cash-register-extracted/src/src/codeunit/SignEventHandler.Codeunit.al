codeunit 1070545 "CCS CASH Sign. Event Handler"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CCS CASH POS Register Func", 'OnCallSignatureService', '', true, true)]
    local procedure CU1070540_OnCallSignatureService(pTransHeader: Record "CCS CASH POS Transaction Hdr."; VAR IsHandled: boolean)
    var
        EFSTAService: Codeunit "CCS CASH Reg. Webserv. EFSTA";
        LocUserMessage: Text;
    begin
        IsHandled := true;

        CLEAR(EFSTAService);
        IF EFSTAService.IsWebServiceEnabled(pTransHeader) THEN BEGIN
            EFSTAService.SendTransToEFR(pTransHeader);
            LocUserMessage := EFSTAService.GetUserMessage(pTransHeader);
            // ++ EFSTA2.01
            IF EFSTAService.HasError(pTransHeader) THEN
                ERROR(LocUserMessage);
            IF EFSTAService.GetMessageSignDevBroken(pTransHeader, LocUserMessage) THEN
                MESSAGE(LocUserMessage)
            ELSE
                // -- EFSTA2.01
                IF LocUserMessage <> '' THEN
                    MESSAGE(LocUserMessage);
        END;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CCS CASH POS Register Func", 'OnIsSignatureServiceDown', '', true, true)]
    local procedure CU1070540_OnIsSignatureServiceDown(StoreNo: Code[20]; POSTerminalNo: Code[20]; ReceiptNo: Code[20]; VAR IsServiceDown: boolean; VAR IsHandled: boolean)
    var
        EFSTAService: Codeunit "CCS CASH Reg. Webserv. EFSTA";
        PreErrorText: Text;
        TempEFSTATrans: Record "CCS CASH POS Transaction Hdr." temporary;
    begin
        IsHandled := true;
        IsServiceDown := false;

        // ++ EFSTA2.01
        CLEAR(EFSTAService);

        //IF (ReceiptNo <> '') THEN BEGIN
        TempEFSTATrans.INIT();
        TempEFSTATrans."Store No." := StoreNo;
        TempEFSTATrans."POS Terminal No." := POSTerminalNo;
        TempEFSTATrans."Receipt No." := ReceiptNo;

        IF EFSTAService.IsWebServiceEnabled(TempEFSTATrans) THEN BEGIN
            CLEAR(PreErrorText);
            IF EFSTAService.GetWebServiceState('', '', TempEFSTATrans, TRUE, PreErrorText) THEN BEGIN
                IsServiceDown := true;
                ERROR(PreErrorText);
            END;
            IF EFSTAService.CheckTerminalSignDevOverdue(StoreNo, POSTerminalNo, PreErrorText) THEN BEGIN
                IsServiceDown := true;
                ERROR(PreErrorText);
            END;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CCS CASH POS Register Func", 'OnIsSignatureSetupActive', '', true, true)]
    local procedure OnIsSignatureSetupActive(StoreNo: Code[20]; POSTerminalNo: Code[20]; VAR IsActive: boolean; VAR IsHandled: boolean)
    var
        EFSTAWebService: Codeunit "CCS CASH Reg. Webserv. EFSTA";
        TempTransHeader: Record "CCS CASH POS Transaction Hdr." temporary;
    begin
        IsHandled := true;
        // ++ EFSTA2.06
        TempTransHeader."Store No." := StoreNo;
        TempTransHeader."POS Terminal No." := POSTerminalNo;
        IsActive := EFSTAWebService.IsWebServiceEnabled(TempTransHeader);
        // -- EFSTA2.06        
    end;



    [EventSubscriber(ObjectType::Page, Page::"CCS CASH POS Terminal Card", 'OnStartFiscalisation', '', true, true)]
    local procedure OnStartFiscalisation(StoreNo: Code[20]; No: Code[20]; VAR IsHandled: boolean)
    var
        SigSetup: Record "CCS CASH Signa. Service Setup";
    begin
        IsHandled := true;
        SigSetup.Get(StoreNo, No);
        SigSetup."WebService Active" := true;
        SigSetup.Modify(true);
    end;

    [EventSubscriber(ObjectType::Page, Page::"CCS CASH POS Terminal Card", 'OnStopFiscalisation', '', true, true)]
    local procedure OnStopFiscalisation(StoreNo: Code[20]; No: Code[20]; VAR IsHandled: boolean)
    var
        SigSetup: Record "CCS CASH Signa. Service Setup";
    begin
        IsHandled := true;
        SigSetup.Get(StoreNo, No);
        SigSetup."WebService Active" := false;
        SigSetup.Modify(true);
    end;

    [EventSubscriber(ObjectType::Page, Page::"CCS CASH POS Transactions", 'OnOpenPageSigServiceRequestLog', '', true, true)]
    local procedure OnOpenPageSigServiceRequestLog(StoreNo: Code[20]; PosTerminalNo: Code[20]; TransactionNo: Integer; VAR IsHandled: boolean)
    var
        SignServiceRequestLogPage: Page "CCS CASH Signa. Srv. Req. Log";
        SignServiceRequestLog: Record "CCS CASH Signa. Srv. Req. Log";
    begin
        IsHandled := true;

        SignServiceRequestLog.Reset();
        SignServiceRequestLog.SetRange("Store No.", StoreNo);
        SignServiceRequestLog.SetRange("POS Terminal No.", PosTerminalNo);
        SignServiceRequestLog.SetRange("Transaction No.", TransactionNo);
        SignServiceRequestLogPage.SetTableView(SignServiceRequestLog);
        SignServiceRequestLogPage.Run();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CCS CASH POS Register Func", 'OnGetDocumentQRCode', '', true, true)]

    local procedure OnGetDocumentQRCode(StoreNo: Code[20]; PosTerminalNo: Code[20]; TransactionNo: Integer; VAR DocumentInformation: Record "CCS CASH Document Information"; VAR IsHandled: boolean)
    var
        EfstaLog: Record "CCS CASH Signa. Srv. Req. Log";
        EfstaSetup: Record "CCS CASH Signa. Service Setup";
        EFSTAWebService: Codeunit "CCS CASH Reg. Webserv. EFSTA";
        EFSTAMessageText: Text;
    begin
        IsHandled := true;

        if not EfstaSetup.Get(StoreNo, PosTerminalNo) then
            if EfstaSetup.Get(StoreNo, '') then;
        if EfstaSetup."Store No." <> '' then begin
            EfstaLog.SetRange("Store No.", StoreNo);
            EfstaLog.SetRange("POS Terminal No.", PosTerminalNo);
            EfstaLog.SetRange("Transaction No.", TransactionNo);
            if EfstaLog.FindLast() then begin
                // ++ EFSTA2.05
                // ++ EFSTA2.07
                //EFSTAWebService.GetQRCode(EfstaLog);
                EFSTAWebService.GetQRCode(EfstaLog, EFSTAMessageText);
                // -- EFSTA2.07
                // -- EFSTA2.05
                EfstaLog.CalcFields("QR Picture");
                EfstaLog.CalcFields("QR Picture Resized");
            end;
            case EfstaSetup."Picture Print Position" of
                EfstaSetup."Picture Print Position"::Left:
                    begin
                        if EfstaSetup."Picture Print Option" = EfstaSetup."Picture Print Option"::Original then
                            //EfstaLogLeft."QR Picture" := EfstaLog."QR Picture"
                            DocumentInformation."QR Code Left" := EfstaLog."QR Picture"
                        else
                            //EfstaLogLeft."QR Picture" := EfstaLog."QR Picture Resized"
                            DocumentInformation."QR Code Left" := EfstaLog."QR Picture Resized";
                    end;
                EfstaSetup."Picture Print Position"::Middle:
                    begin
                        if EfstaSetup."Picture Print Option" = EfstaSetup."Picture Print Option"::Original then
                            //EfstaLogMiddle."QR Picture" := EfstaLog."QR Picture"
                            DocumentInformation."QR Code Middle" := EfstaLog."QR Picture"
                        else
                            //EfstaLogMiddle."QR Picture" := EfstaLog."QR Picture Resized"
                            DocumentInformation."QR Code Middle" := EfstaLog."QR Picture Resized";
                    end;
                EfstaSetup."Picture Print Position"::Right:
                    begin
                        if EfstaSetup."Picture Print Option" = EfstaSetup."Picture Print Option"::Original then
                            //EfstaLogRight."QR Picture" := EfstaLog."QR Picture"
                            DocumentInformation."QR Code Right" := EfstaLog."QR Picture"
                        else
                            //EfstaLogRight."QR Picture" := EfstaLog."QR Picture Resized"
                            DocumentInformation."QR Code Right" := EfstaLog."QR Picture Resized";
                    end;
            end;
        end;
        // -- EFSTA2.00        
    end;
}