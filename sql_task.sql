-- Информация о таблице wifi_session
-- поля таблицы

-- 1) Идентификатор пользователя - uid
-- 2) Дата и время начала сессии - start_dttm
-- 3) Дата и время окончания сессии - stop_dttm
-- 4) Станция начала сессии - start_station
-- 5) Станция окончания сессии - stop_station


-- Задание 1
-- Необходимо найти всех пользователей из таблици wifi_session, 
-- которые за последние 3 месяца использовали станции 50 или 161 более 50 раз.

SELECT uid, COUNT(*) as session_count
FROM wifi_session
WHERE (start_station = 50 OR start_station = 161)
   OR (stop_station = 50 OR stop_station = 161)
   AND stop_dttm >= DATEADD(MONTH, -3, GETDATE())
GROUP BY uid
HAVING COUNT(*) > 50

-- Задание 2
-- Необходимо выделить все сессии, которые начинаются раньше, 
-- чем закончилась предшествующая сессия в рамках каждого пользователя.


WITH SessionsRanked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY uid ORDER BY stop_dttm) as SessionRank 
    FROM wifi_session
)
SELECT s1.*
FROM SessionsRanked s1
JOIN SessionsRanked s2 ON s1.uid = s2.uid AND s1.SessionRank = s2.SessionRank + 1
WHERE s1.start_dttm < s2.stop_dttm

-- Задание 3
-- Необходимо выделить ТОП-10 самых посещаемых станций.

SELECT station_id, COUNT(*) as visit_count
FROM (
    SELECT start_station as station_id FROM wifi_session
    UNION ALL
    SELECT stop_station as station_id FROM wifi_session
) as Stations
GROUP BY station_id
ORDER BY visit_count DESC
LIMIT 10


-- Здание 4
-- Необходимо найти для каждого пользователя станцию, 
-- на которой он чаще всего заканчивает свой день.

SELECT uid, stop_station
FROM (
    SELECT 
        uid, 
        stop_station,
        ROW_NUMBER() OVER (PARTITION BY uid ORDER BY COUNT(*) DESC) as StationRank
    FROM wifi_session
    GROUP BY uid, stop_station
) AS RankedStations
WHERE StationRank = 1;
