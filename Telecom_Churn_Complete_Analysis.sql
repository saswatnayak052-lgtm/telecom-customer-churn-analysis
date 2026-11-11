 /*==============================================================
 DATABASE     : Telecom_Churn_DB
    DBMS         : Microsoft SQL Server
    DATASET      : IBM Telco Customer Churn
    TOTAL ROWS   : 7,043

    PROJECT OBJECTIVE:
    To analyze customer churn patterns, identify high-risk
    customer segments, and generate business recommendations
    using Microsoft SQL Server.

    SQL CONCEPTS:
    Data Cleaning, Aggregation, Subqueries, CTEs,
    Window Functions, Views, Stored Procedures,
    Indexes and Query Optimization.

==============================================================*/


USE Telecom_Churn_DB;
GO
/*--------------------------------------------------------------
  STAGE 1: DATABASE SETUP

  QUERY 1.1: DATABASE AND TABLE VERIFICATION

  PURPOSE:
  Verify the active database and check the number of
  records in the raw and staging tables.
--------------------------------------------------------------*/

USE Telecom_Churn_DB;
GO

SELECT
    DB_NAME() AS Current_Database;

SELECT
    COUNT(*) AS Raw_Table_Records
FROM dbo.[WA_Fn-UseC_-Telco-Customer-Churn];

SELECT
    COUNT(*) AS Staging_Table_Records
FROM dbo.telecom_churn_staging;
GO
/*--------------------------------------------------------------
  STAGE 2: DATA QUALITY ASSESSMENT

  QUERY 2.1: MISSING VALUE ANALYSIS

  PURPOSE:
  Identify missing or blank values in important columns
  before performing data cleaning.
--------------------------------------------------------------*/

SELECT
    COUNT(*) AS Total_Rows,

    SUM(
        CASE
            WHEN customerID IS NULL OR TRIM(customerID) = ''
            THEN 1 ELSE 0
        END
    ) AS Missing_CustomerID,

    SUM(
        CASE
            WHEN TotalCharges IS NULL OR TRIM(TotalCharges) = ''
            THEN 1 ELSE 0
        END
    ) AS Missing_TotalCharges,

    SUM(
        CASE
            WHEN gender IS NULL OR TRIM(gender) = ''
            THEN 1 ELSE 0
        END
    ) AS Missing_Gender,

    SUM(
        CASE
            WHEN Churn IS NULL OR TRIM(Churn) = ''
            THEN 1 ELSE 0
        END
    ) AS Missing_Churn

FROM dbo.telecom_churn_staging;
GO
/*--------------------------------------------------------------
  QUERY 2.2: DUPLICATE CUSTOMER ID CHECK

  PURPOSE:
  Identify duplicate customer IDs in the staging table.
--------------------------------------------------------------*/

SELECT
    COUNT(*) - COUNT(DISTINCT customerID)
        AS Duplicate_CustomerIDs
FROM dbo.telecom_churn_staging;
GO
/*--------------------------------------------------------------
  QUERY 2.3: INVESTIGATION OF MISSING TOTAL CHARGES

  PURPOSE:
  Check whether missing TotalCharges values are associated
  with zero-tenure customers and valid MonthlyCharges.
--------------------------------------------------------------*/

SELECT
    COUNT(*) AS Missing_TotalCharges,

    SUM(
        CASE
            WHEN TRY_CONVERT(INT, tenure) = 0
            THEN 1 ELSE 0
        END
    ) AS Zero_Tenure_Customers,

    SUM(
        CASE
            WHEN TRY_CONVERT(DECIMAL(10,2), MonthlyCharges) IS NULL
            THEN 1 ELSE 0
        END
    ) AS Invalid_MonthlyCharges

FROM dbo.telecom_churn_staging

WHERE TotalCharges IS NULL
   OR TRIM(TotalCharges) = '';
GO
/*--------------------------------------------------------------
  QUERY 2.4: EXACT DUPLICATE RECORD CHECK/duplicate customer ID verification

  PURPOSE:
  Identify whether identical customer records exist
  in the staging table.
--------------------------------------------------------------*/

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT customerID) AS Unique_CustomerIDs,
    COUNT(*) - COUNT(DISTINCT customerID)
        AS Duplicate_CustomerIDs
FROM dbo.telecom_churn_staging;
GO
/*==============================================================
  STAGE 3: DATA CLEANING

  QUERY 3.1: CREATE CLEAN CUSTOMER TABLE

  PURPOSE:
  Convert staging data into a clean table with appropriate
  data types and handle missing TotalCharges values.

  CLEANING DECISION:
  The 11 blank TotalCharges values belong to customers
  with zero tenure. These values are replaced with 0.
==============================================================*/

USE Telecom_Churn_DB;
GO

IF OBJECT_ID('dbo.telecom_churn_clean', 'U') IS NOT NULL
    DROP TABLE dbo.telecom_churn_clean;
GO

SELECT
    customerID,
    TRIM(gender) AS gender,
    TRY_CONVERT(INT, SeniorCitizen) AS SeniorCitizen,
    TRIM(Partner) AS Partner,
    TRIM(Dependents) AS Dependents,
    TRY_CONVERT(INT, tenure) AS tenure,
    TRIM(PhoneService) AS PhoneService,
    TRIM(MultipleLines) AS MultipleLines,
    TRIM(InternetService) AS InternetService,
    TRIM(OnlineSecurity) AS OnlineSecurity,
    TRIM(OnlineBackup) AS OnlineBackup,
    TRIM(DeviceProtection) AS DeviceProtection,
    TRIM(TechSupport) AS TechSupport,
    TRIM(StreamingTV) AS StreamingTV,
    TRIM(StreamingMovies) AS StreamingMovies,
    TRIM(Contract) AS Contract,
    TRIM(PaperlessBilling) AS PaperlessBilling,
    TRIM(PaymentMethod) AS PaymentMethod,

    TRY_CONVERT(DECIMAL(10,2), MonthlyCharges)
        AS MonthlyCharges,

    CASE
        WHEN TotalCharges IS NULL OR TRIM(TotalCharges) = ''
        THEN 0
        ELSE TRY_CONVERT(DECIMAL(10,2), TotalCharges)
    END AS TotalCharges,

    TRIM(Churn) AS Churn

INTO dbo.telecom_churn_clean
FROM dbo.telecom_churn_staging;
GO
/*--------------------------------------------------------------
  QUERY 3.2: CLEAN TABLE VERIFICATION

  PURPOSE:
  Verify total customers, total charges and zero-charge
  records after data cleaning.
--------------------------------------------------------------*/

SELECT
    COUNT(*) AS Total_Customers,
    SUM(TotalCharges) AS Total_Charges,
    SUM(
        CASE
            WHEN TotalCharges = 0 THEN 1
            ELSE 0
        END
    ) AS Zero_TotalCharges

FROM dbo.telecom_churn_clean;
GO
/*==============================================================
  STAGE 4: EXPLORATORY DATA ANALYSIS

  QUERY 4.1: OVERALL CUSTOMER CHURN ANALYSIS

  PURPOSE:
  Calculate total customers, churned customers and
  customer percentage for each churn category.
==============================================================*/

SELECT
    Churn,
    COUNT(*) AS Total_Customers,

    CAST(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM dbo.telecom_churn_clean)
        AS DECIMAL(5,2)
    ) AS Customer_Percentage

FROM dbo.telecom_churn_clean

GROUP BY Churn;
GO
/*--------------------------------------------------------------
  QUERY 4.2: CONTRACT-WISE CHURN ANALYSIS

  PURPOSE:
  Compare customer churn across different contract types.
--------------------------------------------------------------*/

SELECT
    Contract,
    COUNT(*) AS Total_Customers,

    SUM(
        CASE WHEN Churn = 'Yes'
        THEN 1 ELSE 0 END
    ) AS Churned_Customers,

    CAST(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Churn_Rate

FROM dbo.telecom_churn_clean

GROUP BY Contract

ORDER BY Churn_Rate DESC;
GO
/*--------------------------------------------------------------
  QUERY 4.3: TENURE-WISE CHURN ANALYSIS

  PURPOSE:
  Analyze customer churn based on the number of months
  customers have stayed with the company.
--------------------------------------------------------------*/

SELECT
    CASE
        WHEN tenure <= 12 THEN '0-12 Months'
        WHEN tenure <= 24 THEN '13-24 Months'
        WHEN tenure <= 48 THEN '25-48 Months'
        ELSE '49+ Months'
    END AS Tenure_Group,

    COUNT(*) AS Total_Customers,

    SUM(
        CASE WHEN Churn = 'Yes'
        THEN 1 ELSE 0 END
    ) AS Churned_Customers,

    CAST(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Churn_Rate

FROM dbo.telecom_churn_clean

GROUP BY
    CASE
        WHEN tenure <= 12 THEN '0-12 Months'
        WHEN tenure <= 24 THEN '13-24 Months'
        WHEN tenure <= 48 THEN '25-48 Months'
        ELSE '49+ Months'
    END

ORDER BY MIN(tenure);
GO
/*--------------------------------------------------------------
  QUERY 4.4: INTERNET SERVICE-WISE CHURN ANALYSIS

  PURPOSE:
  Compare churn rates among customers using different
  internet service categories.
--------------------------------------------------------------*/

SELECT
    InternetService,
    COUNT(*) AS Total_Customers,

    SUM(
        CASE WHEN Churn = 'Yes'
        THEN 1 ELSE 0 END
    ) AS Churned_Customers,

    CAST(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Churn_Rate

FROM dbo.telecom_churn_clean

GROUP BY InternetService

ORDER BY Churn_Rate DESC;
GO
/*--------------------------------------------------------------
  QUERY 4.5: PAYMENT METHOD-WISE CHURN ANALYSIS

  PURPOSE:
  Identify which payment methods are associated with
  higher customer churn.
--------------------------------------------------------------*/

SELECT
    PaymentMethod,
    COUNT(*) AS Total_Customers,

    SUM(
        CASE WHEN Churn = 'Yes'
        THEN 1 ELSE 0 END
    ) AS Churned_Customers,

    CAST(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Churn_Rate

FROM dbo.telecom_churn_clean

GROUP BY PaymentMethod

ORDER BY Churn_Rate DESC;
GO
/*--------------------------------------------------------------
  QUERY 4.6: MONTHLY CHARGES-WISE CHURN ANALYSIS

  PURPOSE:
  Analyze customer churn across different monthly
  charge categories.
--------------------------------------------------------------*/

SELECT
    CASE
        WHEN MonthlyCharges < 35 THEN 'Low Charges'
        WHEN MonthlyCharges <= 70 THEN 'Medium Charges'
        ELSE 'High Charges'
    END AS Charges_Group,

    COUNT(*) AS Total_Customers,

    SUM(
        CASE WHEN Churn = 'Yes'
        THEN 1 ELSE 0 END
    ) AS Churned_Customers,

    CAST(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Churn_Rate

FROM dbo.telecom_churn_clean

GROUP BY
    CASE
        WHEN MonthlyCharges < 35 THEN 'Low Charges'
        WHEN MonthlyCharges <= 70 THEN 'Medium Charges'
        ELSE 'High Charges'
    END

ORDER BY MIN(MonthlyCharges);
GO
/*==============================================================
  STAGE 5.1: SUBQUERY ANALYSIS
  OBJECTIVE: Identify customers paying above-average
             monthly charges.
==============================================================*/

USE Telecom_Churn_DB;
GO

SELECT
    customerID,
    Contract,
    MonthlyCharges,
    Churn
FROM dbo.telecom_churn_clean
WHERE MonthlyCharges >
(
    SELECT AVG(MonthlyCharges)
    FROM dbo.telecom_churn_clean
)
ORDER BY MonthlyCharges DESC;
GO
/*==============================================================
  STAGE 5.2: CTE ANALYSIS
  OBJECTIVE: Calculate customer churn rate by contract type.
==============================================================*/

WITH ContractChurn AS
(
    SELECT
        Contract,
        COUNT(*) AS Total_Customers,
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
            AS Churned_Customers
    FROM dbo.telecom_churn_clean
    GROUP BY Contract
)
SELECT
    Contract,
    Total_Customers,
    Churned_Customers,
    CAST(
        Churned_Customers * 100.0 / Total_Customers
        AS DECIMAL(5,2)
    ) AS Churn_Rate
FROM ContractChurn
ORDER BY Churn_Rate DESC;
GO
/*==============================================================
  STAGE 5.3: ROW_NUMBER() WINDOW FUNCTION
  OBJECTIVE: Find the top 5 customers by monthly charges
             within each contract category.
==============================================================*/

WITH RankedCustomers AS
(
    SELECT
        customerID,
        Contract,
        MonthlyCharges,
        Churn,
        ROW_NUMBER() OVER
        (
            PARTITION BY Contract
            ORDER BY MonthlyCharges DESC
        ) AS Customer_Rank
    FROM dbo.telecom_churn_clean
)
SELECT
    customerID,
    Contract,
    MonthlyCharges,
    Churn,
    Customer_Rank
FROM RankedCustomers
WHERE Customer_Rank <= 5
ORDER BY Contract, Customer_Rank;
GO
/*==============================================================
  STAGE 5.4: RANK() WINDOW FUNCTION
  OBJECTIVE: Rank internet service categories based on
             their customer churn rate.
==============================================================*/

WITH InternetChurn AS
(
    SELECT
        InternetService,
        COUNT(*) AS Total_Customers,
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
            AS Churned_Customers,
        CAST(
            SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*)
            AS DECIMAL(5,2)
        ) AS Churn_Rate
    FROM dbo.telecom_churn_clean
    GROUP BY InternetService
)
SELECT
    InternetService,
    Total_Customers,
    Churned_Customers,
    Churn_Rate,
    RANK() OVER (ORDER BY Churn_Rate DESC) AS Churn_Rank
FROM InternetChurn
ORDER BY Churn_Rank;
GO
/*==============================================================
  STAGE 5.5: CASE WHEN CUSTOMER SEGMENTATION
  OBJECTIVE: Classify customers into retention priority
             groups using churn status and tenure.
==============================================================*/

SELECT
    customerID,
    tenure,
    Contract,
    MonthlyCharges,
    Churn,
    CASE
        WHEN Churn = 'Yes' AND tenure <= 12
            THEN 'High Priority'

        WHEN Churn = 'Yes' AND tenure BETWEEN 13 AND 24
            THEN 'Medium Priority'

        WHEN Churn = 'Yes'
            THEN 'Other Churned Customers'

        ELSE 'Active Customers'
    END AS Retention_Category
FROM dbo.telecom_churn_clean;
GO
/*==============================================================
  STAGE 5.6: AVG() WINDOW FUNCTION
  OBJECTIVE: Compare each customer's monthly charges with
             the average monthly charges of their contract type.
==============================================================*/

SELECT
    customerID,
    Contract,
    MonthlyCharges,
    Churn,
    AVG(MonthlyCharges) OVER
    (
        PARTITION BY Contract
    ) AS Avg_Contract_MonthlyCharges
FROM dbo.telecom_churn_clean;
GO
/*==============================================================
  STAGE 6.1: OVERALL BUSINESS PERFORMANCE
  OBJECTIVE: Generate a summary of overall customer churn.
==============================================================*/

SELECT
    COUNT(*) AS Total_Customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS Churned_Customers,
		    SUM(CASE WHEN Churn = 'No' THEN 1 ELSE 0 END)
        AS Active_Customers,

    CAST(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Overall_Churn_Rate

FROM dbo.telecom_churn_clean;
GO
/*==============================================================
  STAGE 6.2: CONTRACT-WISE BUSINESS ANALYSIS
  OBJECTIVE: Identify contract categories with higher churn.
==============================================================*/

SELECT
    Contract,
    COUNT(*) AS Total_Customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS Churned_Customers,

    CAST(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Churn_Rate

FROM dbo.telecom_churn_clean
GROUP BY Contract
ORDER BY Churn_Rate DESC;
GO
/*==============================================================
  STAGE 6.3: TENURE-WISE BUSINESS ANALYSIS
  OBJECTIVE: Analyze customer churn across tenure groups.
==============================================================*/

SELECT
    CASE
        WHEN tenure BETWEEN 0 AND 12 THEN '0-12 Months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 Months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 Months'
        ELSE '49+ Months'
    END AS Tenure_Group,

    COUNT(*) AS Total_Customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS Churned_Customers,

    CAST(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Churn_Rate

FROM dbo.telecom_churn_clean

GROUP BY
    CASE
        WHEN tenure BETWEEN 0 AND 12 THEN '0-12 Months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 Months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 Months'
        ELSE '49+ Months'
    END

ORDER BY
    CASE
        WHEN
            CASE
                WHEN tenure BETWEEN 0 AND 12 THEN '0-12 Months'
                WHEN tenure BETWEEN 13 AND 24 THEN '13-24 Months'
                WHEN tenure BETWEEN 25 AND 48 THEN '25-48 Months'
                ELSE '49+ Months'
            END = '0-12 Months' THEN 1
        WHEN
            CASE
                WHEN tenure BETWEEN 0 AND 12 THEN '0-12 Months'
                WHEN tenure BETWEEN 13 AND 24 THEN '13-24 Months'
                WHEN tenure BETWEEN 25 AND 48 THEN '25-48 Months'
                ELSE '49+ Months'
            END = '13-24 Months' THEN 2
        WHEN
            CASE
                WHEN tenure BETWEEN 0 AND 12 THEN '0-12 Months'
                WHEN tenure BETWEEN 13 AND 24 THEN '13-24 Months'
                WHEN tenure BETWEEN 25 AND 48 THEN '25-48 Months'
                ELSE '49+ Months'
            END = '25-48 Months' THEN 3
        ELSE 4
    END;
GO
/*==============================================================
  STAGE 6.4: INTERNET SERVICE BUSINESS ANALYSIS
  OBJECTIVE: Identify internet service categories with
             higher customer churn.
==============================================================*/

SELECT
    InternetService,
    COUNT(*) AS Total_Customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS Churned_Customers,

    CAST(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Churn_Rate

FROM dbo.telecom_churn_clean
GROUP BY InternetService
ORDER BY Churn_Rate DESC;
GO
/*==============================================================
  STAGE 6.5: BUSINESS INSIGHTS AND RECOMMENDATIONS

  KEY FINDINGS:

  1. Overall Churn:
     26.54% of customers have churned.
     Recommendation: Introduce customer retention initiatives.

  2. Contract Type:
     Month-to-month customers show a 42.71% churn rate.
     Recommendation: Test incentives for long-term contracts.

  3. Customer Tenure:
     Customers with 0-12 months tenure show a 47.44%
     churn rate.
     Recommendation: Improve early onboarding and support.

  4. Internet Service:
     Fiber optic customers show a 41.89% churn rate.
     Recommendation: Investigate pricing, service quality
     and customer support.

  5. Payment Method:
     Electronic check customers show a 45.29% churn rate.
     Recommendation: Review the payment experience and
     investigate possible payment-related friction.

  NOTE:
  These findings show associations in the dataset.
  They do not independently prove the causes of churn.

==============================================================*/
/*==============================================================
  STAGE 7.1: CREATE VIEW - OVERALL CHURN SUMMARY
  OBJECTIVE: Create a reusable view for overall churn metrics.
==============================================================*/

USE Telecom_Churn_DB;
GO

CREATE OR ALTER VIEW dbo.vw_ChurnSummary
AS
SELECT
    COUNT(*) AS Total_Customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS Churned_Customers,

    SUM(CASE WHEN Churn = 'No' THEN 1 ELSE 0 END)
        AS Active_Customers,

    CAST(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Churn_Rate

FROM dbo.telecom_churn_clean;
GO
-- Retrieve overall churn summary from the created view.

SELECT *
FROM dbo.vw_ChurnSummary;
GO
/*==============================================================
  STAGE 7.1: CREATE VIEW - CONTRACT-WISE CHURN
  OBJECTIVE: Create a reusable view for contract-level
             customer churn analysis.
==============================================================*/

CREATE OR ALTER VIEW dbo.vw_ContractChurn
AS
SELECT
    Contract,
    COUNT(*) AS Total_Customers,

    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS Churned_Customers,

    CAST(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Churn_Rate

FROM dbo.telecom_churn_clean
GROUP BY Contract;
GO
-- Retrieve contract-wise churn metrics.

SELECT *
FROM dbo.vw_ContractChurn
ORDER BY Churn_Rate DESC;
GO
/*==============================================================
  STAGE 7.2: STORED PROCEDURE
  OBJECTIVE: Generate contract-wise churn analysis using
             an optional contract parameter.
==============================================================*/

CREATE OR ALTER PROCEDURE dbo.sp_ContractChurnAnalysis
    @Contract NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Contract,
        COUNT(*) AS Total_Customers,

        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
            AS Churned_Customers,

        CAST(
            SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*)
            AS DECIMAL(5,2)
        ) AS Churn_Rate

    FROM dbo.telecom_churn_clean

    WHERE @Contract IS NULL
       OR Contract = @Contract

    GROUP BY Contract
    ORDER BY Churn_Rate DESC;
END;
GO
-- Execute the procedure without a parameter.

EXEC dbo.sp_ContractChurnAnalysis;
GO
-- Execute the procedure for a specific contract category.

EXEC dbo.sp_ContractChurnAnalysis
    @Contract = 'Month-to-month';
GO
/*==============================================================
  STAGE 7.3: NONCLUSTERED INDEX
  OBJECTIVE: Create an index on Contract and include
             Churn and MonthlyCharges columns.
==============================================================*/

USE Telecom_Churn_DB;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_TelecomChurn_Contract'
      AND object_id = OBJECT_ID('dbo.telecom_churn_clean')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_TelecomChurn_Contract
    ON dbo.telecom_churn_clean (Contract)
    INCLUDE (Churn, MonthlyCharges);
END;
GO
-- Check whether the nonclustered index exists.

SELECT
    name AS Index_Name,
    type_desc AS Index_Type
FROM sys.indexes
WHERE object_id = OBJECT_ID('dbo.telecom_churn_clean')
  AND name = 'IX_TelecomChurn_Contract';
GO
/*==============================================================
  STAGE 7.4: EXECUTION PLAN ANALYSIS
  OBJECTIVE: Inspect how SQL Server executes a contract-based
             filtering query.
==============================================================*/

SELECT
    customerID,
    Contract,
    Churn
FROM dbo.telecom_churn_clean
WHERE Contract = 'Month-to-month';
GO
/*==============================================================
  STAGE 7.4: QUERY PERFORMANCE STATISTICS
  OBJECTIVE: Measure logical reads and execution time
             for the contract-based query.
==============================================================*/

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    customerID,
    Contract,
    Churn
FROM dbo.telecom_churn_clean
WHERE Contract = 'Month-to-month';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO