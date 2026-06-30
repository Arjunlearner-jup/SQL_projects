#1. Monthly sales trend
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;
#2. Top 5 customers by spending
SELECT 
    c.customer_id,
    c.full_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.full_name
ORDER BY total_spent DESC
LIMIT 5;
#3. Best-selling products by quantity
SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_id, p.product_name
ORDER BY total_units_sold DESC;
#4. Revenue by category
SELECT 
    p.category,
    SUM(oi.quantity * oi.unit_price) AS category_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY category_revenue DESC;
#5. Repeat customers
SELECT 
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS delivered_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.full_name
HAVING COUNT(o.order_id) > 1;
#6. Payment method usage and total payment volume
SELECT 
    payment_method,
    COUNT(*) AS usage_count,
    SUM(amount) AS total_paid
FROM payments
WHERE payment_status = 'Paid'
GROUP BY payment_method
ORDER BY usage_count DESC, total_paid DESC;
#7. Low-stock but high-demand products
SELECT 
    p.product_id,
    p.product_name,
    p.stock_qty,
    SUM(oi.quantity) AS total_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_id, p.product_name, p.stock_qty
HAVING p.stock_qty < 50 AND SUM(oi.quantity) >= 2
ORDER BY total_sold DESC;
#8. Rank products by revenue within each category
SELECT *
FROM (
    SELECT 
        p.category,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS product_revenue,
        RANK() OVER (
            PARTITION BY p.category
            ORDER BY SUM(oi.quantity * oi.unit_price) DESC
        ) AS revenue_rank
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY p.category, p.product_name
) ranked
WHERE revenue_rank <= 3;

#9.Running monthly revenue total
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT 
    month,
    revenue,
    SUM(revenue) OVER (ORDER BY month) AS running_total
FROM monthly_revenue;

#10.Customers who spent above average
SELECT 
    customer_id,
    full_name,
    total_spent
FROM (
    SELECT 
        c.customer_id,
        c.full_name,
        SUM(o.total_amount) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.full_name
) customer_spend
WHERE total_spent > (
    SELECT AVG(total_customer_spend)
    FROM (
        SELECT SUM(total_amount) AS total_customer_spend
        FROM orders
        WHERE order_status = 'Delivered'
        GROUP BY customer_id
    ) avg_table
);

#11. Order vs payment mismatch check
SELECT 
    o.order_id,
    o.total_amount AS order_total,
    COALESCE(SUM(p.amount), 0) AS payment_total,
    o.total_amount - COALESCE(SUM(p.amount), 0) AS difference
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id
GROUP BY o.order_id, o.total_amount
HAVING difference <> 0;

#12. Customer order gap analysis with LAG()
SELECT 
    customer_id,
    full_name,
    order_date,
    previous_order_date,
    DATEDIFF(order_date, previous_order_date) AS days_between_orders
FROM (
    SELECT 
        c.customer_id,
        c.full_name,
        o.order_date,
        LAG(o.order_date) OVER (
            PARTITION BY c.customer_id
            ORDER BY o.order_date
        ) AS previous_order_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
) t
WHERE previous_order_date IS NOT NULL;