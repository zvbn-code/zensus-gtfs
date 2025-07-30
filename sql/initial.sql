load spatial;
load httpfs;
--Einlesen der Linientabelle aus DM
-- erfolgt jetzt über attach 02.12.2024
--create or replace table linien_dm as select * from read_csv_auto('input/linien_dm.csv');

--Erzeugen eines ENUM Type (begrenzte Anzahl von Werten) nur mit String nicht integer
--bei Type gibt es kein replace, daher können diese nur einmalig ausgeführt, ansonsten Error
CREATE TYPE enum01 AS ENUM ('0', '1');
CREATE TYPE enum012 AS ENUM ('0', '1', '2');
CREATE TYPE enum0123 AS ENUM ('0', '1', '2', '3');
CREATE TYPE enum01234 AS ENUM ('0', '1', '2', '3', '4');
CREATE TYPE enum12 AS ENUM ('1', '2');
CREATE TYPE enum_route_type AS ENUM ('0','1', '2','3', '4', '5', '6', '7', '11', '12');