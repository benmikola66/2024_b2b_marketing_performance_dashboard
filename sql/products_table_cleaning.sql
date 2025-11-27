/*
    Products Staging Cleanup
    ------------------------
    Purpose:
      Clean and standardize product data in dbo.stg_products so it is ready
      for analysis and reporting.

    Steps:
      1) Inspect current staging table.
      2) Clean and convert unit_price and unit_cost from messy strings
         (with $, commas, "USD", etc.) into DECIMAL(12,2).
      3) Enforce numeric types for unit_price and unit_cost.
      4) Normalize category values to lowercase.
      5) Clean product_name by removing "Lead Package" labels and
         specific vertical prefixes like "Roofing Lead Package".
      6) Validate product/category combinations.
*/

-- 1. Inspect current data
SELECT *
FROM dbo.stg_products;


-- 2. Clean and convert unit_price and unit_cost to numeric
--    - Remove "$"
--    - Replace commas with dots (if used as decimal separators)
--    - Remove "USD"
--    - Trim spaces
--    - TRY_CAST to DECIMAL(12,2) to avoid hard failures on bad strings
UPDATE dbo.stg_products
SET unit_price = TRY_CAST(
        LTRIM(RTRIM(
            REPLACE(
                REPLACE(
                    REPLACE(unit_price, '$', ''),  -- remove dollar sign
                ',', '.'),                        -- normalize decimal separator
            'USD', '')                            -- remove currency code
        )) AS DECIMAL(12,2)),
    unit_cost = TRY_CAST(
        LTRIM(RTRIM(
            REPLACE(
                REPLACE(
                    REPLACE(unit_cost, '$', ''),
                ',', '.'),
            'USD', '')
        )) AS DECIMAL(12,2));


-- 3. Enforce numeric data types on price and cost columns
ALTER TABLE dbo.stg_products
ALTER COLUMN unit_price DECIMAL(12,2);

ALTER TABLE dbo.stg_products
ALTER COLUMN unit_cost DECIMAL(12,2);


-- 4. Normalize category to lowercase for consistent grouping/filtering
UPDATE dbo.stg_products
SET category = LOWER(category);


-- 5. Inspect raw product names before full standardization
SELECT DISTINCT product_name
FROM dbo.stg_products;


-- 6. Remove vertical-specific "Lead Package" phrases from product_name
--    e.g., "Roofing Lead Package", "Windows Lead Package", etc.
UPDATE dbo.stg_products
SET product_name = LTRIM(RTRIM(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        product_name,
        'Bathroom Lead Package', ''),
        'Flooring Lead Package', ''),
        'Gutters Lead Package', ''),
        'HVAC Lead Package', ''),
        'Insulation Lead Package', ''),
        'Roofing Lead Package', ''),
        'Siding Lead Package', ''),
        'Solar Lead Package', ''),
        'Windows Lead Package', '')
));


-- 7. General cleanup: remove any remaining "Lead Package" suffix
UPDATE dbo.stg_products
SET product_name = LTRIM(RTRIM(
    REPLACE(product_name, 'Lead Package', '')
));


-- 8. Quick sanity check: product_name to category mapping
--    (shows each unique combination)
SELECT
    product_name,
    category
FROM dbo.stg_products
GROUP BY
    product_name,
    category;
