use rpc_13_trips_db; 

## Business Req 1 :- 
SELECT 
city_name,COUNT(*) AS "Total Trips",
ROUND(SUM(fare_amount)/SUM(distance_travelled_km),2) AS "Avg Fare Per KM",
ROUND(SUM(fare_amount)/COUNT(*),0) AS "Avg Fare Per Trip",
ROUND(COUNT(t.trip_id)*100/(SELECT COUNT(*) FROM fact_trips),2) AS "% Contribution"
FROM dim_city c 
INNER JOIN 
fact_trips t 
ON c.city_id = t.city_id
GROUP BY city_name;

## Business Req 2 :- 
SELECT 
c.city_name AS "City Name",
MONTHNAME(t.date) AS "Month Name",
COUNT(t.date) AS "Actual Trips",
tr.total_target_trips AS "Target Trips",
CASE WHEN COUNT(t.date) > tr.total_target_trips THEN 'Above Target'
ELSE 'Below Target'
END AS "Performance Status",
ROUND(((COUNT(t.date) - tr.total_target_trips) * 100.0) / tr.total_target_trips, 2) AS "Percentage Difference"
FROM rpc_13_trips_db.dim_city c
INNER JOIN 
rpc_13_trips_db.fact_trips t
ON c.city_id = t.city_id
INNER JOIN rpc_13_targets_db.monthly_target_trips tr
ON DATE_FORMAT(t.date, '%Y-%m-01') = tr.month AND t.city_id = tr.city_id
GROUP BY c.city_name, DATE_FORMAT(t.date, '%M'), tr.total_target_trips
ORDER BY c.city_name, MONTH(t.date); 

## Business Req 3 :- 
SELECT 
city_name AS "City Name",
SUM(repeat_passenger_count) AS "Total repeat customers",
ROUND(100*SUM(CASE WHEN trip_count = '2-Trips' THEN repeat_passenger_count ELSE 0 END )/SUM(repeat_passenger_count),2)  AS "2-Trips",
ROUND(100*SUM(CASE WHEN trip_count = '3-Trips' THEN repeat_passenger_count ELSE 0 END )/SUM(repeat_passenger_count),2) AS "3-Trips",
ROUND(100*SUM(CASE WHEN trip_count = '4-Trips' THEN repeat_passenger_count ELSE 0 END )/SUM(repeat_passenger_count),2) AS "4-Trips",
ROUND(100*SUM(CASE WHEN trip_count = '5-Trips' THEN repeat_passenger_count ELSE 0 END )/SUM(repeat_passenger_count),2) AS "5-Trips",
ROUND(100*SUM(CASE WHEN trip_count = '6-Trips' THEN repeat_passenger_count ELSE 0 END )/SUM(repeat_passenger_count),2) AS "6-Trips",
ROUND(100*SUM(CASE WHEN trip_count = '7-Trips' THEN repeat_passenger_count ELSE 0 END )/SUM(repeat_passenger_count),2) AS "7-Trips",
ROUND(100*SUM(CASE WHEN trip_count = '8-Trips' THEN repeat_passenger_count ELSE 0 END )/SUM(repeat_passenger_count),2) AS "8-Trips",
ROUND(100*SUM(CASE WHEN trip_count = '9-Trips' THEN repeat_passenger_count ELSE 0 END )/SUM(repeat_passenger_count),2) AS "9-Trips",
ROUND(100*SUM(CASE WHEN trip_count = '10-Trips' THEN repeat_passenger_count ELSE 0 END )/SUM(repeat_passenger_count),2) AS "10-Trips"
FROM dim_city c 
INNER JOIN dim_repeat_trip_distribution r 
ON c.city_id = r.city_id
GROUP BY city_name;


## Business Req 4 :- 
WITH CTE1 AS 
(
SELECT 
city_name AS "City Name",
SUM(new_passengers) AS "New Passengers",
RANK()OVER (ORDER BY new_passengers DESC) AS "Ranking",
CASE WHEN
RANK()OVER (ORDER BY new_passengers DESC) <= 3 THEN "Top 3"
WHEN 
RANK()OVER (ORDER BY new_passengers DESC) IN (8,9,10) THEN "Bottom 3"
END AS "CityCategory"
FROM dim_city c 
INNER JOIN fact_passenger_summary p
ON c.city_id = p.city_id
GROUP BY city_name
)
SELECT * FROM CTE1
WHERE CityCategory IS NOT NULL;

-- Business Req 5 :- 
WITH CTE AS 
(
SELECT 
city_name ,
MONTHNAME(date) AS Month_name,
SUM(fare_amount) AS Highest_Revenue,
RANK() OVER (PARTITION BY city_name ORDER BY SUM(fare_amount) DESC) AS Rank_n
FROM dim_city c 
INNER JOIN fact_trips t
ON c.city_id = t.city_id
GROUP BY 1,2
), 
CTE2 AS 
(
SELECT city_name,Month_name,Highest_Revenue,
ROUND(100*(Highest_Revenue / SUM(Highest_Revenue) OVER(PARTITION BY city_name )) , 2 ) AS Pct_distribution,
Rank_n
FROM CTE
)
SELECT city_name ,
    Month_name ,
    Highest_Revenue ,
    Pct_distribution
FROM CTE2
where Rank_n = 1 ; 

-- Business Req 6 :- Monthly rate
SELECT 
city_name,
MONTHNAME(month) AS "Month Name",
SUM(total_passengers) AS "Total Passesnges",
SUM(repeat_passengers) AS "Repeat Passenges",
ROUND(SUM(repeat_passengers)*100/SUM(total_passengers),2) AS "Monthly Repeat Passenger Rate"
 FROM 
dim_city c 
INNER JOIN fact_passenger_summary p 
ON c.city_id = p.city_id
GROUP BY 1,2;

-- Business Req 6 :- City rate
SELECT 
city_name,
SUM(total_passengers) AS "Total Passesnges",
SUM(repeat_passengers) AS "Repeat Passenges",
ROUND(SUM(repeat_passengers)*100/SUM(total_passengers),2) AS "City Repeat Passenger Rate"
 FROM 
dim_city c 
INNER JOIN fact_passenger_summary p 
ON c.city_id = p.city_id
GROUP BY 1











