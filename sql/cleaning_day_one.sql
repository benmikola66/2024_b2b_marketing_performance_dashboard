/*
    Raw Backup Creation
    -------------------
    Purpose:
      Create one-time raw backup tables for all staging tables.
      These backups preserve the original imported data prior to
      any cleaning or transformations.

    Notes:
      - Use SELECT INTO (creates table if not exists).
      - Only run this script once during initial setup.
*/

-- Customers
SELECT *
INTO raw_customers
FROM dbo.stg_customers;


-- Email Events
SELECT *
INTO raw_email_events
FROM dbo.stg_email_events;


-- Marketing Spend
SELECT *
INTO raw_marketing_spend
FROM dbo.stg_marketing_spend;


-- Order Items
SELECT *
INTO raw_order_items
FROM dbo.stg_order_items;


-- Orders
SELECT *
INTO raw_orders
FROM dbo.stg_orders;


-- Products
SELECT *
INTO raw_products
FROM dbo.stg_products;


-- Web Sessions
SELECT *
INTO raw_web_sessions
FROM dbo.stg_web_sessions;
