****Total number of flights by airline and airport on a monthly basis***
CREATE OR REPLACE FORCE VIEW DM_RPT_MONTHLY_FLI_AIR_CNT AS
SELECT month,airline,air.IATA_CODE,COUNT(1) as cnt
FROM flights fli  LEFT OUTER JOIN airports air
ON (fli.origin_airport=air.IATA_CODE
   OR fli.destination_airport=air.IATA_CODE)
GROUP BY month,airline,air.IATA_CODE;

**** On time percentage of each airline for the year 2015********
CREATE OR REPLACE FORCE VIEW DM_RPT_ON_TIME_AIRLINE AS
SELECT DISTINCT AIRLINE,
(SUM(CASE WHEN DEPARTURE_DELAY IS NULL AND ARRIVAL_DELAY IS NULL THEN 1 ELSE 0 END) OVER (PARTITION BY AIRLINE) /
COUNT(*) OVER (PARTITION BY AIRLINE))*100 AS ON_TIME_PERCENTAGE
FROM FLIGHTS
WHERE YEAR=2015;

****Airlines with the largest number of delays******
CREATE OR REPLACE FORCE VIEW DM_RPT_LARGEST_DELAY_AIRLINES AS
SELECT *
FROM (SELECT AIRLINE,DENSE_RANK() OVER ( ORDER BY SUM(DEPARTURE_DELAY) DESC) AS RNK,
SUM(DEPARTURE_DELAY)
FROM  flights
WHERE DEPARTURE_DELAY IS NOT NULL
GROUP BY AIRLINE)
WHERE RNK=1;

*******delays Cancellation reasons by airport*********
CREATE OR REPLACE FORCE VIEW DM_RPT_Cancellation_reasons_airport AS
SELECT  DISTINCT AIR.AIRPORT, CASE WHEN CANCELLATION_REASON ='A' THEN 'Airline/Carrier'
             WHEN CANCELLATION_REASON ='B' THEN 'Weather'
             WHEN CANCELLATION_REASON ='C' THEN 'National Air System'
             WHEN CANCELLATION_REASON ='D' THEN 'Security' ELSE 'others' end as CANCELLATION_REASON
FROM  flights fli  left outer join airports air
on (fli.origin_airport=air.IATA_CODE
   or fli.destination_airport=air.IATA_CODE)
WHERE CANCELLATION_REASON IS NOT NULL;



*******Delay reasons by airport*********
CREATE OR REPLACE FORCE VIEW DM_RPT_DELAY_REASON_AIRPORT AS
SELECT  DISTINCT AIR.AIRPORT,
CASE WHEN (AIR_SYSTEM_DELAY IS NOT NULL AND AIR_SYSTEM_DELAY >0) THEN 'Delay caused by the air system'
             WHEN (SECURITY_DELAY IS NOT NULL AND SECURITY_DELAY>0) THEN 'Delay caused by security'
             WHEN (AIRLINE_DELAY  IS NOT NULL AND AIRLINE_DELAY>0) THEN 'Delay caused by the airline' ELSE 'others' end as DELAY_REASON
FROM  flights fli  left outer join airports air
on (fli.origin_airport=air.IATA_CODE
   or fli.destination_airport=air.IATA_CODE)
   AND (AIR_SYSTEM_DELAY  IS NOT NULL OR SECURITY_DELAY IS NOT NULL OR AIRLINE_DELAY  IS NOT NULL);
   
******Airline with the most unique routes*********   
CREATE OR REPLACE FORCE VIEW DM_MOST_UNIQUE_ROUTES AS
select distinct least(origin_airport,destination_airport) AS origin_airport,
greatest(origin_airport,destination_airport) AS destination_airport
FROM  flights ;
