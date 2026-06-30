# Ecommerce Sales Analysis Using SQL

## Project Overview
This project focuses on cleaning and analyzing an ecommerce transactional database using SQL. The dataset includes five core tables: `customers`, `orders`, `order_items`, `payments`, and `products`. The work is divided into two major phases: data cleaning and business analysis.

The data cleaning phase improves reliability by checking duplicates, missing values, invalid records, inconsistent labels, payment mismatches, and stock errors. The analysis phase answers business questions related to revenue trends, customer value, product performance, payment behavior, inventory risk, and operational consistency.

## Project Flow

### 1. Understand the schema
The first step is to review the structure of the five tables and understand how they connect:

- `customers` → customer-level details
- `orders` → order header information such as date, customer, amount, and status
- `order_items` → product-level lines within each order
- `payments` → payment transactions for each order
- `products` → product catalog, category, and stock

### 2. Data cleaning and validation
Before doing any business analysis, the dataset should be validated and standardized.

#### Duplicate checks
- Find duplicate customers.
- Find duplicate products.
- Remove exact duplicate rows where required.

#### Missing value checks
- Check for null or blank values in important columns such as customer name, product name, payment method, order status, quantity, and price.

#### Standardization
- Standardize `payment_method` values, for example: `upi`, `UPI`, `Upi` → `UPI`
- Standardize `order_status` values, for example: `delivered`, `Delivered`, `DELIVERED` → `Delivered`

#### Data validity checks
- Find invalid rows in `order_items`, such as negative quantity, zero quantity, or negative unit price.
- Compare order totals with summed line-item values.
- Compare order totals with payment totals.
- Find products with negative stock quantities.

### 3. Exploratory SQL analysis
After cleaning, SQL queries are used to generate business insights across sales, customers, products, payments, and operations.

### 4. Present findings
The final step is to organize results into a portfolio-friendly format with:
- Project title
- Short summary
- Schema description
- SQL queries grouped by theme
- Screenshots of outputs or charts
- Key insights
- Final conclusion

## Database Schema

### 1. customers
Stores customer information.

Typical columns:
- `customer_id`
- `full_name`
- `email`
- `city`
- `created_at`

### 2. orders
Stores order-level transaction details.

Typical columns:
- `order_id`
- `customer_id`
- `order_date`
- `total_amount`
- `order_status`

### 3. order_items
Stores line-item details for each order.

Typical columns:
- `order_item_id`
- `order_id`
- `product_id`
- `quantity`
- `unit_price`

### 4. payments
Stores payment transaction data.

Typical columns:
- `payment_id`
- `order_id`
- `payment_method`
- `amount`
- `payment_status`

### 5. products
Stores product catalog information.

Typical columns:
- `product_id`
- `product_name`
- `category`
- `stock_qty`
- `price`

## Data Cleaning SQL

### 1. Find duplicate customers
```sql
SELECT full_name, COUNT(*) AS duplicate_count
FROM customers
GROUP BY full_name
HAVING COUNT(*) > 1;
```

### 2. Find duplicate products
```sql
SELECT product_name, category, COUNT(*) AS duplicate_count
FROM products
GROUP BY product_name, category
HAVING COUNT(*) > 1;
```

### 3. Check missing values
```sql
SELECT *
FROM customers
WHERE full_name IS NULL OR full_name = '';
```

Example checks can also be repeated for `products.product_name`, `orders.order_status`, `payments.payment_method`, and `order_items.quantity`.

### 4. Standardize payment methods
```sql
UPDATE payments
SET payment_method = CASE
    WHEN LOWER(payment_method) = 'upi' THEN 'UPI'
    WHEN LOWER(payment_method) = 'cod' THEN 'COD'
    WHEN LOWER(payment_method) = 'card' THEN 'Card'
    WHEN LOWER(payment_method) = 'net banking' THEN 'Net Banking'
    ELSE payment_method
END;
```

### 5. Standardize order status
```sql
UPDATE orders
SET order_status = CASE
    WHEN LOWER(order_status) = 'delivered' THEN 'Delivered'
    WHEN LOWER(order_status) = 'pending' THEN 'Pending'
    WHEN LOWER(order_status) = 'cancelled' THEN 'Cancelled'
    WHEN LOWER(order_status) = 'shipped' THEN 'Shipped'
    ELSE order_status
END;
```

### 6. Remove exact duplicates
```sql
DELETE t1
FROM customers t1
JOIN customers t2
  ON t1.customer_id > t2.customer_id
 AND t1.full_name = t2.full_name;
```

### 7. Find invalid order_items rows
```sql
SELECT *
FROM order_items
WHERE quantity <= 0 OR unit_price < 0;
```

### 8. Check order total vs line items
```sql
SELECT 
    o.order_id,
    o.total_amount,
    SUM(oi.quantity * oi.unit_price) AS line_total,
    o.total_amount - SUM(oi.quantity * oi.unit_price) AS difference
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING difference <> 0;
```

### 9. Check payment mismatch
```sql
SELECT 
    o.order_id,
    o.total_amount AS order_total,
    COALESCE(SUM(p.amount), 0) AS payment_total,
    o.total_amount - COALESCE(SUM(p.amount), 0) AS difference
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id
GROUP BY o.order_id, o.total_amount
HAVING difference <> 0;
```

### 10. Find products with negative stock
```sql
SELECT *
FROM products
WHERE stock_qty < 0;
```

## SQL Analysis

## Sales Analysis

### 1. Monthly sales trend
```sql
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;
```

### 2. Running monthly revenue total
```sql
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
```

## Customer Analysis

### 3. Top 5 customers by spending
```sql
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
```

### 4. Repeat customers
```sql
SELECT 
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS delivered_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.full_name
HAVING COUNT(o.order_id) > 1;
```

### 5. Customers who spent above average
```sql
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
```

### 6. Customer order gap analysis with LAG()
```sql
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
```

## Product Analysis

### 7. Best-selling products by quantity
```sql
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
```

### 8. Revenue by category
```sql
SELECT 
    p.category,
    SUM(oi.quantity * oi.unit_price) AS category_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY category_revenue DESC;
```

### 9. Low-stock but high-demand products
```sql
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
```

### 10. Rank products by revenue within each category
```sql
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
```

## Payment and Operational Analysis

### 11. Payment method usage and total payment volume
```sql
SELECT 
    payment_method,
    COUNT(*) AS usage_count,
    SUM(amount) AS total_paid
FROM payments
WHERE payment_status = 'Paid'
GROUP BY payment_method
ORDER BY usage_count DESC, total_paid DESC;
```

### 12. Order vs payment mismatch check
```sql
SELECT 
    o.order_id,
    o.total_amount AS order_total,
    COALESCE(SUM(p.amount), 0) AS payment_total,
    o.total_amount - COALESCE(SUM(p.amount), 0) AS difference
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id
GROUP BY o.order_id, o.total_amount
HAVING difference <> 0;
```

## Suggested Screenshots or Charts
Add screenshots of query results or charts for these outputs:

- Monthly sales trend line chart
- Top 5 customers by spending bar chart
- Revenue by category bar chart
- Best-selling products table
- Payment method breakdown chart
- Low-stock but high-demand products table
- Order vs payment mismatch table

Recommended file naming for images:
- `monthly_sales_trend.png`
- `top_customers.png`
- `category_revenue.png`
- `payment_method_usage.png`

## Key Insights
- Monthly revenue helps identify growth trends and peak business periods.
- Top-spending and repeat customers reveal loyal and high-value buyers.
- Product and category analysis shows which items drive the business most.
- Payment method analysis helps understand customer checkout preferences.
- Stock checks help identify products that need urgent replenishment.
- Data validation queries help detect inconsistencies between line items, orders, and payments.

## Conclusion
This project demonstrates a full SQL workflow for ecommerce analytics, starting from data cleaning and ending with business insight generation. It highlights technical SQL skills such as joins, aggregations, grouping, window functions, common table expressions, and data validation checks.

It also shows business understanding by connecting raw data to decisions related to sales tracking, customer retention, product performance, inventory planning, and payment reconciliation.
