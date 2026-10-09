--drop type UT_Employee
CREATE TYPE UT_Employee AS TABLE  
(  
Emp_Id int NULL,  
EmployeeName nvarchar(MAX),  
EmpSalary INT,  
Gender varchar(10),  
City varchar(50) ,
Dept varchar(50)
);
create procedure Cp1 ( @id int)
as 
begin



CREATE PROCEDURE 
USP_Insert_Employee_Infi (@Employee_Details [UT_Employee] Readonly)  
AS  
BEGIN  
INSERT INTO pup.Employee
(

ID,
Name,
Salary,
Gender,
City,
Dept
)
SELECT
Emp_Id,
EmployeeName,
EmpSalary,
Gender,
City,
Dept
FROM @Employee_Details
end;

declare @id int 

declare @emp [UT_Employee]
INSERT INTO @emp
VALUES 
(101, 'Avijit Pakhira', 75000, 'Male', 'Kolkata', 'IT'),
(102, 'Priya Sharma', 62000, 'Female', 'Bangalore', 'HR'),
(103, 'Rahul Verma', 58000, 'Male', 'Delhi', 'Finance'),
(104, 'Sneha Patel', 85000, 'Female', 'Mumbai', 'IT'),
(105, 'Amit Das', 48000, 'Male', 'Kolkata', 'Marketing'),
(106, 'Ananya Roy', 92000, 'Female', 'Pune', 'IT'),
(107, 'Vikram Singh', 67000, 'Male', 'Hyderabad', 'Sales'),
(108, 'Pooja Nair', 54000, 'Female', 'Chennai', 'HR'),
(109, 'Rohan Mehta', 78000, 'Male', 'Mumbai', 'Finance'),
(110, 'Debolina Sen', 63000, 'Female', 'Kolkata', 'Operations'),
(111, 'Suresh Reddy', 71000, 'Male', 'Bangalore', 'Sales'),
(112, 'Neha Gupta', 80000, 'Female', 'Delhi', 'IT');
--select * from @emp
exec USP_Insert_Employee_Infi @emp 
select * from pup.Employee