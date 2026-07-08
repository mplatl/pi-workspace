---
title: "EDIFACT Integration App Spezifikation für Business Central"
confluence_id: "320536577"
space: "BCEDI"
url: "https://mip-dev.atlassian.net/wiki/spaces/BCEDI/pages/320536577/EDIFACT+Integration+App+Spezifikation+f+r+Business+Central"
last_modified: "2026-03-02T07:53:53.233Z"
author: "Michael Platl"
fetched_at: "2026-06-24T22:00:30.863Z"
---

# EDIFACT Integration App Spezifikation für Business Central

# EDIFACT Integration App f&uuml;r Business Central

## Technische Spezifikation - Version 1.0

---

## 📋 &Uuml;berblick und Architektur

### Zielstellung

Die EDIFACT Integration App erm&ouml;glicht Business Central die nahtlose Verarbeitung elektronischer Gesch&auml;ftsdokumente nach dem UN/EDIFACT-Standard. Das System folgt einem modularen Ansatz mit einer gemeinsamen Base App und standard-spezifischen Apps f&uuml;r verschiedene EDIFACT-Versionen.

### Architektur-Prinzipien
- 
**Modularit&auml;t**: Trennung der Concerns in Base und Standard-spezifischen Apps

- 
**Wiederverwendbarkeit**: Gemeinsame Funktionalit&auml;t in Base App

- 
**Staging-First Ansatz**: Datenzerlegen vor Verarbeitung

- 
**User-Freundlichkeit**: Einfache Fehlerbehandlung und Korrekturen

---

## 🏗️ App-Struktur

### App-&Uuml;bersicht

| App Name | Abh&auml;ngigkeiten | Hauptaufgaben |
| --- | --- | --- |
| **EDIFACT Base** | Keine | &bull; Parser/Encoder
&bull; Staging Tabellen
&bull; Validierung |
| **EDIFACT D96** | EDIFACT Base | &bull; D96A & D96B Unterst&uuml;tzung
&bull; Message-Mapping |
| **EDIFACT D99+** | EDIFACT Base | &bull; D99A, D99B, D03A+ Unterst&uuml;tzung |

### App-Abh&auml;ngigkeiten

**EDIFACT Base App**
- 
Microsoft Dynamics 365 Business Central

- 
System Application

**EDIFACT D96 App**
- 
EDIFACT Base

**EDIFACT D99+ App**
- 
EDIFACT Base

---

## 🔧 Base App &ndash; Allgemeine Programmierung

### Konfigurationstabellen

#### EDIFACT Setup (Tab 50000)

Allgemeine EDIFACT-Konfiguration mit:
- 
Import Path, Export Path

- 
Archive Settings, Logging Settings

- 
Default Separators (UNA Characters)

#### EDIFACT Message Type Setup (Tab 50001)

Definiert verf&uuml;gbare Nachrichtentypen pro Standard:
- 
Message Code (ORDERS, ORDRSP, DESADV, INVOIC, etc.)

- 
Standard Version, Direction (Inbound/Outbound)

- 
Staging Table Reference, Processing Logic

#### EDIFACT Partner Setup (Tab 50002)

Partner-spezifische Konfiguration:
- 
EDI Partner ID, GLN, Company Code

- 
Supported Standards und Message Types

- 
Partner-spezifische Parser/Encoder Settings

### Codeunit-Struktur

#### Parser/Encoder Codeunits

**EDIFACT Parser (Codeunit 50000)**
- 
`ParseMessage(MessageText)`: Gibt strukturierte Segmente zur&uuml;ck

- 
`ValidateUNA(UNAText)`: Validiert UNA-Segment

- 
`ExtractSegment(MessageText, SegmentTag)`: Filtert spezifische Segmente

**EDIFACT Encoder (Codeunit 50001)**
- 
`BuildMessage(SegmentLines)`: Konvertiert zu EDIFACT-Format

- 
`BuildSegment(SegmentTag, Fields)`: Erstellt einzelne Segmente

#### Validierungs-Codeunits

**EDIFACT Validator (Codeunit 50002)**
- 
`ValidateMessage(MessageHeader)`: Pr&uuml;ft UNH-UNT Konsistenz

- 
`ValidateSegment(SegmentText)`: Pr&uuml;ft Segmentstruktur

- 
`ValidateSeparators()`: Pr&uuml;ft konsistente Verwendung von Trennzeichen

#### Import/Export-Management

**EDIFACT File Manager (Codeunit 50003)**
- 
`ImportFile(FilePath)`: Liest EDIFACT-File von Festplatte/FTP

- 
`ExportFile(MessageContent, FilePath)`: Speichert EDIFACT-File

- 
`ArchiveFile(FileName)`: Kopiert in Archiv

---

## 📦 Standard-spezifische Apps (D96A, D96B)

### EDIFACT D96 App

#### Mapping-Codeunits

**ORDERS Mapper (Codeunit 50100)**
- 
`MapFromEDIFACT(RawSegments)`: Konvertiert EDIFACT zu Business Central

Zerlegt BGM, NAD, LIN, QTY, PRI Segmente

- 
F&uuml;llt ORDERS Staging Tabelle

`MapToEDIFACT(SalesOrderHeader)`: Konvertiert BC zu EDIFACT
- 
Erstellt BGM, NAD, LIN, QTY, PRI Segmente

**ORDRSP Mapper (Codeunit 50101)**
- 
&Auml;hnliche Struktur wie ORDERS

- 
Zus&auml;tzliche Felder: DTM (Lieferdatum), MOA (Mengen)

**DESADV Mapper (Codeunit 50102)**
- 
Mappt auf Shipping/Warenausgang

- 
CPS (Konsignation), PAC (Verpackung), GIN (Seriennummern)

**INVOIC Mapper (Codeunit 50103)**
- 
Mappt auf Verkaufsrechnung

- 
MOA (Betr&auml;ge), TAX (Steuern), RFF (Referenzen)

#### Processing-Codeunits

**ORDERS Processor (Codeunit 50200)**
- 
`ProcessStagingData()`: Konvertiert Staging zu Sales Order

Header-Validierung, Line-Validierung

- 
Create Sales Order Header/Lines

- 
Fehlerbehandlung mit Error Logging

**ORDRSP Processor (Codeunit 50201)**
- 
Best&auml;tigt oder lehnt ab, aktualisiert Sales Order

**DESADV Processor (Codeunit 50202)**
- 
Erstellt Posted Sales Shipment oder Warehouse Shipment

**INVOIC Processor (Codeunit 50203)**
- 
Erstellt Sales Invoice aus Staging

---

## 📊 Staging Tabellen Konzept

### Grundkonzept

Staging Tabellen dienen als Zwischenschicht zwischen geparsten EDIFACT-Daten und Business Central-Dokumenten:
- 
**Fehlerbehandlung**: Benutzer k&ouml;nnen Daten korrigieren, bevor Sie verarbeitet werden

- 
**Nachverfolgung**: Vollst&auml;ndiger Audit Trail

- 
**Flexibilit&auml;t**: Standard-spezifische Anpassungen ohne Base App-&Auml;nderungen

### Generische Staging-Header Tabelle

#### EDIFACT Import Header (Tab 50010)

| Feld | Datentyp | Schl&uuml;ssel | Beschreibung |
| --- | --- | --- | --- |
| Import ID | Integer | Ja | Eindeutige ID pro Import |
| Message Type | Code[20] | - | ORDERS, ORDRSP, etc. |
| Standard Version | Code[10] | - | D.96A, D.96B, D.99B, etc. |
| Partner ID | Code[20] | - | EDI Partner-Referenz |
| File Name | Text[250] | - | Ursprungsdateiname |
| Status | Option | - | Pending, Processing, Processed, Error |
| Imported Date | DateTime | - | Import-Zeitstempel |
| Error Message | Text[1000] | - | Fehlerbeschreibung falls Status = Error |

### Message-spezifische Staging Tabellen

#### ORDERS Staging Header (Tab 50020)
- 
Verkn&uuml;pfung mit EDIFACT Import Header (Import ID - Foreign Key)

- 
Kophdaten aus BGM und NAD Segmenten:

Order Reference, Order Date, Requested Delivery Date

- 
Buyer ID, Supplier ID, Ship-To Address

- 
Currency Code, Incoterms, Payment Terms

Status: Ready for Processing, Under Review, Processed

#### ORDERS Staging Line (Tab 50021)
- 
Verkn&uuml;pfung mit ORDERS Staging Header

- 
Zeilendaten aus LIN, QTY, PRI Segmenten:

Line Number, Item Reference, Item Number

- 
Order Quantity, Unit of Measure, Unit Price

- 
Net Amount, Tax Amount, Line Amount

- 
Requested Delivery Date (per Line)

#### DESADV Staging Header (Tab 50030)
- 
Basierend auf CPS, PAC, DTM Segmenten

Shipment Reference, Shipment Date, Delivery Date

- 
Carrier, Tracking Number

Verpackungshierarchie: Pallet Count, Box Count, Serial Numbers (GIN)

#### DESADV Staging Line (Tab 50031)
- 
Item Details, Quantities, Packaging

Item Reference, Shipped Quantity

- 
Batch Number, Serial Number

#### INVOIC Staging Header (Tab 50040)
- 
Aus BGM, NAD, DTM Segmenten

Invoice Number, Invoice Date, Due Date

- 
Bill-To, Ship-To, Amount Details

#### INVOIC Staging Line (Tab 50041)
- 
Aus LIN, QTY, PRI, TAX Segmenten

Item Reference, Quantity, Unit Price

- 
Net Amount, Tax Code, Tax Rate, Tax Amount

---

## ⚙️ Verarbeitungsprozesse

### Inbound-Workflow
1. 
**Datei-Import** &rarr; File Manager liest EDIFACT-File

2. 
**Parsing** &rarr; Parser extrahiert Segmente (UNH, BGM, NAD, LIN, etc.)

3. 
**EDIFACT-Validierung** &rarr; Validator pr&uuml;ft Segmentstruktur

4. 
**Mapping** &rarr; Message-spezifischer Mapper (z.B. ORDERS Mapper)

5. 
**Staging-Speicherung** &rarr; Daten in Staging Header/Line Tabellen

6. 
**Benutzer-Review** &rarr; User korrigiert Staging Daten falls n&ouml;tig

7. 
**Processing** &rarr; Message-spezifischer Processor (z.B. ORDERS Processor)

8. 
**BC-Dokumenterstellung** &rarr; Verkaufsauftrag, Rechnung, etc.

9. 
**Archivierung** &rarr; Datei in Archiv kopiert

### Outbound-Workflow
1. 
**BC-Dokument-Ausl&ouml;ser** &rarr; Sales Order erstellt/gepostet

2. 
**Mapping zu Staging** &rarr; ORDERS Mapper erstellt Staging-Eintr&auml;ge

3. 
**BC-Validierung** &rarr; Validierung der BC-Daten

4. 
**EDIFACT-Codierung** &rarr; Encoder erstellt EDIFACT-File

5. 
**Datei-Export** &rarr; File Manager speichert File

6. 
**Versand** &rarr; An EDI Partner

### Fehlerbehandlung

#### Error Logging Tabelle (Tab 50050)
- 
Verweis auf Import Header

- 
Error Type: Parsing Error, Validation Error, Business Logic Error

- 
Error Description

- 
Severity Level: Info, Warning, Error

- 
Can Be Retried: Ja/Nein

#### Fehlerbehandlungs-Codeunit

**EDIFACT Error Handler (Codeunit 50004)**
- 
`LogError(ErrorMsg, Severity, ImportID)`

- 
`RetryProcessing(ImportID)`

- 
`GetErrorHistory(ImportID)`

---

## ✅ Fehlerbehandlung und Validierung

### Validierungsebenen

**Level 1: EDIFACT Syntax-Validierung**
- 
Segment-Struktur

- 
Trennzeichen-Konsistenz

- 
UNH-UNT Z&auml;hler

**Level 2: Business Logic Validierung**
- 
Artikel existiert in BC

- 
Partner existiert

- 
Mengen > 0

- 
Preise korrekt

**Level 3: Business Central Spezifisch**
- 
Lagerbest&auml;nde ausreichend (falls ben&ouml;tigt)

- 
Kreditlimiten

- 
Benutzergenehmigungen

---

## 🖥️ Benutzerschnittstelle

### Seiten

**EDIFACT Import List (Page 50000)**
- 
Zeigt alle importierten Files

- 
Filter nach Status, Message Type, Date

- 
Aktion: View Details, View Errors, Retry, Delete

**EDIFACT Import Details (Page 50001)**
- 
Header-Informationen

- 
Verkn&uuml;pfte Staging-Eintr&auml;ge

- 
Fehlerlog

- 
Aktion: Process, Edit Staging, View Raw EDIFACT

**ORDERS Staging List (Page 50010)**
- 
Zeigt alle ORDERS Staging-Eintr&auml;ge

- 
Benutzer kann Header/Lines bearbeiten

- 
Aktion: Create Order, Validate, Delete

**ORDERS Staging Card (Page 50011)**
- 
Detailansicht f&uuml;r einen Staging-Eintrag

- 
Editierbare Felder

- 
Validierungsmeldungen

- 
Aktion: Process, Validate, Cancel

**EDIFACT Setup (Page 50020)**
- 
Konfigurationsseite

- 
Partner Setup

- 
Message Type Setup

---

## 📈 Zusammenfassung und Roadmap

### Implementierungs-Phasen

**Phase 1: Base App**
- 
Parser, Encoder, Validator

- 
Setup Tabellen, Error Logging

- 
File Manager

**Phase 2: D96 App**
- 
ORDERS Mapper & Processor

- 
DESADV Mapper & Processor

- 
INVOIC Mapper & Processor

- 
UI-Seiten

**Phase 3: Weitere Standards (D99+)**
- 
Analoge Struktur f&uuml;r weitere Versionen

### Vorteile dieser Architektur
- 
**Modularer Aufbau**: Einfache Wartung und Erweiterung

- 
**Wiederverwendbarkeit**: Base App f&uuml;r alle Standards

- 
**Benutzerfreundlich**: Staging Tabellen f&uuml;r Kontrolle und Korrekturen

- 
**Transparent**: Vollst&auml;ndiger Audit Trail

- 
**Skalierbar**: Einfach weitere Standards und Partner hinzuf&uuml;gbar

---

## 📝 N&auml;chste Schritte
1. 
Detaillierte Tabellen-Definitionen pro App

2. 
Codeunit-Implementierung und Unit-Tests

3. 
UI-Seiten-Design und User Experience

4. 
Integration mit Business Central Standard-Workflows

5. 
Dokumentation und Benutzerhandbuch
