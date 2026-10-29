
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


