// ----------------------------------------------------------------------------
// Table: MIP Import Setup Header
// ----------------------------------------------------------------------------
// Kopf der Import-Setup-Konfiguration.
// Definiert, wie eine Import-Datei verarbeitet wird: Ziel-Buchblatt,
// Dateiformat-Einstellungen, Buchungsoptionen.
// ----------------------------------------------------------------------------

table 50001 "MIP Import Setup Header"
{
    Caption = 'MIP Import Setup Header';
    DataClassification = CustomerContent;

    fields
    {
        /// <summary>
        /// Eindeutiger Code des Import-Setups.
        /// </summary>
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }

        /// <summary>
        /// Bezeichnung des Import-Setups.
        /// </summary>
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Buchblattvorlagenname (optional).
        /// Wenn leer, muss das Mapping pro Zeile das Buchblatt bestimmen.
        /// </summary>
        field(3; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Gen. Journal Template"."Name";
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Buchblattname (optional).
        /// Wenn leer, muss das Mapping pro Zeile das Buchblatt bestimmen.
        /// </summary>
        field(4; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Gen. Journal Batch"."Name";
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Encoding der Quelldatei.
        /// </summary>
        field(5; "File Encoding"; Option)
        {
            Caption = 'File Encoding';
            OptionMembers = "UTF-8", "ANSI", "UTF-16";
            OptionCaption = 'UTF-8,ANSI,UTF-16';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Spalten-Trennzeichen in der CSV-Datei.
        /// </summary>
        field(6; "Column Separator"; Text[5])
        {
            Caption = 'Column Separator';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Gibt an, ob die erste Zeile der Datei Spaltenüberschriften enthält.
        /// </summary>
        field(7; "First Row Is Header"; Boolean)
        {
            Caption = 'First Row Is Header';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Nach erfolgreichem Import automatisch buchen?
        /// </summary>
        field(8; "Auto Post"; Boolean)
        {
            Caption = 'Auto Post';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Datumsformel für das Buchungsdatum (z.B. "0D" = heute, "1W" = nächste Woche).
        /// </summary>
        field(9; "Posting Date Formula"; Text[20])
        {
            Caption = 'Posting Date Formula';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Nummernserie für die Belegnummer (optional).
        /// </summary>
        field(10; "Document No. Series"; Code[10])
        {
            Caption = 'Document No. Series';
            TableRelation = "No. Series"."Code";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", "Description")
        {
            Caption = 'DropDown';
        }

        fieldgroup(Brick; "Journal Template Name", "Journal Batch Name")
        {
            Caption = 'Brick';
        }
    }
}
