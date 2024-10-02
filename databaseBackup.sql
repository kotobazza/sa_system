PGDMP     
    	        
        {            Kursach    15.2    15.2 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16913    Kursach    DATABASE     }   CREATE DATABASE "Kursach" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Russia.1251';
    DROP DATABASE "Kursach";
                postgres    false            �            1255    19242 9   addcarriage(character varying, integer, integer, boolean)    FUNCTION     �  CREATE FUNCTION public.addcarriage(_trainname character varying, _totalseats integer, _reservedseats integer, _carriagestate boolean, OUT result integer) RETURNS integer
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
 �   DROP FUNCTION public.addcarriage(_trainname character varying, _totalseats integer, _reservedseats integer, _carriagestate boolean, OUT result integer);
       public          postgres    false            �            1255    19238 ^   addpassenger(character varying, date, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.addpassenger(_passport character varying, _birthdate date, _firstname character varying, _lastname character varying, _middlename character varying DEFAULT NULL::character varying, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$ 	
	BEGIN
		INSERT INTO passengers(firstName, lastName, middleName, passport, birthDate)
				VALUES (_firstName, _lastName, _middleName, _passport, _birthDate)
				RETURNING passengerId INTO result;			
	END;
	$$;
 �   DROP FUNCTION public.addpassenger(_passport character varying, _birthdate date, _firstname character varying, _lastname character varying, _middlename character varying, OUT result integer);
       public          postgres    false            �            1255    19243 �   addroute(character varying, character varying, timestamp without time zone, character varying, timestamp without time zone, character varying)    FUNCTION     6  CREATE FUNCTION public.addroute(_routenumber character varying, _departurestation character varying, _departuretime timestamp without time zone, _arrivalstation character varying, _arrivaltime timestamp without time zone, _trainname character varying, OUT result integer) RETURNS integer
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
   DROP FUNCTION public.addroute(_routenumber character varying, _departurestation character varying, _departuretime timestamp without time zone, _arrivalstation character varying, _arrivaltime timestamp without time zone, _trainname character varying, OUT result integer);
       public          postgres    false            �            1255    19241 &   addstation(character varying, boolean)    FUNCTION     3  CREATE FUNCTION public.addstation(_stationname character varying, _stationstate boolean, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN 
		INSERT INTO stations(stationName, stationState)
			VALUES (_stationName, _stationState)
			RETURNING stationId INTO result;
	END;
	$$;
 l   DROP FUNCTION public.addstation(_stationname character varying, _stationstate boolean, OUT result integer);
       public          postgres    false            �            1255    19240 4   addtarrif(character varying, boolean, integer, text)    FUNCTION     �  CREATE FUNCTION public.addtarrif(_tarrifname character varying, _animals boolean, _tarrifcost integer, _tarrifdesc text DEFAULT NULL::text, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN 
		INSERT INTO tarrif(tarrifName, tarrifCost, tarrifDesc, tarrifAnimals)
			VALUES (_tarrifName, _tarrifCost, _tarrifDesc, _animals)
			RETURNING tarrifId INTO result;
	END;
	$$;
 �   DROP FUNCTION public.addtarrif(_tarrifname character varying, _animals boolean, _tarrifcost integer, _tarrifdesc text, OUT result integer);
       public          postgres    false            �            1255    19244 [   addticket(character varying, character varying, character varying, character varying, date)    FUNCTION     4  CREATE FUNCTION public.addticket(_passport character varying, _routenumber character varying, _tarrifname character varying, _carriagenumber character varying, _reservationdate date, OUT result integer) RETURNS integer
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
 �   DROP FUNCTION public.addticket(_passport character varying, _routenumber character varying, _tarrifname character varying, _carriagenumber character varying, _reservationdate date, OUT result integer);
       public          postgres    false                       1255    19279 �   addtomainshedule(character varying, character varying, timestamp without time zone, character varying, timestamp without time zone, character varying)    FUNCTION     Y  CREATE FUNCTION public.addtomainshedule(routenumber character varying, depstation character varying, deptime timestamp without time zone, arrstation character varying, arrtime timestamp without time zone, trainname character varying) RETURNS void
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
 �   DROP FUNCTION public.addtomainshedule(routenumber character varying, depstation character varying, deptime timestamp without time zone, arrstation character varying, arrtime timestamp without time zone, trainname character varying);
       public          postgres    false            �            1255    19239    addtrain(character varying)    FUNCTION     �   CREATE FUNCTION public.addtrain(_trainname character varying, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN 
		INSERT INTO trains(trainName)
			VALUES (_trainName)
			RETURNING trainId INTO result;
	END;
	$$;
 Q   DROP FUNCTION public.addtrain(_trainname character varying, OUT result integer);
       public          postgres    false                       1255    19265    averagetarrifcost()    FUNCTION     5  CREATE FUNCTION public.averagetarrifcost() RETURNS TABLE(tarrifname character varying, tarrifcost integer, avgcost integer)
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
 *   DROP FUNCTION public.averagetarrifcost();
       public          postgres    false                       1255    19272 (   birthdaydateandcost(date, date, integer)    FUNCTION     �  CREATE FUNCTION public.birthdaydateandcost(reservdate date, birthdate date, _tarrif integer, OUT result integer) RETURNS integer
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
 p   DROP FUNCTION public.birthdaydateandcost(reservdate date, birthdate date, _tarrif integer, OUT result integer);
       public          postgres    false                       1255    19263 "   carriagenumberdeterminant(integer)    FUNCTION     �   CREATE FUNCTION public.carriagenumberdeterminant(carriageid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN CONCAT('CARR', carriageId);
	END;
	$$;
 D   DROP FUNCTION public.carriagenumberdeterminant(carriageid integer);
       public          postgres    false                       1255    19269    checkticketsdelete()    FUNCTION     1  CREATE FUNCTION public.checkticketsdelete() RETURNS trigger
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
 +   DROP FUNCTION public.checkticketsdelete();
       public          postgres    false                       1255    19267    checkticketsinsert()    FUNCTION     /  CREATE FUNCTION public.checkticketsinsert() RETURNS trigger
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
 +   DROP FUNCTION public.checkticketsinsert();
       public          postgres    false                       1255    19268    checkticketsupdate()    FUNCTION     �  CREATE FUNCTION public.checkticketsupdate() RETURNS trigger
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
 +   DROP FUNCTION public.checkticketsupdate();
       public          postgres    false                       1255    18779 �   createroute(character varying, character varying, character varying, character varying, timestamp without time zone, timestamp without time zone) 	   PROCEDURE     �  CREATE PROCEDURE public.createroute(IN _routenumber character varying, IN _departurestation character varying, IN _arrivalstation character varying, IN _trainname character varying, IN _departuretime timestamp without time zone, IN _arrivaltime timestamp without time zone)
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
   DROP PROCEDURE public.createroute(IN _routenumber character varying, IN _departurestation character varying, IN _arrivalstation character varying, IN _trainname character varying, IN _departuretime timestamp without time zone, IN _arrivaltime timestamp without time zone);
       public          postgres    false                        1255    19254    deletecarriage(integer)    FUNCTION       CREATE FUNCTION public.deletecarriage(_id integer, OUT result integer) RETURNS integer
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
 F   DROP FUNCTION public.deletecarriage(_id integer, OUT result integer);
       public          postgres    false                       1255    19281 (   deletefrommainshedule(character varying)    FUNCTION     �   CREATE FUNCTION public.deletefrommainshedule(_oldroute character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM mainShedule WHERE FLIGHT_№ = _oldRoute;
	END;
	$$;
 I   DROP FUNCTION public.deletefrommainshedule(_oldroute character varying);
       public          postgres    false                       1255    19255    deletepassenger(integer)    FUNCTION     $  CREATE FUNCTION public.deletepassenger(_id integer, OUT result integer) RETURNS integer
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
 G   DROP FUNCTION public.deletepassenger(_id integer, OUT result integer);
       public          postgres    false            �            1255    19253    deleteroute(integer)    FUNCTION       CREATE FUNCTION public.deleteroute(_id integer, OUT result integer) RETURNS integer
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
 C   DROP FUNCTION public.deleteroute(_id integer, OUT result integer);
       public          postgres    false                       1255    19256    deletestation(integer)    FUNCTION       CREATE FUNCTION public.deletestation(_id integer, OUT result integer) RETURNS integer
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
 E   DROP FUNCTION public.deletestation(_id integer, OUT result integer);
       public          postgres    false                       1255    19258    deletetarrif(integer)    FUNCTION       CREATE FUNCTION public.deletetarrif(_id integer, OUT result integer) RETURNS integer
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
 D   DROP FUNCTION public.deletetarrif(_id integer, OUT result integer);
       public          postgres    false            �            1255    19252    deleteticket(integer)    FUNCTION       CREATE FUNCTION public.deleteticket(_id integer, OUT result integer) RETURNS integer
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
 D   DROP FUNCTION public.deleteticket(_id integer, OUT result integer);
       public          postgres    false                       1255    19257    deletetrain(integer)    FUNCTION       CREATE FUNCTION public.deletetrain(_id integer, OUT result integer) RETURNS integer
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
 C   DROP FUNCTION public.deletetrain(_id integer, OUT result integer);
       public          postgres    false                       1255    19266    getactiveservices()    FUNCTION     *  CREATE FUNCTION public.getactiveservices() RETURNS TABLE("flight_№" character varying, departure_station character varying, departure_time timestamp without time zone, arrival_station character varying, arrival_time timestamp without time zone)
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
 *   DROP FUNCTION public.getactiveservices();
       public          postgres    false                       1255    19264    getaverageticketcost()    FUNCTION     3  CREATE FUNCTION public.getaverageticketcost() RETURNS TABLE(passenger character varying, "flight_№" character varying, carriage character varying, reservationdate date, tarrifcost integer, totalcost integer, averagecost numeric)
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
 -   DROP FUNCTION public.getaverageticketcost();
       public          postgres    false                       1255    19271 #   getcountofticketsforeachpassenger()    FUNCTION     \  CREATE FUNCTION public.getcountofticketsforeachpassenger() RETURNS TABLE(passport character varying, firstname character varying, lastname character varying, middlename character varying, numberoftickets bigint)
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
 :   DROP FUNCTION public.getcountofticketsforeachpassenger();
       public          postgres    false                       1255    19262    getemptycarriages()    FUNCTION       CREATE FUNCTION public.getemptycarriages() RETURNS TABLE(trainname character varying, carriagenumber character varying, reservedseats integer, totalseats integer, difference integer)
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
 *   DROP FUNCTION public.getemptycarriages();
       public          postgres    false                       1255    19276    getincompletetrains()    FUNCTION     �  CREATE FUNCTION public.getincompletetrains() RETURNS TABLE(trainname character varying, incompletecarriages bigint, totalcarriages bigint)
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
 ,   DROP FUNCTION public.getincompletetrains();
       public          postgres    false                       1255    19277    indexingticketscost(integer)    FUNCTION     C  CREATE FUNCTION public.indexingticketscost(percent integer) RETURNS TABLE(ticketid integer, passport character varying, routenumber character varying, tarrifname character varying, totalcost integer, carriagenumber character varying, reservationdate date)
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
 ;   DROP FUNCTION public.indexingticketscost(percent integer);
       public          postgres    false            �            1259    19140    routesshedule    TABLE     A  CREATE TABLE public.routesshedule (
    routeid integer NOT NULL,
    routenumber character varying(10),
    departurestation integer NOT NULL,
    arrivalstation integer NOT NULL,
    train integer NOT NULL,
    departuretime timestamp without time zone NOT NULL,
    arrivaltime timestamp without time zone NOT NULL
);
 !   DROP TABLE public.routesshedule;
       public         heap    postgres    false            �           0    0    TABLE routesshedule    ACL     r   GRANT SELECT ON TABLE public.routesshedule TO user_group;
GRANT ALL ON TABLE public.routesshedule TO admin_group;
          public          postgres    false    225            �            1259    19133    stations    TABLE     �   CREATE TABLE public.stations (
    stationid integer NOT NULL,
    stationname character varying(30) NOT NULL,
    stationstate boolean NOT NULL
);
    DROP TABLE public.stations;
       public         heap    postgres    false            �           0    0    TABLE stations    ACL     h   GRANT SELECT ON TABLE public.stations TO user_group;
GRANT ALL ON TABLE public.stations TO admin_group;
          public          postgres    false    223            �            1259    19110    trains    TABLE     k   CREATE TABLE public.trains (
    trainid integer NOT NULL,
    trainname character varying(30) NOT NULL
);
    DROP TABLE public.trains;
       public         heap    postgres    false            �           0    0    TABLE trains    ACL     d   GRANT SELECT ON TABLE public.trains TO user_group;
GRANT ALL ON TABLE public.trains TO admin_group;
          public          postgres    false    217            �            1259    19226    mainshedule    VIEW     e  CREATE VIEW public.mainshedule AS
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
    DROP VIEW public.mainshedule;
       public          postgres    false    223    217    217    225    225    225    225    225    225    223            �           0    0    TABLE mainshedule    ACL     n   GRANT ALL ON TABLE public.mainshedule TO admin_group;
GRANT SELECT ON TABLE public.mainshedule TO user_group;
          public          postgres    false    228                       1255    19261 '   mainshedule_deleter(public.mainshedule)    FUNCTION     �   CREATE FUNCTION public.mainshedule_deleter(oldtable public.mainshedule) RETURNS void
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM routesShedule WHERE routesShedule.FLIGHT_№ = oldTable.FLIGHT_№;
	END;
	$$;
 G   DROP FUNCTION public.mainshedule_deleter(oldtable public.mainshedule);
       public          postgres    false    228                       1255    19260 (   mainshedule_inserter(public.mainshedule)    FUNCTION     �  CREATE FUNCTION public.mainshedule_inserter(newtable public.mainshedule) RETURNS void
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
 H   DROP FUNCTION public.mainshedule_inserter(newtable public.mainshedule);
       public          postgres    false    228                       1255    19259 ;   mainshedule_updater(public.mainshedule, public.mainshedule)    FUNCTION     �  CREATE FUNCTION public.mainshedule_updater(oldtable public.mainshedule, newtable public.mainshedule) RETURNS void
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
 d   DROP FUNCTION public.mainshedule_updater(oldtable public.mainshedule, newtable public.mainshedule);
       public          postgres    false    228                       1255    19274    selectfromcarriages()    FUNCTION       CREATE FUNCTION public.selectfromcarriages() RETURNS TABLE(carraigeid integer, carriagenumber character varying, train character varying, totalseats integer, reservedseats integer, carriagestate boolean)
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
 ,   DROP FUNCTION public.selectfromcarriages();
       public          postgres    false                       1255    19275    selectfromroutesshedule()    FUNCTION     �  CREATE FUNCTION public.selectfromroutesshedule() RETURNS TABLE(routeid integer, routenumber character varying, departurestation character varying, departuretime timestamp without time zone, arrivalstation character varying, arrivaltime timestamp without time zone, train character varying)
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
 0   DROP FUNCTION public.selectfromroutesshedule();
       public          postgres    false                       1255    19273    selectfromtickets()    FUNCTION       CREATE FUNCTION public.selectfromtickets() RETURNS TABLE(ticketid integer, passport character varying, routenumber character varying, tarrifname character varying, totalcost integer, carriagenumber character varying, reservationdate date)
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
 *   DROP FUNCTION public.selectfromtickets();
       public          postgres    false                       1255    19278    supercost()    FUNCTION     �  CREATE FUNCTION public.supercost() RETURNS TABLE(passport character varying, firstname character varying, lastname character varying, middlename character varying, totalcost integer, maxtarrifcost integer)
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
 "   DROP FUNCTION public.supercost();
       public          postgres    false                       1255    19270    ticketstypes(boolean, integer)    FUNCTION     y  CREATE FUNCTION public.ticketstypes(_cananimals boolean, _morethan integer) RETURNS TABLE(passengerpassport character varying, tarrifname character varying, routenumber character varying, cananimals boolean, reservedcount bigint, morethan integer)
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
 K   DROP FUNCTION public.ticketstypes(_cananimals boolean, _morethan integer);
       public          postgres    false            
           1255    19294 �   transactioncaller(character varying, character varying, character varying, character varying, timestamp without time zone, timestamp without time zone)    FUNCTION       CREATE FUNCTION public.transactioncaller(_routenumber character varying, _departurestation character varying, _arrivalstation character varying, _trainname character varying, _departuretime timestamp without time zone, _arrivaltime timestamp without time zone, OUT res integer) RETURNS integer
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
   DROP FUNCTION public.transactioncaller(_routenumber character varying, _departurestation character varying, _arrivalstation character varying, _trainname character varying, _departuretime timestamp without time zone, _arrivaltime timestamp without time zone, OUT res integer);
       public          postgres    false            �            1255    19249 X   updatecarriage(integer, character varying, character varying, integer, integer, boolean)    FUNCTION       CREATE FUNCTION public.updatecarriage(_id integer, newcarriagenumber character varying, newtrainname character varying, newtotalseats integer, newreservedseats integer, newstate boolean, OUT result integer) RETURNS integer
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
 �   DROP FUNCTION public.updatecarriage(_id integer, newcarriagenumber character varying, newtrainname character varying, newtotalseats integer, newreservedseats integer, newstate boolean, OUT result integer);
       public          postgres    false                       1255    19280 �   updatemainshedule(character varying, character varying, character varying, timestamp without time zone, character varying, timestamp without time zone, character varying)    FUNCTION     8  CREATE FUNCTION public.updatemainshedule(_oldroute character varying, routenumber character varying, depstation character varying, deptime timestamp without time zone, arrstation character varying, arrtime timestamp without time zone, trainname character varying) RETURNS void
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
   DROP FUNCTION public.updatemainshedule(_oldroute character varying, routenumber character varying, depstation character varying, deptime timestamp without time zone, arrstation character varying, arrtime timestamp without time zone, trainname character varying);
       public          postgres    false            �            1255    19245 j   updatepassenger(integer, character varying, date, character varying, character varying, character varying)    FUNCTION     9  CREATE FUNCTION public.updatepassenger(_id integer, newpassport character varying, newbirthdate date, newfirstname character varying, newlastname character varying, newmiddlename character varying DEFAULT NULL::character varying, OUT result integer) RETURNS integer
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
 �   DROP FUNCTION public.updatepassenger(_id integer, newpassport character varying, newbirthdate date, newfirstname character varying, newlastname character varying, newmiddlename character varying, OUT result integer);
       public          postgres    false            	           1255    19250 �   updateroute(integer, character varying, character varying, timestamp without time zone, character varying, timestamp without time zone, character varying)    FUNCTION     �  CREATE FUNCTION public.updateroute(_id integer, newroutenumber character varying, newdeparturestation character varying, newdeparturetime timestamp without time zone, newarrivalstation character varying, newarrivaltime timestamp without time zone, newtrain character varying, OUT result integer) RETURNS integer
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
 '  DROP FUNCTION public.updateroute(_id integer, newroutenumber character varying, newdeparturestation character varying, newdeparturetime timestamp without time zone, newarrivalstation character varying, newarrivaltime timestamp without time zone, newtrain character varying, OUT result integer);
       public          postgres    false            �            1255    19248 2   updatestation(integer, character varying, boolean)    FUNCTION     a  CREATE FUNCTION public.updatestation(_id integer, newstationname character varying, newstationstate boolean, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN 
		UPDATE stations SET stationName = newStationName,
							stationState = newStationState
			WHERE stationId = _id
			RETURNING stationId INTO result;
	END;
	$$;
 �   DROP FUNCTION public.updatestation(_id integer, newstationname character varying, newstationstate boolean, OUT result integer);
       public          postgres    false            �            1255    19247 @   updatetarrif(integer, character varying, boolean, integer, text)    FUNCTION     �  CREATE FUNCTION public.updatetarrif(_id integer, newtarrifname character varying, newcananimals boolean, newtarrifcost integer, newtarrifdesc text DEFAULT NULL::text, OUT result integer) RETURNS integer
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
 �   DROP FUNCTION public.updatetarrif(_id integer, newtarrifname character varying, newcananimals boolean, newtarrifcost integer, newtarrifdesc text, OUT result integer);
       public          postgres    false            �            1255    19251 g   updateticket(integer, character varying, character varying, character varying, character varying, date)    FUNCTION     :  CREATE FUNCTION public.updateticket(_id integer, newpassport character varying, newroutenumber character varying, newtarrifname character varying, newcarriagenumber character varying, newreservationdate date, OUT result integer) RETURNS integer
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
 �   DROP FUNCTION public.updateticket(_id integer, newpassport character varying, newroutenumber character varying, newtarrifname character varying, newcarriagenumber character varying, newreservationdate date, OUT result integer);
       public          postgres    false            �            1255    19246 '   updatetrain(integer, character varying)    FUNCTION       CREATE FUNCTION public.updatetrain(_id integer, newtrainname character varying, OUT result integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	BEGIN 
		UPDATE trains SET trainName = newTrainName			
			WHERE trainId = _id
			RETURNING trainId INTO result;
	END;
	$$;
 c   DROP FUNCTION public.updatetrain(_id integer, newtrainname character varying, OUT result integer);
       public          postgres    false            �            1259    19126 	   carriages    TABLE     �   CREATE TABLE public.carriages (
    carriageid integer NOT NULL,
    carriagenumber character varying(10) NOT NULL,
    reservedseats integer NOT NULL,
    totalseats integer NOT NULL,
    train integer NOT NULL,
    carriagestate boolean NOT NULL
);
    DROP TABLE public.carriages;
       public         heap    postgres    false            �           0    0    TABLE carriages    ACL     j   GRANT SELECT ON TABLE public.carriages TO user_group;
GRANT ALL ON TABLE public.carriages TO admin_group;
          public          postgres    false    221            �           0    0    COLUMN carriages.reservedseats    ACL     E   GRANT UPDATE(reservedseats) ON TABLE public.carriages TO user_group;
          public          postgres    false    221    3475            �           0    0    COLUMN carriages.carriagestate    ACL     E   GRANT UPDATE(carriagestate) ON TABLE public.carriages TO user_group;
          public          postgres    false    221    3475            �            1259    19230    availableroutes    VIEW     �  CREATE VIEW public.availableroutes AS
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
 "   DROP VIEW public.availableroutes;
       public          postgres    false    225    225    225    225    225    225    223    223    223    221    221    217    217            �           0    0    TABLE availableroutes    ACL     v   GRANT ALL ON TABLE public.availableroutes TO admin_group;
GRANT SELECT ON TABLE public.availableroutes TO user_group;
          public          postgres    false    229            �            1259    19125    carriages_carriageid_seq    SEQUENCE     �   CREATE SEQUENCE public.carriages_carriageid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.carriages_carriageid_seq;
       public          postgres    false    221            �           0    0    carriages_carriageid_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.carriages_carriageid_seq OWNED BY public.carriages.carriageid;
          public          postgres    false    220            �            1259    19103 
   passengers    TABLE       CREATE TABLE public.passengers (
    passengerid integer NOT NULL,
    firstname character varying(30) NOT NULL,
    lastname character varying(30) NOT NULL,
    middlename character varying(30),
    passport character varying(10) NOT NULL,
    birthdate date NOT NULL
);
    DROP TABLE public.passengers;
       public         heap    postgres    false            �           0    0    TABLE passengers    ACL     z   GRANT SELECT,INSERT,UPDATE ON TABLE public.passengers TO user_group;
GRANT ALL ON TABLE public.passengers TO admin_group;
          public          postgres    false    215            �            1259    19102    passengers_passengerid_seq    SEQUENCE     �   CREATE SEQUENCE public.passengers_passengerid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.passengers_passengerid_seq;
       public          postgres    false    215            �           0    0    passengers_passengerid_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.passengers_passengerid_seq OWNED BY public.passengers.passengerid;
          public          postgres    false    214            �           0    0 #   SEQUENCE passengers_passengerid_seq    ACL     P   GRANT SELECT,USAGE ON SEQUENCE public.passengers_passengerid_seq TO user_group;
          public          postgres    false    214            �            1259    19139    routesshedule_routeid_seq    SEQUENCE     �   CREATE SEQUENCE public.routesshedule_routeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.routesshedule_routeid_seq;
       public          postgres    false    225            �           0    0    routesshedule_routeid_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.routesshedule_routeid_seq OWNED BY public.routesshedule.routeid;
          public          postgres    false    224            �            1259    19132    stations_stationid_seq    SEQUENCE     �   CREATE SEQUENCE public.stations_stationid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.stations_stationid_seq;
       public          postgres    false    223            �           0    0    stations_stationid_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.stations_stationid_seq OWNED BY public.stations.stationid;
          public          postgres    false    222            �            1259    19117    tarrif    TABLE     �   CREATE TABLE public.tarrif (
    tarrifid integer NOT NULL,
    tarrifname character varying(30) NOT NULL,
    tarrifanimals boolean,
    tarrifcost integer NOT NULL,
    tarrifdesc text,
    CONSTRAINT checkpositivitytarrif CHECK ((tarrifcost >= 0))
);
    DROP TABLE public.tarrif;
       public         heap    postgres    false            �           0    0    TABLE tarrif    ACL     d   GRANT SELECT ON TABLE public.tarrif TO user_group;
GRANT ALL ON TABLE public.tarrif TO admin_group;
          public          postgres    false    219            �            1259    19116    tarrif_tarrifid_seq    SEQUENCE     �   CREATE SEQUENCE public.tarrif_tarrifid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.tarrif_tarrifid_seq;
       public          postgres    false    219            �           0    0    tarrif_tarrifid_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.tarrif_tarrifid_seq OWNED BY public.tarrif.tarrifid;
          public          postgres    false    218            �            1259    19147    tickets    TABLE     <  CREATE TABLE public.tickets (
    ticketid integer NOT NULL,
    passenger integer NOT NULL,
    route integer NOT NULL,
    tarrif integer NOT NULL,
    totalcost integer NOT NULL,
    carriage integer NOT NULL,
    reservationdate date NOT NULL,
    CONSTRAINT checkpositivitytotalcost CHECK ((totalcost >= 0))
);
    DROP TABLE public.tickets;
       public         heap    postgres    false            �           0    0    TABLE tickets    ACL     t   GRANT SELECT,INSERT,UPDATE ON TABLE public.tickets TO user_group;
GRANT ALL ON TABLE public.tickets TO admin_group;
          public          postgres    false    227            �            1259    19146    tickets_ticketid_seq    SEQUENCE     �   CREATE SEQUENCE public.tickets_ticketid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.tickets_ticketid_seq;
       public          postgres    false    227            �           0    0    tickets_ticketid_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.tickets_ticketid_seq OWNED BY public.tickets.ticketid;
          public          postgres    false    226            �           0    0    SEQUENCE tickets_ticketid_seq    ACL     J   GRANT SELECT,USAGE ON SEQUENCE public.tickets_ticketid_seq TO user_group;
          public          postgres    false    226            �            1259    19109    trains_trainid_seq    SEQUENCE     �   CREATE SEQUENCE public.trains_trainid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.trains_trainid_seq;
       public          postgres    false    217            �           0    0    trains_trainid_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.trains_trainid_seq OWNED BY public.trains.trainid;
          public          postgres    false    216            �           2604    19129    carriages carriageid    DEFAULT     |   ALTER TABLE ONLY public.carriages ALTER COLUMN carriageid SET DEFAULT nextval('public.carriages_carriageid_seq'::regclass);
 C   ALTER TABLE public.carriages ALTER COLUMN carriageid DROP DEFAULT;
       public          postgres    false    221    220    221            �           2604    19106    passengers passengerid    DEFAULT     �   ALTER TABLE ONLY public.passengers ALTER COLUMN passengerid SET DEFAULT nextval('public.passengers_passengerid_seq'::regclass);
 E   ALTER TABLE public.passengers ALTER COLUMN passengerid DROP DEFAULT;
       public          postgres    false    215    214    215            �           2604    19143    routesshedule routeid    DEFAULT     ~   ALTER TABLE ONLY public.routesshedule ALTER COLUMN routeid SET DEFAULT nextval('public.routesshedule_routeid_seq'::regclass);
 D   ALTER TABLE public.routesshedule ALTER COLUMN routeid DROP DEFAULT;
       public          postgres    false    224    225    225            �           2604    19136    stations stationid    DEFAULT     x   ALTER TABLE ONLY public.stations ALTER COLUMN stationid SET DEFAULT nextval('public.stations_stationid_seq'::regclass);
 A   ALTER TABLE public.stations ALTER COLUMN stationid DROP DEFAULT;
       public          postgres    false    223    222    223            �           2604    19120    tarrif tarrifid    DEFAULT     r   ALTER TABLE ONLY public.tarrif ALTER COLUMN tarrifid SET DEFAULT nextval('public.tarrif_tarrifid_seq'::regclass);
 >   ALTER TABLE public.tarrif ALTER COLUMN tarrifid DROP DEFAULT;
       public          postgres    false    219    218    219            �           2604    19150    tickets ticketid    DEFAULT     t   ALTER TABLE ONLY public.tickets ALTER COLUMN ticketid SET DEFAULT nextval('public.tickets_ticketid_seq'::regclass);
 ?   ALTER TABLE public.tickets ALTER COLUMN ticketid DROP DEFAULT;
       public          postgres    false    226    227    227            �           2604    19113    trains trainid    DEFAULT     p   ALTER TABLE ONLY public.trains ALTER COLUMN trainid SET DEFAULT nextval('public.trains_trainid_seq'::regclass);
 =   ALTER TABLE public.trains ALTER COLUMN trainid DROP DEFAULT;
       public          postgres    false    217    216    217            �          0    19126 	   carriages 
   TABLE DATA           p   COPY public.carriages (carriageid, carriagenumber, reservedseats, totalseats, train, carriagestate) FROM stdin;
    public          postgres    false    221         |          0    19103 
   passengers 
   TABLE DATA           g   COPY public.passengers (passengerid, firstname, lastname, middlename, passport, birthdate) FROM stdin;
    public          postgres    false    215   N      �          0    19140    routesshedule 
   TABLE DATA           �   COPY public.routesshedule (routeid, routenumber, departurestation, arrivalstation, train, departuretime, arrivaltime) FROM stdin;
    public          postgres    false    225         �          0    19133    stations 
   TABLE DATA           H   COPY public.stations (stationid, stationname, stationstate) FROM stdin;
    public          postgres    false    223   �      �          0    19117    tarrif 
   TABLE DATA           ]   COPY public.tarrif (tarrifid, tarrifname, tarrifanimals, tarrifcost, tarrifdesc) FROM stdin;
    public          postgres    false    219         �          0    19147    tickets 
   TABLE DATA           k   COPY public.tickets (ticketid, passenger, route, tarrif, totalcost, carriage, reservationdate) FROM stdin;
    public          postgres    false    227   �      ~          0    19110    trains 
   TABLE DATA           4   COPY public.trains (trainid, trainname) FROM stdin;
    public          postgres    false    217         �           0    0    carriages_carriageid_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.carriages_carriageid_seq', 4, true);
          public          postgres    false    220            �           0    0    passengers_passengerid_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.passengers_passengerid_seq', 5, true);
          public          postgres    false    214            �           0    0    routesshedule_routeid_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.routesshedule_routeid_seq', 11, true);
          public          postgres    false    224            �           0    0    stations_stationid_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.stations_stationid_seq', 19, true);
          public          postgres    false    222            �           0    0    tarrif_tarrifid_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.tarrif_tarrifid_seq', 3, true);
          public          postgres    false    218            �           0    0    tickets_ticketid_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.tickets_ticketid_seq', 3, true);
          public          postgres    false    226            �           0    0    trains_trainid_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.trains_trainid_seq', 11, true);
          public          postgres    false    216            �           2606    19131    carriages carriages_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.carriages
    ADD CONSTRAINT carriages_pkey PRIMARY KEY (carriageid);
 B   ALTER TABLE ONLY public.carriages DROP CONSTRAINT carriages_pkey;
       public            postgres    false    221            �           2606    19108    passengers passengers_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.passengers
    ADD CONSTRAINT passengers_pkey PRIMARY KEY (passengerid);
 D   ALTER TABLE ONLY public.passengers DROP CONSTRAINT passengers_pkey;
       public            postgres    false    215            �           2606    19145     routesshedule routesshedule_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.routesshedule
    ADD CONSTRAINT routesshedule_pkey PRIMARY KEY (routeid);
 J   ALTER TABLE ONLY public.routesshedule DROP CONSTRAINT routesshedule_pkey;
       public            postgres    false    225            �           2606    19138    stations stations_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY public.stations
    ADD CONSTRAINT stations_pkey PRIMARY KEY (stationid);
 @   ALTER TABLE ONLY public.stations DROP CONSTRAINT stations_pkey;
       public            postgres    false    223            �           2606    19124    tarrif tarrif_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.tarrif
    ADD CONSTRAINT tarrif_pkey PRIMARY KEY (tarrifid);
 <   ALTER TABLE ONLY public.tarrif DROP CONSTRAINT tarrif_pkey;
       public            postgres    false    219            �           2606    19152    tickets tickets_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (ticketid);
 >   ALTER TABLE ONLY public.tickets DROP CONSTRAINT tickets_pkey;
       public            postgres    false    227            �           2606    19115    trains trains_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public.trains
    ADD CONSTRAINT trains_pkey PRIMARY KEY (trainid);
 <   ALTER TABLE ONLY public.trains DROP CONSTRAINT trains_pkey;
       public            postgres    false    217            �           2606    19159    carriages uq_carriagenumber 
   CONSTRAINT     `   ALTER TABLE ONLY public.carriages
    ADD CONSTRAINT uq_carriagenumber UNIQUE (carriagenumber);
 E   ALTER TABLE ONLY public.carriages DROP CONSTRAINT uq_carriagenumber;
       public            postgres    false    221            �           2606    19200    passengers uq_passport 
   CONSTRAINT     U   ALTER TABLE ONLY public.passengers
    ADD CONSTRAINT uq_passport UNIQUE (passport);
 @   ALTER TABLE ONLY public.passengers DROP CONSTRAINT uq_passport;
       public            postgres    false    215            �           2606    19198    routesshedule uq_routenumber 
   CONSTRAINT     ^   ALTER TABLE ONLY public.routesshedule
    ADD CONSTRAINT uq_routenumber UNIQUE (routenumber);
 F   ALTER TABLE ONLY public.routesshedule DROP CONSTRAINT uq_routenumber;
       public            postgres    false    225            �           2606    19204    stations uq_stationname 
   CONSTRAINT     Y   ALTER TABLE ONLY public.stations
    ADD CONSTRAINT uq_stationname UNIQUE (stationname);
 A   ALTER TABLE ONLY public.stations DROP CONSTRAINT uq_stationname;
       public            postgres    false    223            �           2606    19202    trains uq_trainname 
   CONSTRAINT     S   ALTER TABLE ONLY public.trains
    ADD CONSTRAINT uq_trainname UNIQUE (trainname);
 =   ALTER TABLE ONLY public.trains DROP CONSTRAINT uq_trainname;
       public            postgres    false    217            �           1259    19236    idx_reservedtime    INDEX     N   CREATE INDEX idx_reservedtime ON public.tickets USING brin (reservationdate);
 $   DROP INDEX public.idx_reservedtime;
       public            postgres    false    227            �           1259    19237    idx_routesshedule    INDEX     N   CREATE INDEX idx_routesshedule ON public.routesshedule USING btree (routeid);
 %   DROP INDEX public.idx_routesshedule;
       public            postgres    false    225            �           1259    19235    idx_stations    INDEX     G   CREATE INDEX idx_stations ON public.stations USING hash (stationname);
     DROP INDEX public.idx_stations;
       public            postgres    false    223            z           2618    19284    mainshedule delete_mainshedule    RULE     �   CREATE RULE delete_mainshedule AS
    ON DELETE TO public.mainshedule DO INSTEAD  SELECT public.mainshedule_deleter(old.*) AS mainshedule_deleter;
 4   DROP RULE delete_mainshedule ON public.mainshedule;
       public          postgres    false    228    228    228    269            y           2618    19283    mainshedule insert_mainshedule    RULE     �   CREATE RULE insert_mainshedule AS
    ON INSERT TO public.mainshedule DO INSTEAD  SELECT public.mainshedule_inserter(new.*) AS mainshedule_inserter;
 4   DROP RULE insert_mainshedule ON public.mainshedule;
       public          postgres    false    228    228    268    228            x           2618    19282    mainshedule update_mainshedule    RULE     �   CREATE RULE update_mainshedule AS
    ON UPDATE TO public.mainshedule DO INSTEAD  SELECT public.mainshedule_updater(old.*, new.*) AS mainshedule_updater;
 4   DROP RULE update_mainshedule ON public.mainshedule;
       public          postgres    false    228    228    228    261            �           2620    19287    tickets triggerdelete_tickets    TRIGGER        CREATE TRIGGER triggerdelete_tickets AFTER DELETE ON public.tickets FOR EACH ROW EXECUTE FUNCTION public.checkticketsdelete();
 6   DROP TRIGGER triggerdelete_tickets ON public.tickets;
       public          postgres    false    227    277            �           2620    19285    tickets triggerinsert_tickets    TRIGGER        CREATE TRIGGER triggerinsert_tickets AFTER INSERT ON public.tickets FOR EACH ROW EXECUTE FUNCTION public.checkticketsinsert();
 6   DROP TRIGGER triggerinsert_tickets ON public.tickets;
       public          postgres    false    227    275            �           2620    19286    tickets triggerupdate_tickets    TRIGGER        CREATE TRIGGER triggerupdate_tickets AFTER UPDATE ON public.tickets FOR EACH ROW EXECUTE FUNCTION public.checkticketsupdate();
 6   DROP TRIGGER triggerupdate_tickets ON public.tickets;
       public          postgres    false    227    276            �           2606    19153    carriages fk_carriages_trains    FK CONSTRAINT     �   ALTER TABLE ONLY public.carriages
    ADD CONSTRAINT fk_carriages_trains FOREIGN KEY (train) REFERENCES public.trains(trainid);
 G   ALTER TABLE ONLY public.carriages DROP CONSTRAINT fk_carriages_trains;
       public          postgres    false    221    3271    217            �           2606    19192 /   routesshedule fk_routesshedule_arrival_stations    FK CONSTRAINT     �   ALTER TABLE ONLY public.routesshedule
    ADD CONSTRAINT fk_routesshedule_arrival_stations FOREIGN KEY (arrivalstation) REFERENCES public.stations(stationid);
 Y   ALTER TABLE ONLY public.routesshedule DROP CONSTRAINT fk_routesshedule_arrival_stations;
       public          postgres    false    225    3282    223            �           2606    19187 1   routesshedule fk_routesshedule_departure_stations    FK CONSTRAINT     �   ALTER TABLE ONLY public.routesshedule
    ADD CONSTRAINT fk_routesshedule_departure_stations FOREIGN KEY (departurestation) REFERENCES public.stations(stationid);
 [   ALTER TABLE ONLY public.routesshedule DROP CONSTRAINT fk_routesshedule_departure_stations;
       public          postgres    false    3282    223    225            �           2606    19182 %   routesshedule fk_routesshedule_trains    FK CONSTRAINT     �   ALTER TABLE ONLY public.routesshedule
    ADD CONSTRAINT fk_routesshedule_trains FOREIGN KEY (train) REFERENCES public.trains(trainid);
 O   ALTER TABLE ONLY public.routesshedule DROP CONSTRAINT fk_routesshedule_trains;
       public          postgres    false    225    3271    217            �           2606    19170    tickets fk_tickets_carriages    FK CONSTRAINT     �   ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_tickets_carriages FOREIGN KEY (carriage) REFERENCES public.carriages(carriageid);
 F   ALTER TABLE ONLY public.tickets DROP CONSTRAINT fk_tickets_carriages;
       public          postgres    false    221    227    3277            �           2606    19160    tickets fk_tickets_passengers    FK CONSTRAINT     �   ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_tickets_passengers FOREIGN KEY (passenger) REFERENCES public.passengers(passengerid);
 G   ALTER TABLE ONLY public.tickets DROP CONSTRAINT fk_tickets_passengers;
       public          postgres    false    215    227    3267            �           2606    19175     tickets fk_tickets_routesshedule    FK CONSTRAINT     �   ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_tickets_routesshedule FOREIGN KEY (route) REFERENCES public.routesshedule(routeid);
 J   ALTER TABLE ONLY public.tickets DROP CONSTRAINT fk_tickets_routesshedule;
       public          postgres    false    3287    225    227            �           2606    19165    tickets fk_tickets_tarrif    FK CONSTRAINT     ~   ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_tickets_tarrif FOREIGN KEY (tarrif) REFERENCES public.tarrif(tarrifid);
 C   ALTER TABLE ONLY public.tickets DROP CONSTRAINT fk_tickets_tarrif;
       public          postgres    false    3275    219    227            �   <   x�3�tv
2�4�44b�.��	DĀ�(d2�4�44���E�@j@�b���� '��      |   �   x�m�;�0D��]@����R@AAJ��h��H�C8��F��F ��wgތ�j�h��h܆������-yW��Ǥt�f��l.IK)GR��K;Y��y�g��-,�z�5��(�ߧm�`Oh2tt� ���c@J8�������o<P~LIl�ܹ�:�>9G�a6�~�����Hc�b,�x���      �   d   x�}���0Ck�,@d_ @:��� ~��g=۱
!��l����5�7f�,���/���&,*�z(A�ljņ�9�؅�k��2��[u��f[0�I(A      �   {   x�-��	�@EϳU�!���X���ыx��l��5���#����������x���ƕ��"��n���DE]/1��x��2yj�3z�Dz?i�����z��ZS��qQÇ���R���LwQ�      �   �   x�]α�@�ڞ�@�KB`j&` �����Db�tp��f�ވDst����+�Ѷ�툗l�
!��n\��g2��u�SB����ꀤ���5� �[KU���J�dmWv"��c�y�X�I�n��g���%m]yU� \~z�      �   @   x�3�4�4bNcN#C]C �2�AcNKs3Sc3��L��5ii3D������ 2�      ~      x�3�	r4�2QF\�`��W� UoP     