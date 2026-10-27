CREATE TABLE sales (
    sale_id INTEGER PRIMARY KEY,
    sale_date DATE NOT NULL,
    salesperson TEXT NOT NULL,
    region TEXT NOT NULL,
    amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0)
);

INSERT INTO sales
    (sale_id, sale_date, salesperson, region, amount)
VALUES
    (1,  '2026-01-01', 'Anu',   'South', 1000.00),
    (2,  '2026-01-01', 'Ravi',  'North', 1500.00),
    (3,  '2026-01-02', 'Anu',   'South',  500.00),
    (4,  '2026-01-02', 'Ravi',  'North', 1500.00),
    (5,  '2026-01-03', 'Meena', 'South', 2000.00),
    (6,  '2026-01-03', 'Ravi',  'North',  800.00),
    (7,  '2026-01-04', 'Anu',   'South', 2000.00),
    (8,  '2026-01-04', 'Meena', 'South', 2000.00),
    (9,  '2026-01-05', 'Ravi',  'North', 1200.00),
    (10, '2026-01-05', 'Anu',   'South',  700.00);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0)
);

INSERT INTO products
    (product_id, product_name, category_id, price)
VALUES
    (1, 'Laptop A', 1, 90000),
    (2, 'Laptop B', 1, 80000),
    (3, 'Laptop C', 1, 80000),
    (4, 'Laptop D', 1, 70000),
    (5, 'Phone A',  2, 40000),
    (6, 'Phone B',  2, 40000),
    (7, 'Phone C',  2, 30000);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL
        CHECK (total_amount >= 0)
);

INSERT INTO orders
    (order_id, customer_id, order_date, total_amount)
VALUES
    (1, 101, '2026-01-01', 1000),
    (2, 101, '2026-01-05', 1500),
    (3, 101, '2026-01-10',  500),
    (4, 102, '2026-01-02', 2000),
    (5, 102, '2026-01-06', 2500),
    (6, 103, '2026-01-03',  800);
