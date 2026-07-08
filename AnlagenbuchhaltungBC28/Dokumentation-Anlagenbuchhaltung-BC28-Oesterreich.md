# Anlagenbuchhaltung Österreich — Business Central 28

## Vollständige technische und fachliche Dokumentation

**Version:** 1.0 | **Basis:** BC 28.1.49838.49886 (AT) | **Zielgruppe:** Buchhalter, ERP-Consultants, AL-Entwickler

---

## Inhaltsverzeichnis

1. [Einleitung](#1-einleitung)
2. [Business Central Anlagenbuchhaltung — Architektur](#2-business-central-anlagenbuchhaltung--architektur)
3. [AL-Code Analyse](#3-al-code-analyse)
4. [Österreichische Anlagenbuchhaltung (UGB + Steuerrecht)](#4-österreichische-anlagenbuchhaltung-ugb--steuerrecht)
5. [Anlagenbücher in Österreich](#5-anlagenbücher-in-österreich)
6. [Business Central Mapping auf österreichische Anforderungen](#6-business-central-mapping-auf-österreichische-anforderungen)
7. [Buchhalterische Prozesse (End-to-End)](#7-buchhalterische-prozesse-end-to-end)
8. [Reporting](#8-reporting)
9. [Anhang: AL-Code Referenz](#9-anhang-al-code-referenz)

---

## 1. Einleitung

### 1.1 Zweck dieser Dokumentation

Diese Dokumentation beschreibt die vollständige technische und fachliche Umsetzung der Anlagenbuchhaltung in Microsoft Dynamics 365 Business Central 28, spezifisch angepasst an die **österreichischen Anforderungen nach UGB (Unternehmensgesetzbuch) und Steuerrecht**. Sie verbindet die **AL-Codebasis** der Base App mit der **österreichischen Bilanzierungspraxis** und dient als Nachschlagewerk für:

- **Buchhalter:** Fachliche Prozesse und gesetzliche Grundlagen
- **ERP-Consultants:** Einrichtung und Konfiguration
- **AL-Entwickler:** Technische Referenz, Event-Subscription, Erweiterungen

### 1.2 Methodik

Die Analyse basiert auf:
- **AL-Code der Base App:** Version 28.1.49838.49886 (AT), extrahiert aus BC Artifacts
- **Qdrant RAG-Index:** Hybrid-Suche (BM25 + Vektor) über 117.296 Code-Chunks
- **Fachwissen:** UGB, EStG 1988, EStR 2000, AFRAC-Stellungnahmen

---

## 2. Business Central Anlagenbuchhaltung — Architektur

### 2.1 Modul-Übersicht

Das Anlagenmodul (Fixed Assets) ist in **fünf Subsysteme** gegliedert:

| Subsystem | Ordner | Funktion |
|---|---|---|
| **FixedAsset** | `FixedAssets/FixedAsset/` | Anlagenstamm, Journale, Ledger, Umbuchung |
| **Depreciation** | `FixedAssets/Depreciation/` | AfA-Bücher, AfA-Methoden, AfA-Berechnung |
| **Insurance** | `FixedAssets/Insurance/` | Versicherungsverwaltung |
| **Maintenance** | `FixedAssets/Maintenance/` | Wartungsverwaltung |
| **Setup** | `FixedAssets/Setup/` | Einrichtung (Klassen, Subklassen, Standorte) |

Zusätzlich existieren:
- **Reports:** Standardberichte und lokale AT-Berichte in `Local/FixedAssets/Reports/`
- **Tests:** Umfangreiche Test-Codeunits in `Test/Tests-Fixed Asset/`

### 2.2 Kern-Datenmodell

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         ANLAGENSTAMMDATEN                                │
│                                                                          │
│  ┌──────────────┐    ┌──────────────────┐    ┌────────────────────┐      │
│  │ FASetup      │    │ FA Class         │    │ FA Subclass        │      │
│  │ (5603)       │    │ (5609)           │    │ (5608)             │      │
│  └──────┬───────┘    └────────┬─────────┘    └─────────┬──────────┘      │
│         │                    │                        │                  │
│         │     ┌──────────────▼────────────────────────▼────────┐        │
│         │     │              Fixed Asset (5600)                │        │
│         │     │  - No., Description, FA Class/Subclass Code    │        │
│         │     │  - FA Posting Group, Location Code             │        │
│         │     │  - BWR Depr. Book Code, Prem Depr. % (AT)     │        │
│         │     └──────────────┬─────────────────────────────────┘        │
│         │                    │ 1:N (pro Abschreibungsbuch)               │
│         │     ┌──────────────▼─────────────────────────────────┐        │
│         │     │         FA Depreciation Book (5612)            │        │
│         │     │  - FA No., Depreciation Book Code              │        │
│         │     │  - Depreciation Method, Starting Date          │        │
│         │     │  - No. of Depreciation Years/Months            │        │
│         │     │  - Straight-Line %, Declining-Balance %        │        │
│         │     │  - Ending Book Value, Salvage Value %          │        │
│         │     └──────────────┬─────────────────────────────────┘        │
│         │                    │                                          │
│  ┌──────▼───────┐    ┌───────▼──────────┐    ┌──────────────────┐       │
│  │ FA Posting   │    │ Depreciation     │    │ FA Journal Line  │       │
│  │ Group (5606) │    │ Book (5611)      │    │ (5621)           │       │
│  └──────┬───────┘    └───────┬──────────┘    └────────┬─────────┘       │
│         │                    │                        │                  │
│         │     ┌──────────────▼────────────────────────▼────────┐        │
│         │     │            FA Ledger Entry (5601)              │        │
│         │     │  - Entry No., FA No., Depr. Book Code          │        │
│         │     │  - FA Posting Type, FA Posting Category        │        │
│         │     │  - Amount, FA Posting Date, Posting Date       │        │
│         │     │  - G/L Entry No. (Verknüpfung Fibu)            │        │
│         │     └────────────────────────────────────────────────┘        │
│         │                                                               │
│  ┌──────▼───────┐                                                       │
│  │ FA Register  │    ┌──────────────────┐                               │
│  │ (5622)       │    │ FA Allocations   │                               │
│  └──────────────┘    │ (5635)           │                               │
│                      └──────────────────┘                               │
└──────────────────────────────────────────────────────────────────────────┘
```

### 2.3 Übersicht aller Tabellen

| Tabelle | ID | Beschreibung |
|---|---|---|
| **Fixed Asset** | 5600 | Anlagenstamm (Nr., Beschreibung, Klasse, Buchungsgruppe, AT-Felder) |
| **FA Ledger Entry** | 5601 | Anlagenbuchungszeilen (gebuchte Einträge) |
| **FA Setup** | 5603 | Anlagen-Einrichtung (Standard-AfA-Buch, Bonus-AfA, Nummernserien) |
| **FA Posting Type Setup** | 5604 | Konfiguration der Buchungsarten pro AfA-Buch (Part of Book Value, Reverse before Disposal) |
| **FA Journal Setup** | 5605 | Journal-Einrichtung pro Benutzer (AfA-Buch, Fibu-Journal) |
| **FA Posting Group** | 5606 | Buchungsgruppen (Sachkontenzuordnung je Buchungsart) |
| **FA Subclass** | 5608 | Anlagen-Unterklassen |
| **FA Class** | 5609 | Anlagen-Klassen |
| **Depreciation Book** | 5611 | AfA-Buch-Definition (G/L-Integration, Abgangsmethode) |
| **FA Depreciation Book** | 5612 | Zuordnung Anlage → AfA-Buch mit AfA-Parametern (Methode, ND, Prozentsatz) |
| **FA Journal Line** | 5621 | Anlagenjournalzeilen |
| **FA Journal Batch** | 5623 | Anlagenjournal-Stapel |
| **FA Journal Template** | 5624 | Anlagenjournal-Vorlagen |
| **FA Register** | 5622 | Anlagenregister (protokolliert Buchungen) |
| **FA Allocation** | 5635 | Anlagenverteilung (Dimensionen) |
| **Main Asset Component** | 5613 | Hauptanlage-Komponenten-Verknüpfung |
| **FA Reclass Journal Line** | 5629 | Umbuchungsjournalzeilen |
| **FAPostingGroupBuffer** | 5630 | Buchungsgruppen-Puffer |
| **FAGLPostingBuffer** | 5631 | Fibu-Buchungs-Puffer |
| **Depreciation Table Header** | 5615 | Benutzerdefinierte AfA-Tabellen (Kopf) |
| **Depreciation Table Line** | 5617 | Benutzerdefinierte AfA-Tabellen (Zeilen) |
| **Adv. Bonus Depreciation Setup** | 5618 | Erweiterte Bonus-AfA-Einrichtung |

### 2.4 Übersicht aller Codeunits

| Codeunit | ID | Beschreibung |
|---|---|---|
| **Calculate Depreciation** | 5610 | Koordinator der AfA-Berechnung (normal + Custom 1) |
| **Calculate Normal Depreciation** | 5612 | Standard-AfA-Berechnung (linear, degressiv, etc.) |
| **Calculate Custom 1 Depr.** | 5613 | Custom-1-AfA-Berechnung |
| **Calculate Acq. Cost Depr.** | 5614 | AfA auf Anschaffungskostenbasis |
| **Depreciation Calculation** | 5616 | Hilfsroutinen (Tage, Filter, EntryAmounts) |
| **FA Date Calculation** | 5617 | Datumsberechnung für AfA-Perioden |
| **Duplicate Depr. Book** | 5625 | Duplizierung von Buchungen zwischen AfA-Büchern |
| **FA Jnl.-Post** | 5636 | Journal-Buchung (Haupt-Codeunit) |
| **FA Jnl.-Post Batch** | 5633 | Journal-Stapelbuchung |
| **FA Jnl.-Post Line** | 5632 | Einzelzeilen-Buchung (Kernlogik) |
| **FA Jnl.-Check Line** | 5630 | Journalzeilen-Prüfung |
| **FA Insert Ledger Entry** | 5637 | Erzeugung von Ledger-Einträgen |
| **Calculate Disposal** | 5605 | Abgangsberechnung (Gewinn/Verlust) |
| **FA General Report** | 5626 | Berichts-Hilfsfunktionen |
| **Cancel FA Ledger Entries** | 5628 | Stornierung von Anlagenbuchungszeilen |
| **FA Reclass Jnl. Management** | 5640 | Umbuchungsjournal-Verwaltung |
| **Fixed Asset Acquisition Wizard** | 5642 | Assistent für Anlagenzugang |

---

## 3. AL-Code Analyse

### 3.1 Fixed Asset Table (5600)

Die Tabelle **Fixed Asset** ist der zentrale Stammdatenträger. Relevante Felder:

| Feld-Nr. | Name | Typ | Beschreibung |
|---|---|---|---|
| 1 | No. | Code[20] | Anlagennummer (Nummernserie) |
| 2 | Description | Text[100] | Bezeichnung |
| 5 | FA Class Code | Code[10] | Anlagenklasse (→ FA Class) |
| 6 | FA Subclass Code | Code[10] | Anlagen-Unterklasse (→ FA Subclass) |
| 7-8 | Global Dimension 1/2 Code | Code[20] | Dimensionen für Reporting |
| 9 | Location Code | Code[10] | Lagerort |
| 10 | FA Location Code | Code[10] | Anlagenstandort |
| 12 | Main Asset/Component | Enum | Hauptanlage / Komponente |
| 21 | Blocked | Boolean | Gesperrt für Buchungen |
| 26 | Inactive | Boolean | Inaktiv |
| 29 | FA Posting Group | Code[20] | Buchungsgruppe (→ FA Posting Group) |
| **11101** | **BWR Depr. Book Code** | Code[10] | **AT: BWR-AfA-Buch (Bewertungsreserve)** |
| **11102** | **Prem Depr. %** | Integer | **AT: Vorzeitige Abschreibung %** |
| **11103** | **Prem. Depr. Amount** | Decimal | **AT: Vorzeitige Abschreibung Betrag** |

**Wichtige Event-Hooks:**
- `OnBeforeOnValidateFAClassCode` — vor Validierung der Klasse
- `OnBeforeOnValidateFASubclassCode` — vor Validierung der Subklasse
- `OnBeforeValidateFAPostingGroup` — vor Validierung der Buchungsgruppe
- `OnBeforeOnDelete` — vor Löschung einer Anlage

**Löschlogik (OnDelete):**
1. `LockTable()` auf Fixed Asset + MainAssetComponent + InsCoverageLedgerEntry
2. Hauptanlagen können nicht gelöscht werden, wenn Komponenten existieren
3. Versicherungsverknüpfungen werden gelöscht
4. Alle FA Depreciation Books werden gelöscht
5. Maintenance Registrations werden gelöscht
6. Kommentare werden gelöscht
7. Dimensionen werden bereinigt

### 3.2 FA Journal Line FA Posting Type Enum (5602)

```al
enum 5602 "FA Journal Line FA Posting Type"
{
    value(0; "Acquisition Cost")      // Anschaffungskosten (Zugang)
    value(1; Depreciation)            // Abschreibung (AfA)
    value(2; "Write-Down")            // Teilwertabschreibung
    value(3; Appreciation)            // Zuschreibung
    value(4; "Custom 1")              // Frei verwendbar 1
    value(5; "Custom 2")              // Frei verwendbar 2
    value(6; Disposal)                // Abgang (Verkauf/Verschrottung)
    value(7; Maintenance)             // Wartung
    value(8; "Salvage Value")         // Restwert
    value(10; "Bonus Depreciation")   // Sonder-AfA / Bonus-AfA
}
```

Diese Buchungsarten bilden **alle relevanten Geschäftsvorfälle** der österreichischen Anlagenbuchhaltung ab:
- **Acquisition Cost** = Anschaffungs-/Herstellungskosten (Zugang)
- **Depreciation** = Planmäßige Abschreibung (AfA)
- **Write-Down** = Außerplanmäßige Abschreibung (Teilwertabschreibung nach § 204 UGB / § 6 Z 2 EStG)
- **Appreciation** = Zuschreibung (Wertaufholung nach Wegfall der Gründe)
- **Disposal** = Anlagenabgang (mit Gewinn/Verlust-Ermittlung)
- **Salvage Value** = Restwert (steuerlich nicht relevant in AT)
- **Bonus Depreciation** = Sonderabschreibung (z.B. § 7g EStG oder § 3 Abs 1 Z 5a EStG für Elektrofahrzeuge)

### 3.3 FA Depreciation Method Enum (5610)

```al
enum 5610 "FA Depreciation Method"
{
    value(0; "Straight-Line")         // Linear (Standard-Österreich)
    value(1; "Declining-Balance 1")   // Degressiv 1 (geometrisch)
    value(2; "Declining-Balance 2")   // Degressiv 2
    value(3; "DB1/SL")               // Degressiv → Linear (Wechsel)
    value(4; "DB2/SL")               // Degressiv 2 → Linear (Wechsel)
    value(5; "User-Defined")          // Benutzerdefiniert (AfA-Tabelle)
    value(6; "Manual")                // Manuell
}
```

**Österreichische Relevanz:**
- **Straight-Line:** Standard-AfA-Methode nach UGB und EStG (§ 7 Abs. 1 EStG)
- **Declining-Balance:** In AT nur eingeschränkt zulässig (z.B. degressive AfA nach § 7 Abs. 2 EStG für bestimmte Wirtschaftsgüter, in den letzten Jahren stark eingeschränkt)
- **DB1/SL:** Automatischer Wechsel von degressiv auf linear — entspricht dem steuerlichen Optimalverhalten
- **User-Defined:** Für Sonder-AfA-Tabellen (z.B. Gebäude-AfA mit unterschiedlichen Sätzen)

### 3.4 Depreciation Book (5611) — G/L-Integration

Die AfA-Bücher steuern, **welche Buchungsarten in die Fibu übernommen werden**:

| Feld | Typ | Bedeutung für Österreich |
|---|---|---|
| G/L Integration - Acq. Cost | Boolean | Anschaffungskosten → Fibu (handelsrechtlich: JA) |
| G/L Integration - Depreciation | Boolean | Abschreibung → Fibu (handelsrechtlich: JA) |
| G/L Integration - Write-Down | Boolean | Teilwertabschreibung → Fibu (JA, für beide Bücher) |
| G/L Integration - Appreciation | Boolean | Zuschreibung → Fibu (JA, Wertaufholungsgebot § 208 UGB) |
| G/L Integration - Disposal | Boolean | Abgang → Fibu (JA) |
| G/L Integration - Custom 1/2 | Boolean | Sonderbuchungen → Fibu |
| G/L Integration - Bonus Depr. | Boolean | Sonder-AfA → Fibu |
| Disposal Calculation Method | Option (Net/Gross) | Abgangsberechnung: Netto (mit Gewinn/Verlust) oder Brutto |
| Use Custom 1 Depreciation | Boolean | Eigene AfA auf Custom-1-Buchungen |
| Part of Duplication List | Boolean | Buchungen aus anderem Buch duplizieren |
| Allow Depr. below Zero | Boolean | AfA unter Null zulassen (i.d.R. NEIN) |
| Use Rounding in Periodic Depr. | Boolean | Rundung in periodischer AfA (AT: Ja) |
| Fiscal Year 365 Days | Boolean | Kalendertage statt 360-Tage-Jahr |
| Use Accounting Period | Boolean | Buchungsperioden statt Datum |
| Allow Indexation | Boolean | Indexierung zulassen |

### 3.5 FA Depreciation Book (5612) — AfA-Parameter pro Anlage

Dies ist die **wichtigste Tabelle für die AfA-Konfiguration**. Sie verknüpft eine Anlage mit einem AfA-Buch und definiert:

| Feld | Beschreibung |
|---|---|
| Depreciation Method | AfA-Methode (linear, degressiv, etc.) |
| Depreciation Starting Date | AfA-Beginn (≠ Anschaffungsdatum!) |
| Straight-Line % | Linearer AfA-Satz (z.B. 10 für 10 Jahre) |
| No. of Depreciation Years | Nutzungsdauer in Jahren |
| Declining-Balance % | Degressiver AfA-Satz (z.B. 20%) |
| Ending Book Value | Erinnerungswert (z.B. 1,00 €) |
| Salvage Value % | Restwert-Prozentsatz |
| Depreciation Ending Date | Berechnetes AfA-Ende |
| Use Half-Year Convention | Halbjahres-AfA (pro rata temporis) |
| Use Bonus Depreciation | Bonus-AfA aktiviert |

**Wichtige Validierungslogik im Code:**
- Bei Änderung der AfA-Methode werden **inkompatible Felder automatisch zurückgesetzt**
- Bei **Straight-Line** werden `Declining-Balance %` und `Depreciation Table Code` gelöscht
- Bei **Declining-Balance** werden `Straight-Line %`, `No. of Depreciation Years` und `Fixed Depr. Amount` gelöscht
- `Depreciation Ending Date` wird automatisch aus Startdatum + Nutzungsdauer berechnet

### 3.6 FA Posting Group (5606)

Die Buchungsgruppe ordnet jedem Buchungsvorgang ein **Sachkonto** zu:

| Feld | Beschreibung | AT-Beispiel |
|---|---|---|
| Acquisition Cost Account | Konto für Zugänge | 0xxx Anlagenzugang |
| Accum. Depreciation Account | Kumulierte Abschreibung | 0xxx Kumulierte AfA |
| Write-Down Account | Teilwertabschreibung | 0xxx Außerplanm. AfA |
| Appreciation Account | Zuschreibung | 0xxx Zuschreibung |
| Custom 1/2 Account | Sonderbuchungskonten | (frei) |
| Acq. Cost Acc. on Disposal | Gegenkonto bei Abgang | 0xxx Abgang Anlagen |
| Accum. Depr. Acc. on Disposal | Gegenkonto AfA bei Abgang | 0xxx Abgang kum. AfA |
| Write-Down Acc. on Disposal | Gegenkonto Teilwertabschr. bei Abgang | |
| ... | Weitere Abgangskonten für Appreciation, Custom | |
| **Maintenance Account** | Wartungsaufwand | 7xxx Instandhaltung |
| **Balancing Account** | Verrechnungskonto | Übergangskonto |
| **Sales FA Account** | Erlöskonto bei Verkauf | 4xxx Erlöse Anlagenverkauf |
| **Gain/Loss Acc. on Disposal** | Gewinn/Verlust bei Abgang | 4xxx/7xxx Gewinn/Verlust Abgang |

### 3.7 FA Posting Type Setup (5604)

Diese Tabelle steuert, **wie Buchungsarten in Berechnungen einfließen**:

| Feld | Beschreibung | Relevanz |
|---|---|---|
| Part of Book Value | Fließt in den Buchwert ein | JA für AK, AfA, Write-Down, Appreciation |
| Part of Depreciable Basis | Fließt in AfA-Bemessungsgrundlage | JA für AK, Zuschreibungen |
| Include in Depr. Calculation | In periodischer AfA-Berechnung | JA für AfA-relevante Posten |
| Include in Gain/Loss Calc. | In Gewinn/Verlust-Berechnung beim Abgang | JA für Buchwert-Komponenten |
| Reverse before Disposal | Vor Abgang auflösen (z.B. Custom-1) | Bei Teilwertabschreibung vor Abgang |
| Sign (Debit/Credit) | Soll/Haben-Kennzeichen | Steuert Buchungsrichtung |
| Depreciation Type | Als Abschreibungstyp klassifiziert | Für AfA-Reporting |
| Acquisition Type | Als Zugangstyp klassifiziert | Für Zugangs-Reporting |

### 3.8 Buchungslogik (FA Jnl.-Post Line — 5632)

Die Kern-Buchungslogik in `PostFixedAsset()`:

```
1. LockTable auf Fixed Asset
2. DeprBook + FA + FADeprBook laden
3. Prüfung: FA nicht Blocked, nicht Inactive
4. Daten vom FA-Stamm in FALedgEntry kopieren
5. FA Posting Group ermitteln (aus FADeprBook)
6. Je nach Buchungsart:
   ├── Disposal → PostDisposalEntry()
   │   ├── Disposal Type ermitteln (First/Second/Error)
   │   ├── Bei FirstDisposal: Reverse before Disposal
   │   ├── CalcGainLoss() → Gewinn/Verlust berechnen
   │   ├── 14 EntryAmounts für alle Buchungskomponenten
   │   └── FAInsertLedgEntry.InsertFA() je Komponente
   ├── Depr. until Date → PostDeprUntilDate()
   └── Sonstige → Direkt InsertFA()
7. Depr. Acquisition Cost → PostDeprUntilDate(AcqCost)
8. Budget-Buchung → PostBudgetAsset()
```

**Abgangsberechnung (Calculate Disposal — 5605):**

Die Gewinn/Verlust-Ermittlung beim Abgang:
```
GainLoss = BookValue + ProceedsOnDisposal
         + EntryAmounts[WriteDown] + EntryAmounts[Appreciation]
         + EntryAmounts[Custom1] + EntryAmounts[Custom2]

Wenn GainLoss ≤ 0 → EntryAmounts[1] = GainLoss (Verlust)
Wenn GainLoss > 0  → EntryAmounts[2] = GainLoss (Gewinn)

EntryAmounts[3] = -AcquisitionCost (Auflösung AK)
EntryAmounts[4] = -Depreciation   (Auflösung kum. AfA)
EntryAmounts[9] = -SalvageValue   (Auflösung Restwert)
```

**Netto- vs. Brutto-Abgangsmethode:**
- **Netto (Net):** Erlös wird gegen Buchwert + Einzelposten gebucht → Gewinn/Verlust als Saldo
- **Brutto (Gross):** Buchwert wird komplett aufgelöst, Erlös separat gebucht

**Österreich-Empfehlung:** Netto-Methode, da handelsrechtlich der Buchwertabgang und das Abgangsergebnis sauber getrennt ausgewiesen werden können.

### 3.9 Abschreibungsberechnung (Depreciation Calculation — 5616)

Kernfunktionen:

**DeprDays() — Taggenaue AfA-Berechnung:**
```al
// 360-Tage-Methode (Standard in AT):
// Tag wird auf max. 30 begrenzt (31. = 30.)
// Monat = 30 Tage, Jahr = 360 Tage
NumberOfDeprDays = 1 + EndingDay - StartingDay
                 + 30 * (EndingMonth - StartingMonth)
                 + 360 * (EndingYear - StartingYear)
```

**CalcEntryAmounts() — Summierung Buchungsbeträge:**
Ermittelt die Summe aller Write-Down / Appreciation / Custom 1 / Custom 2 Buchungen im Zeitraum für eine Anlage. Diese Beträge sind relevant für die AfA-Bemessungsgrundlage bei degressiver AfA und für die Abgangsberechnung.

**SetFAFilter() — Standard-Filter für FA Ledger Entry:**
- Nur Einträge mit `FA Posting Category = " "` (normale Buchungen, keine Abgangs-Auflösungen)
- Sortiert nach FA Posting Type für `FAPostingTypeOrder = true`
- Setzt `Reversed = false`

### 3.10 AT-spezifische Felder im Fixed Asset Table

```
Feld 11101: "BWR Depr. Book Code" → Verweis auf das AfA-Buch für die Bewertungsreserve
Feld 11102: "Prem Depr. %"         → Vorzeitige Abschreibung (Investitionsbegünstigung)
Feld 11103: "Prem. Depr. Amount"   → Betrag der vorzeitigen Abschreibung
```

Diese Felder sind spezifisch für die österreichische Lokalisierung:
- **BWR (Bewertungsreserve):** Nach UGB können stille Reserven durch Unterbewertung entstehen. Die Bewertungsreserve hält die Differenz zwischen handelsrechtlichem und steuerlichem Wert fest.
- **Prem Depr. (Vorzeitige Abschreibung):** Österreich erlaubt unter bestimmten Voraussetzungen eine vorzeitige Abschreibung (z.B. § 7g EStG, § 3/1/5a EStG für E-Autos). Der Prozentsatz und der Betrag werden auf der Anlagenkarte erfasst.

---

## 4. Österreichische Anlagenbuchhaltung (UGB + Steuerrecht)

### 4.1 Rechtliche Grundlagen

Die österreichische Anlagenbuchhaltung basiert auf zwei Rechtskreisen:

| Rechtsgrundlage | Regelungsbereich |
|---|---|
| **UGB** (Unternehmensgesetzbuch) | Handelsrechtliche Bilanzierung (§§ 189-243) |
| **EStG 1988** (Einkommensteuergesetz) | Steuerliche Gewinnermittlung (§§ 4-14) |
| **EStR 2000** (Einkommensteuerrichtlinien) | Interpretation des EStG durch die Finanzverwaltung |
| **AFRAC** (Austrian Financial Reporting and Auditing Committee) | Fachgutachten zur UGB-Auslegung |

**Grundsatz der Maßgeblichkeit (eingeschränkt durch UGB-Reform):**
- Die UGB-Bilanz ist grundsätzlich maßgeblich für die Steuerbilanz (§ 5 Abs. 1 EStG)
- **Ausnahmen:** Steuerliche Sonderabschreibungen, Bewertungsreserven, IFB können zu Abweichungen führen → **Zwei-Bücher-System** erforderlich

### 4.2 Aktivierungspflichten (UGB)

**Aktivierungspflicht (§ 196 UGB):**
- Anlagevermögen: Gegenstände, die dazu bestimmt sind, **dauernd dem Geschäftsbetrieb zu dienen**
- Aktivierung zu **Anschaffungs- oder Herstellungskosten** (§ 203 UGB)

**Anschaffungskosten (§ 203 Abs. 2 UGB):**
> Anschaffungskosten sind die Aufwendungen, die geleistet werden, um einen Vermögensgegenstand zu erwerben und ihn in einen betriebsbereiten Zustand zu versetzen, soweit sie dem Vermögensgegenstand einzeln zugeordnet werden können.

Enthalten: Kaufpreis, Anschaffungsnebenkosten (Transport, Montage, Notar), nachträgliche Anschaffungskosten
Nicht enthalten: Finanzierungskosten (außer aktivierungspflichtig nach § 203 Abs. 4), nicht abzugsfähige Vorsteuer

**Herstellungskosten (§ 203 Abs. 3 UGB):**
> Mindestansatz: Material- + Fertigungseinzelkosten + Sonderkosten + Material-/Fertigungsgemeinkosten (angemessene Teile)
> Wahlrecht für: Verwaltungsgemeinkosten, Sozialkosten, Fremdkapitalzinsen (wenn Herstellungszeitraum > 6 Monate)

**Geringwertige Wirtschaftsgüter (GWG):**
- Anschaffungskosten ≤ **€ 1.000** (seit 2016, zuvor € 400)
- **Sofortabzug** als Betriebsausgabe (§ 13 EStG) — kein Aktivum
- Betrifft **nur** abnutzbare, selbstständig nutzbare Wirtschaftsgüter
- UGB: bei Wesentlichkeit kann auf Aktivierung nicht verzichtet werden; in der Praxis wird das Wahlrecht nach § 198 Abs. 2 UGB i.d.R. steuerlich konform ausgeübt

### 4.3 Abschreibung (AfA)

#### 4.3.1 Planmäßige Abschreibung (§ 204 UGB / § 7 EStG)

**Lineare Abschreibung:**
- **Standardmethode** in Österreich (UGB + Steuerrecht)
- Verteilung der AK/HK gleichmäßig über die Nutzungsdauer
- **Nutzungsdauer:** nach betriebsgewöhnlicher Nutzungsdauer (Schätzung, keine fixen Tabellen im Gesetz)
- AfA-Satz p.a. = AK/HK ÷ Nutzungsdauer
- Beginn: mit Inbetriebnahme / Betriebsbereitschaft
- **Pro rata temporis:** Monatsgenaue AfA im ersten Jahr, wenn Anschaffung unterjährig

**Degressive Abschreibung (§ 7 Abs. 2 EStG):**
- **Historisch:** Bis 2020 möglich (max. 30% vom Buchwert, letztmalig in Veranlagung 2021)
- **Aktuell (ab 2022):** Degressive AfA für Wirtschaftsgüter, die nach dem 30.6.2020 und vor dem 1.1.2022 angeschafft wurden (befristete Corona-Maßnahme)
- **Ab VZ 2024:** Keine degressive AfA im Steuerrecht (wieder ausschließlich linear)
- **UGB:** Degressive AfA weiterhin zulässig, wenn sie dem tatsächlichen Wertverzehr entspricht

**Gebäude-AfA (§ 8 EStG):**
- Betriebsgebäude: **2,5%** linear (40 Jahre)
- Wohngebäude: **1,5%** linear (66,67 Jahre)
- Zuordnung nach tatsächlicher Nutzung (Flächenanteile)

#### 4.3.2 Außerplanmäßige Abschreibung (Teilwertabschreibung)

**Handelsrechtlich (§ 204 Abs. 2 UGB):**
> Außerplanmäßige Abschreibungen sind vorzunehmen, wenn der beizulegende Wert voraussichtlich dauernd unter dem Buchwert liegt.

- **Strenges Niederstwertprinzip** im UGB
- Voraussichtlich dauernde Wertminderung → **Muss-Vorschrift**
- Beizulegender Wert = Wiederbeschaffungswert / Marktwert / Ertragswert

**Steuerrecht (§ 6 Z 2 lit. a EStG):**
- Teilwertabschreibung nur bei **voraussichtlich dauernder Wertminderung**
- Strengerer Maßstab als UGB → kann zu Bewertungsdifferenz führen

#### 4.3.3 Wertaufholung / Zuschreibung (§ 208 UGB)

> Der niedrigere Wertansatz darf beibehalten werden, wenn die Gründe für die außerplanmäßige Abschreibung nicht mehr bestehen (Wertaufholungswahlrecht).

- **Wertaufholungsgebot im Steuerrecht** (§ 6 Z 2 lit. b EStG): Zwingende Zuschreibung bei Wegfall der Gründe
- UGB: Beibehaltungswahlrecht → **Bewertungsreserve** (Differenz UGB-Steuer)

### 4.4 Investitionsbegünstigungen in Österreich

#### 4.4.1 Investitionsbedingter Gewinnfreibetrag (§ 10 EStG)

- **Natürliche Personen** mit Einkünften aus Gewerbebetrieb/Landwirtschaft/selbstständiger Arbeit
- **13%** des Gewinns bis € 33.000 (Grundfreibetrag: bis € 3.900)
- Darüber hinaus: **investitionsbedingter** Freibetrag (Anschaffung abnutzbarer körperlicher Anlagen oder bestimmter Wertpapiere)
- Gewinnfreibetrag wirkt **außerbilanziell** → keine Auswirkung auf Anlagenbuchhaltung selbst

#### 4.4.2 Freibetrag für investierte Gewinne (FBiG) — bis 2016

Wurde durch den investitionsbedingten Gewinnfreibetrag abgelöst.

#### 4.4.3 Vorzeitige Abschreibung (§ 7g EStG) — bis 17.10.2002

Historisch für bestimmte Investitionen. Heute nicht mehr anwendbar, Altfälle laufen aus.

#### 4.4.4 Sonder-AfA für E-Fahrzeuge (§ 3 Abs. 1 Z 5a EStG)

Für nach dem 31.12.2015 angeschaffte Elektrofahrzeuge (CO2-Emissionsfrei) besteht ein **Vorsteuerabzugs- und Angemessenheitsprivileg** sowie großzügige Abschreibungsmöglichkeiten.

#### 4.4.5 Beschleunigte AfA (ÖkoStRefG 2022 — befristet)

- Für Wirtschaftsgüter, die nach dem 31.12.2022 und vor dem 1.1.2025 angeschafft werden
- **Lineare Abschreibung** in der doppelten Höhe des normalen AfA-Satzes im ersten Jahr
- **Nicht** in BC Standard abgebildet → müsste über Custom-1 oder Bonus Depreciation gelöst werden

### 4.5 Buchwert vs. Steuerwert

| Aspekt | Handelsrecht (UGB) | Steuerrecht (EStG) |
|---|---|---|
| **Aktivierung** | AHK, Wahlrecht für GWG | AHK, GWG-Sofortabzug Pflicht |
| **Nutzungsdauer** | Betriebsgewöhnlich (Schätzung) | Betriebsgewöhnlich (i.d.R. gleich) |
| **Abschreibung** | Linear (degressiv möglich) | Nur linear (degressiv ab 2024 nicht mehr) |
| **Teilwertabschreibung** | Bei dauernder Wertminderung (Muss) | Bei voraussichtlich dauernder Wertminderung |
| **Zuschreibung** | Beibehaltungswahlrecht | Zuschreibungsgebot |
| **Sonder-AfA** | Nicht vorgesehen | Früher: § 7g, § 3/1/5a EStG, beschleunigte AfA |

→ **Zwei-Bücher-System** erforderlich für korrekte Abbildung beider Rechtskreise.

---

## 5. Anlagenbücher in Österreich

### 5.1 Warum mehrere Anlagenbücher?

Die parallele Führung mehrerer AfA-Bücher ist in Österreich **kein Luxus, sondern fachliche Notwendigkeit**. Die Unterschiede zwischen Handels- und Steuerrecht (vgl. Abschnitt 4.5) führen zwingend zu abweichenden Wertansätzen.

### 5.2 Das Drei-Bücher-Modell

| Buch | Zweck | G/L-Integration |
|---|---|---|
| **HANDEL** | Handelsrechtlicher Einzelabschluss (UGB) | JA (voll) |
| **STEUER** | Steuerliche Mehr-Weniger-Rechnung | NEIN (nur FA-Ledger) |
| **IFRS** (optional) | Konzernabschluss nach IFRS | NEIN oder JA |

### 5.3 Handelsrechtliches Anlagenbuch (HANDEL)

**Konfiguration:**
- **G/L Integration:** Alle Buchungsarten = JA (Acq. Cost, Depreciation, Write-Down, Appreciation, Disposal)
- **AfA-Methode:** Linear (Standard)
- **Nutzungsdauer:** Betriebsgewöhnliche Nutzungsdauer (nach UGB-Schätzung)
- **Teilwertabschreibung:** Write-Down → G/L Integration = JA (Muss-Vorschrift UGB)
- **Zuschreibung:** Appreciation → G/L Integration = JA (bei Ausübung Zuschreibung)
- **Disposal Calculation Method:** Net (für saubere Gewinn/Verlust-Darstellung)

**Bewertungsreserve (BWR):**
- Entsteht, wenn UGB-Wert < Steuerwert (z.B. durch Beibehaltungswahlrecht bei Zuschreibung)
- **Nicht als eigener Posten in der Bilanz**, sondern als stille Reserve
- In BC: `BWR Depr. Book Code` auf Anlagenkarte verweist auf das STEUER-Buch → Differenz kann im AT-Bericht "Liste AT" ausgewertet werden

### 5.4 Steuerliches Anlagenbuch (STEUER)

**Konfiguration:**
- **G/L Integration:** NEIN (die steuerlichen Werte werden nicht in die Fibu gebucht)
- **AfA-Methode:** Linear (gesetzlich vorgeschrieben seit 2024)
- **Nutzungsdauer:** Steuerlich anerkannte Nutzungsdauer
- **Teilwertabschreibung:** Write-Down → G/L Integration = NEIN (nur für Steuererklärung relevant)
- **Zuschreibung:** Appreciation → G/L Integration = NEIN (Zuschreibungsgebot, aber nur steuerlich)
- **Bonus Depreciation:** Bonus Depr. → G/L Integration = NEIN (steuerliche Sonder-AfA)

**Technische Umsetzung:**
- Buchungen werden über "Part of Duplication List" aus dem HANDEL-Buch dupliziert
- Codeunit **Duplicate Depr. Book (5625)** kopiert Zugänge und Abgänge
- AfA-Lauf wird separat für das STEUER-Buch durchgeführt (mit steuerlicher Nutzungsdauer)
- Steuerliche Sonder-AfA (Bonus Depreciation) wird nur im STEUER-Buch gebucht

### 5.5 IFRS-Anlagenbuch (optional)

**Nur erforderlich bei:**
- Konzernabschluss nach IFRS
- Kapitalmarktorientierten Unternehmen (§ 245a UGB)

**IFRS-Besonderheiten:**
- **Komponentenansatz (IAS 16):** Zerlegung in wesentliche Komponenten → BC: Main Asset / Component
- **Neubewertungsmethode (IAS 16):** Fair Value statt AHK → BC: nicht nativ, braucht Erweiterung
- **Nutzungsdauer-Review:** Jährliche Überprüfung → manueller Prozess

### 5.6 Technische Umsetzung der Mehr-Bücher-Logik in BC

#### Duplikations-Mechanismus

```al
// Duplicate Depr. Book (5625)
// Wenn Part of Duplication List = true:
// Bei Buchung im Quell-Buch → automatische Duplikation ins Ziel-Buch
DuplicateFAJnlLine(FAJnlLine);
// oder
DuplicateGenJnlLine(GenJnlLine);
```

**Voraussetzung:**
- Im Ziel-AfA-Buch muss `Part of Duplication List = true` gesetzt sein
- Bei Duplikation können Wechselkurse verwendet werden (`Use FA Exch. Rate in Duplic.`)

#### Journal-Workflow

| Schritt | HANDEL-Buch | STEUER-Buch |
|---|---|---|
| 1. Anlagenzugang | FA Journal → HANDEL buchen | Automatisch dupliziert |
| 2. AfA-Lauf | HANDEL (UGB-ND) | STEUER (Steuer-ND, separat starten) |
| 3. Teilwertabschreibung | HANDEL buchen | STEUER buchen (ggf. abweichend) |
| 4. Abgang | HANDEL (mit Gewinn/Verlust Fibu) | STEUER (separates Abgangsergebnis) |

### 5.7 G/L-Integration: Aktivierung, Deaktivierung und Strategie

#### 5.7.1 Konzept

Jedes AfA-Buch besitzt **pro Buchungsart** einen eigenen Schalter für die Fibu-Integration. Ist eine Buchungsart auf `G/L Integration = true` gesetzt, erzeugt BC bei jeder Buchung **automatisch einen Fibu-Beleg** (G/L Entry). Bei `false` wird nur im FA-Ledger gebucht — die Fibu bleibt unberührt.

```
Depreciation Book Card → Register "Integration" → Gruppe "G/L Integration"
    ☑ G/L Integration - Acq. Cost
    ☑ G/L Integration - Depreciation
    ☑ G/L Integration - Write-Down
    ☑ G/L Integration - Appreciation
    ☑ G/L Integration - Custom 1
    ☑ G/L Integration - Custom 2
    ☑ G/L Integration - Disposal
    ☑ G/L Integration - Maintenance
    ☑ G/L Integration - Bonus Depreciation
```

**Wichtig:** Die Schalter sind live — eine Änderung wirkt **ab sofort** auf alle neuen Buchungen. Bereits gebuchte FA-Ledger-Einträge bleiben unverändert. Es gibt **keinen automatischen Nachbuchungs-Mechanismus** für zwischenzeitlich nicht integrierte Buchungen.

#### 5.7.2 Standard-Empfehlung für Österreich

| Buchungsart | HANDEL-Buch | STEUER-Buch | Begründung |
|---|---|---|---|
| Acq. Cost | ✅ JA | ❌ NEIN | Nur handelsrechtlicher Zugang gehört in die Fibu |
| Depreciation | ✅ JA | ❌ NEIN | Handelsrechtliche AfA in Fibu; steuerliche AfA nur für Steuererklärung |
| Write-Down | ✅ JA | ❌ NEIN | Außerplanmäßige AfA gehört in UGB-Bilanz; Steuer nur für E1a |
| Appreciation | ✅ JA | ❌ NEIN | Zuschreibung nach UGB in Fibu; steuerliche Zuschreibung separat |
| Disposal | ✅ JA | ❌ NEIN | Abgangsergebnis in Fibu; steuerlicher Abgang in Steuererklärung |
| Custom 1/2 | ❌ NEIN | ❌ NEIN | Nur bei konkretem Bedarf aktivieren |
| Bonus Depr. | ❌ NEIN | ❌ NEIN | Sonder-AfA gehört nie in die UGB-Fibu |
| Maintenance | ❌ NEIN | ❌ NEIN | Wartung wird i.d.R. direkt über Kreditoren gebucht |

#### 5.7.3 Praxis-Szenarien mit Beispielen

##### Szenario 1: Migration / Übernahme — G/L-Integration erst später aktivieren

**Ausgangslage:** Ein Unternehmen migriert von einem Altsystem nach BC28. Der Anlagenbestand (200 Anlagen, kumulierte AfA € 2,4 Mio.) wurde als Saldovortrag manuell im FA-Ledger erfasst. Die Fibu ist noch nicht final abgestimmt.

**Strategie:**
1. **Phase 1:** G/L Integration für ALLE Buchungsarten = `false`
2. Alle Anlagen-Stammdaten und historischen Buchungen im FA-Ledger erfassen
3. Anlagenverzeichnis (Report 11100) mit Fibu-Salden abgleichen
4. **Phase 2:** G/L Integration für Acq. Cost, Depreciation, Disposal = `true`
5. Saldovorträge manuell per Fibu-Journal einbuchen (einmaliger Vorgang)
6. Ab sofort laufen alle neuen Buchungen automatisch in die Fibu

**Warum nicht sofort aktivieren?** Würde man mit G/L-Integration starten, würde jede historische FA-Ledger-Zeile einen Fibu-Beleg erzeugen. Das würde zu Doppelbuchungen führen, weil die Salden bereits im Fibu-Vortrag enthalten sind.

##### Szenario 2: Korrekturphase — temporär deaktivieren für Fehlerbehebung

**Ausgangslage:** Bei der monatlichen Abstimmung fällt auf, dass für drei Anlagen falsche Nutzungsdauern hinterlegt waren. Die AfA-Buchungen der letzten 7 Monate (€ 18.400) müssen storniert und mit korrekter ND neu gebucht werden.

**Strategie:**
1. G/L Integration - Depreciation = `false` (im HANDEL-Buch)
2. Fehlerhafte FA-Ledger-Einträge stornieren (Report "Cancel FA Ledger Entries")
3. FA Depreciation Book korrigieren (neue ND eintragen)
4. AfA-Lauf für die 7 Monate neu durchführen und buchen
5. FA-Ledger prüfen: Beträge und Daten korrekt?
6. G/L Integration - Depreciation = `true`
7. Korrekturbuchung in der Fibu: Storno- und Neubuchung manuell per Fibu-Journal
   - Soll: Abschreibungsaufwand / Haben: Kumulierte AfA (Differenzbetrag)

**Warum temporär deaktivieren?** Würde man mit aktiver G/L-Integration stornieren und neu buchen, entstünden 14 Fibu-Belege (7 Storno + 7 Neu). Das Fibu-Journal wird unübersichtlich. Besser: FA-seitig korrigieren, dann EINEN Fibu-Beleg für die Nettodifferenz.

##### Szenario 3: Parallele Erfassung während der Einführungsphase

**Ausgangslage:** Während der BC-Einführung werden Zugänge noch parallel im Altsystem und in BC erfasst. Die Fibu wird vorerst aus dem Altsystem gespeist. BC dient zunächst nur als Anlagenverzeichnis.

**Strategie:**
1. Alle G/L Integration-Schalter = `false`
2. Anlagenzugänge normal in BC buchen (FA Journal → Acquisition Cost)
3. Monatliche AfA-Läufe in BC durchführen (nur FA-Ledger)
4. Monatlicher Abgleich: BC-Anlagenverzeichnis vs. Altsystem
5. Sobald BC die Fibu-Führung übernimmt:
   - Differenzen zwischen FA-Ledger und Fibu-Salden analysieren
   - Einmaligen Übergang per Fibu-Journal buchen
   - G/L Integration für relevante Buchungsarten = `true`

##### Szenario 4: Fehlende Fibu-Buchungen nachträglich erkennen und korrigieren

**Ausgangslage:** Ein Buchhalter stellt beim Jahresabschluss fest, dass für das HANDEL-Buch versehentlich `G/L Integration - Depreciation = false` war. Die monatlichen AfA-Läufe (12 × € 5.200 = € 62.400) wurden nur im FA-Ledger gebucht, die Fibu weist keine Abschreibungen aus.

**Diagnose in BC:**
```
FA Ledger Entry → Filtern nach Depreciation Book Code = HANDEL, FA Posting Type = Depreciation
→ Prüfen: G/L Entry No. = 0? → Ja → Kein Fibu-Beleg
→ Prüfen: Amount summiert = € 62.400 → Korrekt
```

**Korrektur:**
1. G/L Integration - Depreciation = `true` setzen (für zukünftige Buchungen)
2. **Variante A — Nachbuchung monatsgenau:**
   - 12 Fibu-Buchungen manuell erfassen (Aufwand/Kum. AfA pro Monat)
   - Aufwändig, aber präzise für Monatsabschlüsse
3. **Variante B — Sammelbuchung:**
   - Eine Fibu-Sammelbuchung über € 62.400 zum Bilanzstichtag
   - Geeignet, wenn Monatsabschlüsse bereits abgeschlossen sind
4. **Variante C — FA-Ledger nachträglich verknüpfen:**
   - Report "Cancel FA Ledger Entries" → Storno aller 12 AfA-Buchungen
   - Mit G/L-Integration = `true` die 12 AfA-Buchungen neu buchen
   - Vorsicht: Nur möglich, wenn der Buchungszeitraum noch offen ist

##### Szenario 5: Teilweise G/L-Integration für Übergangsphase

**Ausgangslage:** Ein Fertigungsbetrieb aktiviert eine neue Produktionsstraße. Die Montage erfolgt über 8 Monate. In dieser Zeit fallen laufend aktivierungspflichtige Aufwendungen an (Anlagen im Bau). Der Buchhalter möchte die Zugänge bereits im FA-Ledger sammeln, aber erst nach Fertigstellung und Endabnahme in die Fibu übernehmen.

**Strategie:**
1. G/L Integration - Acq. Cost = `false`
2. Alle anderen Buchungsarten (Depreciation, Disposal etc.) bleiben auf `true` (für andere Anlagen)
3. Teilzugänge der Produktionsstraße als Acquisition Cost buchen (nur FA-Ledger)
4. Nach Fertigstellung:
   - G/L Integration - Acq. Cost = `true`
   - Gesamtbetrag ermitteln: FA Ledger Entry → Summe Amount für diese Anlage
   - Fibu-Journal: Einmalige Aktivierungsbuchung über den Gesamtbetrag

#### 5.7.4 Risiken und Fallstricke

| Risiko | Beschreibung | Prävention |
|---|---|---|
| **Vergessene Reaktivierung** | Nach temporärer Deaktivierung wird nicht zurückgeschaltet → monatelang fehlende Fibu-Buchungen | Merkliste/Jahresplan mit Wiedervorlage; Prüfroutine im Monatsabschluss |
| **Halbierte Integration** | Nur ein Teil der Buchungsarten ist aktiv → Fibu unvollständig (z.B. AK werden gebucht, AfA nicht) | Checkliste bei Einrichtung: Alle relevanten Buchungsarten prüfen |
| **Abstimmdifferenz** | FA-Ledger und Fibu-Salden laufen auseinander, weil zeitweise nicht integriert wurde | Monatlicher Soll-Ist-Abgleich: FA Ledger Entry.Sum(Amount) = G/L Entry.Sum(Amount) je AfA-Buch |
| **Nachbuchung im falschen Jahr** | Korrekturbuchung erfolgt in falscher Periode → Steuererklärung fehlerhaft | Korrekturbuchung strikt mit Original-Posting-Datum; ggf. Perioden-Sperre aufheben |
| **STEUER-Buch versehentlich aktiv** | G/L-Integration im STEUER-Buch aktiv → steuerliche Sonder-AfA erscheint in UGB-Fibu | STEUER-Buch als "Nicht Fibu-relevant" dokumentieren; regelmäßige Prüfung der AfA-Buch-Einstellungen |

#### 5.7.5 Prüfroutine für den Monatsabschluss

```
1. Depreciation Book Card öffnen (HANDEL)
2. Prüfen: Alle G/L Integration-Schalter korrekt?
3. FA Ledger Entry filtern: Depreciation Book Code = HANDEL, G/L Entry No. = 0
   → Wenn Einträge vorhanden → Wurden Buchungen ohne Fibu-Integration gebucht?
4. G/L Entry filtern: Source Type = Fixed Asset
   → Summe mit FA Ledger Entry.Sum(Amount) abgleichen
5. Bei Differenz: Ursache klären, Korrekturbuchung veranlassen
```

---

## 6. Business Central Mapping auf österreichische Anforderungen

### 6.1 Mapping-Tabelle: AT-Begriff → BC-Objekt

| Österreichischer Begriff | BC-Objekt | ID |
|---|---|---|
| Anlagenverzeichnis | Report Fixed Assets - List AT | 11100 |
| Anlagenkarte | Page Fixed Asset Card | 5600 |
| Anlagenzugang (AK) | FA Journal Line FA Posting Type::Acquisition Cost | Enum 5602 |
| Planmäßige AfA | FA Journal Line FA Posting Type::Depreciation | Enum 5602 |
| Teilwertabschreibung | FA Journal Line FA Posting Type::Write-Down | Enum 5602 |
| Zuschreibung (Wertaufholung) | FA Journal Line FA Posting Type::Appreciation | Enum 5602 |
| Anlagenabgang | FA Journal Line FA Posting Type::Disposal | Enum 5602 |
| Restwert / Schrottwert | FA Journal Line FA Posting Type::Salvage Value | Enum 5602 |
| Sonder-AfA | FA Journal Line FA Posting Type::Bonus Depreciation | Enum 5602 |
| Anlagenklasse | FA Class | 5609 |
| Anlagen-Unterklasse | FA Subclass | 5608 |
| Buchungsgruppe | FA Posting Group | 5606 |
| AfA-Buch | Depreciation Book | 5611 |
| AfA-Methode: Linear | FA Depreciation Method::Straight-Line | Enum 5610 |
| AfA-Methode: Degressiv | FA Depreciation Method::Declining-Balance 1 | Enum 5610 |
| Anlagenjournal | FA Journal Line | 5621 |
| Anlagenregister | FA Register | 5622 |
| Anlagen-Ledger | FA Ledger Entry | 5601 |
| Bewertungsreserve (BWR) | "BWR Depr. Book Code" (Fixed Asset) | Feld 11101 |
| Vorzeitige AfA | "Prem Depr. %" / "Prem. Depr. Amount" | Felder 11102-3 |

### 6.2 Konfiguration für Österreich

#### 6.2.1 FA Setup (Einrichtung Anlagenbuchhaltung)

| Feld | Wert AT |
|---|---|
| Default Depr. Book | HANDEL (handelsrechtliches Buch) |
| Allow FA Posting From | 01.01.2020 (oder Geschäftsjahr-Start) |
| Allow FA Posting To | Leer (unbeschränkt) |
| Fixed Asset Nos. | ANL-XXX (Nummernserie) |
| Bonus Depreciation % | 0 (wird nur im STEUER-Buch verwendet, nicht global) |

#### 6.2.2 FA Posting Groups (Buchungsgruppen)

Empfohlene Buchungsgruppen für Österreich:

| Buchungsgruppe | Konten |
|---|---|
| **GWG** | 0650 GWG, 0660 Kum. AfA GWG |
| **MASCHINEN** | 0400 Maschinen, 0410 Kum. AfA Maschinen |
| **BGA** | 0420 BGA, 0430 Kum. AfA BGA |
| **FUHRPARK** | 0450 Fuhrpark, 0460 Kum. AfA Fuhrpark |
| **GEBÄUDE** | 0300 Gebäude, 0310 Kum. AfA Gebäude |

#### 6.2.3 FA Journal Setup

Jedem Benutzer wird das HANDEL-Buch als Standard zugewiesen.
Für Steuerberater/Wirtschaftsprüfer: Zusätzliches Profil mit STEUER-Buch.

### 6.3 Österreichische Besonderheiten im Reporting

#### Report 11100 "Fixed Assets - List AT"

Dieser AT-spezifische Bericht enthält:

**Spalten je AfA-Posting-Typ:**
- Anschaffungskosten: Stand zu Beginn / Veränderung / Abgang / Stand Ende
- Abschreibung: Stand zu Beginn / Veränderung / Abgang / Stand Ende

**Zusätzliche AT-Spalten:**
- **BWR Depr. Book Code** — für Bewertungsreserve-Darstellung
- **Prem Depr. %** — Vorzeitige Abschreibung in %
- **Prem. Depr. Amount** — Vorzeitige Abschreibung Betrag
- **GND / RND** — Gesamtnutzungsdauer / Restnutzungsdauer in Jahren
- **Vendor** — Lieferant (mit Adresse)
- **IFB Amount / IFB Date** — Investitionsbedingter Freibetrag (historisch)

**Gruppierung nach:**
- FA Class, FA Subclass, FA Location, Main Asset, Global Dimension 1/2, FA Posting Group

---

## 7. Buchhalterische Prozesse (End-to-End)

### 7.1 Anlagenzugang

**Buchhalterischer Prozess:**
1. Eingangsrechnung prüfen (Kaufpreis + Anschaffungsnebenkosten)
2. Anschaffungskosten ermitteln (eventuell nachträgliche AK)
3. Anlage in BC anlegen (Anlagenkarte)
4. AfA-Buch zuordnen (Nutzungsdauer, AfA-Methode)
5. Zugang buchen (FA Journal → Acquisition Cost)

**BC-Prozess:**
```
Einkaufsbestellung → Wareneingang → Eingangsrechnung
    └── Buch.-Blatt mit Anlagennr. und AfA-Buch → automatische Zugangsbuchung
ODER
Anlagenkarte → Assistent für Anlagenzugang → FA Journal → Buchen
```

**Beträge in beide AfA-Bücher** (HANDEL + STEUER) via Duplikation.

### 7.2 Umbuchung

**Anwendungsfälle:**
- Standortwechsel (FA Location)
- Änderung der Kostenstelle (Dimension)
- Umklassifizierung (FA Class / Subclass)
- Teilung einer Anlage

**BC-Prozess:**
```
FA Reclass Journal → FA Reclass Journal Template wählen
    ├── Transfer: Umbuchung zwischen Anlagen
    ├── Split: Aufteilung einer Anlage
    └── Combine: Zusammenführung von Anlagen
→ Buchen
```

Codeunit **FA Reclass Jnl. Transfer (5641)** / **FA Reclass Jnl. BTransfer (5642)** führt die Umbuchung durch. AfA-Buchwerte werden proportional übertragen.

### 7.3 Teilabgang

**Anwendungsfall:** Verkauf/Verschrottung eines Teils einer Anlage.

**BC-Prozess:**
```
FA Journal → FA Posting Type = Disposal
    → Betrag = anteiliger Erlös
    → Buchen mit automatischer Gewinn/Verlust-Ermittlung
```

### 7.4 Vollabgang

**BC-Prozess (detailliert):**
```
1. FA Journal → FA Posting Type = Disposal
2. Betrag = Verkaufserlös (Proceeds on Disposal)
3. Buchen starten:
   a. GetDisposalType() → FirstDisposal
   b. PostReverseType() → Auflösung von Write-Down/Appreciation (Reverse before Disposal)
   c. InsertFA(Disposal) → Erlösbuchung
   d. CalcGainLoss() → Gewinn/Verlust berechnen
   e. 14 EntryAmounts werden gebucht:
      - Auflösung Anschaffungskosten
      - Auflösung kumulierte AfA
      - Auflösung Write-Down
      - Auflösung Appreciation
      - Auflösung Custom 1/2
      - Auflösung Salvage Value
      - Gewinn- oder Verlustbuchung
```

### 7.5 AfA-Lauf

**Periodischer Prozess (monatlich/quartalsweise/jährlich):**

```
Report "Calculate Depreciation" (5605)
    → Parameter: AfA-Buch, Bis-Datum, Anlagenfilter
    → Für jede Anlage:
        1. CalculateDepr.Calculate() → AfA-Betrag ermitteln
        2. DeprDays() → Anzahl Tage (360-Tage-Methode)
        3. Prüfung: Allow Depr. below Zero?
        4. FA Journal Line erzeugen (Depreciation)
    → FA Journal buchen (Posting)
```

**AfA-Berechnung (Calculate Normal Depreciation — 5612):**

```
Straight-Line:
    AfA-Betrag = (AK - Restwert) / Nutzungsdauer in Tagen * Tage im Zeitraum
    Oder: AK * Straight-Line % / 100 (bei prozentualer Angabe)

Declining-Balance 1:
    AfA-Betrag = Buchwert * Declining-Balance % / 100
    (maximal bis Restwert/Erinnerungswert)

DB1/SL:
    Solange degressiver Betrag > linearer Betrag → degressiv berechnen
    Sobald linearer Betrag >= degressiver Betrag → auf linear wechseln
```

### 7.6 Inventur

**Prozess:**
1. Anlagenliste drucken (Report Fixed Asset List)
2. Physische Bestandsaufnahme
3. Abgleich mit Anlagenkarte
4. Bei Abweichungen: FA Journal → Disposal (Abgang) oder Korrektur
5. Ggf. Teilwertabschreibung bei festgestellter Wertminderung

**Inventurvereinfachung (Stichprobeninventur):** Für gleichartige Anlagen mit Anschaffungskosten ≤ € 1.000 und einem Bestand von mindestens 20 Stück kann eine Stichprobeninventur durchgeführt werden.

### 7.7 Anlagen im Bau

**BC-Abbildung:**
- Anlagenklasse "Anlagen im Bau" (keine AfA bis Fertigstellung)
- Sammeln aller aktivierungspflichtigen Aufwendungen auf der Anlage
- Bei Fertigstellung: Umbuchung (FA Reclass Journal) oder Aktivierung (Acquisition Cost)
- AfA-Beginn = Datum der Inbetriebnahme

### 7.8 Jahresabschlussprozess

| Schritt | Aktivität | BC-Umsetzung |
|---|---|---|
| 1. | Zugänge prüfen | FA Journal → Posting Date im Geschäftsjahr |
| 2. | GWG-Prüfung | AK ≤ € 1.000 → Sofortabzug (steuerlich) |
| 3. | AfA-Lauf (12 Monate) | Calculate Depreciation für HANDEL + STEUER |
| 4. | Teilwertabschreibung prüfen | Write-Down bei dauernder Wertminderung |
| 5. | Zuschreibung prüfen | Appreciation bei Wegfall der Gründe |
| 6. | Abgänge kontieren | FA Journal → Disposal |
| 7. | Anlagenverzeichnis drucken | Report Fixed Assets - List AT |
| 8. | Anlagenspiegel erstellen | Report Fixed Asset Book Value 03 |
| 9. | Mehr-Weniger-Rechnung | Vergleich HANDEL-IST vs. STEUER-SOLL |
| 10. | Steuererklärung (Beilage E1a) | Export der steuerlichen Werte |

---

## 8. Reporting

### 8.1 Standardberichte (Base App)

| Report | ID | Beschreibung |
|---|---|---|
| Fixed Asset List | 5607 | Anlagenliste (mit Filter) |
| Fixed Asset Book Value 01 | 5608 | Buchwert-Report nach Buchungsgruppe |
| Fixed Asset Book Value 02 | 5609 | Buchwert-Report nach Klasse/Subklasse |
| Fixed Asset Book Value 03 | 11101 | Buchwert-Report AT (lokal) |
| Fixed Assets - List AT | 11100 | Österreichisches Anlagenverzeichnis |
| Fixed Asset Register | 5620 | Anlagenregister (Journal-Nachweis) |
| Fixed Asset G/L Analysis | 5611 | Anlagen-Fibu-Analyse |
| Fixed Asset Projected Value | 5612 | Voraussichtlicher Buchwert (Hochrechnung) |
| Fixed Asset Acquisition List | 5613 | Zugangsliste |
| Fixed Asset Details | 5614 | Anlagendetails |
| Fixed Asset Document Nos | 5615 | Belegnummern-Liste |
| FA Posting Group Net Change | 5616 | Netto-Veränderung je Buchungsgruppe |

### 8.2 AT-spezifisches Anlagenverzeichnis (Fixed Assets - List AT)

Der Bericht **11100** ist das zentrale österreichische Anlagenverzeichnis. Er bietet:

**Aufbau (Spalten):**
1. Anlagennummer (No.)
2. Bezeichnung (Description)
3. Lieferant (Vendor Name + Adresse)
4. BWR-AfA-Buch (BWR Depr. Book Code)
5. GND/RND (Gesamtnutzungsdauer / Restnutzungsdauer)
6. AfA-Beginn (Depreciation Starting Date)
7. **Anschaffungskosten:**
   - Stand per Startdatum
   - Zugänge der Periode
   - Abgänge der Periode
   - Stand per Enddatum
8. **Abschreibungen:**
   - Stand per Startdatum
   - AfA der Periode
   - Abgänge der Periode (aufgelöste AfA)
   - Stand per Enddatum
9. **Buchwert:** per Startdatum / per Enddatum
10. **Vorzeitige AfA:** % und Betrag

**Gruppierung und Summierung:**
- FA Class / FA Subclass / FA Location / Main Asset / Global Dimension 1 / Global Dimension 2 / FA Posting Group
- Summenzeilen je Gruppe
- Gesamtsumme

**Filteroptionen:**
- Depreciation Book (HANDEL oder STEUER)
- Startdatum / Enddatum
- Budget Report (Planwerte einschließen)
- Print Details (Einzelnachweis oder nur Summen)

### 8.3 Buchwert-Report 03 (AT)

Zusätzlicher AT-Bericht (11101) für die Darstellung des Buchwerts nach österreichischen Vorschriften.

### 8.4 Anlagenspiegel (§ 226 UGB)

Das österreichische UGB verlangt im Anhang einen **Anlagenspiegel** (§ 226 Abs. 1 UGB) mit folgender Mindestgliederung:

| Spalte | Inhalt |
|---|---|
| Anschaffungs-/Herstellungskosten | Stand 1.1. / Zugänge / Abgänge / Umbuchungen / Stand 31.12. |
| Kumulierte Abschreibung | Stand 1.1. / Zugänge / Abgänge / Umbuchungen / Stand 31.12. |
| Buchwert | 31.12. laufendes Jahr / 31.12. Vorjahr |
| Abschreibung des Geschäftsjahres | Gesamtbetrag |

**BC-Abbildung:** Report Fixed Asset Book Value 01/02/03 in Kombination mit manuellem Export nach Excel.

---

## 9. Anhang: AL-Code Referenz

### 9.1 Alle Tabellen (kompakt)

```
5600  Fixed Asset                     5601  FA Ledger Entry
5603  FA Setup                        5604  FA Posting Type Setup
5605  FA Journal Setup                5606  FA Posting Group
5608  FA Subclass                     5609  FA Class
5611  Depreciation Book               5612  FA Depreciation Book
5613  Main Asset Component            5615  Depreciation Table Header
5617  Depreciation Table Line         5618  Adv. Bonus Depreciation Setup
5621  FA Journal Line                 5622  FA Register
5623  FA Journal Batch                5624  FA Journal Template
5629  FA Reclass Journal Line         5630  FA Posting Group Buffer
5631  FA GL Posting Buffer            5635  FA Allocation
5640  FA Reclass Journal Batch        5641  FA Reclass Journal Template
```

### 9.2 Alle Codeunits (kompakt)

```
5605  Calculate Disposal              5610  Calculate Depreciation
5612  Calculate Normal Depreciation   5613  Calculate Custom 1 Depr.
5614  Calculate Acq. Cost Depr.       5616  Depreciation Calculation
5617  FA Date Calculation             5625  Duplicate Depr. Book
5626  FA General Report               5628  Cancel FA Ledger Entries
5630  FA Jnl.-Check Line              5632  FA Jnl.-Post Line
5633  FA Jnl.-Post Batch              5636  FA Jnl.-Post
5637  FA Insert Ledger Entry          5638  FA Jnl. Management
5640  FA Reclass Jnl. Management      5641  FA Reclass Jnl. Transfer
5642  FA Reclass Jnl. BTransfer       5643  Fixed Asset Acquisition Wizard
5655  Calc Running FA Balance         5656  FA Get Balance Account
5657  FA Get GL Account No.           5658  FA Get Journal
5659  FA Dimension Management         5660  FAAutomaticEntry
5661  FA Check Consistency            5662  FA Move Entries
5663  FA Reclass Check Line           5664  FA Reclass Transfer Batch
5665  FA Reclass Transfer Line        5667  FA Jnl. Show Entries
```

### 9.3 Wichtige Events (Integration/Extension)

| Event | Ort | Zweck |
|---|---|---|
| `OnBeforeOnValidateFAClassCode` | Fixed Asset Table | Vor Klassen-Validierung |
| `OnBeforeOnValidateFASubclassCode` | Fixed Asset Table | Vor Subklassen-Validierung |
| `OnBeforeValidateFAPostingGroup` | Fixed Asset Table | Vor Buchungsgruppen-Validierung |
| `OnBeforeOnDelete` | Fixed Asset Table | Vor Löschung |
| `OnBeforeFAJnlPostLine` | FA Jnl.-Post Line | Vor Journalzeilen-Buchung |
| `OnAfterFAJnlPostLine` | FA Jnl.-Post Line | Nach Journalzeilen-Buchung |
| `OnBeforeGenJnlPostLine` | FA Jnl.-Post Line | Vor Fibu-Journal-Buchung |
| `OnAfterGenJnlPostLine` | FA Jnl.-Post Line | Nach Fibu-Journal-Buchung |
| `OnBeforePostFixedAsset` | FA Jnl.-Post Line | Vor Anlagenbuchung |
| `OnAfterPostFixedAsset` | FA Jnl.-Post Line | Nach Anlagenbuchung |
| `OnBeforeCalcGainLoss` | Calculate Disposal | Vor Gewinn/Verlust-Berechnung |
| `OnBeforeCalculate` | Calculate Depreciation | Vor AfA-Berechnung |
| `OnAfterCalcDeprYearCalculateAdditionalDepr2ndYear` | Calculate Depreciation | Nach AfA-Jahresberechnung |
| `OnBeforeModifyDeprFields` | FA Depreciation Book | Vor Änderung AfA-Felder |

### 9.4 Dimensionen und Allokation

Die Anlagenbuchhaltung unterstützt **sechs verkürzte Dimensionen** (Shortcut Dimensions):

- `Global Dimension 1 Code` (Feld 7) — z.B. Kostenstelle
- `Global Dimension 2 Code` (Feld 8) — z.B. Kostenträger
- Shortcut Dimension 3-8 (in FA Ledger Entry)

Bei Buchungen werden Dimensionen vom Anlagenstamm in die Ledger-Einträge übernommen. Die Codeunit **FA Dimension Management (5659)** verwaltet die Dimensionslogik.

Für **proportionale Verteilung** von AfA auf mehrere Dimensionen existiert die **FA Allocation (5635)** Tabelle mit dem Enum **FA Allocation Type (5634)**.

---

*Dokumentation erstellt am 28.06.2026 auf Basis von BC 28.1.49838.49886 (AT) Base App AL-Code.*
