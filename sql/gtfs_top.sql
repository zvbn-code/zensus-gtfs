-- Skript zum Erzeugen einer DuckDB Datenbank mit GTFS Tabellen
-- Version für Toplevel
-- Stand 21.07.2025 mit Festlegen der Datenformate
-- Tausch der Spaltenreihenfolge bei Stop_times

load spatial;
load httpfs;
load zipfs from community;
--Einlesen der Linientabelle aus DM
-- erfolgt jetzt über attach 02.12.2024
--create or replace table linien_dm as select * from read_csv_auto('input/linien_dm.csv');

--Erzeugen eines ENUM Type (begrenzte Anzahl von Werten) nur mit String nicht integer
--bei Type gibt es kein replace, daher können diese nur einmalig ausgeführt, ansonsten Error
--CREATE TYPE enum01 AS ENUM ('0', '1');
--CREATE TYPE enum012 AS ENUM ('0', '1', '2');
--CREATE TYPE enum0123 AS ENUM ('0', '1', '2', '3');
--CREATE TYPE enum01234 AS ENUM ('0', '1', '2', '3', '4');
--CREATE TYPE enum12 AS ENUM ('1', '2');
--CREATE TYPE enum_route_type AS ENUM ('0','1', '2','3', '4', '5', '6', '7', '11', '12');

--Einlesen der GTFS Tabellen
--create or replace table agency as select * from read_csv_auto('/home/ts/python/duckdb/gtfs/agency.txt');
CREATE or REPLACE table agency AS 
	select * from read_csv('gtfs_top/agency.txt', delim=',', header=true, dateformat = '%Y%m%d',
	columns={'agency_id': 'VARCHAR', 
	'agency_name': 'VARCHAR', 
	'agency_url': 'VARCHAR', 
	'agency_timezone': 'VARCHAR', 
	'agency_lang': 'VARCHAR', 
	'agency_phone':'VARCHAR'});

--create or replace table calendar as select * from read_csv_auto('calendar.txt');
CREATE OR REPLACE table calendar AS 
	select * from read_csv('gtfs_top/calendar.txt', delim=',', header=true, dateformat = '%Y%m%d',
	columns={'service_id': 'VARCHAR', 
	'monday': 'enum01', 
	'tuesday': 'enum01', 
	'wednesday': 'enum01', 
	'thursday':'enum01', 
	'friday':'enum01',
	'saturday': 'enum01',
	'sunday' : 'enum01',
	'start_date' : 'DATE',
	'end_date' : 'DATE'});
--create or replace table calendar as select * from read_csv_auto('/home/ts/python/duckdb/gtfs/calendar.txt');

--ALTER TABLE calendar ALTER monday TYPE smallint;
--create or replace table calendar_dates as select * from read_csv_auto('/home/ts/python/duckdb/gtfs/calendar_dates.txt');
CREATE or REPLACE table calendar_dates AS 
	select * from read_csv('gtfs_top/calendar_dates.txt', delim=',', header=true, dateformat = '%Y%m%d',
	columns={'service_id': 'VARCHAR', 
	'date': 'DATE', 
	'exception_type': 'enum12'});

create or replace table frequencies as select * from read_csv_auto('gtfs_top/frequencies.txt');
-- Levels / Pathways in TOP nicht enthalten
--create or replace table levels as select * from read_csv_auto('gtfs_top/levels.txt');
--create or replace table pathways as select * from read_csv_auto('gtfs_top/pathways.txt');
--create or replace table routes as select * from read_csv_auto('/home/ts/python/duckdb/gtfs/routes.txt');
CREATE or REPLACE table routes AS 
	select * from read_csv('gtfs_top/routes.txt', delim=',', header=true, dateformat = '%Y%m%d',
	columns={'route_id': 'VARCHAR', 
	'agency_id': 'VARCHAR', 
	'route_short_name': 'VARCHAR', 
	'route_long_name': 'VARCHAR', 
	'route_type':'INTEGER',  -- eigentlich enum aber fehlerhafte Daten mit route_type 715
	'route_color':'VARCHAR',
	'route_text_color': 'VARCHAR',
	'route_desc' : 'VARCHAR'});

create or replace table service_alerts as select * from read_csv_auto('gtfs_top/service_alerts.txt');
create or replace table shapes as select * from read_csv_auto('gtfs_top/shapes.txt');
--create or replace table stop_times as select * from read_csv_auto('/home/ts/python/duckdb/gtfs/stop_times.txt');
CREATE or REPLACE table stop_times AS 
	select * from read_csv(
		'gtfs_top/stop_times.txt', 
		delim=',', 
		header=true, 
		dateformat = '%Y%m%d', 		
		ignore_errors= true,
	columns={
	'trip_id': 'VARCHAR', 
	'stop_id':'VARCHAR', 
	'stop_sequence':'INT16',	
	'pickup_type' : 'VARCHAR',
	'drop_off_type' : 'VARCHAR',
	'stop_headsign': 'VARCHAR',
    'arrival_time': 'VARCHAR', 
	'departure_time': 'VARCHAR'
	},  store_rejects = true
	);


--create or replace table stops as select * from read_csv_auto('/home/ts/python/duckdb/gtfs/stops.txt');
-- bei TOP ohne Level ID
CREATE or REPLACE table stops AS 
	select * from read_csv('gtfs_top/stops.txt', delim=',', header=true, dateformat = '%Y%m%d',
	columns={'stop_id': 'VARCHAR', 
	'stop_code': 'VARCHAR', 
	'stop_name': 'VARCHAR', 
	'stop_desc': 'VARCHAR', 
	'stop_lat':'DOUBLE', 
	'stop_lon':'DOUBLE',	
	'location_type' : 'enum01234',
	'parent_station' : 'VARCHAR',
	'wheelchair_boarding': 'enum012',
	'platform_code': 'VARCHAR',
	'zone_id': 'VARCHAR'
	},
	 store_rejects = true);

create or replace table transfers as select * from read_csv_auto('gtfs_top/transfers.txt');
--create or replace table trips as select * from read_csv_auto('/home/ts/python/duckdb/gtfs/trips.txt');

CREATE or REPLACE TABLE trips AS 
	select * from read_csv('gtfs_top/trips.txt', delim=',', header=true, dateformat = '%Y%m%d',
	columns={'route_id' : 'VARCHAR', 
		'service_id': 'VARCHAR', 
	'trip_id': 'VARCHAR', 
	'trip_headsign': 'VARCHAR', 
	'trip_short_name': 'VARCHAR', 
	'direction_id':'enum01', 
	'block_id':'VARCHAR',
	'shape_id': 'VARCHAR',
	'wheelchair_accessible' : 'enum012',
	'bikes_allowed' : 'enum012'},
	 store_rejects = true);

--Einlesen der VBN Grenzen
create or replace table vbn as select * from st_read('grenzen/vbn.gpkg');

--Einlesen HIS und Erstellen einer Geometry-Spalte
create or replace table his_akt as select * from "https://daten.zvbn.de/his_akt.csv";
alter table his_akt add column geom Geometry;
UPDATE his_akt set geom = st_point(x_wgs, y_wgs);

--Erstellen einer Tabelle mit Geom-Spalte
create or replace table stops_geom as select *, st_point(stop_lon, stop_lat) as geom from stops;
ALTER TABLE stops add column geom Geometry;
UPDATE stops set geom = st_point(stop_lon, stop_lat);

-- Erstellen einer Tabelle Stops im VBN
create or replace table stops_vbn as 
	select s.stop_id, s.stop_name, s.geom from stops s join vbn on st_within(s.geom, vbn.geom);

-- Verknüpfen der Stops mit den Trips und den Routen für die Routen im VBN
create or replace view vw_routes_vbn as 
	select distinct r.route_id, r.route_type, r.route_short_name, a.agency_id, a.agency_name from
	 stop_times st 
	 join stops_vbn s_vbn on s_vbn.stop_id = st.stop_id
	 join trips t on st.trip_id = t.trip_id
	 join routes r on t.route_id = r.route_id
	 join agency a on a.agency_id = r.agency_id;

-- Verknüpfen der Stops mit den Trips und den Routen für die Routen im VBN > feste Tabelle
create or replace table tbl_routes_vbn as 
	select distinct r.route_id, r.route_type, r.route_short_name, a.agency_id, a.agency_name from
	 stop_times st 
	 join stops_vbn s_vbn on s_vbn.stop_id = st.stop_id
	 join trips t on st.trip_id = t.trip_id
	 join routes r on t.route_id = r.route_id
	 join agency a on a.agency_id = r.agency_id;

-- Verknüpfung des Verlaufs mit den Haltestellennamen
create or replace view vw_trip_stop as
	SELECT a.agency_id, r.route_id, r.route_short_name, st.trip_id, t.trip_short_name, t.service_id, st.stop_sequence, st.stop_id, s.stop_name, st.arrival_time, st.departure_time  
	FROM stop_times st 
	JOIN stops s on s.stop_id = st.stop_id 
	JOIN trips t on st.trip_id = t.trip_id 
	JOIN routes r on r.route_id = t.route_id
	JOIN agency a on a.agency_id = r.agency_id;

-- Tag zur Auswahl hier nur noch als Beispiel
/* 
create or replace view vw_trip_20231122 as  
	select r.agency_id, a.agency_name, r.route_id, r.route_short_name, substring(trip_short_name, 2,3) as lin_fnr, r.route_type, 
	t.trip_id, t.trip_short_name, first_stop.departure_time, first_stop.stop_name, t.trip_headsign,
	coalesce(c.wednesday, '0') wednesday, c.start_date, c.end_date, 
	cd.date, coalesce(cd.exception_type, '0') exception_type, t.service_id, 	
	cast(coalesce(c.wednesday, '0') as INTEGER) + cast(coalesce(cd.exception_type, '0') as INTEGER) verkehrt     
	from vw_routes_vbn r 
	join agency a  on r.agency_id = a.agency_id
	join trips t on r.route_id = t.route_id
	join (select trip_id, stop_id, stop_name, departure_time from vw_trip_stop where stop_sequence = 0) first_stop on t.trip_id = first_stop.trip_id  
	left outer join calendar c on t.service_id = c.service_id
	left outer join (select * 
	from calendar_dates where date = '2023-11-22' and end_date >= '2023-11-22') cd on t.service_id = cd.service_id;
*/

--copy (select * from vw_trip_20240101 where verkehrt = 1 order by route_short_name, trip_short_name) to '/home/ts/python/duckdb/out/20240101.csv' (HEADER, DELIMITER ';');

