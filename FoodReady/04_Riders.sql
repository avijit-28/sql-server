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

