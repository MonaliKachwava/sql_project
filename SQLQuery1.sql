/*
Project Queries 

Basic queries :
* Retrive the total number of orders placed .
*Calculate the total revenue generated from pizza sales.
*Identify the heighest-Priced Pizza.
*Identify the most common pizza size ordered .
*List the Top 5 most Ordered Pizza types along with their quantities.

Intermediate queries :
*Join the necessary tables to find the total quantities of each pizza category ordered .
*Determine the distribution of orders by hour of the day .
*Join relevant tables to find the category-wise distribution of pizzas.
*Group the orders by date and calculate the average number of pizzas ordered per day.
*Determine the Top 3 most ordered pizza types based on revenue.

Advance queries :
*Calculate the percentage contribution of each pizza type to total revenue.
*Analyze the cumulative revenue generated over time.

*/

***---Retrive the total number of orders placed .

select count(distinct order_id) as 'Total_orders' from orders
---Total numbers of orders are 21338

***---Calculate the total revenue generated from pizza sales.
select order_details.pizza_id ,order_details.quantity , pizzas.price 
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id

---Here we joined tables order_details and pizzas tables as we need quantity of pizza from order_detail and the price in pizzas tables we calculate revenue 
and we joined the tables based on pizza_id as it the common column in the both the tables ---

--- to get the answer 
select CAST(sum(order_details.quantity * pizzas.price ) AS decimal(10,2)) as 'Total Revenue'
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id

---ans : 817860.05

***---Identify the heighest-Priced Pizza

---using Top/Limit functions 
select top 1 pizza_types.name as 'pizza_name' , Cast(pizzas.price AS decimal(10,2)) as 'Price'
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by price desc

--- ANSWER ---The Greeek Pizza , price =35.95

----Alternative (using window function )-without using Top function

with cte as (
select pizza_types.name as 'pizza_name' , cast(pizzas.price as decimal(10,2)) as 'price',
rank() over (order by price desc) as rnk 
from pizzas
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id 
)

select pizza_name , price  rnk from cte  
order by  rnk desc
OFFSET 0 ROWS FETCH FIRST 5 ROWS ONLY
---here we cannot use limit so we use offset function and fetch function , in offset we can set how rows we want to remove from first and in fetch we can set howa many 
rows we want ----


***----Identify the most common pizza size ordered .

select pizzas.size , count (distinct order_id ) as 'No of orders' , sum(quantity) as 'Total Quantity Ordered'
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by  'No of orders' desc

---Answer : We can use query to plan inventory management .



***----List the Top 5 most Ordered Pizza types along with their quantities.
select top 5 pizza_types.name as 'pizza_name' , sum(quantity) as 'Total_quantity_ordered'
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by 'Total_quantity_ordered' desc 

***--Join the necessary tables to find the total quantities of each pizza category ordered .

select pizza_types.category as 'pizza_name' , sum(quantity) as 'Total_quantity'
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category
order by 'Total_quantity' desc 

***---Determine the distribution of orders by hour of the day .
select datepart(hour , time) as 'hour_of _the_day' , count(distinct order_id) as 'No of orders'
from orders
group by datepart(hour , time)
order by 'No of orders' desc

***---Join relevant tables to find the category-wise distribution of pizzas.
select category , count(distinct pizza_type_id) as 'no_of_pizzas'
from pizza_types
group by category 
order by 'no_of_pizzas' desc

***---Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(total_orders_that_day) as 'avg_orders'
from 
( select orders.date as 'Date' ,sum(order_details.quantity))as 'total_orders_that_day'
from order_details
join orders on order_details.order_id =orders.order_id
group by orders.date 
)

as pizzas_ordered
**-- answer =138

**---Determine the Top 3 most ordered pizza types based on revenue.
select top 3 pizza_types.name , sum(order_details.quantity*pizzas.price) as 'Revenue_from_pizza'
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id =pizzas.pizza_type_id
group by pizza_types.name
order by [Revenue_from_pizza] desc

----using with windows function can also be done
**-- Answer :THE THAI CHICKEN PIZZA WITH 43434.25  Total revenue

**--Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category ,
concat(cast((sum(order_details.quantity*pizzas.price)/
(select sum(order_details.quantity*pizzas.price) from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id)) * 100 as decimal(10,2)) , '%') as 'Revenue contribution from pizza'
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category
order by 'Revenue contribution from pizza' desc


---ANSWER : Classic category have made more contribution to revenue i.e 26.91% 

***--Analyze the cumulative revenue generated over time.
--use of aggerate window function (to get the cumulative sum)
with cte as (
select date as 'Date' , cast(sum(quantity*price) as decimal(10,2)) as 'revenue'
from order_details
join orders on order_details.order_id = orders.order_id
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by date 
)
select Date , revenue , sum(revenue) over (order by date) as 'cumulative sum'
from cte
group by date , revenue




 