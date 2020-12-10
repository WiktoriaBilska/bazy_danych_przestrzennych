--W CMD:
-- cd desktop
-- cd 5semestr
-- cd BD_przestrzennych
-- cd cw5

-- raster2pgsql -s 3763 -N -32767 -t 100x100 -I -C -M -d C:\Users\Wiktoria\Desktop\5semestr\BD_przestrzennych\cw5\rasters\srtm_1arc_v3.tif rasters.dem > C:\Users\Wiktoria\Desktop\5semestr\BD_przestrzennych\cw5\rasters\dem.sql

create extension postgis_raster cascade;

-- raster2pgsql -s 3763 -N -32767 -t 100x100 -I -C -M -d C:\Users\Wiktoria\Desktop\5semestr\BD_przestrzennych\cw5\rasters\srtm_1arc_v3.tif rasters.dem | psql -d cw5_wb -h localhost -U postgres -p 5432

-- raster2pgsql -s 3763 -N -32767 -t 128x128 -I -C -M -d C:\Users\Wiktoria\Desktop\5semestr\BD_przestrzennych\cw5\rasters\Landsat8_L1TP_RGBN.TIF rasters.landsat8 | psql -d cw5_wb -h localhost -U postgres -p 5432

--PRZYKŁAD1
CREATE TABLE bilska.intersects AS 
SELECT a.rast, b.municipality 
FROM rasters.dem AS a, vectors.porto_parishes AS b 
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

alter table bilska.intersects
add column rid SERIAL PRIMARY KEY;

CREATE INDEX idx_intersects_rast_gist ON bilska.intersects USING gist (ST_ConvexHull(rast));
SELECT AddRasterConstraints('bilska'::name, 'intersects'::name,'rast'::name);

--PRZYKŁAD 2
CREATE TABLE bilska.clip AS 
SELECT ST_Clip(a.rast, b.geom, true), b.municipality 
FROM rasters.dem AS a, vectors.porto_parishes AS b 
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';

--PRZYKŁAD 3
CREATE TABLE bilska.union AS 
SELECT ST_Union(ST_Clip(a.rast, b.geom, true))
FROM rasters.dem AS a, vectors.porto_parishes AS b 
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);

--PRZYKŁAD 4
CREATE TABLE bilska.porto_parishes AS
WITH r AS (
	SELECT rast FROM rasters.dem 
	LIMIT 1)
	SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
	FROM vectors.porto_parishes AS a, r
	WHERE a.municipality ilike 'porto';
	
--PRZYKŁAD 5
DROP TABLE bilska.porto_parishes; 
CREATE TABLE bilska.porto_parishes AS
WITH r AS (
	SELECT rast FROM rasters.dem 
	LIMIT 1)
	SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
	FROM vectors.porto_parishes AS a, r
	WHERE a.municipality ilike 'porto';
	
--PRZYKŁAD 6
DROP TABLE bilska.porto_parishes;
CREATE TABLE bilska.porto_parishes AS
WITH r AS (
	SELECT rast FROM rasters.dem
	LIMIT 1)
	SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)),128,128,true,-32767) AS rast
	FROM vectors.porto_parishes AS a, r
	WHERE a.municipality ilike 'porto';
	
--PRZYKŁAD 7
create table bilska.intersection as
SELECT
a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b 
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--PRZYKŁAD 8
CREATE TABLE bilska.dumppolygons AS
SELECT
a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b 
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--PRZYKŁAD 9
CREATE TABLE bilska.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;

--PRZYKŁAD 10
CREATE TABLE bilska.paranhos_dem AS
SELECT 
a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--PRZYKŁAD 11
CREATE TABLE bilska.paranhos_slope AS
SELECT
a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM bilska.paranhos_dem AS a;

--PRZYKŁAD 12
CREATE TABLE bilska.paranhos_slope_reclass AS
SELECT 
a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3', '32BF',0)
FROM bilska.paranhos_slope AS a;

--PRZYKŁAD 13
SELECT st_summarystats(a.rast) AS stats 
FROM bilska.paranhos_dem AS a;

--PRZYKŁAD 14
SELECT st_summarystats(ST_Union(a.rast))
FROM bilska.paranhos_dem AS a;

--PRZYKŁAD 15
WITH t AS (
	SELECT st_summarystats(ST_Union(a.rast)) AS stats
	FROM BILSKA.paranhos_dem AS a)
	SELECT (stats).min,(stats).max,(stats).mean FROM t;
	
--PRZYKŁAD 16
WITH t AS (
	SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast, b.geom,true))) AS stats
	FROM rasters.dem AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
	group by b.parish)
	SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;
	
--PRZYKŁAD 17
SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;

--PRZYKŁAD 18
create table bilska.tpi30 as
select ST_TPI(a.rast,1) as rast
from rasters.dem a;

--PRZYKŁAD 19
CREATE INDEX idx_tpi30_rast_gist ON bilska.tpi30 USING gist (ST_ConvexHull(rast));

--PRZYKŁAD 20
SELECT AddRasterConstraints('bilska'::name, 'tpi30'::name,'rast'::name);

--PRZYKŁAD 21 (SAMODZIELNE)
CREATE TABLE bilska.tpi30_porto as
SELECT ST_TPI(a.rast,1) as rast
FROM rasters.dem a, vectors.porto_parishes AS b 
WHERE  ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

CREATE INDEX idx_tpi30_porto_rast_gist ON bilska.tpi30_porto
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('bilska'::name, 'tpi30_porto'::name,'rast'::name);

--PRZYKŁAD 22
CREATE TABLE bilska.porto_ndvi AS 
WITH r AS (
	SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
	FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto'and ST_Intersects(b.geom,a.rast))
	SELECT r.rid,ST_MapAlgebra(r.rast, 1,r.rast, 4,'([rast2.val] -[rast1.val]) / ([rast2.val] + [rast1.val])::float','32BF') AS rast FROM r;

--PRZYKŁAD 23
CREATE INDEX idx_porto_ndvi_rast_gist ON bilska.porto_ndvi USING gist (ST_ConvexHull(rast));

--PRZYKŁAD 24
SELECT AddRasterConstraints('bilska'::name, 'porto_ndvi'::name,'rast'::name);

--PRZYKŁAD 25
create or replace function bilska.ndvi(
	value double precision [] [] [],
	pos integer [][],
	VARIADIC userargs text [])
	RETURNS double precision AS
	$$
	BEGIN
	RETURN (value [2][1][1] -value [1][1][1])/(value [2][1][1]+value [1][1][1]); 
	END;
	$$
	LANGUAGE 'plpgsql' IMMUTABLE COST 1000;
	
--PRZYKŁAD 26
CREATE TABLE bilska.porto_ndvi2 AS
WITH r AS (
	SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
	FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast))
	SELECT r.rid,ST_MapAlgebra(r.rast, ARRAY[1,4],'bilska.ndvi(double precision[], integer[],text[])'::regprocedure, 
	'32BF'::text) AS rast FROM r;
	
--PRZYKŁAD 27
CREATE INDEX idx_porto_ndvi2_rast_gist ON bilska.porto_ndvi2 USING gist (ST_ConvexHull(rast));

--PRZYKŁAD 28
SELECT AddRasterConstraints('bilska'::name, 'porto_ndvi2'::name,'rast'::name);

--PRZYKŁAD 29
SELECT ST_AsTiff(ST_Union(rast))FROM bilska.porto_ndvi;

--PRZYKŁAD 30
SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff',  ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
FROM bilska.porto_ndvi;
SELECT ST_GDALDrivers();

--PRZYKŁAD 31
CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,ST_AsGDALRaster(ST_Union(rast), 'GTiff',  ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])) AS loid
FROM bilska.porto_ndvi;
----------------------------------------------
SELECT lo_export(loid, 'C:\Users\Wiktoria\Desktop\5semestr\BD_przestrzennych\cw5\myraster.tif') 
FROM tmp_out;
----------------------------------------------
SELECT lo_unlink(loid)
FROM tmp_out; 

--PRZYKŁAD 32
gdal_translate -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 PG:"host=localhost port=5432 dbname=cw5_wb user=postgres password=postgis schema=bilska table=porto_ndvi mode=2" porto_ndvi.tiff

--PRZYKŁAD 33
MAP
	NAME 'map'
	SIZE 800 650
	STATUS ON
	EXTENT -58968 145487 30916 206234
	UNITS METERS

	WEB
		METADATA
				'wms_title' 
				'Terrain wms'
				'wms_srs' 
				'EPSG:3763 EPSG:4326 EPSG:3857'
				'wms_enable_request' '*'
				'wms_onlineresource' 
		'http://54.37.13.53/mapservices/srtm'
		END
	END
	PROJECTION
	'init=epsg:3763'
	END
	LAYER
		NAME srtm
		TYPE raster
		STATUS OFF
		DATA "PG:host=localhost port=5432 dbname='cw5_wb' user='postgres' password='postgis' schema='rasters' table='dem' mode='2'"
		PROCESSING "SCALE=AUTO"
		PROCESSING "NODATA=-32767"
		OFFSITE 0 0 0
		METADATA'wms_title' 'srtm'
		END
	END
END