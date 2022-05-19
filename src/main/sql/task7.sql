-- первый подход
DROP VIEW IF EXISTS FaresStats;

CREATE VIEW FaresStats AS
SELECT
    T.id AS id,
    T.name AS title,
    SUM(B.daily_validation_count) AS total_validations,
    SUM(B.daily_validation_count) * T.cost AS total_price_sum
FROM Ticket T JOIN Booking B ON T.id=B.ticket_id
GROUP BY T.id;

-- вносим изменения
ALTER TABLE Booking ADD COLUMN validation_time TIME;
ALTER TABLE Booking DROP CONSTRAINT booking_daily_route_id_ticket_id_key;

CREATE VIEW tmpBooking AS
SELECT
    ticket_id,
    daily_route_id,
    to_char(('05:30'::TIME + random() * ('18:00'::TIME)), 'HH24:MI')::TIME AS validation_time,
    generate_series(1, daily_validation_count)
FROM Booking B;

INSERT INTO Booking(ticket_id, daily_route_id, validation_time, daily_validation_count)
SELECT ticket_id, daily_route_id, validation_time, 1
FROM tmpBooking ON CONFLICT (id) DO UPDATE SET id=EXCLUDED.id;

ALTER TABLE Booking DROP COLUMN daily_validation_count CASCADE;

-- второй подход
CREATE OR REPLACE VIEW FaresStats AS
SELECT
    T.id AS id,
    T.name AS title,
    COUNT(B.validation_time) AS total_validations,
    COUNT(B.validation_time) * T.cost AS total_price_sum
FROM Ticket T JOIN Booking B ON T.id=B.ticket_id
GROUP BY T.id;