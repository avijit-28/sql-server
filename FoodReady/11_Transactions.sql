/*
================================================================================
 DATABASE OBJECT: dbo.Transactions
 APPLICATION: FoodReady (ASP.NET MVC 5)
 LOCATION: D:\avi\sql\FoodReady\11_Transactions.sql
 DESCRIPTION:
     Table definition, foreign keys, indexes, and ADO.NET inline queries
     for electronic payments, marketplace commission split (Platform Fee vs Restaurant Share),
     and financial audit reports.
================================================================================
*/

USE FoodArrivalDB;
GO

--------------------------------------------------------------------------------
-- 1. TABLE DEFINITION
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Transactions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Transactions
    (
        TransactionId        INT IDENTITY(1,1) PRIMARY KEY,
        OrderId              INT NOT NULL,
        TransactionReference NVARCHAR(100) NOT NULL,
        Amount               DECIMAL(10,2) NOT NULL,
        PaymentMethod        NVARCHAR(50) NOT NULL DEFAULT 'UPI / Online Card',
        PaymentStatus        NVARCHAR(50) NOT NULL DEFAULT 'Success',
        RestaurantShare      DECIMAL(10,2) NOT NULL DEFAULT 0,
        PlatformFee          DECIMAL(10,2) NOT NULL DEFAULT 0,
        DeliveryFee          DECIMAL(10,2) NOT NULL DEFAULT 0,
        CustomerName         NVARCHAR(150) NULL,
        RestaurantName       NVARCHAR(150) NULL,
        CreatedAt            DATETIME2 NOT NULL DEFAULT GETDATE(),

        CONSTRAINT FK_Transactions_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId),
        CONSTRAINT CK_Transactions_Amount CHECK (Amount >= 0)
    );
END
GO

--------------------------------------------------------------------------------
-- 2. INDEXES
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Transactions_OrderId' AND object_id = OBJECT_ID('dbo.Transactions'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Transactions_OrderId ON dbo.Transactions(OrderId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Transactions_CreatedAt' AND object_id = OBJECT_ID('dbo.Transactions'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Transactions_CreatedAt ON dbo.Transactions(CreatedAt DESC);
END
GO

--------------------------------------------------------------------------------
-- 3. SEED TRANSACTION DATA
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Transactions WHERE OrderId = 1)
BEGIN
    INSERT INTO dbo.Transactions 
        (OrderId, TransactionReference, Amount, PaymentMethod, PaymentStatus, RestaurantShare, PlatformFee, DeliveryFee, CustomerName, RestaurantName, CreatedAt)
    VALUES 
        (1, 'TXN-FR-20261103-0001', 598.00, 'UPI (GPay / PhonePe)', 'Success', 508.30, 59.80, 29.90, 'John Doe', 'FoodReady Central Kitchen', GETDATE());
END
GO

--------------------------------------------------------------------------------
-- 4. INLINE ADO.NET SQL QUERIES (Used in AdminRepository.cs & RestaurantRepository.cs)
--------------------------------------------------------------------------------

/*
--- QUERY A: Insert Transaction Record on Successful Order Checkout ---
INSERT INTO dbo.Transactions 
    (OrderId, TransactionReference, Amount, PaymentMethod, PaymentStatus, RestaurantShare, PlatformFee, DeliveryFee, CustomerName, RestaurantName, CreatedAt)
VALUES 
    (@OrderId, @TxnRef, @Amount, @PaymentMethod, 'Success', @RestShare, @PlatformFee, @DeliveryFee, @CustomerName, @RestaurantName, GETDATE());

--- QUERY B: Get Financial Transactions for Specific Restaurant ---
SELECT t.TransactionId, t.OrderId, t.TransactionReference, t.Amount, t.PaymentMethod, t.PaymentStatus,
       t.RestaurantShare, t.PlatformFee, t.DeliveryFee, t.CustomerName, t.RestaurantName, t.CreatedAt
FROM dbo.Transactions t
INNER JOIN dbo.Orders o ON t.OrderId = o.OrderId
WHERE o.RestaurantId = @RestaurantId
ORDER BY t.TransactionId DESC;

--- QUERY C: Get All Transactions for Admin Executive Panel ---
SELECT t.TransactionId, t.OrderId, t.TransactionReference, t.Amount, t.PaymentMethod, t.PaymentStatus,
       t.RestaurantShare, t.PlatformFee, t.DeliveryFee, t.CustomerName, t.RestaurantName, t.CreatedAt
FROM dbo.Transactions t
ORDER BY t.TransactionId DESC;

--- QUERY D: Financial Revenue & Commission Aggregation ---
SELECT 
    ISNULL(SUM(Amount), 0) AS TotalGrossSales,
    ISNULL(SUM(PlatformFee), 0) AS TotalPlatformEarnings,
    ISNULL(SUM(RestaurantShare), 0) AS TotalRestaurantDisbursements,
    ISNULL(SUM(DeliveryFee), 0) AS TotalDeliveryFeesCollected
FROM dbo.Transactions
WHERE PaymentStatus = 'Success';
*/
GO
