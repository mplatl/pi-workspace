// ----------------------------------------------------------------------------
// Codeunit: MIP CSV Parser
// ----------------------------------------------------------------------------
// CSV-Parser-Implementierung des Interface MIP Import Parser.
// Liest einen CSV-BLOB, splittet Zeilen und Spalten,
// serialisiert jede Zeile als JSON in den Data Buffer.
// ----------------------------------------------------------------------------

codeunit 50003 "MIP CSV Parser" implements "MIP Import Parser"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Parst eine CSV-Datei aus dem Import-File-BLOB in den Data Buffer.
    /// </summary>
    procedure Parse(var ImportFile: Record "MIP Import File"; var SetupHeader: Record "MIP Import Setup Header"; var DataBuffer: Record "MIP Import Data Buffer")
    var
        InStream: InStream;
        TextLine: Text;
        LineNo: Integer;
        Columns: List of [Text];
        ColumnNames: List of [Text];
    begin
        ImportFile."File Content".CreateInStream(InStream);

        if not InStream.EOS then begin
            InStream.Read(TextLine);
            LineNo := 1;

            if SetupHeader."First Row Is Header" then begin
                ColumnNames := SplitLine(TextLine, SetupHeader."Column Separator");
                ImportFile."Lines Total" -= 1;
            end
            else begin
                Columns := SplitLine(TextLine, SetupHeader."Column Separator");
                WriteDataBuffer(DataBuffer, ImportFile."Entry No.", LineNo, Columns, ColumnNames);
            end;
        end;

        while not InStream.EOS do begin
            InStream.Read(TextLine);
            LineNo += 1;
            Columns := SplitLine(TextLine, SetupHeader."Column Separator");
            WriteDataBuffer(DataBuffer, ImportFile."Entry No.", LineNo, Columns, ColumnNames);
        end;

        ImportFile."Lines Total" := LineNo;
    end;

    /// <summary>
    /// Schreibt eine geparste Zeile als JSON in den Data Buffer.
    /// </summary>
    local procedure WriteDataBuffer(var DataBuffer: Record "MIP Import Data Buffer"; FileEntryNo: Integer; RowNo: Integer; Columns: List of [Text]; ColumnNames: List of [Text])
    var
        JSONBuilder: TextBuilder;
        OutStream: OutStream;
        i: Integer;
        ColName: Text;
    begin
        JSONBuilder.Append('{');
        for i := 1 to Columns.Count() do begin
            if i > 1 then
                JSONBuilder.Append(',');
            if i <= ColumnNames.Count() then
                ColName := ColumnNames.Get(i)
            else
                ColName := StrSubstNo('Column_%1', i);
            JSONBuilder.Append('"' + ColName + '":"' + Columns.Get(i) + '"');
        end;
        JSONBuilder.Append('}');

        DataBuffer.Init();
        DataBuffer."Import File Entry No." := FileEntryNo;
        DataBuffer."Row No." := RowNo;
        DataBuffer."Raw Data JSON".CreateOutStream(OutStream);
        OutStream.Write(JSONBuilder.ToText());
        DataBuffer.Status := DataBuffer.Status::Pending;
        DataBuffer.Insert();
    end;

    /// <summary>
    /// Zerlegt eine CSV-Zeile anhand des Separators.
    /// </summary>
    local procedure SplitLine(TextLine: Text; Separator: Text) Columns: List of [Text]
    var
        Pos: Integer;
    begin
        repeat
            Pos := TextLine.IndexOf(Separator);
            if Pos > 0 then begin
                Columns.Add(CopyStr(TextLine, 1, Pos));
                TextLine := CopyStr(TextLine, Pos + StrLen(Separator));
            end
            else begin
                Columns.Add(TextLine);
                TextLine := '';
            end;
        until TextLine = '';
    end;
}
