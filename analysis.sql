
-- Day 5 - Task 1: SQL Analysis
-- Database: PostgreSQL

-- =========================================
-- 1. CREATE TABLES
-- =========================================

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

CREATE TABLE customers (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100)
);

CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    amount NUMERIC(10, 2),
    ordered_at DATE
);

CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100),
    attrs JSONB
);

-- =========================================
-- 2. INSERT SAMPLE DATA
-- =========================================

INSERT INTO customers (id, name, city) VALUES
(1, 'Arun', 'Chennai'),
(2, 'Priya', 'Mumbai'),
(3, 'Rahul', 'Chennai'),
(4, 'Divya', 'Bangalore');

-- Original 3 orders + 6 additional orders
INSERT INTO orders (id, customer_id, amount, ordered_at) VALUES
(101, 1, 700, '2026-01-05'),
(102, 1, 600, '2026-02-10'),
(103, 2, 300, '2026-01-20'),
(104, 2, 800, '2026-02-03'),
(105, 3, 1200, '2026-01-08'),
(106, 3, 450, '2026-02-15'),
(107, 1, 250, '2026-03-01'),
(108, 2, 200, '2026-03-05'),
(109, 3, 300, '2026-03-20');

INSERT INTO products (id, name, attrs) VALUES
(1, 'Laptop A', '{"brand":"Dell","ram":16}'),
(2, 'Laptop B', '{"brand":"HP","ram":8}');

-- =========================================
-- 3. TOTAL SALES PER CUSTOMER
-- JOIN, GROUP BY AND HAVING
-- =========================================

SELECT
    c.id,
    c.name,
    SUM(o.amount) AS total_sales
FROM customers c
JOIN orders o
    ON c.id = o.customer_id
GROUP BY c.id, c.name
HAVING SUM(o.amount) > 1000
ORDER BY total_sales DESC;

-- =========================================
-- 4. CUSTOMERS WHO NEVER ORDERED
-- LEFT JOIN
-- =========================================

SELECT
    c.id,
    c.name,
    c.city
FROM customers c
LEFT JOIN orders o
    ON c.id = o.customer_id
WHERE o.id IS NULL;

-- =========================================
-- 5. TOP CUSTOMER PER CITY
-- CTE AND ROW_NUMBER
-- =========================================

WITH customer_sales AS (
    SELECT
        c.id,
        c.name,
        c.city,
        SUM(o.amount) AS total_sales
    FROM customers c
    JOIN orders o
        ON c.id = o.customer_id
    GROUP BY c.id, c.name, c.city
),
ranked_customers AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY city
            ORDER BY total_sales DESC
        ) AS city_rank
    FROM customer_sales
)
SELECT
    id,
    name,
    city,
    total_sales
FROM ranked_customers
WHERE city_rank = 1
ORDER BY city;

-- =========================================
-- 6. RANK ORDERS AND SHOW PREVIOUS ORDER
-- ROW_NUMBER AND LAG
-- =========================================

SELECT
    id AS order_id,
    customer_id,
    amount,
    ordered_at,

    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY amount DESC
    ) AS order_rank,

    LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY ordered_at
    ) AS previous_order_amount

FROM orders
ORDER BY customer_id, ordered_at;

-- =========================================
-- 7. JSONB: FIND DELL PRODUCTS
-- JSONB CONTAINS (@>) AND EXTRACTION (->>)
-- =========================================

SELECT
    id,
    name,
    attrs ->> 'brand' AS brand,
    attrs ->> 'ram' AS ram
FROM products
WHERE attrs @> '{"brand": "Dell"}'::jsonb;
