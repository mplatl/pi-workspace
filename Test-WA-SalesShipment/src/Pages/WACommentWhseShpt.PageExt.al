namespace MPSWIT.Warehouse.Document;

using Microsoft.Warehouse.Document;

/// <summary>
/// Fügt das WA-Kommentarfeld auf der Warenausgangsseite hinzu.
/// </summary>
pageextension 90102 "WA Comment Whse. Shpt." extends "Warehouse Shipment"
{
    layout
    {
        addafter(General)
        {
            group("WA Comment")
            {
                Caption = 'WA Comment';

                field("WA Shipment Comment"; Rec."WA Shipment Comment")
                {
                    Caption = 'WA Shipment Comment';
                    ToolTip = 'Specifies a comment that will be transferred to the posted sales shipment when the warehouse shipment is posted.';
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
