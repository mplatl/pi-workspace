// ----------------------------------------------------------------------------
// Codeunit: MIP Import Engine
// ----------------------------------------------------------------------------
// Zentrale Import-Verarbeitungslogik.
// Liest eine Datei aus der MIP Import File-Tabelle, delegiert Parsing
// per Interface MIP Import Parser, führt Spalten-Mapping und Validate
// durch und erzeugt Buchblattzeilen.
// ----------------------------------------------------------------------------

codeunit 50000 "MIP Import Engine"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        ImportFile: Record "MIP Import File";
        SetupHeader: Record "MIP Import Setup Header";
        SetupColumn: Record "MIP Import Setup Column";
        ValueMap: Record "MIP Import Column Value Map";
        DataBuffer: Record "MIP Import Data Buffer";

    /// <summary>
    /// Verarbeitet eine Import-Datei.
    /// </summary>
    /// <param name="ImportFileEntryNo">Entry No. des MIP Import File-Eintrags</param>
    procedure ImportFile(ImportFileEntryNo: Integer)
    begin
        if not ImportFile.Get(ImportFileEntryNo) then
            Error('Import File Entry No. %1 not found.', ImportFileEntryNo);

        CheckFileDuplicate();
        ImportFile.Status := ImportFile.Status::Processing;
        ImportFile.Modify();

        SetupHeader.Get(ImportFile."Setup Code");

        ParseFile();

        if SetupColumn.IsEmpty() then
            AutoCreateColumns();

        ComputeBusinessKey();

        MapAndInsertJournalLines();

        ImportFile."Processed At" := CurrentDateTime();
        ImportFile.Status := ImportFile.Status::Processed;
        ImportFile.Modify();

        CleanupDataBuffer();
    end;

    /// <summary>
    /// Prüft, ob die Datei bereits verarbeitet wurde (Content Hash-Dublette).
    /// </summary>
    local procedure CheckFileDuplicate()
    var
        ExistingImportFile: Record "MIP Import File";
    begin
        if ImportFile."Content Hash" = '' then
            exit;

        ExistingImportFile.SetRange("Setup Code", ImportFile."Setup Code");
        ExistingImportFile.SetRange(Status, ExistingImportFile.Status::Processed);
        ExistingImportFile.SetRange("Content Hash", ImportFile."Content Hash");
        if ExistingImportFile.FindFirst() then begin
            ImportFile.Status := ImportFile.Status::Skipped;
            ImportFile."Error Message" := StrSubstNo(
                'Duplicate file. Already imported on %1 (Entry %2).',
                ExistingImportFile."Processed At", ExistingImportFile."Entry No.");
            ImportFile.Modify();
            Error(ImportFile."Error Message");
        end;
    end;

    /// <summary>
    /// Delegiert das Datei-Parsing per Interface an den konfigurierten Parser.
    /// </summary>
    local procedure ParseFile()
    var
        Parser: Interface "MIP Import Parser";
    begin
        Parser := SetupHeader."Parser Format" as Interface "MIP Import Parser";
        Parser.Parse(ImportFile, SetupHeader, DataBuffer);
    end;

    /// <summary>
    /// Legt Setup Columns automatisch aus den CSV-Headern an.
    /// Target-Felder müssen manuell gesetzt werden.
    /// </summary>
    local procedure AutoCreateColumns()
    begin
        // Automatische Spalten-Erstellung aus Data Buffer JSON
        // Wird in späterer Iteration implementiert
    end;

    /// <summary>
    /// Berechnet den Business Key für jede Datenzeile.
    /// Key = SetupCode + "|" + Wert1 + "|" + Wert2 + …
    /// </summary>
    local procedure ComputeBusinessKey()
    begin
        // Business-Key-Berechnung und Datensatz-Dubletten-Prüfung
        // Wird in späterer Iteration implementiert
    end;

    /// <summary>
    /// Führt das Spalten-Mapping durch, validiert und erzeugt Buchblattzeilen.
    /// </summary>
    local procedure MapAndInsertJournalLines()
    var
        GenJnlLine: Record "Gen. Journal Line";
        InStream: InStream;
        JSONText: Text;
        SourceValue: Text;
        TargetValue: Text;
    begin
        SetupColumn.SetRange("Setup Code", SetupHeader.Code);
        DataBuffer.SetRange("Import File Entry No.", ImportFile."Entry No.");

        if DataBuffer.FindSet() then
            repeat
                GenJnlLine.Init();
                GenJnlLine."Journal Template Name" := SetupHeader."Journal Template Name";
                GenJnlLine."Journal Batch Name" := SetupHeader."Journal Batch Name";
                // MIP-Felder setzen
                GenJnlLine."MIP Import Setup Code" := SetupHeader.Code;
                GenJnlLine."MIP Import File Entry No." := ImportFile."Entry No.";
                GenJnlLine."MIP Import Row No." := DataBuffer."Row No.";
                // Source ID wird später gesetzt

                if SetupColumn.FindSet() then
                    repeat
                        // Quellwert aus JSON extrahieren
                        DataBuffer."Raw Data JSON".CreateInStream(InStream);
                        InStream.Read(JSONText);
                        SourceValue := GetJSONValue(JSONText, SetupColumn."Source Column Name");

                        if (SourceValue = '') and SetupColumn."Skip Empty" then
                            continue;

                        if SourceValue = '' then
                            TargetValue := SetupColumn."Default Value"
                        else
                            case SetupColumn."Mapping Type" of
                                SetupColumn."Mapping Type"::Direct:
                                    TargetValue := SourceValue;
                                SetupColumn."Mapping Type"::"Value Map":
                                    TargetValue := ApplyValueMap(SetupHeader.Code, SetupColumn."Line No.", SourceValue);
                                SetupColumn."Mapping Type"::"Date Formula":
                                    TargetValue := Format(CalcDate(SourceValue, Today()));
                                SetupColumn."Mapping Type"::Fixed:
                                    TargetValue := SetupColumn."Default Value";
                            end;

                        // Feld setzen und optional validieren
                        SetJournalField(GenJnlLine, SetupColumn."Target Field No.", TargetValue, SetupColumn.Validate);
                    until SetupColumn.Next() = 0;

                GenJnlLine.Validate("Posting Date");
                GenJnlLine.Insert();
                DataBuffer.Status := DataBuffer.Status::Transferred;
                DataBuffer.Modify();
                ImportFile."Lines Processed" += 1;
            until DataBuffer.Next() = 0;

        ImportFile.Modify();
    end;

    /// <summary>
    /// Extrahiert einen Wert aus einem JSON-String.
    /// </summary>
    local procedure GetJSONValue(JSONText: Text; Key: Text): Text
    var
        SearchKey: Text;
        StartPos: Integer;
        EndPos: Integer;
    begin
        SearchKey := '"' + Key + '":"';
        StartPos := JSONText.IndexOf(SearchKey);
        if StartPos = 0 then
            exit('');
        StartPos += StrLen(SearchKey);
        EndPos := JSONText.IndexOf('"', StartPos);
        if EndPos = 0 then
            exit('');
        exit(CopyStr(JSONText, StartPos, EndPos - StartPos));
    end;

    /// <summary>
    /// Wendet Value-Map-Transformation an.
    /// </summary>
    local procedure ApplyValueMap(SetupCode: Code[20]; ColumnLineNo: Integer; SourceValue: Text): Text
    begin
        if ValueMap.Get(SetupCode, ColumnLineNo, SourceValue) then
            exit(ValueMap."Target Value");
        exit(SourceValue);
    end;

    /// <summary>
    /// Setzt ein Feld in der Buchblattzeile und führt optional OnValidate aus.
    /// </summary>
    local procedure SetJournalField(var GenJnlLine: Record "Gen. Journal Line"; FieldNo: Integer; Value: Text; DoValidate: Boolean)
    var
        FieldRef: FieldRef;
    begin
        FieldRef := GenJnlLine.Field(FieldNo);
        FieldRef.Value := Value;
        if DoValidate then
            FieldRef.Validate();
    end;

    /// <summary>
    /// Löscht die Data Buffer-Einträge nach erfolgreichem Import.
    /// </summary>
    local procedure CleanupDataBuffer()
    begin
        DataBuffer.SetRange("Import File Entry No.", ImportFile."Entry No.");
        DataBuffer.DeleteAll();
    end;
}
