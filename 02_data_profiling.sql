-- 02_data_profiling.sql
-- Inspect raw staging data and find data quality issues

USE sba_loans;

-- 1. Row count
SELECT COUNT(*) AS total_rows FROM stg_loans;

-- 2. Sample of raw rows
SELECT TOP 20 * FROM stg_loans;

-- 3. Loan outcome values
SELECT MIS_Status, COUNT(*) AS n
FROM stg_loans
GROUP BY MIS_Status
ORDER BY n DESC;

-- 4. Messy yes/no columns
SELECT RevLineCr, COUNT(*) AS n FROM stg_loans GROUP BY RevLineCr ORDER BY n DESC;
SELECT LowDoc,    COUNT(*) AS n FROM stg_loans GROUP BY LowDoc    ORDER BY n DESC;

-- 5. Business type codes (1 = existing, 2 = new, 0 = unknown)
SELECT NewExist, COUNT(*) AS n FROM stg_loans GROUP BY NewExist ORDER BY n DESC;

-- 6. Approval years that are not clean numbers (e.g. '1976A')
SELECT ApprovalFY, COUNT(*) AS n
FROM stg_loans
WHERE TRY_CAST(ApprovalFY AS int) IS NULL
GROUP BY ApprovalFY;