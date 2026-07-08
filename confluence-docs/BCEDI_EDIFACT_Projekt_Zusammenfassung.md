---
title: "EDIFACT App Projekt - Zusammenfassung und Übersicht"
confluence_id: "320634881"
space: "BCEDI"
url: "https://mip-dev.atlassian.net/wiki/spaces/BCEDI/pages/320634881/EDIFACT+App+Projekt+-+Zusammenfassung+und+bersicht"
last_modified: "2026-03-02T07:55:46.416Z"
author: "Michael Platl"
fetched_at: "2026-06-24T22:00:30.792Z"
---

# EDIFACT App Projekt - Zusammenfassung und Übersicht

# EDIFACT App Projekt - Zusammenfassung und &Uuml;bersicht

## 📌 Projekt&uuml;bersicht

Auf dieser Seite finden Sie alle Ressourcen und Dokumente f&uuml;r die Entwicklung der EDIFACT Integration App f&uuml;r Microsoft Dynamics 365 Business Central.

---

## 📚 Dokumentation

### Hauptdokumente (Word-Format)

| Dokument | Beschreibung | Status |
| --- | --- | --- |
| **EDIFACT_Specification.docx** | Vollst&auml;ndige technische Spezifikation mit App-Struktur, Architektur und Design | ✅ Verf&uuml;gbar |
| **EDIFACT_Tables_Specification.docx** | Detaillierte Tabellen-Definitionen mit Feldlisten und Relationen | ✅ Verf&uuml;gbar |

### Confluence-Seiten

#### 1. **EDIFACT Integration App Spezifikation f&uuml;r Business Central**
- 
&Uuml;berblick der gesamten App-Architektur

- 
App-Struktur und Abh&auml;ngigkeiten

- 
Base App Programmierung

- 
Standard-spezifische Apps (D96A, D96B)

- 
Staging Tabellen Konzept

- 
Verarbeitungsprozesse (Inbound/Outbound)

- 
Fehlerbehandlung

- 
Benutzerschnittstelle

- 
Roadmap und Implementierungs-Phasen

#### 2. **EDIFACT App - Implementierungs-Richtlinien und AL-Code Patterns**
- 
Dateistruktur und Ordnerorganisation

- 
Codeunit-Template Struktur

- 
Mapper und Processor Patterns

- 
Error Handling Best Practices

- 
Tabellen-Design Richtlinien

- 
Data Flow Diagramm

- 
Unit Test-Struktur

- 
Deployment Checklist

---

## 🏗️ App-Architektur-&Uuml;bersicht

```
┌─────────────────────────────────────────────────────┐
│         EDIFACT Integration App System              │
└─────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────┐
│            EDIFACT Base App (Foundation)            │
│  • Parser & Encoder                                │
│  • Validator                                       │
│  • File Manager                                    │
│  • Error Handler                                   │
│  • Configuration Tables                            │
└────────────────────────────────────────────────────┘
         ↑              ↑              ↑
         │              │              │
         │              │              │
    ┌────────┐     ┌─────────┐   ┌─────────┐
    │ D96 App│     │D99+ App │   │ Custom  │
    │(D96A,  │     │(D99A,   │   │ App     │
    │D96B)   │     │D99B,... │   │         │
    └────────┘     └─────────┘   └─────────┘
```

### App-Komponenten

#### **EDIFACT Base App**
- 
**Codeunits**: Parser, Encoder, Validator, FileManager, ErrorHandler

- 
**Tables**: Setup, MessageTypeSetup, PartnerSetup, ImportHeader, ErrorLog

- 
**Pages**: Setup-Karten, Partner-Listen, Error-Logs

#### **EDIFACT D96 App** (abh&auml;ngig von Base)
- 
**Mapper Codeunits**: ORDERS, ORDRSP, DESADV, INVOIC

- 
**Processor Codeunits**: ORDERS, ORDRSP, DESADV, INVOIC

- 
**Staging Tables**: Header und Line-Tabellen f&uuml;r jede Message-Type

- 
**Pages**: Staging-Listen und Karten f&uuml;r Benutzer

#### **EDIFACT D99+ App** (abh&auml;ngig von Base)
- 
Analoge Struktur wie D96 App f&uuml;r neuere Standards

---

## 🔄 Workflow: Von Datei zu Business Central-Dokument

### Inbound-Verarbeitung (7 Schritte)

```
1. FILE IMPORT
   ↓
2. PARSING (in Segmente zerlegen)
   ↓
3. VALIDATION (Syntax-Prüfung)
   ↓
4. MAPPING (zu Staging Tabellen)
   ↓
5. USER REVIEW (Benutzer korrigiert Falls nötig)
   ↓
6. PROCESSING (zu BC-Dokumenten)
   ↓
7. ARCHIVING (Original-Datei archivieren)
```

---

## 💾 Staging Tabellen - Das Kerkonzept

Die Staging Tabellen sind das Herzst&uuml;ck des Systems und erm&ouml;glichen:

### ✅ Vorteile des Staging-Ansatzes
- 
**Benutzerfreundlichkeit**: Benutzer k&ouml;nnen importierte Daten sehen und korrigieren

- 
**Fehlerbehandlung**: Validierungsfehler k&ouml;nnen vor der Verarbeitung behoben werden

- 
**Flexibilit&auml;t**: Neue Nachrichtentypen k&ouml;nnen ohne Base-App-&Auml;nderungen hinzugef&uuml;gt werden

- 
**Transparenz**: Vollst&auml;ndiger Audit Trail von Import bis Verarbeitung

- 
**Rollback**: Fehlerhafte Importe k&ouml;nnen einfach r&uuml;ckg&auml;ngig gemacht werden

### Staging Tabellen pro Nachrichtentyp

| Message Type | Header-Tabelle | Line-Tabelle | Beschreibung |
| --- | --- | --- | --- |
| ORDERS | Tab 50020 | Tab 50021 | Bestellungen |
| DESADV | Tab 50030 | Tab 50031 | Versand-Avis |
| INVOIC | Tab 50040 | Tab 50041 | Rechnungen |
| ORDRSP | Tab 50060 | Tab 50061 | Bestellbest&auml;tigung |

---

## 🛡️ Fehlerbehandlung - 3-Ebenen-Ansatz

### Level 1: EDIFACT Syntax-Validierung
- 
Segment-Struktur pr&uuml;fen

- 
Trennzeichen-Konsistenz

- 
UNH-UNT Z&auml;hler abgleichen

### Level 2: Business Logic Validierung
- 
Artikel existiert in BC

- 
Partner ist konfiguriert

- 
Mengen > 0

- 
Preise sind g&uuml;ltig

### Level 3: Business Central Spezifisch
- 
Lagerbest&auml;nde ausreichend

- 
Kreditlimiten beachtet

- 
Benutzergenehmigungen vorhanden

---

## 🧑&zwj;💻 Implementierungs-Phasen

### **Phase 1: Base App** (Wochen 1-4)

1
044f77aa-ce36-4301-9ae4-0b539d288b5f
complete
Tabellen-Design

2
f7a04f1a-cb17-4af3-98ad-7a4a7e1dce26
complete
Parser & Encoder Codeunits

3
143d7ae0-e2c2-4c93-8073-be83ad3550dc
complete
Validator & Error Handler

4
3490b50a-308c-4665-a147-071987a417ac
complete
File Manager

5
f82e0d63-6785-445f-8b0a-569e5cbbb7fb
incomplete
Unit Tests

6
f4163398-681c-42d9-8c96-c3f37f59f745
incomplete
Dokumentation

### **Phase 2: D96 App** (Wochen 5-10)

7
5912f2a4-7b62-421d-a42f-ecaf3ee4a4ed
incomplete
Mapper Codeunits (ORDERS, DESADV, INVOIC, ORDRSP)

8
408cbf5d-7122-4576-a21a-e9c3eda8ba44
incomplete
Processor Codeunits

9
c3fa86b5-60c9-45ce-ac8e-42c8a3dd5b54
incomplete
Staging Tabellen

10
ff487dd3-5a64-4c62-8649-400acb3f72ad
incomplete
UI Pages (Listen, Karten)

11
b3f0d1e8-51e2-4723-99bc-92418c4d9ce8
incomplete
Integration Tests

12
2a3fe9e8-bba8-47b7-95e2-0b59850d29fc
incomplete
UAT mit Partner

### **Phase 3: D99+ App** (Wochen 11+)

13
e4713b93-6aa5-49d5-9622-df4e6279b1b5
incomplete
Analoge Struktur wie D96

14
0cbda28c-5ee4-4601-965b-75be29699b74
incomplete
Testing & Dokumentation

---

## 📊 Wichtigste Tabellen auf einen Blick

### Base App Tables

| Tabelle | ID | Zweck |
| --- | --- | --- |
| EDIFACT Setup | 50000 | Zentrale Konfiguration |
| EDIFACT Message Type Setup | 50001 | Verf&uuml;gbare Nachrichtentypen |
| EDIFACT Partner Setup | 50002 | Partner-Konfiguration |
| EDIFACT Import Header | 50010 | Master f&uuml;r alle Imports |
| EDIFACT Error Log | 50050 | Fehler-Tracking |

### D96 App Tables - Staging

| Tabelle | ID | Zweck |
| --- | --- | --- |
| ORDERS Staging Header | 50020 | Bestellungs-Kopf |
| ORDERS Staging Line | 50021 | Bestellungs-Zeilen |
| DESADV Staging Header | 50030 | Versand-Kopf |
| DESADV Staging Line | 50031 | Versand-Zeilen |
| INVOIC Staging Header | 50040 | Rechnungs-Kopf |
| INVOIC Staging Line | 50041 | Rechnungs-Zeilen |

---

## 🚀 Key Features

### Mapper & Processor Pattern
- 
**Mapper**: EDIFACT &rarr; Staging Tabellen

- 
**Processor**: Staging Tabellen &rarr; BC Dokumente

### Error Handling
- 
Strukturiertes Error Logging

- 
Retry-Mechanismus

- 
Benutzer-freundliche Error Messages

### Konfigurierbarkeit
- 
Partner-spezifische Mappings

- 
Flexible Nachrichtentyp-Unterst&uuml;tzung

- 
Custom Extensions ohne Code-&Auml;nderungen

### Audit & Compliance
- 
Vollst&auml;ndiger Import-History

- 
Fehler-Tracking und Protokollierung

- 
Archive mit Aufbewahrungsrichtlinien

---

## 📖 Verwendung der Dokumentation

### F&uuml;r Entwickler
1. 
**Technische Spezifikation** lesen (EDIFACT_Specification.docx)

2. 
**Implementierungs-Richtlinien** studieren (Confluence-Seite)

3. 
**Tabellen-Details** anschauen (EDIFACT_Tables_Specification.docx)

4. 
**AL-Code Patterns** als Template verwenden

### F&uuml;r Project Manager
1. 
**Roadmap** in Spezifikation (Phase 1-3)

2. 
**Deployment Checklist** f&uuml;r Qualit&auml;tsicherung

3. 
Regelm&auml;&szlig;ige Status-Updates anhand der Checklist

### F&uuml;r Business Users
1. 
**Staging Tabellen** verstehen (Benutzer-Handbook ben&ouml;tigt)

2. 
**Fehlerbehandlung** lernen

3. 
**Import-Prozess** nachvollziehen

---

## 🔗 Weitere Ressourcen

### UN/EDIFACT Standards
- 
**UNECE D.96A Directory**: [https://unece.org/uncefact/unedifact/2021-2024](https://unece.org/uncefact/unedifact/2021-2024)

- 
**EDIFACTORY**: Segment und Message-Verzeichnisse

- 
**XEDI**: Online-Reference f&uuml;r Nachrichtentypen

### Business Central AL Development
- 
**Microsoft Docs**: [https://docs.microsoft.com/dynamics365/business-central/](https://docs.microsoft.com/dynamics365/business-central/)

- 
**AL Language Guide**: Syntax und Best Practices

- 
**Community**: GitHub, YouTube, Forums

---

## ❓ FAQs

### F: Warum Staging Tabellen statt direkter Verarbeitung?

**A**: Staging Tabellen erm&ouml;glichen Benutzerkontrolle, Fehlerbehandlung und Transparenz. Benutzer k&ouml;nnen Daten &uuml;berpr&uuml;fen und korrigieren, bevor BC-Dokumente erstellt werden.

### F: Wie werden neue Nachrichtentypen hinzugef&uuml;gt?

**A**:
1. 
Mapping-Codeunit f&uuml;r den Typ erstellen

2. 
Staging Header/Line Tabellen definieren

3. 
Processor-Codeunit implementieren

4. 
Keine &Auml;nderungen an Base App n&ouml;tig!

### F: Wie ist die Fehlerbehandlung organisiert?

**A**: 3-stufig: EDIFACT-Syntax &rarr; Business Logic &rarr; BC-Spezifisch. Fehler werden im Error Log protokolliert und k&ouml;nnen reprocessed werden.

### F: Unterst&uuml;tzt das System Outbound (BC &rarr; EDIFACT)?

**A**: Ja! Mapper haben `MapToEDIFACT()` Methoden, die BC-Dokumente zur&uuml;ck zu EDIFACT konvertieren.

---

## 📋 Checkliste f&uuml;r Entwickler-Kickoff

15
bee97538-ce15-4ca7-892c-07d5df2322ae
incomplete
Alle Dokumentationen gelesen

16
8e0102a4-db09-4e05-882e-088fa9aa87e0
incomplete
Base App Tabellen-Struktur verstanden

17
18629c6d-4364-48c9-b402-6fd22d075f71
incomplete
Parser/Encoder Codeunits Design reviews abgeschlossen

18
c80ce4b1-5da6-411f-a34f-e62455f97a35
incomplete
Development Environment eingerichtet

19
e3af3ac0-9d06-44e9-9775-4ce97fc51177
incomplete
Unit Test Framework vorbereitet

20
7ee6a597-5571-4c0e-aad0-80d4bf42625f
incomplete
Git Repository angelegt

21
ee1fb1d4-ede5-4a01-9b63-9c744a6eaa56
incomplete
CI/CD Pipeline geplant

22
ebe8a4e0-a2f5-4a98-a988-b4cb03afba7d
incomplete
Kick-off Meeting mit Stakeholdern

---

## 📞 Kontakt & Support

Bei Fragen zur Spezifikation oder Implementierung kontaktieren Sie das Projekt-Team &uuml;ber diese Confluence-Seite oder melden Sie sich &uuml;ber eine neue Confluence-Seite an.

---

**Letzte Aktualisierung**: 2. M&auml;rz 2026
**Spezifikations-Version**: 1.0
**Status**: Ready for Development
