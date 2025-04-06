
 -- 1. Calculate number of visits per Agent
 select agent_id, count( retailer_id )as NumberOfVisits from visits group by agent_id order by NumberOfVisits asc

--2. 2. Calculate number of visited retailers per Agent & Unique percantage of visits


with cte as(
select agent_id, count(distinct retailer_id)as Retailers from visits group by agent_id 
)
select Retailers,
format( Retailers/cast((select count(distinct retailer_id) from visits)as float),'P') as PercentageOfVisits
from cte

--3. Calculate success rate from visits to orders 

with cte as(
select count(sales_order_id) as orders from Orders 
)
select format(orders/cast ((select count(*) from visits)as  float),'P')  as SucsseRate from cte 


-- 4. Calculate orders, retailers and Net sales per type per Agent

select agent_id , retailer_type ,
count(sales_order_id) as Total_Orders,
count( distinct retailer_id)as NumberOfRetailers,
sum(order_price)as NetSales 
from orders
Group by rollup (retailer_type,agent_id)

-- Cluster the Agents based on their perfrormance
select
agent_id,
case 
when Ranking >=3 then 'Power Saler'
when Ranking =2 then 'Need Attention'
else 'Bad Performance'
End as 'Segment'
from (
select 
agent_id,
NTILE(4) over(order by avgDealSize)as Ranking  

from(

select agent_id ,
sum(order_price)/count(sales_order_id) as avgDealSize from orders
group by agent_id

) as R

)as segmentation


-- insights "Avg response time"
with cte as(
select o.retailer_id,o.agent_id as agent, o.order_created as orderdate, v. visit_date as visitdate  from visits v inner join 
orders o on v.retailer_id=o.retailer_id
),
cte2 as (
select agent,Datediff(day,visitdate,orderdate) as diffrence from cte 
)
select agent,AVG(diffrence) as AvgResponseTimeByDays  from cte2 group by agent


