CREATE TABLE obiekty (gid INT NOT NULL UNIQUE,name CHAR(10),geom GEOMETRY);

INSERT INTO obiekty VALUES(1,'obiekt1',ST_GeomFromText('COMPOUNDCURVE(LINESTRING(0 1,1 1),CIRCULARSTRING(1 1,2 0,3 1), CIRCULARSTRING(3 1,4 2,5 1), LINESTRING(5 1,6 1))',0));
INSERT INTO obiekty VALUES(2,'obiekt2',ST_GeomFromText('MULTICURVE(CIRCULARSTRING(11 2,13 2,11 2),COMPOUNDCURVE(LINESTRING(10 6,14 6),CIRCULARSTRING(14 6,16 4,14 2),CIRCULARSTRING(14 2,12 0, 10 2), LINESTRING(10 2,10 6)))',0));
INSERT INTO obiekty VALUES(3,'obiekt3',ST_GeomFromText('POLYGON((7 15,10 17,12 13,7 15))',0));
INSERT INTO obiekty VALUES(4,'obiekt4',ST_GeomFromText('LINESTRING(20 20,25 25,27 24,25 22,26 21,22 19,20.5 19.5)',0));
INSERT INTO obiekty VALUES(5,'obiekt5',ST_GeomFromText('MULTIPOINT(30 30 59,38 32 234)',0));
INSERT INTO obiekty VALUES(6,'obiekt6',ST_GeomFromText('GEOMETRYCOLLECTION(LINESTRING(1 1, 3 2), POINT(4 2))',0));

--ZAD1
SELECT DISTINCT ST_AREA(ST_BUFFER(ST_SHORTESTLINE((SELECT geom FROM obiekty WHERE gid=3),(SELECT geom FROM obiekty WHERE gid=4)),5))
FROM obiekty

--ZAD2
UPDATE obiekty SET geom = (SELECT ST_MakePolygon( ST_AddPoint(buf.geom, ST_StartPoint(buf.geom))) FROM (SELECT geom  FROM obiekty WHERE  gid = '4' ) As buf) WHERE gid = '4';
SELECT * FROM obiekty WHERE gid = '4';

--ZAD3
INSERT INTO obiekty VALUES (7,'obiekt7',(SELECT ST_Collect((SELECT geom FROM obiekty WHERE gid = '3'),(SELECT geom FROM obiekty WHERE gid = '4'))));
SELECT * FROM obiekty WHERE gid = '7';

--ZAD4 
SELECT SUM(ST_Area(ST_Buffer(geom,5))) FROM obiekty WHERE ST_HasArc(geom) = false;