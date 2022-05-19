CREATE OR REPLACE VIEW StaffWorkload AS
SELECT D.licence          AS id,
       D.name             AS name,
       D.surname          AS surname,
       D.patronymic       AS patronymic,
       COUNT(DR.route_id) AS shift_count
FROM Driver D
         JOIN DailyRoute DR on D.licence = DR.driver_licence
GROUP BY D.licence;
