/*
    Web Sessions Staging Cleanup
    -----------------------------
    Purpose:
      Standardize and clean web session tracking fields in stg_web_sessions.

    Steps:
      1) Inspect current data.
      2) Normalize utm_source:
           - Lowercase
           - Remove parentheses
           - Standardize "facebook" to "meta"
      3) Normalize device values to lowercase.
      4) Inspect distinct utm_source values and table schema.
*/

-- 1. Inspect current staging table
SELECT *
FROM dbo.stg_web_sessions;


-- 2. Clean utm_source: remove parentheses and lowercase
UPDATE dbo.stg_web_sessions
SET utm_source = LOWER(REPLACE(REPLACE(utm_source, '(', ''), ')', ''))
WHERE utm_source LIKE '%(%';


-- 3. Normalize device to lowercase
UPDATE dbo.stg_web_sessions
SET device = LOWER(device);


-- 4. Standardize brand naming: "facebook" -> "meta"
UPDATE dbo.stg_web_sessions
SET utm_source = REPLACE(utm_source, 'facebook', 'meta')
WHERE utm_source LIKE '%facebook%';


-- 5. Check distinct utm_source values after cleaning
SELECT DISTINCT utm_source
FROM dbo.stg_web_sessions;


-- 6. Inspect table structure / data types
EXEC sp_help 'dbo.stg_web_sessions';
