-- 06_analysis_queries.sql
-- Business questions on SBA loan default risk (approved 1990-2010)

USE sba_loans;

-- Q1. Default rate trend by approval year, with year-over-year change (LAG)
WITH yearly AS (
    SELECT approval_fy,
           COUNT(*) AS loans,
           CAST(100.0 * SUM(is_default) / COUNT(*) AS decimal(5,2)) AS default_rate_pct
    FROM vw_fact_loans
    GROUP BY approval_fy
)
SELECT approval_fy, loans, default_rate_pct,
       default_rate_pct - LAG(default_rate_pct) OVER (ORDER BY approval_fy) AS change_vs_prev_year
FROM yearly
ORDER BY approval_fy;

-- Q2. Riskiest industries (RANK)
SELECT i.industry_name,
       COUNT(*) AS loans,
       CAST(100.0 * SUM(f.is_default) / COUNT(*) AS decimal(5,2)) AS default_rate_pct,
       SUM(f.chargeoff_amount) AS total_chargeoff,
       RANK() OVER (ORDER BY 1.0 * SUM(f.is_default) / COUNT(*) DESC) AS risk_rank
FROM vw_fact_loans f
JOIN dim_industry i ON f.naics_sector = i.naics_sector
GROUP BY i.industry_name
ORDER BY risk_rank;

-- Q3. Top 10 riskiest states (min 1,000 loans)
SELECT TOP 10 state,
       COUNT(*) AS loans,
       CAST(100.0 * SUM(is_default) / COUNT(*) AS decimal(5,2)) AS default_rate_pct
FROM vw_fact_loans
GROUP BY state
HAVING COUNT(*) >= 1000
ORDER BY default_rate_pct DESC;

-- Q4. New vs existing businesses, urban vs rural
SELECT business_type, area_type,
       COUNT(*) AS loans,
       CAST(100.0 * SUM(is_default) / COUNT(*) AS decimal(5,2)) AS default_rate_pct
FROM vw_fact_loans
GROUP BY business_type, area_type
ORDER BY business_type, area_type;

-- Q5. Loan term vs default (long terms are usually real-estate backed)
SELECT term_bucket,
       COUNT(*) AS loans,
       CAST(100.0 * SUM(is_default) / COUNT(*) AS decimal(5,2)) AS default_rate_pct
FROM vw_fact_loans
GROUP BY term_bucket
ORDER BY term_bucket;

-- Q6. Loan size vs default
SELECT amount_bucket,
       COUNT(*) AS loans,
       CAST(100.0 * SUM(is_default) / COUNT(*) AS decimal(5,2)) AS default_rate_pct
FROM vw_fact_loans
GROUP BY amount_bucket
ORDER BY amount_bucket;

-- Q7. Top 10 lenders by volume vs portfolio average (window AVG)
WITH bank_stats AS (
    SELECT bank,
           COUNT(*) AS loans,
           100.0 * SUM(is_default) / COUNT(*) AS default_rate_pct
    FROM vw_fact_loans
    GROUP BY bank
)
SELECT TOP 10 bank, loans,
       CAST(default_rate_pct AS decimal(5,2)) AS default_rate_pct,
       CAST(default_rate_pct - (SELECT 100.0 * SUM(is_default) / COUNT(*) FROM vw_fact_loans) AS decimal(5,2)) AS vs_portfolio_avg
FROM bank_stats
ORDER BY loans DESC;

-- Q8. Loss severity: how much of the money lent to defaulted loans was lost?
SELECT COUNT(*) AS defaulted_loans,
       SUM(disbursement_amount) AS amount_disbursed,
       SUM(chargeoff_amount)    AS amount_charged_off,
       CAST(100.0 * SUM(chargeoff_amount) / NULLIF(SUM(disbursement_amount), 0) AS decimal(5,2)) AS loss_severity_pct
FROM vw_fact_loans
WHERE is_default = 1;