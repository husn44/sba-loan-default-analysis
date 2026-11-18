-- =====================================================================
-- 01_import_staging.sql
-- Purpose : Create the database and load the raw SBA CSV into a
--           staging table. Every column is loaded as text so messy
--           values (e.g. '$60,000.00 ', '1976A') can't break the import.
-- Note    : ALREADY RUN. Save only - do not run again.
-- =====================================================================

CREATE DATABASE sba_loans;
GO

USE sba_loans;

DROP TABLE IF EXISTS stg_loans;

CREATE TABLE stg_loans (
    LoanNr_ChkDgt     NVARCHAR(500) NULL,
    Name              NVARCHAR(500) NULL,
    City              NVARCHAR(500) NULL,
    State             NVARCHAR(500) NULL,
    Zip               NVARCHAR(500) NULL,
    Bank              NVARCHAR(500) NULL,
    BankState         NVARCHAR(500) NULL,
    NAICS             NVARCHAR(500) NULL,
    ApprovalDate      NVARCHAR(500) NULL,
    ApprovalFY        NVARCHAR(500) NULL,
    Term              NVARCHAR(500) NULL,
    NoEmp             NVARCHAR(500) NULL,
    NewExist          NVARCHAR(500) NULL,
    CreateJob         NVARCHAR(500) NULL,
    RetainedJob       NVARCHAR(500) NULL,
    FranchiseCode     NVARCHAR(500) NULL,
    UrbanRural        NVARCHAR(500) NULL,
    RevLineCr         NVARCHAR(500) NULL,
    LowDoc            NVARCHAR(500) NULL,
    ChgOffDate        NVARCHAR(500) NULL,
    DisbursementDate  NVARCHAR(500) NULL,
    DisbursementGross NVARCHAR(500) NULL,
    BalanceGross      NVARCHAR(500) NULL,
    MIS_Status        NVARCHAR(500) NULL,
    ChgOffPrinGr      NVARCHAR(500) NULL,
    GrAppv            NVARCHAR(500) NULL,
    SBA_Appv          NVARCHAR(500) NULL
);

BULK INSERT stg_loans
FROM 'C:\sba\SBAnational.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0d0a',
    CODEPAGE = '65001'
);

SELECT COUNT(*) AS total_rows FROM stg_loans;
