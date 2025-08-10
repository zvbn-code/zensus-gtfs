# zensus-gtfs
Verknüpfung der Daten aus dem Zensus 2022 (2011) mit Angebotsdaten aus GTFS

## Datenquellen
- GTFS
    - auf Ebene der Haltestellen

- Zensus
    - Gitterdaten zum Download für geografische Informationssysteme (GIS) https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Bevoelkerung/Zensus2022/_inhalt.html#sprg1403932

    
- Grenzen
    - VBN erzeugt aus OSM
    - Gemeinden und Landkreise aus https://www.destatis.de/static/DE/zensus/gitterdaten/Shapefile_Zensus2022.zip
        - im Verzeichnis entpacken


## Analysen
- Ermitteln der Abfahrten je Haltestelle an einem bestimmten Verkehrstag
- Verschneiden mit dem 100m-Gitterdaten (Mittelpunkt) aus dem Zensus
- Verschneiden mit den Gemeindegrenzen
- Ermitteln der erschlossenen Einwohner je Gemeinde
- Parameter wie Mindestanzahl von Abfahrten je Haltestelle