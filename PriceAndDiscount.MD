# GAR.Base — Preis- und Rabattlogik (Price & Discount)

> **Repository:** `GAR.Base` (`/home/michael/work/GAR.Base`)  
> **Kernmodul:** `Garant Base/src/pricing/`  
> **Stand:** BC28.1, GAR.Base (Garant-Preisfindung)

---

## 1. Übersicht

Das GAR.Base Pricing-Modul erweitert die Standard-Preisfindung von Microsoft Dynamics 365 Business Central um eine **prioritätsbasierte Preiskalkulation** namens *„GAR Priority"*. Es führt neue **Preis-Asset-Typen**, neue **Preis-Quelltypen** und eine **Preisherkunfts-Archivierung** ein.

### Kernkonzepte auf einen Blick

| Konzept | Beschreibung |
|---------|-------------|
| **GAR Priority** | Neue `Price Calculation Method` — priorisiert Preisquellen hierarchisch (Contact → Ship-to → Customer → Cust.PriceGrp → All) |
| **Bulk Group** | Mengenrabatt über alle Artikelpositionen einer Bulk-Gruppe im gesamten Beleg |
| **Discount Code** | Benannte Rabattcodes mit absolutem Einheitsrabatt (`GAR Unit Discount`) |
| **Procurement Method** | Rabatt basierend auf der Beschaffungsmethode des Artikels |
| **Ship-to Address** | Preisquelle auf Lieferadressen-Ebene (feiner als Kunde) |
| **Price Origin** | Vollständige Preisherkunftsnachverfolgung pro gebuchter Zeile |
| **GAR Reference** | Neuer `Price Amount Type` für Referenzlinien auf Rabattcodes |

---

## 2. Architektur

### 2.1 Dateistruktur

```
Garant Base/src/pricing/
├── codeunit/
│   ├── 50038.GARSalesPriceEvents.Codeunit.al     ← Event-Subscriber (Hauptintegration)
│   ├── 50108.GARPABulkGroup.Codeunit.al           ← Price Asset: Bulk Group
│   ├── 50109.GARPADiscountCode.Codeunit.al        ← Price Asset: Discount Code
│   ├── 50110.GARPAProcurement.Codeunit.al         ← Price Asset: Procurement Method
│   ├── 50111.GARPMPriority.Codeunit.al            ← Priority-Source-Hierarchie
│   ├── 50112.GARPSShiptoAddress.Codeunit.al       ← Price Source: Ship-to Address
│   ├── 50113.GARPCGarant.Codeunit.al              ← Price Calculation: Garant (Haupt-Calc)
│   ├── 50114.GARDiscountCodeMgt.Codeunit.al       ← Rabattcode-Verwaltung
│   ├── 50115.GARPriceHelperGarant.Codeunit.al     ← Hilfsfunktionen
│   ├── 50116.GARPriceOriginMgt.Codeunit.al        ← Preisherkunfts-Manager
│   └── 50117.GARSalesInvoiceLinePrice.Codeunit.al ← LineWithPrice für geb. Rechnungen
├── enum/
│   └── 50016.GARSpecialPrice.Enum.al              ← Special Price Stati
├── enumextension/
│   ├── 50002.GARPriceCalculationMethod.EnumExt.al
│   ├── 50003.GARPriceSourceType.EnumExt.al
│   ├── 50004.GARSalesPriceSourceType.EnumExt.al
│   ├── 50005.GARPriceAssetType.EnumExt.al
│   ├── 50007.GARPriceCalculationHandler.EnumExt.al
│   └── 50009.GARPriceAmountType.EnumExt.al
├── table/
│   ├── 50009.GARDiscountCode.Table.al
│   ├── 50012.GARSalesPriceReduction.Table.al      ← Pending Obsolete
│   ├── 50014.GARBulkDiscount.Table.al             ← Pending Obsolete
│   ├── 50018.SalesPriceOrigin.Table.al            ← Pending Obsolete
│   ├── 50019.PostedSalesPriceOrigin.Table.al      ← Pending Obsolete
│   ├── 50047.GARPriceReductionSetup.Table.al      ← Pending Obsolete
│   ├── 50074.GARPriceOriginLine.Table.al          ← Aktive Preisherkunft
│   └── 50076.GARPriceUpdateLine.Table.al
├── tableextension/
│   ├── 50248.GARPriceListLine.TableExt.al         ← Erweiterung Price List Line
│   ├── 50249.GARPriceCalculationBuffer.TableExt.al ← Erweiterung Calc Buffer
│   └── 50250.GARPriceSource.TableExt.al           ← Erweiterung Price Source
├── page/   (14 Pages)
├── query/  (2 Queries)
└── report/ (4 Reports)
```

### 2.2 Zusammenspiel der Codeunits

```
┌──────────────────────────────────────────────────────────┐
│                  GAR Sales Price Events (50038)           │
│              Event-Subscriber in Standard-BC-Events       │
└──────┬───────────────────────────────────────┬───────────┘
       │ füllt Buffer                          │ reagiert auf
       ▼                                       │ Posting
┌──────────────────────┐              ┌──────────────────────┐
│  Price Calculation   │              │  GAR Price Origin    │
│  Buffer (extended)   │              │  Mgt. (50116)        │
└──────┬───────────────┘              └──────────────────────┘
       │ verwendet                        │ erzeugt
       ▼                                  ▼
┌──────────────────────┐         ┌──────────────────────┐
│  GAR PC - Garant     │         │  GAR Price Origin    │
│  (50113)             │         │  Line (50074)        │
│  implements          │         └──────────────────────┘
│  Price Calculation   │
└──────┬───────────────┘
       │ delegiert an
       ▼
┌──────────────────────┐
│  Price Calculation   │
│  - V16 (Standard)    │
└──────────────────────┘
```

---

## 3. Enum-Erweiterungen (neue Werte)

### 3.1 `Price Calculation Method` → „GAR Priority" (50000)

```al
enumextension 50002 "GAR Price Calculation Method" extends "Price Calculation Method"
{
    value(50000; "GAR Priority") { Caption = 'Priority'; }
}
```

Die Priority-Methode priorisiert Preisquellen nach einer festen Hierarchie (nicht wie Standard nach niedrigstem Preis).

### 3.2 `Price Amount Type` → „GAR Reference" (50000)

```al
enumextension 50009 "GAR Price Amount Type" extends "Price Amount Type"
{
    value(50000; "GAR Reference") { Caption = 'Reference'; }
}
```

Neuer Betragstyp für Referenzlinien — verweist auf einen Rabattcode (`GAR Discount Code`), ohne selbst einen Preis/Rabatt zu definieren.

### 3.3 `Price Asset Type` → Bulk Group, Discount Code, Procurement Method

```al
enumextension 50005 "GAR Price Asset Type" extends "Price Asset Type"
{
    value(50000; "GAR Bulk Group")        { Caption = 'Bulk Group'; }
    value(50001; "GAR Discount Code")     { Caption = 'Discount Code'; }
    value(50002; "GAR Procurement Method"){ Caption = 'Procurement Method'; }
}
```

### 3.4 `Price Source Type` → „GAR Ship-to Address" (50000)

```al
enumextension 50003 "GAR Price Source Type" extends "Price Source Type"
{
    value(50000; "GAR Ship-to Address")
    {
        Caption = 'Ship-to Address';
        Implementation = "Price Source" = "GAR PS - Ship-to Address";
    }
}
```

### 3.5 `Price Calculation Handler` → „Garant" (50113)

```al
enumextension 50007 "GAR Price Calculation Handler" extends "Price Calculation Handler"
{
    value(50113; "GAR Garant")
    {
        Caption = 'Garant';
        Implementation = "Price Calculation" = "GAR PC - Garant";
    }
}
```

### 3.6 `GAR Special Price` (Eigenes Enum)

```al
enum 50016 "GAR Special Price"
{
    value(0; " ")                    { Caption = ''; }
    value(1; "Special Price")        { Caption = 'Special Price'; }
    value(2; "Customer Special Price"){ Caption = 'Customer Special Price'; }
}
```

- **Special Price**: Preis stammt nicht von „All Customers" (d.h. individuell)
- **Customer Special Price**: Preis stammt direkt von einer Kunden-Preisquelle

---

## 4. Datenmodell

### 4.1 `Price Calculation Buffer` – GAR-Erweiterungen

Die Tabelle `Price Calculation Buffer` wird um folgende Felder erweitert (TableExtension 50249):

| Feld | Typ | Beschreibung |
|------|-----|-------------|
| `GAR Responsibility Center` | Code[10] | Filtert Preise nach Verantwortungscenter |
| `GAR Discount Code` | Code[10] | Zugewiesener Rabattcode |
| `GAR Unit Discount` | Decimal | Absoluter Einheitsrabatt |
| `GAR Fixed Price` | Boolean | Manuell fixierter Preis (keine Neuberechnung) |
| `GAR Bulk Group Code` | Code[10] | Bulk-Rabattgruppe |
| `GAR Procurement Method` | Enum | Beschaffungsmethode |
| `GAR Allow Proc. Discount` | Boolean | Beschaffungsrabatt erlaubt? |
| `GAR Allow Discount Code` | Boolean | Rabattcode erlaubt? |
| `GAR Custom Discount Code` | Boolean | Manueller Rabattcode-Betrag |
| `GAR Allow Bulk Discount` | Boolean | Bulk-Rabatt erlaubt? |
| `GAR Total Asset Qty.` | Decimal | Gesamtmenge des Artikels im Beleg (für Procurement) |
| `GAR Total Group Qty.` | Decimal | Gesamtmenge aller Bulk-Artikel im Beleg (für Bulk) |
| `GAR Discount Code Amount` | Decimal | Manueller Rabattcode-Betrag |

### 4.2 `Price List Line` – GAR-Erweiterungen

Die Tabelle `Price List Line` wird erweitert (TableExtension 50248):

| Feld | Typ | Beschreibung |
|------|-----|-------------|
| `GAR Responsibility Center` | Code[10] | Verantwortungscenter |
| `GAR Recommended Unit Price` | Decimal | Empfohlener VK-Preis (VK-Empf.) |
| `GAR Bulk Group Code` | Code[10] | Bulk-Gruppe |
| `GAR Unit Discount` | Decimal | Absoluter Einheitsrabatt (€) |
| `GAR Reference Asset No.` | Code[10] | Referenz auf Rabattcode |
| `GAR Closed At` | DateTime | Zeitpunkt der Schließung (Ending Date gesetzt) |
| `GAR Closed By` | Code[50] | Benutzer der Schließung |
| `GAR Closed Automatically` | Boolean | Automatisch geschlossen? |
| `GAR Transferred` | Boolean | Übertragen-Flag |

### 4.3 `GAR Discount Code` (Tabelle 50009)

```
Felder:
  - Code (PK), Description
  - Manual Reduction:    Boolean  (Default für manuelle Rabattzuweisung)
  - Autom. Reduction:    Boolean  (Nur automatisch zuweisbar)
  - Item Type:           Enum GAR Item Type
```

### 4.4 `GAR Price Origin Line` (Tabelle 50074)

Archiviert die komplette Preisherkunft für jede gebuchte Verkaufsrechnungszeile:

```
Felder u.a.:
  - Document Type/No./Line No.  (Verknüpfung zur gebuchten Zeile)
  - Price List Code, Origin Line No.  (Ursprungs-Preislistenposition)
  - Asset Type, Asset No.       (Artikel-Info)
  - Source Type, Source No.     (Preisquelle)
  - Unit Price, Unit Discount   (Beträge)
  - GAR Special Price, GAR Fixed Price  (Flags)
  - GAR Bulk Group Code         (Bulk-Gruppe)
```

---

## 5. Preisfindungslogik im Detail

### 5.1 Ablauf der Preisfindung (`GAR PC - Garant`, Codeunit 50113)

```
ApplyPrice(CalledByFieldNo)
  │
  ├─ 1. Verify() + CopyToBuffer()  → Price Calculation Buffer füllen
  │
  ├─ 2. FindLines("Price", ...)    → Preislisten-Zeilen suchen (über V16)
  │     └─ Findet Zeilen über Price Sources & Price Assets
  │
  ├─ 3. CalcBestAmount("Price", ...) → Besten Preis ermitteln (V16)
  │
  ├─ 4. SetPrice("Price", ...)     → Preis in Verkaufszeile schreiben
  │
  └─ 5. TryReapplyDiscount()       → Rabatte neu anwenden falls Buffer geändert
```

### 5.2 Ablauf der Rabattfindung (`ApplyDiscount`)

```
ApplyDiscount()
  │
  ├─ 1. CheckSpecificReadPermissionAccess() → Berechtigungsprüfung
  │
  ├─ 2. IsDiscountAllowed() → Rabatt erlaubt?
  │
  ├─ 3. CopyToBuffer() → Buffer füllen (inkl. Bulk/Procurement Mengen)
  │     └─ Fügt Assets hinzu: Bulk Group, Discount Code, Procurement Method
  │
  ├─ 4. FindBestLinePerAsset("Discount", ...)
  │     │
  │     ├─ FindLinesOfEachAsset() → Für jeden Asset-Typ Zeilen suchen
  │     │   └─ CopyLinesByAsset() → Zeilen nach Source-Priorität kopieren
  │     │
  │     └─ CalcBestLinePerAsset() → Beste Zeile pro Asset-Typ filtern
  │         └─ CalcBestAmount() pro Asset-Gruppe (V16)
  │
  ├─ 5. CalcTotalAmount() → Summe der Unit Discounts über alle Assets
  │
  └─ 6. SetPrice("Discount", ...) → Rabatt in Verkaufszeile schreiben
```

### 5.3 Mindestmengen-Prüfung (pro Asset-Typ unterschiedlich)

```al
// In: GAR Sales Price Events - OnBeforeIsInMinQty
case PriceListLine."Asset Type" of
    "Price Asset Type"::"GAR Bulk Group":
        QtyToCompare := PriceCalculationBuffer."GAR Total Group Qty.";
    "Price Asset Type"::"GAR Procurement Method":
        QtyToCompare := PriceCalculationBuffer."GAR Total Asset Qty.";
    else:
        QtyToCompare := PriceCalculationBuffer.Quantity;
end;
```

- **Bulk Group**: Gesamtmenge aller Artikel im Beleg (alle `Type`-gleichen Zeilen)
- **Procurement Method**: Gesamtmenge des gleichen Artikels im Beleg
- **Sonstige (Discount Code, Item, etc.)**: Einzelpositionsmenge

### 5.4 Mengenberechnung für Dokument-Ebene

**Bulk Discount Quantity** (`GAR Total Group Qty.`):
```al
// Filtert alle Zeilen des gleichen Belegs mit gleichem Type
SumSalesLine.SetRange("Document Type", SalesLine."Document Type");
SumSalesLine.SetRange("Document No.", SalesLine."Document No.");
SumSalesLine.SetRange(Type, SalesLine.Type);  // nur Bulk-Items
SumSalesLine.SetFilter("Line No.", '<>%1', SalesLine."Line No.");
// Summe aller GAR Original Qty. + aktuelle Zeilenmenge
```

**Procurement Discount Quantity** (`GAR Total Asset Qty.`):
```al
// Filtert gleicher Beleg + gleicher Artikel + GAR Allow Proc. Discount
SumSalesLine.SetRange(Type, SalesLine.Type);
SumSalesLine.SetRange("No.", SalesLine."No.");
SumSalesLine.SetRange("GAR Allow Proc. Discount", true);
```

### 5.5 Source-Hierarchie (Priority)

Definiert in `GAR PM - Priority` (Codeunit 50111), `SetHierarchicalSourceList()`:

```
Höchste Priorität
    1. Contact         (Bill-to Contact)
    2. Ship-to Address (GAR Ship-to Address)
    3. Customer        (Bill-to Customer)
    4. Customer Price Group / Customer Disc. Group
    5. All Customers   (niedrigste Priorität)
```

Die `Price Source List` wird als Level-basierte Liste aufgebaut, wobei `IncLevel()` die Prioritätsebene erhöht. Die Suche erfolgt von der höchsten zur niedrigsten Ebene (`downto`).

### 5.6 „Better Line"-Logik für Priority

```al
// In: GAR PM - Priority - OnAfterIsBetterLine
if AmountType = Discount and PriceListLine."GAR Unit Discount" <> 0 then
    Result := PriceListLine."GAR Unit Discount" > BestPriceListLine."GAR Unit Discount";

// Priority-spezifisch: Zeilen mit Ending Date werden bevorzugt
if (BestPriceListLine."Ending Date" = 0D) and (PriceListLine."Ending Date" <> 0D) then
    Result := true
else
    if (BestPriceListLine."Ending Date" <> 0D) and (PriceListLine."Ending Date" = 0D) then
        Result := false;
```

---

## 6. Fixpreis und manuelle Überschreibung

### 6.1 `GAR Fixed Price`

Wenn auf einer Verkaufszeile `GAR Fixed Price = true` gesetzt ist:
- Die Preisfindung wird **übersprungen** (`OnBeforeUpdateUnitPrice` → `Handled := true`)
- Der manuell gesetzte `Unit Price` bleibt erhalten
- Der Preis wird als `Special Price` markiert

### 6.2 `GAR Custom Discount Code`

Wenn `GAR Custom Discount Code = true`:
- Ein manueller Rabattcode-Betrag wird verwendet
- Es wird der **Default Custom Discount Code** gesucht (`Manual Reduction = true`)
- Eine temporäre „CUSTOM"-Preislistenzeile wird erzeugt

---

## 7. Preisherkunft (Price Origin)

### 7.1 Aktivierung

In `Sales & Receivables Setup`:
- Feld `GAR Archive Price Origin` muss aktiviert sein

### 7.2 Ablauf beim Buchen

```
Sales-Post Codeunit
  │
  └─ OnAfterSalesInvLineInsert (Event)
       │
       ├─ GAR Price Origin Mgt.SetLinesFromSalesInvoiceLine()
       │   └─ Lädt alle relevanten Preislisten-Zeilen
       │
       └─ GAR Price Origin Mgt.CreatePriceOriginLines()
           └─ Schreibt GAR Price Origin Line pro gefundener Zeile
```

### 7.3 Felder in `GAR Price Origin Line`

Jede Zeile enthält:
- **Dokumentreferenz**: Document Type, Subtype, No., Line No.
- **Preislisten-Referenz**: Price List Code, Origin Line No.
- **Preisquelle**: Source Type, Source No., Parent Source No.
- **Artikel**: Asset Type, Asset No., Variant Code, UoM
- **Beträge**: Unit Price, Unit Discount, Line Discount %
- **Flags**: GAR Fixed Price, GAR Special Price
- **Bulk-Info**: GAR Bulk Group Code
- **Rabattcode**: GAR Reference Asset No.

---

## 8. Preislistenzeilen-Verwaltung

### 8.1 `GAR Unit Discount` vs. `Line Discount %`

- `GAR Unit Discount`: **Absoluter** Einheitsrabatt in €
- `Line Discount %`: **Prozentualer** Positionsrabatt (Standard-BC)

Validierung: Wenn ein Wert gesetzt wird, wird der andere auf 0 gesetzt.

### 8.2 `GAR Reference` Amount Type

Spezieller Betragstyp für Verweise:
- `GAR Reference Asset No.` verweist auf einen `GAR Discount Code`
- Die referenzierte Zeile muss den gleichen Asset Type/No. haben
- Bei `Amount Type = GAR Reference` werden Unit Price/Unit Discount leer gesetzt

### 8.3 Automatische Preisschließung

Wenn ein `Ending Date` gesetzt wird:
- `GAR Closed At` / `GAR Closed By` werden protokolliert
- Über `GAR Price Helper - Garant.AddPriceLineToWksh()` kann automatisch eine neue Zeile erstellt werden:
  - Alte Zeile: Ending Date bleibt
  - Neue Zeile: Starting Date = Ending Date + 1 Tag
  - Line No. Offset: +43 (um Duplikate zu vermeiden)

---

## 9. Special Price Markierung

```al
procedure GetSpecialPrice(): Enum "GAR Special Price"
begin
    case Rec."Source Type" of
        "Price Source Type"::All,
        "Price Source Type"::"All Customers":
            exit("GAR Special Price"::" ");
        else
            exit("GAR Special Price"::"Customer Special Price");
    end;
end;
```

- Quelle „All Customers" → kein Special Price
- Quelle Kunde, Kampagne, Ship-to etc. → **Customer Special Price**
- `GAR Fixed Price = true` → **Special Price** (höchste Stufe)

---

## 10. Wesentliche Unterschiede zum BC-Standard

| Aspekt | BC Standard | GAR.Base |
|--------|------------|----------|
| **Preisfindungs-Methode** | Niedrigster Preis / V16 | Priority (hierarchische Quellen) |
| **Rabatt-Typen** | Line Discount % | Line Discount % + **GAR Unit Discount** (absolut) |
| **Preisquellen** | Customer, Cust.PriceGrp, All, Campaign | + **Ship-to Address**, Contact |
| **Mengenrabatt** | Minimum Quantity pro Zeile | + **Bulk Group** (Belegebene), **Procurement** (Artikelebene) |
| **Rabattcodes** | Nicht vorhanden | **GAR Discount Code** mit Unit Discount |
| **Preisherkunft** | Nicht vorhanden | **GAR Price Origin Line** (komplettes Audit) |
| **Fixpreis** | Nicht vorhanden | **GAR Fixed Price** (manuelle Überschreibung) |
| **Verantwortungscenter** | Nicht in Preisfindung | **GAR Responsibility Center** als Filter |
| **Preisdatum** | Order Date / Posting Date | **GAR Pricing Date** (Zeilen- und Kopf-Ebene) |
| **Automatische Preisschließung** | Nicht vorhanden | Closing-Datum, automatische Nachfolgezeilen |

---

## 11. Technische Hinweise

### 11.1 Berechtigungen

Das System prüft spezifische Leseberechtigungen:
- `Sales Price Access` / `Purchase Price Access` für Preise
- `Sales Discount Access` / `Purchase Discount Access` für Rabatte

### 11.2 Integration Events

Das Modul stellt zahlreiche `IntegrationEvent`-Prozeduren bereit:
- `OnAfterFillBuffer` (mehrere Stellen)
- `OnBeforeCalcBestAmountPerAsset`
- `OnAfterCalcBestAmountPerAsset`
- `OnAfterFetchLinesOfAsset`
- `OnAfterSetHierarchicalSourceList`
- u.v.m.

### 11.3 Obsoleszenzen

Folgende Legacy-Tabellen sind als `Pending Obsolete` markiert und werden durch das neue `Price List Line`-basierte System ersetzt:
- `Sales Price Origin` (50018)
- `Posted Sales Price Origin` (50019)
- `GAR Sales Price Reduction` (50012)
- `GAR Bulk Discount` (50014)
- `GAR Price Reduction Setup` (50047)

---

*Dokumentation erstellt am 2026-06-23 aus dem GAR.Base Repository (`/home/michael/work/GAR.Base`).*
