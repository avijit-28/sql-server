/*
================================================================================
 DATABASE OBJECT: dbo.Notifications
 APPLICATION: FoodReady (ASP.NET MVC 5)
 LOCATION: D:\avi\sql\FoodReady\09_Notifications.sql
 DESCRIPTION:
     Table definition, indexes, and ADO.NET inline queries for multi-role
     push alerts, order dispatch notifications, and unread badge counters.
================================================================================
*/

USE FoodArrivalDB;
GO

--------------------------------------------------------------------------------
-- 1. TABLE DEFINITION
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Notifications', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Notifications
    (
        NotificationId   INT IDENTITY(1,1) PRIMARY KEY,
        TargetRole       NVARCHAR(50) NOT NULL, -- Admin, Customer, RestaurantOwner, RestaurantStaff, Rider, All
        TargetUserId     INT NULL,
        Title            NVARCHAR(150) NOT NULL,
        Message          NVARCHAR(500) NOT NULL,
        NotificationType NVARCHAR(50) NOT NULL DEFAULT 'Info', -- Info, Success, Warning, Alert, Order
        IsRead           BIT NOT NULL DEFAULT 0,
        TargetUrl        NVARCHAR(255) NULL,
        CreatedAt        DATETIME2 NOT NULL DEFAULT GETDATE()
    );
END
GO

--------------------------------------------------------------------------------
-- 2. INDEXES
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Notifications_Role_User' AND object_id = OBJECT_ID('dbo.Notifications'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Notifications_Role_User ON dbo.Notifications(TargetRole, TargetUserId, IsRead);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Notifications_CreatedAt' AND object_id = OBJECT_ID('dbo.Notifications'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Notifications_CreatedAt ON dbo.Notifications(CreatedAt DESC);
END
GO

--------------------------------------------------------------------------------
-- 3. INLINE ADO.NET SQL QUERIES (Used directly in C# NotificationRepository.cs)
--------------------------------------------------------------------------------

/*
--- QUERY A: Get Recent Notifications for Admin ---
SELECT TOP 15 NotificationId, TargetUserId AS UserId, TargetRole AS UserRole, Title, Message, NotificationType, IsRead, CreatedAt, TargetUrl
FROM dbo.Notifications
WHERE TargetRole = 'Admin'
ORDER BY CreatedAt DESC;

--- QUERY B: Get Private Notifications for Specific User (Customer, Restaurant, Staff, Rider) ---
SELECT TOP 15 NotificationId, TargetUserId AS UserId, TargetRole AS UserRole, Title, Message, NotificationType, IsRead, CreatedAt, TargetUrl
FROM dbo.Notifications
WHERE TargetRole = @Role AND TargetUserId = @UserId
ORDER BY CreatedAt DESC;

--- QUERY C: Insert New Notification Alert ---
INSERT INTO dbo.Notifications (TargetUserId, TargetRole, Title, Message, NotificationType, TargetUrl)
VALUES (@UserId, @UserRole, @Title, @Message, @Type, @TargetUrl);

--- QUERY D: Mark All Notifications as Read for User ---
UPDATE dbo.Notifications 
SET IsRead = 1 
WHERE TargetRole = @Role AND TargetUserId = @UserId;

--- QUERY E: Mark All Notifications as Read for Admin ---
UPDATE dbo.Notifications 
SET IsRead = 1 
WHERE TargetRole = 'Admin';
*/
GO
