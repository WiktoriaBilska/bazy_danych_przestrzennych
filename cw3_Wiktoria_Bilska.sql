--ZAD4
SELECT COUNT(*) FROM (SELECT popp.* FROM popp, majrivers WHERE ST_DWithin (majrivers.geom, popp.geom, 100000) = true AND popp.f_codedesc LIKE 'Building' GROUP BY popp.gid) as budynki
CREATE TABLE tableB AS SELECT popp.* FROM popp, majrivers WHERE ST_DWithin (majrivers.geom, popp.geom, 100000) = true AND popp.f_codedesc LIKE 'Building' GROUP BY popp.gid
--ZAD5
--a)
CREATE TABLE airportsNew as SELECT elev, name, geom FROM airports;
(SELECT name,geom FROM airportsNew ORDER BY ST_X(geom) DESC LIMIT 1) UNION ALL
(SELECT name,geom FROM airportsNew ORDER BY ST_X(geom) ASC LIMIT 1);
--b)
SELECT ST_Centroid(ST_Shortestline((SELECT airportsNew.geom FROM airportsNew WHERE ST_X(airportsNew.geom) 
IN (SELECT MAX(ST_X(airports.geom)) FROM airports)),(SELECT airportsNew.geom FROM airportsNew WHERE ST_X(airportsNew.geom) 
IN (SELECT MIN(ST_X(airportsNew.geom)) FROM airportsNew)))) AS airportB FROM airportsNew LIMIT 1;
--ZAD6
SELECT ST_Area(ST_Buffer((ST_Shortestline((SELECT lakes.geom FROM lakes WHERE lakes.names='Iliamna Lake'),(SELECT airports.geom FROM airports WHERE airports.name='AMBLER'))),1000)) as area FROM  airports, lakes LIMIT 1;
--ZAD7
SELECT (SUM(tundra.area_km2)+SUM(swamp.areakm2)) area,trees.vegdesc species FROM  trees, tundra , swamp
WHERE tundra.area_km2 IN (SELECT tundra.area_km2 FROM tundra, trees WHERE ST_Contains(trees.geom,tundra.geom) = 'true') AND swamp.areakm2  IN (SELECT swamp.areakm2 FROM swamp, trees WHERE ST_Contains(trees.geom,swamp.geom) = 'true')
GROUP BY trees.vegdesc


