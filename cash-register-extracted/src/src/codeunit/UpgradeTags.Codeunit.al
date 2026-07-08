codeunit 1070554 "CCS CASH Upgrade Tags"
{
    Access = Internal;

    internal procedure CCSCashSalesSetup(): Code[250]
    begin
        exit('CCS CCS Cash Sales Setup')
    end;

    internal procedure ActivateDemoLicense(): Code[250]
    begin
        exit('CCS CASH Activate Demo License')
    end;

    internal procedure DeactivateDemoLicense(): Code[250]
    begin
        exit('CCS CASH Deactivate Demo License')
    end;

    internal procedure CopyFieldValues(): Code[250]
    begin
        exit('CCS CASH Copy Field Values')
    end;

    internal procedure CCSUpdateRemainingPaymentDiscount(): Code[250]
    begin
        exit('CCS CASH Update Remaining Payment Discount');
    end;

    internal procedure CCSUpdateReceiptNoPaymentEntry(): Code[250]
    begin
        exit('CCS CASH Update Receipt No. Pmt Entry');
    end;
}