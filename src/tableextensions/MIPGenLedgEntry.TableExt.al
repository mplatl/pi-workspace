// ----------------------------------------------------------------------------
// TableExtension: Gen. Ledger Entry
// ----------------------------------------------------------------------------
// Erweitert den gebuchten Sachposten um MIP-Felder für Rückverfolgbarkeit.
// Wird beim Buchen aus Gen. Journal Line übertragen (via Event-Subscription).
// ----------------------------------------------------------------------------

tableextension 50001 "MIP GenLedgEntry" extends "G/L Entry"
{
    fields
    {
        field(50000; "MIP Import Setup Code"; Code[20])
        {
            Caption = 'MIP Setup Code';
            DataClassification = CustomerContent;
        }

        field(50001; "MIP Import File Entry No."; Integer)
        {
            Caption = 'MIP File Entry No.';
            DataClassification = CustomerContent;
        }

        field(50002; "MIP Import Row No."; Integer)
        {
            Caption = 'MIP Row No.';
            DataClassification = CustomerContent;
        }

        field(50003; "MIP Import Source ID"; Text[250])
        {
            Caption = 'MIP Source ID';
            DataClassification = CustomerContent;
        }
    }
}
