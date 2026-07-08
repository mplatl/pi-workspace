# GAR.Base Analyse: Warum der Kommentar-Transfer nicht funktioniert

> Bezug: Test-WA-SalesShipment (WA-Kommentar vom Warenausgangskopf → Lieferschein)

---

## 1. Fehlendes Feld auf Warehouse Shipment Header

**Datei:** `Garant Base/src/tableextension/50218.GARWarehouseShipmentHeader.TableExt.al`

```al
tableextension 50218 "GAR Warehouse Shipment Header" extends "Warehouse Shipment Header"
{
    fields
    {
        // Info: moved to ESA APP 
        // field(50005; "GAR Client ID"; Text[50])  ← AUSKOMMENTIERT, kein Kommentarfeld
    }
}
```

Es gibt **kein** Feld auf dem Warenausgangskopf, das transferiert werden könnte.

---

## 2. "GAR Delivery Comment" existiert nur auf Sales Shipment Header

**Datei:** `Garant Base/src/tableextension/50101.GARSalesShipmentHeader.TableExt.al`

```al
field(50021; "GAR Delivery Comment"; Text[100])
{
    Caption = 'Lieferbemerkung';
}
```

Dieses Feld wird beim Erstellen der Rechnungszeilen **gelesen** (Zeile 1838 in `50053.GARSalesOrderManagement.Codeunit.al`), aber **nie** beim Buchen aus dem Warenausgang befüllt.

---

## 3. Kein Event-Subscriber für den Transfer WhseShptHeader → SalesShptHeader

**Datei:** `Garant Base/src/codeunit/50053.GARSalesOrderManagement.Codeunit.al`

In dieser Codeunit gibt es zahlreiche Event-Subscriber auf `Sales-Post`, aber **keiner** überträgt Daten von `WhseShptHeader` nach `SalesShptHeader`.

Der einzige vorhandene Transfer (Zeile 1695) kopiert vom **SalesHeader** (nicht WhseShptHeader):
```al
[EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeSalesShptHeaderInsert, ...)]
local procedure cuSalesPost_OnBeforeSalesShptHeaderInsert(...)
begin
    SalesShptHeader."GAR Shipping Text" := SalesHeader."GAR Shipping Text";
    //                                 ↑ SalesHeader, NICHT WhseShptHeader
end;
```

---

## 4. ESA-Processing löscht den Warenausgangskopf sofort nach dem Buchen

**Datei:** `Garant Base/src/codeunit/50023.ESAWhseProcessing.Codeunit.al`

```al
procedure PostWhseShipment(NewClientID: Text[50]; NewESAID: Integer)
begin
    ...
    WhsePostShipment.Run(WhseShptLine);       // buchen
    ...
    WhseShptHeader2.DeleteAll(true);          // Header SOFORT löschen
end;
```

Jeder Event-Subscriber, der **nach** dem Buchen (`OnAfterSalesPost`) den Warehouse Shipment Header lesen will, findet ihn nicht mehr — der Header wurde bereits durch `PostUpdateWhseDocuments` in `Sales-Post` gelöscht.

---

## Was müsste in GAR.Base geändert werden

| Schritt | Datei | Beschreibung |
|---|---|---|
| 1 | `tableextension/50218.GARWarehouseShipmentHeader.TableExt.al` | Feld `"GAR Delivery Comment"` zum Warenausgangskopf hinzufügen |
| 2 | `pageextension/...` (neu oder bestehend) | PageExtension für Warenausgang-Seite, Feld im UI sichtbar machen |
| 3 | `codeunit/50053.GARSalesOrderManagement.Codeunit.al` | Neuen Event-Subscriber auf `Sales-Post.OnBeforeUpdateWhseDocuments` |

### Event-Subscriber (analog zu Test-WA-SalesShipment)

```al
[EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeUpdateWhseDocuments', '', false, false)]
local procedure TransferDeliveryCommentToSalesShipment(
    var SalesHeader: Record "Sales Header";
    var IsHandled: Boolean;
    WhseReceive: Boolean;
    WhseShip: Boolean;
    WhseRcptHeader: Record "Warehouse Receipt Header";
    WhseShptHeader: Record "Warehouse Shipment Header";
    var TempWhseRcptHeader: Record "Warehouse Receipt Header" temporary;
    var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary)
var
    SalesShipmentHeader: Record "Sales Shipment Header";
begin
    if not WhseShip then
        exit;

    if WhseShptHeader."GAR Delivery Comment" = '' then
        exit;

    if SalesHeader."Last Shipping No." = '' then
        exit;

    if not SalesShipmentHeader.Get(SalesHeader."Last Shipping No.") then
        exit;

    SalesShipmentHeader."GAR Delivery Comment" := WhseShptHeader."GAR Delivery Comment";
    SalesShipmentHeader.Modify(true);
end;
```

### Warum `OnBeforeUpdateWhseDocuments` und nicht `OnAfterSalesPost`?

`Sales-Post` ruft `PostUpdateWhseDocuments` auf, das den Warehouse Shipment Header löscht, **bevor** `OnAfterSalesPost` feuert. `OnBeforeUpdateWhseDocuments` wird dagegen aufgerufen, **nachdem** der Lieferschein erstellt wurde (`Last Shipping No.` ist gesetzt) aber **bevor** der Warenausgangskopf gelöscht wird.

---

## In Test-WA-SalesShipment funktioniert es (Nachweis)

```
=== Results (1s) ===
1 total, 1 passed, 0 failed, 0 skipped   ✅
```

Getestet in BC 28.2 OnPrem Container mit Application Test Toolkit.
