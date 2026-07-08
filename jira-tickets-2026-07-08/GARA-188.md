# GARA-188: Verkauf Aufträge Preisanpassung nach Mengenänderung funktioniert nicht

| Feld | Wert |
|------|------|
| Status | In Progress |
| Priorität | Critical |
| Typ | Support |
| Projekt | null - null |
| Assignee | Michael Platl |
| Reporter | Roland Haunschmied |
| Erstellt | 2026-06-11T12:12:53.000+0200 |
| Aktualisiert | 2026-07-06T16:43:50.000+0200 |

## Beschreibung

Hallo,

wir haben hier ein Problem bei der Preisberechnung von Verkaufsaufträgen festgestellt.

Ich habe den Ablauf in der TEST-Umgebung 1 nachgestellt. Ab hier beziehe ich mich daher auf die TEST-Umgebung. Der gleiche Fehler ist jedoch auch in der LIVE-Umgebung am 11.06.2026 aufgetreten.

 

Das bedeutet, dass sich TEST und LIVE am 11.06.2026 um ca. 10:00 Uhr identisch verhalten haben.

 

*Ablauf*

Über den Webshop wurden automatisch zwei Verkaufsaufträge im BC angelegt. Selber Kunde ,selbes Produkt und Beide Aufträge wurden mit einer Sollmenge von 50 t erstellt.

Da wir 50 t nicht auf einmal liefern können, werden solche Aufträge üblicherweise auf 25 t reduziert und für die Restmenge wird ein weiterer Auftrag manuell angelegt.

Der Fehler tritt bei den automatisch angelegten Aufträgen auf.

Zum Zeitpunkt der Auftragserfassung war für diesen Kunden *kein Preis hinterlegt.* Daher musste der Preis manuell eingetragen werden.

Dabei wurden zwei unterschiedliche Vorgehensweisen getestet:

 

*VA26040228*

* Zuerst wurde der Preis eingetragen.
* Anschließend wurde die Sollmenge von 50 t auf 25 t korrigiert.
* Ergebnis: *_Der Gesamtbetrag bleibt auf Basis von 50 t bestehen und wird nicht neu berechnet._*

*VA26040229*

* Zuerst wurde die Sollmenge von 50 t auf 25 t korrigiert.
* Anschließend wurde der Preis eingetragen.
* Ergebnis: Der Gesamtbetrag wird korrekt auf Basis von 25 t berechnet.

 

*Erwartetes Verhalten*

Nach einer Änderung der Sollmenge sollte der Gesamtbetrag unabhängig von der Reihenfolge der Eingaben neu berechnet werden.

Derzeit scheint die Neuberechnung nicht zu erfolgen, wenn zuerst der Preis eingetragen und danach die Menge geändert wird.

 



## Verknüpfte Issues
* relates to [PROJ4GARHY-267]: 2 gleich Verkaufsaufträge, 2 unterschiedliche Endsummen

## Kommentare (4)

### Roland Haunschmied — 2026-06-11T12:12:54.000+0200



[^VA26040228.mp4] _(15.47 MB)_

[^VA26040229.mp4] _(18.72 MB)_

!image-1.png|thumbnail!

!image.png|thumbnail!

### Andreas Hargassner — 2026-06-13T17:25:02.000+0200

[~Michael.Platl@cegeka.com] : Bitte bearbeiten.

### hinterndorfer@garant.co.at — 2026-06-17T10:47:12.000+0200

Prio1 Ticket

### hinterndorfer@garant.co.at — 2026-07-06T16:43:50.000+0200

Status?

---

