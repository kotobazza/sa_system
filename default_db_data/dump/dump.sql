--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE admin_group;
ALTER ROLE admin_group WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:jIjiCVREtQSJStq8Kf7+/g==$IHGPLpXbOEsJnvDMkblOuixA9qTthDeMJ15xJLepL/Y=:CZes1bOJsSXiEjSgn2SwZgljmL8L5Ko78db5UZQKH+A=';
CREATE ROLE user_group;
ALTER ROLE user_group WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;

--
-- User Configurations
--








--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0 (Debian 17.0-1.pgdg120+1)
-- Dumped by pg_dump version 17.0 (Debian 17.0-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

--
-- Database "kursach2" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0 (Debian 17.0-1.pgdg120+1)
-- Dumped by pg_dump version 17.0 (Debian 17.0-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: kursach2; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE kursach2 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE kursach2 OWNER TO postgres;

\connect kursach2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: addcarriage(character varying, integer, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addcarriage(_trainname character varying, _totalseats integer, _reservedseats integer, _carriagestate boolean, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
		_trainId INTEGER;
	BEGIN
		SELECT trainId INTO _trainId FROM trains WHERE trains.trainName = _trainName;

		IF (_reservedSeats >= _totalSeats) THEN _carriageState := FALSE; END IF;
		
		INSERT INTO carriages(reservedSeats, totalSeats, train, carriageState, carriageNumber)
			VALUES (_reservedSeats, _totalSeats, _trainId, _carriageState, '')
			RETURNING carriageId INTO result;
		UPDATE carriages SET carriageNumber = carriageNumberDeterminant(result) WHERE carriageId = result;             
	END;
	$$;


ALTER FUNCTION public.addcarriage(_trainname character varying, _totalseats integer, _reservedseats integer, _carriagestate boolean, OUT result integer) OWNER TO postgres;

--
-- Name: addpassenger(character varying, date, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addpassenger(_passport character varying, _birthdate date, _firstname character varying, _lastname character varying, _middlename character varying DEFAULT NULL::character varying, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$ 	
	BEGIN
		INSERT INTO passengers(firstName, lastName, middleName, passport, birthDate)
				VALUES (_firstName, _lastName, _middleName, _passport, _birthDate)
				RETURNING passengerId INTO result;			
	END;
	$$;


ALTER FUNCTION public.addpassenger(_passport character varying, _birthdate date, _firstname character varying, _lastname character varying, _middlename character varying, OUT result integer) OWNER TO postgres;

--
-- Name: addroute(character varying, character varying, timestamp without time zone, character varying, timestamp without time zone, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addroute(_routenumber character varying, _departurestation character varying, _departuretime timestamp without time zone, _arrivalstation character varying, _arrivaltime timestamp without time zone, _trainname character varying, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
		_trainId INTEGER;
		_departureStationId INTEGER;
		_arrivalStationId INTEGER;
	BEGIN
		SELECT trainId INTO _trainId FROM trains WHERE trains.trainName = _trainName;
		SELECT stations.stationId INTO _departureStationId FROM stations WHERE stations.stationName = _departureStation;
		SELECT stations.stationId INTO _arrivalStationId FROM stations WHERE stations.stationName = _arrivalStation;
		
		IF _departureTime > _arrivalTime THEN
			result := -1;
		ELSE
			INSERT INTO routesShedule(routeNumber, departureStation, arrivalStation, train, departureTime, arrivalTime)
				VALUES(_routeNumber, _departureStationId, _arrivalStationId, _trainId, _departureTime, _arrivaltime)
				RETURNING routeId INTO result;
		END IF;
	END;
	$$;


ALTER FUNCTION public.addroute(_routenumber character varying, _departurestation character varying, _departuretime timestamp without time zone, _arrivalstation character varying, _arrivaltime timestamp without time zone, _trainname character varying, OUT result integer) OWNER TO postgres;

--
-- Name: addstation(character varying, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addstation(_stationname character varying, _stationstate boolean, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN 
		INSERT INTO stations(stationName, stationState)
			VALUES (_stationName, _stationState)
			RETURNING stationId INTO result;
	END;
	$$;


ALTER FUNCTION public.addstation(_stationname character varying, _stationstate boolean, OUT result integer) OWNER TO postgres;

--
-- Name: addtarrif(character varying, boolean, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addtarrif(_tarrifname character varying, _animals boolean, _tarrifcost integer, _tarrifdesc text DEFAULT NULL::text, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN 
		INSERT INTO tarrif(tarrifName, tarrifCost, tarrifDesc, tarrifAnimals)
			VALUES (_tarrifName, _tarrifCost, _tarrifDesc, _animals)
			RETURNING tarrifId INTO result;
	END;
	$$;


ALTER FUNCTION public.addtarrif(_tarrifname character varying, _animals boolean, _tarrifcost integer, _tarrifdesc text, OUT result integer) OWNER TO postgres;

--
-- Name: addticket(character varying, character varying, character varying, character varying, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addticket(_passport character varying, _routenumber character varying, _tarrifname character varying, _carriagenumber character varying, _reservationdate date, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
		_passengerId INTEGER; 
		_routeId INTEGER; 
		_carriageId INTEGER;
		_tarrifId INTEGER;
		_isReserveable BOOLEAN;
		_arrivalTime TIMESTAMP;
		_trainId INTEGER;
		_birthDate DATE;
		_totalCost INTEGER;
		_carriageState BOOLEAN;
		_trainFromCarriageId INTEGER;
	BEGIN
		SELECT passengerId INTO _passengerId FROM passengers WHERE passport = _passport;
		SELECT birthDate INTO _birthDate FROM passengers WHERE passengerId = _passengerId;

		SELECT routeId INTO _routeId FROM routesShedule WHERE routeNumber = _routeNumber;
		SELECT tarrifId INTO _tarrifId FROM tarrif WHERE tarrifName = _tarrifName;

		SELECT train INTO _trainId FROM routesShedule WHERE routeId = _routeId; 
		SELECT arrivalTime INTO _arrivalTime FROM routesShedule WHERE routeId = _routeId; 
		
		SELECT carriageId INTO _carriageId FROM carriages WHERE carriageNumber = _carriageNumber;
		SELECT carriageState INTO _carriageState FROM carriages WHERE carriageNumber = _carriageNumber;
		SELECT train INTO _trainFromCarriageId FROM carriages WHERE carriageId = _carriageId;

		IF _carriageId IS NULL OR NOT _carriageState OR _trainId != _trainFromCarriageId THEN
			result := -1;
			RETURN;
		END IF;

		--? _arrivalTime - время прибытия. На поезд можно сесть и после его отправления, 
		--? 					но не после его прибытия на станцию назначения
		IF _reservationDate >= _arrivalTime THEN
			result := -1;
			RETURN;
		END IF;

		SELECT * INTO _totalCost FROM birthdayDateAndCost(_reservationDate, _birthDate, _tarrifId);

		INSERT INTO tickets(passenger, route, tarrif, carriage, reservationDate, totalCost)
			VALUES(_passengerId, _routeId, _tarrifId, _carriageId, _reservationDate, _totalCost)
			RETURNING ticketId INTO result;
	END;
	$$;


ALTER FUNCTION public.addticket(_passport character varying, _routenumber character varying, _tarrifname character varying, _carriagenumber character varying, _reservationdate date, OUT result integer) OWNER TO postgres;

--
-- Name: addtomainshedule(character varying, character varying, timestamp without time zone, character varying, timestamp without time zone, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addtomainshedule(routenumber character varying, depstation character varying, deptime timestamp without time zone, arrstation character varying, arrtime timestamp without time zone, trainname character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO mainShedule(FLIGHT_№, DEPRATURE_STATION, DEPARTURE_TIME, ARRIVAL_STATION, ARRIVAL_TIME, TRAIN) VALUES(
			FLIGHT_№ = routeNumber,
			DEPRATURE_STATION = depStation,
			DEPARTURE_TIME = depTime,
			ARRIVAL_STATION = arrStation,
			ARRIVAL_TIME = arrTime,
			TRAIN = trainName);
	END;
	$$;


ALTER FUNCTION public.addtomainshedule(routenumber character varying, depstation character varying, deptime timestamp without time zone, arrstation character varying, arrtime timestamp without time zone, trainname character varying) OWNER TO postgres;

--
-- Name: addtrain(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addtrain(_trainname character varying, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN 
		INSERT INTO trains(trainName)
			VALUES (_trainName)
			RETURNING trainId INTO result;
	END;
	$$;


ALTER FUNCTION public.addtrain(_trainname character varying, OUT result integer) OWNER TO postgres;

--
-- Name: averagetarrifcost(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.averagetarrifcost() RETURNS TABLE(tarrifname character varying, tarrifcost integer, avgcost integer)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY 
			SELECT 
				tarrifName,
				tarrifCost,
				(SELECT AVG(tarrifCost) FROM tarrif) AS avgCost
			FROM tarrif;
	END;
	$$;


ALTER FUNCTION public.averagetarrifcost() OWNER TO postgres;

--
-- Name: birthdaydateandcost(date, date, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.birthdaydateandcost(reservdate date, birthdate date, _tarrif integer, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
		DECLARE
			_tarrifCost INTEGER;
			brthInterval INTEGER DEFAULT 5;
			salePercent FLOAT DEFAULT 10;
			_yearDiff INTEGER;
		BEGIN
			SELECT tarrifCost INTO _tarrifCost FROM tarrif WHERE tarrifId = _tarrif;
			_yearDiff = DATE_PART('year', reservDate) - DATE_PART('year', birthDate);
			
			birthDate = birthDate + make_interval(years => _yearDiff);
			
			IF reservDate BETWEEN birthDate + make_interval(days => brthInterval) AND birthDate - make_interval(days => brthInterval) THEN
				result := _tarrifCost / salePercent;
			ELSE
				result := _tarrifCost;
			END IF;
		END;
	$$;


ALTER FUNCTION public.birthdaydateandcost(reservdate date, birthdate date, _tarrif integer, OUT result integer) OWNER TO postgres;

--
-- Name: carriagenumberdeterminant(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.carriagenumberdeterminant(carriageid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN CONCAT('CARR', carriageId);
	END;
	$$;


ALTER FUNCTION public.carriagenumberdeterminant(carriageid integer) OWNER TO postgres;

--
-- Name: checkticketsdelete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.checkticketsdelete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

		BEGIN
			UPDATE carriages SET
					reservedSeats = reservedSeats - 1,
					carriageState = (totalSeats > reservedSeats) AND carriageState
				WHERE carriageId = OLD.carriage;
			RETURN OLD;
		END;
	$$;


ALTER FUNCTION public.checkticketsdelete() OWNER TO postgres;

--
-- Name: checkticketsinsert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.checkticketsinsert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
		BEGIN
			UPDATE carriages SET
					reservedSeats = reservedSeats + 1,
					carriageState = (totalSeats > reservedSeats) AND carriageState
				WHERE carriageId = NEW.carriage;
			RETURN NEW;
		END;
	$$;


ALTER FUNCTION public.checkticketsinsert() OWNER TO postgres;

--
-- Name: checkticketsupdate(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.checkticketsupdate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
		BEGIN
			UPDATE carriages SET
					reservedSeats = reservedSeats + 1,
					carriageState = (totalSeats > reservedSeats) AND carriageState
				WHERE carriageId = NEW.carriage;
			
			UPDATE carriages SET
					reservedSeats = reservedSeats - 1,
					carriageState = (totalSeats > reservedSeats) AND carriageState
				WHERE carriageId = OLD.carriage;
			RETURN NEW;
		END;
	$$;


ALTER FUNCTION public.checkticketsupdate() OWNER TO postgres;

--
-- Name: createroute(character varying, character varying, character varying, character varying, timestamp without time zone, timestamp without time zone); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.createroute(IN _routenumber character varying, IN _departurestation character varying, IN _arrivalstation character varying, IN _trainname character varying, IN _departuretime timestamp without time zone, IN _arrivaltime timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
		DECLARE
			_trainId INTEGER;
			_depStationId INTEGER;
			_arrStationId INTEGER;
		BEGIN
			BEGIN
			
				SELECT trainId INTO _trainId FROM trains WHERE trainName = _trainName;
				SELECT stationId INTO _depStationId FROM stations WHERE stationName = _departureStation;
				SELECT stationId INTO _arrStationId FROM stations WHERE stationName = _arrivalStation;
				
				IF (_trainId IS NOT NULL OR _depStationId IS NOT NULL OR _arrStationId IS NOT NULL) THEN
					RAISE EXCEPTION 'error1: existing ojbects';
				ELSE 
				
				INSERT INTO trains(trainName) VALUES (_trainName)
					RETURNING trainId INTO _trainId;
				INSERT INTO stations(stationName, stationState) VALUES (_departureStation, TRUE)
					RETURNING stationId INTO _depStationId;
				INSERT INTO stations(stationName, stationState) VALUES (_arrivalStation, TRUE)
					RETURNING stationId INTO _arrStationId;

					IF(_arrivalTime < _departureTime) THEN 
						RAISE EXCEPTION 'error2: logic error in time management';
					ELSE
						INSERT INTO routesShedule(routeNumber, departureStation, arrivalStation, train, departureTime, arrivalTime)
							VALUES(_routeNumber, _depStationId, _arrStationId, _trainId, _departureTime, _arrivalTime);
				
				END IF;
				END IF;

			EXCEPTION
				WHEN OTHERS THEN 
					RAISE NOTICE '_ОШИБКА: %', SQLERRM;
					ROLLBACK;
					return;
				END;
			COMMIT;
	END;
	$$;


ALTER PROCEDURE public.createroute(IN _routenumber character varying, IN _departurestation character varying, IN _arrivalstation character varying, IN _trainname character varying, IN _departuretime timestamp without time zone, IN _arrivaltime timestamp without time zone) OWNER TO postgres;

--
-- Name: deletecarriage(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletecarriage(_id integer, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM carriages WHERE carriageId = _id
			RETURNING carriageId INTO result;
		IF result IS NULL THEN
			result = -1;
		END IF;
	END;
	$$;


ALTER FUNCTION public.deletecarriage(_id integer, OUT result integer) OWNER TO postgres;

--
-- Name: deletefrommainshedule(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletefrommainshedule(_oldroute character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM mainShedule WHERE FLIGHT_№ = _oldRoute;
	END;
	$$;


ALTER FUNCTION public.deletefrommainshedule(_oldroute character varying) OWNER TO postgres;

--
-- Name: deletepassenger(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletepassenger(_id integer, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM passengers CASCADE WHERE passengerId = _id 
			RETURNING passengerId INTO result;
		IF result IS NULL THEN
			result = -1;
		END IF;
	END;
	$$;


ALTER FUNCTION public.deletepassenger(_id integer, OUT result integer) OWNER TO postgres;

--
-- Name: deleteroute(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deleteroute(_id integer, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM routesShedule WHERE routeId = _id 
			RETURNING routeId INTO result;
		IF result IS NULL THEN
			result = -1;
		END IF;
	END;
	$$;


ALTER FUNCTION public.deleteroute(_id integer, OUT result integer) OWNER TO postgres;

--
-- Name: deletestation(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletestation(_id integer, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM stations WHERE stationId = _id
			RETURNING stationId INTO result;
		IF result IS NULL THEN
			result = -1;
		END IF;
	END;
	$$;


ALTER FUNCTION public.deletestation(_id integer, OUT result integer) OWNER TO postgres;

--
-- Name: deletetarrif(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletetarrif(_id integer, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM tarrif WHERE tarrifId = _id
			RETURNING tarrifId INTO result;
		IF result IS NULL THEN
			result = -1;
		END IF;
	END;
	$$;


ALTER FUNCTION public.deletetarrif(_id integer, OUT result integer) OWNER TO postgres;

--
-- Name: deleteticket(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deleteticket(_id integer, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM tickets WHERE ticketId = _id
			RETURNING ticketId INTO result;
		IF result IS NULL THEN
			result = -1;
		END IF;
	END;
	$$;


ALTER FUNCTION public.deleteticket(_id integer, OUT result integer) OWNER TO postgres;

--
-- Name: deletetrain(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletetrain(_id integer, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM trains WHERE trainId = _id
			RETURNING trainId INTO result;
		IF result IS NULL THEN
			result = -1;
		END IF;
	END;
	$$;


ALTER FUNCTION public.deletetrain(_id integer, OUT result integer) OWNER TO postgres;

--
-- Name: getactiveservices(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getactiveservices() RETURNS TABLE("flight_№" character varying, departure_station character varying, departure_time timestamp without time zone, arrival_station character varying, arrival_time timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
		BEGIN
			RETURN QUERY SELECT 
				activeF.FLIGHT_№,
				activeF.DEPRATURE_STATION,
				activeF.DEPARTURE_TIME,
				activeF.ARRIVAL_STATION,
				activeF.ARRIVAL_TIME
			FROM (SELECT * FROM availableRoutes WHERE state = 'Активный') AS activeF;
		END;
	$$;


ALTER FUNCTION public.getactiveservices() OWNER TO postgres;

--
-- Name: getaverageticketcost(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getaverageticketcost() RETURNS TABLE(passenger character varying, "flight_№" character varying, carriage character varying, reservationdate date, tarrifcost integer, totalcost integer, averagecost numeric)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY
			SELECT
				(SELECT passport FROM passengers WHERE passengerId = tickets.passenger) AS passenger,
				(SELECT routeNumber FROM routesShedule WHERE routeId = tickets.route) AS FLIGHT_№,
				(SELECT carriageNumber FROM carriages WHERE carriageId = tickets.carriage) AS carriage,
				tickets.reservationDate,
				(SELECT tarrif.tarrifCost FROM tarrif WHERE tarrifId = tickets.tarrif) AS Tcost,
				tickets.totalCost AS totalCost,
				(SELECT AVG(tarrif.tarrifCost) FROM tarrif) AS averageCost
			FROM tickets;
	END;
	$$;


ALTER FUNCTION public.getaverageticketcost() OWNER TO postgres;

--
-- Name: getcountofticketsforeachpassenger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getcountofticketsforeachpassenger() RETURNS TABLE(passport character varying, firstname character varying, lastname character varying, middlename character varying, numberoftickets bigint)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY
			SELECT 
				passengers.passport,
				passengers.firstName,
				passengers.lastName,
				CASE
					WHEN passengers.middleName IS NULL THEN ''
					ELSE passengers.middleName
				END AS middleName,
				(SELECT COUNT(*) FROM tickets WHERE passenger = passengers.passengerId) AS numberOfTickets
			FROM passengers;
	END;
	$$;


ALTER FUNCTION public.getcountofticketsforeachpassenger() OWNER TO postgres;

--
-- Name: getemptycarriages(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getemptycarriages() RETURNS TABLE(trainname character varying, carriagenumber character varying, reservedseats integer, totalseats integer, difference integer)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY
			SELECT
				(SELECT trains.trainName FROM trains WHERE trainId = carriages.train) AS trainName,
				carriages.carriageNumber,
				carriages.reservedSeats,
				carriages.totalSeats,
				carriages.totalSeats - carriages.reservedSeats AS seatsDifference
			FROM carriages;
	END;
	$$;


ALTER FUNCTION public.getemptycarriages() OWNER TO postgres;

--
-- Name: getincompletetrains(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getincompletetrains() RETURNS TABLE(trainname character varying, incompletecarriages bigint, totalcarriages bigint)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY 
			SELECT
				trains.trainName,
				(SELECT COUNT(*) FROM carriages WHERE carriages.carriageState=TRUE AND carriages.train=trains.trainId) AS incompleteCarriages,
				(SELECT COUNT(*) FROM carriages WHERE carriages.train=trains.trainId) AS totalCarriages
			FROM trains
			JOIN carriages
				ON trains.trainId = carriages.train
			GROUP BY trainId
			HAVING TRUE = ANY(SELECT carriageState FROM carriages WHERE carriages.train = trains.trainId);
	END;
	$$;


ALTER FUNCTION public.getincompletetrains() OWNER TO postgres;

--
-- Name: indexingticketscost(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.indexingticketscost(percent integer) RETURNS TABLE(ticketid integer, passport character varying, routenumber character varying, tarrifname character varying, totalcost integer, carriagenumber character varying, reservationdate date)
    LANGUAGE plpgsql
    AS $$
		DECLARE
			_ticketId INTEGER;
			_ticketCost INTEGER;
			_ticketsCursor CURSOR FOR select tickets.ticketId, tickets.totalCost FROM tickets;
		BEGIN
			OPEN _ticketsCursor;
				LOOP
				FETCH NEXT FROM _ticketsCursor INTO _ticketId, _ticketCost;
				IF NOT FOUND THEN EXIT;END IF;
					_ticketCost := CAST(_ticketCost + _ticketCost *(percent/100) AS INTEGER);
					UPDATE tickets SET totalCost = _ticketCost WHERE tickets.ticketId = _ticketId;
				END LOOP;
			CLOSE _ticketsCursor;

			RETURN QUERY SELECT * FROM selectFromTickets();
		END;
	$$;


ALTER FUNCTION public.indexingticketscost(percent integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: routesshedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.routesshedule (
    routeid integer NOT NULL,
    routenumber character varying(10),
    departurestation integer NOT NULL,
    arrivalstation integer NOT NULL,
    train integer NOT NULL,
    departuretime timestamp without time zone NOT NULL,
    arrivaltime timestamp without time zone NOT NULL
);


ALTER TABLE public.routesshedule OWNER TO postgres;

--
-- Name: stations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stations (
    stationid integer NOT NULL,
    stationname character varying(30) NOT NULL,
    stationstate boolean NOT NULL
);


ALTER TABLE public.stations OWNER TO postgres;

--
-- Name: trains; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trains (
    trainid integer NOT NULL,
    trainname character varying(30) NOT NULL
);


ALTER TABLE public.trains OWNER TO postgres;

--
-- Name: mainshedule; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.mainshedule AS
 SELECT routesshedule.routenumber AS "flight_№",
    depstations.stationname AS deprature_station,
    routesshedule.departuretime AS departure_time,
    arrstations.stationname AS arrival_station,
    routesshedule.arrivaltime AS arrival_time,
    trains.trainname AS train
   FROM (((public.routesshedule
     JOIN public.stations depstations ON ((depstations.stationid = routesshedule.departurestation)))
     JOIN public.stations arrstations ON ((arrstations.stationid = routesshedule.arrivalstation)))
     JOIN public.trains ON ((trains.trainid = routesshedule.train)));


ALTER VIEW public.mainshedule OWNER TO postgres;

--
-- Name: mainshedule_deleter(public.mainshedule); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.mainshedule_deleter(oldtable public.mainshedule) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM routesShedule WHERE routesShedule.FLIGHT_№ = oldTable.FLIGHT_№;
	END;
	$$;


ALTER FUNCTION public.mainshedule_deleter(oldtable public.mainshedule) OWNER TO postgres;

--
-- Name: mainshedule_inserter(public.mainshedule); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.mainshedule_inserter(newtable public.mainshedule) RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE
		_trainId INTEGER;
		_departureStationId INTEGER;
		_arrivalStationId INTEGER;	
	BEGIN
		SELECT stations.stationId INTO _departureStationId FROM stations WHERE stations.stationName = newTable.DEPRATURE_STATION;
		SELECT stations.stationId INTO _arrivalStationId FROM stations WHERE stations.stationName = newTable.ARRIVAL_STATION;
		SELECT trainId INTO _trainId FROM trains WHERE trainName = newTable.TRAIN;
		
		if(_trainId IS NULL OR _departureStationId IS NULL OR _arrivalStationId IS NULL) THEN
			return;
		END IF;

		INSERT INTO routesShedule (routeNumber, departureStation, arrivalStation, departureTime, arrivalTime, train)
			VALUES(newTable.FLIGHT_№, _departureStationId, _arrivalStationId, newTable.DEPARTURE_TIME, newTable.ARRIVAL_TIME, _trainId);
	END;
	$$;


ALTER FUNCTION public.mainshedule_inserter(newtable public.mainshedule) OWNER TO postgres;

--
-- Name: mainshedule_updater(public.mainshedule, public.mainshedule); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.mainshedule_updater(oldtable public.mainshedule, newtable public.mainshedule) RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE
		_trainId INTEGER;
		_departureStationId INTEGER;
		_arrivalStationId INTEGER;
		_oldRouteId INTEGER;
	BEGIN
		SELECT stations.stationId INTO _departureStationId FROM stations WHERE stations.stationName = newTable.DEPRATURE_STATION;
		SELECT stations.stationId INTO _arrivalStationId FROM stations WHERE stations.stationName = newTable.ARRIVAL_STATION;
		SELECT trainId INTO _trainId FROM trains WHERE trainName = newTable.TRAIN;
		SELECT routetId INTO _oldRouteId FROM routessShedule WHERE routeNumber = oldTable.FLIGHT_№;

		UPDATE routessShedule SET 
				routeNumber = newTable.FLIGHT_№,
				departureStation = _departureStationId,
				arrivalStation = _arrivalStationId,
				departureTime = newTable.DEPARTURE_TIME,
				arrivalTime = newTable.ARRIVAL_TIME,
				train = _trainId
			WHERE routetId = _oldRouteId;
	END;
	$$;


ALTER FUNCTION public.mainshedule_updater(oldtable public.mainshedule, newtable public.mainshedule) OWNER TO postgres;

--
-- Name: selectfromcarriages(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.selectfromcarriages() RETURNS TABLE(carraigeid integer, carriagenumber character varying, train character varying, totalseats integer, reservedseats integer, carriagestate boolean)
    LANGUAGE plpgsql
    AS $$
		BEGIN
			RETURN QUERY
				SELECT 
					carriages.carriageId,
					carriages.carriageNumber,
					trains.trainName,
					carriages.totalSeats,
					carriages.reservedSeats,
					carriages.carriageState
				FROM carriages
					JOIN trains ON carriages.train = trains.trainId;
		END;
	$$;


ALTER FUNCTION public.selectfromcarriages() OWNER TO postgres;

--
-- Name: selectfromroutesshedule(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.selectfromroutesshedule() RETURNS TABLE(routeid integer, routenumber character varying, departurestation character varying, departuretime timestamp without time zone, arrivalstation character varying, arrivaltime timestamp without time zone, train character varying)
    LANGUAGE plpgsql
    AS $$
		BEGIN
			RETURN QUERY
				SELECT 
					routesShedule.routeId,
					mainShedule.FLIGHT_№,
					mainShedule.DEPRATURE_STATION,
					mainShedule.DEPARTURE_TIME,
					mainShedule.ARRIVAL_STATION,
					mainShedule.ARRIVAL_TIME,
					mainShedule.TRAIN
				FROM mainShedule
				JOIN routesShedule 
					ON mainShedule.FLIGHT_№ = routesShedule.routeNumber;
		END;
		$$;


ALTER FUNCTION public.selectfromroutesshedule() OWNER TO postgres;

--
-- Name: selectfromtickets(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.selectfromtickets() RETURNS TABLE(ticketid integer, passport character varying, routenumber character varying, tarrifname character varying, totalcost integer, carriagenumber character varying, reservationdate date)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY SELECT 
				tickets.ticketId,
				passengers.passport,
				routesShedule.routeNumber,
				tarrif.tarrifName,
				tickets.totalCost,
				carriages.carriageNumber,
				tickets.reservationDate
				FROM tickets 
				JOIN passengers
					ON tickets.passenger = passengers.passengerId
				JOIN routesShedule
					ON tickets.route = routesShedule.routeId
				JOIN tarrif
					ON tickets.tarrif = tarrif.tarrifId
				JOIN carriages
					ON tickets.carriage = carriages.carriageId;
	END;
	$$;


ALTER FUNCTION public.selectfromtickets() OWNER TO postgres;

--
-- Name: supercost(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.supercost() RETURNS TABLE(passport character varying, firstname character varying, lastname character varying, middlename character varying, totalcost integer, maxtarrifcost integer)
    LANGUAGE plpgsql
    AS $$
		BEGIN
			RETURN QUERY 
				SELECT
					p.passport,
					p.firstName,
					p.lastName,
					p.middleName,
					t.totalCost,
					(SELECT MAX(tarrif.tarrifCost) FROM tarrif)
				FROM passengers AS p
					JOIN tickets t
					ON p.passengerId = t.passenger
				WHERE (SELECT MAX(tarrif.tarrifCost) FROM tarrif) <= ALL(SELECT tickets.totalCost FROM tickets WHERE passenger = p.passengerId);
		END;
	$$;


ALTER FUNCTION public.supercost() OWNER TO postgres;

--
-- Name: ticketstypes(boolean, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ticketstypes(_cananimals boolean, _morethan integer) RETURNS TABLE(passengerpassport character varying, tarrifname character varying, routenumber character varying, cananimals boolean, reservedcount bigint, morethan integer)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY SELECT
			passengers.passport,
			tarrif.tarrifName,
			routesShedule.routeNumber,
			_canAnimals,
			COUNT(passengers.passport) AS reservedCount,
			_moreThan
		FROM tickets 
			JOIN tarrif
				ON tickets.tarrif = tarrif.tarrifId
			JOIN passengers 
				ON tickets.passenger = passengers.passengerId
			JOIN routesShedule
				ON routesShedule.routeId = tickets.route
		WHERE tarrifAnimals = _canAnimals
		GROUP BY passengers.passport, tarrif.tarrifName, routesShedule.routeNumber
		HAVING COUNT(passengers.passport) >= _moreThan
		ORDER BY reservedCount;
	END;
	$$;


ALTER FUNCTION public.ticketstypes(_cananimals boolean, _morethan integer) OWNER TO postgres;

--
-- Name: transactioncaller(character varying, character varying, character varying, character varying, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.transactioncaller(_routenumber character varying, _departurestation character varying, _arrivalstation character varying, _trainname character varying, _departuretime timestamp without time zone, _arrivaltime timestamp without time zone, OUT res integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN
		res = 0;
		CALL createRoute(_routeNumber, _departureStation, _arrivalStation, _trainName, _departureTime, _arrivalTime);
		EXCEPTION
			WHEN OTHERS 
			THEN 
				res = -2; 
	END;
	$$;


ALTER FUNCTION public.transactioncaller(_routenumber character varying, _departurestation character varying, _arrivalstation character varying, _trainname character varying, _departuretime timestamp without time zone, _arrivaltime timestamp without time zone, OUT res integer) OWNER TO postgres;

--
-- Name: updatecarriage(integer, character varying, character varying, integer, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatecarriage(_id integer, newcarriagenumber character varying, newtrainname character varying, newtotalseats integer, newreservedseats integer, newstate boolean, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
		_newTrainId INTEGER;
		_oldReservedSeats INTEGER;
		_oldTotalSeats INTEGER;
	BEGIN 		
		SELECT trainId INTO _newTrainId FROM trains WHERE trainName = newTrainName;

		IF newReservedSeats >= newTotalSeats THEN newState = FALSE; END IF;

		UPDATE carriages SET reservedSeats = newReservedSeats,
							totalSeats = newTotalSeats,
							train = _newTrainId,
							carriageState = newState,
							carriageNumber = newCarriageNumber
			WHERE carriageId = _id
			RETURNING carriageId INTO result;
	END;
	$$;


ALTER FUNCTION public.updatecarriage(_id integer, newcarriagenumber character varying, newtrainname character varying, newtotalseats integer, newreservedseats integer, newstate boolean, OUT result integer) OWNER TO postgres;

--
-- Name: updatemainshedule(character varying, character varying, character varying, timestamp without time zone, character varying, timestamp without time zone, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatemainshedule(_oldroute character varying, routenumber character varying, depstation character varying, deptime timestamp without time zone, arrstation character varying, arrtime timestamp without time zone, trainname character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		UPDATE mainShedule SET
			FLIGHT_№ = routeNumber,
			DEPRATURE_STATION = depStation,
			DEPARTURE_TIME = depTime,
			ARRIVAL_STATION = arrStation,
			ARRIVAL_TIME = arrTime,
			TRAIN = trainName
		WHERE FLIGHT_№ = _oldRoute;
	END;
	$$;


ALTER FUNCTION public.updatemainshedule(_oldroute character varying, routenumber character varying, depstation character varying, deptime timestamp without time zone, arrstation character varying, arrtime timestamp without time zone, trainname character varying) OWNER TO postgres;

--
-- Name: updatepassenger(integer, character varying, date, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatepassenger(_id integer, newpassport character varying, newbirthdate date, newfirstname character varying, newlastname character varying, newmiddlename character varying DEFAULT NULL::character varying, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN
		UPDATE passengers SET passport = newPassport,
							birthDate = newBirthDate,
							firstName = newFirstName,
							lastName = newLastName,
							middleName = newMiddleName
			WHERE passengerId = _id
			RETURNING passengerId INTO result;
	END;
	$$;


ALTER FUNCTION public.updatepassenger(_id integer, newpassport character varying, newbirthdate date, newfirstname character varying, newlastname character varying, newmiddlename character varying, OUT result integer) OWNER TO postgres;

--
-- Name: updateroute(integer, character varying, character varying, timestamp without time zone, character varying, timestamp without time zone, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updateroute(_id integer, newroutenumber character varying, newdeparturestation character varying, newdeparturetime timestamp without time zone, newarrivalstation character varying, newarrivaltime timestamp without time zone, newtrain character varying, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
		_trainId INTEGER;
		_departureStationId INTEGER;
		_arrivalStationId INTEGER;
	BEGIN
		SELECT trainId INTO _trainId FROM trains WHERE trains.trainName = newTrain;
		SELECT stations.stationId INTO _departureStationId FROM stations WHERE stations.stationName = newDepartureStation;
		SELECT stations.stationId INTO _arrivalStationId FROM stations WHERE stations.stationName = newArrivalStation;
		
		IF newDepartureTime > newArrivalTime THEN
			result := -1;
		ELSE
			UPDATE routesShedule SET
							routeNumber = newRouteNumber,
							departureStation = _departureStationId,
							arrivalStation = _arrivalStationId,
							train = _trainId,
							departureTime = newDepartureTime,
							arrivalTime = newArrivalTime
				WHERE routeId = _id
				RETURNING routeId INTO result;
		END IF;
	END;
	$$;


ALTER FUNCTION public.updateroute(_id integer, newroutenumber character varying, newdeparturestation character varying, newdeparturetime timestamp without time zone, newarrivalstation character varying, newarrivaltime timestamp without time zone, newtrain character varying, OUT result integer) OWNER TO postgres;

--
-- Name: updatestation(integer, character varying, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatestation(_id integer, newstationname character varying, newstationstate boolean, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN 
		UPDATE stations SET stationName = newStationName,
							stationState = newStationState
			WHERE stationId = _id
			RETURNING stationId INTO result;
	END;
	$$;


ALTER FUNCTION public.updatestation(_id integer, newstationname character varying, newstationstate boolean, OUT result integer) OWNER TO postgres;

--
-- Name: updatetarrif(integer, character varying, boolean, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatetarrif(_id integer, newtarrifname character varying, newcananimals boolean, newtarrifcost integer, newtarrifdesc text DEFAULT NULL::text, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN 
		UPDATE tarrif SET tarrifName = newTarrifName,
						tarrifCost = newTarrifCost,
						tarrifAnimals = newCanAnimals,
						tarrifDesc = newTarrifDesc  
			WHERE tarrifId = _id
			RETURNING tarrifId INTO result;
	END;
	$$;


ALTER FUNCTION public.updatetarrif(_id integer, newtarrifname character varying, newcananimals boolean, newtarrifcost integer, newtarrifdesc text, OUT result integer) OWNER TO postgres;

--
-- Name: updateticket(integer, character varying, character varying, character varying, character varying, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updateticket(_id integer, newpassport character varying, newroutenumber character varying, newtarrifname character varying, newcarriagenumber character varying, newreservationdate date, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
		_newPassengerId INTEGER;
		_newRouteId INTEGER;
		_newTarrifId INTEGER;
		_newCarriageId INTEGER;
		_oldArrivalTime TIMESTAMP;
		_totalCost INTEGER;
		_passengerBirthDate DATE;
	BEGIN
		SELECT passengerId INTO _newPassengerId FROM passengers WHERE passport = newPassport;
		SELECT birthDate INTO _passengerBirthDate FROM passengers WHERE passport = newPassport;

		SELECT RouteId INTO _newRouteId FROM RoutesShedule WHERE routeNumber = newRouteNumber;
		SELECT tarrifId INTO _newTarrifId FROM tarrif WHERE tarrifName = newTarrifName;
		SELECT carriageId INTO _newCarriageId FROM carriages WHERE carriageNumber = newCarriageNumber;

		SELECT arrivalTime INTO _oldArrivalTime FROM routesShedule WHERE routeId = (SELECT route FROM tickets WHERE ticketId = _id); --! <подзапрос WHERE>

		SELECT * INTO _totalCost FROM birthdayDateAndCost(newReservationDate, _passengerBirthDate, _newTarrifId);

		IF _oldArrivalTime < newReservationDate THEN
			result := -1;
			RETURN;
		END IF;

		UPDATE tickets SET
					passenger = _newPassengerId,
					route = _newRouteId,
					tarrif = _newTarrifId,
					carriage = _newCarriageId,
					reservationDate = newReservationDate,
					totalCost = _totalCost
			WHERE ticketId = _id
			RETURNING ticketId INTO result;			
	END;
	$$;


ALTER FUNCTION public.updateticket(_id integer, newpassport character varying, newroutenumber character varying, newtarrifname character varying, newcarriagenumber character varying, newreservationdate date, OUT result integer) OWNER TO postgres;

--
-- Name: updatetrain(integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatetrain(_id integer, newtrainname character varying, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN 
		UPDATE trains SET trainName = newTrainName			
			WHERE trainId = _id
			RETURNING trainId INTO result;
	END;
	$$;


ALTER FUNCTION public.updatetrain(_id integer, newtrainname character varying, OUT result integer) OWNER TO postgres;

--
-- Name: carriages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.carriages (
    carriageid integer NOT NULL,
    carriagenumber character varying(10) NOT NULL,
    reservedseats integer NOT NULL,
    totalseats integer NOT NULL,
    train integer NOT NULL,
    carriagestate boolean NOT NULL
);


ALTER TABLE public.carriages OWNER TO postgres;

--
-- Name: availableroutes; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.availableroutes AS
 SELECT
        CASE
            WHEN (true = ALL (ARRAY[depstations.stationstate, arrstations.stationstate, ( SELECT carriages.carriagestate
               FROM public.carriages
              WHERE (carriages.train = trains.trainid)
             LIMIT 1)])) THEN 'Активный'::text
            ELSE 'Неактивный'::text
        END AS state,
    routesshedule.routenumber AS "flight_№",
    depstations.stationname AS deprature_station,
    routesshedule.departuretime AS departure_time,
    arrstations.stationname AS arrival_station,
    routesshedule.arrivaltime AS arrival_time,
    trains.trainname AS train
   FROM (((public.routesshedule
     JOIN public.stations depstations ON ((depstations.stationid = routesshedule.departurestation)))
     JOIN public.stations arrstations ON ((arrstations.stationid = routesshedule.arrivalstation)))
     JOIN public.trains ON ((trains.trainid = routesshedule.train)));


ALTER VIEW public.availableroutes OWNER TO postgres;

--
-- Name: carriages_carriageid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.carriages_carriageid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.carriages_carriageid_seq OWNER TO postgres;

--
-- Name: carriages_carriageid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.carriages_carriageid_seq OWNED BY public.carriages.carriageid;


--
-- Name: passengers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.passengers (
    passengerid integer NOT NULL,
    firstname character varying(30) NOT NULL,
    lastname character varying(30) NOT NULL,
    middlename character varying(30),
    passport character varying(10) NOT NULL,
    birthdate date NOT NULL
);


ALTER TABLE public.passengers OWNER TO postgres;

--
-- Name: passengers_passengerid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.passengers_passengerid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.passengers_passengerid_seq OWNER TO postgres;

--
-- Name: passengers_passengerid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.passengers_passengerid_seq OWNED BY public.passengers.passengerid;


--
-- Name: routesshedule_routeid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.routesshedule_routeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.routesshedule_routeid_seq OWNER TO postgres;

--
-- Name: routesshedule_routeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.routesshedule_routeid_seq OWNED BY public.routesshedule.routeid;


--
-- Name: stations_stationid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stations_stationid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stations_stationid_seq OWNER TO postgres;

--
-- Name: stations_stationid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stations_stationid_seq OWNED BY public.stations.stationid;


--
-- Name: tarrif; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tarrif (
    tarrifid integer NOT NULL,
    tarrifname character varying(30) NOT NULL,
    tarrifanimals boolean,
    tarrifcost integer NOT NULL,
    tarrifdesc text,
    CONSTRAINT checkpositivitytarrif CHECK ((tarrifcost >= 0))
);


ALTER TABLE public.tarrif OWNER TO postgres;

--
-- Name: tarrif_tarrifid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tarrif_tarrifid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tarrif_tarrifid_seq OWNER TO postgres;

--
-- Name: tarrif_tarrifid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tarrif_tarrifid_seq OWNED BY public.tarrif.tarrifid;


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tickets (
    ticketid integer NOT NULL,
    passenger integer NOT NULL,
    route integer NOT NULL,
    tarrif integer NOT NULL,
    totalcost integer NOT NULL,
    carriage integer NOT NULL,
    reservationdate date NOT NULL,
    CONSTRAINT checkpositivitytotalcost CHECK ((totalcost >= 0))
);


ALTER TABLE public.tickets OWNER TO postgres;

--
-- Name: tickets_ticketid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tickets_ticketid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tickets_ticketid_seq OWNER TO postgres;

--
-- Name: tickets_ticketid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tickets_ticketid_seq OWNED BY public.tickets.ticketid;


--
-- Name: trains_trainid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.trains_trainid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.trains_trainid_seq OWNER TO postgres;

--
-- Name: trains_trainid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.trains_trainid_seq OWNED BY public.trains.trainid;


--
-- Name: carriages carriageid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carriages ALTER COLUMN carriageid SET DEFAULT nextval('public.carriages_carriageid_seq'::regclass);


--
-- Name: passengers passengerid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.passengers ALTER COLUMN passengerid SET DEFAULT nextval('public.passengers_passengerid_seq'::regclass);


--
-- Name: routesshedule routeid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routesshedule ALTER COLUMN routeid SET DEFAULT nextval('public.routesshedule_routeid_seq'::regclass);


--
-- Name: stations stationid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stations ALTER COLUMN stationid SET DEFAULT nextval('public.stations_stationid_seq'::regclass);


--
-- Name: tarrif tarrifid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tarrif ALTER COLUMN tarrifid SET DEFAULT nextval('public.tarrif_tarrifid_seq'::regclass);


--
-- Name: tickets ticketid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets ALTER COLUMN ticketid SET DEFAULT nextval('public.tickets_ticketid_seq'::regclass);


--
-- Name: trains trainid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trains ALTER COLUMN trainid SET DEFAULT nextval('public.trains_trainid_seq'::regclass);


--
-- Data for Name: carriages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.carriages (carriageid, carriagenumber, reservedseats, totalseats, train, carriagestate) FROM stdin;
2	CARR2	0	110	1	t
4	CARR4	0	1100	3	t
3	CARR3	2	150	3	t
1	CARR1	1	100	1	t
\.


--
-- Data for Name: passengers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.passengers (passengerid, firstname, lastname, middlename, passport, birthdate) FROM stdin;
1	Евгений	Чичик	Андреевич	1234567890	2000-01-01
2	Александр	Пушкин	Сергеевич	1234567891	2000-01-01
3	Елена	Крик	Евгеньевна	1234567892	2000-01-01
4	Иван	Кач	Иванов	1234567893	2000-01-01
5	Дмитрий	Кульков	Александрович	1234567894	2000-01-01
\.


--
-- Data for Name: routesshedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.routesshedule (routeid, routenumber, departurestation, arrivalstation, train, departuretime, arrivaltime) FROM stdin;
2	Z1	2	1	3	2020-01-01 00:00:00	2023-01-01 00:00:00
1	A1	1	2	1	2000-01-01 00:00:00	2010-01-01 00:00:00
9	B100	15	16	10	2023-06-10 02:09:34.651827	2023-06-10 02:09:34.651827
11	B110	1	15	10	2000-01-01 00:00:00	2000-01-01 00:00:00
\.


--
-- Data for Name: stations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stations (stationid, stationname, stationstate) FROM stdin;
1	Москва	t
2	Великий Новгород	t
15	Санкт Петербург	t
16	Новосибирск	t
19	Алматы	t
\.


--
-- Data for Name: tarrif; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tarrif (tarrifid, tarrifname, tarrifanimals, tarrifcost, tarrifdesc) FROM stdin;
1	Первый	t	1000	Первый тариф, можно с животными
2	Второй	f	1250	Второй тариф, без животных
3	Третий	f	1234567	Просто... Золотой
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tickets (ticketid, passenger, route, tarrif, totalcost, carriage, reservationdate) FROM stdin;
1	1	2	1	8000	3	2010-01-01
2	2	2	3	9876536	3	2000-01-01
3	3	1	1	2000	1	2000-01-01
\.


--
-- Data for Name: trains; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trains (trainid, trainname) FROM stdin;
1	TRA1
3	TRA2
10	TRA100
\.


--
-- Name: carriages_carriageid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.carriages_carriageid_seq', 4, true);


--
-- Name: passengers_passengerid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.passengers_passengerid_seq', 5, true);


--
-- Name: routesshedule_routeid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.routesshedule_routeid_seq', 11, true);


--
-- Name: stations_stationid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stations_stationid_seq', 19, true);


--
-- Name: tarrif_tarrifid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tarrif_tarrifid_seq', 3, true);


--
-- Name: tickets_ticketid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tickets_ticketid_seq', 3, true);


--
-- Name: trains_trainid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.trains_trainid_seq', 11, true);


--
-- Name: carriages carriages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carriages
    ADD CONSTRAINT carriages_pkey PRIMARY KEY (carriageid);


--
-- Name: passengers passengers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.passengers
    ADD CONSTRAINT passengers_pkey PRIMARY KEY (passengerid);


--
-- Name: routesshedule routesshedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routesshedule
    ADD CONSTRAINT routesshedule_pkey PRIMARY KEY (routeid);


--
-- Name: stations stations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stations
    ADD CONSTRAINT stations_pkey PRIMARY KEY (stationid);


--
-- Name: tarrif tarrif_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tarrif
    ADD CONSTRAINT tarrif_pkey PRIMARY KEY (tarrifid);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (ticketid);


--
-- Name: trains trains_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trains
    ADD CONSTRAINT trains_pkey PRIMARY KEY (trainid);


--
-- Name: carriages uq_carriagenumber; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carriages
    ADD CONSTRAINT uq_carriagenumber UNIQUE (carriagenumber);


--
-- Name: passengers uq_passport; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.passengers
    ADD CONSTRAINT uq_passport UNIQUE (passport);


--
-- Name: routesshedule uq_routenumber; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routesshedule
    ADD CONSTRAINT uq_routenumber UNIQUE (routenumber);


--
-- Name: stations uq_stationname; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stations
    ADD CONSTRAINT uq_stationname UNIQUE (stationname);


--
-- Name: trains uq_trainname; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trains
    ADD CONSTRAINT uq_trainname UNIQUE (trainname);


--
-- Name: idx_reservedtime; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reservedtime ON public.tickets USING brin (reservationdate);


--
-- Name: idx_routesshedule; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_routesshedule ON public.routesshedule USING btree (routeid);


--
-- Name: idx_stations; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_stations ON public.stations USING hash (stationname);


--
-- Name: mainshedule delete_mainshedule; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE delete_mainshedule AS
    ON DELETE TO public.mainshedule DO INSTEAD  SELECT public.mainshedule_deleter(old.*) AS mainshedule_deleter;


--
-- Name: mainshedule insert_mainshedule; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE insert_mainshedule AS
    ON INSERT TO public.mainshedule DO INSTEAD  SELECT public.mainshedule_inserter(new.*) AS mainshedule_inserter;


--
-- Name: mainshedule update_mainshedule; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE update_mainshedule AS
    ON UPDATE TO public.mainshedule DO INSTEAD  SELECT public.mainshedule_updater(old.*, new.*) AS mainshedule_updater;


--
-- Name: tickets triggerdelete_tickets; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER triggerdelete_tickets AFTER DELETE ON public.tickets FOR EACH ROW EXECUTE FUNCTION public.checkticketsdelete();


--
-- Name: tickets triggerinsert_tickets; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER triggerinsert_tickets AFTER INSERT ON public.tickets FOR EACH ROW EXECUTE FUNCTION public.checkticketsinsert();


--
-- Name: tickets triggerupdate_tickets; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER triggerupdate_tickets AFTER UPDATE ON public.tickets FOR EACH ROW EXECUTE FUNCTION public.checkticketsupdate();


--
-- Name: carriages fk_carriages_trains; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carriages
    ADD CONSTRAINT fk_carriages_trains FOREIGN KEY (train) REFERENCES public.trains(trainid);


--
-- Name: routesshedule fk_routesshedule_arrival_stations; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routesshedule
    ADD CONSTRAINT fk_routesshedule_arrival_stations FOREIGN KEY (arrivalstation) REFERENCES public.stations(stationid);


--
-- Name: routesshedule fk_routesshedule_departure_stations; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routesshedule
    ADD CONSTRAINT fk_routesshedule_departure_stations FOREIGN KEY (departurestation) REFERENCES public.stations(stationid);


--
-- Name: routesshedule fk_routesshedule_trains; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routesshedule
    ADD CONSTRAINT fk_routesshedule_trains FOREIGN KEY (train) REFERENCES public.trains(trainid);


--
-- Name: tickets fk_tickets_carriages; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_tickets_carriages FOREIGN KEY (carriage) REFERENCES public.carriages(carriageid);


--
-- Name: tickets fk_tickets_passengers; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_tickets_passengers FOREIGN KEY (passenger) REFERENCES public.passengers(passengerid);


--
-- Name: tickets fk_tickets_routesshedule; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_tickets_routesshedule FOREIGN KEY (route) REFERENCES public.routesshedule(routeid);


--
-- Name: tickets fk_tickets_tarrif; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_tickets_tarrif FOREIGN KEY (tarrif) REFERENCES public.tarrif(tarrifid);


--
-- Name: TABLE routesshedule; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.routesshedule TO user_group;
GRANT ALL ON TABLE public.routesshedule TO admin_group;


--
-- Name: TABLE stations; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.stations TO user_group;
GRANT ALL ON TABLE public.stations TO admin_group;


--
-- Name: TABLE trains; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.trains TO user_group;
GRANT ALL ON TABLE public.trains TO admin_group;


--
-- Name: TABLE mainshedule; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.mainshedule TO admin_group;
GRANT SELECT ON TABLE public.mainshedule TO user_group;


--
-- Name: TABLE carriages; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.carriages TO user_group;
GRANT ALL ON TABLE public.carriages TO admin_group;


--
-- Name: COLUMN carriages.reservedseats; Type: ACL; Schema: public; Owner: postgres
--

GRANT UPDATE(reservedseats) ON TABLE public.carriages TO user_group;


--
-- Name: COLUMN carriages.carriagestate; Type: ACL; Schema: public; Owner: postgres
--

GRANT UPDATE(carriagestate) ON TABLE public.carriages TO user_group;


--
-- Name: TABLE availableroutes; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.availableroutes TO admin_group;
GRANT SELECT ON TABLE public.availableroutes TO user_group;


--
-- Name: TABLE passengers; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.passengers TO user_group;
GRANT ALL ON TABLE public.passengers TO admin_group;


--
-- Name: SEQUENCE passengers_passengerid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.passengers_passengerid_seq TO user_group;


--
-- Name: TABLE tarrif; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tarrif TO user_group;
GRANT ALL ON TABLE public.tarrif TO admin_group;


--
-- Name: TABLE tickets; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.tickets TO user_group;
GRANT ALL ON TABLE public.tickets TO admin_group;


--
-- Name: SEQUENCE tickets_ticketid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tickets_ticketid_seq TO user_group;


--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0 (Debian 17.0-1.pgdg120+1)
-- Dumped by pg_dump version 17.0 (Debian 17.0-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

