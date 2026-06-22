
Perform RFM analysis (Recency, Frequency, Monetary) 

select 
	c.customer_id,
	sum(price * quantity) as monetary,
	count(order_id)as total_purchase,
	max(order_date) as recency
	from customers as c
	join orders as o
	on o.customer_id=c.customer_id
	join products as p
	on o.product_id=p.product_id
	group by c.customer_id
	order by monetary,total_purchase,recency desc;




	Build cohort analysis (customers grouped by first order month) 

WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
),

cohort_analysis AS (
    SELECT
        o.customer_id,
        fp.first_order_date,
	TO_CHAR(fp.first_order_date, 'Mon 	YYY') AS cohort_month,

        (
            (EXTRACT(YEAR FROM o.order_date) -
             EXTRACT(YEAR FROM fp.first_order_date)) * 12
            +
            (EXTRACT(MONTH FROM o.order_date) -
             EXTRACT(MONTH FROM fp.first_order_date))
        ) AS month_number

    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
)

SELECT *
FROM cohort_analysis
ORDER BY customer_id, month_number;


WITH retention AS (
    SELECT
        customer_id,
        order_date,
        MIN(order_date) OVER (PARTITION BY customer_id) AS first_order_date
    FROM orders
),

cohort_analysis AS (
    SELECT
        customer_id,

        DATE_TRUNC('month', first_order_date) AS cohort_month,

        (
            (EXTRACT(YEAR FROM order_date) -
             EXTRACT(YEAR FROM first_order_date)) * 12
            +
            (EXTRACT(MONTH FROM order_date) -
             EXTRACT(MONTH FROM first_order_date))
        ) AS month_number

    FROM retention
),

active_customers AS (
    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM cohort_analysis
    GROUP BY cohort_month, month_number
),

retention_rate AS (
    SELECT
        cohort_month,
        month_number,
        active_customers,

        FIRST_VALUE(active_customers) OVER (
            PARTITION BY cohort_month
            ORDER BY month_number
        ) AS cohort_size

    FROM active_customers
)

SELECT
    TO_CHAR(cohort_month, 'Mon YYYY') AS cohort_month,
    month_number,
    active_customers,
    cohort_size,

    ROUND(
        active_customers * 100.0 / cohort_size,
        2
    ) AS retention_rate

FROM retention_rate
ORDER BY cohort_month, month_number;



	Identify revenue leakage due to returns 

-- how many we are losing bcz the customer returns product
WITH revenue AS (
    SELECT
        o.customer_id,
        o.order_id,
        SUM(p.price * o.quantity) AS total_revenue
    FROM orders o
    JOIN products p
        ON o.product_id = p.product_id
    GROUP BY o.customer_id, o.order_id
),

returned_value AS (
    SELECT
        r.order_id,
        SUM(p.price * o.quantity) AS return_value
    FROM returns r
    JOIN orders o
        ON o.order_id = r.order_id
    JOIN products p
        ON o.product_id = p.product_id
    GROUP BY r.order_id
),

return_leakage AS (
    SELECT
        SUM(r.total_revenue) AS total_revenue,
        COALESCE(SUM(rv.return_value), 0) AS returned_revenue,

        SUM(r.total_revenue)
        - COALESCE(SUM(rv.return_value), 0) AS net_revenue
    FROM revenue r
    LEFT JOIN returned_value rv
        ON r.order_id = rv.order_id
)

SELECT *
FROM return_leakage;


	Find top employees contributing to revenue growth 
WITH revenue AS (
    SELECT
        e.employee_id,
        e.employee_name,
        DATE_TRUNC('month', o.order_date) AS month,
        SUM(p.price * o.quantity) AS total_revenue
    FROM orders o
    JOIN employees e
        ON o.employee_id = e.employee_id
    JOIN products p
        ON o.product_id = p.product_id
    GROUP BY e.employee_id, e.employee_name, DATE_TRUNC('month', o.order_date)
)

SELECT 
    employee_id,
    employee_name,
    month,
    total_revenue,

    LAG(total_revenue) OVER (
        PARTITION BY employee_id 
        ORDER BY month
    ) AS prev_revenue,

    ROUND(
        (total_revenue - LAG(total_revenue) OVER (
            PARTITION BY employee_id 
            ORDER BY month
        )) * 100.0 /
        NULLIF(LAG(total_revenue) OVER (
            PARTITION BY employee_id 
            ORDER BY month
        ), 0),
    2) AS growth_percentage

FROM revenue
ORDER BY total_revenue DESC;

