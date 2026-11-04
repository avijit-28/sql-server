/*
================================================================================
 DATABASE OBJECT: dbo.OrderDetails
 APPLICATION: FoodReady (ASP.NET MVC 5)
 LOCATION: D:\avi\sql\FoodReady\08_OrderDetails.sql
 DESCRIPTION:
     Table definition, computed persistence column for line-item subtotal,
     foreign keys, indexes, and inline queries for itemized billing and kitchen slips.
================================================================================
*/

USE FoodArrivalDB;
GO

--------------------------------------------------------------------------------
-- 1. TABLE DEFINITION
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.OrderDetails', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.OrderDetails
    (
        OrderDetailId INT IDENTITY(1,1) PRIMARY KEY,
        OrderId       INT NOT NULL,
        FoodItemId    INT NOT NULL,
        Quantity      INT NOT NULL,
        UnitPrice     DECIMAL(10,2) NOT NULL,
        SubTotal      AS (Quantity * UnitPrice) PERSISTED,

        CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId),
        CONSTRAINT FK_OrderDetails_FoodItems FOREIGN KEY (FoodItemId) REFERENCES dbo.FoodItems(FoodItemId),
        CONSTRAINT CK_OrderDetails_Quantity CHECK (Quantity > 0),
        CONSTRAINT CK_OrderDetails_UnitPrice CHECK (UnitPrice >= 0)
    );
END
GO

--------------------------------------------------------------------------------
-- 2. INDEXES
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderDetails_OrderId' AND object_id = OBJECT_ID('dbo.OrderDetails'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_OrderDetails_OrderId ON dbo.OrderDetails(OrderId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderDetails_FoodItemId' AND object_id = OBJECT_ID('dbo.OrderDetails'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_OrderDetails_FoodItemId ON dbo.OrderDetails(FoodItemId);
END
GO

--------------------------------------------------------------------------------
-- 3. INLINE ADO.NET SQL QUERIES (Used for Item Extraction & Summaries)
--------------------------------------------------------------------------------

/*
--- QUERY A: Insert Item Line in Transaction ---
INSERT INTO dbo.OrderDetails (OrderId, FoodItemId, Quantity, UnitPrice)
VALUES (@OrderId, @FoodItemId, @Quantity, @UnitPrice);

--- QUERY B: Fetch Itemized Food Breakdown for Kitchen Ticket & Receipt ---
SELECT od.OrderDetailId, od.OrderId, od.FoodItemId, f.ItemName, f.Category, od.Quantity, od.UnitPrice, od.SubTotal
FROM dbo.OrderDetails od
INNER JOIN dbo.FoodItems f ON od.FoodItemId = f.FoodItemId
WHERE od.OrderId = @OrderId
ORDER BY od.OrderDetailId ASC;

--- QUERY C: Concatenate Items for Order Dashboard Grid ---
SELECT STUFF
(
    (
        SELECT ', ' + f.ItemName + ' x' + CAST(od.Quantity AS NVARCHAR(10))
        FROM dbo.OrderDetails od
        INNER JOIN dbo.FoodItems f ON od.FoodItemId = f.FoodItemId
        WHERE od.OrderId = @OrderId
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, ''
) AS OrderSummary;
*/
GO
