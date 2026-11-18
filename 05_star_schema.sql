-- 05_star_schema.sql
-- Build star schema: fact view + dimension tables/views for Power BI

USE sba_loans;
GO

-- Dimension: industry (NAICS 2-digit sector lookup)
DROP TABLE IF EXISTS dim_industry;
CREATE TABLE dim_industry (
    naics_sector  NVARCHAR(2) PRIMARY KEY,
    industry_name NVARCHAR(100)
);
INSERT INTO dim_industry VALUES
('0','Unknown'),
('11','Agriculture, Forestry & Fishing'),
('21','Mining, Oil & Gas'),
('22','Utilities'),
('23','Construction'),
('31','Manufacturing'),('32','Manufacturing'),('33','Manufacturing'),
('42','Wholesale Trade'),
('44','Retail Trade'),('45','Retail Trade'),
('48','Transportation & Warehousing'),('49','Transportation & Warehousing'),
('51','Information'),
('52','Finance & Insurance'),
('53','Real Estate & Rental'),
('54','Professional & Technical Services'),
('55','Management of Companies'),
('56','Administrative & Support Services'),
('61','Educational Services'),
('62','Health Care & Social Assistance'),
('71','Arts, Entertainment & Recreation'),
('72','Accommodation & Food Services'),
('81','Other Services'),
('92','Public Administration');
GO

-- Fact: one row per loan, approved 1990-2010
DROP VIEW IF EXISTS vw_fact_loans;
GO
CREATE VIEW vw_fact_loans AS
SELECT
    l.loan_id,
    l.approval_date,
    l.approval_fy,
    COALESCE(d.naics_sector, '0') AS naics_sector,
    l.state,
    l.bank,
    l.term_months,
    CASE WHEN l.term_months IS NULL  THEN '0. Unknown'
         WHEN l.term_months < 12     THEN '1. Under 1 yr'
         WHEN l.term_months < 60     THEN '2. 1-5 yrs'
         WHEN l.term_months < 120    THEN '3. 5-10 yrs'
         WHEN l.term_months < 240    THEN '4. 10-20 yrs'
         ELSE '5. 20+ yrs (real estate)' END AS term_bucket,
    CASE WHEN l.disbursement_amount < 50000   THEN '1. Under $50K'
         WHEN l.disbursement_amount < 150000  THEN '2. $50K-150K'
         WHEN l.disbursement_amount < 500000  THEN '3. $150K-500K'
         WHEN l.disbursement_amount < 1000000 THEN '4. $500K-1M'
         ELSE '5. $1M+' END AS amount_bucket,
    l.num_employees,
    l.business_type,
    l.area_type,
    l.is_franchise,
    l.revolving_credit,
    l.low_doc,
    l.disbursement_amount,
    l.gross_approved,
    l.sba_guaranteed,
    l.chargeoff_amount,
    CAST(l.sba_guaranteed / NULLIF(l.gross_approved, 0) AS decimal(6,4)) AS sba_guarantee_pct,
    l.is_default,
    CASE WHEN l.is_default = 1 THEN 'Defaulted' ELSE 'Paid in full' END AS loan_outcome
FROM loans_clean l
LEFT JOIN dim_industry d ON l.naics_sector = d.naics_sector
WHERE l.approval_fy BETWEEN 1990 AND 2010;
GO

-- Dimension: bank (one row per bank)
DROP VIEW IF EXISTS vw_dim_bank;
GO
CREATE VIEW vw_dim_bank AS
SELECT bank, MAX(bank_state) AS bank_state
FROM loans_clean
WHERE bank IS NOT NULL AND bank <> ''
GROUP BY bank;
GO

-- Dimension: state
DROP VIEW IF EXISTS vw_dim_state;
GO
CREATE VIEW vw_dim_state AS
SELECT DISTINCT state
FROM loans_clean
WHERE state IS NOT NULL AND state <> '';
GO

-- Check
SELECT COUNT(*) AS fact_rows,
       CAST(100.0 * SUM(is_default) / COUNT(*) AS decimal(5,2)) AS default_rate_pct
FROM vw_fact_loans;