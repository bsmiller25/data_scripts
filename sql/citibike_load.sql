-- update geometries for the stations table
SELECT AddGeometryColumn ('citibike_stations','geom',4326,'POINT',2);
UPDATE citibike_stations SET geom = ST_SetSRID(ST_MakePoint(lon, lat), 4326);

