CREATE OR REPLACE VIEW `bank-fraud-analytics-platform.bank_analytical.vw_fraud_transactions` AS
SELECT
    t.transaction_id,
    t.customer_id,
    SAFE_CAST(t.transaction_amount AS NUMERIC) AS transaction_amount,
    f.fraud_type,
    l.country,
    l.city
FROM `bank-fraud-analytics-platform.bank_raw.raw_transaction` t
JOIN `bank-fraud-analytics-platform.bank_raw.raw_fraud` f
    ON t.transaction_id = f.transaction_id
LEFT JOIN `bank-fraud-analytics-platform.bank_raw.raw_location` l
    ON t.transaction_id = l.transaction_id
WHERE SAFE_CAST(f.is_fraud AS INT64) = 1;

CREATE OR REPLACE VIEW `bank-fraud-analytics-platform.bank_analytical.vw_customer_risk` AS
SELECT
    t.customer_id,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(CASE WHEN SAFE_CAST(f.is_fraud AS INT64) = 1 THEN 1 ELSE 0 END) AS total_frauds,
    ROUND(
        SAFE_DIVIDE(
            SUM(CASE WHEN SAFE_CAST(f.is_fraud AS INT64) = 1 THEN 1 ELSE 0 END),
            COUNT(t.transaction_id)
        ) * 100,
        2
    ) AS fraud_rate_percent
FROM `bank-fraud-analytics-platform.bank_raw.raw_transaction` t
LEFT JOIN `bank-fraud-analytics-platform.bank_raw.raw_fraud` f
    ON t.transaction_id = f.transaction_id
GROUP BY t.customer_id;

CREATE OR REPLACE VIEW `bank-fraud-analytics-platform.bank_analytical.vw_fraud_by_payment_method` AS
SELECT
    t.payment_method,
    COUNT(t.transaction_id) AS fraud_count
FROM `bank-fraud-analytics-platform.bank_raw.raw_transaction` t
JOIN `bank-fraud-analytics-platform.bank_raw.raw_fraud` f
    ON t.transaction_id = f.transaction_id
WHERE SAFE_CAST(f.is_fraud AS INT64) = 1
GROUP BY t.payment_method;

CREATE OR REPLACE VIEW `bank-fraud-analytics-platform.bank_analytical.vw_fraud_by_device` AS
SELECT
    t.device_type,
    COUNT(t.transaction_id) AS fraud_count
FROM `bank-fraud-analytics-platform.bank_raw.raw_transaction` t
JOIN `bank-fraud-analytics-platform.bank_raw.raw_fraud` f
    ON t.transaction_id = f.transaction_id
WHERE SAFE_CAST(f.is_fraud AS INT64) = 1
GROUP BY t.device_type;

CREATE OR REPLACE VIEW `bank-fraud-analytics-platform.bank_analytical.vw_fraud_by_location` AS
SELECT
    l.country,
    l.city,
    COUNT(l.transaction_id) AS fraud_count
FROM `bank-fraud-analytics-platform.bank_raw.raw_location` l
JOIN `bank-fraud-analytics-platform.bank_raw.raw_fraud` f
    ON l.transaction_id = f.transaction_id
WHERE SAFE_CAST(f.is_fraud AS INT64) = 1
GROUP BY l.country, l.city;

CREATE OR REPLACE VIEW `bank-fraud-analytics-platform.bank_analytical.vw_high_risk_transactions` AS
SELECT
    t.transaction_id,
    t.customer_id,
    SAFE_CAST(t.transaction_amount AS NUMERIC) AS transaction_amount,
    SAFE_CAST(b.failed_attempts AS INT64) AS failed_attempts,
    SAFE_CAST(l.distance_from_home_km AS FLOAT64) AS distance_from_home_km,
    SAFE_CAST(f.is_fraud AS INT64) AS is_fraud
FROM `bank-fraud-analytics-platform.bank_raw.raw_transaction` t
JOIN `bank-fraud-analytics-platform.bank_raw.raw_behavior` b
    ON t.transaction_id = b.transaction_id
LEFT JOIN `bank-fraud-analytics-platform.bank_raw.raw_location` l
    ON t.transaction_id = l.transaction_id
LEFT JOIN `bank-fraud-analytics-platform.bank_raw.raw_fraud` f
    ON t.transaction_id = f.transaction_id
WHERE SAFE_CAST(b.failed_attempts AS INT64) >= 3;