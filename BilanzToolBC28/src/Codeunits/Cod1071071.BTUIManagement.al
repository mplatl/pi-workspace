namespace S_W.BilanzTool;

/// <summary>UI helpers for page state and user interaction.</summary>
codeunit 62013 "BT UI Management"
{
    var Logger: Codeunit "BT Logger";

    procedure ConfirmDelete(RecordName: Text; RecordID: Text): Boolean
    begin
        exit(Confirm(StrSubstNo('Delete %1 "%2"?', RecordName, RecordID), false));
    end;

    procedure ShowProgress(Text: Text)
    begin
    end;

    procedure ShowError(Text: Text)
    begin
        Error(Text);
    end;

    procedure ShowMessage(Text: Text)
    begin
        Message(Text);
    end;
}
