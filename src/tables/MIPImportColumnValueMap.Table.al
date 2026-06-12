// ----------------------------------------------------------------------------
// Table: MIP Import Column Value Map
// ----------------------------------------------------------------------------
// Wert-Transformationen pro Setup-Spalte.
// Ermöglicht die Abbildung von Quellwerten auf Zielwerte
// (z.B. "Istmeldung" → "1", "Verbrauch" → "0").
// ----------------------------------------------------------------------------

table 50003 "MIP Import Column Value Map"
{
    Caption = 'MIP Import Column Value Map';
    DataClassification = CustomerContent;

    fields
    {
        /// <summary>
        /// Verweis auf das Import-Setup.
        /// </summary>
        field(1; "Setup Code"; Code[20])
        {
            Caption = 'Setup Code';
            TableRelation = "MIP Import Setup Header"."Code";
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Verweis auf die Setup-Spalte.
        /// </summary>
        field(2; "Column Line No."; Integer)
        {
            Caption = 'Column Line No.';
            TableRelation = "MIP Import Setup Column"."Line No."
                            where("Setup Code" = field("Setup Code"));
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Wert aus der Quelldatei (z.B. "Istmeldung").
        /// </summary>
        field(3; "Source Value"; Text[100])
        {
            Caption = 'Source Value';
            DataClassification = CustomerContent;
        }

        /// <summary>
        /// Zielwert im Buchblatt (z.B. "1").
        /// </summary>
        field(4; "Target Value"; Text[100])
        {
            Caption = 'Target Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Setup Code", "Column Line No.", "Source Value")
        {
            Clustered = true;
        }
    }
}
