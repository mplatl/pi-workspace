// ----------------------------------------------------------------------------
// TableExtension: Item Ledger Entry
// ----------------------------------------------------------------------------
// Erweitert den Artikelposten um MIP-Felder für Rückverfolgbarkeit.
// Wird beim Buchen aus Item Journal Line übertragen (via Event-Subscription).
// ----------------------------------------------------------------------------

tableextension 50003 "MIP ItemLedgEntry" extends "Item Ledger Entry"
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
