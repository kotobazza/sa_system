-- Active: 1677943579599@@127.0.0.1@5432@Kursach

--! <подзапрос WHERE> 
--! <подзапрос SELECT>
--! <подзапрос FROM>

-- ! ACCESS FUNCTIONS (INSERT, UPDATE, DELETE)

--? значение -1 в результатах функции означает логическую ошибку при введении данных, 

--? ошибки с данными, не найденными в базе данных, появляются благодаря ограничениям,
--? 		и функции, в таком случае, ничего не возвращают (появляется ошибка обработки запроса)



--* addPassenger (passport, birthDate, FIO)

CREATE OR REPLACE FUNCTION addPassenger(
	_passport VARCHAR(10),
	_birthDate DATE,
	_firstName VARCHAR(30), 
	_lastName VARCHAR(30), 
	_middleName VARCHAR(30) DEFAULT NULL,
	OUT result INTEGER) AS
	$$ 	
	BEGIN
		INSERT INTO passengers(firstName, lastName, middleName, passport, birthDate)
				VALUES (_firstName, _lastName, _middleName, _passport, _birthDate)
				RETURNING passengerId INTO result;			
	END;
	$$ LANGUAGE plpgsql;


--* addTrain (trainName)
CREATE OR REPLACE FUNCTION addTrain(
	_trainName VARCHAR(30), 
	OUT result INTEGER)
	AS
	$$
	BEGIN 
		INSERT INTO trains(trainName)
			VALUES (_trainName)
			RETURNING trainId INTO result;
	END;
	$$ LANGUAGE plpgsql;


--* addTarrif (tarrifName, tarrifCost, canAnimnals, tarrifDesc)
CREATE OR REPlACE FUNCTION addTarrif(
	_tarrifName VARCHAR(30),
	_animals BOOLEAN,
	_tarrifCost INTEGER,
	_tarrifDesc TEXT DEFAULT NULL, 
	OUT result INTEGER)
	AS
	$$
	BEGIN 
		INSERT INTO tarrif(tarrifName, tarrifCost, tarrifDesc, tarrifAnimals)
			VALUES (_tarrifName, _tarrifCost, _tarrifDesc, _animals)
			RETURNING tarrifId INTO result;
	END;
	$$ LANGUAGE plpgsql;


--* addStation (stationName, stationState)
CREATE OR REPLACE FUNCTION addStation(
	_stationName VARCHAR(30), 
	_stationState BOOLEAN, 
	OUT result INTEGER)
	AS
	$$
	BEGIN 
		INSERT INTO stations(stationName, stationState)
			VALUES (_stationName, _stationState)
			RETURNING stationId INTO result;
	END;
	$$ LANGUAGE plpgsql;



--* addCarriage(trainName, totalSeats, reservedSeats, carraigeState)


CREATE OR REPLACE FUNCTION addCarriage(
	_trainName VARCHAR(30), 
	_totalSeats INTEGER, 
	_reservedSeats INTEGER,
	_carriageState BOOLEAN,
	OUT result INTEGER)
	AS
	$$
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
	$$ LANGUAGE plpgsql;


--* addRoute (routeNumber, departureStationName, arrivalStationName, trainName, departureTime, arrivalTime)
CREATE OR REPLACE FUNCTION addRoute(
	_routeNumber VARCHAR(10),
	_departureStation VARCHAR(30), 
	_departureTime TIMESTAMP,
	_arrivalStation VARCHAR(30),
	_arrivalTime TIMESTAMP,
	_trainName VARCHAR(30),
	OUT result INTEGER)
	AS
	$$
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
	$$ LANGUAGE plpgsql;


--* addTicket (passport, routeNumber,  tarrifName, carriageNumber, reservationDate)
CREATE OR REPLACE FUNCTION addTicket(
	_passport VARCHAR(10), 
	_routeNumber VARCHAR(10), 
	_tarrifName VARCHAR(30), 
	_carriageNumber VARCHAR(10), 
	_reservationDate DATE,
	OUT result INTEGER) AS  
	$$
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
	$$ LANGUAGE plpgsql;





--* updatePassenger(oldPassportId, newPassport, newBirthDate newFIO)
CREATE OR REPLACE FUNCTION updatePassenger(
	_id INTEGER,
	newPassport VARCHAR(10),
	newBirthDate DATE,
	newFirstName VARCHAR(30),
	newLastName VARCHAR(30),
	newMiddleName VARCHAR(30) DEFAULT NULL,
	OUT result INTEGER)
	AS
	$$
	BEGIN
		UPDATE passengers SET passport = newPassport,
							birthDate = newBirthDate,
							firstName = newFirstName,
							lastName = newLastName,
							middleName = newMiddleName
			WHERE passengerId = _id
			RETURNING passengerId INTO result;
	END;
	$$ LANGUAGE plpgsql;


--* updateTrain(id, newTrainName)
CREATE OR REPLACE FUNCTION updateTrain(
	_id INTEGER,
	newTrainName VARCHAR(30), 
	OUT result INTEGER)
	AS
	$$
	BEGIN 
		UPDATE trains SET trainName = newTrainName			
			WHERE trainId = _id
			RETURNING trainId INTO result;
	END;
	$$ LANGUAGE plpgsql;


--* updateTarrif(id, newTarrifName, newCanAnimals, newTarrifCost, newTarrifDesc)
CREATE OR REPlACE FUNCTION updateTarrif(
	_id INTEGER,
	newTarrifName VARCHAR(30), 
	newCanAnimals BOOLEAN,
	newTarrifCost INTEGER, 
	newTarrifDesc TEXT DEFAULT NULL, 
	OUT result INTEGER)
	AS
	$$
	BEGIN 
		UPDATE tarrif SET tarrifName = newTarrifName,
						tarrifCost = newTarrifCost,
						tarrifAnimals = newCanAnimals,
						tarrifDesc = newTarrifDesc  
			WHERE tarrifId = _id
			RETURNING tarrifId INTO result;
	END;
	$$ LANGUAGE plpgsql;


--* updateStation(id, newStationName, newStationState)
CREATE OR REPLACE FUNCTION updateStation(
	_id INTEGER,
	newStationName VARCHAR(30), 
	newStationState BOOLEAN, 
	OUT result INTEGER)
	AS
	$$
	BEGIN 
		UPDATE stations SET stationName = newStationName,
							stationState = newStationState
			WHERE stationId = _id
			RETURNING stationId INTO result;
	END;
	$$ LANGUAGE plpgsql;



--* updateCarriage(id, newCarrigeNumber, newTrainName, newTotalSeats, newReservedSeats, newState)
CREATE OR REPLACE FUNCTION updateCarriage(
	_id INTEGER,
	newCarriageNumber VARCHAR(10),
	newTrainName VARCHAR(30), 
	newTotalSeats INTEGER, 
	newReservedSeats INTEGER, 
	newState BOOLEAN,
	OUT result INTEGER)
	AS
	$$
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
	$$ LANGUAGE plpgsql;


--* updateRoute (id, newRouteNumber, newDepartureStation, newArrivalStation, newTrain, newDepartureTime, newArrivalTime)
CREATE OR REPLACE FUNCTION updateRoute(
	_id INTEGER,
	newRouteNumber VARCHAR(10),
	newDepartureStation VARCHAR(30),
	newDepartureTime TIMESTAMP,
	newArrivalStation VARCHAR(30),
	newArrivalTime TIMESTAMP,
	newTrain VARCHAR(30),
	OUT result INTEGER)
	AS
	$$
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
	$$ LANGUAGE plpgsql;



--* updateTicket (id, newPassport, newRouteNumber, newTarrifName, newCarriageNumber, newReservationDate)
CREATE OR REPLACE FUNCTION updateTicket(
		_id INTEGER,
		newPassport VARCHAR(10),
		newRouteNumber VARCHAR(10),
		newTarrifName VARCHAR(10),
		newCarriageNumber VARCHAR(10),
		newReservationDate DATE,
		OUT result INTEGER)
	AS
	$$
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
	$$ LANGUAGE plpgsql;


--* deleteTicket(id)
CREATE OR REPLACE FUNCTION deleteTicket(_id INTEGER, OUT result INTEGER) AS
	$$
	BEGIN
		DELETE FROM tickets WHERE ticketId = _id
			RETURNING ticketId INTO result;
		IF result IS NULL THEN
			result = -1;
		END IF;
	END;
	$$ LANGUAGE plpgsql;


--* deleteRoute(id)
CREATE OR REPLACE FUNCTION deleteRoute(_id INTEGER, OUT result INTEGER) AS
	$$
	BEGIN
		DELETE FROM routesShedule WHERE routeId = _id 
			RETURNING routeId INTO result;
		IF result IS NULL THEN
			result = -1;
		END IF;
	END;
	$$ LANGUAGE plpgsql;


--* deleteCarriage(id)
CREATE OR REPLACE FUNCTION deleteCarriage(_id INTEGER, OUT result INTEGER) AS
	$$
	BEGIN
		DELETE FROM carriages WHERE carriageId = _id
			RETURNING carriageId INTO result;
		IF result IS NULL THEN
			result = -1;
		END IF;
	END;
	$$ LANGUAGE plpgsql;


--* deletePassenger(id)
CREATE OR REPLACE FUNCTION deletePassenger(_id INTEGER, OUT result INTEGER) AS
	$$
	BEGIN
		DELETE FROM passengers CASCADE WHERE passengerId = _id 
			RETURNING passengerId INTO result;
		IF result IS NULL THEN
			result = -1;
		END IF;
	END;
	$$ LANGUAGE plpgsql;



--* deleteStation(id)
CREATE OR REPLACE FUNCTION deleteStation(_id INTEGER, OUT result INTEGER) AS
	$$
	BEGIN
		DELETE FROM stations WHERE stationId = _id
			RETURNING stationId INTO result;
		IF result IS NULL THEN
			result = -1;
		END IF;
	END;
	$$ LANGUAGE plpgsql;


--* deleteTrain(id)
CREATE OR REPLACE FUNCTION deleteTrain(_id INTEGER, OUT result INTEGER) AS
	$$
	BEGIN
		DELETE FROM trains WHERE trainId = _id
			RETURNING trainId INTO result;
		IF result IS NULL THEN
			result = -1;
		END IF;
	END;
	$$ LANGUAGE plpgsql;


--* deleteTarrif(id)
CREATE OR REPLACE FUNCTION deleteTarrif(_id INTEGER, OUT result INTEGER)AS
	$$
	BEGIN
		DELETE FROM tarrif WHERE tarrifId = _id
			RETURNING tarrifId INTO result;
		IF result IS NULL THEN
			result = -1;
		END IF;
	END;
	$$ LANGUAGE plpgsql;





--!  VIEW_mainShedule rules
CREATE OR REPLACE FUNCTION mainShedule_updater(oldTable mainShedule, newTable mainShedule) RETURNS VOID 
	AS
	$$
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
	$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION mainShedule_inserter(newTable mainShedule) RETURNS VOID 
	AS
	$$
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
	$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION mainShedule_deleter(oldTable mainShedule) RETURNS VOID 
	AS
	$$
	BEGIN
		DELETE FROM routesShedule WHERE routesShedule.FLIGHT_№ = oldTable.FLIGHT_№;
	END;
	$$ LANGUAGE plpgsql;




--! коррелированный запрос 
CREATE OR REPLACE FUNCTION getEmptyCarriages()
	RETURNS TABLE (
		trainName VARCHAR(30),
		carriageNumber VARCHAR(10),
		reservedSeats INTEGER,
		totalSeats INTEGER,
		difference INTEGER
	) AS
	$$
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
	$$ LANGUAGE plpgsql;




--* carriageNumberDeterminant(carriageId) -> carriageNumber
CREATE OR REPLACE FUNCTION carriageNumberDeterminant(carriageId INTEGER)
	RETURNS VARCHAR(10)
	AS
	$$
	BEGIN
		RETURN CONCAT('CARR', carriageId);
	END;
	$$ LANGUAGE plpgsql;




--! коррелированный подзапрос
CREATE OR REPLACE FUNCTION getAverageTicketCost()
	RETURNS TABLE(
		passenger VARCHAR(10),
		FLIGHT_№ VARCHAR(10),
		carriage VARCHAR(10),
		reservationDate DATE,
		tarrifCost INTEGER,
		totalCost INTEGER,
		averageCost NUMERIC
	)
	AS
	$$
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
	$$ LANGUAGE plpgsql;






--! подзапрос в SELECT <подзапрос SELECT>
CREATE OR REPLACE FUNCTION averageTarrifCost()
	RETURNS TABLE(
		tarrifName VARCHAR(10),
		tarrifCost INTEGER,
		avgCost INTEGER
	)
	AS
	$$
	BEGIN
		RETURN QUERY 
			SELECT 
				tarrifName,
				tarrifCost,
				(SELECT AVG(tarrifCost) FROM tarrif) AS avgCost
			FROM tarrif;
	END;
	$$ LANGUAGE plpgsql;



--! подзапрос в FROM <подзапрос FROM>
CREATE OR REPLACE FUNCTION getActiveServices()
	RETURNS TABLE (
		FLIGHT_№ VARCHAR(10),
		DEPARTURE_STATION VARCHAR(30),
		DEPARTURE_TIME TIMESTAMP,
		ARRIVAL_STATION VARCHAR(30),
		ARRIVAL_TIME TIMESTAMP
	) AS
	$$
		BEGIN
			RETURN QUERY SELECT 
				activeF.FLIGHT_№,
				activeF.DEPRATURE_STATION,
				activeF.DEPARTURE_TIME,
				activeF.ARRIVAL_STATION,
				activeF.ARRIVAL_TIME
			FROM (SELECT * FROM availableRoutes WHERE state = 'Активный') AS activeF;
		END;
	$$ LANGUAGE plpgsql;

	

--! функции триггеров
CREATE OR REPLACE FUNCTION checkTicketsInsert() --* выполняется после успешной вставки в tickets
	RETURNS TRIGGER 
	AS 
	$$
		BEGIN
			UPDATE carriages SET
					reservedSeats = reservedSeats + 1,
					carriageState = (totalSeats > reservedSeats) AND carriageState
				WHERE carriageId = NEW.carriage;
			RETURN NEW;
		END;
	$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION checkTicketsUpdate() --* выполняется после успешной вставки в tickets
	RETURNS TRIGGER
	AS
	$$
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
	$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION checkTicketsDelete() --* выполняется после успешной вставки в tickets
	RETURNS TRIGGER
	AS
	$$

		BEGIN
			UPDATE carriages SET
					reservedSeats = reservedSeats - 1,
					carriageState = (totalSeats > reservedSeats) AND carriageState
				WHERE carriageId = OLD.carriage;
			RETURN OLD;
		END;
	$$ LANGUAGE plpgsql;



--! HAVING
CREATE OR REPLACE FUNCTION ticketsTypes(_canAnimals BOOLEAN, _moreThan INTEGER)
	RETURNS TABLE(
		passengerPassport VARCHAR(10),
		tarrifName VARCHAR(30),
		routeNumber VARCHAR(30),
		canAnimals BOOLEAN,
		reservedCount BIGINT,
		moreThan INTEGER
	)
	AS
	$$
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
	$$ LANGUAGE plpgsql;


--! коррелированный поздапрос 3
CREATE OR REPLACE FUNCTION getCountOfTicketsForEachPassenger()
	RETURNS TABLE(
		passport VARCHAR(10),
		firstName VARCHAR(30),
		lastName VARCHAR(30),
		middleName VARCHAR(30),
		numberOfTickets BIGINT
	)
	AS
	$$
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
	$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION birthdayDateAndCost(reservDate DATE, birthDate DATE, _tarrif INTEGER, OUT result INTEGER) AS
	$$
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
	$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION selectFromTickets()
	RETURNS TABLE(
			ticketId INTEGER,
			passport VARCHAR(10),
			routeNumber VARCHAR(10),
			tarrifName VARCHAR(30),
			totalCost INTEGER,
			carriageNumber VARCHAR(10),
			reservationDate DATE
		)
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
	$$LANGUAGE plpgsql;






CREATE OR REPLACE FUNCTION selectFromCarriages()
	RETURNS TABLE(
		carraigeId INTEGER,
		carriageNumber VARCHAR(10),
		train VARCHAR(10),
		totalSeats INTEGER,
		reservedSeats INTEGER,
		carriageState BOOLEAN
	) AS $$
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
	$$ LANGUAGE plpgsql;





CREATE OR REPLACE FUNCTION selectFromRoutesShedule()
	RETURNS TABLE(
		routeId INTEGER,
		routeNumber VARCHAR(10),
		departureStation VARCHAR(30),
		departureTime TIMESTAMP,
		arrivalStation VARCHAR(30),
		arrivalTime TIMESTAMP,
		train VARCHAR(10)
	)
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
		$$LANGUAGE plpgsql;




--! ANY
CREATE OR REPLACE FUNCTION getIncompleteTrains()
	RETURNS TABLE(
		trainName VARCHAR(10),
		incompleteCarriages BIGINT,
		totalCarriages BIGINT
	) AS
	$$
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
	$$ LANGUAGE plpgsql;




--! Transaction 
drop function transactionCaller;
CREATE OR REPLACE FUNCTION transactionCaller(_routeNumber VARCHAR(10), _departureStation VARCHAR(30), _arrivalStation VARCHAR(30), _trainName VARCHAR(30),
										_departureTime TIMESTAMP, _arrivalTime TIMESTAMP, OUT res INTEGER)
	AS
	$$
	BEGIN
		res = 0;
		CALL createRoute(_routeNumber, _departureStation, _arrivalStation, _trainName, _departureTime, _arrivalTime);
		EXCEPTION
			WHEN OTHERS 
			THEN 
				res = -2; 
	END;
	$$ LANGUAGE plpgsql;




CREATE OR REPLACE PROCEDURE createRoute(_routeNumber VARCHAR(10), _departureStation VARCHAR(30), _arrivalStation VARCHAR(30), _trainName VARCHAR(30),
										_departureTime TIMESTAMP, _arrivalTime TIMESTAMP)
	AS
	$$
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
					RAISE EXCEPTION '1error1: existing ojbects';
				ELSE 
				
				INSERT INTO trains(trainName) VALUES (_trainName)
					RETURNING trainId INTO _trainId;
				INSERT INTO stations(stationName, stationState) VALUES (_departureStation, TRUE)
					RETURNING stationId INTO _depStationId;
				INSERT INTO stations(stationName, stationState) VALUES (_arrivalStation, TRUE)
					RETURNING stationId INTO _arrStationId;

					IF(_arrivalTime < _departureTime) THEN 
						RAISE EXCEPTION '2error2: logic error in time management';
					ELSE
						INSERT INTO routesShedule(routeNumber, departureStation, arrivalStation, train, departureTime, arrivalTime)
							VALUES(_routeNumber, _depStationId, _arrStationId, _trainId, _departureTime, _arrivalTime);
				
				END IF;
				END IF;

			EXCEPTION
				WHEN OTHERS THEN 
					RAISE NOTICE '%', SQLERRM;
					ROLLBACK;
					return;
				END;
			COMMIT;
	END;
	$$ 
	LANGUAGE plpgsql;





--! Cursor 
CREATE OR REPLACE FUNCTION indexingTicketsCost(percent INTEGER)
	RETURNS TABLE(
			ticketId INTEGER,
			passport VARCHAR(10),
			routeNumber VARCHAR(10),
			tarrifName VARCHAR(30),
			totalCost INTEGER,
			carriageNumber VARCHAR(10),
			reservationDate DATE
		)
	AS
	$$
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
	$$ LANGUAGE plpgsql;





CREATE OR REPLACE FUNCTION superCost()
	RETURNS TABLE(
		passport VARCHAR(10),
		firstName VARCHAR(30),
		lastName VARCHAR(30),
		middleName VARCHAR(30),
		totalCost INTEGER,
		maxTarrifCost INTEGEr
	)
	AS
	$$
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
	$$ LANGUAGE plpgsql;





CREATE OR REPLACE FUNCTION addToMainShedule(
		routeNumber VARCHAR(10),
		depStation VARCHAR(30),
		depTime TIMESTAMP,
		arrStation VARCHAR(30),
		arrTime TIMESTAMP,
		trainName VARCHAR(10)
	) RETURNS VOID AS
	$$
	BEGIN
		INSERT INTO mainShedule(FLIGHT_№, DEPRATURE_STATION, DEPARTURE_TIME, ARRIVAL_STATION, ARRIVAL_TIME, TRAIN) VALUES(
			FLIGHT_№ = routeNumber,
			DEPRATURE_STATION = depStation,
			DEPARTURE_TIME = depTime,
			ARRIVAL_STATION = arrStation,
			ARRIVAL_TIME = arrTime,
			TRAIN = trainName);
	END;
	$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION updateMainShedule(
		_oldRoute VARCHAR(10),
		routeNumber VARCHAR(10),
		depStation VARCHAR(30),
		depTime TIMESTAMP,
		arrStation VARCHAR(30),
		arrTime TIMESTAMP,
		trainName VARCHAR(10)
	) RETURNS VOID AS
	$$
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
	$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION deleteFromMainShedule(
		_oldRoute VARCHAR(10)
	) RETURNS VOID AS
	$$
	BEGIN
		DELETE FROM mainShedule WHERE FLIGHT_№ = _oldRoute;
	END;
	$$ LANGUAGE plpgsql;



