namespace MPSWIT.Warehouse.Posting;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using Microsoft.Warehouse.Document;

/// <summary>
/// Überträgt den WA-Kommentar vom Warenausgangskopf in den gebuchten Lieferschein.
/// Nutzt das OnBeforeUpdateWhseDocuments-Event in Sales-Post, das feuert NACHDEM
/// der gebuchte Lieferschein erstellt wurde, aber BEVOR der Warenausgangskopf
/// durch PostUpdateWhseDocuments gelöscht wird.
/// </summary>
codeunit 90104 "WA Comment Transfer"
{
    /// <summary>
    /// Wird während Sales-Post ausgelöst, nachdem der gebuchte Lieferschein erstellt
    /// wurde (Last Shipping No. ist gesetzt) aber bevor PostUpdateWhseDocuments
    /// den Warenausgangskopf löscht. Überträgt den Kommentar.
    /// </summary>
    /// <param name="SalesHeader">Der Verkaufskopf mit gesetzter Last Shipping No.</param>
    /// <param name="IsHandled">Wird nicht modifiziert.</param>
    /// <param name="WhseReceive">Warenzugang-Flag.</param>
    /// <param name="WhseShip">Warenausgang-Flag.</param>
    /// <param name="WhseRcptHeader">Warenzugangskopf.</param>
    /// <param name="WhseShptHeader">Warenausgangskopf MIT Kommentar.</param>
    /// <param name="TempWhseRcptHeader">Temporärer Warenzugangskopf.</param>
    /// <param name="TempWhseShptHeader">Temporärer Warenausgangskopf.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeUpdateWhseDocuments', '', false, false)]
    local procedure TransferCommentToSalesShipment(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean; WhseReceive: Boolean; WhseShip: Boolean; WhseRcptHeader: Record "Warehouse Receipt Header"; WhseShptHeader: Record "Warehouse Shipment Header"; var TempWhseRcptHeader: Record "Warehouse Receipt Header" temporary; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary)
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        // Nur bei Warenausgang und wenn ein Kommentar vorhanden ist
        if not WhseShip then
            exit;

        if WhseShptHeader."WA Shipment Comment" = '' then
            exit;

        // Last Shipping No. ist zu diesem Zeitpunkt gesetzt
        if SalesHeader."Last Shipping No." = '' then
            exit;

        // Gebuchten Lieferschein laden
        if not SalesShipmentHeader.Get(SalesHeader."Last Shipping No.") then
            exit;

        // Kommentar übertragen
        SalesShipmentHeader."WA Shipment Comment" := WhseShptHeader."WA Shipment Comment";
        SalesShipmentHeader.Modify(true);
    end;
}
