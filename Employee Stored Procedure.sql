CREATE TABLE Employee
(
    ID INT NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Salary INT NOT NULL,
    Gender VARCHAR(20) NOT NULL,
    City VARCHAR(100) NOT NULL,
    Dept VARCHAR(100) NOT NULL,
    -- Reference to Address
    AddressId INT NOT NULL
);
ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_EmployeeUser
FOREIGN KEY (ID)
REFERENCES EmployeeUser(ID);

ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_Address
FOREIGN KEY (AddressId)
REFERENCES Address(AddressId);

USE [Assignmet]
GO

INSERT INTO Employee
    (ID, Name, Salary, Gender, City, Dept, AddressId)
VALUES
(1,  'Avijit Pakhira', 50000, 'Male',   'Kolkata',   'IT',        1),
(2,  'Rahul Sharma',   45000, 'Male',   'Delhi',     'HR',        2),
(3,  'Priya Das',      48000, 'Female', 'Kolkata',   'Finance',   3),
(4,  'Amit Kumar',     60000, 'Male',   'Mumbai',    'IT',        4),
(5,  'Sneha Roy',      42000, 'Female', 'Kolkata',   'Marketing', 5),
(6,  'Arjun Singh',    55000, 'Male',   'Delhi',     'IT',        6),
(7,  'Neha Gupta',     47000, 'Female', 'Noida',     'HR',        7),
(8,  'Rohit Verma',    52000, 'Male',   'Bangalore', 'IT',        8),
(9,  'Ankita Sen',     58000, 'Female', 'Kolkata',   'HR',        1),
(10, 'Vikas Yadav',    44000, 'Male',   'Lucknow',   'Sales',     2),
(11, 'Pooja Singh',    62000, 'Female', 'Mumbai',    'Finance',   3),
(12, 'Karan Mehta',    51000, 'Male',   'Ahmedabad', 'IT',        4),
(13, 'Riya Das',       46000, 'Female', 'Kolkata',   'Marketing', 5),
(14, 'Saurav Ghosh',   57000, 'Male',   'Kolkata',   'IT',        6),
(15, 'Tanya Sharma',   43000, 'Female', 'Delhi',     'HR',        7),
(16, 'Manish Kumar',   49000, 'Male',   'Patna',     'Sales',     8),
(17, 'Swati Roy',      53000, 'Female', 'Kolkata',   'Finance',   1),
(18, 'Deepak Singh',   56000, 'Male',   'Chennai',   'IT',        2),
(19, 'Megha Patel',    61000, 'Female', 'Ahmedabad', 'Finance',   3),
(20, 'Akash Gupta',    50000, 'Male',   'Bangalore', 'IT',        4);



--------

INSERT INTO Employee
(
    ID,
    Name,
    Salary,
    Gender,
    City,
    Dept,
    AddressId
)
VALUES
(109, 'Rahul Sharma', 35000, 'Male', 'Kolkata', 'IT', 1),
(102, 'Priya Das', 42000, 'Female', 'Mumbai', 'HR', 2),
(103, 'Amit Kumar', 38000, 'Male', 'Bangalore', 'Finance', 3),
(104, 'Sneha Roy', 45000, 'Female', 'New Delhi', 'IT', 4),
(105, 'Arjun Singh', 40000, 'Male', 'Chennai', 'Marketing', 5),
(106, 'Ananya Sen', 48000, 'Female', 'Hyderabad', 'IT', 6),
(107, 'Rohit Verma', 36000, 'Male', 'Lucknow', 'Sales', 7),
(108, 'Neha Gupta', 44000, 'Female', 'Jaipur', 'HR', 8);
GO





ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_Address
FOREIGN KEY (AddressId)
REFERENCES Address(AddressId);
GO

  --sp_help '[dbo].[Employee]'
--Get All Employe
ALTER PROCEDURE GetAllEmployee
AS
BEGIN
    SELECT
        ID,
        Name,
        Salary,
        Gender,
        City,
        Dept,
        AddressId
    FROM Employee;
END
-- Get Employee by Id
ALTER PROCEDURE GetEmployeeById
    @ID INT
AS
BEGIN
    SELECT
        ID,
        Name,
        Salary,
        Gender,
        City,
        Dept,
        AddressId
    FROM Employee
    WHERE ID = @ID;
END


--Insert employee

ALTER PROCEDURE InsertEmployee
    @ID INT,
    @Name VARCHAR(100),
    @Salary INT,
    @Gender VARCHAR(20),
    @City VARCHAR(100),
    @Dept VARCHAR(100),
    @AddressId INT
AS
BEGIN
    INSERT INTO Employee
    (
        ID,
        Name,
        Salary,
        Gender,
        City,
        Dept,
        AddressId
    )
    VALUES
    (
        @ID,
        @Name,
        @Salary,
        @Gender,
        @City,
        @Dept,
        @AddressId
    );
END
-- Update Employee
 ALTER PROCEDURE UpdateEmployee
    @ID INT,
    @Name VARCHAR(100) = NULL,
    @Salary INT = NULL,
    @Gender VARCHAR(20) = NULL,
    @City VARCHAR(100) = NULL,
    @Dept VARCHAR(100) = NULL,
    @AddressId INT = NULL
AS
BEGIN
    UPDATE Employee
    SET
        Name = ISNULL(@Name, Name),
        Salary = ISNULL(@Salary, Salary),
        Gender = ISNULL(@Gender, Gender),
        City = ISNULL(@City, City),
        Dept = ISNULL(@Dept, Dept),
        AddressId = ISNULL(@AddressId, AddressId)
    WHERE ID = @ID;
END



--Delete Employee
alter PROCEDURE DeleteEmployee
    @ID INT
AS
BEGIN
    DELETE FROM Employee
    WHERE ID = @ID;
END

--
