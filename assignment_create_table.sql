USE BikeStores; -- or your target database
GO

-- Clean up existing tables if recreating
IF OBJECT_ID('dbo.Enrollments', 'U') IS NOT NULL DROP TABLE dbo.Enrollments;
IF OBJECT_ID('dbo.Courses', 'U')     IS NOT NULL DROP TABLE dbo.Courses;
IF OBJECT_ID('dbo.Students', 'U')    IS NOT NULL DROP TABLE dbo.Students;
GO

--------------------------------------------------------------------------------
-- 1. CREATE TABLES
--------------------------------------------------------------------------------

-- Table 1: Students
CREATE TABLE dbo.Students (
    StudentID INT PRIMARY KEY IDENTITY(1,1),
    StudentName VARCHAR(100) NOT NULL
);

-- Table 2: Courses
CREATE TABLE dbo.Courses (
    CourseID INT PRIMARY KEY IDENTITY(1,1),
    CourseName VARCHAR(100) NOT NULL
);

-- Table 3: Enrollments
CREATE TABLE dbo.Enrollments (
    EnrollmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    EnrollmentDate DATE NOT NULL,
    CONSTRAINT FK_Enrollments_Students FOREIGN KEY (StudentID) REFERENCES dbo.Students(StudentID),
    CONSTRAINT FK_Enrollments_Courses  FOREIGN KEY (CourseID)  REFERENCES dbo.Courses(CourseID),
    CONSTRAINT UQ_Student_Course UNIQUE (StudentID, CourseID)
);
GO

--------------------------------------------------------------------------------
-- 2. INSERT 10 DATA RECORDS FOR EACH TABLE
--------------------------------------------------------------------------------

-- 10 Students
INSERT INTO dbo.Students (StudentName)
VALUES 
    ('Avijit Pakhira'),     -- StudentID: 1
    ('Rahul Sharma'),      -- StudentID: 2
    ('Priya Sen'),         -- StudentID: 3
    ('Amit Das'),          -- StudentID: 4
    ('Sneha Patel'),       -- StudentID: 5
    ('Rohan Mehta'),       -- StudentID: 6
    ('Ananya Roy'),        -- StudentID: 7
    ('Vikram Singh'),      -- StudentID: 8
    ('Pooja Nair'),        -- StudentID: 9
    ('Debolina Sen');      -- StudentID: 10

-- 10 Courses
INSERT INTO dbo.Courses (CourseName)
VALUES 
    ('.NET Core'),          -- CourseID: 1
    ('SQL Server & T-SQL'), -- CourseID: 2
    ('SSRS Reporting'),     -- CourseID: 3
    ('SharePoint'),         -- CourseID: 4
    ('WCF & Web API'),      -- CourseID: 5
    ('Angular Framework'),  -- CourseID: 6
    ('Azure Cloud Basics'), -- CourseID: 7
    ('Entity Framework'),   -- CourseID: 8
    ('Python for Data'),    -- CourseID: 9
    ('Power BI');           -- CourseID: 10

-- 10 Initial Enrollments (All unique pairs of StudentID and CourseID)
INSERT INTO dbo.Enrollments (StudentID, CourseID, EnrollmentDate)
VALUES 
    (1, 1, '2026-10-01'),  -- Avijit enrolled in .NET Core
    (1, 2, '2026-10-01'),  -- Avijit enrolled in SQL Server
    (2, 2, '2026-10-02'),  -- Rahul enrolled in SQL Server
    (2, 3, '2026-10-03'),  -- Rahul enrolled in SSRS
    (3, 1, '2026-10-05'),  -- Priya enrolled in .NET Core
    (4, 4, '2026-10-08'),  -- Amit enrolled in SharePoint
    (5, 5, '2026-10-10'),  -- Sneha enrolled in WCF
    (6, 6, '2026-10-12'),  -- Rohan enrolled in Angular
    (7, 7, '2026-10-15'),  -- Ananya enrolled in Azure
    (8, 8, '2026-10-18');  -- Vikram enrolled in Entity Framework
GO

--------------------------------------------------------------------------------
-- 3. VERIFY DATA
--------------------------------------------------------------------------------
SELECT * FROM dbo.Students;
SELECT * FROM dbo.Courses;
SELECT 
    e.EnrollmentID,
    s.StudentName,
    c.CourseName,
    e.EnrollmentDate
FROM dbo.Enrollments e
INNER JOIN dbo.Students s ON e.StudentID = s.StudentID
INNER JOIN dbo.Courses c  ON e.CourseID = c.CourseID;
GO
--============================================

USE Assignment2; -- or your target database
GO

-- Clean up existing tables if recreating
IF OBJECT_ID('dbo.OrderItems', 'U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID('dbo.Orders', 'U')     IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Stock', 'U')      IS NOT NULL DROP TABLE dbo.Stock;
IF OBJECT_ID('dbo.Products', 'U')   IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Customers', 'U')  IS NOT NULL DROP TABLE dbo.Customers;
GO

-- 1. Customers Table
CREATE TABLE dbo.Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerName VARCHAR(100) NOT NULL
);

-- 2. Products Table
CREATE TABLE dbo.Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(100) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL
);

-- 3. Stock Table (Inventory tracking)
CREATE TABLE dbo.Stock (
    ProductID INT PRIMARY KEY,
    QuantityAvailable INT NOT NULL CHECK (QuantityAvailable >= 0),
    LastUpdated DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Stock_Products FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID)
);

-- 4. Orders Table
CREATE TABLE dbo.Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID)
);

-- 5. OrderItems Table
CREATE TABLE dbo.OrderItems (
    OrderItemID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_OrderItems_Orders   FOREIGN KEY (OrderID)   REFERENCES dbo.Orders(OrderID),
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID)
);
GO

--------------------------------------------------------------------------------
-- INSERT INITIAL SEED DATA
--------------------------------------------------------------------------------
INSERT INTO dbo.Customers (CustomerName)
VALUES ('Avijit Pakhira'), ('Rahul Sharma'), ('Priya Sen');

INSERT INTO dbo.Products (ProductName, UnitPrice)
VALUES 
    ('Laptop Dell XPS', 75000.00),     -- ProductID: 1
    ('Wireless Mouse',    850.00),     -- ProductID: 2
    ('Mechanical Keyboard', 2500.00),  -- ProductID: 3
    ('USB-C Monitor 27"', 22000.00);   -- ProductID: 4

-- Initial stock levels
INSERT INTO dbo.Stock (ProductID, QuantityAvailable)
VALUES 
    (1, 10),   -- 10 Laptops
    (2, 50),   -- 50 Mice
    (3, 20),   -- 20 Keyboards
    (4, 5);    -- 5 Monitors
GO

IF OBJECT_ID('dbo.Sales', 'U') IS NOT NULL DROP TABLE dbo.Sales;
GO

CREATE TABLE dbo.Sales (
    SalesID     INT IDENTITY(1,1) PRIMARY KEY, -- Clustered Index by default
    SalesDate   DATE NOT NULL,
    CustomerID  INT NOT NULL,
    ProductID   INT NOT NULL,
    TotalAmount DECIMAL(12,2) NOT NULL
);
GO

-- Insert sample rows
INSERT INTO dbo.Sales (SalesDate, CustomerID, ProductID, TotalAmount)
VALUES 
    ('2026-11-01', 101, 501, 1500.00),
    ('2026-11-02', 102, 502, 2300.00),
    ('2026-11-03', 101, 503,  450.00),
    ('2026-11-04', 103, 501, 1500.00),
    ('2026-11-05', 102, 501, 3000.00);
GO

CREATE TABLE dbo.SalesTransactions (
    SalesID     INT IDENTITY(1,1),
    CustomerID  INT NOT NULL,
    ProductID   INT NOT NULL,
    SalesDate   DATE NOT NULL,
    TotalAmount DECIMAL(12,2) NOT NULL,
    
    -- IMPORTANT: Make the Primary Key NONCLUSTERED so CustomerID can have the Clustered Index
    CONSTRAINT PK_SalesTransactions PRIMARY KEY NONCLUSTERED (SalesID)
);

INSERT INTO dbo.SalesTransactions (CustomerID, ProductID, SalesDate, TotalAmount)
VALUES 
    (101, 501, '2026-11-01', 1500.00),
    (101, 502, '2026-11-02', 2400.00),
    (101, 501, '2026-11-05', 1500.00),
    (102, 503, '2026-11-03',  850.00),
    (102, 501, '2026-11-06', 3000.00),
    (103, 502, '2026-11-04', 1200.00),
    (104, 504, '2026-11-07', 4500.00),
    (104, 501, '2026-11-08', 1500.00),
    (105, 503, '2026-11-09',  950.00),
    (105, 505, '2026-11-10', 5200.00);
GO

GO
SELECT * 
FROM dbo.SalesTransactions
WHERE CustomerID = 101
;