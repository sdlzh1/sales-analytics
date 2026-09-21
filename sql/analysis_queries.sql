-- ============================================
-- SALES ANALYTICS
-- PostgreSQL
-- ============================================


-- 1. Total Revenue
-- Общая выручка

SELECT
    SUM(p.price * oi.quantity) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id;


-- 2. Order Count
-- Количество заказов

SELECT
    COUNT(*) AS order_count
FROM orders;


-- 3. Average Order Value
-- Средний чек

WITH order_totals AS (
    SELECT
        oi.order_id,
        SUM(p.price * oi.quantity) AS order_total
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY oi.order_id
)
SELECT
    AVG(order_total) AS average_order_value
FROM order_totals;


-- 4. Top 5 Customers by Revenue
-- Топ-5 клиентов по выручке

SELECT
    c.customer_id,
    c.name,
    SUM(p.price * oi.quantity) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    c.customer_id,
    c.name
ORDER BY total_revenue DESC
LIMIT 5;


-- 5. Customers with Revenue Above 500
-- Клиенты с выручкой более 500

SELECT
    c.customer_id,
    c.name,
    SUM(p.price * oi.quantity) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    c.customer_id,
    c.name
HAVING SUM(p.price * oi.quantity) > 500
ORDER BY total_revenue DESC;


-- 6. Customers Without Orders
-- Клиенты без заказов

SELECT
    c.customer_id,
    c.name,
    c.city
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- 7. Average Order Value by Customer
-- Средний чек по каждому клиенту

WITH order_totals AS (
    SELECT
        c.customer_id,
        c.name,
        o.order_id,
        SUM(p.price * oi.quantity) AS order_total
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        c.customer_id,
        c.name,
        o.order_id
)
SELECT
    customer_id,
    name,
    AVG(order_total) AS average_order_value
FROM order_totals
GROUP BY
    customer_id,
    name
ORDER BY average_order_value DESC;


-- 8. Revenue by Category
-- Выручка по категориям

SELECT
    p.category,
    SUM(p.price * oi.quantity) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;


-- 9. Units Sold by Category
-- Количество проданных единиц по категориям

SELECT
    p.category,
    SUM(oi.quantity) AS units_sold
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY units_sold DESC;


-- 10. Top 5 Products by Revenue
-- Топ-5 товаров по выручке

SELECT
    p.product_id,
    p.product_name,
    SUM(p.price * oi.quantity) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_revenue DESC
LIMIT 5;


-- 11. Top 3 Orders by Value
-- Топ-3 заказа по стоимости

SELECT
    o.order_id,
    o.order_date,
    SUM(p.price * oi.quantity) AS order_total
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    o.order_id,
    o.order_date
ORDER BY order_total DESC
LIMIT 3;


-- 12. Orders with Customer Information
-- Заказы с информацией о клиентах

SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    c.name,
    SUM(p.price * oi.quantity) AS order_total
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    o.order_id,
    o.order_date,
    c.customer_id,
    c.name
ORDER BY order_total DESC;


-- 13. Monthly Revenue
-- Выручка по месяцам

SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(p.price * oi.quantity) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;


-- 14. Monthly Revenue with Previous Month
-- Выручка по месяцам с выручкой предыдущего месяца

WITH month_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_date) AS month,
        SUM(p.price * oi.quantity) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY DATE_TRUNC('month', o.order_date)
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
FROM month_revenue
ORDER BY month;


-- 15. Customer Revenue Ranking
-- Рейтинг клиентов по выручке

WITH revenue AS (
    SELECT
        c.customer_id,
        c.name,
        SUM(p.price * oi.quantity) AS total_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        c.customer_id,
        c.name
)
SELECT
    customer_id,
    name,
    total_revenue,
    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank
FROM revenue
ORDER BY revenue_rank;
