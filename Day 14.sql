DECLARE @product_name VARCHAR(MAX), @list_price   DECIMAL;
DECLARE cursor_product CURSOR
FOR SELECT product_name, list_price
FROM production.products;

OPEN cursor_product;

FETCH NEXT FROM cursor_product INTO @product_name, @list_price;
WHILE @@FETCH_STATUS = 0
BEGIN
PRINT @product_name + CAST(@list_price AS varchar);
FETCH NEXT FROM cursor_product INTO @product_name,@list_price;
END;

CLOSE cursor_product;
DEALLOCATE cursor_product;


DECLARE @emp_id int ,@emp_name varchar(20),@job_title varchar(50), @message varchar(max);
PRINT '-------- EMPLOYEE DETAILS --------';
DECLARE emp_cursor CURSOR FOR
SELECT employee_id,employee_name,job_title
FROM hr.employees order by employee_id;
OPEN emp_cursor
FETCH NEXT FROM emp_cursor INTO @emp_id,@emp_name,@job_title print 'Employee_ID  Employee_Name  Job'
WHILE @@FETCH_STATUS = 0
BEGIN
print '      ' + CAST(@emp_id as varchar(10)) +'      '+ cast(@emp_name as char(12)) + '   ' +cast(@job_title as varchar(50))
FETCH NEXT FROM emp_cursor INTO @emp_id,@emp_name,@job_title
END
CLOSE emp_cursor;
DEALLOCATE emp_cursor;



-- Trigger-------------------------------------------------------------

SELECT name, is_disabled
FROM sys.triggers
WHERE name = 'tr_AllDMLOperationsOnEmployee';

ENABLE TRIGGER tr_AllDMLOperationsOnEmployee
ON hr.employees;

select * from hr.employees

CREATE TRIGGER tr_InsertEmployee ON hr.employees
FOR INSERT
AS
BEGIN
PRINT 'YOU CANNOT PERFORM INSERT OPERATION'
ROLLBACK TRANSACTION
END

-- Insert,Update,Delete ---------------- 

create trigger tr_AllDMLOperationsOnEmployee ON hr.employees
FOR INSERT, UPDATE, DELETE
AS
BEGIN
IF DATEPART(HH,GETDATE()) < 13
BEGIN
PRINT 'INVALID TIME'
ROLLBACK TRANSACTION
END 
END

insert into hr.employees values (22,'Marcos','tester',5,'2022-10-01',96320),(23,'alpha','AI',6,'2021-10-01',150000);

--Insert
CREATE TRIGGER tr_InsertedEmployee ON hr.employees
FOR INSERT
AS
BEGIN
SELECT * FROM INSERTED
END

--Update
create TRIGGER tr_UpdateEmployee ON hr.employees
FOR update
AS
BEGIN
SELECT * FROM INSERTED
SELECT * FROM DELETED
END

UPDATE hr.employees SET employee_name = 'gamma' where employee_id = 12

---Delete
create TRIGGER tr_deleteEmployee ON hr.employees
FOR DELETE
AS
BEGIN
SELECT * FROM DELETED
END

DELETE FROM hr.employees
WHERE employee_name= 'alpha';


----

CREATE TABLE hr.EmployeeAudit
(
ID INT IDENTITY(1,1) PRIMARY KEY,
AuditData VARCHAR(MAX),
AuditDate DATETIME
)


CREATE TRIGGER tr_Employee_For_Insert ON hr.employees
FOR INSERT
AS
BEGIN-- Declare a variable to hold the ID Value
DECLARE @ID INT-- Declare a variable to hold the Name value
DECLARE @Name VARCHAR(100)-- Declare a variable to hold the Audit data
DECLARE @AuditData VARCHAR(100)-- Get the ID and Name from the INSERTED Magic table
SELECT @ID = employee_id, @Name = employee_name FROM INSERTED-- Set the AuditData to be stored in the EmployeeAudit table
SET @AuditData = 'New employee Added with ID  = ' + Cast(@ID AS VARCHAR(10)) + ' and Name ' + @Name-- Insert the data into the EmployeeAudit table
INSERT INTO hr.EmployeeAudit (AuditData, AuditDate) VALUES(@AuditData, GETDATE())
END

insert into hr.employees values (15,'Marcos','sd',5,'2022-10-01',96320)

select * from  hr.EmployeeAudit