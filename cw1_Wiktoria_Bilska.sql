CREATE ROLE ksiegowosc;
GRANT SELECT ON ALL TABLES IN SCHEMA firma TO ksiegowosc;
CREATE TABLE pracownicy(
	id_pracownika serial NOT NULL primary key,
	imie varchar(30) NOT NULL,
	nazwisko varchar(30) NOT NULL,
	adres VARCHAR(50),
	telefon varchar(9)
);

CREATE TABLE godziny(
	id_godziny serial NOT NULL primary key,
	data DATE,
	liczba_godzin int,
	id_pracownika serial NOT NULL,
	FOREIGN KEY(id_pracownika) references pracownicy(id_pracownika)
);

CREATE TABLE pensja_stanowisko(
	id_pensji serial NOT NULL primary key,
	stanowisko VARCHAR(20), 
	kwota int,
	id_premii serial unique NOT NULL
);

CREATE TABLE premia(
	id_premii serial NOT NULL primary key,
	rodzaj varchar(20),
	kwota INT
);

CREATE TABLE wynagrodzenie(
	id_wynagrodzenia varchar(5) unique NOT NULL PRIMARY KEY,
	Data DATE,
	id_pracownika serial NOT NULL,
	id_godziny serial,
	id_pensji serial,
	id_premii serial,
 	FOREIGN KEY(id_pracownika) REFERENCES pracownicy(id_pracownika),
	FOREIGN KEY(id_godziny) REFERENCES godziny(id_godziny),
	FOREIGN KEY(id_pensji) REFERENCES pensja_stanowisko(id_pensji),
	FOREIGN KEY(id_premii) REFERENCES premia(id_premii)	
);

ALTER TABLE premia
ADD FOREIGN KEY (id_premii) REFERENCES pensja_stanowisko(id_premii);

ALTER TABLE pensja_stanowisko
ADD FOREIGN KEY (id_pensji) REFERENCES pracownicy(id_pracownika);

INSERT INTO pracownicy (imie,nazwisko,adres,telefon) VALUES
('Wiktoria','Bilska','Gorlice','556675876'),
('Dariusz','Mag','Kraków','653216789'),
('Dobrawa','Dobra','Gdańsk','645764888'),
('Filip','Słup','Gdynia','545345876'),
('Czesław','Marek','Zakopane','223432234'),
('Konrad','Konrad','Kraków','512232322'),
('Jan','Kowalski','Warszawa','656767654'),
('Sara','Sarna','Nowy Targ','654656458'),
('Mateusz','Cep','Tarnów','511831421'),
('Hubert','Gupi','Gdynia','666778787');

INSERT INTO godziny(data,liczba_godzin) values 
('2020-05-11',23),
('2020-05-05',121),
('2020-05-04',168),
('2020-05-10',100),
('2020-05-05',89),
('2020-05-06',55),
('2020-05-11',61),
('2020-05-07',92),
('2020-05-14',172),
('2020-05-09',115);

ALTER TABLE godziny ADD miesiac DATE;

ALTER TABLE wynagrodzenie ALTER COLUMN data TYPE varchar;

INSERT INTO pensja_stanowisko(stanowisko, kwota) values
('kierownik', 100000),
('sprzątaczka',5000),
('sekretarka',6200),
('księgowy',1000),
('zastępca kierownika',25000),
('konserwator',3000),
('technik',5200),
('bufet',4100),
('tester jakości',7000),
('PR',4000);

INSERT INTO premia(rodzaj,kwota) values
('roczna',500),
('świąteczna',220),
('uznaniowa',150),
('motywacyjna',350),
('motywacyjna',150),
('za zasługi',250),
('kwartalna',225),
('zapomoga',125),
('okolicznościowa',450),
('motywacyjna',520);

SELECT id_pracownika, nazwisko FROM pracownicy;
SELECT fw.id_pracownika, fp.kwota, fprem.kwota FROM wynagrodzenie AS fw, pensja_stanowisko AS fp, premia AS fprem
WHERE fw.id_pensji = fp.id_pensji AND fw.id_premii = fprem.id_premii AND fprem.kwota + fprem.kwota > 1000;
	
SELECT fw.id_pracownika FROM wynagrodzenie AS fw, pensja_stanowisko AS fpen
	WHERE fw.id_pensji=fpen.id_pensji AND fw.id_premii IS NULL and fpen.kwota > 1000;

SELECT * FROM pracownicy AS fpr WHERE fpr.imie like '%J';

SELECT fpr.imie, fpr.nazwisko FROM pracownicy AS fpr WHERE fpr.nazwisko LIKE '%n%' AND fpr.imie like '%a';

SELECT fpr.imie, fpr.nazwisko FROM pracownicy AS fpr, godziny AS fgodz
	WHERE fpr.id_pracownika = fgodz.id_pracownika AND fgodz.liczba_godzin > 160;

SELECT fpr.imie, fpr.nazwisko FROM pracownicy AS fpr, wynagrodzenie AS fw, pensja_stanowisko AS fpen
	WHERE fpr.id_pracownika = fw.id_pracownika AND fw.id_pensji = fpen.id_pensji AND fpen.kwota > 1500 AND fpen.kwota <3000;

SELECT fpr.imie, fpr.nazwisko FROM pracownicy AS fpr, godziny AS fgodz, wynagrodzenie AS fw
	WHERE fpr.id_pracownika = fw.id_pracownika AND fw.id_godziny = fgodz.id_godziny AND fgodz.liczba_godzin > 160 AND fw.id_premii IS NULL;

SELECT COUNT(*), fpen.stanowisko FROM pensja_stanowisko AS fpen
	GROUP BY fpen.stanowisko ORDER BY fpen.stanowisko DESC;
SELECT MIN(fpen.kwota), MAX(fpen.kwota) FROM pensja_stanowisko fpen 
	WHERE fpen.stanowisko = 'kierownik';

SELECT SUM(COALESCE(fpr.kwota,0))+ SUM(COALESCE(fpen.kwota,0)) AS wynagrodznie FROM wynagrodzenie AS fw 
	LEFT JOIN pensja_stanowisko fpen ON fw.id_pensji = fpen.id_pensji
	LEFT JOIN premia fpr ON fw.id_premii = fpr.id_premii ;
	
SELECT SUM(COALESCE(fpr.kwota,0))+ SUM(COALESCE(fpen.kwota,0)) AS wynagrodznie FROM wynagrodzenie AS fw
	LEFT JOIN pensja_stanowisko AS fpen ON fw.id_pensji = fpen.id_pensji
	LEFT JOIN premia fpr ON fw.id_premii = fpr.id_premii GROUP BY fpen.stanowisko;
	
SELECT COUNT(fw.id_premii) FROM wynagrodzenie AS fw
	LEFT JOIN pensja_stanowisko AS fpen ON fw.id_pensji=fpen.id_pensji GROUP BY fpen.stanowisko;
	
DELETE
FROM  wynagrodzenie AS fw    
USING pensja_stanowisko AS fpen 
WHERE fpen.kwota < 1200 AND fw.id_pensji = fpen.id_pensji;

ALTER TABLE pracownicy  ALTER COLUMN telefon TYPE varchar(17) USING telefon::varchar;
UPDATE pracownicy AS fp SET telefon = '(+48)'||fp.telefon;

UPDATE pracownicy AS fp SET telefon=SUBSTRING(fp.telefon,1,9)||'-'||SUBSTRING(fp.telefon,10,3)||'-'||SUBSTRING(fp.telefon,13,3);

SELECT UPPER(fp.imie), UPPER(fp.nazwisko), UPPER(fp.adres), UPPER(fp.telefon), LENGTH(fp.nazwisko) 
		FROM pracownicy AS fp 
			ORDER BY length(fp.nazwisko) DESC LIMIT 1;
			
SELECT fp.*,fpen.kwota AS kwota FROM pracownicy fp
	   JOIN wynagrodzenie fw ON fw.id_pracownika = fp.id_pracownika 
       JOIN pensja_stanowisko fpen ON fpen.id_pensji = fw.id_pensji;
	   
SELECT 'Pracownik ' || fp.imie || ' ' || fp.nazwisko 
|| ' w dniu ' || fg.data
|| ' otrzymał pensje całkowitą na kwotę ' || fpen.kwota + fpr.kwota 
|| ' gdzie wynagrodzenie zasadnicze wynosiło: '|| fpen.kwota || ',a premia: ' || fpr.kwota || ', nadgodziny: ' || '0 zł' AS raport
FROM pracownicy AS fp
JOIN wynagrodzenie AS fw ON fw.id_pracownika = fp.id_pracownika 
JOIN pensja_stanowisko AS fpen ON fpen.id_pensji = fw.id_pensji 
JOIN premia AS fpr ON fpr.id_premii =fw.id_premii 
JOIN godziny AS fg ON fp.id_pracownika = fp.id_pracownika