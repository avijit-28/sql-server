/*
================================================================================
 DATABASE OBJECT: dbo.Orders & dbo.OrderItemType
 APPLICATION: FoodReady (ASP.NET MVC 5)
 LOCATION: D:\avi\sql\FoodReady\07_Orders.sql
 DESCRIPTION:
     Table definition, foreign keys, table-valued parameter (TVP), indexes,
     comprehensive order lifecycle stored procedures, and inline queries
     for restaurant kitchen queue, rider dispatch, and OTP delivery verification.
================================================================================
*/

USE FoodArrivalDB;
GO

--------------------------------------------------------------------------------
-- 1. TABLE-VALUED TYPE FOR CHECKOUT
--------------------------------------------------------------------------------
IF TYPE_ID('dbo.OrderItemType') IS NULL
BEGIN
    CREATE TYPE dbo.OrderItemType AS TABLE
    (
        FoodItemId INT NOT NULL,
        Quantity   INT NOT NULL
    );
END
GO

--------------------------------------------------------------------------------
-- 2. TABLE DEFINITION
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Orders', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Orders
    (
        OrderId         INT IDENTITY(1,1) PRIMARY KEY,
        CustomerId      INT NOT NULL,
        RestaurantId    INT NULL,
        RiderId         INT NULL,
        TotalAmount     DECIMAL(10,2) NOT NULL DEFAULT 0,
        OrderStatus     NVARCHAR(20) NOT NULL DEFAULT 'Pending',   -- Pending, Accepted, Rejected, Cancelled
        DeliveryStatus  NVARCHAR(50) NOT NULL DEFAULT 'Pending',   -- Pending, Accepted, Preparing, ReadyForPickup, OutForDelivery, Delivered
        DeliveryOtp     NVARCHAR(10) NULL,
        OrderedAt       DATETIME2 NOT NULL DEFAULT GETDATE(),
        ProcessedAt     DATETIME2 NULL,
        ProcessedBy     INT NULL,
        RejectionReason NVARCHAR(500) NULL,

        CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerId) REFERENCES dbo.Customers(CustomerId),
        CONSTRAINT FK_Orders_Admins FOREIGN KEY (ProcessedBy) REFERENCES dbo.Admins(AdminId),
        CONSTRAINT FK_Orders_Restaurants FOREIGN KEY (RestaurantId) REFERENCES dbo.Restaurants(RestaurantId),
        CONSTRAINT FK_Orders_Riders FOREIGN KEY (RiderId) REFERENCES dbo.Riders(RiderId),
        CONSTRAINT CK_Orders_Status CHECK (OrderStatus IN ('Pending', 'Accepted', 'Rejected', 'Cancelled')),
        CONSTRAINT CK_Orders_Total CHECK (TotalAmount >= 0)
    );
END
GO

--------------------------------------------------------------------------------
-- 3. INDEXES
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_CustomerId' AND object_id = OBJECT_ID('dbo.Orders'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Orders_CustomerId ON dbo.Orders(CustomerId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_Status' AND object_id = OBJECT_ID('dbo.Orders'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Orders_Status ON dbo.Orders(OrderStatus);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_OrderedAt' AND object_id = OBJECT_ID('dbo.Orders'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Orders_OrderedAt ON dbo.Orders(OrderedAt);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_RestaurantId' AND object_id = OBJECT_ID('dbo.Orders'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Orders_RestaurantId ON dbo.Orders(RestaurantId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_RiderId' AND object_id = OBJECT_ID('dbo.Orders'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Orders_RiderId ON dbo.Orders(RiderId);
END
GO

--------------------------------------------------------------------------------
-- 4. STORED PROCEDURES
--------------------------------------------------------------------------------

-- SP 1: Place Single Item Order
IF OBJECT_ID('dbo.sp_Order_Create', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Order_Create;
GO

CREATE PROCEDURE dbo.sp_Order_Create
(
    @CustomerId INT,
    @FoodItemId INT,
    @Quantity   INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @UnitPrice    DECIMAL(10,2);
        DECLARE @RestaurantId INT;
        DECLARE @OrderId      INT;

        IF @Quantity <= 0
            RAISERROR('Quantity must be greater than zero.', 16, 1);

        SELECT @UnitPrice = Price, @RestaurantId = ISNULL(RestaurantId, 1) 
        FROM dbo.FoodItems 
        WHERE FoodItemId = @FoodItemId AND IsAvailable = 1;

        IF @UnitPrice IS NULL
            RAISERROR('Food item is not available.', 16, 1);

        IF NOT EXISTS (SELECT 1 FROM dbo.Customers WHERE CustomerId = @CustomerId AND IsActive = 1)
            RAISERROR('Customer is not active or does not exist.', 16, 1);

        INSERT INTO dbo.Orders (CustomerId, RestaurantId, TotalAmount, OrderStatus, DeliveryStatus, DeliveryOtp)
        VALUES (@CustomerId, @RestaurantId, 0, 'Pending', 'Pending', RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS VARCHAR(6)), 6));

        SET @OrderId = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO dbo.OrderDetails (OrderId, FoodItemId, Quantity, UnitPrice)
        VALUES (@OrderId, @FoodItemId, @Quantity, @UnitPrice);

        UPDATE dbo.Orders
        SET TotalAmount = (SELECT SUM(SubTotal) FROM dbo.OrderDetails WHERE OrderId = @OrderId)
        WHERE OrderId = @OrderId;

        COMMIT TRANSACTION;

        SELECT 1 AS Result, @OrderId AS OrderId, 'Order placed successfully.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- SP 2: Place Multi-Item Cart Order (Table-Valued Parameter)
IF OBJECT_ID('dbo.sp_Order_CreateMultiple', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Order_CreateMultiple;
GO

CREATE PROCEDURE dbo.sp_Order_CreateMultiple
(
    @CustomerId INT,
    @Items      dbo.OrderItemType READONLY
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OrderId INT;
        DECLARE @PrimaryRestId INT;

        IF NOT EXISTS (SELECT 1 FROM @Items WHERE Quantity > 0)
            RAISERROR('Order must contain at least one item.', 16, 1);

        IF EXISTS
        (
            SELECT 1
            FROM @Items i
            LEFT JOIN dbo.FoodItems f ON i.FoodItemId = f.FoodItemId
            WHERE f.FoodItemId IS NULL OR f.IsAvailable = 0 OR i.Quantity <= 0
        )
        BEGIN
            RAISERROR('One or more food items are unavailable.', 16, 1);
        END;

        IF NOT EXISTS (SELECT 1 FROM dbo.Customers WHERE CustomerId = @CustomerId AND IsActive = 1)
            RAISERROR('Customer is not active or does not exist.', 16, 1);

        SELECT TOP 1 @PrimaryRestId = ISNULL(f.RestaurantId, 1)
        FROM @Items i
        INNER JOIN dbo.FoodItems f ON i.FoodItemId = f.FoodItemId;

        INSERT INTO dbo.Orders (CustomerId, RestaurantId, TotalAmount, OrderStatus, DeliveryStatus, DeliveryOtp)
        VALUES (@CustomerId, @PrimaryRestId, 0, 'Pending', 'Pending', RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS VARCHAR(6)), 6));

        SET @OrderId = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO dbo.OrderDetails (OrderId, FoodItemId, Quantity, UnitPrice)
        SELECT @OrderId, i.FoodItemId, i.Quantity, f.Price
        FROM @Items i
        INNER JOIN dbo.FoodItems f ON i.FoodItemId = f.FoodItemId;

        UPDATE dbo.Orders
        SET TotalAmount = (SELECT SUM(SubTotal) FROM dbo.OrderDetails WHERE OrderId = @OrderId)
        WHERE OrderId = @OrderId;

        COMMIT TRANSACTION;

        SELECT 1 AS Result, @OrderId AS OrderId, 'Order placed successfully.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- SP 3: Get Customer Order History
IF OBJECT_ID('dbo.sp_Order_GetByCustomer', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Order_GetByCustomer;
GO

CREATE PROCEDURE dbo.sp_Order_GetByCustomer
(
    @CustomerId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT o.OrderId, o.CustomerId, o.RestaurantId, r.RestaurantName, o.TotalAmount, o.OrderStatus, o.DeliveryStatus, o.DeliveryOtp, o.OrderedAt, o.ProcessedAt
    FROM dbo.Orders o
    LEFT JOIN dbo.Restaurants r ON o.RestaurantId = r.RestaurantId
    WHERE o.CustomerId = @CustomerId
    ORDER BY o.OrderedAt DESC;
END;
GO

-- SP 4: Get Order Details by Order ID
IF OBJECT_ID('dbo.sp_Order_GetDetails', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Order_GetDetails;
GO

CREATE PROCEDURE dbo.sp_Order_GetDetails
(
    @OrderId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.OrderId,
        c.CustomerId,
        c.CustomerName,
        c.Email,
        c.PhoneNumber,
        c.Address,
        o.RestaurantId,
        r.RestaurantName,
        o.RiderId,
        rd.RiderName,
        o.TotalAmount,
        o.OrderStatus,
        o.DeliveryStatus,
        o.DeliveryOtp,
        o.OrderedAt,
        o.ProcessedAt,
        o.RejectionReason,
        f.FoodItemId,
        f.ItemName,
        od.Quantity,
        od.UnitPrice,
        od.SubTotal
    FROM dbo.Orders o
    INNER JOIN dbo.Customers c ON o.CustomerId = c.CustomerId
    LEFT JOIN dbo.Restaurants r ON o.RestaurantId = r.RestaurantId
    LEFT JOIN dbo.Riders rd ON o.RiderId = rd.RiderId
    INNER JOIN dbo.OrderDetails od ON o.OrderId = od.OrderId
    INNER JOIN dbo.FoodItems f ON od.FoodItemId = f.FoodItemId
    WHERE o.OrderId = @OrderId
    ORDER BY od.OrderDetailId;
END;
GO

-- SP 5: Get Pending Orders Queue (Admin / Kitchen)
IF OBJECT_ID('dbo.sp_Order_GetPending', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Order_GetPending;
GO

CREATE PROCEDURE dbo.sp_Order_GetPending
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.OrderId,
        c.CustomerId,
        c.CustomerName,
        c.Email,
        o.RestaurantId,
        r.RestaurantName,
        o.TotalAmount,
        o.OrderedAt,
        o.OrderStatus,
        o.DeliveryStatus,
        STUFF
        (
            (
                SELECT ', ' + f.ItemName + ' x' + CAST(od.Quantity AS NVARCHAR(10))
                FROM dbo.OrderDetails od
                INNER JOIN dbo.FoodItems f ON od.FoodItemId = f.FoodItemId
                WHERE od.OrderId = o.OrderId
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 2, ''
        ) AS Items
    FROM dbo.Orders o
    INNER JOIN dbo.Customers c ON o.CustomerId = c.CustomerId
    LEFT JOIN dbo.Restaurants r ON o.RestaurantId = r.RestaurantId
    WHERE o.OrderStatus = 'Pending'
    ORDER BY o.OrderedAt DESC;
END;
GO

-- SP 6: Get Accepted Orders Queue
IF OBJECT_ID('dbo.sp_Order_GetAccepted', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Order_GetAccepted;
GO

CREATE PROCEDURE dbo.sp_Order_GetAccepted
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.OrderId,
        c.CustomerId,
        c.CustomerName,
        c.Email,
        o.RestaurantId,
        r.RestaurantName,
        o.TotalAmount,
        o.OrderedAt,
        o.ProcessedAt,
        o.OrderStatus,
        o.DeliveryStatus,
        STUFF
        (
            (
                SELECT ', ' + f.ItemName + ' x' + CAST(od.Quantity AS NVARCHAR(10))
                FROM dbo.OrderDetails od
                INNER JOIN dbo.FoodItems f ON od.FoodItemId = f.FoodItemId
                WHERE od.OrderId = o.OrderId
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 2, ''
        ) AS Items
    FROM dbo.Orders o
    INNER JOIN dbo.Customers c ON o.CustomerId = c.CustomerId
    LEFT JOIN dbo.Restaurants r ON o.RestaurantId = r.RestaurantId
    WHERE o.OrderStatus = 'Accepted'
    ORDER BY o.ProcessedAt DESC;
END;
GO

-- SP 7: Get Rejected Orders Queue
IF OBJECT_ID('dbo.sp_Order_GetRejected', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Order_GetRejected;
GO

CREATE PROCEDURE dbo.sp_Order_GetRejected
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.OrderId,
        c.CustomerId,
        c.CustomerName,
        c.Email,
        o.RestaurantId,
        r.RestaurantName,
        o.TotalAmount,
        o.OrderedAt,
        o.ProcessedAt,
        o.RejectionReason,
        o.OrderStatus,
        STUFF
        (
            (
                SELECT ', ' + f.ItemName + ' x' + CAST(od.Quantity AS NVARCHAR(10))
                FROM dbo.OrderDetails od
                INNER JOIN dbo.FoodItems f ON od.FoodItemId = f.FoodItemId
                WHERE od.OrderId = o.OrderId
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 2, ''
        ) AS Items
    FROM dbo.Orders o
    INNER JOIN dbo.Customers c ON o.CustomerId = c.CustomerId
    LEFT JOIN dbo.Restaurants r ON o.RestaurantId = r.RestaurantId
    WHERE o.OrderStatus = 'Rejected'
    ORDER BY o.ProcessedAt DESC;
END;
GO

-- SP 8: Today's Pending Orders
IF OBJECT_ID('dbo.sp_Order_GetTodayPending', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Order_GetTodayPending;
GO

CREATE PROCEDURE dbo.sp_Order_GetTodayPending
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.OrderId,
        c.CustomerId,
        c.CustomerName,
        c.Email,
        o.TotalAmount,
        o.OrderedAt,
        o.OrderStatus,
        STUFF
        (
            (
                SELECT ', ' + f.ItemName + ' x' + CAST(od.Quantity AS NVARCHAR(10))
                FROM dbo.OrderDetails od
                INNER JOIN dbo.FoodItems f ON od.FoodItemId = f.FoodItemId
                WHERE od.OrderId = o.OrderId
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 2, ''
        ) AS Items
    FROM dbo.Orders o
    INNER JOIN dbo.Customers c ON o.CustomerId = c.CustomerId
    WHERE o.OrderStatus = 'Pending'
      AND o.OrderedAt >= CAST(GETDATE() AS DATE)
      AND o.OrderedAt < DATEADD(DAY, 1, CAST(GETDATE() AS DATE))
    ORDER BY o.OrderedAt ASC;
END;
GO

-- SP 9: Today's Accepted Orders
IF OBJECT_ID('dbo.sp_Order_GetTodayAccepted', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Order_GetTodayAccepted;
GO

CREATE PROCEDURE dbo.sp_Order_GetTodayAccepted
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.OrderId,
        c.CustomerId,
        c.CustomerName,
        c.Email,
        o.TotalAmount,
        o.OrderedAt,
        o.ProcessedAt,
        o.OrderStatus,
        STUFF
        (
            (
                SELECT ', ' + f.ItemName + ' x' + CAST(od.Quantity AS NVARCHAR(10))
                FROM dbo.OrderDetails od
                INNER JOIN dbo.FoodItems f ON od.FoodItemId = f.FoodItemId
                WHERE od.OrderId = o.OrderId
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 2, ''
        ) AS Items
    FROM dbo.Orders o
    INNER JOIN dbo.Customers c ON o.CustomerId = c.CustomerId
    WHERE o.OrderStatus = 'Accepted'
      AND o.OrderedAt >= CAST(GETDATE() AS DATE)
      AND o.OrderedAt < DATEADD(DAY, 1, CAST(GETDATE() AS DATE))
    ORDER BY o.ProcessedAt DESC;
END;
GO

-- SP 10: Today's Rejected Orders
IF OBJECT_ID('dbo.sp_Order_GetTodayRejected', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Order_GetTodayRejected;
GO

CREATE PROCEDURE dbo.sp_Order_GetTodayRejected
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.OrderId,
        c.CustomerId,
        c.CustomerName,
        c.Email,
        o.TotalAmount,
        o.OrderedAt,
        o.ProcessedAt,
        o.RejectionReason,
        o.OrderStatus,
        STUFF
        (
            (
                SELECT ', ' + f.ItemName + ' x' + CAST(od.Quantity AS NVARCHAR(10))
                FROM dbo.OrderDetails od
                INNER JOIN dbo.FoodItems f ON od.FoodItemId = f.FoodItemId
                WHERE od.OrderId = o.OrderId
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 2, ''
        ) AS Items
    FROM dbo.Orders o
    INNER JOIN dbo.Customers c ON o.CustomerId = c.CustomerId
    WHERE o.OrderStatus = 'Rejected'
      AND o.OrderedAt >= CAST(GETDATE() AS DATE)
      AND o.OrderedAt < DATEADD(DAY, 1, CAST(GETDATE() AS DATE))
    ORDER BY o.ProcessedAt DESC;
END;
GO

-- SP 11: Admin / Kitchen Accept Order
IF OBJECT_ID('dbo.sp_Order_Accept', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Order_Accept;
GO

CREATE PROCEDURE dbo.sp_Order_Accept
(
    @OrderId INT,
    @AdminId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Orders WHERE OrderId = @OrderId AND OrderStatus = 'Pending')
    BEGIN
        SELECT 0 AS Result, 'Order is not in pending status.' AS Message;
        RETURN;
    END;

    UPDATE dbo.Orders
    SET OrderStatus    = 'Accepted',
        DeliveryStatus = 'Accepted',
        ProcessedAt    = GETDATE(),
        ProcessedBy    = @AdminId
    WHERE OrderId = @OrderId;

    SELECT 1 AS Result, 'Order accepted successfully.' AS Message;
END;
GO

-- SP 12: Admin / Kitchen Reject Order
IF OBJECT_ID('dbo.sp_Order_Reject', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Order_Reject;
GO

CREATE PROCEDURE dbo.sp_Order_Reject
(
    @OrderId         INT,
    @AdminId         INT,
    @RejectionReason NVARCHAR(500)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Orders WHERE OrderId = @OrderId AND OrderStatus = 'Pending')
    BEGIN
        SELECT 0 AS Result, 'Order is not in pending status.' AS Message;
        RETURN;
    END;

    UPDATE dbo.Orders
    SET OrderStatus     = 'Rejected',
        DeliveryStatus  = 'Cancelled',
        ProcessedAt     = GETDATE(),
        ProcessedBy     = @AdminId,
        RejectionReason = @RejectionReason
    WHERE OrderId = @OrderId;

    SELECT 1 AS Result, 'Order rejected successfully.' AS Message;
END;
GO

-- SP 13: Auto-Reject Orders Older Than 5 Minutes
IF OBJECT_ID('dbo.sp_Order_AutoReject', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Order_AutoReject;
GO

CREATE PROCEDURE dbo.sp_Order_AutoReject
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Orders
    SET OrderStatus     = 'Rejected',
        DeliveryStatus  = 'Cancelled',
        ProcessedAt     = GETDATE(),
        RejectionReason = 'Automatically rejected after 5 minutes of no restaurant response.'
    WHERE OrderStatus = 'Pending'
      AND DATEDIFF(SECOND, OrderedAt, GETDATE()) >= 300;

    SELECT @@ROWCOUNT AS RejectedOrders;
END;
GO

--------------------------------------------------------------------------------
-- 5. INLINE ADO.NET SQL QUERIES (Used in Restaurant & Rider Repositories)
--------------------------------------------------------------------------------

/*
--- QUERY A: Restaurant Update Cooking / Dispatch Status ---
UPDATE dbo.Orders 
SET DeliveryStatus = @Status 
WHERE OrderId = @OrderId;

--- QUERY B: Rider Accept & Assign Delivery ---
UPDATE dbo.Orders
SET RiderId = @RiderId,
    DeliveryStatus = 'OutForDelivery'
WHERE OrderId = @OrderId;

UPDATE dbo.Riders 
SET CurrentStatus = 'On Delivery' 
WHERE RiderId = @RiderId;

--- QUERY C: Rider Complete Delivery Handover (Verify 6-Digit Customer OTP) ---
SELECT DeliveryOtp, DeliveryStatus 
FROM dbo.Orders 
WHERE OrderId = @OrderId;

UPDATE dbo.Orders
SET DeliveryStatus = 'Delivered',
    ProcessedAt = GETDATE()
WHERE OrderId = @OrderId;

UPDATE dbo.Riders 
SET CurrentStatus = 'Available' 
WHERE RiderId = @RiderId;
*/
GO
