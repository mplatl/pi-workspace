codeunit 1070556 "CCS CASH App. Area Enablement"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetBasicExperienceAppAreas', '', false, false)]
    local procedure RegisterDocumentDispatcherOnGetBasicExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        EnableApplicationAreas(TempApplicationAreaSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetEssentialExperienceAppAreas', '', false, false)]
    local procedure RegisterDocumentDispatcherOnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        EnableApplicationAreas(TempApplicationAreaSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetPremiumExperienceAppAreas', '', false, false)]
    local procedure RegisterDocumentDispatcherOnGetPremiumExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        EnableApplicationAreas(TempApplicationAreaSetup);
    end;

    local procedure EnableApplicationAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
        CCSLICLicensing: Codeunit "CCS LIC Licensing";
    begin
        TempApplicationAreaSetup."CCS CASH" := CCSLICLicensing.IsValid("CCS LIC App Granule"::"CCS CASH Base", false);
        OnAfterEnableApplicationAreas(TempApplicationAreaSetup);
    end;

    /// <summary>
    /// The event is fired after the product application areas have been enabled, based on the setup and licensing.
    /// </summary>
    /// <param name="TempApplicationAreaSetup">The application area setup record.</param>
    /// <param name="Setup">The product setup. The record might not be open, if no setup exists.</param>
    [IntegrationEvent(false, false)]
    local procedure OnAfterEnableApplicationAreas(var TempApplicationAreaSetup: Record "Application Area Setup")
    begin
    end;
}