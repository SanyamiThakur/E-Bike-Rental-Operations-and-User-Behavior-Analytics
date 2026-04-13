CREATE TABLE users (
user_id INT PRIMARY KEY,
username VARCHAR(200) NOT NULL,
age INT NOT NULL,
membership_level VARCHAR(50) NOT NULL,
created_at TEXT NOT NULL
);

CREATE TABLE stations (
station_id INT PRIMARY KEY,
station_name VARCHAR(200) NOT NULL,
capacity INT NOT NULL,
lat DECIMAL(9,6),
lon DECIMAL(9,6)
);

CREATE TABLE rides (
ride_id INT PRIMARY KEY,
user_id INT,
start_station_id INT,
end_station_id INT,
start_time TEXT,
end_time TEXT,
distance_km DECIMAL(5,2),

FOREIGN KEY (user_id) REFERENCES users(user_id),
FOREIGN KEY (start_station_id) REFERENCES stations(station_id),
FOREIGN KEY (end_station_id) REFERENCES stations(station_id)
);

SELECT * FROM users;
SELECT * FROM rides;
SELECT * FROM stations;

-- converting time(text) to time stamps:
ALTER TABLE rides
ALTER COLUMN start_time TYPE timestamp USING start_time::timestamp,
ALTER COLUMN end_time TYPE timestamp USING end_time::timestamp;

-- Get count of rows per table:
CREATE OR REPLACE VIEW bi_table_counts AS
SELECT
	(SELECT COUNT (*) FROM users) AS total_users,
	(SELECT COUNT (*) FROM stations) AS total_stations,
	(SELECT COUNT (*) FROM rides) AS total_rides

-- Check for missing values:

CREATE OR REPLACE VIEW bi_data_quality AS
SELECT 
	COUNT(CASE WHEN start_station_id IS NULL THEN 1 END) AS null_start_station_id,
	COUNT(CASE WHEN end_station_id IS NULL THEN 1 END) AS null_end_station_id,
	COUNT(CASE WHEN start_time IS NULL THEN 1 END) AS null_start_time,
	COUNT(CASE WHEN end_time IS NULL THEN 1 END) AS null_end_time
FROM rides;

--Summary Statistics:

SCREATE OR REPLACE VIEW bi_summary_stats AS
SELECT 
	MIN(distance_km) AS minimum_dist,
	MAX(distance_km) AS maximum_dist,
	AVG(distance_km) AS average_dist,
	ROUND(MIN(EXTRACT(EPOCH FROM (end_time - start_time))/ 60), 2) AS min_duration_mins,
    ROUND(MAX(EXTRACT(EPOCH FROM (end_time - start_time))/ 60), 2) AS max_duration_mins,
	ROUND(AVG(EXTRACT(EPOCH FROM (end_time - start_time))/ 60), 2) AS avg_duration_mins
FROM rides;

-- check for false data {minimum dist is 0 and min duration is 0, not valid behavior in this case:}
/*could be false starts, user unlocks but doesnt move, ride starts and ends immediately, gps didnt record movement
app glitch, ride wasnt properly tracked*/

CREATE OR REPLACE VIEW bi_suspicious_rides AS
SELECT 
	COUNT(CASE WHEN EXTRACT(EPOCH FROM (end_time - start_time)) / 60 < 2 THEN 1 END) AS short_duration_trips, 
	COUNT(CASE WHEN distance_km = 0 THEN 1 END) AS short_distance
FROM rides;
-- GET MEMEBERSHIP INFO:

CREATE OR REPLACE VIEW bi_membership_analysis AS
SELECT
	u.membership_level,
	COUNT (r.distance_km) AS total_rides,
	AVG(r.distance_km) AS avg_distance_km,
	ROUND(EXTRACT(EPOCH FROM AVG(r.end_time - r.start_time)) / 60, 2) AS avg_duration_mins

FROM rides r
JOIN users u
	ON r.user_id = u.user_id
GROUP BY u.membership_level
ORDER BY total_rides DESC;
/* a lot of casual mem_level could mean tourists using it, subsricbers could be daily commuters using it for short dist.*/

-- select peek hours:
CREATE OR REPLACE VIEW bi_peak_hours AS
SELECT 
	EXTRACT(HOUR FROM start_time) as hour_of_day,
	COUNT(*) AS ride_count

FROM rides
GROUP BY hour_of_day
ORDER BY hour_of_day;
/* starting 7 am peak hour then peaks at 4pm */ 

-- check for popular stations:
select * from rides;
select * from users;
select * from stations;

CREATE OR REPLACE VIEW bi_popular_stations AS
SELECT 
	s.station_name,
	COUNT(r.ride_id) AS total_starts

FROM rides as r
JOIN stations as s
	ON r.start_station_id = s.station_id

GROUP BY s.station_name
ORDER BY total_starts DESC;
LIMIT 10;

-- Categorize rides by distance: short, medium, long:

CREATE OR REPLACE VIEW bi_ride_categories AS
SELECT 
	CASE
		WHEN EXTRACT(EPOCH FROM (end_time - start_time)) / 60 <= 10 THEN 'Short (< 10m)'
		WHEN EXTRACT(EPOCH FROM (end_time - start_time)) / 60 BETWEEN 11 AND 30 THEN 'Medium (11m-30m)'
		ELSE 'Long > 30m'
	END AS ride_category,
	COUNT(*) AS count_of_rides
FROM rides 
GROUP BY ride_category
ORDER BY count_of_rides;

-- net flow for each station:

-- net flow for each station

CREATE OR REPLACE VIEW bi_station_net_flow AS

WITH departures AS (
    SELECT 
        start_station_id, 
        COUNT(*) AS total_departures
    FROM rides
    GROUP BY start_station_id
),

arrivals AS (
    SELECT 
        end_station_id, 
        COUNT(*) AS total_arrivals
    FROM rides
    GROUP BY end_station_id
)

SELECT 
    s.station_name, 
    d.total_departures, 
    a.total_arrivals,
    (a.total_arrivals - d.total_departures) AS net_flow
FROM stations s
JOIN departures d 
    ON s.station_id = d.start_station_id
JOIN arrivals a 
    ON s.station_id = a.end_station_id
ORDER BY net_flow ASC;

/*negative net flow means that people are taking their e-bikes from here and they are not returning them. 
These stations are likely residential areas or morning commute starting points where people take bikes to work. 
For example, people leave the Jennifer Land Street and they ride to the downtown office area and they return bikes 
elsewhere. Jennifer Land Street runs out of bikes over time.
This is important because it shows rebalancing bikes. 
They send trucks to move the bikes from surplus stations to short-term stations. 
This will help us to protect demand; negative net flow stations mean that they need more bikes, 
and positive net flow stations mean they need more parking lots. */

-- user retention:

CREATE OR REPLACE VIEW bi_user_growth AS

WITH monthly_signups AS (

	SELECT 
		DATE_TRUNC ( 'MONTH', created_at:: timestamp) AS signup_month,
		COUNT(user_id) AS new_user_count
	FROM users
	GROUP BY signup_month
)

SELECT 
	signup_month,
	new_user_count,
	LAG(new_user_count) OVER (ORDER BY signup_month) AS previous_month_count,

	(new_user_count - 
	LAG(new_user_count) OVER (ORDER BY signup_month))
	/
	NULLIF(
		LAG(new_user_count) OVER (ORDER BY signup_month), 0
	) * 100 AS mom_growth

FROM monthly_signups
ORDER BY signup_month;

--- sEE YOUR VIEWS:
SELECT * FROM bi_table_counts;
SELECT * FROM bi_data_quality;
SELECT * FROM bi_summary_stats;
SELECT * FROM bi_suspicious_rides;
SELECT * FROM bi_membership_analysis;
SELECT * FROM bi_peak_hours;
SELECT * FROM bi_popular_stations;
SELECT * FROM bi_ride_categories;
SELECT * FROM bi_station_net_flow;
SELECT * FROM bi_user_growth;