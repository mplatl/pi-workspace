codeunit 1070555 "CCS CASH License Management" implements "CCS LIC App Granule Information", "CCS LIC App Granule Info. OnPrem"
{
    // #region interface implementation

    /// <summary>
    /// Returns the app id
    /// </summary>
    /// <returns>The app info app id.</returns>
    procedure GetAppId(): Guid
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.Id);
    end;

    /// <summary>
    /// Returns a guid of the granule. The granule can also be the app id.
    /// </summary>
    /// <param name="AppGranule">The granule to return the guid from.</param>
    /// <returns>The granule guid.</returns>
    procedure GetGranuleId(AppGranule: Enum "CCS LIC App Granule"): Guid
    var
        MissingGranuleErr: Label 'Missing Granule ID for %1.', Comment = '%1 - granule name';
    begin
        case AppGranule of
            AppGranule::"CCS CASH Base":
                exit(GetAppId());
            else
                Error(MissingGranuleErr, Format(AppGranule));
        end;
    end;

    /// <summary>
    /// Returns the name of the granule. The granule can also be the app id.
    /// </summary>
    /// <param name="AppGranule">The granule to return the name from.</param>
    /// <returns>The granule name.</returns>
    procedure GetGranuleName(AppGranule: Enum "CCS LIC App Granule"): Text[128]
    begin
        exit(Format(AppGranule));
    end;
    // #endregion

    procedure GetCodeunitId(AppGranule: Enum "CCS LIC App Granule"): Integer
    begin
        exit(Codeunit::"CCS CASH License Management");
    end;

    // #region event subscribers
    [EventSubscriber(ObjectType::Page, Page::"CCS CASH CSL Setup", 'OnOpenPageEvent', '', true, true)]
    local procedure OnOpenCCSCASHCSLSetupPage(var Rec: Record "CCS CASH Cash Sales Setup")
    var
        Licensing: Codeunit "CCS LIC Licensing";
    begin
        Licensing.ShowRegistrationNotificationFor(GetAppId());
        Licensing.ShowInformationNotificationFor(GetAppId());
    end;



    [EventSubscriber(ObjectType::Page, Page::"CCS CASH Cash Sales Login", 'OnOpenPageEvent', '', true, true)]
    local procedure OnOpenCCSCASHCashSalesLoginPage()
    var
        CCSLICLicensing: Codeunit "CCS LIC Licensing";
    begin
        CCSLICLicensing.IsValid("CCS LIC App Granule"::"CCS CASH Base", true);
    end;

    // #endregion
}