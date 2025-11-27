/*
    Customer Staging Cleanup
    ------------------------
    Purpose:
      Standardize and clean customer attributes in dbo.stg_customers.

    Steps:
      1) Check for duplicate customer records.
      2) Standardize name formatting.
      3) Clean and normalize email values.
      4) Normalize phone numbers.
      5) Standardize city and state values.
      6) Clean postal codes.
      7) Normalize country values.
      8) Clean utm_source values.
      9) Create raw backup tables (one-time archival).
*/

-- 1. Inspect table
SELECT *
FROM dbo.stg_customers;


-- 1a. Check for duplicate full duplicate rows
SELECT 
    full_name, email, phone, city, state, postal_code, country, created_at, utm_source
FROM dbo.stg_customers
GROUP BY 
    full_name, email, phone, city, state, postal_code, country, created_at, utm_source
HAVING COUNT(*) > 1;


-- 2. Standardize full_name to uppercase and trim spaces
UPDATE dbo.stg_customers
SET full_name = LTRIM(RTRIM(UPPER(full_name)));


-- 3. EMAIL CLEANING
--------------------------------------------------------

-- Count total vs distinct emails
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT email) AS distinct_emails
FROM dbo.stg_customers;

-- Find invalid emails
SELECT email
FROM dbo.stg_customers
WHERE email NOT LIKE '%@%';

-- Preview cleaned email format
SELECT email, LOWER(REPLACE(email, '[at]', '@'))
FROM dbo.stg_customers;

-- Apply cleaning
UPDATE dbo.stg_customers
SET email = LOWER(REPLACE(email, '[at]', '@'));


-- 4. PHONE NUMBER CLEANUP
--------------------------------------------------------

-- Preview cleanup
SELECT phone,
       REPLACE(REPLACE(REPLACE(REPLACE(phone, '(', ''), ')', ''), '-', ''), ' ', '')
FROM dbo.stg_customers;

-- Apply cleaning
UPDATE dbo.stg_customers
SET phone = LTRIM(RTRIM(
           REPLACE(REPLACE(REPLACE(REPLACE(phone, '(', ''), ')', ''), '-', ''), ' ', '')
       ));

-- Replace NULLs with "N/A"
UPDATE dbo.stg_customers
SET phone = 'N/A'
WHERE phone IS NULL;


-- 5. CITY AND STATE STANDARDIZATION
--------------------------------------------------------

-- Convert state and city to uppercase
UPDATE dbo.stg_customers
SET state = UPPER(state);

UPDATE dbo.stg_customers
SET city = UPPER(city);

-- Manual city->state fixes (example-based)
UPDATE dbo.stg_customers
SET state =
    CASE
        WHEN city = 'AUSTIN' THEN 'TX'
        WHEN city = 'ATLANTA' THEN 'GA'
        WHEN city = 'BOSTON' THEN 'MA'
        WHEN city = 'CHARLOTTE' THEN 'NC'
        WHEN city = 'CHICAGO' THEN 'IL'
        WHEN city = 'COLUMBUS' THEN 'OH'
        WHEN city = 'DENVER' THEN 'CO'
        WHEN city = 'MIAMI' THEN 'FL'
        WHEN city = 'NEW YORK' THEN 'NY'
        WHEN city = 'PHILADELPHIA' THEN 'PA'
        WHEN city = 'PHOENIX' THEN 'AZ'
        WHEN city = 'SAN FRANCISCO' THEN 'CA'
        WHEN city = 'SEATTLE' THEN 'WA'
        ELSE state
    END;


-- 6. POSTAL CODE CLEANUP (keep first 5 chars)
--------------------------------------------------------
UPDATE dbo.stg_customers
SET postal_code = LEFT(postal_code, 5);


-- 7. COUNTRY NORMALIZATION
--------------------------------------------------------
UPDATE dbo.stg_customers
SET country = UPPER(country);

UPDATE dbo.stg_customers
SET country = 
    CASE 
        WHEN country = 'US' THEN 'UNITED STATES'
        WHEN country = 'USA' THEN 'UNITED STATES'
        ELSE country
    END;


-- 8. UTM SOURCE CLEANING
--------------------------------------------------------

-- Remove parentheses
UPDATE dbo.stg_customers
SET utm_source = REPLACE(REPLACE(utm_source, '(', ''), ')', '')
WHERE utm_source LIKE '%(%';

-- Replace NULLs with unknown
UPDATE dbo.stg_customers
SET utm_source = 'unknown'
WHERE utm_source IS NULL;

-- Standardize facebook/meta naming
UPDATE dbo.stg_customers
SET utm_source =
    CASE 
        WHEN utm_source = 'facebook' THEN 'meta'
        ELSE utm_source
    END;


-- 9. RAW BACKUP TABLES (one-time snapshots)
--------------------------------------------------------

SELECT *
INTO raw_email_events
FROM stg_email_events;

SELECT *
INTO raw_marketing_spend
FROM stg_marketing_spend;

SELECT *
INTO raw_order_items
FROM stg_order_items;

SELECT *
INTO raw_orders
FROM stg_orders;

SELECT *
INTO raw_products
FROM stg_products;

SELECT *
INTO raw_web_sessions
FROM stg_web_sessions;
