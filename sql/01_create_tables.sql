-- ============================================
-- SALES ANALYTICS
-- Database schema
-- PostgreSQL
-- ============================================


-- 1. Customers
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100)
);


-- 2. Products
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    category VARCHAR(50)
);


-- 3. Orders
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


-- 4. Order Items
CREATE TABLE order_items (
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,

    CONSTRAINT pk_order_items
        PRIMARY KEY (order_id, product_id),

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);
