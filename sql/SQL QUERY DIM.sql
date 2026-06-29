CREATE OR REPLACE TABLE `bank-fraud-analytics-platform.bank_analytical.dim_customers` AS
SELECT DISTINCT
  customer_id,
  SAFE_CAST(customer_age AS INT64) AS customer_age,
  SAFE_CAST(credit_score AS INT64) AS credit_score,
  SAFE_CAST(account_age_years AS FLOAT64) AS account_age_years,
  SAFE_CAST(account_balance AS NUMERIC) AS account_balance
FROM `bank-fraud-analytics-platform.bank_raw.raw_customers`;


CREATE OR REPLACE TABLE `bank-fraud-analytics-platform.bank_analytical.dim_location` AS
SELECT
  ROW_NUMBER() OVER() AS location_id,
  country,
  city,
  SAFE_CAST(is_international AS INT64) = 1 AS is_international
FROM (
  SELECT DISTINCT
    country,
    city,
    is_international
  FROM `bank-fraud-analytics-platform.bank_raw.raw_location`
);


CREATE OR REPLACE TABLE `bank-fraud-analytics-platform.bank_analytical.dim_payment` AS
SELECT
  ROW_NUMBER() OVER() AS payment_method_id,
  payment_method
FROM (
  SELECT DISTINCT payment_method
  FROM `bank-fraud-analytics-platform.bank_raw.raw_transaction`
  WHERE payment_method IS NOT NULL
);


CREATE OR REPLACE TABLE `bank-fraud-analytics-platform.bank_analytical.dim_merchant` AS
SELECT
  ROW_NUMBER() OVER() AS merchant_category_id,
  merchant_category
FROM (
  SELECT DISTINCT merchant_category
  FROM `bank-fraud-analytics-platform.bank_raw.raw_transaction`
  WHERE merchant_category IS NOT NULL
);



CREATE OR REPLACE TABLE `bank-fraud-analytics-platform.bank_analytical.dim_device` AS
SELECT
  ROW_NUMBER() OVER() AS device_type_id,
  device_type
FROM (
  SELECT DISTINCT device_type
  FROM `bank-fraud-analytics-platform.bank_raw.raw_transaction`
  WHERE device_type IS NOT NULL
);



CREATE OR REPLACE TABLE `bank-fraud-analytics-platform.bank_analytical.dim_date` AS
SELECT DISTINCT
  CAST(FORMAT_DATE('%Y%m%d', transaction_date_parsed) AS INT64) AS date_id,
  transaction_date_parsed AS transaction_date,
  EXTRACT(YEAR FROM transaction_date_parsed) AS year,
  EXTRACT(MONTH FROM transaction_date_parsed) AS month,
  EXTRACT(DAY FROM transaction_date_parsed) AS day,
  FORMAT_DATE('%A', transaction_date_parsed) AS day_of_week,
  SAFE_CAST(b.is_weekend AS INT64) = 1 AS is_weekend
FROM (
  SELECT
    transaction_id,
    SAFE.PARSE_DATE('%d/%m/%Y', transaction_date) AS transaction_date_parsed
  FROM `bank-fraud-analytics-platform.bank_raw.raw_transaction`
) t
LEFT JOIN `bank-fraud-analytics-platform.bank_raw.raw_behavior` b
  ON t.transaction_id = b.transaction_id
WHERE transaction_date_parsed IS NOT NULL;



CREATE OR REPLACE TABLE `bank-fraud-analytics-platform.bank_analytical.dim_time` AS
SELECT DISTINCT
  SAFE_CAST(t.hour_of_day AS INT64) AS time_id,
  t.transaction_time,
  SAFE_CAST(t.hour_of_day AS INT64) AS hour_of_day,
  CASE
    WHEN SAFE_CAST(t.hour_of_day AS INT64) BETWEEN 0 AND 5 THEN 'Night'
    WHEN SAFE_CAST(t.hour_of_day AS INT64) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN SAFE_CAST(t.hour_of_day AS INT64) BETWEEN 12 AND 17 THEN 'Afternoon'
    ELSE 'Evening'
  END AS period_of_day,
  SAFE_CAST(b.is_night_transaction AS INT64) = 1 AS is_night_transaction
FROM `bank-fraud-analytics-platform.bank_raw.raw_transaction` t
LEFT JOIN `bank-fraud-analytics-platform.bank_raw.raw_behavior` b
  ON t.transaction_id = b.transaction_id;


