select * from customers
select * from employees
select * from orders
select * from products
select * from payments
select * from returns


--1.	How many total customers do we have? 

select 
	count(customer_id) as total_customers
	from customers 
	


--2.	How many orders were placed in total? 

select 
	count(order_id) as total_orders
	from orders

--	What is the total revenue generated? 
select 
	sum(price * quantity) as total_revenue
	from orders as o
	join products as p
	on o.product_id=p.product_id;
	


--	How many products are available in each category? 
select 
	category,
	 count(product_name) as total_products
	 from products
	 group by category;



--How many employees work in each department? 

select 
	department,
	employee_id
	from employees;
	


--	What is the total salary expense of the company? 

select 
SUM(salary) as salary_expense
from employees;


--	How many payments are marked as Paid vs Pending?

select 
	
	payment_status,
	count(*) as total_payments
	from payments
	where payment_status in ('Pending', 'Paid')
	group by payment_status;


--	How many returns were made in total? 
select 
count(return_id) as total_returns
from returns;

--	Which city has the most customers? 

select
	city,
	count(customer_id) as total_customers
	from customers
	group by city 
	order by total_customers desc
	limit 1;


--	What is the average product price? 
select 
	AVG(price) as avg_product_price
	from products;


