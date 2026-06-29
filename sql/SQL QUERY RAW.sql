CREATE OR REPLACE EXTERNAL TABLE `bank-fraud-analytics-platform.bank_raw.raw_transaction` 
( 
  transaction_id STRING, 
  customer_id STRING, 
  transaction_date STRING, 
  transaction_time STRING, 
  hour_of_day STRING, 
  transaction_amount STRING, 
  merchant_category STRING, 
  payment_method STRING, 
  device_type STRING, 
) 

OPTIONS( format = 'CSV', uris = ['gs://transactions-fraud-data/bronze/transactions.csv'], 
skip_leading_rows = 1, 
field_delimiter = ';', 
allow_quoted_newlines = TRUE, 
allow_jagged_rows = TRUE ); 

CREATE OR REPLACE EXTERNAL TABLE `bank-fraud-analytics-platform.bank_raw.raw_customers`
( 
  customer_id STRING, 
  customer_age STRING, 
  credit_score STRING, 
  account_age_years STRING, 
  account_balance STRING, 
) 

OPTIONS( format = 'CSV', uris = ['gs://transactions-fraud-data/bronze/customers.csv'], 
skip_leading_rows = 1, 
field_delimiter = ';', 
allow_quoted_newlines = TRUE,
allow_jagged_rows = TRUE ); 

CREATE OR REPLACE EXTERNAL TABLE `bank-fraud-analytics-platform.bank_raw.raw_location`
( 
  transaction_id STRING,
  country STRING, 
  city STRING, 
  distance_from_home_km STRING,
  is_international STRING, 
) 

OPTIONS( format = 'CSV', uris = ['gs://transactions-fraud-data/bronze/location.csv'], 
skip_leading_rows = 1, 
field_delimiter = ';', 
allow_quoted_newlines = TRUE,
allow_jagged_rows = TRUE );

CREATE OR REPLACE EXTERNAL TABLE `bank-fraud-analytics-platform.bank_raw.raw_behavior`
( 
  transaction_id STRING, 
  num_prev_transactions STRING, 
  transaction_freq_monthly STRING, 
  time_since_last_txn_hrs STRING, 
  failed_attempts STRING, 
  pin_changed_recently STRING, 
  is_weekend STRING, 
  is_night_transaction STRING, 
) 

OPTIONS( format = 'CSV', uris = ['gs://transactions-fraud-data/bronze/behavior.csv'], 
skip_leading_rows = 1, 
field_delimiter = ';', 
allow_quoted_newlines = TRUE,
allow_jagged_rows = TRUE ); 


CREATE OR REPLACE EXTERNAL TABLE `bank-fraud-analytics-platform.bank_raw.raw_fraud`
(
   transaction_id STRING, 
   is_fraud STRING, 
   fraud_type STRING, 
) 
OPTIONS( format = 'CSV', uris = ['gs://transactions-fraud-data/bronze/fraud.csv'], 
skip_leading_rows = 1, 
field_delimiter = ';', 
allow_quoted_newlines = TRUE, 
allow_jagged_rows = TRUE );