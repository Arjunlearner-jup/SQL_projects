
#1. Current stock by product
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(i.stock_qty) AS total_stock
FROM products p
JOIN inventory i ON p.product_id = i.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_stock ASC;

#2. Products below reorder level
SELECT
    p.product_id,
    p.product_name,
    SUM(i.stock_qty) AS total_stock,
    p.reorder_level
FROM products p
JOIN inventory i ON p.product_id = i.product_id
GROUP BY p.product_id, p.product_name, p.reorder_level
HAVING SUM(i.stock_qty) < p.reorder_level
ORDER BY total_stock ASC;

#3. Products below safety stock
SELECT
    p.product_id,
    p.product_name,
    SUM(i.stock_qty) AS total_stock,
    p.safety_stock
FROM products p
JOIN inventory i ON p.product_id = i.product_id
GROUP BY p.product_id, p.product_name, p.safety_stock
HAVING SUM(i.stock_qty) < p.safety_stock
ORDER BY total_stock ASC;

#4. Low-stock but high-demand products
SELECT
    p.product_id,
    p.product_name,
    SUM(i.stock_qty) AS total_stock,
    SUM(CASE WHEN sm.movement_type = 'OUT' THEN sm.quantity ELSE 0 END) AS units_moved_out
FROM products p
JOIN inventory i ON p.product_id = i.product_id
JOIN stock_movements sm ON p.product_id = sm.product_id
WHERE sm.movement_date >= CURRENT_DATE - INTERVAL 30 DAY
GROUP BY p.product_id, p.product_name
HAVING SUM(i.stock_qty) < 20
   AND SUM(CASE WHEN sm.movement_type = 'OUT' THEN sm.quantity ELSE 0 END) >= 10
ORDER BY units_moved_out DESC;

#5. Fast-moving products in the last 30 days
SELECT
    p.product_id,
    p.product_name,
    SUM(CASE WHEN sm.movement_type = 'OUT' THEN sm.quantity ELSE 0 END) AS units_sold
FROM products p
JOIN stock_movements sm ON p.product_id = sm.product_id
WHERE sm.movement_date >= CURRENT_DATE - INTERVAL 30 DAY
GROUP BY p.product_id, p.product_name
ORDER BY units_sold DESC
LIMIT 10;

#6. Slow-moving products in the last 90 days
SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(CASE WHEN sm.movement_type = 'OUT' THEN sm.quantity ELSE 0 END), 0) AS units_sold
FROM products p
LEFT JOIN stock_movements sm
    ON p.product_id = sm.product_id
   AND sm.movement_date >= CURRENT_DATE - INTERVAL 90 DAY
GROUP BY p.product_id, p.product_name
ORDER BY units_sold ASC;

#7. Products with no movement in 60 days
SELECT
    p.product_id,
    p.product_name
FROM products p
LEFT JOIN stock_movements sm
    ON p.product_id = sm.product_id
   AND sm.movement_date >= CURRENT_DATE - INTERVAL 60 DAY
WHERE sm.product_id IS NULL;

#8. Inventory value by category
SELECT
    p.category,
    SUM(i.stock_qty * p.unit_cost) AS inventory_value
FROM products p
JOIN inventory i ON p.product_id = i.product_id
GROUP BY p.category
ORDER BY inventory_value DESC;

#9. Inventory turnover by product
SELECT
    p.product_id,
    p.product_name,
    SUM(CASE WHEN sm.movement_type = 'OUT' THEN sm.quantity ELSE 0 END) AS total_outflow,
    AVG(i.stock_qty) AS avg_stock,
    ROUND(
        SUM(CASE WHEN sm.movement_type = 'OUT' THEN sm.quantity ELSE 0 END) / NULLIF(AVG(i.stock_qty), 0),
        2
    ) AS turnover_ratio
FROM products p
JOIN inventory i ON p.product_id = i.product_id
LEFT JOIN stock_movements sm ON p.product_id = sm.product_id
GROUP BY p.product_id, p.product_name
ORDER BY turnover_ratio DESC;

#10. ABC classification by stock value
WITH product_value AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(i.stock_qty * p.unit_cost) AS stock_value
    FROM products p
    JOIN inventory i ON p.product_id = i.product_id
    GROUP BY p.product_id, p.product_name
),
ranked AS (
    SELECT
        product_id,
        product_name,
        stock_value,
        SUM(stock_value) OVER (ORDER BY stock_value DESC) AS cumulative_value,
        SUM(stock_value) OVER () AS total_value
    FROM product_value
)
SELECT
    product_id,
    product_name,
    stock_value,
    ROUND(cumulative_value / total_value * 100, 2) AS cumulative_pct,
    CASE
        WHEN cumulative_value / total_value <= 0.80 THEN 'A'
        WHEN cumulative_value / total_value <= 0.95 THEN 'B'
        ELSE 'C'
    END AS abc_class
FROM ranked
ORDER BY stock_value DESC;

#11. Supplier lead time performance
SELECT
    s.supplier_id,
    s.supplier_name,
    AVG(DATEDIFF(po.received_date, po.order_date)) AS avg_actual_lead_time
FROM suppliers s
JOIN purchase_orders po ON s.supplier_id = po.supplier_id
WHERE po.received_date IS NOT NULL
GROUP BY s.supplier_id, s.supplier_name
ORDER BY avg_actual_lead_time DESC;

#12. Late purchase orders
SELECT
    po.po_id,
    s.supplier_name,
    p.product_name,
    po.order_date,
    po.expected_date,
    po.received_date,
    DATEDIFF(po.received_date, po.expected_date) AS delay_days
FROM purchase_orders po
JOIN suppliers s ON po.supplier_id = s.supplier_id
JOIN products p ON po.product_id = p.product_id
WHERE po.received_date IS NOT NULL
  AND po.received_date > po.expected_date
ORDER BY delay_days DESC;

#13. Supplier fill rate
SELECT
    s.supplier_id,
    s.supplier_name,
    SUM(po.ordered_qty) AS total_ordered,
    SUM(po.received_qty) AS total_received,
    ROUND(SUM(po.received_qty) / NULLIF(SUM(po.ordered_qty), 0) * 100, 2) AS fill_rate_pct
FROM suppliers s
JOIN purchase_orders po ON s.supplier_id = po.supplier_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY fill_rate_pct ASC;

#14. Open purchase orders by product
SELECT
    p.product_name,
    po.po_id,
    po.ordered_qty,
    po.received_qty,
    po.expected_date
FROM purchase_orders po
JOIN products p ON po.product_id = p.product_id
WHERE po.po_status = 'Open'
ORDER BY po.expected_date ASC;

#15. Warehouse stock summary
SELECT
    warehouse_id,
    SUM(stock_qty) AS total_stock,
    COUNT(DISTINCT product_id) AS products_count
FROM inventory
GROUP BY warehouse_id
ORDER BY total_stock DESC;
