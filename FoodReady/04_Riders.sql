/*
================================================================================
 DATABASE OBJECT: dbo.Riders
 APPLICATION: FoodReady (ASP.NET MVC 5)
 LOCATION: D:\avi\sql\FoodReady\04_Riders.sql
 DESCRIPTION:
     Table definition, indexes, default rider seed, and ADO.NET inline queries
     used for Delivery Partner onboarding, vehicle/license records,
     live delivery status, and order pickup tracking.
================================================================================
*/

USE FoodArrivalDB;
GO

--------------------------------------------------------------------------------
-- 1. TABLE DEFINITION
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Riders', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Riders
    (
        RiderId             INT IDENTITY(1,1) PRIMARY KEY,
        RiderName           NVARCHAR(150) NOT NULL,
        Username            NVARCHAR(100) NULL,
        Email               NVARCHAR(150) NOT NULL,
        PasswordHash        NVARCHAR(255) NOT NULL,
        PhoneNumber         NVARCHAR(20) NULL,
        VehicleType         NVARCHAR(100) NOT NULL DEFAULT 'Motorbike', -- Motorbike, Bicycle, Scooter, Electric EV
        LicenseNumber       NVARCHAR(100) NULL,
        LicenseDocumentUrl  NVARCHAR(500) NULL,
        CurrentStatus       NVARCHAR(50) NOT NULL DEFAULT 'Available', -- Available, On Delivery, Offline
        IsActive            BIT NOT NULL DEFAULT 1,
        CreatedAt           DATETIME2 NOT NULL DEFAULT GETDATE(),

        CONSTRAINT UQ_Riders_Email UNIQUE (Email)
    );
END
GO

--------------------------------------------------------------------------------
-- 2. INDEXES
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Riders_Email' AND object_id = OBJECT_ID('dbo.Riders'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Riders_Email ON dbo.Riders(Email);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Riders_Username' AND object_id = OBJECT_ID('dbo.Riders'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Riders_Username ON dbo.Riders(Username) WHERE Username IS NOT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Riders_CurrentStatus' AND object_id = OBJECT_ID('dbo.Riders'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Riders_CurrentStatus ON dbo.Riders(CurrentStatus) WHERE IsActive = 1;
END
GO

--------------------------------------------------------------------------------
-- 3. DEFAULT RIDER SEED
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Riders WHERE RiderId = 1 OR Email = 'rider@example.com')
BEGIN
    SET IDENTITY_INSERT dbo.Riders ON;

    INSERT INTO dbo.Riders 
        (RiderId, RiderName, Username, Email, PasswordHash, PhoneNumber, VehicleType, LicenseNumber, LicenseDocumentUrl, CurrentStatus, IsActive)
    VALUES 
        (1, 'Amit Kumar (Speedy)', 'speedy_amit', 'rider@example.com', 'rider123', '9876599999', 'Hero Splendor Plus', 'DL-09-2022-887712', '/Content/images/rider-avatar.png', 'Available', 1);

    SET IDENTITY_INSERT dbo.Riders OFF;
END
GO

--------------------------------------------------------------------------------
-- 4. INLINE ADO.NET SQL QUERIES (Used directly in C# RiderRepository.cs)
--------------------------------------------------------------------------------

/*
--- QUERY A: Duplicate Check Across All System Roles ---
SELECT 1 FROM dbo.Riders WHERE LOWER(Email) = @Email OR LOWER(Username) = @Username
UNION ALL
SELECT 1 FROM dbo.Customers WHERE LOWER(Email) = @Email OR LOWER(Username) = @Username
UNION ALL
SELECT 1 FROM dbo.Restaurants WHERE LOWER(Email) = @Email OR LOWER(Username) = @Username
UNION ALL
SELECT 1 FROM dbo.RestaurantStaff WHERE LOWER(Email) = @Email OR LOWER(Username) = @Username
UNION ALL
SELECT 1 FROM dbo.Admins WHERE LOWER(Username) = @Username;

--- QUERY B: Register New Delivery Rider ---
INSERT INTO dbo.Riders 
    (RiderName, Username, Email, PasswordHash, PhoneNumber, VehicleType, LicenseNumber, LicenseDocumentUrl, CurrentStatus, IsActive)
VALUES 
    (@Name, @Username, @Email, @Password, @Phone, @Vehicle, @LicenseNumber, @LicenseUrl, 'Available', 1);
SELECT CAST(SCOPE_IDENTITY() AS INT);

--- QUERY C: Rider Login by Username OR Email ---
SELECT RiderId, RiderName, Username, Email, PasswordHash, PhoneNumber, VehicleType, LicenseNumber, LicenseDocumentUrl, CurrentStatus, IsActive
FROM dbo.Riders
WHERE (LOWER(Email) = @LoginId OR LOWER(Username) = @LoginId)
  AND IsActive = 1;

--- QUERY D: Get Rider By ID ---
SELECT RiderId, RiderName, Username, Email, PhoneNumber, VehicleType, LicenseNumber, LicenseDocumentUrl, CurrentStatus, IsActive, CreatedAt
FROM dbo.Riders
WHERE RiderId = @RiderId;

--- QUERY E: Get All Active Riders (For Admin Dispatch / Operations) ---
SELECT RiderId, RiderName, Username, Email, PhoneNumber, VehicleType, LicenseNumber, LicenseDocumentUrl, CurrentStatus, IsActive, CreatedAt
FROM dbo.Riders
WHERE IsActive = 1
ORDER BY CurrentStatus ASC, RiderName ASC;

--- QUERY F: Update Rider Duty Status (Available / On Delivery / Offline) ---
UPDATE dbo.Riders
SET CurrentStatus = @Status
WHERE RiderId = @RiderId;

--- QUERY G: Change Rider Password ---
UPDATE dbo.Riders 
SET PasswordHash = @Password 
WHERE RiderId = @RiderId;
*/
GO
