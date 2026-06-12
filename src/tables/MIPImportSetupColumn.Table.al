// ----------------------------------------------------------------------------
// Table: MIP Import Setup Column
// ----------------------------------------------------------------------------
// Spalten-Mapping für ein Import-Setup.
// Definiert, welche Quellspalte auf welches Zielfeld im Buchblatt gemappt wird,
// mit Validate-Steuerung, Wert-Transformation und Business-Key-Definition.
// ----------------------------------------------------------------------------

table 50002 "MIP Import Setup Column"
{
    Caption = 'MIP Import Setup Column';
    DataClassification = CustomerContent;

    fields
    {
        /// <summary>
        /// Verweis auf das Import-Setup.
        /// </summary>
        field(1; "Setup Code"; Code[20])
        {
            Caption = 'Setup Code';
            TableRelation = "MIP Import Setup Header".Code;
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Laufende Zeilennummer innerhalb des Setups.
        /// </summary>
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Name der Spalte in der Quelldatei (z.B. aus CSV-Header-Zeile).
        /// </summary>
        field(3; "Source Column Name"; Text[50])
        {
            Caption = 'Source Column Name';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Spaltenposition in der Quelldatei (1-basiert).
        /// Fallback, wenn Source Column Name nicht gefunden wird.
        /// </summary>
        field(4; "Source Column No."; Integer)
        {
            Caption = 'Source Column No.';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Feldnummer in der Ziel-Tabelle (Buchblattzeile).
        /// </summary>
        field(5; "Target Field No."; Integer)
        {
            Caption = 'Target Field No.';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Anzeigename des Zielfeldes (Read-only, aus FieldRef).
        /// </summary>
        field(6; "Target Field Name"; Text[50])
        {
            Caption = 'Target Field Name';
            Editable = false;
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// OnValidate-Trigger nach Setzen des Wertes ausführen?
        /// </summary>
        field(7; "Validate"; Boolean)
        {
            Caption = 'Validate';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Leere Quellwerte ignorieren (kein Setzen, kein Validate)?
        /// </summary>
        field(8; "Skip Empty"; Boolean)
        {
            Caption = 'Skip Empty';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Fallback-Wert, wenn die Quellspalte leer ist und Skip Empty = false.
        /// </summary>
        field(9; "Default Value"; Text[250])
        {
            Caption = 'Default Value';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Typ der Wert-Transformation (Direct, Value Map, Date Formula, Fixed).
        /// </summary>
        field(10; "Mapping Type"; Enum "MIP Import Mapping Type")
        {
            Caption = 'Mapping Type';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Bedingung für bedingtes Setzen (optional).
        /// Syntax: [Quellspaltenname] = 'Wert' oder [Quellspaltenname] <> ''.
        /// Bei Nichterfüllung wird die Spalte für diese Zeile übersprungen.
        /// </summary>
        field(11; "Condition Expression"; Text[250])
        {
            Caption = 'Condition Expression';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Diese Spalte ist Teil des fachlichen Business Key.
        /// Alle Spalten mit IsBusinessKey = true werden konkateniert
        /// und bilden den eindeutigen Schlüssel für die Datensatz-Dublettenprüfung.
        /// </summary>
        field(12; "Is Business Key"; Boolean)
        {
            Caption = 'Is Business Key';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Setup Code", "Line No.")
        {
            Clustered = true;
        }
    }
}
