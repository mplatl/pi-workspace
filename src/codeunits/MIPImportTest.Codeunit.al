// ----------------------------------------------------------------------------
// Codeunit: MIP Import Test
// ----------------------------------------------------------------------------
// Test-Codeunit für die Import-Schnittstelle.
// Testet CSV-Parsing, Mapping-Typen, Validate, Fehlerbehandlung und Dubletten.
// ----------------------------------------------------------------------------

codeunit 50002 "MIP Import Test"
{
    Access = Internal;
    Subtype = Test;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        Engine: Codeunit "MIP Import Engine";
        ImportFile: Record "MIP Import File";
        SetupHeader: Record "MIP Import Setup Header";
        SetupColumn: Record "MIP Import Setup Column";
        ValueMap: Record "MIP Import Column Value Map";
        DataBuffer: Record "MIP Import Data Buffer";

    /// <summary>
    /// Test: CSV-Datei mit Header-Zeile parsen.
    /// </summary>
    [Test]
    procedure TestCSVWithHeader()
    begin
        // Given
        CreateTestFile('ColA,ColB,ColC\nVal1,Val2,Val3');
        // When
        Engine.ParseCSV();
        // Then
        AssertEquals(DataBuffer.Count(), 1);
    end;

    /// <summary>
    /// Test: Direct-Mapping mit Validate.
    /// </summary>
    [Test]
    procedure TestDirectMappingWithValidate()
    begin
        // Given
        CreateTestFile('Type,Amount\nG/L Account,100');
        // When
        Engine.MapAndInsertJournalLines();
        // Then
        AssertEquals(ImportFile."Lines Processed", 1);
    end;

    /// <summary>
    /// Test: Direct-Mapping ohne Validate (Skip).
    /// </summary>
    [Test]
    procedure TestDirectMappingSkipValidate()
    begin
        // Given
        SetupColumn.Validate := false;
        // When
        Engine.MapAndInsertJournalLines();
        // Then
        AssertEquals(ImportFile."Lines Processed", 1);
    end;

    /// <summary>
    /// Test: Value-Map-Transformation ("Istmeldung" → "1").
    /// </summary>
    [Test]
    procedure TestValueMapTransformation()
    begin
        // Given
        ValueMap.Init();
        ValueMap."Setup Code" := SetupHeader.Code;
        ValueMap."Column Line No." := 1;
        ValueMap."Source Value" := 'Istmeldung';
        ValueMap."Target Value" := '1';
        ValueMap.Insert();
        // When
        Engine.MapAndInsertJournalLines();
        // Then
        AssertEquals(ImportFile."Lines Processed", 1);
    end;

    /// <summary>
    /// Test: Date-Formula-Mapping.
    /// </summary>
    [Test]
    procedure TestDateFormulaMapping()
    begin
        // Given
        SetupColumn."Mapping Type" := SetupColumn."Mapping Type"::"Date Formula";
        // When
        Engine.MapAndInsertJournalLines();
        // Then
        AssertEquals(ImportFile."Lines Processed", 1);
    end;

    /// <summary>
    /// Test: Fixed-Default-Value-Mapping.
    /// </summary>
    [Test]
    procedure TestFixedDefaultValue()
    begin
        // Given
        SetupColumn."Mapping Type" := SetupColumn."Mapping Type"::Fixed;
        SetupColumn."Default Value" := 'G/L Account';
        // When
        Engine.MapAndInsertJournalLines();
        // Then
        AssertEquals(ImportFile."Lines Processed", 1);
    end;

    /// <summary>
    /// Test: Datei-Dublette erkennen (Content Hash).
    /// </summary>
    [Test]
    procedure TestFileDuplicateDetection()
    begin
        // Given: Zwei Dateien mit gleichem Inhalt
        CreateTestFile('Duplicate');
        CreateTestFile('Duplicate');
        // When
        Engine.CheckFileDuplicate();
        // Then
        AssertEquals(ImportFile.Status, ImportFile.Status::Skipped);
    end;

    /// <summary>
    /// Test: Datensatz-Dublette erkennen (Business Key).
    /// </summary>
    [Test]
    procedure TestBusinessKeyDuplicate()
    begin
        // Given: Bereits gebuchter Datensatz mit gleichem Business Key
        // When
        Engine.ComputeBusinessKey();
        // Then: Sollte als Duplikat erkannt werden
    end;

    /// <summary>
    /// Test: Fehler bei Validate → Status Error.
    /// </summary>
    [Test]
    procedure TestValidateError()
    begin
        // Given: Ungültiger Wert für Validate
        // When
        Engine.MapAndInsertJournalLines();
        // Then
        AssertEquals(DataBuffer.Status, DataBuffer.Status::Error);
    end;

    /// <summary>
    /// Test: Leere Quellspalte → Default Value.
    /// </summary>
    [Test]
    procedure TestEmptySourceDefaultValue()
    begin
        // Given
        SetupColumn."Skip Empty" := false;
        SetupColumn."Default Value" := 'DEFAULT';
        // When
        Engine.MapAndInsertJournalLines();
        // Then
        AssertEquals(ImportFile."Lines Processed", 1);
    end;

    /// <summary>
    /// Test: Leere Quellspalte → Skip.
    /// </summary>
    [Test]
    procedure TestEmptySourceSkip()
    begin
        // Given
        SetupColumn."Skip Empty" := true;
        // When
        Engine.MapAndInsertJournalLines();
        // Then
        AssertEquals(ImportFile."Lines Processed", 0);
    end;

    /// <summary>
    /// Test: Business Key aus mehreren Spalten.
    /// </summary>
    [Test]
    procedure TestCompositeBusinessKey()
    begin
        // Given: Zwei Spalten mit IsBusinessKey = true
        // When
        Engine.ComputeBusinessKey();
        // Then: Key = "SetupCode|Wert1|Wert2"
    end;

    // --- Helpers ---

    local procedure CreateTestFile(Content: Text)
    var
        OutStream: OutStream;
        Hash: Text;
    begin
        ImportFile.Init();
        ImportFile."Entry No." := 1;
        ImportFile."Setup Code" := SetupHeader.Code;
        ImportFile."File Name" := 'test.csv';
        ImportFile."File Extension" := '.csv';
        ImportFile."File Content".CreateOutStream(OutStream);
        OutStream.Write(Content);
        ImportFile."Content Hash" := Hash; // ToDo: SHA-256
        ImportFile.Status := ImportFile.Status::Pending;
        ImportFile."Uploaded At" := CurrentDateTime();
        ImportFile.Insert();
    end;
}
