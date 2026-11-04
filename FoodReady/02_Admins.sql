/*
================================================================================
 DATABASE OBJECT: dbo.Admins
 APPLICATION: FoodReady (ASP.NET MVC 5)
 LOCATION: D:\avi\sql\FoodReady\02_Admins.sql
 DESCRIPTION:
     Table definition, default credentials seed, stored procedures,
     and inline ADO.NET queries used for Administrator authentication,
     privilege verification, and platform executive dashboard.
================================================================================
*/

USE FoodArrivalDB;
GO

--------------------------------------------------------------------------------
-- 1. TABLE DEFINITION
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Admins', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Admins
    (
        AdminId      INT IDENTITY(1,1) PRIMARY KEY,
        AdminName    NVARCHAR(150) NOT NULL,
        Username     NVARCHAR(100) NULL,
        Email        NVARCHAR(150) NOT NULL,
        PasswordHash NVARCHAR(255) NOT NULL,
        IsActive     BIT NOT NULL DEFAULT 1,
        CreatedAt    DATETIME2 NOT NULL DEFAULT GETDATE(),

        CONSTRAINT UQ_Admins_Email UNIQUE (Email)
    );
END
GO

--------------------------------------------------------------------------------
-- 2. INDEXES
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Admins_Email' AND object_id = OBJECT_ID('dbo.Admins'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Admins_Email ON dbo.Admins(Email);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Admins_Username' AND object_id = OBJECT_ID('dbo.Admins'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Admins_Username ON dbo.Admins(Username) WHERE Username IS NOT NULL;
END
GO

--------------------------------------------------------------------------------
-- 3. DEFAULT SYSTEM ADMINISTRATOR SEED
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Admins WHERE Username = 'avi@123' OR Email = 'admin@example.com')
BEGIN
    INSERT INTO dbo.Admins (AdminName, Username, Email, PasswordHash, IsActive)
    VALUES ('System Admin', 'avi@123', 'admin@example.com', '28072003', 1);
END
GO

--------------------------------------------------------------------------------
-- 4. STORED PROCEDURES
--------------------------------------------------------------------------------

-- SP 1: Admin Login (By Email)
IF OBJECT_ID('dbo.sp_Admin_Login', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Admin_Login;
GO

CREATE PROCEDURE dbo.sp_Admin_Login
(
    @Email        NVARCHAR(150),
    @PasswordHash NVARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT AdminId, AdminName, Username, Email
    FROM dbo.Admins
    WHERE Email = @Email AND PasswordHash = @PasswordHash AND IsActive = 1;
END;
GO

-- SP 2: Admin Dashboard Summary (Classic Counts)
IF OBJECT_ID('dbo.sp_Admin_DashboardSummary', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Admin_DashboardSummary;
GO

CREATE PROCEDURE dbo.sp_Admin_DashboardSummary
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        (SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus = 'Pending') AS PendingOrders,
        (SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus = 'Accepted') AS AcceptedOrders,
        (SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus = 'Rejected') AS RejectedOrders,
        (SELECT COUNT(*) FROM dbo.FoodItems WHERE IsAvailable = 1) AS AvailableFoodItems,
        (SELECT COUNT(*) FROM dbo.Customers WHERE IsActive = 1) AS ActiveCustomers;
END;
GO

--------------------------------------------------------------------------------
-- 5. INLINE ADO.NET SQL QUERIES (Used directly in C# AdminRepository.cs)
--------------------------------------------------------------------------------

/*
--- QUERY A: Admin Login by Username OR Email ---
SELECT AdminId, AdminName, Username, Email, IsActive
FROM dbo.Admins
WHERE (LOWER(Email) = @LoginId OR LOWER(Username) = @LoginId)
  AND PasswordHash = @Password
  AND IsActive = 1;

--- QUERY B: Modern Executive Dashboard Metric Aggregation ---
SELECT 
    (SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus = 'Pending') AS PendingOrders,
    (SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus = 'Accepted') AS AcceptedOrders,
    (SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus = 'Rejected') AS RejectedOrders,
    (SELECT COUNT(*) FROM dbo.FoodItems WHERE IsAvailable = 1 AND IsVerified = 1) AS AvailableFoodItems,
    (SELECT COUNT(*) FROM dbo.Customers WHERE IsActive = 1) AS ActiveCustomers,
    (SELECT COUNT(*) FROM dbo.Restaurants WHERE IsActive = 1 AND IsVerified = 1) AS TotalRestaurants,
    (SELECT COUNT(*) FROM dbo.Riders WHERE IsActive = 1) AS TotalRiders,
    (SELECT COUNT(*) FROM dbo.RestaurantStaff WHERE IsActive = 1 AND IsVerified = 1) AS TotalStaff,
    (
        (SELECT COUNT(*) FROM dbo.Restaurants WHERE IsVerified = 0 AND IsActive = 1) +
        (SELECT COUNT(*) FROM dbo.RestaurantStaff WHERE IsVerified = 0 AND IsActive = 1) +
        (SELECT COUNT(*) FROM dbo.RiderRestaurantAffiliations WHERE IsVerified = 0) +
        (SELECT COUNT(*) FROM dbo.FoodItems WHERE IsVerified = 0)
    ) AS PendingApprovalsCount,
    ISNULL((SELECT SUM(Amount) FROM dbo.Transactions WHERE PaymentStatus = 'Success'), 0) AS TotalRevenue,
    ISNULL((SELECT SUM(PlatformFee) FROM dbo.Transactions WHERE PaymentStatus = 'Success'), 0) AS PlatformEarnings;
*/
GO
