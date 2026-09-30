--create database Hospital;
--use Hospital

--create schema hpl

-- 1. Departments Table
CREATE TABLE hpl.Departments (
    department_id INT PRIMARY KEY IDENTITY,
    department_name VARCHAR(100) NOT NULL,
    head_of_department VARCHAR(100),
    phone_extension VARCHAR(10)
);

INSERT INTO hpl.Departments (department_name, head_of_department, phone_extension) VALUES
( 'Cardiology', 'Dr. Robert Smith', '1001'),
( 'Neurology', 'Dr. Sarah Connor', '1002'),
( 'Orthopedics', 'Dr. James Wilson', '1003'),
( 'Pediatrics', 'Dr. Emily Watson', '1004'),
( 'Oncology', 'Dr. Michael Chang', '1005'),
( 'Gastroenterology', 'Dr. Laura Vance', '1006'),
( 'Dermatology', 'Dr. Alan Grant', '1007'),
( 'Urology', 'Dr. Susan Calvin', '1008'),
( 'Pulmonology', 'Dr. David Bowman', '1009'),
( 'Endocrinology', 'Dr. Grace Augustine', '1010'),
( 'Ophthalmology', 'Dr. Thomas Kane', '1011'),
( 'Otolaryngology (ENT)', 'Dr. Rachel Tyrell', '1012'),
( 'Psychiatry', 'Dr. Bruce Banner', '1013'),
( 'Nephrology', 'Dr. Eleanor Arroway', '1014'),
( 'Rheumatology', 'Dr. Henry Wu', '1015'),
( 'General Surgery', 'Dr. Stephen Strange', '1016'),
( 'Emergency Medicine', 'Dr. Leonard McCoy', '1017'),
( 'Obstetrics & Gynecology', 'Dr. Beverly Crusher', '1018'),
( 'Hematology', 'Dr. John Watson', '1019'),
( 'Radiology', 'Dr. Dana Scully', '1020');


-- 2. Doctors Table
CREATE TABLE hpl.Doctors (
    doctor_id INT PRIMARY KEY IDENTITY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    department_id INT,
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(20),
    FOREIGN KEY (department_id) REFERENCES hpl.Departments(department_id)
);

INSERT INTO hpl.Doctors ( first_name, last_name, specialization, department_id, email, phone_number) VALUES
( 'Robert', 'Smith', 'Cardiologist', 1, 'r.smith@hospital.org', '555-0101'),
( 'Sarah', 'Connor', 'Neurologist', 2, 's.connor@hospital.org', '555-0102'),
( 'James', 'Wilson', 'Orthopedic Surgeon', 3, 'j.wilson@hospital.org', '555-0103'),
('Emily', 'Watson', 'Pediatrician', 4, 'e.watson@hospital.org', '555-0104'),
( 'Michael', 'Chang', 'Oncologist', 5, 'm.chang@hospital.org', '555-0105'),
( 'Laura', 'Vance', 'Gastroenterologist', 6, 'l.vance@hospital.org', '555-0106'),
( 'Alan', 'Grant', 'Dermatologist', 7, 'a.grant@hospital.org', '555-0107'),
( 'Susan', 'Calvin', 'Urologist', 8, 's.calvin@hospital.org', '555-0108'),
( 'David', 'Bowman', 'Pulmonologist', 9, 'd.bowman@hospital.org', '555-0109'),
( 'Grace', 'Augustine', 'Endocrinologist', 10, 'g.augustine@hospital.org', '555-0110'),
( 'Thomas', 'Kane', 'Ophthalmologist', 11, 't.kane@hospital.org', '555-0111'),
( 'Rachel', 'Tyrell', 'ENT Specialist', 12, 'r.tyrell@hospital.org', '555-0112'),
( 'Bruce', 'Banner', 'Psychiatrist', 13, 'b.banner@hospital.org', '555-0113'),
( 'Eleanor', 'Arroway', 'Nephrologist', 14, 'e.arroway@hospital.org', '555-0114'),
( 'Henry', 'Wu', 'Rheumatologist', 15, 'h.wu@hospital.org', '555-0115'),
( 'Stephen', 'Strange', 'General Surgeon', 16, 's.strange@hospital.org', '555-0116'),
( 'Leonard', 'McCoy', 'Emergency Physician', 17, 'l.mccoy@hospital.org', '555-0117'),
( 'Beverly', 'Crusher', 'Obstetrician', 18, 'b.crusher@hospital.org', '555-0118'),
( 'John', 'Watson', 'Hematologist', 19, 'j.watson@hospital.org', '555-0119'),
( 'Dana', 'Scully', 'Radiologist', 20, 'd.scully@hospital.org', '555-0120');

-- 3. Patients Table
CREATE TABLE hpl.Patients (
    patient_id INT PRIMARY KEY identity,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender char(6) check([gender] in ('Male', 'Female', 'Other')) NOT NULL,
    phone_number VARCHAR(20),
    blood_group VARCHAR(5)
);

INSERT INTO hpl.Patients (first_name, last_name, date_of_birth, gender, phone_number, blood_group) VALUES
( 'Alice', 'Johnson', '1985-04-12', 'Female', '555-0201', 'A+'),
( 'Bob', 'Williams', '1972-09-25', 'Male', '555-0202', 'O-'),
( 'Charlie', 'Brown', '1990-11-03', 'Male', '555-0203', 'B+'),
( 'Diana', 'Prince', '1988-03-22', 'Female', '555-0204', 'AB+'),
( 'Ethan', 'Hunt', '1980-07-18', 'Male', '555-0205', 'O+'),
( 'Fiona', 'Gallagher', '1995-01-30', 'Female', '555-0206', 'A-'),
( 'George', 'Clark', '1965-06-14', 'Male', '555-0207', 'B-'),
( 'Hannah', 'Abbott', '2001-12-05', 'Female', '555-0208', 'AB-'),
( 'Ian', 'Malcolm', '1978-08-09', 'Male', '555-0209', 'O+'),
( 'Julia', 'Roberts', '1992-05-17', 'Female', '555-0210', 'A+'),
( 'Kevin', 'Flynn', '1983-02-28', 'Male', '555-0211', 'B+'),
( 'Laura', 'Palmer', '1998-10-10', 'Female', '555-0212', 'O-'),
( 'Michael', 'Scott', '1964-03-15', 'Male', '555-0213', 'A+'),
( 'Nina', 'Sayers', '1993-07-04', 'Female', '555-0214', 'B-'),
( 'Oscar', 'Martinez', '1975-11-20', 'Male', '555-0215', 'O+'),
( 'Pam', 'Beesly', '1984-03-25', 'Female', '555-0216', 'AB+'),
( 'Quinn', 'Fabray', '1996-09-08', 'Female', '555-0217', 'A-'),
( 'Ron', 'Swanson', '1961-05-06', 'Male', '555-0218', 'O+'),
( 'Samantha', 'Jones', '1979-04-28', 'Female', '555-0219', 'B+'),
( 'Tim', 'Drake', '2003-01-12', 'Male', '555-0220', 'AB-');

-- 4. Appointments Table
CREATE TABLE hpl.Appointments (
    appointment_id INT PRIMARY KEY IDENTITY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    [status] char(10) check([status] in ('Scheduled', 'Completed', 'Cancelled', 'No-Show')) DEFAULT 'Scheduled',
    reason_for_visit TEXT,
    diagnosis TEXT,
    FOREIGN KEY (patient_id) REFERENCES hpl.Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES hpl.Doctors(doctor_id)
);
INSERT INTO hpl.Appointments (patient_id, doctor_id, appointment_date, status, reason_for_visit, diagnosis) VALUES
( 1, 1, '2026-10-01 09:00:00', 'Scheduled', 'Chest tightness during exercise', NULL),
( 2, 2, '2026-10-01 10:30:00', 'Scheduled', 'Chronic migraines', NULL),
( 3, 3, '2026-09-28 14:00:00', 'Completed', 'Right knee pain after running', 'Mild ligament strain'),
( 4, 4, '2026-09-29 11:15:00', 'Completed', 'Annual pediatric checkup', 'Healthy growth metrics'),
( 5, 5, '2026-10-02 13:00:00', 'Scheduled', 'Follow-up post-chemotherapy', NULL),
( 6, 6, '2026-09-27 15:30:00', 'Completed', 'Acid reflux and abdominal bloating', 'GERD'),
( 7, 7, '2026-09-25 09:45:00', 'Cancelled', 'Skin rash on forearms', NULL),
( 8, 8, '2026-10-03 10:00:00', 'Scheduled', 'Routine kidney ultrasound review', NULL),
( 9, 9, '2026-09-26 16:00:00', 'Completed', 'Persistent cough and shortness of breath', 'Mild asthma exacerbation'),
( 10, 10, '2026-10-04 08:30:00', 'Scheduled', 'Thyroid panel consultation', NULL),
( 11, 11, '2026-09-24 11:00:00', 'Completed', 'Blurry vision in left eye', 'Early-stage cataract'),
( 12, 12, '2026-09-23 14:30:00', 'No-Show', 'Sore throat and earache', NULL),
( 13, 13, '2026-10-05 15:00:00', 'Scheduled', 'Anxiety and insomnia consultation', NULL),
( 14, 14, '2026-09-22 10:00:00', 'Completed', 'Elevated creatinine levels', 'Stage 2 CKD management'),
( 15, 15, '2026-10-06 09:15:00', 'Scheduled', 'Joint stiffness in hands', NULL),
( 16, 16, '2026-09-21 13:30:00', 'Completed', 'Gallbladder consultation', 'Gallstones recommended for surgery'),
( 17, 17, '2026-09-20 22:00:00', 'Completed', 'Acute abdominal pain', 'Appendicitis, referred to surgery'),
( 18, 18, '2026-10-07 11:30:00', 'Scheduled', 'Prenatal checkup week 24', NULL),
( 19, 19, '2026-09-19 14:00:00', 'Completed', 'Low hemoglobin levels', 'Iron deficiency anemia'),
( 20, 20, '2026-09-18 16:30:00', 'Completed', 'Wrist X-ray review', 'Hairline fracture of distal radius');

---------------------------------------------------------------------------------------------------------
--1 Write a query to display each department name with total appointments pivoted by their 
--  status (Scheduled, Completed, Cancelled, No-Show).

select department_name, 
isnull(Scheduled,0) as Schedule,isnull(Completed,0) as Completed, 
isnull(Cancelled,0) as Cancelled,isnull([No-Show],0) as No_show
from(
select dep.department_name, app.[status], app.appointment_id from hpl.Departments as dep 
inner join hpl.Doctors as dc  on dep.department_id = dc.department_id
inner join hpl.Appointments as app on dc.doctor_id = app.doctor_id
) as PivotData
pivot(
count(appointment_id) for [status] in (Scheduled, Completed, Cancelled, [No-Show])
) as pivotTable;

--2 Business Goal: The blood bank team needs a demographic breakdown of registered patients to assess 
--donor availability by blood group.
-- Task: Write a query to output each blood_group as a row and pivot the total count of patients by 
--their gender (Male, Female, Other)

select blood_group,
ISNULL(Male,0) as Male,
ISNULL(Female,0) as Female,
ISNULL(Other,0) as Other
from
(
select blood_group, gender from hpl.Patients 
) as base
pivot(
count(gender) for gender in (Male, Female, Other)
)as pivotTable


--3 Business Goal: Hospital management needs to track individual doctor activity to evaluate attendance
-- and workload.
-- Task: Display each doctor's full name (first_name + last_name) with the total number of appointments pivoted
-- across statuses (Completed, Scheduled, Cancelled, No-Show). 

select Full_name ,
isnull(Scheduled,0) as Schedule,isnull(Completed,0) as Completed, 
isnull(Cancelled,0) as Cancelled,isnull([No-Show],0) as No_show
from(
select  (dc.first_name +' '+ dc.last_name)as Full_name, app.[status] from hpl.Doctors as dc
inner join hpl.Appointments as app on dc.doctor_id = app.doctor_id
) as PivotData
pivot(
count([status]) for [status] in (Scheduled, Completed, Cancelled, [No-Show])
) as pivotTable;

--4. Business Goal: The scheduling department wants to identify peak months for patient visits per 
-- department to optimize staffing.
-- Task: Display each department name with total appointments pivoted by month name (e.g., September, October) 
-- for the year 2026.

SELECT
    department_name,
    ISNULL([January], 0) AS [January],
    ISNULL([February], 0) AS [February],
    ISNULL([March], 0) AS [March],
    ISNULL([April], 0) AS [April],
    ISNULL([May], 0) AS [May],
    ISNULL([June], 0) AS [June],
    ISNULL([July], 0) AS [July],
    ISNULL([August], 0) AS [August],
    ISNULL([September], 0) AS [September],
    ISNULL([October], 0) AS [October],
    ISNULL([November], 0) AS [November],
    ISNULL([December], 0) AS [December]
FROM
(
    SELECT
        dep.department_name,
        DATENAME(MONTH, app.appointment_date) AS MonthName
    FROM hpl.Appointments app
    INNER JOIN hpl.Doctors dc
        ON app.doctor_id = dc.doctor_id
    INNER JOIN hpl.Departments dep
        ON dc.department_id = dep.department_id
    WHERE YEAR(app.appointment_date) = 2026
) AS base
PIVOT
(
    COUNT([MonthName])
    FOR [MonthName] IN ( [January],[February],[March],[April],[May],[June],[July],[August],
        [September],[October],[November],[December])
) AS PivotTable


--5 Business Goal: The emergency response team needs to see which blood types are most frequently required 
-- across different specialty departments.
-- Task: Display each department name and pivot the count of distinct patient visits by their blood_group 
-- (A+, O+, B+, AB+, O-, A-, B-, AB-).


SELECT
    department_name,
    ISNULL([A+], 0) AS [A+],
    ISNULL([O+], 0) AS [O+],
    ISNULL([B+], 0) AS [B+],
    ISNULL([AB+], 0) AS [AB+],
    ISNULL([O-], 0) AS [O-],
    ISNULL([A-], 0) AS [A-],
    ISNULL([B-], 0) AS [B-],
    ISNULL([AB-], 0) AS [AB-]
from (
 SELECT DISTINCT 
dep.department_name,
pt.patient_id,
pt.blood_group
FROM hpl.Departments dep
JOIN hpl.Doctors dc
ON dep.department_id = dc.department_id
JOIN hpl.Appointments app
ON dc.doctor_id = app.doctor_id
JOIN hpl.Patients pt
ON app.patient_id = pt.patient_id
) AS base
PIVOT
(
COUNT([patient_id])
FOR blood_group IN
(
[A+], [O+], [B+], [AB+],
[O-], [A-], [B-], [AB-]
)
) AS pivotTable



