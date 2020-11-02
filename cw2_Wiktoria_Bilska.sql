CREATE EXTENSION postgis;

CREATE TABLE budynki (id INTEGER, the_geom GEOMETRY, nazwa VARCHAR(100));
CREATE TABLE drogi (id INTEGER, the_geom GEOMETRY, nazwa VARCHAR(100));
CREATE TABLE punkty_informacyjne (id INTEGER, the_geom GEOMETRY, nazwa VARCHAR(100));

INSERT INTO  budynki VALUES (1, ST_GeomFromText('POLYGON((1 1, 1 2, 2 2, 2 1, 1 1))',0), 'BuildingF');
INSERT INTO  budynki VALUES (2, ST_GeomFromText('POLYGON((8 1.5, 8 4, 10.5 4, 10.5 1.5, 8 1.5))',0), 'BuildingA');
INSERT INTO  budynki VALUES (3, ST_GeomFromText('POLYGON((9 8, 9 9, 10 9, 10 8, 9 8))',0), 'BuildingD');
INSERT INTO  budynki VALUES (4, ST_GeomFromText('POLYGON((3 6, 3 8, 5 8, 5 6, 3 6))',0), 'BuildingC');
INSERT INTO  budynki VALUES (5, ST_GeomFromText('POLYGON((4 5, 4 7, 6 7, 6 5, 4 5))',0), 'BuildingB');

INSERT INTO drogi VALUES (1, ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)',0), 'RoadX');
INSERT INTO drogi VALUES (2, ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)',0), 'RoadY');

INSERT INTO punkty_informacyjne VALUES (1, ST_GeomFromText('POINT(9.5 6)',0), 'I');
INSERT INTO punkty_informacyjne VALUES (2, ST_GeomFromText('POINT(6.5 6)',0), 'J');
INSERT INTO punkty_informacyjne VALUES (3, ST_GeomFromText('POINT(6 9.5)',0), 'K');
INSERT INTO punkty_informacyjne VALUES (4, ST_GeomFromText('POINT(1 3.5)',0), 'G');
INSERT INTO punkty_informacyjne VALUES (5, ST_GeomFromText('POINT(5.5 1.5)',0), 'H');

--ZAD6 
--a)
SELECT SUM(ST_Length(the_geom)) FROM drogi
--b)
SELECT the_geom, ST_Area(the_geom), ST_Perimeter(the_geom) from budynki WHERE nazwa LIKE 'BuildingA'
--c)
SELECT nazwa, ST_Area(the_geom) from budynki ORDER BY nazwa ASC
--d)
SELECT nazwa, ST_Perimeter(the_geom) from budynki ORDER BY ST_Area(the_geom) DESC LIMIT 2
--e)
SELECT ST_Distance(budynki.the_geom, punkty_informacyjne.the_geom) FROM budynki, punkty_informacyjne WHERE budynki.nazwa LIKE 'BuildingC' AND  punkty_informacyjne.nazwa LIKE 'G'
--f)
SELECT ST_Area(ST_Difference(budynki.the_geom,(SELECT ST_Buffer(the_geom,0.5) FROM budynki WHERE nazwa LIKE 'BuildingB')) )
FROM budynki WHERE nazwa LIKE 'BuildingC'
--g)
SELECT nazwa, ST_AsText(ST_Centroid(the_geom)) FROM budynki WHERE ST_Y(ST_Centroid(the_geom)) > (SELECT ST_Y(ST_Centroid(the_geom)) FROM drogi WHERE nazwa LIKE 'RoadX')

--ZAD8
SELECT ST_Area(ST_SymDifference(the_geom,ST_GeomFromText('POLYGON((4 7,6 7,6 8,4 8,4 7))',0))) FROM budynki WHERE nazwa='BuildingC'