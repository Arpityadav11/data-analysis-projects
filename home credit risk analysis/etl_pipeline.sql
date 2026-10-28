Create database home_credit_risk ;
USE home_credit_risk;
SET GLOBAL local_infile = 1 ;

-- 1. Drop any half-built or misnamed tables from the Import Wizard
DROP TABLE IF EXISTS application_train;
DROP TABLE IF EXISTS previous_application;
DROP TABLE IF EXISTS app_train_clean;
DROP TABLE IF EXISTS prev_app_clean;

-- 2. Create Table 1: application_train (22 Columns)
CREATE TABLE application_train (
    SK_ID_CURR INT PRIMARY KEY,
    TARGET TINYINT,
    NAME_CONTRACT_TYPE VARCHAR(50),
    AMT_INCOME_TOTAL DECIMAL(15,2),
    AMT_CREDIT DECIMAL(15,2),
    AMT_ANNUITY DECIMAL(15,2),
    AMT_GOODS_PRICE DECIMAL(15,2),
    CODE_GENDER VARCHAR(10),
    DAYS_BIRTH INT,
    NAME_INCOME_TYPE VARCHAR(50),
    OCCUPATION_TYPE VARCHAR(50),
    ORGANIZATION_TYPE VARCHAR(100),
    DAYS_EMPLOYED INT,
    NAME_EDUCATION_TYPE VARCHAR(50),
    NAME_FAMILY_STATUS VARCHAR(50),
    CNT_CHILDREN INT,
    CNT_FAM_MEMBERS DECIMAL(5,1),
    NAME_HOUSING_TYPE VARCHAR(50),
    FLAG_OWN_REALTY CHAR(1),
    FLAG_OWN_CAR CHAR(1),
    EXT_SOURCE_2 DECIMAL(10,8),
    EXT_SOURCE_3 DECIMAL(10,8)
);

-- 3. Create Table 2: previous_application (12 Columns)
CREATE TABLE previous_application (
    SK_ID_PREV INT PRIMARY KEY,
    SK_ID_CURR INT,
    NAME_CONTRACT_STATUS VARCHAR(50),
    NAME_CONTRACT_TYPE VARCHAR(50),
    AMT_APPLICATION DECIMAL(15,2),
    AMT_CREDIT DECIMAL(15,2),
    AMT_ANNUITY DECIMAL(15,2),
    AMT_DOWN_PAYMENT DECIMAL(15,2),
    CODE_REJECT_REASON VARCHAR(20),
    DAYS_DECISION INT,
    NAME_CLIENT_TYPE VARCHAR(30),
    NAME_YIELD_GROUP VARCHAR(20),
    INDEX idx_sk_id_curr (SK_ID_CURR)
);

-- 4. Disable per-row overhead for bulk loading
SET GLOBAL local_infile = 1;
SET autocommit = 0;
SET unique_checks = 0;
SET foreign_key_checks = 0;

-- 5. Bulk Load application_train
LOAD DATA LOCAL INFILE 'C:/Users/ARPIT YADAV/Documents/Projects/Data analysis/Home credit group/app_train_clean.csv'
INTO TABLE application_train
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    SK_ID_CURR,
    TARGET,
    NAME_CONTRACT_TYPE,
    AMT_INCOME_TOTAL,
    AMT_CREDIT,
    @AMT_ANNUITY,
    @AMT_GOODS_PRICE,
    CODE_GENDER,
    DAYS_BIRTH,
    NAME_INCOME_TYPE,
    @OCCUPATION_TYPE,
    ORGANIZATION_TYPE,
    DAYS_EMPLOYED,
    NAME_EDUCATION_TYPE,
    NAME_FAMILY_STATUS,
    CNT_CHILDREN,
    @CNT_FAM_MEMBERS,
    NAME_HOUSING_TYPE,
    FLAG_OWN_REALTY,
    FLAG_OWN_CAR,
    @EXT_SOURCE_2,
    @EXT_SOURCE_3
)
SET 
    AMT_ANNUITY     = NULLIF(NULLIF(TRIM(BOTH '\r' FROM TRIM(@AMT_ANNUITY)), ''), '\\N'),
    AMT_GOODS_PRICE = NULLIF(NULLIF(TRIM(BOTH '\r' FROM TRIM(@AMT_GOODS_PRICE)), ''), '\\N'),
    OCCUPATION_TYPE = NULLIF(NULLIF(TRIM(BOTH '\r' FROM TRIM(@OCCUPATION_TYPE)), ''), '\\N'),
    CNT_FAM_MEMBERS = NULLIF(NULLIF(TRIM(BOTH '\r' FROM TRIM(@CNT_FAM_MEMBERS)), ''), '\\N'),
    EXT_SOURCE_2    = NULLIF(NULLIF(TRIM(BOTH '\r' FROM TRIM(@EXT_SOURCE_2)), ''), '\\N'),
    EXT_SOURCE_3    = NULLIF(NULLIF(TRIM(BOTH '\r' FROM TRIM(@EXT_SOURCE_3)), ''), '\\N');

COMMIT;

-- 6. Bulk Load previous_application
LOAD DATA LOCAL INFILE 'C:/Users/ARPIT YADAV/Documents/Projects/Data analysis/Home credit group/prev_app_clean.csv'
INTO TABLE previous_application
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    SK_ID_PREV,
    SK_ID_CURR,
    NAME_CONTRACT_STATUS,
    NAME_CONTRACT_TYPE,
    @AMT_APPLICATION,
    @AMT_CREDIT,
    @AMT_ANNUITY,
    @AMT_DOWN_PAYMENT,
    @CODE_REJECT_REASON,
    DAYS_DECISION,
    NAME_CLIENT_TYPE,
    @NAME_YIELD_GROUP
)
SET 
    AMT_APPLICATION    = NULLIF(NULLIF(TRIM(BOTH '\r' FROM TRIM(@AMT_APPLICATION)), ''), '\\N'),
    AMT_CREDIT         = NULLIF(NULLIF(TRIM(BOTH '\r' FROM TRIM(@AMT_CREDIT)), ''), '\\N'),
    AMT_ANNUITY        = NULLIF(NULLIF(TRIM(BOTH '\r' FROM TRIM(@AMT_ANNUITY)), ''), '\\N'),
    AMT_DOWN_PAYMENT   = NULLIF(NULLIF(TRIM(BOTH '\r' FROM TRIM(@AMT_DOWN_PAYMENT)), ''), '\\N'),
    CODE_REJECT_REASON = NULLIF(NULLIF(TRIM(BOTH '\r' FROM TRIM(@CODE_REJECT_REASON)), ''), '\\N'),
    NAME_YIELD_GROUP   = NULLIF(NULLIF(TRIM(BOTH '\r' FROM TRIM(@NAME_YIELD_GROUP)), ''), '\\N');

COMMIT;

-- 7. Restore safety checks
SET autocommit = 1;
SET unique_checks = 1;
SET foreign_key_checks = 1;

-- 8. Audit Row Counts and NULL Integrity
SELECT 
    (SELECT COUNT(*) FROM application_train) AS current_app_rows,
    (SELECT COUNT(*) FROM previous_application) AS prev_app_rows,
    (SELECT COUNT(*) FROM application_train WHERE EXT_SOURCE_3 IS NULL) AS ext_source_3_nulls ;

-- ANALYSIS PHASE

-- checking how many application we have currently and how many previous applications logged

SELECT COUNT(*) FROM application_train ;

SELECT COUNT(*) FROM previous_application ; 


-- ## APPLICATION TRAIN TABLE ANALYSIS ##

-- 1 . Overall Portfolio Risk
SELECT AVG(TARGET)*100 AS default_rate FROM applicatIon_train;

-- 2. Product Risk: Calculate the Default Rate and Total Loan Volume (Count of loans) grouped by NAME_CONTRACT_TYPE (Cash loans vs. Revolving loans).

SELECT
 name_contract_type,AVG(TARGET)*100 AS default_rate, COUNT(SK_ID_CURR) AS total_loan_volume
 FROM applicatIon_train
 GROUP BY name_contract_type;
 
-- 3. Income Source Risk: Calculate the Default Rate grouped by NAME_INCOME_TYPE. Order the results from the highest default rate to the lowest.
SELECT 
 name_income_type, COUNT(NAME_INCOME_TYPE) AS TOTAL_APP,AVG(TARGET)*100 AS default_rate 
 FROM application_train
 GROUP BY name_income_type 
 ORDER BY default_rate DESC;
 
-- 4. Financial Exposure: Calculate the average AMT_CREDIT (loan amount approved) for Defaulters (TARGET = 1) versus Non-Defaulters (TARGET = 0).
SELECT (SELECT AVG(AMT_CREDIT) FROM application_train
	WHERE TARGET = 0) AS avg_amt_credit_for_non_defaulters,
    (SELECT AVG(AMT_CREDIT) FROM application_train
	WHERE TARGET = 1) AS avg_amt_credit_for_defaulters;
    

-- ## JOINING THE TABLES 
CREATE TABLE mater_table AS 
WITH HistoricalSummary AS (
    -- Step 1: Group the historical table by applicant and calculate their totals
    SELECT 
        SK_ID_CURR,
        COUNT(SK_ID_PREV) AS total_previous_apps,
        SUM(CASE WHEN NAME_CONTRACT_STATUS = 'Refused' THEN 1 ELSE 0 END) AS total_rejections
    FROM previous_application
    GROUP BY SK_ID_CURR
)
-- Step 2: LEFT JOIN that summary to our current applicants
SELECT 
    a.SK_ID_CURR,
    target,
    NAME_CONTRACT_TYPE,
    AMT_INCOME_TOTAL,
    AMT_CREDIT,
    AMT_ANNUITY,
    AMT_GOODS_PRICE,
    CODE_GENDER,
    DAYS_BIRTH,
    NAME_INCOME_TYPE,
    OCCUPATION_TYPE,
    ORGANIZATION_TYPE,
    DAYS_EMPLOYED,
    NAME_EDUCATION_TYPE,
    NAME_FAMILY_STATUS,
    CNT_CHILDREN,
    CNT_FAM_MEMBERS,
    NAME_HOUSING_TYPE,
    FLAG_OWN_REALTY,
    FLAG_OWN_CAR,
    EXT_SOURCE_2,
    EXT_SOURCE_3,
    COALESCE(h.total_previous_apps, 0) AS total_previous_apps,
    COALESCE(h.total_rejections, 0) AS total_rejections
FROM application_train a
LEFT JOIN HistoricalSummary h ON a.SK_ID_CURR = h.SK_ID_CURR;

select * from mater_table;