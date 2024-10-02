-- Retrieve the total number of orders placed.
use pizza_sales_project;

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
    
    
-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        INNER JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;


-- Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;


-- Identify the most common pizza size ordered
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;


-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name,
    COUNT(order_details.quantity) AS total_quantity
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        INNER JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 5;



-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;



-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(time) AS hours, COUNT(order_id)
FROM
    orders
GROUP BY hours
ORDER BY hours asc;



-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    AVG(quantity) AS avg_quantity_order_per_day
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS quantity
    FROM
        order_details
    INNER JOIN orders ON order_details.order_id = orders.order_id
    GROUP BY orders.date) AS order_quantity_per_day;
    
    
    
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizzas
        INNER JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        INNER JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;



-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.name,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS revenvue
                FROM
                    order_details
                        INNER JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS percentage_of_toatal_revenue
FROM
    pizzas
        INNER JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        INNER JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY percentage_of_toatal_revenue DESC;



-- Analyze the cumulative revenue generated over time.
Select date, sum(revenue) over (order by date) as cum_revenue
from 
(select orders.date, sum(order_details.quantity*pizzas.price) as revenue
from
order_details inner join pizzas 
on order_details.pizza_id = pizzas.pizza_id 
inner join orders 
on orders.order_id = order_details.order_id
group by orders.date) as sales; 



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name ,revenue,  rn
from
(select category,name, revenue, rank() over (partition by category order by revenue desc) as rn
from
(SELECT 
    pizza_types.category,
    pizza_types.name,
    sum(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category , pizza_types.name) as a) as b
where rn<=3;
