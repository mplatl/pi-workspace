namespace MPSWIT.Warehouse.Comment;

using Microsoft.Warehouse.Document;

/// <summary>
/// Erweitert den Warenausgangskopf um ein Kommentarfeld für die Übertragung in den Lieferschein.
/// </summary>
tableextension 90100 "WA Comment Whse. Shpt. Hdr." extends "Warehouse Shipment Header"
{
    fields
    {
        /// <summary>
        /// Kommentar, der beim Buchen des Warenausgangs in den Lieferschein übertragen wird.
        /// </summary>
        field(90100; "WA Shipment Comment"; Text[250])
        {
            Caption = 'WA Shipment Comment';
            ToolTip = 'Specifies a comment that will be transferred to the posted sales shipment when the warehouse shipment is posted.';
            DataClassification = CustomerContent;
        }
    }
}
