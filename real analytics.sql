--21.	Find customers who have never placed an order. 


select 
	c.customer_id,
	c.customer_name,
	count(*) as total_orders
	from customers as c
	left join orders as o
	on o.customer_id=c.customer_id
	group by c.customer_id, c.customer_name
	having count (o.order_id) =0;


SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;




select * from customers 
select * from payments
select * from employees
select * from returns 
select * from orders
select * from products  



--	Find products that were never sold.

SELECT
    p.product_id,
    p.product_name
FROM products p
LEFT JOIN orders o
    ON p.product_id = o.product_id
WHERE o.order_id IS NULL;




--	Find orders that were not paid yet. 

select
	o.order_id,
	c.customer_name,
	p.payment_status
	from customers as c
	join orders as o
	on c.customer_id=o.order_id
	join payments as p
	on o.order_id=p.order_id
	where payment_status = 'Pending'



	select * from returns 


--	Find orders that were returned. 

select 
	o.order_id,
	r.return_id
	from orders as o
	join returns as r
	on o.order_id=r.order_id




--	Identify “high-value customers” (top 20% customers). 

SELECT
    c.customer_id,
    c.customer_name,
    ROUND(SUM(price * quantity), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
join products as p
on p.product_id=o.product_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC;
	
	


----	Identify “high-value customers” (top 20% revenue).

select * from 
(select 
	c.customer_id,
	c.customer_name,
	Round(sum(price * quantity),2) as total_revenue,
	NTILE (5)over (order by sum(price * quantity)desc)as revenue_group
	from customers c
	join orders o
	on o.customer_id=c.customer_id
	join products p
	on o.product_id=p.product_id
	group by 	c.customer_id,c.customer_name
	)t
	where revenue_group =1;



)


--Find customers who only ordered once. 

select 
	c.customer_id,
	c.customer_name
	from orders as o
	join customers as c
	on o.customer_id=c.customer_id
	group by c.customer_id,c.customer_name
	Having count(order_id)= 1;



--	Find repeat customers (more than 1 order). 


select 
	c.customer_id,
	c.customer_name
	from orders as o
	join customers as c
	on o.customer_id=c.customer_id
	group by c.customer_id,c.customer_name
	Having count(order_id) >1;

--	Which employees generate the highest revenue? 

select * from employees  --salary
select * from products

select 
	e.salary,
	e.employee_name,
	sum(price * quantity) as total_revenue
	from employees as e
	join orders as o
	on e.employee_id= o.employee_id
	join products as p
	on p.product_id=o.product_id
	group by e.salary, e.employee_name
	order by total_revenue desc 
	limit 1;


select * from orders

--	Which cities generate the most revenue? 
select 
	c.city,
	sum(price * quantity) as total_revenue
	from customers as c
		join orders as o
	on c.customer_id= o.customer_id
	join products as p
	on p.product_id=o.product_id
	group by city
	order by total_revenue desc 
	limit 1;

select * from returns


--Which products are frequently returned? 
select
	p.product_name,
	count(return_id) as total_returns
from products as p
join orders as o
on o.product_id=p.product_id
join returns as r
on r.order_id=o.order_id
group by p.product_name
order by total_returns desc;

