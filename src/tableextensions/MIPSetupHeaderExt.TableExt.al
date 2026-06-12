// ----------------------------------------------------------------------------
// TableExtension: MIP Import Setup Header
// ----------------------------------------------------------------------------
// Erweitert den Setup Header um das Feld Parser Format.
// Steuert, welcher Parser (CSV, Excel, XML, …) beim Import verwendet wird.
// ----------------------------------------------------------------------------

tableextension 50004 "MIP SetupHeaderExt" extends "MIP Import Setup Header"
{
    fields
    {
        /// <summary>
        /// Definiert das Datei-Parser-Format für den Import.
        /// Standard: CSV.
        /// </summary>
        field(50000; "Parser Format"; Enum "MIP Import Parser Type")
        {
            Caption = 'Parser Format';
            DataClassification = CustomerContent;
        }
    }
}
