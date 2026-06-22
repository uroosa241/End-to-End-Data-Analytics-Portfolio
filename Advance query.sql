--	Rank customers by lifetime value (CLV) 
select 
	c.customer_name,
	sum(price * quantity) as lifetime_value
	from customers as c
	join orders as o
	on o.customer_id=c.customer_id
	join products as p
	on p.product_id=o.product_id
	group by c.customer_name
	order by lifetime_value desc;




--	Find monthly revenue trend 
select 
 extract(year from order_date) as year,
 extract(MONTH from order_date) as month,
 sum (price * quantity) as total_revenue 
 from orders as o
 join products as p
 on p.product_id=o.product_id
 group by  extract(MONTH from order_date), extract(year from order_date)
 order by month desc;
 



--	Find running total revenue over time 
select 
	EXTRACT(month from order_date) as months,
	sum(price * quantity)as total_revenue,
	sum(sum(price * quantity))over(order by extract(month from order_date))
	as runing_total
	from orders as o
	join products as p
	on p.product_id=o.product_id	
	group by extract(month from order_date)
	order by months;


--	Identify churned customers (no recent orders) 

SELECT 
	c.customer_id,
	c.customer_name,
	max(order_date) as last_order_date
	from orders as o
	join customers as c
	on o.customer_id=c.customer_id
	group by c.customer_id,c.customer_name
	having max(order_date) < current_date - interval'90 days'


35.	Find customers with decreasing order values 
36.	Find products with rising demand trend 
37.	Detect abnormal return behavior (fraud pattern) 
38.	Compare paid vs pending conversion rate 
39.	Find average time between orders per customer 
40.	Find top 3 products per category 
