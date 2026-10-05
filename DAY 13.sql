USE [PaintUpdated];
--use pup;
--drop table pup.Employee

CREATE TABLE pup.Employee (
[ID] INT,
[Name] VARCHAR(50),
[Salary] INT,
[Gender]  VARCHAR(10),
[City] VARCHAR(50),
[Dept] VARCHAR(50)
)

WITH Numbers AS
(
    SELECT TOP 1000000
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO pup.Employee (ID, Name, Salary, Gender, City, Dept)
SELECT
    ID,
    'Emp' + CAST(ID AS VARCHAR(10)),
    20000 + (ID % 80000),
    CASE WHEN ID % 2 = 0 THEN 'Male' ELSE 'Female' END,
    CASE ID % 5
         WHEN 0 THEN 'Delhi'
         WHEN 1 THEN 'Mumbai'
         WHEN 2 THEN 'Kolkata'
         WHEN 3 THEN 'Chennai'
         ELSE 'Bangalore'
    END,
    CASE ID % 4
         WHEN 0 THEN 'IT'
         WHEN 1 THEN 'HR'
         WHEN 2 THEN 'Finance'
         ELSE 'Sales'
    END
FROM Numbers;

select * from pup.Employee


SELECT * FROM pup.Employee Where Id = 8;

--drop index pup.Employee.ix_employee_id

--create clustered index ix_employee_id on pup.Employee(Id ASC);

--sp_helpindex 'pup.Employee'

create clustered index ix_employee_city_salary on pup.Employee(City asc, salary desc)

SELECT * FROM pup.Employee Where salary = 99995 and City = 'delhi' 


CREATE TABLE pup.tblOrder
(
[Id] INT,
[CustomerId] INT,
[ProductId] Varchar(100),
[ProductName] VARCHAR(50)
)

DECLARE @i int = 0
WHILE @i < 3000 
BEGIN
SET @i = @i + 1
IF(@i < 500)
Begin          
INSERT INTO pup.tblOrder VALUES (@i, 1, 'Product - 10120', 'Laptop')    End
ELSE IF(@i < 1000)
Begin         
INSERT INTO pup.tblOrder VALUES (@i, 3, 'Product - 1020', 'Mobile')       end
Else if(@i < 1500)
Begin         
INSERT INTO pup.tblOrder VALUES (@i, 2, 'Product - 101', 'Desktop')   end
Else if(@i < 2000)
begin
INSERT INTO pup.tblOrder VALUES (@i, 3, 'Product - 707', 'Pendrive')     End
Else if(@i < 2500)
Begin          
INSERT INTO pup.tblOrder VALUES (@i, 2, 'Product - 999', 'HD')    end         
Else if(@i < 3000)
Begin          
INSERT INTO pup.tblOrder VALUES (@i, 1, 'Product - 100', 'Tablet')end

END

select * from pup.tblOrder;

select * from pup.tblOrder where ProductId = 'Product - 10120'
select * from pup.tblOrder where    [Id] =2 and  ProductId = 'Product - 10120'  ;
select * from pup.tblOrder where    [Id] =2 or  ProductId = 'Product - 10120'  ;
select * from pup.tblOrder where      ProductId = 'Product - 10120' and [Id] =2  ;

--drop index IX_tblOrder_ProductId

create NONCLUSTERED INDEX IX_tblOrder_ProductId ON pup.tblOrder (ProductId)
INCLUDE ([Id],[CustomerId],[ProductName]) 