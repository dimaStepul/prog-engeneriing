DROP FUNCTION IF EXISTS GenName() CASCADE;
DROP FUNCTION IF EXISTS GenSurname() CASCADE;
DROP FUNCTION IF EXISTS GenPatronymic() CASCADE;
DROP FUNCTION IF EXISTS GenTransportType() CASCADE;
DROP FUNCTION IF EXISTS GenCondition() CASCADE;
DROP FUNCTION IF EXISTS GenStopId() CASCADE;
DROP FUNCTION IF EXISTS GenDriverLicense() CASCADE;
DROP FUNCTION IF EXISTS GenDailyRouteId() CASCADE;
DROP FUNCTION IF EXISTS GenTransportId() CASCADE;
DROP FUNCTION IF EXISTS GenRouteId() CASCADE;
DROP FUNCTION IF EXISTS GenTicketId() CASCADE;
DROP FUNCTION IF EXISTS GetPlatformCount(INT) CASCADE;

DROP TYPE IF EXISTS Condition CASCADE;
DROP TYPE IF EXISTS Vehicle CASCADE;
DROP TABLE IF EXISTS Model CASCADE;
DROP TABLE IF EXISTS Transport CASCADE;
DROP TABLE IF EXISTS Stop CASCADE;
DROP TABLE IF EXISTS Route CASCADE;
DROP TABLE IF EXISTS Timetable CASCADE;
DROP TABLE IF EXISTS Driver CASCADE;
DROP TABLE IF EXISTS Logbook CASCADE;
DROP TABLE IF EXISTS Ticket CASCADE;
DROP TABLE IF EXISTS DailyRoute CASCADE;
DROP TABLE IF EXISTS Booking CASCADE;
DROP TABLE IF EXISTS Backend CASCADE;
DROP TABLE IF EXISTS AppUser CASCADE;
DROP TABLE IF EXISTS FeedBack CASCADE;
DROP TABLE IF EXISTS POIType CASCADE;
DROP TABLE IF EXISTS POI CASCADE;
DROP TABLE IF EXISTS POIPath CASCADE;
DROP TABLE IF EXISTS POIPathStats CASCADE;

-- Значения состояния транспорта
CREATE TYPE Condition AS ENUM ('Требует ремонта', 'Некритические неисправности', 'Исправен');

-- Типы ТС
CREATE TYPE Vehicle AS ENUM ('Автобус', 'Троллейбус', 'Трамвай', 'ТУАХ', 'Электробус');

-- Модель ТС
CREATE TABLE Model
(
    id       SERIAL PRIMARY KEY,
    type     Vehicle NOT NULL,
    name     TEXT    NOT NULL,
    capacity INT     NOT NULL CHECK ( capacity > 0 )
);

-- Транспортное средство
CREATE TABLE Transport
(
    id        INT PRIMARY KEY,
    year      INT       CHECK ( year > 0 ),
    condition Condition NOT NULL,
    model_id  INT       NOT NULL REFERENCES Model (id)
);

-- Остановка ОТ
CREATE TABLE Stop
(
    id             INT PRIMARY KEY,
    address        TEXT NOT NULL,
    platform_count INT  NOT NULL CHECK ( platform_count > 0 ),

    UNIQUE(address)
);

-- Маршрут ТС
CREATE TABLE Route
(
    id             INT PRIMARY KEY,
    transport_type Vehicle NOT NULL,
    first_stop_id  INT     NOT NULL REFERENCES Stop (id),
    last_stop_id   INT     NOT NULL REFERENCES Stop (id)
);

CREATE FUNCTION GetPlatformCount (field INT) RETURNS INT AS
$$
    SELECT platform_count FROM Stop WHERE id = field
$$ LANGUAGE SQL;

-- Расписание
CREATE TABLE Timetable
(
    id           SERIAL PRIMARY KEY,
    route_id     INT     NOT NULL REFERENCES Route (id),
    stop_id      INT     NOT NULL REFERENCES Stop (id),
    platform     INT     NOT NULL,
    arrival_time TIME    NOT NULL,
    weekend      BOOLEAN NOT NULL,

    UNIQUE (stop_id, route_id, arrival_time, platform, weekend),
    CHECK ( platform > 0 AND platform <= GetPlatformCount(stop_id) )
);

-- Водители
CREATE TABLE Driver
(
    licence    INT PRIMARY KEY,
    name       TEXT NOT NULL,
    surname    TEXT NOT NULL,
    patronymic TEXT
);

-- Наряды на работу
CREATE TABLE DailyRoute
(
    id             SERIAL PRIMARY KEY,
    day            DATE NOT NULL,
    transport_id   INT  NOT NULL REFERENCES Transport (id),
    route_id       INT  NOT NULL REFERENCES Route (id),
    departure_time TIME NOT NULL,
    driver_licence INT  NOT NULL REFERENCES Driver (licence),

    UNIQUE (day, driver_licence),
    UNIQUE (day, transport_id)
);

-- Логи записи с gps
CREATE TABLE Logbook
(
    daily_route_id    INT  NOT NULL REFERENCES DailyRoute (id),
    stop_id      INT  NOT NULL REFERENCES Stop (id),
    arrival_time TIME NOT NULL,

    UNIQUE (daily_route_id, arrival_time)
);

-- Билетное меню
CREATE TABLE Ticket
(
    id   SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    cost INT  NOT NULL CHECK ( cost > 0 ),

    UNIQUE(name, cost)
);

-- Продажи билетов на маршрут (наряд)
CREATE TABLE Booking
(
    id                     SERIAL PRIMARY KEY,
    ticket_id              INT  NOT NULL REFERENCES Ticket (id),
    daily_route_id         INT  NOT NULL REFERENCES DailyRoute (id),
    daily_validation_count INT NOT NULL,

    UNIQUE(daily_route_id, ticket_id)
);

-- Бэкенды для анализа
CREATE TABLE Backend
(
    id          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL,
    description TEXT NOT NULL
    
);

-- Пользователи приложения
CREATE TABLE AppUser
(
    id                    BYTEA PRIMARY KEY,
    datetime_registration TIMESTAMP NOT NULL,
    app_version           TEXT NOT NULL
);

-- Фидбэк по маршрутам
CREATE TABLE FeedBack
(
    id                SERIAL PRIMARY KEY,
    user_id           BYTEA NOT NULL REFERENCES AppUser (id),
    stop_id           INT REFERENCES Stop (id),
    route_id          INT REFERENCES Route (id),
    backend_id        INT NOT NULL REFERENCES Backend (id),
    features_map      JSONB NOT NULL,
    datetime_feedback TIMESTAMP NOT NULL,
    
    CONSTRAINT chk_target CHECK (stop_id IS NOT NULL OR route_id IS NOT NULL)
);

-- Тип достопримечательности
CREATE TABLE POIType 
(
    type TEXT PRIMARY KEY
);

-- Достопримечательности
CREATE TABLE POI
(
    name TEXT PRIMARY KEY,
    photo_url TEXT,
    poi_type TEXT NOT NULL REFERENCES POIType,
    address TEXT NOT NULL
);

-- Пути от остановок к достопримечательностям
CREATE TABLE POIPath 
(
    id SERIAL PRIMARY KEY,
    poi_name TEXT NOT NULL REFERENCES POI,
    stop_id INT NOT NULL REFERENCES Stop,
    route_time INT NOT NULL,
    has_obstacles BOOLEAN NOT NULL,
    road_crosses INT NOT NULL,

    UNIQUE(poi_name, stop_id)
);

-- Статистика для маршрутов к достопримечательностям
CREATE TABLE POIPathStats 
(
    id SERIAL PRIMARY KEY,
    poi_path_id INT NOT NULL REFERENCES POIPath,
    date DATE NOT NULL,
    use_count INT NOT NULL,

    UNIQUE(poi_path_id, date)
);

CREATE FUNCTION GenName() RETURNS TEXT AS
$$
SELECT (array ['Михаил', 'Константин', 'Виктор', 'Геннадий', 'Акакий', 'Юрий', 'Андрей', 'Максим'])[floor(random() * 8 + 1)];
$$ LANGUAGE SQL;

CREATE FUNCTION GenSurname() RETURNS TEXT AS
$$
SELECT (array ['Иванов', 'Пупкин', 'Васечкин', 'Попов', 'Петров', 'Козлов', 'Куликов', 'Алексеев'])[floor(random() * 8 + 1)];
$$ LANGUAGE SQL;

CREATE FUNCTION GenPatronymic() RETURNS TEXT AS
$$
SELECT (array ['Михаилович', 'Константинович', 'Викторович', 'Иванович', 'Алексеевич', 'Юрьевич', 'Андреевич', 'Анатольевич'])[floor(random() * 8 + 1)];
$$ LANGUAGE SQL;

CREATE FUNCTION GenTransportType() RETURNS Vehicle AS
$$
SELECT result FROM unnest(enum_range(NULL::Vehicle)) result ORDER BY random() LIMIT 1;
$$ LANGUAGE SQL;

CREATE FUNCTION GenCondition() RETURNS Condition AS
$$
SELECT result FROM unnest(enum_range(NULL::Condition)) result ORDER BY random() LIMIT 1;
$$ LANGUAGE SQL;

CREATE FUNCTION GenStopId() RETURNS INT AS
$$
SELECT id FROM Stop order by random() LIMIT 1
$$ LANGUAGE SQL;

WITH IDX as (SELECT * FROM generate_series(1, 30))
INSERT
INTO Driver(licence, name, surname, patronymic)
SELECT ((random() + 1) * 1E5)::INT, GenName(), GenSurname(), GenPatronymic()
FROM IDX
ON CONFLICT DO NOTHING;

WITH Adress AS (
    SELECT unnest(ARRAY [
        'перекресток Блюхера и Полюстровского', 'Нежинская улица', 'Елецкая улица', 'Поклонная гора', 'пять углов', 'Боткинская улица',
        'станция метро Чкаловская', 'Большой пропект ПС 67', 'улица Ленина 44', 'Петропавловская улица', 'перекресток Медиков и проф. Попова',
        'Тучков мост', '1-я линия ВО', '6-я линия ВО', 'музей Эрарта','Дворцовая площадь','Тамбовская улица','Ашан','станция метро Обводный канал',
        'Кузнечный переулок','Херсонская д.2','Таврический сад','Смольный собор','цирк','автовокзал','Пискаревский проспект','Феодосийская улица'
        ]) AS address
)
INSERT
INTO Stop(id, address, platform_count)
SELECT ((random() + 1) * 1E2)::INT, address, floor(random() * 10 + 1)
FROM Adress
ON CONFLICT DO NOTHING;

INSERT INTO Model(type, name, capacity)
VALUES ('Автобус', 'ЛИАЗ', 50),
       ('Автобус', 'VolgaBus', 70),
       ('Автобус', 'НефАЗ', 40),
       ('Автобус', 'ПАЗ', 30),
       ('Автобус', 'МАЗ', 60),
       ('Автобус', 'Hyundai', 35),
       ('Автобус', 'Scania', 43),
       ('Автобус', 'Volvo', 20),
       ('Троллейбус', 'ТролЗА', 44),
       ('Троллейбус', 'ЛиАЗ', 53),
       ('Троллейбус', 'ЗиУ', 29),
       ('Трамвай', 'ВРТТЗ', 67),
       ('Трамвай', 'ПТМЗ', 59),
       ('Электробус', 'Tesla', 4),
       ('ТУАХ', 'ТролЗА', 44);


WITH Data as (SELECT * FROM generate_series(1, 50) as id)
INSERT
INTO Transport(id, year, condition, model_id)
SELECT Data.id, 2000 + random() * 20, GenCondition(), 1 + random() * (SELECT count(*) - 1 from model)
FROM Data
ON CONFLICT DO NOTHING;

WITH Data as (SELECT * FROM generate_series(1, 20) as id)
INSERT
INTO Route(id, transport_type, first_stop_id, last_stop_id)
SELECT Data.id, GenTransportType(), GenStopId(), GenStopId()
FROM Data
ON CONFLICT DO NOTHING;


INSERT INTO Ticket(name, cost)
VALUES ('беспересадочный билет на 20 минут', 21),
       ('пересадочный билет на 20 минут', 27),
       ('беспересадочный билет на 30 минут', 31),
       ('пересадочный билет на 30 минут', 35),
       ('беспересадочный билет на 45 минут', 42),
       ('пересадочный билет на 45 минут', 45),
       ('беспересадочный билет на 60 минут', 55),
       ('пересадочный билет на 60 минут', 60),
       ('беспересадочный билет на 75 минут', 65),
       ('пересадочный билет на 75 минут', 72),
       ('беспересадочный билет на 90 минут', 80),
       ('пересадочный билет на 90 минут', 84);

CREATE FUNCTION GenTicketId() RETURNS INT AS
$$
SELECT id FROM Ticket order by random() LIMIT 1
$$ LANGUAGE SQL;

CREATE FUNCTION GenTransportId() RETURNS INT AS
$$
SELECT id FROM Transport order by random() LIMIT 1
$$ LANGUAGE SQL;

CREATE FUNCTION GenRouteId() RETURNS INT AS
$$
SELECT id FROM Route order by random() LIMIT 1
$$ LANGUAGE SQL;

CREATE FUNCTION GenDriverLicense() RETURNS INT AS
$$
SELECT licence FROM Driver order by random() LIMIT 1
$$ LANGUAGE SQL;

WITH Data as (SELECT * FROM generate_series(1, 50) as id)
INSERT
INTO DailyRoute(id, day, transport_id, route_id, departure_time, driver_licence)
SELECT Data.id,
       ('2021-10-01'::DATE + random() * (interval '1 month'))::DATE,
       GenTransportId(),
       GenRouteId(),
       to_char(('05:30'::TIME + random() * ('18:00'::TIME)), 'HH24:MI')::TIME,
       GenDriverLicense()
FROM Data
ON CONFLICT DO NOTHING;

CREATE FUNCTION GenDailyRouteId() RETURNS INT AS
$$
SELECT id FROM DailyRoute order by random() LIMIT 1
$$ LANGUAGE SQL;

WITH Data as (SELECT * FROM generate_series(1, 20) as id)
INSERT
INTO Booking(id, ticket_id, daily_route_id, daily_validation_count)
SELECT Data.id, GenTicketId(), GenDailyRouteId(), (random() * 200)::INT
FROM Data
ON CONFLICT DO NOTHING;

WITH Data as (SELECT * FROM generate_series(1, 20) as id)
INSERT
INTO Logbook(daily_route_id, stop_id, arrival_time)
SELECT GenDailyRouteId(), GenStopId(),
to_char(('05:30'::TIME + random() * ('18:00'::TIME)), 'HH24:MI')::TIME
FROM Data
ON CONFLICT DO NOTHING;

WITH Data as (SELECT * FROM generate_series(2, 20) as id),
Stops as (SELECT Data.id, GenStopId() as stop_id FROM Data)
INSERT
INTO Timetable(id, route_id, stop_id, platform, arrival_time, weekend)
SELECT Stops.id, GenRouteId(), stop_id,
floor(random() * GetPlatformCount(stop_id) + 1)::int,
to_char(('05:30'::TIME + random() * ('18:00'::TIME)), 'HH24:MI')::TIME,
(random() > 0.5)::boolean
FROM Stops
ON CONFLICT DO NOTHING;
