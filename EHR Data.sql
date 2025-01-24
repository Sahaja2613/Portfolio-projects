-- 1. What is the average age of diagnosis for each cancer type and how does it differ between male and female patients?
SELECT cancer_type, gender, AVG(age_at_diagnosis) AS avg_age_at_diagnosis
FROM cancer_diagnosis_data
GROUP BY cancer_type, gender
ORDER BY cancer_type, avg_age_at_diagnosis DESC;

-- 2. How many patients are diagnosed with each cancer type, and what is the survival rate for each type?
SELECT cancer_type, COUNT(*) AS diagnosis_count, 
       AVG(survival_status) AS survival_rate
FROM cancer_diagnosis_data
GROUP BY cancer_type
ORDER BY diagnosis_count DESC;

-- 3. What is the average time between diagnosis and treatment for different cancer types?
SELECT cancer_type, AVG(DATEDIFF(treatment_date, diagnosis_date)) AS avg_days_to_treatment
FROM cancer_diagnosis_data
WHERE treatment_date IS NOT NULL AND diagnosis_date IS NOT NULL
GROUP BY cancer_type
ORDER BY avg_days_to_treatment ASC;

-- 4. Which cancer types have the highest and lowest survival rates by age group?
SELECT cancer_type,
       CASE
           WHEN age_at_diagnosis BETWEEN 20 AND 29 THEN '20-29'
           WHEN age_at_diagnosis BETWEEN 30 AND 39 THEN '30-39'
           WHEN age_at_diagnosis BETWEEN 40 AND 49 THEN '40-49'
           WHEN age_at_diagnosis BETWEEN 50 AND 59 THEN '50-59'
           WHEN age_at_diagnosis BETWEEN 60 AND 69 THEN '60-69'
           ELSE '70+' 
       END AS age_group,
       AVG(survival_status) AS survival_rate
FROM cancer_diagnosis_data
GROUP BY cancer_type, age_group
ORDER BY age_group, survival_rate DESC;

-- 5. How do treatment methods correlate with survival rates for different cancer types?
SELECT cancer_type, treatment_method, AVG(survival_status) AS survival_rate
FROM cancer_diagnosis_data
GROUP BY cancer_type, treatment_method
ORDER BY cancer_type, survival_rate DESC;

-- 6. What are the most common diagnostic methods for each cancer type, and how do they impact survival rates?
SELECT cancer_type, diagnostic_method, AVG(survival_status) AS avg_survival_rate, COUNT(*) AS method_count
FROM cancer_diagnosis_data
GROUP BY cancer_type, diagnostic_method
ORDER BY method_count DESC, avg_survival_rate DESC;

-- 7. How does cancer diagnosis age vary by region and cancer type?
SELECT region, cancer_type, AVG(age_at_diagnosis) AS avg_age_at_diagnosis
FROM cancer_diagnosis_data
GROUP BY region, cancer_type
ORDER BY region, avg_age_at_diagnosis DESC;

-- 8. Treatment Outcomes Across Different Regions and Diagnostic Methods:
SELECT d.cancer_type, d.diagnostic_method, t.treatment_outcome, 
       AVG(d.survival_status) AS avg_survival_rate, COUNT(*) AS diagnosis_count
FROM cancer_diagnosis_data d
INNER JOIN treatment_data t ON d.patient_id = t.patient_id
GROUP BY d.cancer_type, d.diagnostic_method, t.treatment_outcome
ORDER BY diagnosis_count DESC;
