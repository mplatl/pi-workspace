// ----------------------------------------------------------------------------
// Enum: MIP Import Mapping Type
// ----------------------------------------------------------------------------
// Typ der Wert-Transformation beim Spalten-Mapping.
// Definiert, wie ein Quellwert aus der Import-Datei in das Zielfeld übernommen wird.
// ----------------------------------------------------------------------------

enum 50001 "MIP Import Mapping Type"
{
    Extensible = false;

    /// <summary>
    /// Wert wird direkt aus der Quellspalte übernommen.
    /// </summary>
    value(0; Direct) { Caption = 'Direct'; }

    /// <summary>
    /// Wert wird über Tabelle "MIP Import Column Value Map" transformiert.
    /// </summary>
    value(1; "Value Map") { Caption = 'Value Map'; }

    /// <summary>
    /// Wert wird als Datumsformel interpretiert (z.B. "0D" = heute).
    /// </summary>
    value(2; "Date Formula") { Caption = 'Date Formula'; }

    /// <summary>
    /// Der Default Value wird immer gesetzt, Quellspalte wird ignoriert.
    /// </summary>
    value(3; Fixed) { Caption = 'Fixed'; }
}
