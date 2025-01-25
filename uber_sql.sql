create database uber;

use uber;

create table trips
(trip_id text,
date_of_booking date,
time_duration_minute int,
trip_distance_km double,
pickup_location text,
drop_off_location text,
trip_status varchar(30),
customer_id text,
customer_name text,
customer_rating double,
driver_id text,
driver_name text,
driver_rating double,
vehicle_id text,
vehicle_type text,
vehicle_model text,
base_fare double,
distance_fare double,
time_fare double,
surge_multiplier double,
surcharges double,
discount double,
total_fare double,
payment_method text,
payment_status text,
cancellation_status varchar(10),
cancellation_reason text,
eta_minutes int,
day_of_week text,
time_of_day text,
traffic_condition text,
weather_condition text,
city text,
region varchar(20),
ride_category varchar(20),
driver_feedback_behavior text
);

SELECT * FROM trips;

--  drop table trips;

# 1. Retrieve all successful trips:
create view successful_trips as 
select * from trips
where Trip_Status = 'Completed';

select * from successful_trips;

# 2. Find the average distance for each vehicle type:
create view average_distance_for_each_vehicle_type as
select Vehicle_Type, avg(Trip_Distance_km) as avg_distance
from trips
group by Vehicle_Type;

select * from average_distance_for_each_vehicle_type;

# 3. Get the total number of cancelled rides by customers:
create view cancelled_rides_by_customers as 
select count(*) from trips where Cancellation_Reason='Customer Canceled';

select * from cancelled_rides_by_customers;

# 4. List the top 5 customers who looked the highest number of rides:
create view top_5_customers as
select customer_id,count(trip_id) as total_rides
from trips
group by customer_id
order by total_rides desc
limit 5;

select * from top_5_customers;
# 5. Get the number of rides cancelled by drivers due to personal and car-related issues:
create view cancelled_by_drivers_p_c as
select count(*) from trips where Cancellation_Reason in ('Driver Canceled','Vehicle Issue');

select * from cancelled_by_drivers_p_c;
# 6. Find the maximum and minimum driver ratings for UberPremier rides:
create view max_min_driver_ratings as
select max(Driver_Rating) as max_ratings,
min(Driver_Rating) as min_ratings
from trips
where vehicle_type='UberPremier';

select * from max_min_driver_ratings;

# 7. Retrieve all rides where payment was made using UPI:
create view UPI_Payments as
select * from trips where Payment_Method='UPI';

select * from UPI_Payments;

# 8. Find the average customer rating per vehicle type:
create view avg_customer_ratings as
select vehicle_type,avg(Customer_Rating) as cust_rating
from trips
group by vehicle_type;

select * from avg_customer_ratings;

# 9. Calculate the total booking value of rides completed successfully:
create view total_successful_ride_values as
select sum(total_fare) as total_successful_ride_value
from trips
where trip_status='completed';

select * from total_successful_ride_values;

# 10. List all incomplete rides along with the reason:
create view incomplete_rides_reasons as 
select trip_id,Cancellation_Reason from trips
where Cancellation_status='yes';

select * from incomplete_rides_reasons;
-- Trip Demand and Volume
# 11.Which cities experience the highest trip demand during peak hours?
create view highest_trip_demand_during_peak_hours as
select city,time_of_day,count(trip_id) as trip_count
from trips
where time_of_day='Morning' or time_of_day='Evening'
group by city,time_of_day
order by trip_count desc; 

select * from  highest_trip_demand_during_peak_hours;

-- Revenue Analysis
# 12.what is the total revenue generated per vehicle type in the last 3 months?
create view revenue_generated_in_last_3_months as
select vehicle_type,sum(Total_fare) as total_revenue
from trips
where date_sub(curdate(),interval 3 month)
group by vehicle_type
order by total_revenue desc;

select * from revenue_generated_in_last_3_months;

-- Driver Performance
# 13. Who is the top 10 drivers based on average customer ratings in the last month?
create view last_month_avg_rating as
select driver_id,avg(customer_rating) as avg_rating
from trips
where date_of_Booking between date_sub(curdate(),interval 1 month) and curdate()
group by driver_id
order by avg_rating desc
limit 10;

select * from last_month_avg_rating;

-- Customer Retention
# 14.How many repeat customers booked rides more than twice in the past month?
create view repeat_cust_more_than_2 as
select customer_id,count(trip_id) as counts
from trips
where  date_of_Booking between date_sub(curdate(),interval 1 month) and curdate()
group by customer_id
having counts>2
order by counts desc;

select * from repeat_cust_more_than_2;

-- Surge Pricing Impact
# 15 How much revenue was generated from surge pricing in the last 6 months?
create view surge_pricing_revenue as
select city,sum((surge_multiplier-1)*base_fare) as surge_revenue
from trips
where surge_multiplier>1 and date_of_Booking between date_sub(curdate(),interval 6 month) and curdate()
group by city
order by surge_revenue desc;

select * from surge_pricing_revenue;

-- ETA - Estimated time of arrival for the driver at the pickup location
# 16. what is average Estimated time of arrival for the driver at the pickup location?
create view average_ETA as 
select city,avg(eta_minutes) as avg_eta
from trips
group by city
order by avg_eta desc;

select * from average_ETA;

--  Vehicle Utilization
# 17. which vehicle type has the highest trip count in each city?
create view highest_count_city_and_vehicle as 
select city,vehicle_type,count(trip_id) as total_trips
from trips
group by city,vehicle_type
order by city,total_trips desc;

select * from highest_count_city_and_vehicle;

-- Trip efficiency
# 18. what is the average trip distance and duration for completed rides?
create view avg_distance_and_duartion as
select avg(trip_distance_km) as avg_distance,avg(time_duration_minute) as avg_duration
from trips
where trip_status='completed';

select * from avg_distance_and_duartion;

-- customer spend analysis
# 19.Who are the top 5 customers based on total spending in the last 3 months?
create view top_5_cust_in_last_month as 
select customer_id,sum(Total_fare) as total_spent
from trips
where date_of_Booking between date_sub(curdate(),interval 3 month) and curdate()
group by customer_id
order by total_spent desc
limit 5;

select * from top_5_cust_in_last_month;
