// ----------------------------------------------------------------------------
// TableExtension: Gen. Journal Line
// ----------------------------------------------------------------------------
// Erweitert die Standard-Buchblattzeile um MIP-Felder für Rückverfolgbarkeit.
// Felder sind in FieldGroups unsichtbar, nur per Personalisierung einblendbar.
// ----------------------------------------------------------------------------

tableextension 50000 "MIP GenJnlLine" extends "Gen. Journal Line"
{
    fields
    {
        /// <summary>
        /// Welches Import-Setup hat diese Zeile erzeugt.
        /// </summary>
        field(50000; "MIP Import Setup Code"; Code[20])
        {
            Caption = 'MIP Setup Code';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Verweis auf den Import-Datei-Eintrag (Quelldatei).
        /// </summary>
        field(50001; "MIP Import File Entry No."; Integer)
        {
            Caption = 'MIP File Entry No.';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Zeilennummer in der Quelldatei.
        /// </summary>
        field(50002; "MIP Import Row No."; Integer)
        {
            Caption = 'MIP Row No.';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Business Key des Quellsatzes (SetupCode|Wert1|Wert2|…).
        /// </summary>
        field(50003; "MIP Import Source ID"; Text[250])
        {
            Caption = 'MIP Source ID';
            DataClassification = CustomerContent;
        }
    }
}
