namespace MPSWIT.Sales.History;

using Microsoft.Sales.History;

/// <summary>
/// Erweitert den gebuchten Lieferscheinkopf um ein Kommentarfeld aus dem Warenausgang.
/// </summary>
tableextension 90101 "WA Comment Sales Shpt. Hdr." extends "Sales Shipment Header"
{
    fields
    {
        /// <summary>
        /// Kommentar, der vom Warenausgangskopf beim Buchen in den Lieferschein übertragen wurde.
        /// </summary>
        field(90101; "WA Shipment Comment"; Text[250])
        {
            Caption = 'WA Shipment Comment';
            ToolTip = 'Specifies the comment that was transferred from the warehouse shipment header when posted.';
            DataClassification = CustomerContent;
        }
    }
}
