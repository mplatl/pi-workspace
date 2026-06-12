// ----------------------------------------------------------------------------
// Interface: MIP Import Parser
// ----------------------------------------------------------------------------
// Vertrag für Datei-Parser-Implementierungen.
// Jeder Parser liest eine Datei und befüllt den Data Buffer mit JSON-Zeilen.
// ----------------------------------------------------------------------------

interface "MIP Import Parser"
{
    /// <summary>
    /// Parst eine Datei und schreibt die extrahierten Zeilen als JSON in den Data Buffer.
    /// </summary>
    /// <param name="ImportFile">Die importierte Datei mit BLOB-Inhalt.</param>
    /// <param name="SetupHeader">Setup-Konfiguration (Encoding, Separator, Header-Erkennung).</param>
    /// <param name="DataBuffer">Ausgabe: gefüllte Data Buffer-Records mit Raw Data JSON.</param>
    procedure Parse(var ImportFile: Record "MIP Import File"; var SetupHeader: Record "MIP Import Setup Header"; var DataBuffer: Record "MIP Import Data Buffer")
    {
    }
}
