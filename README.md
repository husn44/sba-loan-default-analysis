# SBA Loan Default Risk Analysis | SQL Server + Power BI

Analysis of ~900K U.S. Small Business Administration (SBA) loans to find what drives loan defaults. Data is cleaned and modelled in SQL Server and visualised in Power BI.

![Dashboard](images/dashboard_overview.png)

## Dataset
[SBA Loans – Kaggle](https://www.kaggle.com/datasets/mirbektoktogaraev/should-this-loan-be-approved-or-denied). The raw CSV is not included because of its size.

## Tools
SQL Server (T-SQL) · SSMS · Power BI · DAX

## Process
1. **Import:** bulk-loaded the raw CSV into a text-only staging table
2. **Clean:** converted messy money, dates and codes using `TRY_CAST`, `REPLACE` and `CASE` (0 conversion failures)
3. **Scope:** kept loans approved from 1990 to 2010 (847,980 loans). Earlier years had too few records and later loans hadn't matured.
4. **Model:** star schema with a loan fact view and industry, bank, state and date dimensions
5. **Analyse:** CTEs and window functions (`LAG`, `RANK`)
6. **Visualise:** Power BI dashboard with DAX measures (default rate, loss rate, time intelligence)

## Key Insights
- Overall default rate: **17.5%**
- Defaults rose from ~2–4% in the early 1990s, climbing from 1995 onwards
- Riskiest industries: **Real Estate (29.7%)** and **Finance (29.2%)**

## Repo
- `sql/`: SQL scripts, run in order 01 → 06
- `powerbi/`: dashboard `.pbix`
- `images/`: screenshots
