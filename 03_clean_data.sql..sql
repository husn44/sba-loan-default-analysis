-- 03_clean_data.sql
-- Convert raw text staging table into a clean, typed table

USE sba_loans;

DROP TABLE IF EXISTS loans_clean;

SELECT
    LTRIM(RTRIM(LoanNr_ChkDgt))                              AS loan_id,
    LTRIM(RTRIM(Name))                                       AS borrower_name,
    LTRIM(RTRIM(City))                                       AS city,
    LTRIM(RTRIM(State))                                      AS state,
    LTRIM(RTRIM(Bank))                                       AS bank,
    LTRIM(RTRIM(BankState))                                  AS bank_state,
    LEFT(LTRIM(RTRIM(NAICS)), 2)                             AS naics_sector,

    TRY_CONVERT(date, REPLACE(ApprovalDate, '-', ' '), 6)     AS approval_date,
    TRY_CONVERT(date, REPLACE(DisbursementDate, '-', ' '), 6) AS disbursement_date,

    TRY_CAST(LEFT(ApprovalFY, 4) AS int)                     AS approval_fy,

    TRY_CAST(Term AS int)                                    AS term_months,
    TRY_CAST(NoEmp AS int)                                   AS num_employees,
    TRY_CAST(CreateJob AS int)                               AS jobs_created,
    TRY_CAST(RetainedJob AS int)                             AS jobs_retained,

    CASE TRY_CAST(NewExist AS float)
        WHEN 1 THEN 'Existing' WHEN 2 THEN 'New' ELSE 'Unknown' END AS business_type,
    CASE TRY_CAST(UrbanRural AS float)
        WHEN 1 THEN 'Urban' WHEN 2 THEN 'Rural' ELSE 'Undefined' END AS area_type,
    CASE WHEN LTRIM(RTRIM(FranchiseCode)) IN ('0', '1') THEN 0 ELSE 1 END AS is_franchise,
    CASE LTRIM(RTRIM(RevLineCr)) WHEN 'Y' THEN 'Yes' WHEN 'N' THEN 'No' ELSE 'Unknown' END AS revolving_credit,
    CASE LTRIM(RTRIM(LowDoc))    WHEN 'Y' THEN 'Yes' WHEN 'N' THEN 'No' ELSE 'Unknown' END AS low_doc,

    TRY_CAST(REPLACE(REPLACE(LTRIM(RTRIM(DisbursementGross)), '$', ''), ',', '') AS decimal(14,2)) AS disbursement_amount,
    TRY_CAST(REPLACE(REPLACE(LTRIM(RTRIM(GrAppv)), '$', ''), ',', '') AS decimal(14,2))            AS gross_approved,
    TRY_CAST(REPLACE(REPLACE(LTRIM(RTRIM(ChgOffPrinGr)), '$', ''), ',', '') AS decimal(14,2))      AS chargeoff_amount,
    TRY_CAST(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(SBA_Appv)), '$', ''), ',', ''), CHAR(13), '') AS decimal(14,2)) AS sba_guaranteed,

    LTRIM(RTRIM(MIS_Status))                                 AS loan_status,
    CASE WHEN LTRIM(RTRIM(MIS_Status)) = 'CHGOFF' THEN 1 ELSE 0 END AS is_default
INTO loans_clean
FROM stg_loans
WHERE LTRIM(RTRIM(MIS_Status)) IN ('P I F', 'CHGOFF');

SELECT COUNT(*) AS clean_rows FROM loans_clean;