namespace S_W.BilanzTool;

/// <summary>Logging codeunit for BilanzTool.</summary>
codeunit 62012 "BT Logger"
{
    var Log: Record "BT Log";

    procedure Trace(Msg: Text)
    begin Log.Init(); Log.Level := Log.Level::Trace; Log.Message := Msg; Log."Entry Timestamp" := CurrentDateTime(); Log.Insert(); end;

    procedure Debug(Msg: Text)
    begin Log.Init(); Log.Level := Log.Level::Debug; Log.Message := Msg; Log."Entry Timestamp" := CurrentDateTime(); Log.Insert(); end;

    procedure Info(Msg: Text)
    begin Log.Init(); Log.Level := Log.Level::Info; Log.Message := CopyStr(Msg, 1, 250); Log."Entry Timestamp" := CurrentDateTime(); Log.Insert(); end;

    procedure Warning(Msg: Text)
    begin Log.Init(); Log.Level := Log.Level::Warning; Log.Message := CopyStr(Msg, 1, 250); Log."Entry Timestamp" := CurrentDateTime(); Log.Insert(); end;

    procedure Error(Msg: Text)
    begin Log.Init(); Log.Level := Log.Level::Error; Log.Message := CopyStr(Msg, 1, 250); Log."Entry Timestamp" := CurrentDateTime(); Log.Insert(); end;
}
