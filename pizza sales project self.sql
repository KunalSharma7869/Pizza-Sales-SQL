create database pizza;
use pizza;
create table orders(orderid int not null,orderdate date not null,ordertime time not null,primary key(orderid));
create table order_details(order_details_id int not null,order_id int not null,pizza_id text not null,quantity int not null,primary key(order_details_id));
--  Retrieve the total number of orders placed.
select  count(*)orderid from orders;

#Calculate the total revenue generated from pizza sales.
select round(sum(quantity*price),2)as sales from order_details  inner join pizzas using(pizza_id);

-- Identify the highest-priced pizza-- 

select *from pizzas;
 
select name,price from pizza_types inner join  pizzas using(pizza_type_id) order by price desc limit 1;

-- Identify the most common pizza size ordered.
select size,count(order_id)as o from order_details inner join pizzas using(pizza_id) group by size order by o desc ;

-- List the top 5 most ordered pizza types along with their quantities.
select  * from pizza_types;
select  size,count(order_id) as o from order_details inner join pizzas using(pizza_id) group by size order by o desc;
-- pizza_typesJoin the necessary tables to find the total quantity of each pizza category ordered.
select category ,sum(quantity) as quantity from pizza_types inner join pizzas using(pizza_type_id) inner join order_details using(pizza_id) group by category order by quantity desc  ;

 --  Determine the distribution of orders by hour of the day.
 select hour(ordertime) as ordertime,count(orderid) orderid from orders group by hour(ordertime) order by orderid desc ;
 
 -- Join relevant tables to find the category wise distribution of pizzas
 select category ,count(order_id) from pizza_types inner join pizzas using(pizza_type_id) inner join order_details using(pizza_id) group by category;
-- Group the orders by date and calculate the average number of pizza ordered per day
select round(avg(quantity),2) from(select orderdate,sum(quantity)as quantity from orders o inner join order_details od on o.orderid=od.order_id group by orderdate)as ordered_quantity;
-- determine the top3  most ordered pizza based on revenue
select sum(quantity*price)as revenue,pizza_types.name from pizza_types inner join pizzas using(pizza_type_id) inner join order_details using(pizza_id) group by pizza_types.name order by revenue desc limit 3;
 -- calculate the percentage contribution of each pizza type to revenue
 select  category ,(sum(quantity*price)/(select ROUND(sum(quantity*price),2)
 as toatal_sales from order_details inner join pizzas on pizzas.pizza_id=order_details.pizza_id))*100 as revenue from pizza_types pt inner join pizzas p on pt.pizza_type_id=p.pizza_type_id inner join order_details o on o.pizza_id=p.pizza_id group by category order by revenue desc;

#Analyze the cummulative revenue genereated over time -- 
select orderdate,sum(revenue) over  (order by orderdate) as cum_revenue from 
(select orders.orderdate,sum(order_details.quantity*pizzas.price)as revenue from order_details inner join pizzas on order_details.pizza_id=pizzas.pizza_id join orders on
orders.orderid=order_details.order_id group by orders.orderdate) as sales;

-- determine  the top3 most ordered pizzas  types based on revenue for each category
select name,revenue from 
(select category,name,revenue, rank() over(partition by category order by revenue desc) as rn from
(select pizza_types.category,pizza_types.name,sum(order_details.quantity*pizzas.price)as revenue from pizza_types inner join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
inner join order_details on order_details.pizza_id=pizzas.pizza_id group by pizza_types.category,pizza_types.name)as a)as b where rn<=3;
 