-- Active: 1677943579599@@127.0.0.1@5432@Kursach


--! CREATE TABLES


CREATE TABLE passengers(
	passengerId SERIAL PRIMARY KEY,
	firstName VARCHAR(30) NOT NULL,
	lastName VARCHAR(30) NOT NULL,
	middleName VARCHAR(30),
	passport VARCHAR(10) NOT NULL,
	birthDate DATE NOT NULL
);



CREATE TABLE trains(
	trainId SERIAL PRIMARY KEY,
	trainName VARCHAR(30) NOT NULL
);


CREATE TABLE tarrif(
	tarrifId SERIAL PRIMARY KEY,
	tarrifName VARCHAR(30) NOT NULL,
	tarrifAnimals BOOLEAN,
	tarrifCost INTEGER NOT NULL,
	tarrifDesc TEXT
);

--? state для вагона- возможность туда записаться
--? то есть, когда мы добавляем вагон, мы должны явно указывать, можно ли в него записаться
CREATE TABLE carriages(
	carriageId SERIAL PRIMARY KEY,
	carriageNumber VARCHAR(10) NOT NULL,
	reservedSeats INTEGER NOT NULL,
	totalSeats INTEGER NOT NULL,
	train INTEGER NOT NULL,
	carriageState BOOLEAN NOT NULL 
);

CREATE TABLE stations(
	stationId SERIAL PRIMARY KEY,
	stationName VARCHAR(30) NOT NULL,
	stationState BOOLEAN NOT NULL
);


CREATE TABLE routesShedule(
	routeId SERIAL PRIMARY KEY,
	routeNumber VARCHAR(10),
	departureStation INTEGER NOT NULL, 
	arrivalStation INTEGER NOT NULL, 
	train INTEGER NOT NULL, 
	departureTime TIMESTAMP NOT NULL,
	arrivalTime TIMESTAMP NOT NULL
);

CREATE TABLE tickets(
	ticketId SERIAL PRIMARY KEY,
	passenger INTEGER NOT NULL,
	route INTEGER NOT NULL,
	tarrif INTEGER NOT NULL,
	totalCost INTEGER NOT NULL,
	carriage INTEGER NOT NULL,
	reservationDate DATE NOT NULL
);


--! ALTER TABLES

--* CARRIAGES
ALTER TABLE carriages ADD CONSTRAINT fk_carriages_trains 
	FOREIGN KEY (train) 
	REFERENCES trains (trainId);
	
ALTER TABLE carriages ADD CONSTRAINT uq_carriageNumber
	UNIQUE (carriageNumber);

--* TICKETS
ALTER TABLE tickets ADD CONSTRAINT fk_tickets_passengers 
	FOREIGN KEY (passenger) 
	REFERENCES passengers (passengerId);
	
ALTER TABLE tickets ADD CONSTRAINT fk_tickets_tarrif 
	FOREIGN KEY (tarrif) 
	REFERENCES tarrif (tarrifId);
	
ALTER TABLE tickets ADD CONSTRAINT fk_tickets_carriages 
	FOREIGN KEY (carriage) 
	REFERENCES carriages (carriageId);
	
ALTER TABLE tickets ADD CONSTRAINT fk_tickets_routesShedule 
	FOREIGN KEY (route) 
	REFERENCES routesShedule (routeId);


ALTER TABLE tickets ADD CONSTRAINT checkPositivityTotalCost
	CHECK(totalCost >= 0);

--* TARRIF

ALTER TABLE tarrif ADD CONSTRAINT checkPositivityTarrif
	CHECK(tarrifCost >= 0);



--* ROUTE_SHEDULE
ALTER TABLE routesShedule ADD CONSTRAINT fk_routesShedule_trains 
	FOREIGN KEY (train) 
	REFERENCES trains (trainId);
	
ALTER TABLE routesShedule ADD CONSTRAINT fk_routesShedule_departure_stations 
	FOREIGN KEY (departureStation) 
	REFERENCES stations (stationId);
	
ALTER TABLE routesShedule ADD CONSTRAINT fk_routesShedule_arrival_stations 
	FOREIGN KEY (arrivalStation) 
	REFERENCES stations (stationId);

ALTER TABLE routesShedule ADD CONSTRAINT uq_routeNumber
	UNIQUE(routeNumber);



--* PASSENGERS
ALTER TABLE passengers ADD CONSTRAINT uq_passport
	UNIQUE (passport);



--* TRAINS
ALTER TABLE trains ADD CONSTRAINT uq_trainName
	UNIQUE (trainName);



--* STATIONS
ALTER TABLE stations ADD CONSTRAINT uq_stationName
    UNIQUE (stationName);






--! VIEW_mainShedule (полное расписание прибытия\отбытия поездов на станции)
CREATE VIEW mainShedule AS
	SELECT
		routesShedule.routeNumber AS FLIGHT_№,
		depStations.stationName AS DEPRATURE_STATION,
		routesShedule.departureTime AS DEPARTURE_TIME,
		arrStations.stationName AS ARRIVAL_STATION,
		routesShedule.arrivalTime AS ARRIVAL_TIME,
		trains.trainName AS TRAIN
	FROM routesShedule 
		JOIN stations AS depStations
		ON depStations.stationId = routesShedule.departureStation
		JOIN stations AS arrStations
		ON arrStations.stationId = routesShedule.arrivalStation
		JOIN trains
		ON trains.trainId = routesShedule.train;



--! многотабличный CASE.
--? рейс активный, если обе станции его активны, и поезд тоже активен.
CREATE VIEW availableRoutes AS
	SELECT
		CASE 
			WHEN TRUE = ALL(ARRAY[depStations.stationState, arrStations.stationState, (SELECT ALL(carriageState) FROM carriages WHERE train = trains.trainId LIMIT 1)])
				THEN 'Активный'
			ELSE 'Неактивный'
		END AS STATE,
		routesShedule.routeNumber AS FLIGHT_№,
		depStations.stationName AS DEPRATURE_STATION,
		routesShedule.departureTime AS DEPARTURE_TIME,
		arrStations.stationName AS ARRIVAL_STATION,
		routesShedule.arrivalTime AS ARRIVAL_TIME,
		trains.trainName AS TRAIN
	FROM routesShedule
	JOIN stations AS depStations
	ON depStations.stationId = routesShedule.departureStation
	JOIN stations AS arrStations
	ON arrStations.stationId = routesShedule.arrivalStation
	JOIN trains
	ON trains.trainId = routesShedule.train;

	

--! VIEW_mainShedule RULE UPDATE
CREATE RULE update_mainShedule AS
ON UPDATE TO mainShedule DO INSTEAD(
	SELECT mainShedule_updater(OLD, NEW));

CREATE RULE insert_mainShedule AS
ON INSERT TO mainShedule DO INSTEAD(
	SELECT mainShedule_inserter(NEW));

CREATE RULE delete_mainShedule AS
ON DELETE TO mainShedule DO INSTEAD(
	SELECT mainShedule_deleter(OLD));

--! triggers

CREATE OR REPLACE TRIGGER triggerInsert_tickets
	AFTER INSERT ON tickets
	FOR EACH ROW
	EXECUTE FUNCTION checkTicketsInsert();

CREATE OR REPLACE TRIGGER triggerUpdate_tickets
	AFTER UPDATE ON tickets
	FOR EACH ROW
	EXECUTE FUNCTION checkTicketsUpdate();

CREATE OR REPLACE TRIGGER triggerDelete_tickets
	AFTER DELETE ON tickets
	FOR EACH ROW
	EXECUTE FUNCTION checkTicketsDelete();


--! индексы 




CREATE INDEX idx_stations ON stations USING hash(stationName);
CREATE INDEX idx_reservedTime ON tickets USING brin(reservationDate);
CREATE INDEX idx_routesShedule ON routesShedule USING btree(routeId);






--! USERS CREATION

CREATE USER someone WITH PASSWORD 'someone';


CREATE ROLE user_group;
GRANT SELECT ON TABLE passengers, tickets, tarrif, trains, carriages, routesShedule, stations TO user_group;
GRANT SELECT ON mainShedule, availableRoutes TO user_group;
GRANT UPDATE, INSERT ON TABLE passengers, tickets TO user_group;
GRANT UPDATE(reservedSeats, carriageState) ON TABLE carriages TO user_group;
REVOKE UPDATE(totalCost) ON TABLE tickets FROM user_group;
REVOKE DELETE ON TABLE passengers, tickets, tarrif, trains, carriages, routesShedule, stations FROM user_group;
REVOKE UPDATE, INSERT ON TABLE tarrif, trains, routesShedule, stations FROM user_group;
GRANT USAGE, SELECT ON SEQUENCE passengers_passengerid_seq, tickets_ticketid_seq TO user_group;
GRANT user_group TO someone;


CREATE USER admin WITH PASSWORD 'admin';
CREATE ROLE admin_group;
GRANT postgres TO admin_group;
GRANT admin_group TO admin;



--! DROP TABLES

DROP TABLE carriages CASCADE;
DROP TABLE routesShedule CASCADE;
DROP TABLE tickets CASCADE;
DROP TABLE passengers;
DROP TABLE trains;
DROP TABLE tarrif CASCADE;
DROP TABLE stations;




DROP VIEW mainShedule CASCADE;

DROP VIEW availableRoutes CASCADE;

--! DROP FUNCTIONS

DO $$
DECLARE
  func_name text;
BEGIN
  FOR func_name IN (SELECT proname FROM pg_proc WHERE pronamespace = 'public'::regnamespace) LOOP
    EXECUTE 'DROP FUNCTION IF EXISTS ' || func_name || ' CASCADE;';
  END LOOP;
END $$;














