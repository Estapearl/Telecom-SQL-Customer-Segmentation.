/*
===========================================================
 01_Data_Cleaning_Transformation.sql
===========================================================
Purpose:
This file contains the SQL queries used for both 
Exploratory Data Analysis (EDA) and Data Transformation 
on NexaSat’s customer and usage data. 
The goal is to inspect, clean, and restructure the raw data 
to make it suitable for deeper business analysis.

Contents:
01. Data Quality Checks (duplicates, missing values, outliers)  
02. Exploratory Analysis to understand key patterns  
03. Creation of Derived Tables (e.g., normalized views, CLV table)  
04. Feature Engineering (Customer Lifetime Value, CLV Segments)  
05. Preparing final structured dataset for analysis  
===========================================================
*/

Purpose: Exploratory Data Analysis (EDA) queries for NexaSat dataset.
Author: Kasham Esther Bature
Date: 2025-09-14
*/
-------------------------------
-- Q0: Check for duplicate rows across all columns (none found)
-------------------------------
SELECT 
    Customer_ID, gender, Partner, Dependents, Senior_Citizen, 
    Call_Duration, Data_Usage, Plan_Type, Plan_Level, 
    Monthly_Bill_Amount, Tenure_Months, Multiple_Lines, 
    Tech_Support, Churn,
    COUNT(*) AS DuplicateCount
FROM NexaSat_data
GROUP BY 
    Customer_ID, gender, Partner, Dependents, Senior_Citizen, 
    Call_Duration, Data_Usage, Plan_Type, Plan_Level, 
    Monthly_Bill_Amount, Tenure_Months, Multiple_Lines, 
    Tech_Support, Churn
HAVING COUNT(*) > 1;


-------------------------------
-- Q1: Distribution of customers by Plan Type and Plan Level (active customers only)
-------------------------------
SELECT 
    Plan_Type,
    Plan_Level,
    COUNT(*) AS CustomerCount
FROM NexaSat_data
WHERE Churn = 0
GROUP BY Plan_Type, Plan_Level
ORDER BY Plan_Type, Plan_Level;

-------------------------------
-- Q2: Average Monthly Bill and Data Usage by Plan Type and Plan Level
-------------------------------
SELECT 
    Plan_Type,
    Plan_Level,
    ROUND(AVG(Monthly_Bill_Amount), 2) AS Avg_Monthly_Bill,
    ROUND(AVG(Data_Usage), 2) AS Avg_Data_Usage
FROM NexaSat_data
GROUP BY Plan_Type, Plan_Level
ORDER BY Plan_Type, Plan_Level;

-------------------------------
-- Q3: Average Monthly Bill by Tenure Range
-- Grouped in years for easier interpretation
-------------------------------
SELECT 
    CASE 
        WHEN Tenure_Months BETWEEN 1 AND 12 THEN 'Year 1'
        WHEN Tenure_Months BETWEEN 13 AND 24 THEN 'Year 2'
        WHEN Tenure_Months BETWEEN 25 AND 36 THEN 'Year 3'
        WHEN Tenure_Months BETWEEN 37 AND 48 THEN 'Year 4'
        WHEN Tenure_Months BETWEEN 49 AND 60 THEN 'Year 5'
    END AS Tenure_Range,
    ROUND(AVG(Monthly_Bill_Amount), 2) AS Avg_Monthly_Bill
FROM NexaSat_data
GROUP BY 
    CASE 
        WHEN Tenure_Months BETWEEN 1 AND 12 THEN 'Year 1'
        WHEN Tenure_Months BETWEEN 13 AND 24 THEN 'Year 2'
        WHEN Tenure_Months BETWEEN 25 AND 36 THEN 'Year 3'
        WHEN Tenure_Months BETWEEN 37 AND 48 THEN 'Year 4'
        WHEN Tenure_Months BETWEEN 49 AND 60 THEN 'Year 5'
    END
ORDER BY Tenure_Range;

-------------------------------
-- Q4: Average Call Duration and Data Usage for churned vs active customers
-------------------------------
SELECT 
    Churn,
    ROUND(AVG(Call_Duration), 2) AS Avg_Call_Duration,
    ROUND(AVG(Data_Usage), 2) AS Avg_Data_Usage
FROM NexaSat_data
GROUP BY Churn;

-------------------------------
-- Q5: Relationship between demographics and Monthly Bill & Churn
-------------------------------
SELECT 
    Partner,
    Dependents,
    Senior_Citizen,
    ROUND(AVG(Monthly_Bill_Amount), 2) AS Avg_Monthly_Bill,
    SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS Churned_Customers,
    SUM(CASE WHEN Churn = 0 THEN 1 ELSE 0 END) AS Active_Customers
FROM NexaSat_data
GROUP BY Partner, Dependents, Senior_Citizen
ORDER BY Avg_Monthly_Bill DESC;

-------------------------------
-- Q6: Total, churned, and active customers
-------------------------------
SELECT 
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS Churned_Customers,
    SUM(CASE WHEN Churn = 0 THEN 1 ELSE 0 END) AS Active_Customers
FROM NexaSat_data;

-------------------------------
-- Q7: Churn count and rate by Plan Type and Plan Level
-------------------------------
SELECT 
    Plan_Type,
    Plan_Level,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS Churned_Customers,
    SUM(CASE WHEN Churn = 0 THEN 1 ELSE 0 END) AS Active_Customers,
    ROUND(
        (CAST(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100, 
        2
    ) AS Churn_Rate_Percent
FROM NexaSat_data
GROUP BY Plan_Type, Plan_Level
ORDER BY Churn_Rate_Percent DESC;

-------------------------------
-- Revenue EDA: Total revenue from active customers
-------------------------------
SELECT ROUND(SUM(Monthly_Bill_Amount * Tenure_Months),2) AS TotalRevenueActive
FROM NexaSat_data
WHERE Churn = 0;

-------------------------------
-- Revenue EDA: Revenue by Plan Type and Plan Level (active customers only)
-------------------------------
SELECT 
    Plan_Type,
    Plan_Level,
    SUM(Monthly_Bill_Amount * Tenure_Months) AS Total_Revenue,
    ROUND(AVG(Monthly_Bill_Amount), 2) AS Avg_Monthly_Bill,
    COUNT(*) AS Total_Customers
FROM NexaSat_data
WHERE Churn = 0
GROUP BY Plan_Type, Plan_Level
ORDER BY Total_Revenue DESC;


/* 
File: 02_customer_segmentation.sql
Purpose: Data transformation for customer segmentation and CLV calculation.
Author: Kasham Esther Bature
Date: 2025-09-14
*/

-------------------------------
-- Step 1: Create a table for active customers only (Churn = 0)
-------------------------------
SELECT *
INTO existing_users
FROM NexaSat_data
WHERE Churn = 0;

-------------------------------
-- Step 2: Add CLV column and calculate Customer Lifetime Value (Monthly Bill × Tenure)
-------------------------------
ALTER TABLE existing_users
ADD CLV DECIMAL(12,2);

UPDATE existing_users
SET CLV = Monthly_Bill_Amount * Tenure_Months;

-------------------------------
-- Step 3: Add CLV_Score column for weighted score (initial calculation)
-------------------------------
ALTER TABLE existing_users
ADD CLV_Score DECIMAL(12,2);

UPDATE existing_users
SET CLV_Score = 
      (Monthly_Bill_Amount * 0.4) +
      (Tenure_Months * 0.3) +
      (Call_Duration * 0.1) +
      (Data_Usage * 0.1) +
      (CASE WHEN Plan_Level = 'Premium' THEN 1 ELSE 0 END) * 0.1;

-------------------------------
-- Step 4: Reset CLV_Score to NULL for normalization
-------------------------------
UPDATE existing_users
SET CLV_Score = NULL;

-------------------------------
-- Step 5: Add columns for normalized values
-------------------------------
ALTER TABLE existing_users
ADD MonthlyBill_Norm DECIMAL(6,4),
    Tenure_Norm DECIMAL(6,4),
    CallDuration_Norm DECIMAL(6,4),
    DataUsage_Norm DECIMAL(6,4);

-------------------------------
-- Step 6: Normalize Monthly Bill, Tenure, Call Duration, and Data Usage
-------------------------------
-- Normalize Monthly Bill
UPDATE existing_users
SET MonthlyBill_Norm =
    (Monthly_Bill_Amount - (SELECT MIN(Monthly_Bill_Amount) FROM existing_users)) * 1.0 /
    ((SELECT MAX(Monthly_Bill_Amount) FROM existing_users) - (SELECT MIN(Monthly_Bill_Amount) FROM existing_users));

-- Normalize Tenure
UPDATE existing_users
SET Tenure_Norm =
    (Tenure_Months - (SELECT MIN(Tenure_Months) FROM existing_users)) * 1.0 /
    ((SELECT MAX(Tenure_Months) FROM existing_users) - (SELECT MIN(Tenure_Months) FROM existing_users));

-- Normalize Call Duration
UPDATE existing_users
SET CallDuration_Norm =
    (Call_Duration - (SELECT MIN(Call_Duration) FROM existing_users)) * 1.0 /
    ((SELECT MAX(Call_Duration) FROM existing_users) - (SELECT MIN(Call_Duration) FROM existing_users));

-- Normalize Data Usage
UPDATE existing_users
SET DataUsage_Norm =
    (Data_Usage - (SELECT MIN(Data_Usage) FROM existing_users)) * 1.0 /
    ((SELECT MAX(Data_Usage) FROM existing_users) - (SELECT MIN(Data_Usage) FROM existing_users));

-------------------------------
-- Step 7: Update CLV_Score using normalized values and weights
-------------------------------
UPDATE existing_users
SET CLV_Score = 
      (MonthlyBill_Norm * 0.4) +
      (Tenure_Norm * 0.3) +
      (CallDuration_Norm * 0.1) +
      (DataUsage_Norm * 0.1) +
      (CASE WHEN Plan_Level = 'Premium' THEN 1 ELSE 0 END) * 0.1;

-------------------------------
-- Step 8: Add CLV_Segment column and define segments based on CLV_Score
-------------------------------
ALTER TABLE existing_users
ADD CLV_Segment VARCHAR(10);

-- Optional: check min, max, avg CLV_Score for reference
SELECT 
    MIN(CLV_Score) AS Min_CLVScore,
    MAX(CLV_Score) AS Max_CLVScore,
    AVG(CLV_Score) AS Avg_CLVScore
FROM existing_users;

-- Populate CLV_Segment based on CLV_Score
UPDATE existing_users
SET CLV_Segment = 
    CASE
        WHEN CLV_Score <= 0.33 THEN 'Low'
        WHEN CLV_Score <= 0.66 THEN 'Medium'
        ELSE 'High'
    END;

-- Count customers in each CLV segment
SELECT CLV_Segment, COUNT(*) AS Customer_Count
FROM existing_users
GROUP BY CLV_Segment
ORDER BY Customer_Count DESC;