codeunit 1070552 "CCS CASH UpgradeUtils"
{
    Subtype = Upgrade;
    Access = Internal;

    trigger OnUpgradePerCompany()
    begin
        CCSCashSalesSetup();
        RegisterLicenses();
        CopyFieldValues();
        CCSUpdateRemainingPaymentDiscount();
        UpdateReceiptNoPaymentEntry();
        DeactivateDemoLicense();
    end;

    local procedure CCSCashSalesSetup()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        CCSCUpgradeTags: Codeunit "CCS Cash Upgrade Tags";
        CCSCashSetup: Record "CCS CASH Cash Sales Setup";
    begin
        if UpgradeTag.HasUpgradeTag(CCSCUpgradeTags.CCSCashSalesSetup()) then
            exit;

        if CCSCashSetup.Get() then begin
            CCSCashSetup.Validate("PMT. Meth. in Descr. of Rct.", true);
            CCSCashSetup.Modify();
        end;

        UpgradeTag.SetUpgradeTag(CCSCUpgradeTags.CCSCashSalesSetup());
    end;

    local procedure CCSUpdateRemainingPaymentDiscount()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        CCSCUpgradeTags: Codeunit "CCS Cash Upgrade Tags";
        CCSStaff: Record "CCS CASH Staff";
    begin
        if UpgradeTag.HasUpgradeTag(CCSCUpgradeTags.CCSUpdateRemainingPaymentDiscount()) then
            exit;

        CCSStaff.ModifyAll("Remaining Pmt. Disc. allowed", true);

        UpgradeTag.SetUpgradeTag(CCSCUpgradeTags.CCSUpdateRemainingPaymentDiscount());
    end;

    local procedure RegisterLicenses()
    var
        CCSCASHCashSalesSetup: Record "CCS CASH Cash Sales Setup";
        Licensing: Codeunit "CCS LIC Licensing";
        UpgradeTag: Codeunit "Upgrade Tag";
        CCSDDPUpgradeTags: Codeunit "CCS CASH Upgrade Tags";
    begin
        if UpgradeTag.HasUpgradeTag(CCSDDPUpgradeTags.ActivateDemoLicense()) then
            exit;

        if Licensing.RegisterLicense("CCS LIC App Granule"::"CCS CASH Base") then begin
            if CCSCASHCashSalesSetup.Get() then begin
                CCSCASHCashSalesSetup."Automatic Demo License" := true;
                CCSCASHCashSalesSetup.Modify();
            end;
            UpgradeTag.SetUpgradeTag(CCSDDPUpgradeTags.ActivateDemoLicense());
        end;
    end;

    local procedure DeactivateDemoLicense()
    var
        CCSCASHCashSalesSetup: Record "CCS CASH Cash Sales Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        CCSDDPUpgradeTags: Codeunit "CCS CASH Upgrade Tags";
    begin
        if UpgradeTag.HasUpgradeTag(CCSDDPUpgradeTags.DeactivateDemoLicense()) then
            exit;

        if CCSCASHCashSalesSetup.Get() then begin
            CCSCASHCashSalesSetup."Automatic Demo License" := false;
            CCSCASHCashSalesSetup.Modify();
        end;
        UpgradeTag.SetUpgradeTag(CCSDDPUpgradeTags.DeactivateDemoLicense());
    end;

    local procedure CopyFieldValues()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        CCSCUpgradeTags: Codeunit "CCS Cash Upgrade Tags";
        locDataTransfer: DataTransfer;
        CCSCASHPOSTransactionHdr: Record "CCS CASH POS Transaction Hdr.";
        CCSCASHStore: Record "CCS CASH Store";
        InStreamPic: InStream;
        locRecRef: RecordRef;
    begin
        if UpgradeTag.HasUpgradeTag(CCSCUpgradeTags.CopyFieldValues()) then
            exit;

        if CCSCASHStore.FindSet() then
            repeat
                CCSCASHStore.CalcFields(Picture);
                if CCSCASHStore.Picture.HasValue then begin
                    CCSCASHStore.Picture.CreateInStream(InStreamPic);
                    CCSCASHStore.Logo.ImportStream(InStreamPic, 'Picture');
                    CCSCASHStore.Modify();
                end;
            until CCSCASHStore.Next() = 0;

        locRecRef.Open(Database::"CCS CASH POS Transaction Hdr.");
        if locRecRef.FieldExist(77700) then begin
            locDataTransfer.SetTables(Database::"CCS CASH POS Transaction Hdr.", Database::"CCS CASH POS Transaction Hdr.");
            locDataTransfer.AddFieldValue(77700, 103);
            locDataTransfer.AddJoin(CCSCASHPOSTransactionHdr.FieldNo("Store No."), CCSCASHPOSTransactionHdr.FieldNo("Store No."));
            locDataTransfer.AddJoin(CCSCASHPOSTransactionHdr.FieldNo("POS Terminal No."), CCSCASHPOSTransactionHdr.FieldNo("POS Terminal No."));
            locDataTransfer.AddJoin(CCSCASHPOSTransactionHdr.FieldNo("Transaction No."), CCSCASHPOSTransactionHdr.FieldNo("Transaction No."));
            locDataTransfer.CopyFields();
        end;

        UpgradeTag.SetUpgradeTag(CCSCUpgradeTags.CopyFieldValues());
    end;

    local procedure UpdateReceiptNoPaymentEntry()
    var
        POSTransactionHdr: Record "CCS CASH POS Transaction Hdr.";
        UpgradeTag: Codeunit "Upgrade Tag";
        CCSCUpgradeTags: Codeunit "CCS Cash Upgrade Tags";
    begin
        if UpgradeTag.HasUpgradeTag(CCSCUpgradeTags.CCSUpdateReceiptNoPaymentEntry()) then
            exit;
        POSTransactionHdr.SetRange(Status, POSTransactionHdr.Status::Normal);
        POSTransactionHdr.SetFilter("Receipt No.", '<>%1', '');
        if POSTransactionHdr.FindSet() then
            repeat
                POSTransactionHdr.UpdateReceiptNoTransPaymentEntry();
            until POSTransactionHdr.Next() = 0;
        UpgradeTag.SetUpgradeTag(CCSCUpgradeTags.CCSUpdateReceiptNoPaymentEntry());
    end;
}