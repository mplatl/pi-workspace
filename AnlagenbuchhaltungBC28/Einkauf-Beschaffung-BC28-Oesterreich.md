# Einkauf — Beschaffung, Bestellung, Bedarfsplanung & Bestellvorschlag

## Business Central 28 — Vollständige technische und fachliche Dokumentation

**Version:** 1.0 | **Basis:** BC 28.1.49838.49886 (AT) | **Zielgruppe:** Einkäufer, Disponenten, ERP-Consultants, AL-Entwickler

---

## Inhaltsverzeichnis

1. [Einleitung](#1-einleitung)
2. [Einkaufsarchitektur in Business Central](#2-einkaufsarchitektur-in-business-central)
3. [Einkaufsbelege (Purchase Documents)](#3-einkaufsbelege-purchase-documents)
4. [Bedarfsermittlung & Wiederbeschaffung](#4-bedarfsermittlung--wiederbeschaffung)
5. [Bestellvorschlag & Planungs-Worksheet](#5-bestellvorschlag--planungs-worksheet)
6. [Bedarfsplanungsparameter (Planning Parameters)](#6-bedarfsplanungsparameter-planning-parameters)
7. [Bestellanforderung (Requisition Worksheet)](#7-bestellanforderung-requisition-worksheet)
8. [Bestellabwicklung (End-to-End)](#8-bestellabwicklung-end-to-end)
9. [Wareneingang & Einlagerung](#9-wareneingang--einlagerung)
10. [Fakturierung & Fibu-Integration](#10-fakturierung--fibu-integration)
11. [Österreichische Besonderheiten](#11-österreichische-besonderheiten)
12. [Reporting & Analyse](#12-reporting--analyse)
13. [Anhang: AL-Code Referenz](#13-anhang-al-code-referenz)

---

## 1. Einleitung

### 1.1 Zweck dieser Dokumentation

Diese Dokumentation beschreibt die vollständige Einkaufs- und Beschaffungslogik in Microsoft Dynamics 365 Business Central 28. Sie verbindet die **AL-Codebasis** der Base App mit der **betriebswirtschaftlichen Einkaufspraxis** und deckt den gesamten Beschaffungsprozess ab — von der Bedarfsermittlung über den Bestellvorschlag bis zur bezahlten Lieferantenrechnung.

Sie dient als Nachschlagewerk für:

- **Einkäufer & Disponenten:** Operative Abläufe, Planungsparameter, Wiederbeschaffungsstrategien
- **ERP-Consultants:** Einrichtung und Konfiguration
- **AL-Entwickler:** Technische Referenz, Event-Subscription, Erweiterungen

### 1.2 Methodik

Die Analyse basiert auf:

- **AL-Code der Base App:** Version 28.1.49838.49886 (AT)
- **Qdrant RAG-Index:** Hybrid-Suche (BM25 + Vektor) über 117.296 Code-Chunks
- **Fachwissen:** Betriebswirtschaftliche Beschaffungslogik, MRP/MPS, österreichische E-Rechnung

### 1.3 Die fünf Säulen der BC-Beschaffung

```
┌────────────────────────────────────────────────────────────────────────┐
│                    BESCHAFFUNG IN BUSINESS CENTRAL                      │
│                                                                        │
│  ┌──────────┐   ┌──────────────┐   ┌─────────────┐                    │
│  │  ANFRAGE │   │  BESTELLUNG  │   │  RAHMEN-     │                    │
│  │  (Quote) │──▶│  (Order)     │──▶│  BESTELLUNG  │                    │
│  │          │   │              │   │  (Blanket)   │                    │
│  └──────────┘   └──────┬───────┘   └─────────────┘                    │
│                        │                                               │
│       ┌────────────────┼────────────────┐                              │
│       ▼                ▼                ▼                              │
│  ┌──────────┐   ┌──────────────┐   ┌──────────┐                       │
│  │ WAREN-   │   │ BESTELL-     │   │ PLANUNGS- │                       │
│  │ EINGANG  │   │ VORSCHLAG    │   │ WORKSHEET│                       │
│  └────┬─────┘   │ (Req. Wksh.) │   │ (Plan.)  │                       │
│       │         └──────┬───────┘   └────┬─────┘                       │
│       │                │                │                              │
│       ▼                ▼                ▼                              │
│  ┌─────────────────────────────────────────────────────┐               │
│  │              EINGANGSRECHNUNG (Invoice)             │               │
│  │            Fibu-Integration, Kreditoren              │               │
│  └─────────────────────────────────────────────────────┘               │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Einkaufsarchitektur in Business Central

### 2.1 Modul-Übersicht

Das Einkaufsmodul ist in folgende Subsysteme gegliedert:

| Subsystem | Ordner | Funktion |
|---|---|---|
| **Document** | `Purchases/Document/` | Einkaufsbelege (Anfrage, Bestellung, Rechnung, Gutschrift, Retoure, Rahmenbestellung) |
| **History** | `Purchases/History/` | Gebuchte Belege (geliefert, fakturiert) |
| **Archive** | `Purchases/Archive/` | Archivierte Belege |
| **Setup** | `Purchases/Setup/` | Einrichtung (Einkäufer, Buchungsgruppen) |
| **Vendor** | `Purchases/Vendor/` | Kreditorenverwaltung |
| **Pricing** | `Purchases/Pricing/` | Einkaufspreise, Rabatte |
| **Payables** | `Purchases/Payables/` | Kreditorenposten, Zahlung |
| **Posting** | `Purchases/Posting/` | Buchungslogik (Fibu, Lager) |
| **Comment** | `Purchases/Comment/` | Beleg-Kommentare |
| **Analysis** | `Purchases/Analysis/` | Einkaufsanalyse, Budgets |

Dazu kommen die **beschaffungsrelevanten Teile des Inventory-Moduls:**

| Subsystem | Ordner | Funktion |
|---|---|---|
| **Requisition** | `Inventory/Requisition/` | Bestellanforderung, Planungs-Worksheet |
| **Planning** | `Inventory/Planning/` | Planungskomponenten, Planungsparameter |
| **Item** | `Inventory/Item/` | Artikelstamm (Dispositionsdaten) |

### 2.2 Kern-Datenmodell

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         EINKAUFS-DATENMODELL                              │
│                                                                          │
│  ┌──────────────┐    ┌──────────────────┐    ┌────────────────────┐      │
│  │ Vendor (23)  │    │ Item (27)        │    │ Location (14)     │      │
│  │ Kreditor     │    │ Artikelstamm     │    │ Lagerort          │      │
│  └──────┬───────┘    └────────┬─────────┘    └─────────┬──────────┘      │
│         │                     │                        │                  │
│         │                     ▼                        │                  │
│         │     ┌──────────────────────────────┐         │                  │
│         │     │ Stockkeeping Unit (5700)    │         │                  │
│         │     │ Lagerhaltungsdaten (SKU)    │         │                  │
│         │     │ - Reordering Policy         │         │                  │
│         │     │ - Replenishment System      │         │                  │
│         │     │ - Reorder Point, Max. Inv.  │         │                  │
│         │     └──────────────┬───────────────┘         │                  │
│         │                    │                         │                  │
│  ┌──────▼───────┐    ┌───────▼──────────┐    ┌────────▼─────────┐        │
│  │ Purchase     │    │ Requisition      │    │ Planning         │        │
│  │ Header (38)  │    │ Line (246)       │    │ Component (5425) │        │
│  │ Purchase     │    │ - Action Message │    │ - SKU reference   │        │
│  │ Line (39)    │    │ - Planning Date   │    │ - Stückliste     │        │
│  └──────┬───────┘    └───────┬──────────┘    └──────────────────┘        │
│         │                    │ 1:N                                       │
│         │     ┌──────────────▼──────────────────────────────────┐        │
│         │     │        Req. Wksh. Template (5414)               │        │
│         │     │        Req. Wksh. Name (248)                    │        │
│         │     │        Planning Worksheet ← gleiche Tabellen    │        │
│         │     └─────────────────────────────────────────────────┘        │
│         │                                                                │
│  ┌──────▼───────┐                                                       │
│  │ Purch. Inv.  │    ┌──────────────────┐                               │
│  │ Header (121) │    │ Purch. Rcpt.    │                                │
│  │ Purch. Inv.  │    │ Header (120)    │                                │
│  │ Line (122)   │    │ Purch. Rcpt.    │                                │
│  └──────────────┘    │ Line (121)      │                                │
│                      └──────────────────┘                                │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────┐        │
│  │  Fibu-Integration: Vendor Ledger Entry (25), G/L Entry (17)  │        │
│  │  Lager-Integration: Item Ledger Entry (32), Value Entry (…)  │        │
│  └──────────────────────────────────────────────────────────────┘        │
└──────────────────────────────────────────────────────────────────────────┘
```

### 2.3 Purchase Document Type — Belegarten

```al
enum 38 "Purchase Document Type"
{
    value(0; Quote)        // Anfrage
    value(1; Order)        // Bestellung
    value(2; Invoice)      // Rechnung
    value(3; Credit Memo)  // Gutschrift
    value(4; Blanket Order) // Rahmenbestellung
    value(5; Return Order)  // Retoure / Rücksendung
}
```

**Belegfluss in BC:**

```
 Anfrage ──▶ Bestellung ──▶ Wareneingang ──▶ Eingangsrechnung
 (Quote)     (Order)        (Receipt)         (Invoice)
    │
    └── Stornierung möglich (vor Lieferung)
```

### 2.4 Replenishment System — Beschaffungsart

```al
enum 5419 "Replenishment System"
{
    value(0; Purchase)     // Einkauf
    value(1; Prod. Order)  // Fertigungsauftrag
    value(2; Transfer)     // Umlagerung
    value(4; " ")          // Keine Beschaffung
}
```

| Beschaffungsart | Verwendung |
|---|---|
| **Purchase** | Zukauf von Fremdartikeln oder Handelsware → erzeugt Bestellzeilen |
| **Prod. Order** | Eigenfertigung → erzeugt Fertigungsauftragsvorschläge |
| **Transfer** | Umlagerung zwischen Standorten → erzeugt Umlagerungsaufträge |
| **(leer)** | Nur manuelle Disposition; kein automatischer Bestellvorschlag |

---

## 3. Einkaufsbelege (Purchase Documents)

### 3.1 Purchase Header (Tabelle 38)

Die Tabelle **Purchase Header** ist der zentrale Belegkopf für alle Einkaufsdokumente. Wichtige Felder:

| Feld-Nr. | Name | Beschreibung |
|---|---|---|
| 1 | Document Type | Belegart (Quote, Order, Invoice, Credit Memo, Blanket Order, Return Order) |
| 2 | Buy-from Vendor No. | Kreditorennummer |
| 3 | No. | Belegnummer (aus Nummernserie) |
| 5 | Pay-to Vendor No. | Abweichender Zahlungsempfänger |
| 11 | Vendor Invoice No. | Lieferantenrechnungsnummer |
| 14 | Due Date | Fälligkeitsdatum (Zahlungsziel) |
| 15 | Posting Date | Buchungsdatum |
| 16 | Document Date | Belegdatum |
| 17 | Order Date | Bestelldatum |
| 21 | Requested Receipt Date | Gewünschtes Wareneingangsdatum |
| 22 | Promised Receipt Date | Zugesagtes Lieferdatum |
| 68 | Payment Terms Code | Zahlungsbedingungen |
| 71 | Vendor Posting Group | Kreditorenbuchungsgruppe |
| 73 | VAT Bus. Posting Group | MwSt.-Buchungsgruppe Geschäft |
| 74 | VAT Prod. Posting Group | MwSt.-Buchungsgruppe Produkt |
| 80 | Currency Code | Währungscode |
| … | … | … |
| 92 | Status | Belegstatus (Open, Released, Pending Approval) |
| 500 | Amount | Nettobetrag |
| 501 | Amount Including VAT | Bruttobetrag |

**Wichtige Validierungen beim Setzen des Kreditors:**
- TestStatusOpen() — Buchungen nur bei offenem Status zulässig
- InitRecord() — Initialisiert Nummern, Zahlungsbedingungen, Währung, MwSt.-Daten vom Kreditor
- Kopiert Standard-Dimensionen vom Kreditor

### 3.2 Purchase Line (Tabelle 39)

Die **Purchase Line** enthält die einzelnen Belegzeilen. Wichtige Felder:

| Feld-Nr. | Name | Beschreibung |
|---|---|---|
| 5 | Type | Zeilentyp (Item, G/L Account, Fixed Asset, Resource, Charge/Item) |
| 6 | No. | Artikelnummer / Sachkontonummer |
| 15 | Quantity | Menge |
| 18 | Direct Unit Cost | Einstandspreis (exkl. MwSt.) |
| 21 | Line Amount | Zeilenbetrag |
| 22 | Line Discount % | Zeilenrabatt |
| 23 | Line Discount Amount | Zeilenrabattbetrag |
| 39 | Quantity Received | Gelieferte Menge |
| 40 | Quantity Invoiced | Fakturierte Menge |
| 45 | Outstanding Quantity | Offene Menge |
| 48 | Outstd. Qty. to Receive | Noch zu liefernde Menge |
| 55 | Planned Receipt Date | Geplanter Wareneingang |
| 56 | Expected Receipt Date | Erwarteter WE |
| ... | ... | ... |
| 5498 | Job No. | Projektnummer |
| 5499 | Job Task No. | Projektaufgabe |

### 3.3 Purchase Line Type

```al
enum "Purchase Line Type"
{
    value(0; " ")           // Leer
    value(1; "G/L Account") // Sachkonto
    value(2; Item)          // Artikel
    value(3; Resource)      // Ressource
    value(4; "Fixed Asset") // Anlagevermögen
    value(5; "Charge (Item)") // Artikelbezogener Zuschlag
}
```

**Belegstatus-Flow:**
```
Open → Released → Pending Approval → Pending Prepayment → Ready to Post
```

---

## 4. Bedarfsermittlung & Wiederbeschaffung

### 4.1 Das Planungssystem im Überblick

Business Central verwendet ein **Bestandsgeführtes Material Requirements Planning (MRP)** zur Ermittlung von Beschaffungsbedarfen.

**Grundprinzip:**

```
Zukünftiger Bestand = Aktueller Bestand
                    − Bruttobedarf (Verkäufe, Fertigungsbedarf, Prognosen)
                    + Geplante Zugänge (Bestellungen, Fertigungsaufträge)

Wenn zukünftiger Bestand < Meldebestand → Beschaffungsvorschlag
```

### 4.2 Reordering Policy — Wiederbeschaffungsverfahren

```al
enum 5440 "Reordering Policy"
{
    value(0; " ")                    // Kein automatischer Vorschlag
    value(1; "Fixed Reorder Qty.")   // Feste Bestellmenge
    value(2; "Maximum Qty.")         // Maximalbestand
    value(3; "Order")                // Auftragsbezogen
    value(4; "Lot-for-Lot")          // Los-für-Los
}
```

#### 4.2.1 Fixed Reorder Qty. (Feste Bestellmenge)

**Prinzip:** Sobald der Meldebestand unterschritten wird, wird immer eine fixe Menge bestellt.

| Parameter | Beschreibung |
|---|---|
| **Reorder Point** | Meldebestand — wenn unterschritten → Bestellvorschlag |
| **Reorder Quantity** | Feste Bestellmenge (z.B. immer 100 Stück) |
| **Safety Lead Time** | Sicherheitsvorlaufzeit |
| **Rescheduling Period** | Zeitfenster für Umterminierungen |
| **Order Multiple** | Bestellmenge wird auf Vielfaches gerundet |

**Beispiel:**
```
Meldebestand = 50, Feste Bestellmenge = 100, Order Multiple = 10
Bestand aktuell = 45 → Bedarf = 60 (um auf 105 zu kommen)
Gerundet auf Order Multiple = 60
```

#### 4.2.2 Maximum Qty. (Maximalbestand)

**Prinzip:** Der Bestand wird bis zu einem definierten Maximalbestand aufgefüllt.

| Parameter | Beschreibung |
|---|---|
| **Reorder Point** | Meldebestand |
| **Maximum Inventory** | Maximalbestand |
| **Order Multiple** | Bestellmengenrundung |

**Beispiel:**
```
Meldebestand = 50, Maximalbestand = 200
Bestand aktuell = 30 → Bestellmenge = 200 − 30 = 170
```

#### 4.2.3 Order (Auftragsbezogen)

**Prinzip:** Für jeden Bedarf wird ein eigener Beschaffungsvorschlag erstellt. Bedarfe werden **nicht** zu einem Los zusammengefasst. Jeder Verkaufsauftrag erzeugt eine eigene Bestellzeile.

| Parameter | Beschreibung |
|---|---|
| **Order Multiple** | Mindestmenge / Rundung |
| **Rescheduling Period** | Umterminierungs-Zeitfenster |

**Einsatz:** Bei kundenauftragsbezogener Beschaffung, wenn Rückverfolgbarkeit wichtig ist.

#### 4.2.4 Lot-for-Lot (Los-für-Los)

**Prinzip:** Bedarfe eines Zeitraums werden zu einem Los gebündelt. Identische Bedarfe innerhalb der **Lot Accumulation Period** werden zusammengefasst.

| Parameter | Beschreibung |
|---|---|
| **Lot Accumulation Period** | Bündelungszeitraum (z.B. 1W = eine Woche) |
| **Rescheduling Period** | Umterminierungszeitraum |
| **Dampener Period** | Dämpfungsperiode (Puffer) |
| **Dampener Quantity** | Dämpfungsmenge |
| **Order Multiple** | Bestellmengenrundung |

**Beispiel:**
```
Lot Accumulation Period = 1W, Order Multiple = 10
Bedarf Mo: 25 Stk, Di: 30 Stk, Do: 15 Stk = Gesamtbedarf Woche: 70
Gerundet auf Order Multiple = 70 → 70 Stück bestellt
```

### 4.3 Bedarfsquellen

Das Planungssystem berücksichtigt folgende **Bruttobedarfe:**

| Bedarfsquelle | Herkunft |
|---|---|
| **Verkaufsaufträge** | Sales Line, Menge + Lieferdatum |
| **Fertigungsaufträge (Komponenten)** | Production BOM Line, Menge + Bedarfsdatum |
| **Montageaufträge (Komponenten)** | Assembly Line |
| **Serviceaufträge** | Service Line |
| **Projektplanungszeilen** | Job Planning Line |
| **Umlagerungsbedarfe** | Transfer Line (Ziel-Lagerort) |
| **Prognosen** | Production Forecast / Sales Forecast |
| **Rahmenbestellungen (Abrufe)** | Blanket Purchase Order + Abrufzeilen |

**Zugänge (Scheduled Receipts):**

| Zugangsquelle | Herkunft |
|---|---|
| **Bestellungen** | Purchase Line (offene Menge) |
| **Fertigungsaufträge** | Released Prod. Order (Ausstoß) |
| **Umlagerungen** | Transfer Order (Eingang) |
| **Montageaufträge** | Assembly Order (Fertigungsausstoß) |

### 4.4 Planungsflexibilität

Auf Artikelebene gibt es zwei Flexibilitätseinstellungen:

| Enum | Wert | Bedeutung |
|---|---|---|
| **Inventory Planning Flexibility** | None / Some / Unlimited | Wie weit darf das Planungssystem Zugänge verschieben? |
| **Reservation Planning Flexibility** | None / Some / Unlimited | Wie weit dürfen Reservierungen vom Planungssystem geändert werden? |

---

## 5. Bestellvorschlag & Planungs-Worksheet

### 5.1 Begriffsklärung

In BC 28 gibt es **zwei Worksheet-Typen**, die **dieselbe Tabelle** (Requisition Line, 246) verwenden:

| Begriff | Deutsch | Englisch | Verwendung |
|---|---|---|---|
| **Bestellanforderung** | Bestellvorschlag | Planning Worksheet | Einkäufer plant Beschaffungen, wandelt Vorschläge in Bestellungen um |
| **Planungs-Worksheet** | Dispositionslauf | Requisition Worksheet | Disponent führt MRP/MPS-Lauf durch, prüft Aktionsmeldungen |

**Unterschied:** Beide nutzen dieselben Tabellen (`Requisition Line`, `Req. Wksh. Template`, `Req. Wksh. Name`), aber mit unterschiedlichen **Berechnungsmodi**.

### 5.2 Berechnungsmodi (Calculation Options)

```
┌─────────────────────────────────────────────────────────────┐
│  PLANUNGSLAUF (Calc. Plan)                                   │
│                                                              │
│  ○ MPS (Master Production Schedule)                         │
│    Nur Endprodukte / kritische Materialien                   │
│                                                              │
│  ○ MRP (Material Requirements Planning)                     │
│    Alle Artikel mit Wiederbeschaffungsverfahren              │
│    inkl. Stücklistenauflösung                                │
│                                                              │
│  ○ Net Change (Nettoveränderung)                             │
│    Nur Artikel, deren Bedarfs-/Bestandssituation             │
│    sich seit dem letzten Lauf geändert hat                   │
│                                                              │
│  ○ Regenerative Plan (Regenerative Plan)                    │
│    Kompletter Neuaufbau der Planung. Alle alten              │
│    Planungszeilen werden gelöscht und neu erzeugt            │
└─────────────────────────────────────────────────────────────┘
```

### 5.3 Aktionsmeldungen (Action Messages)

Nach dem Planungslauf erzeugt das System **Aktionsmeldungen** für den Disponenten:

| Action Message | Bedeutung | Aktion |
|---|---|---|
| **New** | Neuer Bedarf, kein vorhandener Auftrag | Bestellvorschlag → Bestellung umwandeln |
| **Change Qty.** | Menge eines vorhandenen Auftrags ändern | Bestellmenge anpassen |
| **Reschedule** | Auftrag zeitlich verschieben (später) | Liefertermin verschieben |
| **Resched. & Chg. Qty.** | Auftrag verschieben + Mengenänderung | Beides anpassen |
| **Cancel** | Auftrag nicht mehr benötigt (keine Nachfrage) | Bestellung stornieren |
| **Forward** (Register) | Abgeleitete Planungszeilen — keine Aktion nötig | Nur zur Info |

### 5.4 Planungs-Worksheet (Requisition Worksheet)

**Aufruf:** `Planungs-Worksheet` (Page `Planning Worksheet`)

**Workflow:**
```
1. Planungsvorlage + Planungsname wählen
2. "Berechnungsvorschlag" ausführen (Calc. Plan)
   → System erzeugt Requisition Lines mit Action Messages
3. Aktionsmeldungen prüfen und ggf. anpassen
4. "Aktionsmeldung ausführen" (Carry Out Action Message)
   → Zeilen werden in Bestellungen / Fertigungsaufträge umgewandelt
```

**Umwandlung in Bestellungen:**
```
Req. Line → Action Message = "New"
    ↓ "Aktionsmeldung ausführen"
    ├── Erzeugt Purchase Header + Purchase Line
    ├── Übernimmt Menge, Datum, Kreditor, Einkaufspreis
    └── Req. Line wird gelöscht (oder bleibt als Referenz)
```

### 5.5 Planungskomponenten (Planning Components)

Bei Fertigungsartikeln wird die **Stückliste aufgelöst**. Das Planungssystem erzeugt für jede Komponente eine eigene **Planning Component** (Tabelle 5425) als Kind der Requisition Line.

```
Req. Line (Fertigerzeugnis, Type = Prod. Order)
 ├── Planning Component 1 (Rohstoff A, Menge 2)
 ├── Planning Component 2 (Rohstoff B, Menge 5)
 └── Planning Component 3 (Halbfabrikat, eigene Stückliste)
```

---

## 6. Bedarfsplanungsparameter (Planning Parameters)

### 6.1 Kalkulations-Codeunit: Calc. Item Plan - Plan Wksh. (5431)

Die Codeunit **5431** ist der zentrale Planungsalgorithmus. Sie wird pro Artikel ausgeführt (`TableNo = Item`).

**Kernlogik (Code):**
```al
// Vereinfachte Darstellung der Planungslogik:
if not PlanThisItem() then
    exit;

// 1. Bestand zum Berechnungsdatum ermitteln
// 2. Bedarfe einsammeln (Sales, Prod. Order Comp., Forecast)
// 3. Zugänge einsammeln (Purchase Orders, Prod. Orders, Transfers)
// 4. Bruttobedarf − Planzugänge = Nettobedarf
// 5. Wenn Nettobedarf > 0 → Requisition Line mit Action Message erzeugen
// 6. Bei Fertigungsartikeln: Stückliste auflösen → Planning Components
```

### 6.2 Planungsparameter-Tabelle (Planning Parameters, 5424)

| Parameter | Beschreibung | Beispiel |
|---|---|---|
| **Starting Date** | Planungsbeginn (heute oder später) | 01.07.2026 |
| **Ending Date** | Planungshorizont | 31.12.2026 |
| **Respect Planning Parameters** | Planungsparameter des Artikels respektieren | Ja |
| **Use Forecast** | Prognosen einbeziehen | Ja/Nein |
| **Exclude Forecast Before** | Prognosen vor diesem Datum ignorieren | — |
| **Calculate Components** | Stücklisten auflösen | Ja/Nein |
| **Calculate Planning** | Planungslauf durchführen | Ja/Nein (MPS/MRP) |

### 6.3 Artikelspezifische Dispositionsparameter

Pro Artikel / SKU werden folgende **Dispositionsstammdaten** gesetzt:

| Feld | Nr. | Beschreibung |
|---|---|---|
| Replenishment System | 5419 | Einkauf / Fertigung / Umlagerung |
| Reordering Policy | 5440 | Lot-for-Lot / Fixed Qty. / Max. Qty. / Order |
| Reorder Point | 34 | Meldebestand |
| Maximum Inventory | 35 | Maximalbestand |
| Reorder Quantity | — | Feste Bestellmenge |
| Order Multiple | 5414 | Bestellmengenrundung (Vielfaches) |
| Safety Lead Time | 5415 | Sicherheitsvorlaufzeit |
| Rescheduling Period | 5443 | Umterminierungsfenster |
| Lot Accumulation Period | 5444 | Bündelungsperiode (Lot-for-Lot) |
| Dampener Period | 5445 | Dämpfungsperiode |
| Dampener Quantity | — | Dämpfungsmenge |
| Flushing Method | 5417 | Rückmeldeverfahren |
| Reserve | 100 | Reservierungsverhalten (Never/Optional/Always) |
| Lead Time Calculation | — | Wiederbeschaffungszeit (Basis) |
| Safety Stock Quantity | — | Sicherheitsbestand |

### 6.4 Planungsflexibilität und Reservierungen

```
Inventory Planning Flexibility:
  None    → Planungssystem darf KEINE Zugangsdaten ändern
  Some    → Darf innerhalb der Rescheduling Period verschieben
  Unlimited → Darf beliebig verschieben und planen

Reservation Planning Flexibility:
  None    → Bestehende Reservierungen bleiben unverändert
  Some    → Darf Restmengen umreservieren
  Unlimited → Darf alle Reservierungen auflösen und neu verplanen
```

---

## 7. Bestellanforderung (Requisition Worksheet)

### 7.1 Datenmodell

| Tabelle | ID | Beschreibung |
|---|---|---|
| **Requisition Line** | 246 | Zeilen der Bestellanforderung |
| **Req. Wksh. Template** | 5414 | Vorlagen (z.B. "EINKAUF", "FERTIGUNG") |
| **Req. Wksh. Name** | 248 | Stapel innerhalb der Vorlage |
| **Planning Component** | 5425 | Stücklisten-Komponenten zur Planungszeile |
| **Planning Assignment** | (intern) | Verknüpfung Planungszeile ↔ Bedarfsursprung |

### 7.2 Requisition Line Type

```al
enum "Requisition Line Type"
{
    value(0; " ")           // Leer (manuelle Zeile)
    value(1; Item)          // Artikel
    value(2; "G/L Account") // Sachkonto
    value(3; Resource)      // Ressource
}
```

### 7.3 Manueller Bestellvorschlag (ohne MRP-Lauf)

Der Einkäufer kann auch **manuell** Zeilen im Planungs-Worksheet erfassen:
1. Worksheet öffnen
2. Artikelnummer, Menge, Fälligkeitsdatum eintragen
3. Action Message = "New" manuell setzen
4. "Aktionsmeldung ausführen" → Bestellung wird erzeugt

### 7.4 Carry Out Action Message

Codeunit **CarryOutAction** (im Inventory/Requisition-Ordner) implementiert die Logik zur Umwandlung der Planungszeilen:

```al
// Typ-Abhängige Verarbeitung:
case ReqLine."Replenishment System" of
    Replenishment System::Purchase:
        CreatePurchaseOrder(ReqLine)          // → Purchase Header/Line
    Replenishment System::"Prod. Order":
        CreateProductionOrder(ReqLine)        // → Prod. Order Header/Line
    Replenishment System::Transfer:
        CreateTransferOrder(ReqLine)          // → Transfer Header/Line
end;
```

**Beim Erzeugen der Bestellung werden übernommen:**
- Kreditor, Einkaufspreis, Rabatte (aus EK-Preisliste)
- Währung, MwSt. (vom Kreditor)
- Liefertermin, Menge
- Planungsreferenz (Tracking)

---

## 8. Bestellabwicklung (End-to-End)

### 8.1 Überblick: Von der Anforderung zur bezahlten Rechnung

```
 Schritt 1         Schritt 2          Schritt 3           Schritt 4
┌──────────┐     ┌──────────┐       ┌──────────┐        ┌──────────┐
│ BEDARF   │────▶│ANFRAGE   │──────▶│BESTELLUNG│───────▶│LIEFERUNG │
│ planen   │     │einholen  │       │erteilen  │        │buchen    │
└──────────┘     └──────────┘       └──────────┘        └────┬─────┘
                                                             │
 Schritt 5         Schritt 6          Schritt 7              │
┌──────────┐     ┌──────────┐       ┌──────────┐            │
│RECHNUNG  │◀────│RECHNUNG  │◀──────│WAREN-    │◀───────────┘
│bezahlen  │     │buchen    │       │EINGANG   │
└──────────┘     └──────────┘       └──────────┘
```

### 8.2 Schritt 1: Bedarfsplanung

1. Disponent öffnet **Planungs-Worksheet**
2. Parameter setzen: Startdatum, Enddatum, MRP/MPS, Net Change/Regenerativ
3. **Berechnungsvorschlag** ausführen
4. Aktionsmeldungen prüfen
5. **Aktionsmeldung ausführen** → Bestellungen werden erzeugt

### 8.3 Schritt 2: Anfrage (Quote)

**Zweck:** Vorabanfrage bei Lieferanten zu Preisen und Lieferbedingungen. Keine buchhalterische Auswirkung.

| Feld | Wert |
|---|---|
| Document Type | Quote |
| Vendor No. | Kreditor |
| Valid Until Date | Gültig bis |

**Umwandlung in Bestellung:**
- Funktion "Auftrag erstellen" → Quote wird kopiert → Order entsteht
- Quote bleibt erhalten (archivierbar)

### 8.4 Schritt 3: Bestellung (Order)

**Erzeugung:**
- Aus Planungs-Worksheet → "Aktionsmeldung ausführen"
- Aus Anfrage → "Auftrag erstellen"
- Manuell → Neue Bestellung erfassen
- Aus Rahmenbestellung → "Bestellung erstellen"
- Aus Verkaufsauftrag → "Einkaufsbestellung erstellen" (Drop-Ship)

**Status-Flow:**
```
Open → Released (Freigegeben) → Pending Approval → Ready to Post
```

**Status Open:** Kann noch geändert werden (Mengen, Preise, Kreditor)
**Status Released:** Keine Änderungen mehr, aber noch nicht gebucht
**Status Pending Approval:** Genehmigungsworkflow wartet
**Status Ready to Post:** Kann geliefert/fakturiert werden

### 8.5 Schritt 4: Wareneingang buchen (Receipt)

**BC-Vorgang:**
1. Bestellung öffnen → "Buchen" → "Wareneingang buchen"
2. Oder: **Eingangsrechnung** direkt buchen (Wareneingang + Rechnung in einem Schritt)

**Buchungseffekte Wareneingang:**
```
Lagerbestand     Soll (+)     Menge × Einstandspreis
Bestandsverrechnungskonto     Haben (−)  gleicher Betrag
```

### 8.6 Schritt 5: Eingangsrechnung buchen (Invoice)

**BC-Vorgang:**
1. Bestellung öffnen → "Buchen" → "Rechnung buchen"
2. Oder: Bestellung → "Wareneingang buchen" → "Rechnung buchen" (getrennt)

**Buchungseffekte Rechnung:**
```
Bestandsverrechnung     Soll (+)     Menge × Einkaufspreis
Kreditor                Haben (−)    Bruttobetrag (inkl. MwSt.)
Vorsteuer               Soll (+)     MwSt.-Betrag
```

**Bei getrennter Buchung (WE zuerst, Rechnung später):**
- WE: Bestandskonto / Bestandsverrechnungskonto
- Rechnung: Bestandsverrechnung / Kreditor
- Preisdifferenzen zwischen WE und Rechnung werden automatisch auf das Bestandskonto gebucht

### 8.7 Schritt 6: Zahlung

- Fibu → Zahlungsausgangsjournal
- Oder: Kreditorenposten → "Zahlung buchen"
- Zahlungsvorschlag (automatisierte Selektion offener Posten)

### 8.8 Gutschrift & Retoure

| Vorgang | BC-Dokumenttyp |
|---|---|
| Gutschrift (ohne Rücksendung) | **Credit Memo** (Document Type = Credit Memo) |
| Retoure mit Gutschrift | **Return Order** → Wareneingang der Retoure → **Credit Memo** erzeugen |

---

## 9. Wareneingang & Einlagerung

### 9.1 Basislager vs. Erweitertes Lager

| Lagertyp | Wareneingang | Einlagerung |
|---|---|---|
| **Basislager** | Direkt in der Bestellung buchen | Keine (Bestand wird direkt gebucht) |
| **Erweitertes Lager** | Warehouse Receipt → Warehouse Put-away | Mehrstufig mit Lagerplätzen |

### 9.2 Buchungsschema Wareneingang

```
Purchase Line → Post = true → Receive
    ↓
Item Ledger Entry (Item No., Quantity, Location, Entry Type = Purchase)
Value Entry (Item Ledger Entry, Cost Amount)
G/L Entry (Inventory Account Soll / Interim Account Haben)
```

### 9.3 Teillieferung

BC erlaubt **Teillieferungen** aus einer Bestellzeile:
- `Quantity Received` < `Quantity`
- `Outstanding Quantity` zeigt die Restmenge
- Weitere Wareneingänge sind möglich, bis die volle Menge erreicht ist
- **Orderstatus** geht erst auf "Fully Received" wenn alle Zeilen komplett geliefert sind

### 9.4 Lieferung fakturieren (Kombi-Buchung)

Funktion: **"Lieferung und Rechnung buchen"**

Bucht Wareneingang + Rechnung in **einem Schritt** → keine Bestandsverrechnung nötig, da Einstandspreis sofort endgültig.

```
Bestandskonto       Soll   Einkaufspreis
Vorsteuer           Soll   MwSt.
Kreditor            Haben  Bruttobetrag
```

---

## 10. Fakturierung & Fibu-Integration

### 10.1 Gebuchte Belege (History)

Nach dem Fakturieren entstehen folgende gebuchte Belege:

| Tabelle | ID | Inhalt |
|---|---|---|
| **Purch. Inv. Header** | 121 | Gebuchte Einkaufsrechnung (Kopf) |
| **Purch. Inv. Line** | 122 | Gebuchte Einkaufsrechnung (Zeilen) |
| **Purch. Rcpt. Header** | 120 | Gebuchter Wareneingang (Kopf) |
| **Purch. Rcpt. Line** | 121 | Gebuchter Wareneingang (Zeilen) |
| **Purch. Cr. Memo Hdr.** | 126 | Gebuchte Einkaufsgutschrift (Kopf) |

### 10.2 Fibu-Integration

Jede Einkaufsrechnung erzeugt:

| Buchung | Soll/Haben | Konto |
|---|---|---|
| Bestandsverrechnung | Soll | Bestandsverrechnungskonto (Interim) |
| Einkauf (Aufwand) | Soll | Aufwandskonto (bei Sachkontenzeilen) |
| Vorsteuer | Soll | Vorsteuerkonto |
| Kreditor | Haben | Kreditorenkonto (Verbindlichkeit) |

### 10.3 Preisabweichungen

Bei getrennter Buchung von Wareneingang und Rechnung:
- Wareneingang: Vorläufiger Einstandspreis (aus Bestellung)
- Rechnung: Endgültiger Einstandspreis (aus Lieferantenrechnung)
- Differenz = Preisabweichung → wird automatisch auf das Bestandskonto gebucht

### 10.4 Mahnwesen & Zahlung

```
Offene Kreditorenposten ──▶ Zahlungsvorschlag ──▶ Zahlungsausgangsjournal ──▶ Banküberweisung
```

- **Zahlungsbedingungen:** Payment Terms Code auf Purchase Header
- **Skonto:** Zahlungsbedingungen mit Skontofrist
- **Mahnung:** Mahnung an Lieferanten? Nein — Mahnwesen betrifft nur Debitoren. Einkaufsseitig gibt es Fälligkeitslisten.

---

## 11. Österreichische Besonderheiten

### 11.1 E-Rechnung an die öffentliche Hand (seit 2014)

Österreichische Bundesdienststellen müssen elektronische Rechnungen empfangen. Für Lieferanten bedeutet das:

- Rechnungen im **ebInterface-Format** (XML-Standard)
- In BC über **E-Document Core Extension** abbildbar
- Elektronische Signatur möglich (je nach Empfänger)

### 11.2 Umsatzsteuer (UStG 1994)

| Steuersatz | Verwendung |
|---|---|
| **20%** (Normalsteuersatz) | Standard-Einkäufe |
| **10%** (ermäßigt) | Lebensmittel, Bücher, Mieten, Beherbergung |
| **0%** (unecht steuerbefreit) | Export, innergemeinschaftliche Lieferung |

**BC-Mapping:**
- **VAT Bus. Posting Group** + **VAT Prod. Posting Group** → **VAT Posting Setup**
- UID-Nummer des Lieferanten wird auf Vendor Card hinterlegt
- Innergemeinschaftlicher Erwerb (IGE): Erwerbsteuer

### 11.3 Zusammenfassende Meldung (ZM)

Innergemeinschaftliche Einkäufe ab € 0,01 (seit 2010) müssen in der **Zusammenfassenden Meldung (ZM)** an das Finanzamt gemeldet werden.

**BC:** Auswertung über Intrastat / VAT-VIES Reporting.

### 11.4 Reverse Charge (§ 19 UStG)

Bei bestimmten Leistungen (Bauleistungen, Lieferung von Gas/Elektrizität, Schrottlieferungen) geht die Steuerschuld auf den Leistungsempfänger über.

**BC-Konfiguration:**
- Spezielle **VAT Prod. Posting Group** für Reverse Charge
- VAT Posting Setup: VAT % = 20%, aber **Reverse Charge = true**
- Buchung: Vorsteuer + Umsatzsteuer (gleiches Konto) = Nullsumme, aber Meldeverpflichtung

### 11.5 Vorsteuerabzug

**Voraussetzungen (§ 12 UStG):**
- Rechnung mit allen Pflichtmerkmalen (Name, Adresse, UID, Menge, Entgelt, Steuerbetrag)
- Leistung für das Unternehmen
- Kein Ausschlussgrund (z.B. Repräsentationsaufwendungen, PKW bis 202x)

**BC-Prüfung:** Keine automatische Prüfung der Rechnungspflichtmerkmale; manuelle Kontrolle oder über E-Document Extension.

### 11.6 Anzahlungen / Vorauszahlungen

Österreich: Bei Anzahlungen entsteht die Steuerschuld bereits mit Vereinnahmung.

**BC:** Purchase Order → Prepayment Invoice buchen → Verrechnung mit Schlussrechnung.

### 11.7 GWG (Geringwertige Wirtschaftsgüter)

Anschaffungskosten ≤ **€ 1.000** (netto) → Sofortabzug im Jahr der Anschaffung.

**BC:** Einkauf als G/L Account Type (Aufwandskonto) statt Item Type → kein Bestand, direkt Aufwand.

---

## 12. Reporting & Analyse

### 12.1 Standardberichte

| Bericht | Beschreibung |
|---|---|
| **Purchase Order** | Bestellung drucken (Formular) |
| **Purchase Quote** | Anfrage drucken |
| **Purch. Order List** | Bestellliste nach Status |
| **Purchase - Receipt** | Wareneingangsliste |
| **Purch. Order - Top 10** | Top-10-Lieferanten |
| **Vendor - Order Summary** | Bestellvolumen pro Kreditor |
| **Aged Accounts Payable** | OP-Liste nach Fälligkeit |
| **Planning Availability** | Bedarfs-/Bestandsplanung pro Artikel |

### 12.2 Analyse-Ansichten

- **Purchase by Vendor Group** (Query)
- **Purchase Analysis by Dimensions**
- **Purchase Budget Overview**
- **Analysis View List Purchase**
- **Analysis Report Purchase**

### 12.3 Bedarfsplanungsbericht (Planning Availability)

Der Bericht **Planning Availability** zeigt pro Artikel:

| Größe | Beschreibung |
|---|---|
| **Gross Requirement** | Bruttobedarf im Planungszeitraum |
| **Scheduled Receipts** | Geplante Zugänge |
| **Projected Balance** | Voraussichtlicher Bestand pro Periode |
| **Expected Available Balance** | Erwarteter verfügbarer Bestand |

### 12.4 Einkaufs-FactBox (Item Card)

Auf der Artikelkarte (Page `Item Card`) zeigt der **ItemPlanningFactBox**:
- Aktueller Bestand
- Reservierte Menge
- Bestellte Menge (offene Bestellungen)
- Verkaufte Menge (offene Verkäufe)
- Verfügbarer Bestand
- Letzter Planungslauf / Aktionsmeldungen

---

## 13. Anhang: AL-Code Referenz

### 13.1 Alle Tabellen (Einkauf + Planung)

```
38   Purchase Header                  39   Purchase Line
50   Purch. Comment Line             121   Purch. Inv. Header
122  Purch. Inv. Line                 120   Purch. Rcpt. Header
121  Purch. Rcpt. Line                126   Purch. Cr. Memo Hdr.
127  Purch. Cr. Memo Line            5107   Purchase Header Archive
5108  Purchase Line Archive          5109   Purch. Comment Line Archive
23   Vendor                          246   Requisition Line
248  Req. Wksh. Name                 5414  Req. Wksh. Template
5425  Planning Component             5424  Planning Parameters
5432  Planning Error Log             …     Untracked Planning Element
```

### 13.2 Alle Codeunits (Einkauf + Planung)

```
60   Purch.-Post                       61   Purch.-Post + Print
62   Purch.-Post Batch                 74   Purch.-Calc. VAT
75   Purch.-Get Posted Line            76   Purch.-Post Line
90   Purch.-Check                      91   Purch.-Check Line
5431  Calc. Item Plan - Plan Wksh.    5431  Calc. Item Plan (Mfg.)
    CarryOutAction (Inventory/Requisition)
    PlanningLineManagement
    PlanningWkshManagement
    OrderPlanningMgt
    RequisitionLinePrice
    CalcItemPlanPlanWksh (Inventory/Planning)
    MakeSupplyOrders (Yes/No)
```

### 13.3 Wichtige Events (Integration/Extension)

| Event | Ort | Zweck |
|---|---|---|
| `OnBeforeValidateBuyFromVendorNo` | Purchase Header | Vor Kreditor-Validierung |
| `OnAfterInitRecordFromVendor` | Purchase Header | Nach Initialisierung vom Kreditor |
| `OnBeforePostPurchase` | Purch.-Post | Vor Buchungsdurchlauf |
| `OnAfterPostPurchase` | Purch.-Post | Nach Buchungsdurchlauf |
| `OnBeforePostPurchaseLine` | Purch.-Post Line | Vor Zeilenbuchung |
| `OnAfterPostPurchaseLine` | Purch.-Post Line | Nach Zeilenbuchung |
| `OnBeforeValidateTypeOnPurchLine` | Purchase Line | Vor Zeilentyp-Validierung |
| `OnBeforeInsertFromReqLine` | CarryOutAction | Vor Erzeugung aus Req. Line |
| `OnAfterCalcPlan` | Calc. Item Plan | Nach Planungslauf pro Artikel |
| `OnBeforeCarryOutActionMsg` | CarryOutAction | Vor Umwandlung einer Aktionsmeldung |

### 13.4 Dimensionen im Einkauf

Jeder Einkaufsbeleg kann mit zwei **Shortcut-Dimensionen** + zusätzlichen Dimensionen versehen werden:

- `Shortcut Dimension 1 Code` — z.B. Kostenstelle
- `Shortcut Dimension 2 Code` — z.B. Kostenträger
- Dimensionen werden vom Konto/Kreditor in die Belegzeilen kopiert
- Bei der Buchung werden sie in die Sachkonten- und Kreditorenposten übertragen

---

*Dokumentation erstellt am 28.06.2026 auf Basis von BC 28.1.49838.49886 (AT) Base App AL-Code.*
