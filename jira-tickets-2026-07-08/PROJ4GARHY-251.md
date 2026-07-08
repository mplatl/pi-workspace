# PROJ4GARHY-251: PIM / RWA Onfarming Export

| Feld | Wert |
|------|------|
| Status | In Progress |
| Priorität | Medium |
| Typ | Support |
| Projekt | null - null |
| Assignee | nicht zugewiesen |
| Reporter | hinterndorfer@garant.co.at |
| Erstellt | 2026-05-20T08:57:43.000+0200 |
| Aktualisiert | 2026-07-01T12:14:35.000+0200 |

## Beschreibung

Der Export läuft noch nicht, es werden keine Daten ausgegeben  

Mit freundlichen Grüßen 
 

Dipl. Fw. Markus Hinterndorfer
Leitung IT / Head of IT
 


Garant-Tiernahrung Gesellschaft m.b.H.
Raiffeisenstraße 3 | A-3380 Pöchlarn 

Tel: +43 2757 2281 408 | FAX: +43 2757 2281 67408
Hinterndorfer@garant.co.at | www.garant.co.at

Es gelten die in den Geschäftsräumen der Garant Tiernahrung GmbH ausgehängten und auf der Homepage [https://shop.garant.co.at/agb|https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fshop.garant.co.at%2Fagb&data=05%7C02%7Cgarsd%40cegeka.com%7Cb0131948e34547883de208deb63cf88e%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639148570165947133%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=%2BpKcaqWndtUH0YaGkmjqeqhUq72PBrvZ6ub3Gk3Rsyw%3D&reserved=0] veröffentlichten Allgemeinen Geschäftsbedingungen, die dem Kunden auf dessen Verlangen unentgeltlich ausgehändigt werden. 

{color:#222222}{color} 

Firmensitz: Pöchlarn | Firmenbuchgericht: Landesgericht St. Pölten | Firmenbuchnummer: FN 90109p;
Informationen zum Datenschutz (Privacy Information) finden Sie unter [http://www.garant.co.at/datenschutz|https://eur03.safelinks.protection.outlook.com/?url=http%3A%2F%2Fwww.garant.co.at%2Fdatenschutz&data=05%7C02%7Cgarsd%40cegeka.com%7Cb0131948e34547883de208deb63cf88e%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639148570165986547%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=VviLN26%2BfhxMfbyhJCtRs%2B0FbktdOuiGyPQsC75NCD0%3D&reserved=0]
Diese E Mail Mitteilung ist ausschließlich für den Empfänger bestimmt und kann privilegierte Informationen enthalten. Sollten Sie diese Nachricht irrtümlich erhalten, bitten wir Sie, uns zu verständigen und diese Nachricht sofort zu vernichten.


  

 

{color:#222222}{color}

## Verknüpfte Issues


## Kommentare (8)

### hinterndorfer@garant.co.at — 2026-06-11T16:53:08.000+0200

Im Test mit Hr. Platl getestet - Bereit zur Übernahme ins Live

### hinterndorfer@garant.co.at — 2026-06-23T15:51:36.000+0200

PIM Export Files funktioniert (XLS file für Artikel, Basisprodukte, mediaImport)

Aufgabenwarteschlangenposten für Export Bilder und Dokumente fehlt noch





### hinterndorfer@garant.co.at — 2026-06-23T16:09:09.000+0200

Ausgabedateien haben auch Fehler:
alte und neue mittels KI analysiert (zur Sicherheit auch zur Kontrolle an RWA gesandt per Mail)

h1. *Basisprodukte_23_6_2026_13_28_45.xlsx*

h3.  *Codierung / Encoding*

Mir ist sofort aufgefallen:

* 2026 Datei hat viele Zeichen wie:
** {{FÃ¼tterung}}
** {{KÃ¤lber}}
* 2025 Datei hat:
** korrekt {{Fütterung}}, {{Kälber}}

👉 *das ist kein Satzaufbau-Thema, sondern Encoding-Problem (UTF-8 vs. ANSI)*



h1. *Artikel_23_6_2026_13_28_06.xlsx*

h1. *Datenstruktur – Gesamturteil*

👉 *Grundstruktur ist gleich (kompatibel)*
👉 *aber NICHT 1:1 identisch*

h1. *Attributstruktur (wichtigster Punkt)*

h3. ALT (2025)

{noformat}rwaClass/1.0/Class_054211.attribute_064397
{noformat}

h3. NEU (2026)

{noformat}waClass/1.0/Class_054211/Attribute_064397
{noformat}

👉 Unterschiede:

* Prefix geändert: {{rwaClass}} → {{waClass}}
* Trennzeichen: {{.}} → {{/}}
* Schreibweise: {{attribute}} → {{Attribute}}

h1. *Werte / Codierungen*

h3. ALT

* viele Werte wie:
** {{Ja}}

h3. NEU

* teilweise ersetzt durch:
** {{B}}, {{J}}, {{P}}

👉 Bedeutet:

* Bool / Kennzeichen wurden geändert

➡️ *Mapping-Risiko\!*



h1. *mediaImport_23_6_2026_13_28_31.xlsx → dürfte OK sein*





### hinterndorfer@garant.co.at — 2026-06-23T16:49:24.000+0200

Dieser Job läuft auch nicht - gehört zu Onfarming → xml Export

vor dem 16.03.2026 täglich gelaufen



!image.png|thumbnail!

!image-1.png|thumbnail!

!image-2.png|thumbnail!

### hinterndorfer@garant.co.at — 2026-06-29T14:03:11.000+0200

Aufgabenwarteschlangenpostern für XML Export eingerichtet - XML wird korrekt exportiert

### hinterndorfer@garant.co.at — 2026-06-29T16:26:38.000+0200

Artikel_23_6_2026_13_28_06.xlsx - passt lt Hr. Platl
Basisprodukte_23_6_2026_13_28_45.xlsx -> Codierung passt in der Spalte "T" nicht, muss angepasst werden



### hinterndorfer@garant.co.at — 2026-06-29T16:30:26.000+0200

zum Artikel xls habe ich noch folgendes in unserem Ticketsystem gefunden
da stand damals schon falsch waClass statt rwaClass im File
dürfte doch jetzt wieder falsch sein
damaliges Ticket: GARA-108: PIM Massendatenpflege per Excel

!image-3.png|thumbnail!

### hinterndorfer@garant.co.at — 2026-06-29T16:34:07.000+0200

Hier die Infos aus unserem Ticketsystem zu der Umsetzung von damals

[^Ticket_2024051010000042_2026-06-29_16_31.pdf] _(448 kB)_

---

