# Telecom Customer Churn Analysis using Microsoft SQL Server

# Project Overview
This project focuses on analyzing customer churn in a telecommunications company using Microsoft SQL Server. The objective is to identify customer segments with high churn rates, understand customer behaviour, and generate data-driven business recommendations.
The project uses SQL queries to perform data quality checks, data cleaning, exploratory data analysis, advanced analysis, and database development.

# Business Problem

Customer churn is a major challenge for telecommunications companies because losing customers can affect revenue and long-term business growth.

## The company needs to understand:

How many customers are leaving the service?
Which contract categories have higher churn rates?
Are new customers more likely to leave?
Which internet service categories have higher churn?
What actions could help improve customer retention?

# Project Objectives

Assess dataset quality and identify missing values.
Clean and prepare customer data for analysis.
Calculate overall customer churn and churn rates.
Analyze churn by contract, tenure, internet service, payment method, and monthly charges.
Use advanced SQL concepts to identify customer patterns.
Create reusable database objects such as views and stored procedures.
Generate actionable business insights and recommendations.

# Dataset Description

Dataset: IBM Telco Customer Churn Sample Dataset
Total records: 7,043 customers
Total columns: 21
Target column: Churn

## Important columns include:

|Column                           |Description                          |
|--------------------------------:|-------------------------------------|
|customer ID                      |Unique customer identifier           |
|gender                           |Customer gender                      |
|Senior Citizen                   |Senior citizen indicator             |
|tenure                           |Number of months with the company    |
|Contract                         |Customer contract type               |
|Internet Service                 |Internet service category            |
|Payment Method                   |Customer payment method              |
|Monthly Charges                  | Monthly customer charges            |
|Total Charges                    |Total customer charges               |
|Churn                            |Whether the customer left the company|

# Tools and Technologies

Microsoft SQL Server
SQL Server Management Studio (SSMS)
SQL
CSV Dataset
GitHub

# Data Cleaning and Preparation

## The following data preparation activities were performed:
Imported the original CSV dataset into SQL Server.
Created a staging table for data preparation.
Checked missing values and duplicate customer IDs.
Converted numeric columns into appropriate data types.
Removed unnecessary leading and trailing spaces using TRIM().
Handled blank TotalCharges values.
Data cleaning assumption: The dataset contained 11 blank TotalCharges values. All 11 records had zero tenure. These blank values were converted to 0 in the cleaned table rather than deleting the customer records.
The original raw and staging tables were preserved.

# SQL Analysis Performed

## Data Quality Assessment

Missing value analysis
Duplicate customer ID verification
Investigation of blank TotalCharges records

## Exploratory Data Analysis

Overall customer churn analysis
Contract-wise churn analysis
Tenure-wise churn analysis
Internet service-wise churn analysis
Payment method-wise churn analysis
Monthly charges segmentation

## Advanced SQL Analysis

Subqueries
Common Table Expressions (CTEs)
ROW_NUMBER()
RANK()
CASE WHEN
Window functions using AVG() OVER()

## SQL Development Features

Views
Stored procedures with parameters
Nonclustered index
Actual execution plan analysis
Query performance statistics using SET STATISTICS IO and SET STATISTICS TIME

# Key Business Insights

## Overall Customer Churn

|Metric                                 |Result|
|--------------------------------------:|------|
|Total Customers                        |7,043 |
|Churned Customers                      |1,869 |
|Active Customers                       |5,174 |
|Overall Churn Rate                     |26.54%|

## Contract-wise Churn

|Contract              |Customers              |Churned              |Churn Rate |
|---------------------:|----------------------:|--------------------:|----------:|
|Month-to-month        |3,875                  |1,655                |42.71%     |
|One year              |1,473                  |166                  |11.27%     |
|Two year              |1,695                  |48                   |2.83%      |

## Tenure-wise Churn

|Tenure Group|       Customers|               Churned|              Churn Rate|
|-----------:|---------------:|---------------------:|-----------------------:|
|0–12 Months |       2,186    |               1,037  |              47.44%    |
|13–24 Months|       1,024    |               294    |              28.71%    |
|25–48 Months|       1,594    |               325    |              20.39%    |
|49+ Months  |       2,239    |               213    |              9.51%     |

## Internet Service-wise Churn

|Internet Service          |Customers             |Churned             |Churn Rate|
|-------------------------:|---------------------:|-------------------:|----------|
|Fiber optic               | 3,096                |  1,297             |   41.89% |
|DSL                       |2,421                 | 459                |  18.96%  |
|No Internet Service       |1,526                 | 113                |  7.40%   |

## Payment Method-wise Churn

|Payment Method             |Customers              |Churned              |Churn Rate|
|--------------------------:|----------------------:|--------------------:|---------:|
|Electronic check           |2,365                  |1,071                |45.29%    |
|Mailed check               |1,612                  |308                  |19.11%    |
|Bank transfer (automatic)  |1,544                  |258                  |16.71%    |
|Credit card (automatic)    |1,522                  |232                  |15.24%    |

## Monthly Charges-wise Churn

|Category                    |Customers               |Churned                |Churn Rate|
|---------------------------:|-----------------------:|----------------------:|----------|
|Low Charges                 |1,731                   |188                    |10.86%    |
|Medium Charges              |1,721                   |407                    |23.65%    |
|High Charges                |3,591                   |1,274                  |35.48%    |

# Business Recommendations

Improve early customer retention: Customers with 0–12 months of tenure show a 47.44% churn rate. Improve onboarding and provide timely customer support.
Encourage long-term contracts: Month-to-month customers show a 42.71% churn rate. Test suitable incentives for customers choosing longer contracts.
Investigate Fiber optic churn: Fiber optic customers show a 41.89% churn rate. Review service quality, pricing, and customer support.
Review payment experience: Electronic check customers show a 45.29% churn rate. Investigate possible payment-related friction and improve the payment experience.
Introduce retention initiatives: The overall churn rate is 26.54%. Develop targeted retention strategies for higher-risk customer segments.

Note: These findings represent associations in the dataset. They do not independently establish the causes of customer churn.

# Project Structure
``` text
Telecom-Customer-Churn-Analysis/
│
├── SQL/
│   └── Telecom_Churn_Complete_Analysis.sql
│
├── Screenshots/
│   ├── 01_Data_Quality.png
│   ├── 02_Churn_Summary.png
│   ├── 03_Contract_Analysis.png
│   ├── 04_Tenure_Analysis.png
│   ├── 05_Internet_Analysis.png
│   ├── 06_Stored_Procedure.png
│   └── 07_Execution_Plan.png
│
├── WA_Fn-UseC_-Telco-Customer-Churn.csv
│
└── README.md
```
# How to Run the Project

Install Microsoft SQL Server and SQL Server Management Studio.
Download or clone this repository.
Create a database named Telecom_Churn_DB.
Import the CSV dataset into SQL Server.
Open Telecom_Churn_Complete_Analysis.sql in SSMS.
Execute the SQL sections in the appropriate order.
Review the query results and generated database objects.

Important: The clean-table creation section contains a DROP TABLE statement for rebuilding the clean table. Review the script and execute setup or rebuild sections carefully rather than running the entire file blindly.

# Learning Outcomes

Through this project, I gained practical experience in:
SQL-based data cleaning and validation.
Exploratory data analysis using aggregate functions.
Writing subqueries and CTEs.
Applying SQL window functions.
Creating views and stored procedures.
Creating and verifying indexes.
Inspecting SQL Server execution plans and performance statistics.
Translating SQL analysis into business insights.

# Author

Saswat Nayak
Aspiring Data Analyst
GitHub: https://github.com/saswatnayak052-lgtm
LinkedIn: https://www.linkedin.com/in/saswat-nayak-data-analyst

## Project: Telecom Customer Churn Analysis
## Database: Microsoft SQL Server
## Dataset: IBM Telco Customer Churn Sample Dataset
