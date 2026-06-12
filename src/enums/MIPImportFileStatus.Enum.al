// ----------------------------------------------------------------------------
// Enum: MIP Import File Status
// ----------------------------------------------------------------------------
// Status der Import-Datei in der Tabelle "MIP Import File".
// ----------------------------------------------------------------------------

enum 50000 "MIP Import File Status"
{
    Extensible = false;

    /// <summary>
    /// Datei wurde hochgeladen, aber noch nicht verarbeitet.
    /// </summary>
    value(0; "Pending") { Caption = 'Pending'; }

    /// <summary>
    /// Datei wird gerade verarbeitet.
    /// </summary>
    value(1; "Processing") { Caption = 'Processing'; }

    /// <summary>
    /// Datei wurde erfolgreich verarbeitet und gebucht.
    /// </summary>
    value(2; "Processed") { Caption = 'Processed'; }

    /// <summary>
    /// Fehler bei der Verarbeitung (z.B. ungültige Daten).
    /// </summary>
    value(3; "Error") { Caption = 'Error'; }

    /// <summary>
    /// Datei wurde wegen Dublette übersprungen (Content Hash bereits vorhanden).
    /// </summary>
    value(4; "Skipped") { Caption = 'Skipped'; }
}
