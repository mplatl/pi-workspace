// ----------------------------------------------------------------------------
// Enum: MIP Import Parser Type
// ----------------------------------------------------------------------------
// Definiert die verfügbaren Datei-Parser-Implementierungen.
// Jeder Wert ist über Implementation mit einer Parser-Codeunit verknüpft.
// Extensible = true → Partner können eigene Parser ergänzen.
// ----------------------------------------------------------------------------

enum 50002 "MIP Import Parser Type"
{
    Extensible = true;

    /// <summary>
    /// CSV-Parser mit konfigurierbarem Separator.
    /// </summary>
    value(0; CSV)
    {
        Implementation = "MIP Import Parser" = "MIP CSV Parser";
    }
}
