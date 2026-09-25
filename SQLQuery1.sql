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
=======
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
