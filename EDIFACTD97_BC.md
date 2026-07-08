# EDIFACT D.97A / D.97B — Integration in Business Central 28 (Verkauf)

> **Brainstorming-Dokument** auf Basis des BCEDI-Confluence-Projekts,  
> der BC28-Basis-App-Architektur und der UN/EDIFACT-Standards D.97A/B.

---

## 1. Warum D.97A/B?

D.97A (1997) und D.97B sind direkte Nachfolger von D.96A und in vielen Branchen speziell im
deutschsprachigen Raum (Automotive-Zulieferer, Großhandel) bis heute der produktiv genutzte
Standard. Gegenüber D.96A bringen sie:

| Verbesserung | D.96A → D.97A/B |
|---|---|
| **Segment** `RFF` | Neue Qualifier für erweiterte Referenzen (Auftragsnummer, Lieferavis, Lieferschein) |
| **Segment** `DTM` | Zusätzliche Datums-Qualifier (Liefertermin bestätigt, Wareneingang) |
| **Segment** `FTX` | Strukturierte Text-Qualifier für ICC, Lieferbedingungen, Gefahrgut |
| **Segment** `QTY` | Neue Mengen-Qualifier (bestellte vs. gelieferte vs. fakturierte Menge) |
| **Segment** `CUX` | Währungsangaben jetzt auch auf Zeilenebene möglich |
| **Segment** `TAX` | Steuerangaben detaillierter (Steuerart, -satz, -betrag) |
| **Nachrichtentypen** | `ORDCHG` (Order Change) neu eingeführt |

> **Referenz:** [edifactory.de — D.97A Directory](https://www.edifactory.de/edifact/directory/D97A)  
> bzw. [D.97B Directory](https://www.edifactory.de/edifact/directory/D97B)

---

## 2. Welche Message-Typen machen im BC28-Verkauf Sinn?

### 2.1 Kern-Messages (Muss)

| # | Message | Richtung | BC-Entsprechung | Nutzen |
|---|---|---|---|---|
| 1 | **ORDERS** | Kunde → BC | Verkaufsauftrag (Sales Order) | Digitaler Bestelleingang ohne manuelle Erfassung |
| 2 | **ORDRSP** | BC → Kunde | Auftragsbestätigung | Automatische Rückmeldung: bestätigt, geändert, abgelehnt |
| 3 | **DESADV** | BC → Kunde | Warenausgang/Lieferschein (Posted Sales Shipment) | Lieferavis mit Packstück-Hierarchie, Tracking-Nummern |
| 4 | **INVOIC** | BC → Kunde | Gebuchte Verkaufsrechnung (Posted Sales Invoice) | Elektronische Rechnungsstellung |

### 2.2 Erweiterte Messages (Soll)

| # | Message | Richtung | BC-Entsprechung | Nutzen |
|---|---|---|---|---|
| 5 | **ORDCHG** | Kunde → BC | Änderung/Storno Verkaufsauftrag | Mengen-, Termin-, Preisänderungen ohne Telefon/Mail |
| 6 | **APERAK** | Bidirektional | Technische Rückmeldung | „Datei erhalten und syntaktisch OK / Fehler XYZ" |
| 7 | **CONTRL** | Bidirektional | Syntax-Prüfung | Bestätigung des Interchange-Empfangs (UNB/UNZ-Ebene) |

### 2.3 Optionale Messages (Kann)

| # | Message | Richtung | BC-Entsprechung | Nutzen |
|---|---|---|---|---|
| 8 | **DELFOR** | Kunde → BC | Lieferplan (Planning Worksheet) | Langfristige Bedarfsvorschau für Produktionsplanung |
| 9 | **CREADV** | Kunde → BC | Gutschrift (Sales Credit Memo) | Automatische Reklamationsgutschrift |
| 10 | **REMADV** | Kunde → BC | Zahlungsavise | Automatischer Zahlungsabgleich (Cash Application) |

---

## 3. Ablauf: Der vollständige Order-to-Cash-Zyklus

```
┌──────────────────────────────────────────────────────────────────┐
│                    ORDER-TO-CASH MIT EDIFACT D.97A               │
└──────────────────────────────────────────────────────────────────┘

KUNDE                                          BUSINESS CENTRAL 28
─────                                          ──────────────────

  │  ① ORDERS (Purchase Order)                       │
  │────────────────────────────────────────────────▶│
  │                                                  │  → EDIFACT Transfer (Tab 50005)
  │                                                  │  → Parser (D97A)
  │                                                  │  → Mapper → Staging (D97 Staging Header/Line)
  │                                                  │  → Validator prüft Artikel, Partner, Mengen
  │                                                  │
  │  ② APERAK / CONTRL                               │  → Processor erstellt Sales Order
  │◀────────────────────────────────────────────────│  → ORDRSP-Mapper füllt Staging
  │  (Syntax-OK + Empfangsbestätigung)               │  → Encoder erzeugt EDIFACT
  │                                                  │
  │  ③ ORDRSP (Order Response)                       │
  │◀────────────────────────────────────────────────│
  │  · Status: Bestätigt / Geändert / Abgelehnt      │
  │  · Bestätigte Mengen & Termine                   │
  │  · Alternativartikel falls Ersatz                │
  │                                                  │
  │                                                  │  → Sales Order wird kommissioniert
  │                                                  │  → Warenausgang wird gebucht
  │                                                  │    (Posted Sales Shipment)
  │                                                  │  → DESADV-Mapper füllt Staging
  │                                                  │  → Encoder erzeugt EDIFACT
  │                                                  │
  │  ④ DESADV (Despatch Advice)                      │
  │◀────────────────────────────────────────────────│
  │  · CPS: Paletten/Karton-Hierarchie               │
  │  · PAC: Verpackungsdetails                       │
  │  · GIN: SSCC-Seriennummern                       │
  │  · LIN: Artikel, Mengen, Chargen                 │
  │  · DTM: Lieferdatum, Versanddatum                │
  │  · TDT: Spediteur, Tracking-Nummer               │
  │                                                  │
  │                                                  │  → Verkaufsrechnung wird gebucht
  │                                                  │    (Posted Sales Invoice)
  │                                                  │  → INVOIC-Mapper füllt Staging
  │                                                  │  → Encoder erzeugt EDIFACT
  │                                                  │
  │  ⑤ INVOIC (Invoice)                              │
  │◀────────────────────────────────────────────────│
  │  · Rechnungsnummer, -datum                       │
  │  · Positionen, Mengen, Preise                    │
  │  · Steuern (TAX), Zahlungsbedingungen (PAT)      │
  │  · Gesamtbetrag (MOA)                            │
  │                                                  │
  │  ⑥ REMADV (Remittance Advice)                    │
  │────────────────────────────────────────────────▶│
  │  · Zahlungsbetrag & -datum                       │  → Automatischer Zahlungsabgleich
  │  · Referenz auf INVOIC                            │    (Cash Application)
  │                                                  │
  │  ⑦ CREADV (Credit Advice)                        │
  │────────────────────────────────────────────────▶│
  │  · Gutschrift wegen Retoure/Reklamation          │  → Sales Credit Memo erstellen
  │                                                  │
```

### 3.1 ORDCHG — Änderungsschleife (Detail)

```
KUNDE                                          BUSINESS CENTRAL 28
─────                                          ──────────────────

  │  ORDCHG (Order Change)                           │
  │────────────────────────────────────────────────▶│
  │  · BGM+230 = Änderung (vs. 220 = Neu)           │  → Staging-Eintrag mit Change-Type
  │  · RFF+ON: Referenz auf Original-ORDERS          │  → Suche bestehenden Sales Order
  │  · LIN: nur geänderte Positionen                 │  → Zeilenweise Änderung:
  │    ├ QTY+21: neue Menge                          │     · Menge ändern
  │    ├ DTM+2: neuer Liefertermin                   │     · Liefertermin ändern
  │    ├ PRI+AAA: neuer Preis                        │     · Preis ändern
  │    └ LIN+...: stornierte Positionen              │     · Zeile löschen
  │                                                  │  → ORDRSP über Änderungsstatus
  │  ◀─────────────────────────────────────────────  │
```

---

## 4. Auswirkungen der einzelnen Messages auf BC

### 4.1 ORDERS — Eingang einer Bestellung

| Ebene | Auswirkung |
|---|---|
| **Daten** | `Sales Header` + `Sales Line` werden automatisch angelegt |
| **Validierung** | Artikelstamm, Debitor, Lieferadresse, Mengen > 0, Preise |
| **Fehler** | Bei fehlendem Artikel → Staging behält Daten, Error-Log-Eintrag, manuelle Korrektur möglich |
| **Nummernkreis** | BC-interne `Sales Header."No."` wird vergeben; externe `External Order No.` aus BGM gespeichert |
| **Logistik** | `Requested Delivery Date` aus DTM+2 wird in Sales Header übernommen |
| **Preise** | Entweder aus EDIFACT übernehmen oder BC-Preislogik greift (je nach Partner-Setup) |
| **Rabatte** | Falls `ALC`-Segment vorhanden → Zeilen- oder Kopfrabatt |

### 4.2 ORDRSP — Bestätigung oder Ablehnung

| Ebene | Auswirkung |
|---|---|
| **Daten** | Verkaufsauftrag erhält Status-Update: Bestätigt / Teilbestätigt / Abgelehnt |
| **Mengen** | `QTY+21` (bestätigte Menge) kann von `QTY+192` (bestellte Menge) abweichen |
| **Termine** | `DTM+2` (bestätigter Liefertermin) überschreibt ggf. Wunschtermin |
| **Alternativen** | `LIN` mit `PIA+5` (Ersatzartikel) → Benutzer entscheidet über Annahme |
| **Kunde** | Erhält Planungssicherheit: weiß sofort, ob/wan/wie viel geliefert wird |

### 4.3 DESADV — Lieferung wurde versendet

| Ebene | Auswirkung |
|---|---|
| **Daten** | `Posted Sales Shipment` existiert bereits → DESADV transportiert Zusatzinfos |
| **Logistik** | `CPS`-Hierarchie (Palette → Karton → Artikel) wird übertragen |
| **Tracking** | `GIN`-Segment: SSCC-Nummern (NVE) für jede Versandeinheit |
| **Serien/Chargen** | `LIN` → `GIN` (Seriennummern) oder `ATT` (Chargennummern) |
| **Spedition** | `TDT` mit Spediteur, `RFF` mit Tracking-Nummer |
| **Wareneingang** | Beim Kunden: Scannen der SSCC genügt zur Vereinnahmung |

### 4.4 INVOIC — Rechnungsstellung

| Ebene | Auswirkung |
|---|---|
| **Daten** | `Posted Sales Invoice` → gesetzlich relevante Rechnungsdaten |
| **Steuern** | `TAX`-Segment: Steuerart, -satz, -betrag (pro Position und Summe) |
| **Währung** | `CUX` auf Kopf- und optional Zeilenebene |
| **Zahlungsziel** | `PAT` → Payment Terms: Skonto-Fristen, Nettotage |
| **Summenteil** | `UNS+S` trennt Positionen vom Summenteil (`MOA+77` = Gesamtbetrag) |
| **Compliance** | GoBD/GDPdU-konforme Archivierung der Original-EDIFACT-Datei |

### 4.5 ORDCHG — Änderung einer bestehenden Bestellung

| Ebene | Auswirkung |
|---|---|
| **Daten** | `Sales Line`-Felder werden modifiziert oder Zeilen gelöscht |
| **Log** | Änderungshistorie im Staging + Error-Log nachvollziehbar |
| **Geschäftsregeln** | Nur erlaubt, solange noch keine Lieferung erfolgt ist |
| **ORDRSP** | Automatische Bestätigung der Änderung an den Kunden |

### 4.6 APERAK / CONTRL — Technische Rückmeldungen

| Ebene | Auswirkung |
|---|---|
| **CONTRL** | Bestätigt Interchange-Empfang (UNB/UNZ); bei Fehler: genaue Segment-Position |
| **APERAK** | Bestätigt Anwendungs-Empfang (UNH/UNT); enthält ggf. Business-Fehler |
| **Monitoring** | Bei fehlendem APERAK → Sender weiß: Nachricht kam nicht an → Resend |
| **Automation** | Kein manuelles „Hast du meine Bestellung erhalten?"-Telefonat |

---

## 5. Integration in BC28: Technische Umsetzung

### 5.1 Architektur-Überblick (Interface-basiert, v3.0)

```
┌──────────────────────────────────────────────────────────────┐
│                   BC28 Sales Integration                      │
└──────────────────────────────────────────────────────────────┘

┌─────────────────┐    ┌──────────────────┐    ┌──────────────┐
│ Tab 50005       │    │ EDIFACT Transfer │    │ Factories    │
│ EDIFACT Transfer│───▶│ Manager          │───▶│ (Codeunit)   │
│ (Blob-basiert)  │    │ (Codeunit 50000) │    │              │
└─────────────────┘    └──────────────────┘    │ ┌──────────┐ │
                                               │ │ D97A     │ │
     External API                              │ │ Parser   │ │
     POST/GET                                  │ ├──────────┤ │
     Blob                                      │ │ D97A     │ │
                                               │ │ Encoder  │ │
                                               │ ├──────────┤ │
                                               │ │ Mapper:  │ │
                                               │ │ · ORDERS │ │
                                               │ │ · ORDRSP │ │
                                               │ │ · DESADV │ │
                                               │ │ · INVOIC │ │
                                               │ │ · ORDCHG │ │
                                               │ ├──────────┤ │
                                               │ │ Process: │ │
                                               │ │ · ORDERS │ │
                                               │ │ · ORDCHG │ │
                                               │ └──────────┘ │
                                               └──────────────┘
```

### 5.2 Trigger-Punkte für Outbound-Messages

BC28 Business Events als Auslöser:

| Message | BC-Event | Zeitpunkt |
|---|---|---|
| **ORDRSP** | `SalesOrderReleased` + `OnAfterInsert` Sales Header | Nach Generierung der Auftragsbestätigung |
| **DESADV** | `OnAfterPostSalesShipment` | Nach Buchen des Warenausgangs |
| **INVOIC** | `OnAfterPostSalesInvoice` | Nach Buchen der Verkaufsrechnung |
| **APERAK** | `OnAfterProcessTransfer` | Nach erfolgreichem/fehlgeschlagenem Processing |

### 5.3 Dynamisches Mapping (Tab 50007)

Partner-spezifische Transformationen ohne Code-Änderung:

| Mapping-Typ | Source (EDIFACT) | Target (BC) |
|---|---|---|
| `UoM_D97A` | `PC` | `STK` (Stück) |
| `UoM_D97A` | `CS` | `KAR` (Karton) |
| `UoM_D97A` | `PAL` | `PAL` (Palette) |
| `ItemRef_PartnerX` | `ABC-001` | `ITEM-0001` |
| `TaxCode_D97A` | `VAT` | `MwSt. 19%` |
| `PaymentTerms` | `14D3%30D` | `14 TAGE 3% 30 NETTO` |

### 5.4 Fehlerbehandlungs-Strategie

```
EDI-Datei kommt an
       │
       ▼
  ┌──────────────┐
  │ 1. CONTRL    │── Fehler? → Fehler an Sender, STOP
  │    prüfen    │
  └──────┬───────┘
         │ OK
         ▼
  ┌──────────────┐
  │ 2. Parser    │── Fehler? → Error-Log, Status=Error
  │    D97A      │              Manuelle Prüfung
  └──────┬───────┘
         │ OK
         ▼
  ┌──────────────┐
  │ 3. Validator │── Fehler? → Error-Log + Staging
  │    (Syntax)  │              Benutzer korrigiert
  └──────┬───────┘
         │ OK
         ▼
  ┌──────────────┐
  │ 4. Mapper    │── Fehler? → Error-Log + Staging
  │    → Staging │              Benutzer korrigiert
  └──────┬───────┘
         │ OK
         ▼
  ┌──────────────┐
  │ 5. Validator │── Fehler? → Error-Log + Staging
  │  (Business)  │              Benutzer ergänzt Daten
  └──────┬───────┘
         │ OK
         ▼
  ┌──────────────┐
  │ 6. Processor │── Fehler? → Error-Log + Staging
  │    → BC Doc  │              Retry möglich
  └──────┬───────┘
         │ OK
         ▼
  ┌──────────────┐
  │ 7. APERAK    │── Sender erhält OK (oder Fehler)
  │    senden    │
  └──────────────┘
```

---

## 6. Messaging-Matrix: Wer sendet was wann?

| Prozessschritt | Kunde → BC | BC → Kunde | BC-intern |
|---|---|---|---|
| Bestellung wird ausgelöst | ORDERS | — | — |
| Technische Prüfung | — | CONTRL | — |
| Inhaltliche Prüfung | — | APERAK | Validator läuft |
| Auftrag angelegt | — | — | `Sales Header` + `Sales Line` |
| Auftragsbestätigung | — | ORDRSP | — |
| Auftragsänderung | ORDCHG | — | `Sales Line` wird modifiziert |
| Änderungsbestätigung | — | ORDRSP | — |
| Warenausgang gebucht | — | — | `Posted Sales Shipment` |
| Lieferavis | — | DESADV | `Posted Sales Shpt.` → Staging → EDIFACT |
| Rechnung gebucht | — | — | `Posted Sales Invoice` |
| Elektronische Rechnung | — | INVOIC | `Posted Sales Inv.` → Staging → EDIFACT |
| Zahlungsavise | REMADV | — | Cash Application |
| Reklamationsgutschrift | CREADV | — | `Sales Credit Memo` |

---

## 7. D97A/B-spezifische Besonderheiten im Vergleich zu D96A

### 7.1 Neue Segmente/Qualifier für BC-Verkauf

| Segment | D97A/B-Neuerung | BC-Nutzen |
|---|---|---|
| `BGM` | Qualifier `230` = Änderungsauftrag | **ORDCHG** überhaupt erst möglich |
| `RFF` | `ON` = Order Number, `DQ` = Delivery Note | Bessere Referenzverknüpfung |
| `DTM` | `10` = Shipment Date Requested, `63` = Delivery Date Latest | Feinere Terminsteuerung |
| `QTY` | `52` = Quantity per Pack, `59` = Number of Consumer Units | Packstück-Details im DESADV |
| `FTX` | `AAI` = General Information, `DEL` = Delivery Information | Strukturierte Texte statt Freitext |
| `CUX` | Zeilenebene möglich | Multi-Währungs-Zeilen |
| `TAX` | `7` = Tax, `VAT`, `GST` je nach Setup | Mehrstufige Steuern |

### 7.2 D97A Nachrichten-Struktur ORDERS (vereinfacht)

```
UNH+1+ORDERS:D:97A:UN:EAN008'
BGM+220+PO-2026-0042+9'
DTM+137:20260624:102'                     ← Belegdatum
RFF+CR:A-12345'                           ← Kundenreferenz (neu in D97A)
RFF+VA:VAT-98765'                         ← USt-ID Referenz
NAD+BY+DE123456789::9'                    ← Buyer
NAD+SU+DE987654321::9'                    ← Supplier
CUX+2:EUR:9'                              ← Währung (Kopf)
LIN+1++ARTIKEL-001:SA'                    ← Zeile 1
PIA+1+EAN-4001234567890:SA'              ← EAN (neu in D97A)
QTY+21:100:PCE'                           ← Bestellmenge
DTM+2:20260715:102'                       ← Liefertermin
TAX+7+VAT+++:::19+S'                      ← Steuer 19% (neu in D97A)
UNS+S'
CNT+2:1'
UNT+14+1'
```

---

## 8. Empfehlung: Phasenweise Einführung

### Phase 1: Basis (Wochen 1–4)
- **ORDERS** (Inbound) → Verkaufsauftrag
- **ORDRSP** (Outbound) → Auftragsbestätigung
- **APERAK** (Bidirektional) → Technische Rückmeldung
- Transfer-Tabelle (Tab 50005), Parser D97A, Base Interfaces

### Phase 2: Logistik (Wochen 5–8)
- **DESADV** (Outbound) → Lieferavis mit CPS/PAC/GIN
- **ORDCHG** (Inbound) → Auftragsänderung
- Dynamisches Mapping (Tab 50007) für UoM und Artikelreferenzen

### Phase 3: Finanzen (Wochen 9–12)
- **INVOIC** (Outbound) → Elektronische Rechnung
- **REMADV** (Inbound) → Zahlungsabgleich
- **CREADV** (Inbound) → Reklamationsgutschriften

### Phase 4: Planung (optional)
- **DELFOR** (Inbound) → Lieferplan-Integration
- **CONTRL** (Bidirektional) → Syntax-Prüfung auf Interchange-Ebene

---

## 9. Quellen & Referenzen

| Quelle | URL | Inhalt |
|---|---|---|
| **edifactory.de** | `https://www.edifactory.de/edifact/directories` | Vollständige Segment-/Message-Verzeichnisse für alle Versionen |
| **edifactory.de D97A** | `https://www.edifactory.de/edifact/directory/D97A` | D.97A-spezifisch |
| **UNECE** | `https://unece.org/uncefact/unedifact/2021-2024` | Offizielle UN/EDIFACT-Directories |
| **XEDI** | `https://xedi.com/resources/edifact` | Segment-Vergleich über Versionen |
| **BCEDI Confluence** | `./confluence-docs/BCEDI_*.md` | Lokale Projektdokumentation |

---

> **Status:** Brainstorming / Draft  
> **Nächster Schritt:** Detaillierte Mapping-Tabelle ORDERS D97A → BC `Sales Header`/`Sales Line`  
> **Fragen?** → Als Kommentar im BCEDI-Confluence oder als neue Confluence-Seite.
