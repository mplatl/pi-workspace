# General Import Interface #

## Brainstorming ##

In Business Central soll man mehrere Import Einrichtungen anlegen können. Ähnlich wie die Konfigurationspakete. 
Der Import soll im ersten Schritt nur für Buchblätter gelten. 
Buchblätter funktionieren in Business Central immer gleich. 
- Buchblätter haben Vorlagename und Name
- Buchblätter haben eine Zeilennummer
- Abhängig vom Buchblatt gibt es eine entsprechende Buchungsroutine

Diese Punkte können somit fix vordefiniert programmiert werden. Somit soll man im Import Setup ein Buchblatt wählen können. Manchmal macht es aber auch sinn abhängig von den importierten Daten ein entsprechendes Buchblatt zu wählen. Auch das muss später funktionieren. Beispiel: CSV Datei mit Artikel für Verbrauch und Istmeldungen. Wenn Verbrauch -> Buchblatt A, Istmeldung -> Buchblatt B. 
Trotzdem soll man auch die Möglichkeit haben das Buchblatt im Import Setup zu wählen.

* Für die Initialisierung der Daten soll es die Möglichkeit geben die Datei zu importieren. Wir lesen dann alle Spalten und wenn die erste Zeile die Spaltenüberschriften enthält können wir diese gleich für die Darstellung der Import Zeilen (Zeilen zugehörig zum Import Setup) anlegen. Ein manuelles Anlegen des Formats muss auch funktionieren. 
* Pro Spalte müssen wir auch ein Mapping machen können um zu definieren in welches Feld im Buchblatt die Spalte eingetragen werden muss. Beim Eintragen muss auch das in Business Central übliche Validate ausgeführt werden können. Aber man muss dieses Validate auch überspringen können. 
* Es kann notwendig sein, abhängig vom Wert der importiert wird auch weitere Spalten im Buchblatt zu setzen! Beispiel: Wenn Typ = Istmeldung dann Belegnummer befüllen oder eben nicht befüllen. 
* Es kann auch sein, dass in der Datei der Wert "Istmeldung" steht, wir aber statt Istmeldung den Wert "1" setzen wollen. Somit benötigen wir die MÖglichkeit unterschiedliche Mappings pro Spalte zu machen



TODO: Erstelle ein Konzept. Keine Programmierung im ersten Schritt. Konzept als .MD Datei

