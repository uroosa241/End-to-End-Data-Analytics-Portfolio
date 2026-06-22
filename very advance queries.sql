--	Build customer segmentation (VIP / Regular / Lost) 

select * from customers
select * from payments
select * from returns
select * from employees
select * from orders
select * from products

WITH customer_purchase AS
(
    SELECT
        c.customer_id,
        COUNT(order_id) AS total_orders,
        SUM(price * quantity) AS total_purchase
    FROM customers c
    JOIN orders o
        ON o.customer_id = c.customer_id
    JOIN products p
        ON p.product_id = o.product_id
    GROUP BY c.customer_id
),

customer_segmentation AS
(
    SELECT
        customer_id,
        total_orders,
        total_purchase,
        CASE
            WHEN total_purchase >= 10000 THEN 'VIP'
            WHEN total_purchase >= 5000 THEN 'Regular'
            ELSE 'Lost'
        END AS customer_segment
    FROM customer_purchase
)

SELECT *
FROM customer_segmentation;

--Perform RFM analysis (Recency, Frequency, Monetary) 
select 
	c.customer_id,
	current_date - max(order_date) as recency,
	count(order_id) as frequency,
	sum(price * quantity) as monetary
	from customers as c
	join orders as o
	on o.customer_id=c.customer_id
	join products as p
	on p.product_id=o.product_id
	group by c.customer_id;




--Build cohort analysis (customers grouped by first order month) 

WITH first_purchase AS (
    SELECT
        c.customer_id,
        MIN(o.order_date) AS first_order_date
    FROM customers c
    JOIN orders o
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_id
),

cohort AS (
    SELECT
        o.customer_id,
        DATE_TRUNC('month', fp.first_order_date) AS cohort_month,
        DATE_TRUNC('month', o.order_date) AS order_month
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
)

SELECT
    customer_id,
    cohort_month,
    order_month
FROM cohort;





WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
),

cohorts AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', first_order_date) AS cohort_month
    FROM first_purchase
)

SELECT
    o.customer_id,
    c.cohort_month,
    DATE_TRUNC('month', o.order_date) AS order_month,
    (EXTRACT(YEAR FROM o.order_date) - EXTRACT(YEAR FROM first_order_date)) * 12 +
    (EXTRACT(MONTH FROM o.order_date) - EXTRACT(MONTH FROM first_order_date)) AS month_number
FROM orders o
JOIN first_purchase fp
    ON o.customer_id = fp.customer_id
JOIN cohorts c
    ON o.customer_id = c.customer_id;







--	Find customer retention rate over time 

WITH retention AS (
    SELECT
        c.customer_id,
        o.order_date,

        MIN(o.order_date) OVER (PARTITION BY c.customer_id) AS first_order_date,

        DATE_TRUNC('month',
            MIN(o.order_date) OVER (PARTITION BY c.customer_id)
        ) AS cohort_month,

        DATE_TRUNC('month', o.order_date) AS order_month

    FROM customers c
    JOIN orders o
        ON o.customer_id = c.customer_id
),

cohort_data AS (
    SELECT 
        cohort_month,
        order_month,

        (EXTRACT(YEAR FROM order_month) - EXTRACT(YEAR FROM cohort_month)) * 12 +
        (EXTRACT(MONTH FROM order_month) - EXTRACT(MONTH FROM cohort_month)) AS month_number,

        COUNT(DISTINCT customer_id) AS active_customers
    FROM retention
    GROUP BY cohort_month, order_month
),

retention_rate AS (
    SELECT 
        TO_CHAR(cohort_month, 'Mon YYYY') AS cohort_month,
        month_number,
        active_customers,

        FIRST_VALUE(active_customers) OVER (
            PARTITION BY cohort_month 
            ORDER BY month_number
        ) AS cohort_size,

        ROUND(
            active_customers * 100.0 /
            FIRST_VALUE(active_customers) OVER (
                PARTITION BY cohort_month 
                ORDER BY month_number
            ),
        2) AS retention_rate

    FROM cohort_data
)

SELECT *
FROM retention_rate
ORDER BY cohort_month, month_number;




--	Identify revenue leakage due to returns 






46.	Find top employees contributing to revenue growth 
47.	Detect customers likely to churn 
48.	Identify best acquisition month for customers 
49.	Build full sales funnel (order → payment → return) 
50.	Create executive KPI dashboard queries (Revenue, Growth, Retention) 
