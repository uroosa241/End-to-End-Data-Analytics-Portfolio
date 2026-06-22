select * from customers
select * from payments
select * from orders
select * from returns
select * from  products 
select * from employees




--	Which customer placed the most orders? customer-id order id
select
	c.customer_id,
	c.customer_name,
	max(order_id) as highest_order
	from customers as c
	join orders as o
	on o.customer_id=c.customer_id
	group by c.customer_id,customer_name
	order by highest_order desc
	limit 1;



--	Who are the top 5 highest spending customers? 

select
	c.customer_id,
	c.customer_name,
	sum(price * quantity) as spending 
	from customers as c
	join orders as o
	on o.customer_id=c.customer_id
	join products as p
	on o.product_id=p.product_id
	group by c.customer_name,c.customer_id
	order by spending desc
	limit 5;



--	Which product generates the most revenue? 

select 
	p.product_name,
	sum(price * quantity) as revenue
	from customers as c
	join orders as o
	on o.customer_id=c.customer_id
	join products as p
	on o.product_id=p.product_id
	group by p.product_name
	order by revenue desc 
	limit 1;



--Which category generates the most revenue? 
select 
	p.category,
	sum(price * quantity) as revenue
	from customers as c
	join orders as o
	on o.customer_id=c.customer_id
	join products as p
	on o.product_id=p.product_id
	group by p.category
	order by revenue desc 
	limit 1;



--	Which employee handles the most orders? 
select 
	e.employee_name,
	count(order_id) as total_orders
	from employees as e
	join orders as o
	on o.employee_id=e.employee_id
	group by e.employee_name
	order  by total_orders desc
	limit 1;



--	Which payment method is most used? 
select
	c.customer_id,
	p.payment_method,
	count(*) as total_orders
	from customers as c
	join orders as o
	on o.customer_id=c.customer_id
	join payments as p
	on o.order_id=p.order_id
	group by c.customer_id,p.payment_method
	order by p.payment_method desc
	limit 1;


--	What is the return rate of the business?
select 
	reason,
	count(*)as total_returns
	from returns 
	group by reason 
	order by total_returns desc;




--	Which reason is most common for returns? 

select 
	reason,
	count(*)as total_returns
	from returns 
	group by reason 
	order by total_returns desc;



1--	Which day/month has the highest order volume? 

select
	extract(month from order_date) as month,
	extract(day from order_date) as day,
	count(*) as total_orders
	from orders
	group by extract(month from order_date),extract(day from order_date)
	ORDER BY total_orders desc;





--What is the average order quantity per customer? 

select 
	c.customer_id,
	c.customer_name,
	Round(avg(quantity),2) as avg_order_quantity
	from orders as o
	join customers as c
	on o.customer_id=c.customer_id
	group by c.customer_id, c.customer_name 
	order by avg_order_quantity;
	
	

