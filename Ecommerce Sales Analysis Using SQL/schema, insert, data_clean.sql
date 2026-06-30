CREATE DATABASE ecommerce_sales_analytics;
USE ecommerce_sales_analytics;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(50),
    join_date DATE NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_qty INT NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
INSERT INTO customers VALUES
(1, 'Arjun Patel', 'arjun@email.com', 'Dublin', '2025-01-10'),
(2, 'Neha Sharma', 'neha@email.com', 'Cork', '2025-01-15'),
(3, 'Rahul Mehta', 'rahul@email.com', 'Galway', '2025-02-01'),
(4, 'Priya Nair', 'priya@email.com', 'Limerick', '2025-02-10'),
(5, 'Karan Singh', 'karan@email.com', 'Dublin', '2025-03-05');

INSERT INTO products VALUES
(101, 'Wireless Mouse', 'Electronics', 25.00, 100),
(102, 'Bluetooth Headphones', 'Electronics', 80.00, 50),
(103, 'Office Chair', 'Furniture', 150.00, 20),
(104, 'Notebook Pack', 'Stationery', 12.00, 200),
(105, 'Water Bottle', 'Lifestyle', 18.00, 150),
(106, 'Desk Lamp', 'Furniture', 35.00, 40);

INSERT INTO orders VALUES
(1001, 1, '2025-03-01', 'Delivered', 105.00),
(1002, 2, '2025-03-02', 'Delivered', 150.00),
(1003, 1, '2025-03-10', 'Delivered', 37.00),
(1004, 3, '2025-04-01', 'Pending', 80.00),
(1005, 4, '2025-04-03', 'Delivered', 180.00),
(1006, 5, '2025-04-10', 'Delivered', 43.00),
(1007, 2, '2025-05-01', 'Cancelled', 25.00),
(1008, 3, '2025-05-05', 'Delivered', 162.00);

INSERT INTO order_items VALUES
(1, 1001, 101, 1, 25.00),
(2, 1001, 102, 1, 80.00),
(3, 1002, 103, 1, 150.00),
(4, 1003, 104, 1, 12.00),
(5, 1003, 105, 1, 18.00),
(6, 1003, 101, 1, 25.00),
(7, 1004, 102, 1, 80.00),
(8, 1005, 103, 1, 150.00),
(9, 1005, 106, 1, 35.00),
(10, 1006, 104, 2, 12.00),
(11, 1006, 105, 1, 18.00),
(12, 1007, 101, 1, 25.00),
(13, 1008, 102, 1, 80.00),
(14, 1008, 106, 1, 35.00),
(15, 1008, 105, 1, 18.00),
(16, 1008, 104, 1, 12.00);

INSERT INTO payments VALUES
(501, 1001, '2025-03-01', 'Card', 105.00, 'Paid'),
(502, 1002, '2025-03-02', 'UPI', 150.00, 'Paid'),
(503, 1003, '2025-03-10', 'Card', 37.00, 'Paid'),
(504, 1004, '2025-04-01', 'Wallet', 80.00, 'Pending'),
(505, 1005, '2025-04-03', 'Card', 180.00, 'Paid'),
(506, 1006, '2025-04-10', 'UPI', 43.00, 'Paid'),
(507, 1007, '2025-05-01', 'Card', 25.00, 'Failed'),
(508, 1008, '2025-05-05', 'Card', 145.00, 'Paid');

SELECT email, COUNT(*) AS duplicate_count
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

SELECT product_name, category, COUNT(*) AS duplicate_count
FROM products
GROUP BY product_name, category
HAVING COUNT(*) > 1;

SELECT *
FROM customers
WHERE full_name IS NULL
   OR email IS NULL
   OR city IS NULL;
   
SET SQL_SAFE_UPDATES = 0;

UPDATE payments
SET payment_method = CASE
    WHEN LOWER(payment_method) IN ('cc', 'card', 'credit card') THEN 'Card'
    WHEN LOWER(payment_method) IN ('upi', 'gpay', 'phonepe') THEN 'UPI'
    WHEN LOWER(payment_method) IN ('paypal', 'pp') THEN 'PayPal'
    ELSE payment_method
END
WHERE payment_id > 0
  AND LOWER(payment_method) IN ('cc', 'card', 'credit card', 'upi', 'gpay', 'phonepe', 'paypal', 'pp');
  
UPDATE orders
SET order_status = CASE
    WHEN LOWER(order_status) IN ('delivered', 'deliv') THEN 'Delivered'
    WHEN LOWER(order_status) IN ('pending', 'processing') THEN 'Pending'
    WHEN LOWER(order_status) IN ('cancelled', 'canceled') THEN 'Cancelled'
    ELSE order_status
END;

DELETE c1
FROM customers c1
JOIN customers c2
  ON c1.email = c2.email
 AND c1.customer_id > c2.customer_id;
 
 SELECT *
FROM order_items
WHERE quantity <= 0
   OR unit_price <= 0;
   
SELECT 
    o.order_id,
    o.total_amount,
    SUM(oi.quantity * oi.unit_price) AS computed_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING ABS(o.total_amount - SUM(oi.quantity * oi.unit_price)) > 0.01;

SELECT 
    o.order_id,
    o.total_amount,
    SUM(p.amount) AS paid_amount
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id
GROUP BY o.order_id, o.total_amount
HAVING ABS(o.total_amount - COALESCE(SUM(p.amount), 0)) > 0.01;

SELECT *
FROM products
WHERE stock_qty < 0;