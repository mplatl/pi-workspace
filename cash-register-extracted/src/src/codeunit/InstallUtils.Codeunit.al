codeunit 1070551 "CCS CASH InstallUtils"
{
    Subtype = Install;
    Access = Internal;

    trigger OnInstallAppPerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        CCSCUpgradeTags: Codeunit "CCS Cash Upgrade Tags";
    begin
        if not UpgradeTag.HasUpgradeTag(CCSCUpgradeTags.CopyFieldValues()) then
            UpgradeTag.SetUpgradeTag(CCSCUpgradeTags.CopyFieldValues());
        if not UpgradeTag.HasUpgradeTag(CCSCUpgradeTags.CCSUpdateRemainingPaymentDiscount()) then
            UpgradeTag.SetUpgradeTag(CCSCUpgradeTags.CCSUpdateRemainingPaymentDiscount());
        if not UpgradeTag.HasUpgradeTag(CCSCUpgradeTags.CCSUpdateReceiptNoPaymentEntry()) then
            UpgradeTag.SetUpgradeTag(CCSCUpgradeTags.CCSUpdateReceiptNoPaymentEntry());
        if not UpgradeTag.HasUpgradeTag(CCSCUpgradeTags.ActivateDemoLicense()) then
            UpgradeTag.SetUpgradeTag(CCSCUpgradeTags.ActivateDemoLicense());
        if not UpgradeTag.HasUpgradeTag(CCSCUpgradeTags.DeactivateDemoLicense()) then
            UpgradeTag.SetUpgradeTag(CCSCUpgradeTags.DeactivateDemoLicense());
        RefreshExperienceTier();
    end;

    local procedure RefreshExperienceTier()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;
}