-- Select all records from the healthcare dataset
SELECT *
FROM healthcare_dataset;

-- Counting the total number of records
SELECT COUNT(*) AS No_records
FROM healthcare_dataset;

SELECT COUNT(*) AS No_Columns
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'healthcare_dataset';

-- Rounding the billing amount to 2 decimal places
UPDATE healthcare_dataset
SET Billing_Amount = ROUND(Billing_Amount, 2);

-- Check for null values in critical columns
SELECT *
FROM healthcare_dataset
WHERE Age IS NULL 
    OR Insurance_Provider IS NULL 
    OR Hospital IS NULL;

-- Add a new column to count repetitive records
ALTER TABLE healthcare_dataset
ADD Count_Names INT;

-- Create a temporary table to count the occurrences of each name
SELECT Name, COUNT(*) AS Count_Names
INTO Count_Table
FROM healthcare_dataset
GROUP BY Name;

-- Update the Count_Names column with the actual counts
UPDATE healthcare_dataset
SET Count_Names = (SELECT COUNT(*) 
                   FROM healthcare_dataset AS t 
                   WHERE t.Name = healthcare_dataset.Name);

-- Rename the Count_Names column to Visits
EXEC sp_rename 'dbo.healthcare_dataset.Count_Names', 'Visits', 'COLUMN';

-- Select distinct names and visit counts for patients with multiple visits
SELECT DISTINCT Name, Visits
FROM healthcare_dataset
WHERE Visits > 1
ORDER BY Name;

-- Validate the discharge date format
SELECT Discharge_Date,
    CASE 
        WHEN ISDATE(Discharge_Date) = 1 THEN 'Valid Date'
        ELSE 'Invalid Date'
    END AS DateFormatCheck
FROM healthcare_dataset;

-- Select discharge dates not in the specified range
SELECT Discharge_Date 
FROM healthcare_dataset
WHERE Discharge_Date NOT BETWEEN '2018-01-01' AND '2023-12-31';

-- Calculate the number of admitted days
SELECT Date_of_Admission, Discharge_Date,
    CASE 
        WHEN Date_of_Admission IS NOT NULL AND Discharge_Date IS NOT NULL THEN DATEDIFF(DAY, Date_of_Admission, Discharge_Date)
        ELSE NULL 
    END AS Admitted_Days
FROM healthcare_dataset;

-- Add a new column for admitted days
ALTER TABLE healthcare_dataset
ADD Admitted_Days INT;

-- Update the admitted days column with the calculated values
UPDATE healthcare_dataset
SET Admitted_Days = DATEDIFF(DAY, Date_of_Admission, Discharge_Date);

-- Check the unique values for various attributes
SELECT DISTINCT Insurance_Provider
FROM healthcare_dataset;

SELECT DISTINCT Blood_Type
FROM healthcare_dataset;

SELECT DISTINCT Admission_Type
FROM healthcare_dataset;

SELECT DISTINCT Test_Results
FROM healthcare_dataset;

-- Replace commas in hospital names with hyphens
UPDATE healthcare_dataset
SET Hospital = REPLACE(Hospital, ',', '-');

-- Count the distinct number of hospitals
SELECT COUNT(DISTINCT Hospital) AS Hospital_Count
FROM healthcare_dataset;

-- Add a new column for age category
ALTER TABLE healthcare_dataset
ADD Age_Category NVARCHAR(50);

-- Update the age category column based on age ranges
UPDATE healthcare_dataset
SET Age_Category =
    CASE
        WHEN Age < 13 THEN 'Child'
        WHEN Age BETWEEN 13 AND 19 THEN 'Teenager'
        WHEN Age BETWEEN 20 AND 29 THEN 'Adult'
        WHEN Age BETWEEN 30 AND 49 THEN 'Middle Age'
        WHEN Age BETWEEN 50 AND 64 THEN 'Elderly'
        WHEN Age > 64 THEN 'Senior'
    END;

-- Select age categories and ages for verification
SELECT Age_Category, Age
FROM healthcare_dataset;

-- Analysis

--Number of Patients by Age Category:

SELECT Age_Category, COUNT(*) AS Number_of_Patients
FROM healthcare_dataset
GROUP BY Age_Category;

--Highest Insurance Claimed by Provider:

SELECT Insurance_Provider, COUNT(*) AS Claims
FROM healthcare_dataset
GROUP BY Insurance_Provider
ORDER BY Claims DESC;

--Gender Distribution:

SELECT Gender, COUNT(*) AS Number_of_Patients
FROM healthcare_dataset
GROUP BY Gender;


--Average Days Admitted by Medical Condition:

SELECT Medical_Condition, AVG(Admitted_Days) AS Average_Admitted_Days
FROM healthcare_dataset
GROUP BY Medical_Condition;


--Medication Usage by Medical Condition:

SELECT Medical_Condition, 
       SUM(CASE WHEN Medication = 'Aspirin' THEN 1 ELSE 0 END) AS Aspirin_Usage,
       SUM(CASE WHEN Medication = 'Ibuprofen' THEN 1 ELSE 0 END) AS Ibuprofen_Usage,
       SUM(CASE WHEN Medication = 'Lipitor' THEN 1 ELSE 0 END) AS Lipitor_Usage,
       SUM(CASE WHEN Medication = 'Paracetamol' THEN 1 ELSE 0 END) AS Paracetamol_Usage,
       SUM(CASE WHEN Medication = 'Penicillin' THEN 1 ELSE 0 END) AS Penicillin_Usage
FROM healthcare_dataset
GROUP BY Medical_Condition;