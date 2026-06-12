// ----------------------------------------------------------------------------
// Table: MIP Import File
// ----------------------------------------------------------------------------
// Zentrale Ablagetabelle für alle zu importierenden Dateien.
// Quelle der Datei ist kanal-agnostisch (API, Drag & Drop, E-Mail, …).
// ----------------------------------------------------------------------------
// Dubletten-Erkennung über Content Hash (SHA-256):
//   Vor Verarbeitung wird geprüft, ob eine Datei mit gleichem Hash bereits
//   den Status "Processed" hat → dann Status = Skipped.
// ----------------------------------------------------------------------------

table 50000 "MIP Import File"
{
    Caption = 'MIP Import File';
    DataClassification = CustomerContent;

    fields
    {
        /// <summary>
        /// Eindeutige laufende Nummer des Import-Datei-Eintrags.
        /// </summary>
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Verweis auf das Import-Setup, das diese Datei verarbeiten soll.
        /// </summary>
        field(2; "Setup Code"; Code[20])
        {
            Caption = 'Setup Code';
            TableRelation = "MIP Import Setup Header".Code;
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Original-Dateiname zur Anzeige.
        /// </summary>
        field(3; "File Name"; Text[250])
        {
            Caption = 'File Name';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Dateiendung (.csv, .txt) zur Format-Erkennung.
        /// </summary>
        field(4; "File Extension"; Text[10])
        {
            Caption = 'File Extension';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Binärer Dateiinhalt (BLOB).
        /// </summary>
        field(5; "File Content"; BLOB)
        {
            Caption = 'File Content';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// SHA-256-Hash des Dateiinhalts zur Dubletten-Erkennung.
        /// Wird beim Upload berechnet.
        /// </summary>
        field(6; "Content Hash"; Text[64])
        {
            Caption = 'Content Hash';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Verarbeitungsstatus der Datei.
        /// </summary>
        field(7; "Status"; Enum "MIP Import File Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Gesamtanzahl der Zeilen in der Datei.
        /// </summary>
        field(8; "Lines Total"; Integer)
        {
            Caption = 'Lines Total';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Anzahl erfolgreich verarbeiteter Zeilen.
        /// </summary>
        field(9; "Lines Processed"; Integer)
        {
            Caption = 'Lines Processed';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Anzahl Zeilen mit Fehler.
        /// </summary>
        field(10; "Lines Error"; Integer)
        {
            Caption = 'Lines Error';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Globaler Fehlertext (z.B. bei Hash-Dublette).
        /// </summary>
        field(11; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Zeitpunkt des Uploads.
        /// </summary>
        field(12; "Uploaded At"; DateTime)
        {
            Caption = 'Uploaded At';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Zeitpunkt der Verarbeitung.
        /// </summary>
        field(13; "Processed At"; DateTime)
        {
            Caption = 'Processed At';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Benutzer, der die Datei hochgeladen hat.
        /// </summary>
        field(14; "Uploaded By"; Guid)
        {
            Caption = 'Uploaded By';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "File Name", "Status")
        {
            Caption = 'DropDown';
        }

        fieldgroup(Brick; "Setup Code", "Lines Processed", "Lines Error")
        {
            Caption = 'Brick';
        }
    }
}
