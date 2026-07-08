namespace S_W.BilanzTool;

/// <summary>Setup creation and migration.</summary>
codeunit 62018 "BT Setup Management"
{
    var
        Logger: Codeunit "BT Logger";
        Setup: Record "BT Setup";

    procedure CreateDefaultSetup()
    begin
        if not Setup.Get() then
            Logger.Warning('Setup not found — creating default');
    end;

    procedure UpgradeSetup()
    begin
        // Data upgrade logic for version 4.0.0.0
        Setup.Get();
        Setup.Modify();
    end;
}
