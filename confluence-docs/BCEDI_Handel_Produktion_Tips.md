---
title: "Handel und Produktion Tips"
confluence_id: "168525847"
space: "BCEDI"
url: "https://mip-dev.atlassian.net/wiki/spaces/BCEDI/pages/168525847/Handel+und+Produktion+Tips"
last_modified: "2025-11-18T23:47:55.696Z"
author: "Michael Platl"
fetched_at: "2026-06-24T22:00:48.204Z"
---

# Handel und Produktion Tips

Hier ist eine **umfassende Analyse f&uuml;r ein Handels- bzw. Produktionsunternehmen**, welche **EDIFACT D.96A-Nachrichten** von XEDI relevant sind und welche meist verzichtbar sind:

---

## ✅ Empfohlene D.96A-Nachrichten f&uuml;r Handel & Produktion

| Nachricht | Zweck | Anwendungsbereich |
| --- | --- | --- |
| **ORDERS** | Auftragserteilung | essentiell f&uuml;r Auftragserfassung &ndash; Standardsegmentgruppe mit BGM, DTM, PAI, MOA, NAD &hellip; [[xedi.com]](https://xedi.com/resources/edifact/D96A/orders), [[edifactory.de]](https://www.edifactory.de/edifact/directory/D96A/message/INVOIC) |
| **ORDRSP** | Auftragbest&auml;tigung/-ablehnung | Feedback auf ORDERS &ndash; enth&auml;lt Mengen, Preise, Termine [[support.ariba.com]](https://support.ariba.com/item/download?item_id=190553&locale=en) |
| **DELFOR** | Lieferplan / Forecast | Steuerung Produktion und Logistik &ndash; enth&auml;lt Terminvorgaben [[adient.com]](https://www.adient.com/wp-content/uploads/2021/11/Adient_EDI-Implementation-Guide-DELFOR-UN-D96A-Updated-Logo.pdf) |
| **DESADV** | Versandavis (ASN) | Warennachverfolgung &ndash; enth&auml;lt CPS, PAC, QTY, GIN, etc. [[help.sap.com]](https://help.sap.com/doc/sap-business-network-edifact-desadv-d96a-inbound/cloud/en-US/SAP%20Business%20Network%20EDIFACT%20DESADV%20D96A%20Inbound.pdf) |
| **INVOIC** | Rechnung / Gutschrift / Lastschrift | Kernmeldung f&uuml;r Zahlungsprozesse &ndash; unterst&uuml;tzt Positionen, Summen, W&auml;hrungen [[edifactory.de]](https://www.edifactory.de/edifact/directory/D96A/message/INVOIC) |
| **CREADV / DEBADV** | Kredit-/Debit Advice | optional &ndash; f&uuml;r Finanzabgleiche nach INVOIC |
| **CUSMAN / IFTMIN / IFTMBC** | Transport- & Zollinfos | relevant bei externen Logistikprozessen [[xedi.com]](https://xedi.com/resources/edifact/D96B) |
| **DOCINF / DOCADV** | Dokumenten-Akkreditiv/Status | bei Handelsfinanzierung n&ouml;tig &ndash; nicht universell ben&ouml;tigt [[xedi.com]](https://xedi.com/resources/edifact/D96B) |
| **APERAK** | Technische Ack/Nachrichtenverarbeitung | zur Integrit&auml;tspr&uuml;fung &ndash; n&uuml;tzlich f&uuml;r EDI-Fehlermanagement |

---

## 🚫 Nachrichten, die oft nicht ben&ouml;tigt werden
- 
**HANMOV**, **BAPLIE**, **BAPLTE**, etc. &ndash; spezialisiert auf maritime/Containerlogistik [[xedi.com]](https://xedi.com/resources/edifact/D96B)

- 
**DIRDEB**, **BOPBNK**, **BOPINF** &ndash; Bank-/Debitor-Meldungen, normalerweise durch Banken ersetzt [[xedi.com]](https://xedi.com/resources/edifact/D96B)

- 
**CUSCAR**, **CUSDEC**, **CUSREP** &ndash; customs / zollbezogen; nur bei direktem Zollkontakt ben&ouml;tigt [[xedi.com]](https://xedi.com/resources/edifact/D96B)

- 
**GSMSGES**, **COMDIS**, **CON* &ndash; kontextspezifisch f&uuml;r reine Transport-/Containerprozesse [[xedi.com]](https://xedi.com/resources/edifact/D96B)

---

## 🔎 Auswahllogik f&uuml;r D.96A-Nachrichten
1. 
EDI-Startpunkt: **ORDERS &rarr; ORDRSP &rarr; DELFOR &rarr; DESADV &rarr; INVOIC**

2. 
Finanzmeldung: **CREADV / DEBADV**

3. 
Technische Acknowledgements: **APERAK**

4. 
Transport-Partner/WZOLL: nur bei externen Logistikketten oder direktem Zollkontakt

5. 
Dokumente: nur bei Akkreditiv-gest&uuml;tzten Lieferungen

---

### 🔗 N&uuml;tzliche Quellen & Dokumente
- 
**XEDI Liste D.96A** mit allen Message-Typen [[xedi.com]](https://xedi.com/resources/edifact)

- 
**XEDI Implementierungsseite ORDRSP**, DELFOR, etc. [[support.ariba.com]](https://support.ariba.com/item/download?item_id=190553&locale=en), [[adient.com]](https://www.adient.com/wp-content/uploads/2021/11/Adient_EDI-Implementation-Guide-DELFOR-UN-D96A-Updated-Logo.pdf)

- 
**Faurecia INVOIC-Guide** (optional: Steueranforderungen CZ/SK/PL) [[forvia.com]](https://www.forvia.com/sites/default/files/2024-07/Faurecia%20EDI%20Guideline%20INVOIC%20D96A%20V2R6.pdf)

- 
**UNECE TRSD/EDMD Directory D.96A** f&uuml;r vollst&auml;ndige Segmentverzeichnisse [[unece.org]](https://unece.org/fileadmin/DAM/trade/untdid/d96a/content.htm)

---

## ✔️ Fazit
- 
**Unbedingt erforderlich**: ORDERS, ORDRSP, DELFOR, DESADV, INVOIC

- 
**Optional sinnvoll**: CREADV / DEBADV, APERAK

- 
**Bei Bedarf**: CUSDEC, CUSCAR, IFTMIN/IFTMBC, DOCINF

- 
**Vernachl&auml;ssigbar bei Fokus auf Handel/Produktion**: Container-/Terminal-Nachrichten (BAPLIE, HANMOV &hellip;), Banken-/Zollprozesse ohne Automatisierung

---

Mit dieser &Uuml;bersicht kannst du in **Confluence** gezielt eine Auswahl an D.96A-Meldungen konfigurieren &ndash; zugeschnitten auf Aufwand, Automatisierungstiefe und logistische Anforderungen.

Soll ich dir eine **Confluence-taugliche Tabelle mit Pflicht-, Optional- und Nicht-empfohlenen Nachrichten f&uuml;r Handel & Produktion** erstellen?
