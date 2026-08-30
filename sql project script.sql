create database project;
use project;
-- Task 1: Data Cleaning & Preparation
-- 1. Identify and delete duplicate Order_ID or Shipment_ID records
SELECT 
    order_id, COUNT(*) AS dupes
FROM
    orders_fedex
group by order_id
having dupes >1;

SELECT 
    Shipment_ID, COUNT(*) AS dupes
FROM
    shipments_fedex
GROUP BY Shipment_ID
HAVING dupes > 1;
-- there is no dupes in oreder_id and shipment_id

-- 2.Replace null or missing Delay_Hours values in the Shipments Table with the average delay for that Route_ID.
select * from shipments_fedex
where delay_hours is null;
-- there is no null values in delay hours

-- 3.Convert all date columns (Order_Date, Pickup_Date, Delivery_Date) into YYYY-MM-DD HH:MM:SS format using SQL date functions. 
alter table shipments_fedex
modify column pickup_date datetime,
modify column delivery_date datetime;

SELECT 
    *
FROM
    orders_fedex;
alter table orders_fedex
modify column order_date datetime;
-- converted all 3 colunms to datetime 

-- 4.Ensure that no Delivery_Date occurs before Pickup_Date (flag such records).
SELECT 
    order_id,
    delivery_date,
    pickup_date,
    CASE
        WHEN delivery_date < pickup_date THEN 'invalid'
        ELSE 'valid'
    END AS date_validation
FROM
    shipments_fedex;
 -- another method
 SELECT 
    *
FROM
    shipments_fedex
WHERE
    delivery_date < pickup_date;
-- there is no invalid pickup date or delivery date

-- Task 2:  Delivery Delay Analysis 
-- 1.Calculate delivery delay (in hours) for each shipment using Delivery_Date – Pickup_Date. 
SELECT 
    shipment_id,
    pickup_date,
    delivery_date,
    TIMESTAMPDIFF(HOUR,
        pickup_date,
        delivery_date) AS delivery_delay
FROM
    shipments_fedex;

-- 2. Find the Top 10 delayed routes based on average delay hours
SELECT 
    route_id, ROUND(AVG(delay_hours), 2) AS avg_delay
FROM
    shipments_fedex
GROUP BY route_id
ORDER BY avg_delay DESC
LIMIT 10;

-- 3.Use SQL window functions to rank shipments by delay within each Warehouse_ID
select shipment_id,warehouse_id, dense_rank() over(partition by Warehouse_ID order by delay_hours desc) as rank_ from shipments_fedex;

-- 4.Identify the average delay per Delivery_Type (Express / Standard) to compare service-level efficiency. 
SELECT 
    o.delivery_type, ROUND(AVG(s.delay_hours), 2) AS avg_delay
FROM
    orders_fedex o
        INNER JOIN
    shipments_fedex s ON o.order_id = s.order_id
GROUP BY delivery_type;

-- Task 3: Route Optimization Insights
-- 1.Average transit time (in hours) across all shipments. 
select avg(timestampdiff(hour , pickup_date, delivery_date)) as avg_transit_time from shipments_fedex;
-- 2.Average delay (in hours) per route.
select route_id, round(avg(delay_hours),2) as avg_delay_hours from shipments_fedex
group by route_id
order by avg_delay_hours desc;
-- 3.Distance-to-time efficiency ratio = Distance_KM / Avg_Transit_Time_Hours. 
SELECT 
    route_id,
    distance_km,
    Avg_Transit_Time_Hours,
    ROUND(distance_km / Avg_Transit_Time_Hours, 3) AS efficiency_ratio
FROM
    routes_fedex;
-- 4.Identify 3 routes with the worst efficiency ratio (lowest distance-to-time)
SELECT 
    route_id,
    distance_km,
    Avg_Transit_Time_Hours,
    ROUND(distance_km / Avg_Transit_Time_Hours, 3) AS efficiency_ratio
FROM
    routes_fedex
ORDER BY efficiency_ratio ASC
LIMIT 3;
--  5.Find routes with >20% of shipments delayed beyond expected transit time. 
SELECT 
    route_id,
    COUNT(*) AS total_shipment,
    SUM(CASE
        WHEN delay_hours > 0 THEN 1
        ELSE 0
    END) AS delayed_shipment,
    ROUND(SUM(CASE
                WHEN delay_hours > 0 THEN 1
                ELSE 0
            END) / COUNT(*),
            3) * 100 AS delayed_shipment_percentage
FROM
    shipments_fedex
GROUP BY route_id
HAVING delayed_shipment_percentage > 20
ORDER BY delayed_shipment_percentage DESC;
-- Recommend potential routes or hub pairs for optimization
-- based on poor efficiency, route R003, R015, R006 need optimaization 

-- Task 4: Warehouse Performance
-- 1. Find the top 3 warehouses with the highest average delay in shipments dispatched
-- as there is no column named dispatch time in any table, we have to calculate dispatch time with formulla pickup_date - order_date
SELECT 
    s.warehouse_id,
    AVG(TIMESTAMPDIFF(HOUR,
        o.order_date,
        s.pickup_date)) AS dispatch_time_taken
FROM
    shipments_fedex s
        INNER JOIN
    orders_fedex o ON s.order_id = o.order_id
GROUP BY warehouse_id
ORDER BY dispatch_time_taken DESC
LIMIT 3;
-- warehouse w007, w006, w002 has the highest time diff between order_date and pickup_date

-- 2.Calculate total shipments vs delayed shipments for each warehouse
SELECT 
    warehouse_id,
    COUNT(*) AS total_shipment,
    SUM(CASE
        WHEN delay_hours > 0 THEN 1
        ELSE 0
    END) AS delayed_shipment,
    ROUND(SUM(CASE
                WHEN delay_hours > 0 THEN 1
                ELSE 0
            END) / COUNT(*),
            3) * 100 AS delayed_shipment_percentage
FROM
    shipments_fedex
GROUP BY warehouse_id
ORDER BY delayed_shipment_percentage DESC;

-- 3. Use CTEs to identify warehouses where average delay exceeds the global average delay. 
with warehouse_delay as(
select warehouse_id, round(avg(delay_hours),2) avg_delay from shipments_fedex
group by warehouse_id)
select w.*, round(avg(s.delay_hours) over(),2) as global_avg 
from warehouse_delay w inner join shipments_fedex s 
where avg_delay > (select avg(delay_hours) from shipments_fedex)
limit 10;

-- 4.Rank all warehouses based on on-time delivery percentage
with timly_delivery as(
select warehouse_id,count(*) as total_delivery ,sum(case when delay_hours =0 then 1 else 0 end) as on_time_delivery,
(sum(case when delay_hours =0 then 1 else 0 end)/count(*))*100 as on_time_delivery_percentage
from shipments_fedex
group by warehouse_id)
select * , rank() over(order by on_time_delivery_percentage desc) as warehouse_Rnak from timly_delivery;

-- Task 5: Delivery Agent Performance
-- 1 .Rank delivery agents (per route) by on-time delivery percentage.
with timly_delivery as(
select route_id,Agent_ID,count(*)as total_delivery  ,sum(case when delay_hours =0 then 1 else 0 end) as on_time_delivery,
round(sum(case when delay_hours =0 then 1 else 0 end)/count(*),2)*100 as on_time_delivery_percentage
from shipments_fedex
group by route_id,Agent_ID)
select * , rank() over(partition by route_id order by on_time_delivery_percentage desc) as agent_rank from timly_delivery;
-- 2.Find agents whose on-time % is below 85%.
with timly_delivery as(
select Agent_ID,count(*) as total_delivery ,sum(case when delay_hours =0 then 1 else 0 end) as on_time_delivery,
(sum(case when delay_hours =0 then 1 else 0 end)/count(*))*100 as on_time_delivery_percentage
from shipments_fedex
group by Agent_ID)
select *  from timly_delivery
where on_time_delivery_percentage < 85
order by agent_id;
-- 3.Compare the average rating and experience (in years) of the top 5 vs bottom 5 agents using subqueries. 
select *, avg(experience_years) over() as avg_exp_of_5,round(avg(avg_rating) over(),2) as avg_rating_of_5 from (select Agent_ID,Agent_Name,Experience_Years,Avg_Rating from fedex_agents
order by avg_rating desc limit 5) as top_5
union all
select *, avg(experience_years) over() avg_exp_of_5, avg(avg_rating) over() as avg_rating_of_5 from (select Agent_ID,Agent_Name,Experience_Years,Avg_Rating from fedex_agents
order by avg_rating asc limit 5) as top_5;

-- Task 6: Shipment Tracking Analytics
-- 1.For each shipment, display the latest status (Delivered, In Transit, or Returned) along with the latest Delivery_Date.
SELECT 
    shipment_id, delivery_date, delivery_status
FROM
    shipments_fedex;
-- 2.Identify routes where the majority of shipments are still “In Transit” or “Returned”
SELECT 
    route_id, delivery_status
FROM
    shipments_fedex
WHERE
    delivery_status IN ('in transit' , 'returned');
-- 3.Find the most frequent delay reasons (if available in delay-related columns or flags)
SELECT 
    delay_reason, COUNT(*) AS frequency
FROM
    shipments_fedex
GROUP BY delay_reason
ORDER BY frequency DESC
LIMIT 1;
-- 4. Identify orders with exceptionally high delay (>120 hours) to investigate potential bottlenecks.
SELECT 
    order_id,delay_hours,delay_reason
FROM
    shipments_fedex
WHERE
    delay_hours > 120
ORDER BY delay_hours DESC;

 -- Task 7: Advanced KPI Reporting
 -- 1 Average Delivery Delay per Source_Country. 
SELECT 
    r.Source_Country,
    ROUND(AVG(s.delay_hours), 3) AS avg_delay_hours
FROM
    routes_fedex r
        INNER JOIN
    shipments_fedex s ON r.route_id = s.route_id
GROUP BY Source_Country
ORDER BY avg_delay_hours DESC;
-- 2. On-Time Delivery % = (Total On-Time Deliveries / Total Deliveries) * 100
SELECT 
    (SUM(CASE
        WHEN delay_hours = 0 THEN 1
        ELSE 0
    END) / COUNT(*)) * 100 AS total_on_time_delivery_percentage
FROM
    shipments_fedex;
-- 3. Average Delay (in hours) per Route_ID.
SELECT 
    route_id, ROUND(AVG(delay_hours), 2) AS avg_delay
FROM
    shipments_fedex
GROUP BY route_id
ORDER BY avg_delay DESC;
-- 4. Warehouse Utilization % = (Shipments_Handled / Capacity_per_day) * 100
with shipments as(
SELECT 
    warehouse_id, COUNT(*) AS shipments
FROM
    shipments_fedex
group by warehouse_id
order by shipments desc)
SELECT 
    w.warehouse_id,
    w.Capacity_per_day,
    s.shipments,
    (s.shipments / w.Capacity_per_day) * 100 AS warehouse_utilization
FROM
    warehouses_fedex w
        INNER JOIN
    shipments s
