---
title: "EDIFACT App v2.0 - Cloud-Ready mit Vereinheitlichten Staging & Dynamischem Mapping"
confluence_id: "320241666"
space: "BCEDI"
url: "https://mip-dev.atlassian.net/wiki/spaces/BCEDI/pages/320241666/EDIFACT+App+v2.0+-+Cloud-Ready+mit+Vereinheitlichten+Staging+Dynamischem+Mapping"
last_modified: "2026-03-02T08:03:13.970Z"
author: "Michael Platl"
fetched_at: "2026-06-24T22:00:38.092Z"
---

# EDIFACT App v2.0 - Cloud-Ready mit Vereinheitlichten Staging & Dynamischem Mapping

# EDIFACT App - Cloud-Ready Architecture v2.0

## 🚀 &Uuml;berarbeitete Spezifikation mit neuen Requirements

---

## 1️⃣ Cloud-Ready: EDIFACT Transfer Tabelle statt Dateisystem

### Architektur-&Auml;nderung

**ALT**: File Manager &rarr; Dateisystem Import/Export  
**NEU**: File Manager &rarr; EDIFACT Transfer Tabelle (Tab 50005) &rarr; API-agnostisch

### EDIFACT Transfer Table (Tab 50005)

Zentrale **Blob-basierte Tabelle** f&uuml;r alle Datei&uuml;bertragungen:

| Feld | Typ | Key | Beschreibung |
| --- | --- | --- | --- |
| **Transfer ID** | Integer | PK1 | Eindeutige ID |
| **Direction** | Option | PK2 | Inbound / Outbound |
| **File Content** | Blob | - | Komplette EDIFACT-Datei (max 2GB) |
| **File Name** | Text[250] | - | Dateiname f&uuml;r Referenz |
| **Status** | Option | - | New / Processing / Processed / Error |
| **Created DateTime** | DateTime | - | Upload-Zeitstempel |
| **Processed DateTime** | DateTime | - | Verarbeitungs-Zeitstempel |
| **Processing Method** | Code[30] | - | WholesaleAPI / FTP / Direct Upload / etc. |
| **Partner Code** | Code[20] | - | Partner-Referenz |
| **Message Type** | Code[20] | - | ORDERS, DESADV, INVOIC, etc. |
| **Error Message** | Text[1000] | - | Falls Status = Error |

### Datenfluss (Cloud-Ready)

```
INBOUND:
├─ External System
│  └─ POST /api/edifact-transfer (Blob, FileName, Partner, Direction=Inbound)
│     └─ Insert into Tab 50005 (Status=New)
├─ BC Background Job (Scheduled/Event-triggered)
│  └─ Read from Tab 50005 (Status=New)
│     └─ Parse → Mapping → Staging
│     └─ Update Status = Processed / Error

OUTBOUND:
├─ BC creates Sales Order / etc.
├─ Scheduled Job / Event
│  └─ Read from Tab 50005 (Direction=Outbound, Status=New)
│     └─ Encode EDIFACT
│     └─ Update Status = Processed
└─ External System
   └─ GET /api/edifact-transfer?filter=processed (Blob abrufen)
```

### Keine Dateisystem-Zugriffe!
- 
✅ APIs/Web Services laden Files in Tab 50005

- 
✅ BC verarbeitet aus Tab 50005

- 
✅ BC schreibt Outbound in Tab 50005

- 
✅ Externe Systeme holen Files aus Tab 50005

- 
✅ Cloud-Safe: Keine lokalen Pfade, kein Dateisystem-Code

---

## 2️⃣ Vereinheitlichte Staging-Tabellen

### Konzept: Eine Tabelle pro Standard f&uuml;r ALLE Message Types

**ALT:**
- 
Tab 50020/21: ORDERS

- 
Tab 50030/31: DESADV

- 
Tab 50040/41: INVOIC

- 
Tab 50060/61: ORDRSP

**NEU:**
- 
**Tab 50020**: D96 Staging Header (ALLE Message Types)

- 
**Tab 50021**: D96 Staging Line (ALLE Message Types)

- 
Message Type im Kopf &rarr; Filter f&uuml;r unterschiedliche Pages

### D96 Staging Header (Tab 50020) - VEREINHEITLICHT

| Feld | Typ | Key | Zweck |
| --- | --- | --- | --- |
| **Staging ID** | Integer | PK | Auto-increment |
| **Message Type** | Code[20] | - | **ORDERS / DESADV / INVOIC / ORDRSP** |
| **Transfer ID** | Integer | - | FK &rarr; Tab 50005 (Original-Datei) |
| **Standard Version** | Code[10] | - | D.96A, D.96B, D.99A, etc. |
| **EDI Partner Code** | Code[20] | - | Partner-Referenz |
| **Status** | Option | - | New / Valid / Invalid / Processed |
| **JSON Data** | Text (max 10MB) | - | **Geparste Daten als JSON** (flexibel) |
| **Created DateTime** | DateTime | - | Erzeugungszeitpunkt |
| **Processed DateTime** | DateTime | - | Verarbeitungszeitpunkt |
| **Message Reference** | Code[35] | - | Externe Bestellnummer / Referenz |
| **Partner Info** | Text[500] | - | Zus&auml;tz. Partner-Infos |

### D96 Staging Line (Tab 50021) - VEREINHEITLICHT

| Feld | Typ | Key | Zweck |
| --- | --- | --- | --- |
| **Staging ID** | Integer | PK1 | FK &rarr; Header |
| **Line No** | Integer | PK2 | Zeilennummer |
| **Item Reference** | Code[50] | - | Partner-Artikelnummer (bevor Mapping) |
| **Item Number** | Code[20] | - | BC Artikel (nach Mapping) |
| **Quantity** | Decimal | - | Menge |
| **Unit of Measure** | Code[10] | - | **VOR Mapping** (PC &rarr; wird zu STK) |
| **Unit Price** | Decimal | - | Preis (nur bei INVOIC relevant) |
| **JSON Data** | Text | - | Extra-Felder (Batch, Serial, etc.) |
| **Status** | Option | - | Valid / Invalid |

### Filterung f&uuml;r UI-Seiten

```
// ORDERS List Page Filter
StagingHeader.SetRange("Message Type", "Message Type"::ORDERS);
StagingHeader.SetRange(Status, Status::Valid);

// DESADV List Page Filter
StagingHeader.SetRange("Message Type", "Message Type"::DESADV);

// Dynamische Pages basierend auf Message Type
```

### Vorteil: JSON Data Feld
- 
Flexibel f&uuml;r unterschiedliche Message Types

- 
Keine fixen Spalten f&uuml;r jede Message Type

- 
Leicht erweiterbar ohne Tabellen-&Auml;nderungen

- 
Auch f&uuml;r spezielle Felder (z.B. Seriennummern, Chargennummern)

---

## 3️⃣ Field Mapping: EDIFACT &harr; Business Central

### Mapping Documentation (Tab 50008)

Zentrale Dokumentation WELCHE EDIFACT-Segmente zu WELCHEN BC-Feldern:

| EDIFACT Segment | Element | Qualifier | BC Target Field | Tabelle | Mapping-Typ |
| --- | --- | --- | --- | --- | --- |
| UNH | 1 | - | (nicht mappt) | - | Store Only |
| BGM | 1 | 220 | External Order No | Sales Header | Direct |
| BGM | 3 | - | Order Date | Sales Header | Format Convert (YYYYMMDD) |
| NAD | 1 | BY | Bill-to Customer No | Sales Header | Lookup Customer |
| NAD | 1 | DP | Ship-to Address | Sales Header | Lookup Ship-to Address |
| DTM | 1 | 2 | Requested Delivery Date | Sales Header | Format Convert |
| LIN | 2 | - | Item Reference | Sales Line | Dynamic (Tab 50007) |
| QTY | 1 | 21 | Quantity | Sales Line | Direct |
| UNM | 1 | - | Unit of Measure Code | Sales Line | **Dynamic UoM Mapping** |
| PRI | 1 | - | Unit Price | Sales Line | Direct |
| MOA | 1 | 203 | Amount | Sales Header | Direct |

### Mapping-Typen
1. 
**Direct** &rarr; 1:1 Copy (BGM Element 1 &rarr; External Order No)

2. 
**Format Convert** &rarr; Datumformat/Nummernformat &auml;ndern (BGM Element 3 &rarr; Order Date)

3. 
**Lookup** &rarr; Externe Tabelle abfragen (NAD Element 1 &rarr; Customer Lookup)

4. 
**Dynamic** &rarr; Tabelle 50007 (Unit of Measure, Item Reference)

5. 
**JSON Extract** &rarr; JSON-Feld parsen (f&uuml;r komplexe Strukturen)

6. 
**Conditional** &rarr; IF-Logik (z.B. nur bei bestimmtem Message Type)

---

## 4️⃣ Dynamisches Mapping-System

### EDIFACT Mapping Configuration (Tab 50007)

Flexible Table f&uuml;r Field-Transformationen **OHNE Code-&Auml;nderungen**:

| Field | Type | PK | Zweck |
| --- | --- | --- | --- |
| **Mapping Type** | Code[30] | PK1 | UoM_D96, ItemRef_Supplier, Currency, etc. |
| **Source Value** | Code[50] | PK2 | Wert aus EDIFACT (PC, CS, BOX, etc.) |
| **Target Value** | Code[50] | - | Wert in BC (STK, KAR, PAL, etc.) |
| **Partner Code** | Code[20] | PK3 (optional) | Wenn Partner-spezifisch |
| **Direction** | Option | - | Inbound / Outbound / Both |
| **Priority** | Integer | - | F&uuml;r mehrere Mappings (h&ouml;her = zuerst) |
| **Description** | Text[200] | - | Dokumentation |

### Beispiel: Unit of Measure Mapping

```
Mapping Type: UoM_D96
Direction: Inbound

Source (EDIFACT)  → Target (BC)
────────────────────────────
PC                → STK (Stück)
CS                → KAR (Kartons)
BOX               → KAR
PAL               → PAL
KG                → KG
```

### Beispiel: Item Reference Mapping (Lieferanten-spezifisch)

```
Mapping Type: ItemRef_SUPPLIER_123
Direction: Inbound
Partner Code: SUPPLIER_123

Source (Partner)  → Target (BC Item No)
──────────────────────────────────────
ABC-001          → ITEM-0001
ABC-002          → ITEM-0002
EAN-1234567890   → ITEM-0003 (via EAN Lookup)
```

### Processor-Logik mit Dynamic Mapping

```
codeunit 50100 "ORDERS Mapper" {
  procedure MapUnitOfMeasure(var StagingLine: Record "D96 Staging Line"; PartnerCode: Code[20]) {
    var
      MappingConfig: Record "EDIFACT Mapping Configuration";
      MappingType: Code[30] := 'UoM_D96';
    begin
      // Suche Mapping
      MappingConfig.SetRange("Mapping Type", MappingType);
      MappingConfig.SetRange("Source Value", StagingLine."Unit of Measure");
      MappingConfig.SetRange("Partner Code", PartnerCode);
      
      if MappingConfig.FindFirst() then
        StagingLine."Unit of Measure" := MappingConfig."Target Value"
      else
        // Fallback: Nutze Standard-Mapping
        MappingConfig.SetRange("Partner Code", '');
        if MappingConfig.FindFirst() then
          StagingLine."Unit of Measure" := MappingConfig."Target Value";
    end;
}
```

### Vorteil: Zero-Code Mapping
- 
✅ Neue Mappings &uuml;ber UI hinzuf&uuml;gen

- 
✅ Partner-spezifische Mappings ohne Code

- 
✅ Inbound + Outbound gleiche Tabelle

- 
✅ Leicht zu dokumentieren und auditable

---

## 5️⃣ Complete Field Reference - ORDERS Message Type

### Header-Level Mapping

| EDIFACT | Element | Desc. | BC Field | Type | Comment |
| --- | --- | --- | --- | --- | --- |
| UNH | 1 | Msg Ref | (Skip) | - | Store only in JSON |
| BGM | 1 | Order Ref | External Order No | Sales Header | Direct Copy |
| BGM | 3 | Order Date | Order Date | Sales Header | Format: YYYYMMDD &rarr; Date |
| NAD | BY | Buyer | Bill-to Customer | Sales Header | Lookup or Create |
| NAD | DP | Delivery Point | Ship-to Address | Sales Header | Address Lookup |
| DTM | 137 | Order Date | Order Date | Sales Header | Format Convert |
| DTM | 2 | Delivery Date | Requested Delivery Date | Sales Header | Format Convert |
| TOD | 1 | Terms | Incoterms Code | Sales Header | Mapping Tab 50007 |
| PAT | 1 | Payment Terms | Payment Terms Code | Sales Header | Mapping Tab 50007 |
| MOA | 203 | Total Amount | Total Amount | Sales Header | Decimal |

### Line-Level Mapping

| EDIFACT | Element | Desc. | BC Field | Type | Comment |
| --- | --- | --- | --- | --- | --- |
| LIN | 1 | Line No | Line No | Sales Line | Direct |
| LIN | 2 | Item ID | Item Reference | Sales Line | Dynamic Mapping (Tab 50007) |
| LIN | 3 | Item ID Alt | (skip) | - | Store in JSON |
| PIA | 1 | Item Alternate ID | Item Number | Sales Line | Lookup / Match |
| IMD | 3 | Description | Description | Sales Line | Direct |
| QTY | 21 | Order Qty | Quantity | Sales Line | Direct |
| UNM | 1 | Unit Code | Unit of Measure | Sales Line | **Dynamic UoM Mapping (Tab 50007)** |
| PRI | 1 | Unit Price | Unit Price | Sales Line | Direct (nur INVOIC) |
| DTM | 2 | Delivery Date | Requested Delivery Date | Sales Line | Format Convert |

---

## 6️⃣ Outbound: Business Central &rarr; EDIFACT

### Beispiel: Sales Order &rarr; ORDERS Message

```
BC Sales Order
├─ Header Fields
│  ├─ External Order No (BGM Element 1)
│  ├─ Order Date (BGM Element 3) → Format YYYYMMDD
│  ├─ Sell-to Customer (NAD Qualifier BY)
│  └─ Requested Delivery Date (DTM 2) → Format YYYYMMDD
└─ Lines
   ├─ Item No → Item Reference (LIN 2)
   │  └─ REVERSE Dynamic Mapping: STK → PC (if configured)
   ├─ Quantity (QTY 21)
   ├─ Unit of Measure → UNM 1
   │  └─ REVERSE Dynamic Mapping: STK → PC (Tab 50007, Direction=Outbound)
   └─ Unit Price (PRI 1)
```

### Reverse Mapping in Tab 50007

```
Mapping Type: UoM_D96
Direction: Outbound

Source (BC)  → Target (EDIFACT)
──────────────────────────────
STK (Stück)  → PC
KAR (Karton) → CS
PAL (Palette)→ PAL
```

---

## 📊 Neue Tabellen-&Uuml;bersicht

| Tabelle | Zweck | Cloud-Ready |
| --- | --- | --- |
| 50005 | EDIFACT Transfer (Blob-basiert) | ✅ API-agnostisch |
| 50007 | Mapping Configuration (Dynamic) | ✅ Zero-Code |
| 50008 | Mapping Documentation | ✅ F&uuml;r &Uuml;bersicht |
| 50020 | D96 Staging Header (VEREINHEITLICHT) | ✅ JSON Data Feld |
| 50021 | D96 Staging Line (VEREINHEITLICHT) | ✅ JSON Data Feld |

---

## 🎯 Zusammenfassung Neuer Anforderungen

### ✅ Cloud-Ready
- 
Tab 50005 f&uuml;r Blob-basierte Datei&uuml;bertragungen

- 
Keine Dateisystem-Zugriffe

- 
API-agnostisch (WholesaleAPI, FTP, Direct Upload m&ouml;glich)

### ✅ Vereinheitlichte Staging
- 
**Eine** Header-Tabelle f&uuml;r ALLE Message Types (ORDERS, DESADV, INVOIC, ORDRSP)

- 
Message Type Field f&uuml;r Filterung in unterschiedlichen Pages

- 
JSON Data Feld f&uuml;r flexible extra Daten

### ✅ Field Mapping Dokumentation
- 
Zentrale Dokumentation (Tab 50008) welches Feld wohin

- 
Mapping-Typen: Direct, Format Convert, Lookup, Dynamic, JSON Extract, Conditional

- 
Inbound und Outbound unterst&uuml;tzt

### ✅ Dynamisches Mapping
- 
Tab 50007 f&uuml;r Unit of Measure, Item Reference, Currency, etc.

- 
Partner-spezifische Mappings m&ouml;glich

- 
Zero-Code: Admin kann neue Mappings &uuml;ber UI hinzuf&uuml;gen

- 
Bidirektional: Inbound + Outbound in gleicher Tabelle

---

## 📄 Dateien zur Verf&uuml;gung
- 
**EDIFACT_CloudReady_Revised.docx** - Detaillierte Spezifikation mit Tabellen-Strukturen

- 
**EDIFACT_Specification.docx** - Original Architektur (f&uuml;r Referenz)

- 
[**README.md**](http://README.md) - &Uuml;bersichtliche Zusammenfassung

---

**Status**: Cloud-Ready Architecture Ready for Development  
**Version**: 2.0  
**Datum**: 2. M&auml;rz 2026
