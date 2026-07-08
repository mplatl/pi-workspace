---
title: "Standard Schnittstellen"
confluence_id: "163053570"
space: "BCEDI"
url: "https://mip-dev.atlassian.net/wiki/spaces/BCEDI/pages/163053570/Standard+Schnittstellen"
last_modified: "2025-11-14T20:27:14.154Z"
author: "Michael Platl"
fetched_at: "2026-06-24T22:00:48.265Z"
---

# Standard Schnittstellen

#### 1. **ORDERS** &ndash; *Purchase Order*
- Wird verwendet, um eine Bestellung vom Kunden an den Lieferanten zu senden.

- 
Inhalt:

Kundeninformationen

- 
Artikelpositionen

- 
Mengen, Preise

- 
Lieferbedingungen

- 
Wunschlieferdatum

#### 2. **ORDRSP** &ndash; *Order Response*
- 
Antwort auf eine Bestellung (z. B. Best&auml;tigung, Ablehnung, &Auml;nderung).

- 
Inhalt:

Referenz zur Bestellung

- 
Best&auml;tigte Mengen und Liefertermine

- 
&Auml;nderungen oder Kommentare

#### 3. **DESADV** &ndash; *Despatch Advice*
- 
Versandavis, informiert &uuml;ber bevorstehende Lieferung.

- 
Inhalt:

Lieferdatum

- 
Verpackungsinformationen

- 
Artikel und Mengen

- 
Transportdetails

#### 4. **INVOIC** &ndash; *Invoice*
- 
Elektronische Rechnung.

- 
Inhalt:

Rechnungsnummer, Datum

- 
Artikel, Mengen, Preise

- 
Steuerinformationen

- 
Zahlungsbedingungen

#### 5. **RECADV** &ndash; *Receiving Advice*
- 
Best&auml;tigung des Wareneingangs.

- 
Inhalt:

Empfangene Mengen

- 
Abweichungen

- 
Datum und Uhrzeit des Wareneingangs

#### 6. **CREDIT NOTE / DEBMUL** &ndash; *Gutschrift / Debit Note*
- 
F&uuml;r Reklamationen oder Preisnachl&auml;sse.

- 
Inhalt:

Referenz zur Rechnung

- 
Gutschriftbetrag

- 
Grund der Gutschrift
