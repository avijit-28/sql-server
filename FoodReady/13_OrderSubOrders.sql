/*
================================================================================
 DATABASE OBJECT: dbo.OrderSubOrders
 APPLICATION: FoodReady (ASP.NET MVC 5)
 LOCATION: D:\avi\sql\FoodReady\13_OrderSubOrders.sql
 DESCRIPTION:
     Table definition, foreign keys, indexes, and ADO.NET inline queries
     for Multi-Vendor Cart splitting (one master order split into multiple
     kitchen restaurant sub-orders with independent cooking prep timers).
================================================================================
*/

USE FoodArrivalDB;
GO

--------------------------------------------------------------------------------
-- 1. TABLE DEFINITION
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.OrderSubOrders', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.OrderSubOrders
    (
        SubOrderId          INT IDENTITY(1,1) PRIMARY KEY,
        OrderId             INT NOT NULL,
        RestaurantId        INT NOT NULL,
        RiderId             INT NULL,
        SubTotal            DECIMAL(10,2) NOT NULL DEFAULT 0,
        PreparationStatus   NVARCHAR(50) NOT NULL DEFAULT 'Confirmed', -- Confirmed, Preparing, ReadyForPickup, Completed
        EstimatedReadyAt    DATETIME2 NULL,
        DeliveryStatus      NVARCHAR(50) NOT NULL DEFAULT 'Pending',   -- Pending, OutForDelivery, Delivered, Cancelled
        PickupSequence      INT NOT NULL DEFAULT 1,
        DeliveryOtp         NVARCHAR(10) NULL,
        DeliveredAt         DATETIME2 NULL,
        CreatedAt           DATETIME2 NOT NULL DEFAULT GETDATE(),

        CONSTRAINT FK_OrderSubOrders_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId),
        CONSTRAINT FK_OrderSubOrders_Restaurants FOREIGN KEY (RestaurantId) REFERENCES dbo.Restaurants(RestaurantId),
        CONSTRAINT FK_OrderSubOrders_Riders FOREIGN KEY (RiderId) REFERENCES dbo.Riders(RiderId)
    );
END
GO

--------------------------------------------------------------------------------
-- 2. INDEXES
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderSubOrders_OrderId' AND object_id = OBJECT_ID('dbo.OrderSubOrders'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_OrderSubOrders_OrderId ON dbo.OrderSubOrders(OrderId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderSubOrders_RestaurantId' AND object_id = OBJECT_ID('dbo.OrderSubOrders'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_OrderSubOrders_RestaurantId ON dbo.OrderSubOrders(RestaurantId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderSubOrders_RiderId' AND object_id = OBJECT_ID('dbo.OrderSubOrders'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_OrderSubOrders_RiderId ON dbo.OrderSubOrders(RiderId);
END
GO

--------------------------------------------------------------------------------
-- 3. INLINE ADO.NET SQL QUERIES (Used in OrderRepository, RestaurantRepository & RiderRepository)
--------------------------------------------------------------------------------

/*
--- QUERY A: Insert Sub-Order for Each Restaurant in Multi-Vendor Checkout ---
INSERT INTO dbo.OrderSubOrders 
    (OrderId, RestaurantId, SubTotal, PreparationStatus, EstimatedReadyAt, DeliveryStatus, PickupSequence, CreatedAt, DeliveryOtp)
VALUES 
    (@OrderId, @RestaurantId, @SubTotal, 'Confirmed', DATEADD(MINUTE, @PrepMin, GETDATE()), 'Pending', 1, GETDATE(), @DeliveryOtp);
SELECT CAST(SCOPE_IDENTITY() AS INT);

--- QUERY B: Restaurant Update Kitchen Preparation Status ---
UPDATE dbo.OrderSubOrders
SET PreparationStatus = @Status,
    DeliveryStatus = CASE WHEN @Status = 'ReadyForPickup' THEN 'ReadyForPickup' ELSE DeliveryStatus END
WHERE OrderId = @OrderId AND RestaurantId = @RestaurantId;

--- QUERY C: Rider Assign to Sub-Orders ---
UPDATE dbo.OrderSubOrders
SET RiderId = @RiderId, 
    DeliveryStatus = 'OutForDelivery'
WHERE OrderId = @OrderId;

--- QUERY D: Complete Sub-Order Delivery on Customer OTP Verification ---
UPDATE dbo.OrderSubOrders
SET DeliveryStatus = 'Delivered', 
    DeliveredAt = GETDATE()
WHERE OrderId = @OrderId;
*/
GO
