


--	Find customers with decreasing order values 
WITH order_data AS (
    SELECT
        c.customer_id,
        o.order_date,
        SUM(p.price * o.quantity) AS order_value
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN products p
        ON o.product_id = p.product_id
    GROUP BY c.customer_id, o.order_date
),
lagged AS (
    SELECT
        customer_id,
        order_date,
        order_value,
        LAG(order_value) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS prev_order_value
    FROM order_data
)
SELECT *
FROM lagged
WHERE order_value < prev_order_value;




--Find products with rising demand trend 

WITH monthly_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        DATE_TRUNC('month', o.order_date) AS month,
        SUM(o.quantity) AS total_quantity
    FROM orders o
    JOIN products p
        ON o.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, DATE_TRUNC('month', o.order_date)
),
trend AS (
    SELECT
        product_id,
        product_name,
        month,
        total_quantity,
        LAG(total_quantity) OVER (
            PARTITION BY product_id
            ORDER BY month
        ) AS prev_month_qty
    FROM monthly_sales
)
SELECT *
FROM trend
WHERE total_quantity > prev_month_qty;







--Detect abnormal return behavior (fraud pattern) 

with products_returns 
as (
select 
		p.product_id,
		count(return_id) as total_returns
		from products as p
		join orders as o
		on o.product_id=p.product_id
		left join returns  as r
		on r.order_id=o.order_id
		group by p.product_id
),
stats as 
	(select
	 avg(returns) as avg_returns,
	 stddev(returns) as std_returns
	 from product_returns
	
)
select
	pr.product_id
	pr.total_returns
	from product_returns pr
	cross join  stats s
	where pr.total_returns > s.avg_returns + 2 * s.std_returns;


