-- 04_validation_checks.sql
-- Confirm cleaning worked and first look at default rates

USE sba_loans;

-- 1. Overall default rate
SELECT COUNT(*)                                     AS loans,
       SUM(is_default)                              AS defaults,
       ROUND(100.0 * SUM(is_default) / COUNT(*), 2) AS default_rate_pct
FROM loans_clean;

-- 2. Values that failed to convert (should be 0 or very small)
SELECT COUNT(*) - COUNT(approval_date)       AS bad_approval_dates,
       COUNT(*) - COUNT(approval_fy)         AS bad_years,
       COUNT(*) - COUNT(disbursement_amount) AS bad_amounts,
       COUNT(*) - COUNT(sba_guaranteed)      AS bad_sba_amounts
FROM loans_clean;

-- 3. Loans and default rate by approval year
SELECT approval_fy,
       COUNT(*)                                     AS loans,
       ROUND(100.0 * SUM(is_default) / COUNT(*), 2) AS default_rate_pct
FROM loans_clean
GROUP BY approval_fy
ORDER BY approval_fy;