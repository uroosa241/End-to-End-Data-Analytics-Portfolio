CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(100),
    customer_type VARCHAR(50)
);


CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department VARCHAR(50),
    salary NUMERIC(12,2)
);


CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price NUMERIC(10,2)
);



CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    employee_id INT,
    product_id INT,
    quantity INT,
    order_date DATE
);



CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20)
);

CREATE TABLE returns (
    return_id INT PRIMARY KEY,
    order_id INT,
    reason VARCHAR(100)
);


alter table orders
add constraint fk_customers
foreign key (customer_id)
references customers(customer_id);


alter table orders
add constraint fk_employees
foreign key (employee_id)
references employees(employee_id);


alter table orders 
add constraint fk_products
foreign key (product_id)
references products(product_id);

alter table payments 
add constraint fk_order_payment
foreign key (order_id)
references orders(order_id);


alter table  returns
add constraint  fk_order_return
foreign key (order_id)
references orders(order_id);
