-- update geometries for the stations table
SELECT AddGeometryColumn ('citibike_stations','geom',4326,'POINT',2);
UPDATE citibike_stations SET geom = ST_SetSRID(ST_MakePoint(lon, lat), 4326);

-- update permissions on the tables
GRANT All ON citibike_trips, citibike_stations TO qc_capstone_2017_admin;
