-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT 
	city_name,
	ROUND(
	(population * 0.25)/1000000, 
	2) as coffee_consumers_in_millions,
	city_rank
FROM city
ORDER BY coffee_consumers_in_millions DESC





-- -- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
select ct.city_name,sum(s.total) as total_revenue from 
sales s join customers c on c.customer_id=s.customer_id 
join city ct on ct.city_id=c.city_id
where year(s.sale_date)=2023 and quarter(s.sale_date)=4
group by ct.city_name
order by total_revenue desc




-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?
select p.product_name,count(s.sale_id) as total_orders from 
products p left join sales s on p.product_id=s.product_id
group by p.product_name
order by total_orders desc




-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?

-- city abd total sale
-- no cx in each these city
select ct.city_name,sum(s.total) as total_sale,count(distinct(s.customer_id)) as 
cus_count, round(sum(s.total)/count(distinct(s.customer_id)),2)  as sale_pr_cus from 
sales s join customers c on c.customer_id=s.customer_id 
join city ct on ct.city_id=c.city_id
group by ct.city_name
order by sale_pr_cus desc




-- -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)
SELECT 
	ct.city_name,count(distinct(s.customer_id)) as unique_cus,ROUND((ct.population * 0.25/1000000),2)
    as coffee_consumers_in_millions
FROM city ct join customers c on
 ct.city_id=c.city_id join sales s on
 s.customer_id=c.customer_id
group by ct.city_name
ORDER BY coffee_consumers_in_millions desc




-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
select ct.city_name,count(distinct(s.customer_id)) as 
cus_count from 
sales s join customers c on c.customer_id=s.customer_id 
join city ct on ct.city_id=c.city_id
where s.product_id<=14
group by ct.city_name




-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

with cte as (
select ct.city_name,p.product_name,count(s.sale_id) as total_orders,
dense_rank() over (partition by ct.city_name order by count(s.sale_id) desc) as
rnk from 
products p  join sales s on p.product_id=s.product_id
join customers c on c.customer_id=s.customer_id join city ct on
ct.city_id=c.city_id
group by ct.city_name,p.product_name
order by ct.city_name,total_orders desc)

select * from cte where rnk<=3





-- -- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer
WITH city_table AS (
    SELECT 
        ci.city_name,
        SUM(s.total) AS total_revenue,
        COUNT(DISTINCT s.customer_id) AS total_cx,
        ROUND(SUM(s.total) / COUNT(DISTINCT s.customer_id), 2) AS avg_sale_pr_cx
    FROM sales AS s
    JOIN customers AS c ON s.customer_id = c.customer_id
    JOIN city AS ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name
    ORDER BY SUM(s.total) DESC
),
city_rent AS (
    SELECT 
        city_name, 
        estimated_rent
    FROM city
)
SELECT 
    cr.city_name,
    cr.estimated_rent,
    ct.total_cx,
    ct.avg_sale_pr_cx,
    ROUND(cr.estimated_rent / ct.total_cx, 2) AS avg_rent_per_cx
FROM city_rent AS cr
JOIN city_table AS ct ON cr.city_name = ct.city_name
ORDER BY ct.avg_sale_pr_cx, avg_rent_per_cx DESC;





-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city
with cte as (
select ct.city_name,month(s.sale_date) as month_,year(s.sale_date) as year_,
sum(s.total) as cur_mnth_sales,lag(sum(s.total)) over (partition by ct.city_name) 
as nxt_mnth_sales
from sales s join customers c on c.customer_id=s.customer_id
join city ct on c.city_id=ct.city_id
group by ct.city_name,month(s.sale_date),year(s.sale_date)
order by ct.city_name,year(s.sale_date),month(s.sale_date))

select city_name,month_,year_,cur_mnth_sales,nxt_mnth_sales,
round((cur_mnth_sales-nxt_mnth_sales)/nxt_mnth_sales*100,2) as growth_ratio
 from cte where nxt_mnth_sales is not null
 
 
 
 
 -- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer
WITH city_table AS (
    SELECT 
        ci.city_name,
        SUM(s.total) AS total_revenue,
        COUNT(DISTINCT s.customer_id) AS total_cx,
        ROUND(SUM(s.total) / COUNT(DISTINCT s.customer_id), 2) AS avg_sale_pr_cx
    FROM sales AS s
    JOIN customers AS c ON s.customer_id = c.customer_id
    JOIN city AS ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name
    ORDER BY SUM(s.total) DESC
),
city_rent AS (
    SELECT 
        city_name, 
        estimated_rent,ROUND(
	(population * 0.25)/1000000, 
	2) as estimated_coffee_consumers_in_millions
    FROM city
)
SELECT 
    cr.city_name,
    total_revenue,
    cr.estimated_rent as total_rent,
    ct.total_cx,
    ct.avg_sale_pr_cx,
    cr.estimated_coffee_consumers_in_millions,
    ROUND(cr.estimated_rent / ct.total_cx, 2) AS avg_rent_per_cx
FROM city_rent AS cr
JOIN city_table AS ct ON cr.city_name = ct.city_name
ORDER BY total_revenue desc







/*
-- Recomendation according to my analysis
City 1: Pune
	1.Average rent per customer is very low.
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers at 7.7 million.
	2.Highest total number of customers, which is 68.
	3.Average rent per customer is 330 (still under 500).

City 3: Jaipur
	1.Highest number of customers, which is 69.
	2.Average rent per customer is very low at 156.
	3.Average sales per customer is better at 11.6k.


 
 
 
 
 
 
























