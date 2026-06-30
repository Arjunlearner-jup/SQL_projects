
#1. Check duplicate suppliers
SELECT supplier_name, COUNT(*) AS duplicate_count
FROM suppliers
GROUP BY supplier_name
HAVING COUNT(*) > 1;

#2. Check duplicate products
SELECT product_name, category, COUNT(*) AS duplicate_count
FROM products
GROUP BY product_name, category
HAVING COUNT(*) > 1;

#3. Check missing supplier fields
SELECT *
FROM suppliers
WHERE supplier_name IS NULL
   OR supplier_name = ''
   OR lead_time_days IS NULL
   OR rating IS NULL;
   
#4. Check missing product fields
SELECT *
FROM products
WHERE product_name IS NULL
   OR product_name = ''
   OR category IS NULL
   OR category = ''
   OR unit_cost IS NULL
   OR unit_price IS NULL
   OR reorder_level IS NULL
   OR safety_stock IS NULL;
   
#5. Check invalid stock values
SELECT *
FROM inventory
WHERE stock_qty < 0;

#6. Check invalid movement rows
SELECT *
FROM stock_movements
WHERE quantity <= 0
   OR movement_type IS NULL
   OR movement_type = '';
   
#7. Check invalid purchase orders
SELECT *
FROM purchase_orders
WHERE ordered_qty <= 0
   OR received_qty < 0
   OR order_date IS NULL
   OR po_status IS NULL
   OR po_status = '';
   
#8. Find products with missing supplier reference
SELECT *
FROM products
WHERE supplier_id IS NULL;

#9. Standardize movement type values
UPDATE stock_movements
SET movement_type = CASE
    WHEN UPPER(TRIM(movement_type)) = 'IN' THEN 'IN'
    WHEN UPPER(TRIM(movement_type)) = 'OUT' THEN 'OUT'
    WHEN UPPER(TRIM(movement_type)) = 'RETURN' THEN 'RETURN'
    WHEN UPPER(TRIM(movement_type)) = 'ADJUSTMENT' THEN 'ADJUSTMENT'
    ELSE UPPER(TRIM(movement_type))
END;

#10. Standardize purchase order status
UPDATE purchase_orders
SET po_status = CASE
    WHEN LOWER(TRIM(po_status)) = 'open' THEN 'Open'
    WHEN LOWER(TRIM(po_status)) = 'received' THEN 'Received'
    WHEN LOWER(TRIM(po_status)) = 'cancelled' THEN 'Cancelled'
    WHEN LOWER(TRIM(po_status)) = 'partial' THEN 'Partial'
    ELSE po_status
END;

#11. Trim product and supplier text
UPDATE products
SET product_name = TRIM(product_name),
    category = TRIM(category);

UPDATE suppliers
SET supplier_name = TRIM(supplier_name),
    city = TRIM(city);
    
#12. Check order quantity mismatch
SELECT *
FROM purchase_orders
WHERE received_qty > ordered_qty;

#13. Check overdue open purchase orders
SELECT *
FROM purchase_orders
WHERE po_status = 'Open'
  AND expected_date < CURRENT_DATE;
  