/*
    Marketing Spend Staging Cleanup
    -------------------------------
    Purpose:
      Standardize and prepare marketing spend data in dbo.stg_marketing_spend
      for consistent reporting and attribution analysis.

    Steps:
      1) Inspect raw staging data.
      2) Review channel values and total spend.
      3) Normalize channel field to lowercase.
      4) Clean and convert spend amounts from text to DECIMAL(12,2):
           - Remove "$"
           - Replace commas with dots (if present)
           - Remove "USD"
           - Trim spaces
           - TRY_CAST into DECIMAL
      5) Enforce correct numeric data type on spend.
      6) Inspect table schema.
*/

-- 1. View raw data
SELECT *
FROM dbo.stg_marketing_spend;


-- 2. Inspect channel values and spending totals
SELECT DISTINCT channel
FROM dbo.stg_marketing_spend;

SELECT SUM(spend) AS total_raw_spend
FROM dbo.stg_marketing_spend;


-- 3. Normalize channel names to lowercase
UPDATE dbo.stg_marketing_spend
SET channel = LOWER(channel);


-- 4. Clean and convert spend amounts to DECIMAL(12,2)
UPDATE dbo.stg_marketing_spend
SET spend = TRY_CAST(
    LTRIM(RTRIM(
        REPLACE(
            REPLACE(
                REPLACE(spend, '$', ''),  -- remove dollar sign
            ',', '.'),                    -- normalize decimal separator
        'USD', '')                        -- remove currency label
    )) AS DECIMAL(12,2)
);


-- 5. Inspect schema before enforcing types
EXEC sp_help 'dbo.stg_marketing_spend';


-- 6. Enforce numeric type on spend
ALTER TABLE dbo.stg_marketing_spend
ALTER COLUMN spend DECIMAL(12,2);
