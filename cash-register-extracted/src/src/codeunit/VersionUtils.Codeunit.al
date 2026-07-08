codeunit 1070553 "CCS CASH VersionUtils"
{
    procedure GetVersion(): Text
    var
        AppInfo: ModuleInfo;
    begin
#pragma warning disable AA0217
        exit(StrSubstNo('%1-%2', AppInfo.Name(), AppInfo.AppVersion()));
#pragma warning restore AA0217
    end;
}