/*
    Orders Staging Cleanup
    ----------------------
    Purpose:
      Standardize and clean order-level data in dbo.stg_orders so it is ready
      for analysis and joins.

    Steps:
      1) Inspect current staging table.
      2) Normalize text fields (order_status, shipping_country, payment_method).
      3) Standardize country values for the U.S.
      4) Clean and convert order_total from string to DECIMAL(12,2).
      5) Normalize coupon_code, replacing NULL with 'N/A'.
      6) Inspect distinct values for key dimensions.
*/

-- 1. Inspect current data
SELECT *
FROM dbo.stg_orders;


-- 2. Normalize order_status to lowercase
UPDATE dbo.stg_orders
SET order_status = LOWER(order_status);

-- Check distinct values after normalization
SELECT DISTINCT order_status
FROM dbo.stg_orders;


-- 3. Inspect coupon_code and shipping_country values
SELECT DISTINCT coupon_code
FROM dbo.stg_orders;

SELECT DISTINCT shipping_country
FROM dbo.stg_orders;


-- 4. Normalize shipping_country
--    - Convert to uppercase
--    - Standardize US variants
UPDATE dbo.stg_orders
SET shipping_country = UPPER(shipping_country);

UPDATE dbo.stg_orders
SET shipping_country = CASE 
                           WHEN shipping_country = 'US'  THEN 'UNITED STATES'
                           WHEN shipping_country = 'USA' THEN 'UNITED STATES'
                           ELSE shipping_country
                       END;


-- 5. Clean and convert order_total from string to DECIMAL(12,2)
--    - Remove "$"
--    - Replace commas with dots if they are used as decimal separators
--    - Remove "USD"
--    - Trim whitespace
--    - TRY_CAST into numeric
UPDATE dbo.stg_orders
SET order_total = TRY_CAST(
    LTRIM(RTRIM(
        REPLACE(
            REPLACE(
                REPLACE(order_total, '$', ''),
            ',', '.'),
        'USD', '')
    )) AS DECIMAL(12,2)
);

-- Enforce numeric type on order_total
ALTER TABLE dbo.stg_orders
ALTER COLUMN order_total DECIMAL(12,2);


-- 6. Normalize payment_method values and inspect them
UPDATE dbo.stg_orders
SET payment_method = LOWER(payment_method);

SELECT DISTINCT payment_method
FROM dbo.stg_orders;


-- 7. Standardize coupon_code: replace NULL with 'N/A'
UPDATE dbo.stg_orders
SET coupon_code = 'N/A'
WHERE coupon_code IS NULL;
