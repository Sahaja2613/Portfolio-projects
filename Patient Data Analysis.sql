select * from Patients;
select * from PatientRecords;
select * from AppointmentDetails;
select * from HealthcareProfessionals;
select * from MedicationsPrescribed;
select * from Transactions;


-- Find the first and last appointment date for each patient.
SELECT 
    p.PatientID, 
    p.FullName, 
    MIN(a.AppointmentDate) AS FirstAppointment,
    MAX(a.AppointmentDate) AS LastAppointment
FROM 
    Patients p
JOIN 
    Appointments a ON p.PatientID = a.PatientID
GROUP BY 
    p.PatientID, p.FullName;


-- Identify patients who used services more than the average amount.
WITH AverageSpending AS (
    SELECT AVG(t.AmountCharged) AS AvgSpent
    FROM Transactions t
)
SELECT 
    p.PatientID, 
    p.FullName, 
    SUM(t.AmountCharged) AS TotalSpent
FROM 
    Patients p
JOIN 
    Transactions t ON p.PatientID = t.PatientID
GROUP BY 
    p.PatientID, p.FullName
HAVING 
    SUM(t.AmountCharged) > (SELECT AvgSpent FROM AverageSpending);


-- Find the medication that is most frequently prescribed for each diagnosis.
WITH DiagnosisMedications AS (
    SELECT 
        p.Diagnosis, 
        m.MedicationName, 
        COUNT(*) AS PrescriptionCount
    FROM 
        MedicalRecords p
    JOIN 
        Appointments a ON a.PatientID = p.PatientID
    JOIN 
        Medications m ON m.AppointmentID = a.AppointmentID
    GROUP BY 
        p.Diagnosis, m.MedicationName
)
SELECT 
    Diagnosis, 
    MedicationName
FROM (
    SELECT 
        Diagnosis, 
        MedicationName,
        ROW_NUMBER() OVER (PARTITION BY Diagnosis ORDER BY PrescriptionCount DESC) AS Rank
    FROM 
        DiagnosisMedications
) AS RankedMedications
WHERE Rank = 1;


-- Find patients with no prescribed medications from who had appointment.
SELECT 
    p.PatientID, 
    p.FullName
FROM 
    Patients p
JOIN 
    Appointments a ON p.PatientID = a.PatientID
LEFT JOIN 
    Medications m ON a.AppointmentID = m.AppointmentID
WHERE 
    m.PrescriptionID IS NULL;


-- Find patients with more than an appointment on the same day.
WITH DiagnosisMedications AS (
    SELECT 
        p.Diagnosis, 
        m.MedicationName, 
        COUNT(*) AS PrescriptionCount
    FROM 
        MedicalRecords p
    JOIN 
        Appointments a ON a.PatientID = p.PatientID
    JOIN 
        Medications m ON m.AppointmentID = a.AppointmentID
    GROUP BY 
        p.Diagnosis, m.MedicationName
)
SELECT 
    Diagnosis, 
    MedicationName
FROM (
    SELECT 
        Diagnosis, 
        MedicationName,
        ROW_NUMBER() OVER (PARTITION BY Diagnosis ORDER BY PrescriptionCount DESC) AS Rank
    FROM 
        DiagnosisMedications
) AS RankedMedications
WHERE Rank = 1;


 -- Display patients who didn't have appointments from past half year.
SELECT 
    p.PatientID, 
    p.FullName
FROM 
    Patients p
LEFT JOIN 
    Appointments a ON p.PatientID = a.PatientID
WHERE 
    a.AppointmentDate < CURDATE() - INTERVAL 6 MONTH OR a.AppointmentDate IS NULL;


-- Make a comparison of past month's and current month's Total revenue.
WITH MonthlyRevenue AS (
    SELECT 
        CONCAT(YEAR(TransactionDate), '-', MONTH(TransactionDate)) AS Month,
        SUM(AmountCharged) AS TotalRevenue
    FROM 
        Transactions
    GROUP BY 
        CONCAT(YEAR(TransactionDate), '-', MONTH(TransactionDate))
)
SELECT 
    Month, 
    TotalRevenue,
    LAG(TotalRevenue) OVER (ORDER BY Month) AS LastMonthRevenue,
    (TotalRevenue - LAG(TotalRevenue) OVER (ORDER BY Month)) AS RevenueChange
FROM 
    MonthlyRevenue;


 -- What is the Highest prescribed medication for each patient.
WITH MedicationFrequency AS (
    SELECT 
        m.PatientID, 
        m.MedicationName, 
        COUNT(m.MedicationName) AS PrescriptionCount
    FROM 
        Medications m
    GROUP BY 
        m.PatientID, m.MedicationName
)
SELECT 
    m.PatientID, 
    m.MedicationName
FROM (
    SELECT 
        PatientID, 
        MedicationName, 
        ROW_NUMBER() OVER (PARTITION BY PatientID ORDER BY PrescriptionCount DESC) AS Rank
    FROM 
        MedicationFrequency
) AS RankedMedications
WHERE Rank = 1;



-- Rank patients depending upon how much was the total spending per month and for patients who haven't spent anything, handle null values and display as zero.
WITH MonthlySpending AS (
    SELECT 
        p.PatientID, 
        p.FullName, 
        CONCAT(YEAR(t.TransactionDate), '-', MONTH(t.TransactionDate)) AS Month,
        COALESCE(SUM(t.AmountCharged), 0) AS TotalSpent
    FROM 
        Patients p
    LEFT JOIN 
        Transactions t ON p.PatientID = t.PatientID
    GROUP BY 
        p.PatientID, p.FullName, CONCAT(YEAR(t.TransactionDate), '-', MONTH(t.TransactionDate))
)
SELECT 
    PatientID, 
    FullName, 
    Month, 
    TotalSpent, 
    RANK() OVER (PARTITION BY Month ORDER BY TotalSpent DESC) AS SpendingRank
FROM 
    MonthlySpending;



-- Find month-to-month change in the number of appointments and with no appointments as NULL.
WITH AppointmentCounts AS (
    SELECT 
        CONCAT(YEAR(AppointmentDate), '-', MONTH(AppointmentDate)) AS Month,
        COUNT(AppointmentID) AS AppointmentCount
    FROM 
        AppointmentDetails
    GROUP BY 
        CONCAT(YEAR(AppointmentDate), '-', MONTH(AppointmentDate))
),
PreviousMonthAppointments AS (
    SELECT 
        Month, 
        AppointmentCount, 
        LAG(AppointmentCount) OVER (ORDER BY Month) AS PreviousMonthCount
    FROM 
        AppointmentCounts
)
SELECT 
    Month, 
    AppointmentCount, 
    PreviousMonthCount, 
    COALESCE(AppointmentCount - PreviousMonthCount, AppointmentCount) AS MonthlyChange
FROM 
    PreviousMonthAppointments;



-- Show the time difference between patients who had appointments on consecutive days.
WITH AppointmentInfo AS (
    SELECT 
        p.PatientID, 
        p.FullName, 
        a.AppointmentDate,
        LEAD(a.AppointmentDate) OVER (PARTITION BY p.PatientID ORDER BY a.AppointmentDate) AS NextAppointmentDate
    FROM 
        Patients p
    JOIN 
        AppointmentDetails a ON p.PatientID = a.PatientID
)
SELECT 
    PatientID, 
    FullName, 
    AppointmentDate, 
    NextAppointmentDate,
    DATEDIFF(NextAppointmentDate, AppointmentDate) AS DaysBetweenAppointments
FROM 
    AppointmentInfo
WHERE 
    DATEDIFF(NextAppointmentDate, AppointmentDate) = 1;



-- Rank healthcare professionals depending upon number of unique patients they have seen, handling cases where no patients are assigned.
WITH PatientLoad AS (
    SELECT 
        hp.Name AS HealthcareProfessional, 
        COUNT(DISTINCT a.PatientID) AS UniquePatients
    FROM 
        HealthcareProfessionals hp
    LEFT JOIN 
        AppointmentDetails a ON a.HealthcareProfessional = hp.Name
    GROUP BY 
        hp.Name
)
SELECT 
    HealthcareProfessional, 
    UniquePatients, 
    RANK() OVER (ORDER BY UniquePatients DESC) AS PatientRank
FROM 
    PatientLoad;




