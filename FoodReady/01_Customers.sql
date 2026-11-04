/*
================================================================================
 DATABASE OBJECT: dbo.Customers
 APPLICATION: FoodReady (ASP.NET MVC 5)
 LOCATION: D:\avi\sql\FoodReady\01_Customers.sql
 DESCRIPTION:
     Table definition, indexes, stored procedures, and inline ADO.NET queries
     used for Customer account management, registration, authentication,
     and profile operations.
================================================================================
*/

USE FoodArrivalDB;
GO

--------------------------------------------------------------------------------
-- 1. TABLE DEFINITION
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Customers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Customers
    (
        CustomerId      INT IDENTITY(1,1) PRIMARY KEY,
        CustomerName    NVARCHAR(150) NOT NULL,
        Username        NVARCHAR(100) NULL,
        Email           NVARCHAR(150) NOT NULL,
        PasswordHash    NVARCHAR(255) NOT NULL,
        PhoneNumber     NVARCHAR(20) NULL,
        Address         NVARCHAR(500) NULL,
        IsActive        BIT NOT NULL DEFAULT 1,
        CreatedAt       DATETIME2 NOT NULL DEFAULT GETDATE(),

        CONSTRAINT UQ_Customers_Email UNIQUE (Email)
    );
END
GO

--------------------------------------------------------------------------------
-- 2. INDEXES
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Customers_Email' AND object_id = OBJECT_ID('dbo.Customers'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Customers_Email ON dbo.Customers(Email);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Customers_Username' AND object_id = OBJECT_ID('dbo.Customers'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Customers_Username ON dbo.Customers(Username) WHERE Username IS NOT NULL;
END
GO

--------------------------------------------------------------------------------
-- 3. STORED PROCEDURES
--------------------------------------------------------------------------------

-- SP 1: Insert / Register Customer
IF OBJECT_ID('dbo.sp_Customer_Insert', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Customer_Insert;
GO

CREATE PROCEDURE dbo.sp_Customer_Insert
(
    @CustomerName NVARCHAR(150),
    @Email        NVARCHAR(150),
    @PasswordHash NVARCHAR(255),
    @PhoneNumber  NVARCHAR(20),
    @Address      NVARCHAR(500)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.Customers WHERE Email = @Email)
    BEGIN
        SELECT 0 AS Result, 'Email already exists.' AS Message, NULL AS CustomerId;
        RETURN;
    END;

    INSERT INTO dbo.Customers (CustomerName, Email, PasswordHash, PhoneNumber, Address)
    VALUES (@CustomerName, @Email, @PasswordHash, @PhoneNumber, @Address);

    SELECT 1 AS Result, 'Customer registered successfully.' AS Message, CAST(SCOPE_IDENTITY() AS INT) AS CustomerId;
END;
GO

-- SP 2: Customer Login (By Email)
IF OBJECT_ID('dbo.sp_Customer_Login', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Customer_Login;
GO

CREATE PROCEDURE dbo.sp_Customer_Login
(
    @Email        NVARCHAR(150),
    @PasswordHash NVARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CustomerId, CustomerName, Username, Email, PhoneNumber, Address
    FROM dbo.Customers
    WHERE Email = @Email AND PasswordHash = @PasswordHash AND IsActive = 1;
END;
GO

-- SP 3: Get All Customers (Admin Panel)
IF OBJECT_ID('dbo.sp_Customer_GetAll', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Customer_GetAll;
GO

CREATE PROCEDURE dbo.sp_Customer_GetAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CustomerId, CustomerName, Username, Email, PhoneNumber, Address, IsActive, CreatedAt
    FROM dbo.Customers
    ORDER BY CustomerId DESC;
END;
GO

-- SP 4: Get Customer By ID
IF OBJECT_ID('dbo.sp_Customer_GetById', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Customer_GetById;
GO

CREATE PROCEDURE dbo.sp_Customer_GetById
(
    @CustomerId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CustomerId, CustomerName, Username, Email, PhoneNumber, Address, IsActive, CreatedAt
    FROM dbo.Customers
    WHERE CustomerId = @CustomerId;
END;
GO

-- SP 5: Update Customer Profile
IF OBJECT_ID('dbo.sp_Customer_Update', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Customer_Update;
GO

CREATE PROCEDURE dbo.sp_Customer_Update
(
    @CustomerId   INT,
    @CustomerName NVARCHAR(150),
    @PhoneNumber  NVARCHAR(20),
    @Address      NVARCHAR(500)
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Customers
    SET CustomerName = @CustomerName,
        PhoneNumber  = @PhoneNumber,
        Address      = @Address
    WHERE CustomerId = @CustomerId;

    IF @@ROWCOUNT = 0
    BEGIN
        SELECT 0 AS Result, 'Customer not found.' AS Message;
        RETURN;
    END;

    SELECT 1 AS Result, 'Customer updated successfully.' AS Message;
END;
GO

-- SP 6: Soft Delete / Deactivate Customer
IF OBJECT_ID('dbo.sp_Customer_Delete', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Customer_Delete;
GO

CREATE PROCEDURE dbo.sp_Customer_Delete
(
    @CustomerId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Customers 
    SET IsActive = 0 
    WHERE CustomerId = @CustomerId;

    IF @@ROWCOUNT = 0
    BEGIN
        SELECT 0 AS Result, 'Customer not found.' AS Message;
        RETURN;
    END;

    SELECT 1 AS Result, 'Customer deactivated successfully.' AS Message;
END;
GO

--------------------------------------------------------------------------------
-- 4. INLINE ADO.NET SQL QUERIES (Used directly in C# CustomerRepository.cs)
--------------------------------------------------------------------------------

/*
--- QUERY A: Cross-Role Duplicate Check on Registration ---
SELECT 'Username already taken' AS Reason FROM dbo.Customers WHERE LOWER(Username) = @Username
UNION ALL
SELECT 'Email already registered' FROM dbo.Customers WHERE LOWER(Email) = @Email
UNION ALL
SELECT 'Username already taken' FROM dbo.Restaurants WHERE LOWER(Username) = @Username
UNION ALL
SELECT 'Email already registered' FROM dbo.Restaurants WHERE LOWER(Email) = @Email
UNION ALL
SELECT 'Username already taken' FROM dbo.Riders WHERE LOWER(Username) = @Username
UNION ALL
SELECT 'Email already registered' FROM dbo.Riders WHERE LOWER(Email) = @Email
UNION ALL
SELECT 'Username already taken' FROM dbo.RestaurantStaff WHERE LOWER(Username) = @Username
UNION ALL
SELECT 'Email already registered' FROM dbo.RestaurantStaff WHERE LOWER(Email) = @Email
UNION ALL
SELECT 'Username already taken' FROM dbo.Admins WHERE LOWER(Username) = @Username;

--- QUERY B: Register Customer with Username Support ---
INSERT INTO dbo.Customers (CustomerName, Username, Email, PasswordHash, PhoneNumber, Address)
VALUES (@CustomerName, @Username, @Email, @PasswordHash, @PhoneNumber, @Address);
SELECT CAST(SCOPE_IDENTITY() AS INT);

--- QUERY C: Unified Login by Username OR Email ---
SELECT CustomerId, CustomerName, Username, Email, PhoneNumber, Address, PasswordHash, IsActive
FROM dbo.Customers
WHERE (LOWER(Email) = @LoginId OR LOWER(Username) = @LoginId)
  AND IsActive = 1;

--- QUERY D: Password Reset / Change ---
UPDATE dbo.Customers 
SET PasswordHash = @Password 
WHERE CustomerId = @CustomerId;
*/
GO
