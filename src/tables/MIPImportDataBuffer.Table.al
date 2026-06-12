// ----------------------------------------------------------------------------
// Table: MIP Import Data Buffer
// ----------------------------------------------------------------------------
// Temporäre Tabelle für die Rohdaten einer Import-Datei.
// Speichert die geparsten Zeilen als JSON pro Quellzeile.
// Wird nach erfolgreichem Import geleert.
// ----------------------------------------------------------------------------

table 50004 "MIP Import Data Buffer"
{
    Caption = 'MIP Import Data Buffer';
    DataClassification = CustomerContent;
    Temporary = true;

    fields
    {
        /// <summary>
        /// Verweis auf den Import-Datei-Eintrag.
        /// </summary>
        field(1; "Import File Entry No."; Integer)
        {
            Caption = 'Import File Entry No.';
            TableRelation = "MIP Import File"."Entry No.";
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Zeilennummer in der Quelldatei.
        /// </summary>
        field(2; "Row No."; Integer)
        {
            Caption = 'Row No.';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Alle Spaltenwerte der Zeile als JSON ({"SpalteA":"Wert",…}).
        /// </summary>
        field(3; "Raw Data JSON"; BLOB)
        {
            Caption = 'Raw Data JSON';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Verarbeitungsstatus der Zeile.
        /// </summary>
        field(4; "Status"; Option)
        {
            Caption = 'Status';
            OptionMembers = "Pending", "Validated", "Error", "Transferred";
            OptionCaption = 'Pending,Validated,Error,Transferred';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Fehlertext bei Validate-Fehler.
        /// </summary>
        field(5; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Import File Entry No.", "Row No.")
        {
            Clustered = true;
        }
    }
}
