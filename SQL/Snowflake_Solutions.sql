--1) Update The Store Table so that all stores have opening data on or after 1-Jan-2014, Populate random dates

select * from DIMSTORE;

--Step-1:

select datediff(day,'2014-01-01', current_date) --Find The diff from 1-Jan-2014 to current_date
--in our case it is 4057, we can consider it as our upper bound,lets say for convinence we havent opened our stores from past 2months in that case we can consider 4000

--Step-2:

select dateadd(day,uniform(0,4000,random()),'2014-01-01') --now using random and uniform function we can define our upper bound which is 4000 and lower bound which is 0 , and could populate random dates

--Step -3:

update DIMSTORE set STOREOPENINGDATE=dateadd(day,uniform(0,4000,random()),'2014-01-01') -- Update the col 

--Step -4:
commit; --Commit the query



--2) Update The Store Table so that stores with storied between 91 and 100 are opened in the last 12 months


select * from DIMSTORE where STOREID between 91 and 100;

select dateadd(year,-1,current_date) --to find exact date 1yr ago

select dateadd(day,uniform(0,360,random()),'2024-02-09')

update DIMSTORE set STOREOPENINGDATE = dateadd(day,uniform(0,360,random()),'2024-02-09')


--3) Update The Customer Table so that all Customers are at least 12 years old, Any customer that is less than 12 years old. Subtract 12 years from there DOB.

select * from DIMCUSTOMER where dateofbirth >=dateadd(year,-12,current_date);

update DIMCUSTOMER set dateofbirth = dateadd(year,-12,dateofbirth) where dateofbirth >=dateadd(year,-12,current_date);

commit;


--4) We may have some orders in the fact table that may have a DateID which contains a value even before the store was opened. For Example: A store was opened last year but we have an order from 10 years ago which is incorrect Update dateid in order table for such rows with to have a random dateid after the opening date of their respective stores

--Identify Record that has problem
update FACTORDERS f
set f.dateid = r.dateid from
(select orderid,d.dateid from
(select orderid,

dateadd(day,datediff(day,S.STOREOPENINGDATE,current_date)*uniform(1,10,random())*.1,S.STOREOPENINGDATE) as new_date

from FACTORDERS F
join DIMDATE D on F.DATEID=D.DATEID
join DIMSTORE S on F.STOREID=S.STOREID
where D.DATE<S.STOREOPENINGDATE) o 
join dimdate d on o.new_date =d.date)r 
where f.orderid = r.orderid

commit

--5) List Customers who haven't placed an order in the last 30days

select * from dimcustomer where customerid not in
(select distinct c.Customerid from dimcustomer c
join factorders f on c.customerid = f.customerid
join dimdate d on f.dateid = d.dateid
where d.date >=dateadd(month,-1,current_date));


--6) List the store that was opened most recently along with its sales since then

with store_rank as
(
select storeid, storeopeningdate,row_number() over (order by storeopeningdate desc) as final_Rank from DIMSTORE
 ),
 most_recent_store as 
 (
 select storeid from store_rank where final_rank =1
),
store_amount as
(
select o.storeid,sum(totalamount)as totalamount from factorders o join most_recent_store s on o.storeid=s.storeid
group by o.storeid
)
select *,a.totalamount from dimstore s join store_amount a on s.storeid=a.storeid


--7) Find Customers who have ordered product from more than 3 categories in the last 6 months


WITH BASE_DATA AS
(
SELECT O.CUSTOMERID,P.CATEGORY FROM FACTORDERS O JOIN DIMDATE D ON O.DATEID =D.DATEID
JOIN DIMPRODUCT P ON O.PRODUCTID=P.PRODUCTID
WHERE D.DATE >=DATEADD(MONTH,-6,CURRENT_DATE)
GROUP BY O.CUSTOMERID,P.CATEGORY
)
SELECT CUSTOMERID
FROM BASE_DATA
GROUP BY CUSTOMERID
HAVING COUNT(DISTINCT CATEGORY)>3

--8) Get the monthly total sales for the current year.

SELECT MONTH,SUM(TOTALAMOUNT) AS MONTHLY_AMOUNT FROM FACTORDERS O JOIN DIMDATE D ON O.DATEID=D.DATEID
WHERE D.YEAR=EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY MONTH
ORDER BY MONTH

--9) Find the highest discount given on any order in the last 1 year.

with base_data as 
(
select discountamount, row_number() over (order by discountamount desc) as discountamount_rank from factorders O join dimdate D on O.dateid = D.dateid
where D.date >=dateadd(year,-1,current_date)
)
select * from base_data where discountamount_rank=1

--10) Calculate total sales by multiplying the unit price from product column with quantity ordered from fact orders

select sum(quantityordered*unitprice) from factorders o join dimproduct p on o.productid=p.productid

--11) Show the customerid of the Customer who has taken the maximum discount in their lifetime.

select customerid,sum(discountamount) from factorders f
group by customerid
order by sum(discountamount) desc limit 5

--12) List the customer who was placed maximum number of orders till date.

with base_data as
(
select customerid,count(orderid) as order_count from factorders f
group by customerid
),
order_rank_data as 
(
select *,row_number() over (order by order_count desc) as order_rank from base_data b
)
select * from order_rank_data where order_rank=1

--13) Show the top 3 brands based on there sales in the last 1 year

with brand_sales as 
(
select brand,sum(totalamount) as total_sales from
factorders f join dimdate d on f.dateid = d.dateid
join dimproduct p on f.productid=p.productid
where d.date>=dateadd(year,-1,current_date)
group by brand
),
brand_sales_rank as
(
select *,row_number() over (order by total_sales desc) as sales_rank from brand_sales s
)
select * from brand_sales_rank where sales_rank <=3

--14) If the discount amount and the shipping cost was made static at 5 and 8% respectively  will the sum of new total amount be greater than the total amount we have 

select case when sum(orderamount - orderamount*.05 - orderamount*.08) > sum(totalamount) then 'yes' else 'no' end from factorders f

--15) Share the Number of Customers and their current loyalty program status 

select l.programtier,count(customerid) as customer_count from dimcustomer d join dimloyaltyprogram l on d.loyaltyprogramid=l.loyaltyprogramid 
group by l.programtier

--16) Show the region category wise total amount for the last 6 months

select region, category, sum(totalamount) as total_sales
from factorders f
join dimdate d on f.dateid=d.dateid
join dimproduct p on f.productid=p.productid
join dimstore s on f.storeid=s.storeid
where d.date >= dateadd(month,-6,current_date)
group by region,category

--17) Show the top 5 products based on quantity ordered in the last 3 years

with quantity_data as 
(
select f.productid,sum(quantityordered)as total_quantity from factorders f join dimdate d on f.dateid=d.dateid
where d.date>=dateadd(year,-3,current_date)
group by f.productid
),
quantity_rank_data as
(
select *,row_number() over (order by total_quantity desc) as quantity_wise_rank from quantity_data q
)
select productid,total_quantity from quantity_rank_data where quantity_wise_rank <=5

--18) List the total amount for each loyalty program tier since year 2023

select p.programname,sum(totalamount) as total_sales from factorders f
join dimdate d on f.dateid=d.dateid
join dimcustomer c on f.customerid=c.customerid
join dimloyaltyprogram p on c.loyaltyprogramid = p.loyaltyprogramid
where d.year >= 2023
group by p.programname

--19) Calculate the revenue generated by each store manager in June 2024

select s.managername,sum(totalamount) as total_sales from factorders f
join dimdate d on f.dateid=d.dateid
join dimstore s on f.storeid=s.storeid
where d.year = 2024 and d.month=6
group by s.managername

--20) List the average order amount per store, along with the store name and type for the year 2024

select s.storename,s.storetype,AVG(totalamount) as total_sales from factorders f
join dimdate d on f.dateid=d.dateid
join dimstore s on f.storeid=s.storeid
where d.year = 2024
group by s.storename,s.storetype