/*
================================================================================
 DATABASE OBJECT: dbo.OrderStatusHistory
 APPLICATION: FoodReady (ASP.NET MVC 5)
 LOCATION: D:\avi\sql\FoodReady\14_OrderStatusHistory.sql
 DESCRIPTION:
     Table definition, foreign keys, indexes, and ADO.NET inline queries
     for immutable order timeline event logging and real-time order tracking.
================================================================================
*/

USE FoodArrivalDB;
GO

--------------------------------------------------------------------------------
-- 1. TABLE DEFINITION
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.OrderStatusHistory', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.OrderStatusHistory
    (
        HistoryId       INT IDENTITY(1,1) PRIMARY KEY,
        OrderId         INT NOT NULL,
        Status          NVARCHAR(50) NOT NULL, -- Placed, Accepted, Preparing, ReadyForPickup, OutForDelivery, Delivered, Rejected, Cancelled
        ChangedByUserId INT NULL,
        ChangedByRole   NVARCHAR(50) NOT NULL, -- Customer, RestaurantOwner, KitchenStaff, Rider, Admin, System
        Message         NVARCHAR(500) NULL,
        CreatedAt       DATETIME2 NOT NULL DEFAULT GETDATE(),

        CONSTRAINT FK_OrderStatusHistory_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId)
    );
END
GO

--------------------------------------------------------------------------------
-- 2. INDEXES
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderStatusHistory_OrderId' AND object_id = OBJECT_ID('dbo.OrderStatusHistory'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_OrderStatusHistory_OrderId ON dbo.OrderStatusHistory(OrderId, CreatedAt ASC);
END
GO

--------------------------------------------------------------------------------
-- 3. INLINE ADO.NET SQL QUERIES (Used across Repositories for Status Logging)
--------------------------------------------------------------------------------

/*
--- QUERY A: Log New Status Event into Timeline ---
INSERT INTO dbo.OrderStatusHistory (OrderId, Status, ChangedByUserId, ChangedByRole, Message, CreatedAt)
VALUES (@OrderId, @Status, @UserId, @Role, @Message, GETDATE());

--- QUERY B: Fetch Live Tracking Timeline for Customer & Rider Order Details Screen ---
SELECT HistoryId, OrderId, Status, ChangedByUserId, ChangedByRole, Message, CreatedAt
FROM dbo.OrderStatusHistory
WHERE OrderId = @OrderId
ORDER BY CreatedAt ASC;
*/
GO
