SELECT TOP (1000) [ID]
      ,[Name]
      ,[Salary]
      ,[Gender]
      ,[City]
      ,[Dept]
  FROM [Assignmet].[dbo].[Employee];


  --sp_help '[dbo].[Employee]'
--Get All Employe
CREATE PROCEDURE GetAllEmployee
AS
BEGIN
    SELECT
        ID,
        Name,
        Salary,
        Gender,
        City,
        Dept
    FROM Employee;
END

-- Get Employee by Id
CREATE PROCEDURE GetEmployeeById
    @ID INT
AS
BEGIN
    SELECT
        ID,
        Name,
        Salary,
        Gender,
        City,
        Dept
    FROM Employee
    WHERE ID = @ID;
END



--Insert employee

alter PROCEDURE InsertEmployee
    @ID int,
    @Name VARCHAR(100),
    @Salary int,
    @Gender VARCHAR(20),
    @City VARCHAR(100),
    @Dept VARCHAR(100)
AS
BEGIN
    INSERT INTO Employee
    (   ID ,
        Name,
        Salary,
        Gender,
        City,
        Dept
    )
    VALUES
    (   @Id,
        @Name,
        @Salary,
        @Gender,
        @City,
        @Dept
    );
END;

-- Update Employee
ALTER PROCEDURE UpdateEmployee
    @ID INT,
    @Name VARCHAR(100) = NULL,
    @Salary int = NULL,
    @Gender VARCHAR(20) = NULL,
    @City VARCHAR(100) = NULL,
    @Dept VARCHAR(100) = NULL
AS
BEGIN
    UPDATE Employee
    SET
        Name = ISNULL(@Name, Name),
        Salary = ISNULL(@Salary, Salary),
        Gender = ISNULL(@Gender, Gender),
        City = ISNULL(@City, City),
        Dept = ISNULL(@Dept, Dept)
    WHERE ID = @ID;
END



--Delete Employee
CREATE PROCEDURE DeleteEmployee
    @ID INT
AS
BEGIN
    DELETE FROM Employee
    WHERE ID = @ID;
END

--
