CREATE DATABASE inventory_risk_analysis;
USE inventory_risk_analysis;

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100) NOT NULL,
    lead_time_days INT NOT NULL CHECK (lead_time_days >= 0),
    city VARCHAR(100),
    rating DECIMAL(3,2) CHECK (rating BETWEEN 0 AND 5)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL CHECK (unit_cost >= 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    reorder_level INT NOT NULL CHECK (reorder_level >= 0),
    safety_stock INT NOT NULL CHECK (safety_stock >= 0),
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    stock_qty INT NOT NULL CHECK (stock_qty >= 0),
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE stock_movements (
    movement_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    movement_date DATE NOT NULL,
    movement_type VARCHAR(20) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE purchase_orders (
    po_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    supplier_id INT NOT NULL,
    order_date DATE NOT NULL,
    expected_date DATE,
    received_date DATE,
    ordered_qty INT NOT NULL CHECK (ordered_qty > 0),
    received_qty INT DEFAULT 0 CHECK (received_qty >= 0),
    po_status VARCHAR(20) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

INSERT INTO suppliers (supplier_name, lead_time_days, city, rating) VALUES
('Alpha Wholesale', 5, 'Dublin', 4.50),
('Nova Supply Co', 8, 'Cork', 4.20),
('Metro Distributors', 12, 'Galway', 3.90),
('Prime Industrial', 6, 'Limerick', 4.70),
('GreenLine Traders', 10, 'Waterford', 4.10);

INSERT INTO products (product_name, category, unit_cost, unit_price, reorder_level, safety_stock, supplier_id) VALUES
('Wireless Mouse', 'Electronics', 12.00, 20.00, 30, 15, 1),
('Mechanical Keyboard', 'Electronics', 35.00, 60.00, 20, 10, 1),
('USB-C Charger', 'Electronics', 10.00, 18.00, 40, 20, 2),
('Office Chair', 'Furniture', 75.00, 120.00, 10, 5, 3),
('Standing Desk', 'Furniture', 150.00, 250.00, 8, 4, 3),
('Notebook Pack', 'Stationery', 3.00, 6.00, 100, 50, 4),
('Ball Pen Box', 'Stationery', 2.50, 5.00, 120, 60, 4),
('Water Bottle', 'Lifestyle', 8.00, 15.00, 25, 12, 5),
('Backpack', 'Lifestyle', 18.00, 35.00, 18, 8, 5),
('Desk Lamp', 'Furniture', 20.00, 40.00, 15, 7, 2);

INSERT INTO inventory (product_id, warehouse_id, stock_qty, last_updated) VALUES
(1, 101, 22, '2026-06-01 10:00:00'),
(2, 101, 12, '2026-06-01 10:00:00'),
(3, 101, 35, '2026-06-01 10:00:00'),
(4, 102, 6, '2026-06-01 10:00:00'),
(5, 102, 3, '2026-06-01 10:00:00'),
(6, 103, 140, '2026-06-01 10:00:00'),
(7, 103, 90, '2026-06-01 10:00:00'),
(8, 101, 10, '2026-06-01 10:00:00'),
(9, 102, 7, '2026-06-01 10:00:00'),
(10, 101, 9, '2026-06-01 10:00:00');

INSERT INTO stock_movements (product_id, warehouse_id, movement_date, movement_type, quantity) VALUES
(1, 101, '2026-05-05', 'OUT', 8),
(1, 101, '2026-05-15', 'OUT', 6),
(1, 101, '2026-05-22', 'IN', 20),
(1, 101, '2026-06-10', 'OUT', 10),

(2, 101, '2026-05-08', 'OUT', 4),
(2, 101, '2026-05-18', 'OUT', 3),
(2, 101, '2026-06-12', 'IN', 10),
(2, 101, '2026-06-20', 'OUT', 6),

(3, 101, '2026-05-03', 'OUT', 12),
(3, 101, '2026-05-19', 'OUT', 9),
(3, 101, '2026-06-11', 'IN', 25),
(3, 101, '2026-06-23', 'OUT', 14),

(4, 102, '2026-05-02', 'OUT', 2),
(4, 102, '2026-06-07', 'OUT', 1),
(4, 102, '2026-06-15', 'IN', 5),

(5, 102, '2026-05-06', 'OUT', 1),
(5, 102, '2026-06-05', 'OUT', 1),
(5, 102, '2026-06-18', 'IN', 2),

(6, 103, '2026-05-01', 'OUT', 30),
(6, 103, '2026-05-20', 'OUT', 25),
(6, 103, '2026-06-09', 'IN', 100),
(6, 103, '2026-06-22', 'OUT', 40),

(7, 103, '2026-05-04', 'OUT', 20),
(7, 103, '2026-05-25', 'OUT', 18),
(7, 103, '2026-06-14', 'IN', 50),

(8, 101, '2026-05-10', 'OUT', 7),
(8, 101, '2026-06-16', 'OUT', 6),
(8, 101, '2026-06-21', 'IN', 8),

(9, 102, '2026-05-09', 'OUT', 5),
(9, 102, '2026-06-19', 'OUT', 4),
(9, 102, '2026-06-25', 'IN', 6),

(10, 101, '2026-05-14', 'OUT', 3),
(10, 101, '2026-06-02', 'OUT', 2),
(10, 101, '2026-06-17', 'IN', 4);

INSERT INTO purchase_orders (product_id, supplier_id, order_date, expected_date, received_date, ordered_qty, received_qty, po_status) VALUES
(1, 1, '2026-05-18', '2026-05-23', '2026-05-22', 20, 20, 'Received'),
(2, 1, '2026-06-08', '2026-06-13', '2026-06-12', 10, 10, 'Received'),
(3, 2, '2026-06-05', '2026-06-13', '2026-06-14', 25, 25, 'Received'),
(4, 3, '2026-06-10', '2026-06-22', '2026-06-25', 5, 5, 'Received'),
(5, 3, '2026-06-12', '2026-06-24', NULL, 6, 0, 'Open'),
(6, 4, '2026-06-01', '2026-06-07', '2026-06-09', 100, 100, 'Received'),
(7, 4, '2026-06-11', '2026-06-17', '2026-06-17', 50, 50, 'Received'),
(8, 5, '2026-06-15', '2026-06-25', NULL, 20, 0, 'Open'),
(9, 5, '2026-06-20', '2026-06-30', NULL, 15, 0, 'Open'),
(10, 2, '2026-06-10', '2026-06-18', '2026-06-17', 4, 4, 'Received');