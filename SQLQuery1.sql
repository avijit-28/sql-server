<<<<<<< HEAD
﻿------------------------------------------------------
-- DAY 1
------------------------------------------------------
--create schema hr;

create table hr.jobs(
[job_id] int primary key identity,
[customer_id] int not null,
[description] varchar(20),
[created_at] datetime2 not null);


create table hr.t1(
[id] int primary key identity,
[name] nchar(20));

insert into hr.t1 values(N'कोमल');

select * from hr.t1;


create table [hr].[child](
[visit_id] int primary key identity(1,1),
[first_name] varchar(50) not null,
[last_name] varchar(50) not null,
[visited_at] datetime,
[phone] char(10),
[store_id] int not null,
foreign key ([store_id]) references [sales].[stores] ([store_id])
);


create table [hr].[visit](
[visit_id] int primary key identity(1,1),
[first_name] varchar(50) not null,
[last_name] varchar(50) not null,
[phone] char(10),
[store_id] int not null,
foreign key ([store_id]) references [sales].[stores] ([store_id])
);

insert into [hr].[visit] values ('avijit', 'pakhira', '15-09-2026','7589641232',1);

select * from [hr].[visit];

create table [hr].[visit2](
[visit_id] int primary key identity(1,1),
[first_name] varchar(50) not null,
[last_name] varchar(50) not null,
[visited_at] date,
[phone] char(10),
[store_id] int not null,
foreign key ([store_id]) references [sales].[stores] ([store_id])
);

insert into [hr].[visit2] values ('avijit', 'pakhira', '2026-09-15','7589641232',1);

select * from [hr].[visit2];

-------------------------------------------------------------------
-------------------------------------------------------------------

create table [hr].[product] (
[product_id] int primary key identity,
[product_name] varchar(100) not null,
[category] varchar(15) check([category] in ('exterior','interior','dual')) not null,
[finish_type] varchar(50) not null ,
[binder_type] varchar(50) not null,
[voc_level_g_l] decimal(5,2) not null,
[create_at] date default current_timestamp);

insert into [hr].[product] values('Apex shield', 'Dual', 'Gloss', 'Pure acrylic', 5.2, '2026-11-22'),
								  ('velvet_interior pure', 'interior', 'eggshell', 'vinyl acetate', 4.4,'2025-7-25');

select * from [hr].[product];

--drop table [hr].[product_varient];
create table [hr].[product_varient](
[varient_id] int primary key identity,
[product_id] int not null,
[base_type] varchar(20) not null,
[pack_size_lt] decimal(5,2) not null,
[sku_code] varchar(30) unique not null,
[unit_cost] decimal(10,2) not null,
[manufacturing_cost_mrp] decimal(10,2) not null,
foreign key ([product_id]) references [hr].[product] ([product_id]));



insert into [hr].[product_varient] values (2,'deep base', 4.00,'AS-INT-W-4',1000,4200),
										(1, 'White Base', 6.00, 'AS-DU-W-6', 1000, 6200);

Select * from [hr].[product_varient];

-------------------------------------------------------------------------------------------------------------------------
-- Day 2
-------------------------------------------------------------------------------------------------------------------------

create table [hr].[demo2](
[id] int primary key identity(100,1),
[dm_name] varchar(20) not null,
);

alter table [hr].[demo2] add [address] varchar(50) not null ;

select * from [hr].[demo2];
insert into [hr].[demo2] values ('jit','kolkata');
insert into [hr].[demo2] values ('Subh','Delhi'), ('neha','chennai');

--change the datatype of column 
alter table [hr].[demo2] alter column [dm_name] nvarchar(20);
-------------------

insert into [hr].[demo2] values (N'कोमल','Pakista'), ('anurag','chennai');

-------------to see the schemas--------------------
sp_help '[hr].[demo2]';
---------------------------------------------

truncate table [hr].[demo2];
----------------------------------------------
delete [hr].[demo2];
----------------------------------------------
------identity insert on/off------------

set identity_insert [hr].[demo2] on 
insert into [hr].[demo2] (id,dm_name,address) values (101,N'komal','delhi');

select * from [hr].[demo2];

set identity_insert [hr].[demo2] off
------------------------------
------------tempory Table -----------------
select * from [sales].[customers] where state = 'NY';


select * into [#temp_ny1] from [sales].[customers] where state = 'NY' collate sql_latin1_general_cp1_cs_as;

select * from [#temp_ny1];
sp_help '[#temp_ny]';
-----------------------------------------------
drop table [hr].[dept];

create table [hr].[dept](
[d_id] int identity(101,1) primary key,
[d_name] varchar(50) not null,
[d_loc] varchar(25) not null);


insert into [hr].[dept] values ('Pharma', 'kolkata'),
							('llb','barrackpore');

select * from [hr].[dept];

drop table [hr].[emp];

create table [hr].[emp](
[e_id] int identity(1000,1) primary key,
[ename] varchar(20) not null,
[age] char(3),
[ph] char(10),
[doj] date not null,
[d_id] int foreign key ([d_id]) references [hr].[dept] ([d_id]) on update set null on delete set null,
);

insert into [hr].[emp] values ('Nishat', '22','1236547896','2026-09-14',101),
							  ('kamal','22','4567893215','2026-09-14',102);

select * from [hr].[emp];

delete from [hr].[dept] where [d_id]=102;

----------------------------------------------------------------------------------------------------------------------
--Day 3
----------------------------------------------------------------------------------------------------------------------
create table [hr].[student](
[std_id] int primary key identity,
[std_name] varchar(30) not null,
[std_ph] char(10));


insert into [hr].[student] values('avijit','7894561236'),('anubhaw','523697412')
INSERT INTO [hr].[student] (std_name, std_ph)
VALUES
    ('Rahul', '9876543210'),
    ('Priya', '9123456789'),
    ('Amit',  '9988776655'),
    ('Sneha', '9871234567'),
    ('Rohit', '9012345678');

create table [hr].[books](
[book_id] int primary key identity,
[book_name] varchar(30),
[publish_date] date);

INSERT INTO [hr].[books] ([book_name], [publish_date])
VALUES
('SQL Server Basics', '2024-01-15'),
('Learning C#', '2023-06-10'),
('ASP.NET Core Guide', '2022-11-20'),
('Database Design', '2021-08-05'),
('Entity Framework', '2020-03-18');


alter table [hr].[books] add [book_price] decimal(6,2) check ([book_price]>0);
alter table [hr].[books] add [book_sell_date] date default getdate();  

select * from [hr].[books];

INSERT INTO [hr].[books] ([book_name], [publish_date], [book_price])
VALUES
('SQL Server Advance', '2025-01-15',500.00);
sp_help '[hr].[books]';


--drop table [hr].[lib1];

create table [hr].[lib1](
[std_id] int,
[book_id] int,
[issued_date] date,
[submitted_date] date,
constraint pk_library primary key ([std_id],[book_id]));

INSERT INTO [hr].[lib1]
    (std_id, book_id, issued_date, submitted_date)
VALUES
    (1, 1, '2026-09-01', '2026-09-10'),
    (2, 3, '2026-09-02', '2026-09-11'),
    (3, 2, '2026-09-03', '2026-09-12'),
    (4, 5, '2026-09-04', '2026-09-13'),
    (5, 4, '2026-09-05', NULL);

--insert into [hr].[lib1] values (2,3,'2026-09-15','2026-09-18');


select * from [hr].[student];
select * from [hr].[books];
select * from [hr].[lib1];

--drop table [hr].[author];
create table [hr].[author](
[author_id] int primary key identity,
[author_name] varchar(30) not null,
[phone] char(10) constraint check_UNIQUE_phone_number unique ([phone]));

INSERT INTO [hr].[author] (author_name, phone)
VALUES
    ('R.K. Sharma', '9876543210'),
    ('Anita Roy', '9123456789'),
    ('Suman Das', '9988776655'),
    ('Priya Sen', '9012345678');

SELECT * FROM [hr].[author];
insert into [hr].[author] values ('Ronit yadav','');
insert into [hr].[author] values ('Anuj Kumar',NULL);

------------------------------------
select * from [hr].[month];
-------bulk insert-----------------

bulk insert [hr].[month] from 'D:\avi\month.csv'
with (
firstrow = 2,
lastrow = 7,
fieldterminator = ',',
rowterminator = '\n'
)

select * from [hr].[month];

-----------------------------------------------------------------------------------------------------------------------------
--DAY 3 
-----------------------------------------------------------------------------------------------------------------------------

INSERT INTO [hr].[books] ([book_name], [publish_date], [book_price])
VALUES

('Database Design',         '2022-11-12', 400.00),
('Mastering LINQ',          '2025-02-14', 700.00),
('Design Patterns in C#',   '2024-05-25', 800.00),
('Web API Development',     '2023-12-30', 650.00),
('Azure Fundamentals',      '2025-04-09', 900.00),
('Microservices with .NET', '2025-07-21', 1200.00),
('The Alchemist',            '2019-01-10', 299.00),
('Rich Dad Poor Dad',        '2020-03-15', 450.00),
('Think and Grow Rich',      '2018-07-21', 399.00),
('Atomic Habits',            '2021-05-11', 550.00),
('The Power of Habit',       '2017-09-30', 425.00),
('Deep Work',                '2022-02-18', 650.00),
('The 5 AM Club',            '2020-11-25', 499.00),
('Zero to One',              '2021-08-14', 599.00),
('Psychology of Money',      '2023-01-05', 699.00),
('Ikigai',                   '2019-12-20', 350.00);

select * 
from [hr].[books]
where [book_id] = 6
or [book_id]=12 
and [book_price]>500;


--drop table [hr].[new_books];

CREATE TABLE [hr].[new_books]
(
    book_id INT primary key identity,
    book_name VARCHAR(30),
    publish_date DATE,
    book_price DECIMAL(6,2),
    book_sell_date DATE
);

INSERT INTO [hr].[new_books]

VALUES
('SQL Server Advanced','2024-01-15',750.00,'2026-09-18'),

('ASP.NET Core MVC','2022-11-20',920.00,'2026-09-18'),

('Entity Framework Core','2020-03-18',680.00,'2026-09-18'),

('Azure DevOps','2025-02-10',1200.00,'2026-09-18'),

('Microservices with .NET','2025-07-12',1500.00,'2026-09-18');


select * 
from [hr].[books];
select * 
from [hr].[new_books];


----------------Merge Statemet-----------------------
MERGE [hr].[books] AS T
USING [hr].[new_books] AS S
ON T.book_id = S.book_id

WHEN MATCHED THEN
    UPDATE
    SET
        T.book_name = S.book_name,
        T.publish_date = S.publish_date,
        T.book_price = S.book_price,
        T.book_sell_date = S.book_sell_date

WHEN NOT MATCHED BY TARGET THEN
    INSERT
    (
        book_name,
        publish_date,
        book_price,
        book_sell_date
    )
    VALUES
    (
        S.book_name,
        S.publish_date,
        S.book_price,
        S.book_sell_date
    )

WHEN NOT MATCHED BY SOURCE THEN
    DELETE;

-------------------------------------------------------------------------------------------------------------
--DAY 6
-------------------------------------------------------------------------------------------------------------
--drop table [hr].[Department];
-- Create Dept Table
CREATE TABLE [hr].[Department]
(
    [D_id] INT PRIMARY KEY,
    [D_name] VARCHAR(30)
);

-- Insert 10 records into Dept
INSERT INTO [hr].[Department] ([D_id], [D_name])
VALUES
(1, 'HR'),
(2, 'IT'),
(3, 'Finance'),
(4, 'Sales'),
(5, 'Marketing'),
(6, 'Production'),
(7, 'Support'),
(8, 'Admin'),
(9, 'Quality'),
(10, 'Research');

--drop table [hr].[Employee]
-- Create Employee Table
CREATE TABLE [hr].[Employee]
(
    [E_id] INT PRIMARY KEY,
    [E_name] VARCHAR(30)
);

-- Insert 10 records into Employee
INSERT INTO [hr].[Employee] ([E_id], [E_name])
VALUES
(1, 'Amit'),
(2, 'Rahul'),
(3, 'Priya'),
(4, 'Sneha'),
(5, 'Arjun');
--(6, 'Riya'),
--(7, 'Suman'),
--(8, 'Karan'),
--(9, 'Anjali'),
--(10, 'Rohit');

SELECT
    d.[D_id],
    d.[D_name],
    e.[E_id],
    e.[E_name]
FROM [hr].[Department] AS d
Left JOIN [hr].[Employee] AS e
ON d.[D_id] = e.[E_id] 
and e.[E_id] = 2 ;

--------------------------------------------------------------------------------------------------------------------
-- Day 7
--------------------------------------------------------------------------------------------------------------------

CREATE TABLE [hr].[college_stud]
(
    [stud_id] INT PRIMARY KEY IDENTITY,
    [stud_name] VARCHAR(50) NOT NULL,
    [department] VARCHAR(30) NOT NULL
);

INSERT INTO [hr].[college_stud]
([stud_name], [department])
VALUES
('Amit', 'CSE'),
('Rahul', 'ECE'),
('Priya', 'BBA'),
('Sneha', 'CSE'),
('Vikas', 'MBA'),
('Anjali', 'ECE'),
('Rohit', 'BCA'),
('Neha', 'CSE'),
('Karan', 'MBA'),
('Pooja', 'BBA');

CREATE TABLE [hr].[ex_college_stud]
(
    [stud_id] INT PRIMARY KEY IDENTITY,
    [stud_name] VARCHAR(50) NOT NULL,
    [department] VARCHAR(30) NOT NULL
);

INSERT INTO [hr].[ex_college_stud]
([stud_name], [department])
VALUES
('Priya', 'BBA'),
('Sneha', 'CSE'),
('Vikas', 'MBA'),
('Deepak', 'ECE'),
('Riya', 'BCA'),
('Arjun', 'CSE'),
('Megha', 'BBA'),
('Nitin', 'MBA'),
('Kavya', 'ECE'),
('Manoj', 'CSE');


-- Union
SELECT [stud_name], [department]
FROM [hr].[college_stud]

UNION

SELECT [stud_name], [department]
FROM [hr].[ex_college_stud];

--Union All

SELECT [stud_name], [department]
FROM [hr].[college_stud]

UNION ALL

SELECT [stud_name], [department]
FROM [hr].[ex_college_stud];

--Inner Join
SELECT
    c.[stud_id],
    c.[stud_name],
    c.[department]
FROM [hr].[college_stud] c
INNER JOIN [hr].[ex_college_stud] e
    ON c.[stud_name] = e.[stud_name];

--Except
SELECT [stud_name], [department]
FROM [hr].[college_stud]

EXCEPT

SELECT [stud_name], [department]
FROM [hr].[ex_college_stud];

-- Intersect
SELECT [stud_name], [department]
FROM [hr].[college_stud]

INTERSECT

SELECT [stud_name], [department]
FROM [hr].[ex_college_stud]; 

SELECT TOP (1000) [varient_id]
      ,[product_id]
      ,[base_type]
      ,[pack_size_lt]
      ,[sku_code]
      ,[unit_cost]
      ,[manufacturing_cost_mrp]
  FROM [PaintUpdated].[pup].[product_varient]
  order by [product_id]


  select [varient_id],[product_id],[manufacturing_cost_mrp] 
  from [pup].[product_varient]
  where [manufacturing_cost_mrp] = 6200;
>>>>>>> 1041d34 ( 29 sept done)
=======

-----------------------------------------------------------------------------------------------------------
-- Day 8
-----------------------------------------------------------------------------------------------------------
--1. Display all authors and replace NULL phone numbers with 'No Phone'.

SELECT author_name,
ISNULL(phone, 'Not Avail')
FROM hr.author;

--2 Compare book_price with 750. Return NULL if equal.

SELECT book_name, book_price,
NULLIF(book_price,750)
FROM hr.books;

--3 Show author phone number. If phone is NULL, show 'Not Available
SELECT author_name,phone,
COALESCE(phone,'Unavailable') number
FROM hr.author;

--4 Create a table with an IDENTITY column and retrieve the generated ID after inserting one row.

-- Create Table
CREATE TABLE [hr].[test_student]
(
    student_id INT IDENTITY(1,1) PRIMARY KEY,
    student_name VARCHAR(50)
);
select * from hr.test_student;

-- Insert One Row
INSERT INTO hr.test_student(student_name)
VALUES ('Anoop');

-- Retrieve Generated Identity Value
SELECT SCOPE_IDENTITY() AS Generated_ID;

select @@IDENTITY as G_Id;


---
INSERT INTO hr.test_student(student_name)
VALUES ('Amit');

DECLARE @NewID INT;
SET @NewID = SCOPE_IDENTITY();
SELECT @NewID AS Student_ID;


--5. Display whether a book is expensive or affordable.

SELECT
    book_name,
    book_price,
    IIF(book_price >= 750, 'Expensive', 'Affordable') AS Category
FROM hr.books;


select TRIM('     sql      server     ') as trm;

SELECT FORMAT(GETDATE(), 'dd/MM/yyyy', 'en-US') AS Result;

SELECT DATEDIFF(DAY, '2026-09-01', '2026-09-25') AS DaysDiff;

select NEWID() as guid; --generate always new id

SELECT
    book_name,
    book_price,
    ROW_NUMBER() OVER (ORDER BY book_price asc) AS RowNum
FROM hr.books;

SELECT
    book_name,
    book_price,
    RANK() OVER (ORDER BY book_price asc) AS RankNo
FROM hr.books;



SELECT * FROM (
SELECT product_id,product_name,brand_id,list_price, Dense_RANK () OVER ( 
PARTITION BY brand_id
ORDER BY list_price DESC
) price_rank 
FROM production.products
) t
WHERE price_rank <= 3;


SELECT first_name, last_name, city,
ROW_NUMBER() OVER (PARTITION BY city ORDER BY first_name ) row_num
FROM sales.customers
ORDER BY city;

-----------------------------------------------------------------------------------------------------------------------
-- DAY 9
-----------------------------------------------------------------------------------------------------------------------
-- While Loop
CREATE TABLE hr.SampleTable
(Id INT, CountryName NVARCHAR(100), ReadStatus TINYINT)
GO
INSERT INTO hr.SampleTable ( Id, CountryName, ReadStatus)
Values (1, 'Germany', 0),
(2, 'France', 0),
(3, 'Italy', 0),
(4, 'Netherlands', 0) ,
(5, 'Poland', 0)
SELECT * FROM hr.SampleTable

DECLARE @Counter INT , @MaxId INT, @ReadStatus TINYINT,
@CountryName NVARCHAR(100)
SELECT @Counter = min(Id) , @MaxId = max(Id), @ReadStatus=min(ReadStatus)
FROM hr.SampleTable
WHILE(@Counter IS NOT NULL
AND @Counter <= @MaxId)
BEGIN
SELECT @CountryName = CountryName
FROM hr.SampleTable WHERE Id = @Counter
IF @ReadStatus = 1
    UPDATE HR.SampleTable SET ReadStatus = 0 where @Counter=id
    --PRINT CONVERT(VARCHAR,@Counter) + '. country name is ' + @CountryName+' ' + CONVERT(VARCHAR, @READSTATUS)
    
SET @Counter = @Counter + 1
END

declare @Count int, @Max_id int,@CountryNames NVARCHAR(100), @ReadSts tinyint
select @Count = min(ID),@Max_id = max(ID),@ReadSts=min(ReadStatus) from hr.SampleTable
while (@Count is not null and @Count<=@Max_Id)
Begin
SELECT @CountryNames = CountryName
FROM hr.SampleTable WHERE Id = @Count
PRINT CONVERT(VARCHAR,@Count) + '. country name is ' + @CountryNames+' and status is ' + CONVERT(VARCHAR, @Readsts)
SET @Count = @Count + 1
end

----Loop and date 

declare @s_date varchar(15), @EndDate date, @LoopDate Date,@StartDate Date
set @s_date =format(GETDATE(),'dd/MM/yyyy','en-us')
set @StartDate = GETDATE()
set @EndDate = '2026/09/30'
set @LoopDate = @StartDate

select(SQL_VARIANT_PROPERTY(@EndDate, 'BaseType')  )


print(type(@LoopDate))
print(type(@EndDate))
------------------------------------Assignment--------------------------------------------------------------
---star printing
declare @i int = 1
while @i < 5
begin 
print REPLICATE('*',@i)
set @i = @i +1
end


-- abc printing

declare @x int = 0
declare @save varchar(10)= ' '
while @x <5 
begin
 set @save = @save + char(65 + @x)
 print (@save)
set @x= @x+1
end

----- prime or not 
declare @num int= 136155417
declare @c int = 2
declare @Prime bit = 1;

while @c < sqrt(@num)
begin
if @num % @c = 0
    begin
    set @prime = 0
    break
    end
set @c = @c + 1
end
if @Prime = 0
print(convert(varchar(10),@num)+' is not prime')
else
print(convert(varchar(10),@num)+' is prime')

---------------------------------------

-- Create Table
CREATE TABLE hr.Students
(
    StudentName VARCHAR(100),
    FatherName  VARCHAR(100)
);

-- Insert Data
INSERT INTO hr.Students (StudentName, FatherName)
VALUES
('Rajiv Kumar', 'Arvind Kumar'),
('Asish Roy', 'Ashim Roy'),
('Bipin Gupta', 'Rajiv Gupta'),
('Rajiv Kumar', 'Arvind Kumar'),
('Sourav Patra', 'Asish Patra'),
('Asish Roy', 'Ashim Roy');

SELECT * FROM hr.Students
--How to display the students from a student table having same student's name and father's name from below table:


select StudentName, FatherName,count(*) as total from hr.Students
group by StudentName,FatherName
having count(StudentName) > 1

--------------------------------------
CREATE TABLE hr.employees
(
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50) NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    manager_id INT NULL,
    hired_date DATE,
    FOREIGN KEY (manager_id)
        REFERENCES hr.employees(employee_id)
);

INSERT INTO hr.employees
VALUES
(1, 'John',  'CEO',       NULL, '2020-01-01'),
(2, 'David', 'Manager',   1,    '2021-02-15'),
(3, 'Sarah', 'Manager',   1,    '2021-04-10'),
(4, 'Mike',  'Developer', 2,    '2022-06-05'),
(5, 'Lisa',  'Tester',    2,    '2022-07-01'),
(6, 'Tom',   'Developer', 3,    '2023-01-15');

INSERT INTO hr.employees
VALUES
(7, 'Rajiv', 'Developer',2, '2026-09-01'),
(8, 'Asish', 'Tester',3, '2026-07-15'),
(9, 'Bipin', 'Manager',1, '2026-03-10'),
(10, 'Sourav', 'Developer',2, '2025-12-20');

select * from hr.employees

--5 Write a query to find employees hired in last n months.
declare @nMonths int = 3
select * from hr.employees 
where hired_date >= DATEADD(Month, -@nMonths, GETDATE())

--6

SELECT
    e.employee_name AS Employee,e.[job_title], ISNULL(m.employee_name, 'No Manager') AS ReportsTo
FROM hr.employees e
left join hr.employees m
--inner join hr.employees m
    ON e.manager_id = m.employee_id
order by ReportsTo

--7
SELECT employee_name FROM hr.employees
--where LEFT(employee_name,1) = 'S'
where substring(employee_name,1,1)='S'

--8
ALTER TABLE hr.employees
ADD salary DECIMAL(10,2);

UPDATE hr.employees
SET salary =
    CASE employee_id
        WHEN 1 THEN 200000
        WHEN 2 THEN 120000
        WHEN 3 THEN 120000
        WHEN 4 THEN 80000
        WHEN 5 THEN 70000
        WHEN 6 THEN 85000
        WHEN 7 THEN 90000
        WHEN 8 THEN 75000
        WHEN 9 THEN 130000
        WHEN 10 THEN 95000
    END;

SELECT * FROM hr.employees

--8
--using offset and fetch
select * from hr.employees
order by salary desc
offset 5 rows
fetch next 1 rows only

--
select *
from(
select *,DENSE_RANK() over (order by salary desc) as sal_rank from hr.employees) as temp
where temp.sal_rank = 6;

---------------------------------------------------------------------------------------------------------------------------
--DAY 10
---------------------------------------------------------------------------------------------------------------------------

create function [sales].[udfNetSale](
@quantity int, @list_price Dec(10,2), @discount Dec(4,2))
returns Dec(10,2)
as 
Begin
    return @quantity * @list_price * (1-@discount);
end;

select sales.udfNetSale (10,100.0,0.15) as net_sale;

-- create a function to return no. of order generated by a staff in 2018
drop function sales.udfOrderGen
alter function sales.udfOrderGen(
@StaffId int,
@Year int)
returns int
as
begin
declare @totalCount int = (select count(*) from sales.[orders]
where  @year = year([order_date]) and @staffId = [staff_id])

return isnull(@totalCount,0);
end;

select sales.udfOrderGen(1,2018) as total_order;



alter function age( @dob date)
returns int
as
begin
declare @calc int = (datediff(MONTH,@dob,getdate()))
return @calc/12
end;

select dbo.age('2003/07/28') as CurrentAge;

-------------------------------------------------------------------------------------
CREATE FUNCTION udfProductInYear (  @model_year INT)
RETURNS TABLE
AS
RETURN
SELECT product_name, model_year, list_price
FROM production.products
WHERE  model_year = @model_year;

SELECT * 
FROM udfProductInYear(2017);
-----------------------------------------------
ALTER FUNCTION udfProductInYear (
@start_year INT,
@end_year INT
)
RETURNS TABLE
AS
RETURN SELECT product_name, model_year,  list_price
FROM production.products
WHERE model_year BETWEEN @start_year AND @end_year


SELECT product_name, model_year, list_price
FROM udfProductInYear(2017,2019)
ORDER BY product_name;

-----------------------------------------------------------------------------------
--Multi-statement table-valued function 
--1
create function fn_GetOrderFulfillmentStatus (@storeID int)
returns @details table(
    order_id int,
    customer_id int,
    order_date date,
    required_date date,
    shipped_date date,
    fulfillment_category VARCHAR(30)
)
as 
begin
insert into @details (
order_id,
customer_id ,
order_date ,
required_date ,
shipped_date ,
fulfillment_category )
select 
order_id,
customer_id ,
order_date ,
required_date ,
shipped_date ,

case 
when shipped_date > required_date then 'Late'
when shipped_date <= required_date then 'On-Time'
when shipped_date IS NULL and current_date > required_date then 'Overdue Pending'
when shipped_date IS NULL and current_date <= required_date then 'In Progress'
end as fulfillment_category
from Sales.orders
where store_id =@storeID 
return;
end;


select * from fn_GetOrderFulfillmentStatus(1);


--2

alter function fn_GetStaffOrderSummary(@start_date date, @end_date date)
returns @StaffSummary table(
[staff_id] int,
[Total_orders_handled] int,
[completed_orders] int,
[delayed_orders] int,
[avg_days_to_ship] decimal(10,2)
)
as 
begin
insert into @StaffSummary 
select [staff_id],
count(*) as Total_orders_handled,
sum(case when shipped_date is null then 0 else 1 end) as completed_orders,
Sum(case when shipped_date > required_date then 1 else 0 end) as delayed_orders,
AVG(DATEDIFF(day,order_date,shipped_date)) as avg_days_to_ship
from [sales].[orders]
where order_date between @start_date and @end_date
group by [staff_id];

return;
end;


select * from fn_GetStaffOrderSummary ('2016-01-01','2016-08-26');


-- inline table-valued function 
--3
alter function fn_GetStoreFulfilledOrders (@store_id  int, @max_processing_days int)
returns table 
as 
return(
select [order_id],[customer_id],[order_date],[shipped_date],[store_id],
    DATEDIFF(day,order_date,shipped_date) as processing_days
    from [sales].[orders]
    where @store_id = store_id and DATEDIFF(day,order_date,shipped_date) <= @max_processing_days 
    and shipped_date is not null
    
);

select * from fn_GetStoreFulfilledOrders(1,2) 

--4
--drop function fn_GetCustomerDelayedOrders
alter function fn_GetCustomerDelayedOrders( @customer_id int)
returns table
as 
return(
select order_id from [sales].[orders]
where (datediff(day,required_date,shipped_date) >=1 or shipped_date is null)  and customer_id = @customer_id  
);
select * from fn_GetCustomerDelayedOrders(91)

-----------------------------------------------------------------------------------------------------------------------
-- DAY 11
CREATE TABLE hr.Customers
(
CustomerName VARCHAR(50),
ProductName VARCHAR(50),
Amount INT
)

INSERT INTO hr.Customers VALUES('James', 'Desktop', 25000)
INSERT INTO hr.Customers VALUES('James', 'Laptop', 30000)
INSERT INTO hr.Customers VALUES('David', 'Laptop', 25000)
INSERT INTO hr.Customers VALUES('Smith', 'Desktop', 30000)
INSERT INTO hr.Customers VALUES('Pam', 'Laptop', 45000)
INSERT INTO hr.Customers VALUES('Pam', 'Laptop', 30000)
INSERT INTO hr.Customers VALUES('John', 'Desktop', 30000)
INSERT INTO hr.Customers VALUES('John', 'Desktop', 30000)
INSERT INTO hr.Customers VALUES('John', 'Laptop', 30000)


select CustomerName, Laptop, Desktop,PC
from
(select CustomerName, ProductName, Amount from hr.Customers 
where Amount > (select Avg(Amount) from hr.Customers as sal) ) as PivotData
pivot(
sum(Amount) for ProductName in (laptop,Desktop,PC)) as PivotTable



BEGIN TRY
    BEGIN TRAN

    INSERT INTO hr.Employee VALUES (25,'kaalu')
    begin tran
    update hr.Employee set [E_name] = 'nisuuuuu' where [E_id] = 8
    begin tran
    insert into hr.Department values(15,'accounts')
    begin tran
    insert into hr.Department values(16,'accounts')
    COMMIT TRAN
    -- Error here
    --INSERT INTO hr.Employee VALUES (13,'Mike')
    select @@trancount
    
END TRY
BEGIN CATCH
    IF (@@TRANCOUNT >= 0)
        ROLLBACK TRAN
END CATCH


SELECT @@TRANCOUNT AS TranCount1;  -- 0

BEGIN TRANSACTION;
SELECT @@TRANCOUNT AS TranCount2;  -- 1

BEGIN TRANSACTION;
SELECT @@TRANCOUNT AS TranCount3;  -- 2

BEGIN TRANSACTION;
SELECT @@TRANCOUNT AS TranCount4;

COMMIT;
SELECT @@TRANCOUNT AS commit1;  -- 1
--COMMIT;
--SELECT @@TRANCOUNT AS commit2;
rollback;
SELECT @@TRANCOUNT AS rollback1;  -- 0
