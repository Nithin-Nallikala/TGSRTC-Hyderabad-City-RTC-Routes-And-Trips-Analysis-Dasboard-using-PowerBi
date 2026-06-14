/*Creating the TGSRTC database*/
create database tgsrtc;

/* Using the database TGSRTC */
Use tgsrtc;

/* Creating the table with the coulumns for the routes */
Create table routes(
rounte_id int primary Key,
route_Long_name varchar(100),
agency_id varchar(50),
route_type Int,
route_short_name varchar(20)
);

/* Creating the table for trips */
Create table trips (
route_id int,
trip_id int primary key,
service_id varchar(20),
direction_id int,
pattern_id int,
trip_headsign varchar(200),
trip_short_name varchar(100),
depot varchar(50),
bus_class varchar(50)
);

/* Creating the table for stop times */
Create table stop_times(
trip_id int,
stop_sequence int,
stop_id int,
departure_time time,
arrival_time time,
timepoint int
);

/* Creating the table for calendar */
Create table calendar(
service_id varchar(2),
start_date date,
end_date date,
monday int,
tuesday int,
wednesday int,
thursday int,
friday int,
saturday int,
sunday int
);

/* Creating the table for stops */
create table stops(
stop_id int primary key,
stop_name varchar(200),
zone_id varchar(50),
stop_lat decimal(9,6),
stop_lon decimal(9,6)
);

/* Imporing the table calendar and viewing all the records */
Select * from Calendar;

/* Alter table calendar
modify start_date varchar(8),
modify end_date varchar(8); */

/* Describing the coulmns and data types of the table calnedar */
describe calendar;

/* Changing the size of the service id, from 2 to 20 */
Alter table calendar
modify service_id varchar(20);


/* update calendar 
set start_date =str_to_date(start_date, '%Y%m%d'),
	end_date = str_to_date(end_date, '%Y%m%d'); */
    
/*--Addning new date columns--*/
Alter table calendar
add start_date_d date,
add end_date_d date;

/* Convert into the new columns */
Update calendar
set start_date_d = str_to_date(start_date,'%Y%m%d%'),
    end_date_d = str_to_date(end_date,'%Y%m%d');

/* Drop old VARCHAR columns */
Alter table calendar
drop column start_date,
drop column end_date;

/* Rename new columns */
Alter table calendar
change start_date_d start_date date,
change end_date_d end_date date;

/* Alter table calendar
modify start_date varchar(10),
modify end_date varchar(10); */

describe calendar;

/* Selecting the coulms on the changes we have made so far */
Select service_id, start_date, end_date
from calendar
limit 10;

/* Adding the routes table from csv file and viewing them */
Select * from routes;

/* Drop & recreate stop_times table to Change arrival_time & departure_time to VARCHAR */
drop table if exists stop_times;

/* Creating the table for stop times again */
create table stop_times(
trip_id int not null,
stop_sequence int not null,
stop_id int not null,
departure_time varchar(8) not null,
arrival_time varchar(8) not null,
timepoint tinyint,
primary key (trip_id, stop_sequence)
 );

Describe stop_times;

/* Imporing the table stop_times after sampling from the 1 million rows of data, to 1lakh rows of data and viewing all the records */
select * from stop_time;


/* Imporing the table stops and viewing all the records */
Select * from stops;

/* Imporing the trips table and viewing all the records */
Select * from trips;

/* Truncating and deleting the records which were previosuly imported in the stop_times table and I wanted to import new table with 
the sample size of 100000 for the stop_times table*/
truncate table stop_times;

/* Now viewing the stop_times table */
select * from stop_times;
select count(*) from stop_times;
select * from calendar;
select count(*) from calendar;
select * from routes;
select count(*) from routes;
select * from stops;
select count(*) from stops;
select * from trips;
select count(*) from trips;

/* --DATA CLEANING IN SQL--*/
/* Checking for the Duplicates */
select trip_id, count(*)
from trips
group by trip_id
having count(*)>1;

Select stop_id, count(*)
from stop_times
group by stop_id
having count(*)>1;

/* Trips per route */
Select route_id, count(trip_id) as total_trips
from trips
group by route_id;

/* Stop count per trip */
select trip_id, count(stop_id) as total_stops
from stop_times
group by trip_id;

/* PEAK DEPARTURE HOURS */
/* This query counts how many trips start in each hour of the day, by considering only
the first stop of each trip, grouping by departure hour, and ordering by the busiest hours.*/
select hour(departure_time) as hour, count(*) trips
from stop_times
where stop_sequence = 1
group by hour
order by trips desc;

/* Creating a view */
CREATE VIEW vw_trip_master AS
SELECT
    t.trip_id,
    t.route_id,
    r.route_long_name,
    r.route_short_name,
    t.service_id,
    t.direction_id,
    t.trip_headsign,
    t.depot,
    t.bus_class,
    c.start_date,
    c.end_date,
    c.monday,
    c.tuesday,
    c.wednesday,
    c.thursday,
    c.friday,
    c.saturday,
    c.sunday
FROM trips t
LEFT JOIN routes r
    ON t.route_id = r.route_id
LEFT JOIN calendar c
    ON t.service_id = c.service_id;
