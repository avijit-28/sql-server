
CREATE TABLE EmployeeUser
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    UserName NVARCHAR(100) NOT NULL,
    Name NVARCHAR(150) NOT NULL,
    Role NVARCHAR(50) NOT NULL,
    PhoneNumber NVARCHAR(15) NOT NULL,
    Email NVARCHAR(150) NOT NULL
);

USE [Assignmet]
GO

INSERT INTO EmployeeUser
    (UserName, Name, Role, PhoneNumber, Email)
VALUES
    ('avijit28', 'Avijit Pakhira', 'Admin', '9876543210', 'avijit@gmail.com'),
    ('rahul101', 'Rahul Sharma', 'Employee', '9876543211', 'rahul@gmail.com'),
    ('priya102', 'Priya Das', 'Employee', '9876543212', 'priya@gmail.com'),
    ('amit103', 'Amit Kumar', 'Manager', '9876543213', 'amit@gmail.com'),
    ('sneha104', 'Sneha Roy', 'Employee', '9876543214', 'sneha@gmail.com'),
    ('arjun105', 'Arjun Singh', 'Team Lead', '9876543215', 'arjun@gmail.com'),
    ('neha106', 'Neha Gupta', 'Employee', '9876543216', 'neha@gmail.com'),
    ('rohit107', 'Rohit Verma', 'Employee', '9876543217', 'rohit@gmail.com'),
    ('ankita108', 'Ankita Sen', 'HR', '9876543218', 'ankita@gmail.com'),
    ('vikas109', 'Vikas Yadav', 'Employee', '9876543219', 'vikas@gmail.com'),
    ('pooja110', 'Pooja Singh', 'Manager', '9876543220', 'pooja@gmail.com'),
    ('karan111', 'Karan Mehta', 'Employee', '9876543221', 'karan@gmail.com'),
    ('riya112', 'Riya Das', 'Employee', '9876543222', 'riya@gmail.com'),
    ('saurav113', 'Saurav Ghosh', 'Team Lead', '9876543223', 'saurav@gmail.com'),
    ('tanya114', 'Tanya Sharma', 'Employee', '9876543224', 'tanya@gmail.com'),
    ('manish115', 'Manish Kumar', 'Employee', '9876543225', 'manish@gmail.com'),
    ('swati116', 'Swati Roy', 'HR', '9876543226', 'swati@gmail.com'),
    ('deepak117', 'Deepak Singh', 'Employee', '9876543227', 'deepak@gmail.com'),
    ('megha118', 'Megha Patel', 'Manager', '9876543228', 'megha@gmail.com'),
    ('akash119', 'Akash Gupta', 'Employee', '9876543229', 'akash@gmail.com');


    ALTER TABLE EmployeeUser
ADD Password NVARCHAR(255) NOT NULL
    CONSTRAINT DF_EmployeeUser_Password DEFAULT 'Welcome@123';

    UPDATE EmployeeUser
SET Password = CASE ID
    WHEN 1  THEN 'Avijit@123'
    WHEN 2  THEN 'Rahul@123'
    WHEN 3  THEN 'Priya@123'
    WHEN 4  THEN 'Amit@123'
    WHEN 5  THEN 'Sneha@123'
    WHEN 6  THEN 'Arjun@123'
    WHEN 7  THEN 'Neha@123'
    WHEN 8  THEN 'Rohit@123'
    WHEN 9  THEN 'Ankita@123'
    WHEN 10 THEN 'Vikas@123'
    WHEN 11 THEN 'Pooja@123'
    WHEN 12 THEN 'Karan@123'
    WHEN 13 THEN 'Riya@123'
    WHEN 14 THEN 'Saurav@123'
    WHEN 15 THEN 'Tanya@123'
    WHEN 16 THEN 'Manish@123'
    WHEN 17 THEN 'Swati@123'
    WHEN 18 THEN 'Deepak@123'
    WHEN 19 THEN 'Megha@123'
    WHEN 20 THEN 'Akash@123'
END;
GO