/*
    Order Items Staging Cleanup
    ---------------------------
    Purpose:
      Standardize line-item price values in dbo.stg_order_items.
      Order item prices often come in as strings ("$39.99", "29,99", "USD 12.00"),
      so we normalize and convert them to DECIMAL for analysis.

    Steps:
      1) Inspect raw data.
      2) Test conversion using TRY_CAST.
      3) Clean unit_price:
           - Remove "$"
           - Normalize commas
           - Remove "USD"
           - Trim whitespace
           - Convert to DECIMAL(12,2)
      4) Enforce numeric data type.
*/

-- 1. Inspect raw order item data
SELECT *
FROM dbo.stg_order_items;


-- 2. Test conversion logic safely before applying it
SELECT TRY_CAST(unit_price AS DECIMAL(12,2))
FROM dbo.stg_order_items;


-- 3. Clean and convert unit_price to DECIMAL(12,2)
UPDATE dbo.stg_order_items
SET unit_price = TRY_CAST(
    LTRIM(RTRIM(
        REPLACE(
            REPLACE(
                REPLACE(unit_price, '$', ''),     -- remove dollar sign
            ',', '.'),                           -- convert comma decimals
        'USD', '')                                -- remove currency code
    )) AS DECIMAL(12,2)
);


-- 4. Enforce numeric type
ALTER TABLE dbo.stg_order_items
ALTER COLUMN unit_price DECIMAL(12,2);
