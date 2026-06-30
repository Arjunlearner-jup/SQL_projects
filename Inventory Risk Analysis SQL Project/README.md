# Inventory Risk Analysis SQL Project

## Overview
This project is an end-to-end SQL portfolio project for analyzing inventory health, stock risk, warehouse stock, product movement, purchase orders, and supplier performance. It uses a relational MySQL database with five core tables: `suppliers`, `products`, `inventory`, `stock_movements`, and `purchase_orders`.[cite:34][cite:383][cite:385]

The project is designed to answer practical business questions such as which products are below reorder thresholds, which items are moving fast or slowly, which suppliers create replenishment risk, and where inventory value is concentrated. These are common goals in inventory and procurement analytics projects.[cite:34][cite:381][cite:383]

## Objectives
- Build a normalized inventory and procurement database.[cite:34][cite:383]
- Validate and clean operational data before analysis.[cite:34][cite:381]
- Identify low-stock, safety-stock, and reorder risks.[cite:34][cite:383]
- Measure product movement, turnover, and dead-stock signals.[cite:34][cite:381]
- Evaluate supplier lead time, late orders, and fill rate performance.[cite:34][cite:385]
- Prepare clean outputs for Power BI reporting and dashboarding.[cite:34][cite:381]

## Database Schema
The project uses five related tables that model supplier master data, product master data, warehouse inventory, stock transactions, and replenishment orders. This structure follows common inventory-management database patterns used in SQL practice projects.[cite:34][cite:382][cite:383]

### Tables
| Table | Purpose | Key fields |
|---|---|---|
| `suppliers` | Stores supplier information and lead-time context | `supplier_id`, `supplier_name`, `lead_time_days`, `city`, `rating` |
| `products` | Stores product master data and stocking thresholds | `product_id`, `product_name`, `category`, `unit_cost`, `unit_price`, `reorder_level`, `safety_stock`, `supplier_id` |
| `inventory` | Stores current stock by warehouse | `inventory_id`, `product_id`, `warehouse_id`, `stock_qty`, `last_updated` |
| `stock_movements` | Stores stock inflow and outflow transactions | `movement_id`, `product_id`, `warehouse_id`, `movement_date`, `movement_type`, `quantity` |
| `purchase_orders` | Stores replenishment order activity | `po_id`, `product_id`, `supplier_id`, `order_date`, `expected_date`, `received_date`, `ordered_qty`, `received_qty`, `po_status` |

## Project Flow
### 1. Database setup
The project begins by creating the database and all five tables with primary keys, foreign keys, and basic constraints such as nonnegative lead time, stock quantity, and order quantity. This creates a structured and auditable base for later analysis.[cite:34][cite:383][cite:385]

### 2. Sample data loading
Sample records are inserted for suppliers, products, inventory positions, stock movements, and purchase orders. The data is intentionally broad enough to support stock-risk, movement, and supplier-performance analysis.[cite:34][cite:383][cite:384]

### 3. Data quality checks
Before analysis, the project checks for duplicate suppliers, duplicate products, missing fields, invalid stock quantities, invalid movement rows, invalid purchase orders, missing supplier references, quantity mismatches, and overdue open purchase orders. Data validation is a standard prerequisite in inventory SQL workflows because poor-quality data directly distorts reorder and supplier metrics.[cite:34][cite:381][cite:383]

### 4. Data cleaning and standardization
Text fields are trimmed, `movement_type` values are standardized, and `po_status` values are standardized. This ensures consistent grouping, filtering, and reporting in later SQL and BI steps.[cite:34][cite:381][cite:385]

### 5. Inventory analysis
The project calculates current stock by product, products below reorder level, products below safety stock, and warehouse stock summaries. These outputs create the core inventory status layer for the project.[cite:34][cite:383]

### 6. Movement and demand analysis
The project identifies low-stock but high-demand products, fast-moving products, slow-moving products, and products with no movement in a recent period. These queries help distinguish immediate stockout risk from slow-moving inventory risk.[cite:34][cite:381][cite:383]

### 7. Value and turnover analysis
The project measures inventory value by category, turnover by product, and ABC classification by stock value. These analyses help prioritize which products matter most financially and operationally.[cite:34][cite:383]

### 8. Supplier performance analysis
The project evaluates average supplier lead time, late purchase orders, supplier fill rate, and open purchase orders by product. This reveals whether inventory risk is caused by demand patterns, supply delays, or incomplete deliveries.[cite:34][cite:381][cite:385]

### 9. Reporting and visualization
The cleaned analytical outputs are designed to feed Power BI visuals such as clustered bar charts, matrices, combo charts, and KPI cards. Inventory SQL projects commonly end with dashboard-ready outputs because the business value comes from fast operational monitoring.[cite:34][cite:381][cite:383]

## Data Cleaning Checks Included
The SQL script includes the following data-cleaning and validation steps:
- Duplicate supplier detection.
- Duplicate product detection.
- Missing supplier-field checks.
- Missing product-field checks.
- Invalid stock quantity checks.
- Invalid stock movement checks.
- Invalid purchase order checks.
- Missing supplier reference checks.
- Standardization of `movement_type`.
- Standardization of `po_status`.
- Trimming of supplier and product text fields.
- Ordered versus received quantity mismatch checks.
- Overdue open purchase order checks.[cite:34][cite:381][cite:383]

## Analysis Queries Included
The project contains SQL analysis for the following business questions:

### Inventory health
- Current stock by product.
- Products below reorder level.
- Products below safety stock.
- Warehouse stock summary.[cite:34][cite:383]

### Stock risk and movement
- Low-stock but high-demand products.
- Fast-moving products in the last 30 days.
- Slow-moving products in the last 90 days.
- Products with no movement in 60 days.[cite:34][cite:381][cite:383]

### Financial inventory analysis
- Inventory value by category.
- Inventory turnover by product.
- ABC classification by stock value.[cite:34][cite:383]

### Procurement and supplier analysis
- Supplier lead time performance.
- Late purchase orders.
- Supplier fill rate.
- Open purchase orders by product.[cite:34][cite:381][cite:385]

## Example Business Questions Answered
- Which products are currently below reorder level or safety stock?[cite:34][cite:383]
- Which products are at risk because they are low in stock but have strong recent demand?[cite:34][cite:381]
- Which categories hold the highest inventory value?[cite:34][cite:383]
- Which products turn over quickly, and which may be overstocked or slow moving?[cite:34][cite:381]
- Which suppliers have the slowest lead times or weakest fill rates?[cite:34][cite:385]
- Which purchase orders arrived late, and by how many days?[cite:34][cite:381]

## Suggested Power BI Visuals
| Analysis area | Recommended visual |
|---|---|
| Current stock by product | Clustered bar chart |
| Products below reorder level | Clustered bar chart |
| Products below safety stock | Clustered bar chart |
| Low-stock but high-demand products | Clustered bar chart |
| Fast-moving products | Clustered bar chart |
| Slow-moving products | Matrix or clustered bar chart |
| Inventory value by category | Clustered bar chart |
| Inventory turnover by product | Matrix |
| ABC classification | Line and clustered column chart plus matrix |
| Supplier lead time | Clustered bar chart |
| Late purchase orders | Matrix |
| Supplier fill rate | Matrix or clustered bar chart |
| Open purchase orders by product | Matrix |
| Warehouse stock summary | Matrix or clustered bar chart |

## Tools Used
- MySQL for database creation, cleaning, and analysis logic.
- Power BI for dashboarding and business visualization.
- SQL joins, aggregations, `CASE`, `CTE`, window functions, and date functions for analysis.[cite:34][cite:381][cite:383]

## Key Skills Demonstrated
- Relational database design.[cite:34][cite:383]
- Data validation and cleaning in SQL.[cite:34][cite:381]
- Inventory and procurement analysis.[cite:34][cite:385]
- Business metric design for reorder, safety stock, turnover, and fill rate.[cite:34][cite:381]
- Dashboard-ready query development for Power BI.[cite:34][cite:383]

## Conclusion
This project demonstrates a full SQL workflow for inventory risk analysis, from schema design and data quality checks to operational, financial, and supplier-performance reporting. It is suitable as a portfolio project because it shows both technical SQL capability and business understanding of stock control, replenishment, and supply risk.[cite:34][cite:381][cite:383]
