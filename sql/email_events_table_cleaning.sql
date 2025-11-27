/* 
    Email Events Staging Cleanup
    ----------------------------
    Purpose:
      Standardize campaign naming, normalize event types, and clean
      user_agent fields in dbo.stg_email_events for accurate email
      performance analysis.

    Steps:
      1) Inspect raw data and unique campaign names.
      2) Normalize campaign_name values.
      3) Lowercase event_type values.
      4) Normalize user_agent values.
      5) Validate schema.
*/

-- 1. Preview raw data
SELECT *
FROM dbo.stg_email_events;

-- Inspect unique campaign names
SELECT DISTINCT campaign_name
FROM dbo.stg_email_events;


-- 2. Standardize campaign_name using snake_case formats
UPDATE dbo.stg_email_events
SET campaign_name =
    CASE
        WHEN campaign_name = 'Newsletter' THEN 'newsletter'
        WHEN campaign_name = 'Promo - Black Friday' THEN 'promo_black_friday'
        WHEN campaign_name = 'Winback' THEN 'winback'
        WHEN campaign_name = 'Promo - Spring' THEN 'promo_spring'
        WHEN campaign_name = 'Product Education' THEN 'product_education'
        WHEN campaign_name = 'Promo - Summer' THEN 'promo_summer'
        WHEN campaign_name = 'Welcome Series' THEN 'welcome_series'
        ELSE campaign_name
    END;

-- Confirm final list
SELECT DISTINCT campaign_name
FROM dbo.stg_email_events;


-- 3. Normalize event_type values
UPDATE dbo.stg_email_events
SET event_type = LOWER(event_type);

SELECT DISTINCT event_type
FROM dbo.stg_email_events;


-- 4. Clean user_agent values
UPDATE dbo.stg_email_events
SET user_agent = LOWER(user_agent);

UPDATE dbo.stg_email_events
SET user_agent = 'unknown'
WHERE user_agent IS NULL;

SELECT DISTINCT user_agent
FROM dbo.stg_email_events;


-- 5. Review schema
EXEC sp_help 'dbo.stg_email_events';
