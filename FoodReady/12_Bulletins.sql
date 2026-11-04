/*
================================================================================
 DATABASE OBJECT: dbo.Bulletins
 APPLICATION: FoodReady (ASP.NET MVC 5)
 LOCATION: D:\avi\sql\FoodReady\12_Bulletins.sql
 DESCRIPTION:
     Table definition, foreign keys, indexes, and ADO.NET inline queries
     for Public Announcements, System Flash Bulletins, and role-targeted broadcast alerts.
================================================================================
*/

USE FoodArrivalDB;
GO

--------------------------------------------------------------------------------
-- 1. TABLE DEFINITION
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Bulletins', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Bulletins
    (
        BulletinId          INT IDENTITY(1,1) PRIMARY KEY,
        Title               NVARCHAR(200) NOT NULL,
        Message             NVARCHAR(MAX) NOT NULL,
        TargetAudience      NVARCHAR(50) NOT NULL DEFAULT 'All', -- All, Customers, Restaurants, Riders
        Priority            NVARCHAR(50) NOT NULL DEFAULT 'Normal', -- Normal, Important, Urgent
        CreatedByAdminId    INT NOT NULL DEFAULT 1,
        CreatedAt           DATETIME2 NOT NULL DEFAULT GETDATE(),
        IsActive            BIT NOT NULL DEFAULT 1,

        CONSTRAINT FK_Bulletins_Admins FOREIGN KEY (CreatedByAdminId) REFERENCES dbo.Admins(AdminId)
    );
END
GO

--------------------------------------------------------------------------------
-- 2. INDEXES
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Bulletins_Audience_Active' AND object_id = OBJECT_ID('dbo.Bulletins'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Bulletins_Audience_Active ON dbo.Bulletins(TargetAudience, IsActive);
END
GO

--------------------------------------------------------------------------------
-- 3. SEED BULLETINS
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Bulletins WHERE BulletinId = 1)
BEGIN
    INSERT INTO dbo.Bulletins (Title, Message, TargetAudience, Priority, CreatedByAdminId, CreatedAt, IsActive)
    VALUES 
    ('Welcome to FoodReady Platform!', 'We are excited to launch our new 4-role multi-vendor food delivery ecosystem with live OTP delivery tracking.', 'All', 'Important', 1, GETDATE(), 1),
    ('Rain Alert for Delivery Partners', 'Please ride safely in monsoon zones. Protective waterproof rain gear is required during deliveries.', 'Riders', 'Urgent', 1, GETDATE(), 1),
    ('Hygiene & Packaging Protocol', 'All registered restaurant kitchens must ensure sealed tamper-evident food packages.', 'Restaurants', 'Important', 1, GETDATE(), 1);
END
GO

--------------------------------------------------------------------------------
-- 4. INLINE ADO.NET SQL QUERIES (Used directly in C# AdminRepository.cs)
--------------------------------------------------------------------------------

/*
--- QUERY A: Get Active Bulletins Filtered by Target Audience ---
SELECT BulletinId, Title, Message, TargetAudience, Priority, CreatedByAdminId, CreatedAt, IsActive
FROM dbo.Bulletins
WHERE IsActive = 1
  AND (@Audience IS NULL OR TargetAudience = 'All' OR TargetAudience = @Audience)
ORDER BY BulletinId DESC;

--- QUERY B: Publish New Platform Bulletin ---
INSERT INTO dbo.Bulletins (Title, Message, TargetAudience, Priority, CreatedByAdminId)
VALUES (@Title, @Message, @TargetAudience, @Priority, @AdminId);

--- QUERY C: Soft Delete / Deactivate Bulletin ---
UPDATE dbo.Bulletins 
SET IsActive = 0 
WHERE BulletinId = @Id;
*/
GO
