/* ============================================================
   FoodReady - Complete SQL Server Database
   Database: FoodDeliveryDB
   Run in SQL Server Management Studio (SSMS)
   ============================================================ */
USE master;
GO
IF DB_ID(N'FoodDeliveryDB') IS NULL CREATE DATABASE FoodDeliveryDB;
GO
USE FoodDeliveryDB;
GO

/* ========================= TABLES ========================== */
IF OBJECT_ID(N'dbo.Customers',N'U') IS NULL
CREATE TABLE dbo.Customers(
 Id INT IDENTITY(1,1) PRIMARY KEY,
 Username NVARCHAR(100) NULL,
 FullName NVARCHAR(150) NOT NULL,
 Email NVARCHAR(200) NOT NULL,
 Phone NVARCHAR(30) NULL,
 PasswordHash NVARCHAR(500) NOT NULL,
 Address NVARCHAR(500) NULL,
 IsActive BIT NOT NULL DEFAULT 1,
 CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
 UpdatedAt DATETIME2 NULL
);
GO
IF COL_LENGTH('dbo.Customers','Username') IS NULL ALTER TABLE dbo.Customers ADD Username NVARCHAR(100) NULL;
GO

IF OBJECT_ID(N'dbo.Admins',N'U') IS NULL
CREATE TABLE dbo.Admins(
 Id INT IDENTITY(1,1) PRIMARY KEY,
 Username NVARCHAR(100) NULL,
 FullName NVARCHAR(150) NOT NULL,
 Email NVARCHAR(200) NOT NULL,
 PasswordHash NVARCHAR(500) NOT NULL,
 IsActive BIT NOT NULL DEFAULT 1,
 CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
 UpdatedAt DATETIME2 NULL
);
GO
IF COL_LENGTH('dbo.Admins','Username') IS NULL ALTER TABLE dbo.Admins ADD Username NVARCHAR(100) NULL;
GO

IF OBJECT_ID(N'dbo.Restaurants',N'U') IS NULL
CREATE TABLE dbo.Restaurants(
 Id INT IDENTITY(1,1) PRIMARY KEY,
 OwnerName NVARCHAR(150) NOT NULL,
 RestaurantName NVARCHAR(200) NOT NULL,
 Username NVARCHAR(100) NOT NULL,
 Email NVARCHAR(200) NOT NULL,
 Phone NVARCHAR(30) NULL,
 PasswordHash NVARCHAR(500) NOT NULL,
 CuisineType NVARCHAR(150) NULL,
 Address NVARCHAR(500) NULL,
 City NVARCHAR(100) NULL,
 State NVARCHAR(100) NULL,
 Pincode NVARCHAR(20) NULL,
 Rating DECIMAL(3,2) NOT NULL DEFAULT 0,
 IsVerified BIT NOT NULL DEFAULT 0,
 IsActive BIT NOT NULL DEFAULT 1,
 CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
 UpdatedAt DATETIME2 NULL
);
GO

IF OBJECT_ID(N'dbo.Riders',N'U') IS NULL
CREATE TABLE dbo.Riders(
 Id INT IDENTITY(1,1) PRIMARY KEY,
 FullName NVARCHAR(150) NOT NULL,
 Username NVARCHAR(100) NOT NULL,
 Email NVARCHAR(200) NULL,
 Phone NVARCHAR(30) NOT NULL,
 PasswordHash NVARCHAR(500) NOT NULL,
 VehicleType NVARCHAR(50) NOT NULL,
 VehicleNumber NVARCHAR(50) NULL,
 IsAvailable BIT NOT NULL DEFAULT 1,
 IsActive BIT NOT NULL DEFAULT 1,
 IsVerified BIT NOT NULL DEFAULT 0,
 CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
 UpdatedAt DATETIME2 NULL
);
GO

IF OBJECT_ID(N'dbo.RestaurantStaff',N'U') IS NULL
CREATE TABLE dbo.RestaurantStaff(
 Id INT IDENTITY(1,1) PRIMARY KEY,
 RestaurantId INT NOT NULL,
 StaffCode NVARCHAR(50) NOT NULL,
 FullName NVARCHAR(150) NOT NULL,
 Username NVARCHAR(100) NOT NULL,
 Email NVARCHAR(200) NULL,
 Phone NVARCHAR(30) NULL,
 PasswordHash NVARCHAR(500) NOT NULL,
 Designation NVARCHAR(100) NOT NULL,
 PerformanceRating DECIMAL(3,2) NOT NULL DEFAULT 0,
 PreparedOrdersCount INT NOT NULL DEFAULT 0,
 IsApproved BIT NOT NULL DEFAULT 0,
 IsActive BIT NOT NULL DEFAULT 1,
 CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
 UpdatedAt DATETIME2 NULL,
 CONSTRAINT FK_RestaurantStaff_Restaurant FOREIGN KEY(RestaurantId) REFERENCES dbo.Restaurants(Id)
);
GO

IF OBJECT_ID(N'dbo.FoodItems',N'U') IS NULL
CREATE TABLE dbo.FoodItems(
 Id INT IDENTITY(1,1) PRIMARY KEY,
 RestaurantId INT NULL,
 SubmittedByStaffId INT NULL,
 Name NVARCHAR(200) NOT NULL,
 Description NVARCHAR(500) NULL,
 Category NVARCHAR(100) NULL,
 Price DECIMAL(18,2) NOT NULL,
 ImageUrl NVARCHAR(500) NULL,
 IsAvailable BIT NOT NULL DEFAULT 1,
 IsVerified BIT NOT NULL DEFAULT 0,
 CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
 UpdatedAt DATETIME2 NULL,
 CONSTRAINT FK_FoodItems_Restaurant FOREIGN KEY(RestaurantId) REFERENCES dbo.Restaurants(Id),
 CONSTRAINT FK_FoodItems_Staff FOREIGN KEY(SubmittedByStaffId) REFERENCES dbo.RestaurantStaff(Id)
);
GO
IF COL_LENGTH('dbo.FoodItems','RestaurantId') IS NULL ALTER TABLE dbo.FoodItems ADD RestaurantId INT NULL;
GO
IF COL_LENGTH('dbo.FoodItems','SubmittedByStaffId') IS NULL ALTER TABLE dbo.FoodItems ADD SubmittedByStaffId INT NULL;
GO
IF COL_LENGTH('dbo.FoodItems','IsVerified') IS NULL ALTER TABLE dbo.FoodItems ADD IsVerified BIT NOT NULL CONSTRAINT DF_FoodItems_IsVerified_Migration DEFAULT 0;
GO
IF COL_LENGTH('dbo.FoodItems','Category') IS NULL ALTER TABLE dbo.FoodItems ADD Category NVARCHAR(100) NULL;
GO

IF OBJECT_ID(N'dbo.Orders',N'U') IS NULL
CREATE TABLE dbo.Orders(
 Id INT IDENTITY(1,1) PRIMARY KEY,
 OrderNumber NVARCHAR(30) NOT NULL,
 CustomerId INT NOT NULL,
 RestaurantId INT NULL,
 RiderId INT NULL,
 TotalAmount DECIMAL(18,2) NOT NULL,
 DeliveryFee DECIMAL(18,2) NOT NULL DEFAULT 0,
 DeliveryAddress NVARCHAR(500) NULL,
 PaymentMethod NVARCHAR(50) NOT NULL DEFAULT 'COD',
 PaymentStatus NVARCHAR(50) NOT NULL DEFAULT 'Pending',
 OrderStatus NVARCHAR(50) NOT NULL DEFAULT 'Pending',
 DeliveryStatus NVARCHAR(50) NOT NULL DEFAULT 'Pending',
 RejectionReason NVARCHAR(500) NULL,
 OrderedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
 AcceptedAt DATETIME2 NULL,
 RejectedAt DATETIME2 NULL,
 DeliveredAt DATETIME2 NULL,
 CONSTRAINT FK_Orders_Customer FOREIGN KEY(CustomerId) REFERENCES dbo.Customers(Id),
 CONSTRAINT FK_Orders_Restaurant FOREIGN KEY(RestaurantId) REFERENCES dbo.Restaurants(Id),
 CONSTRAINT FK_Orders_Rider FOREIGN KEY(RiderId) REFERENCES dbo.Riders(Id)
);
GO
IF COL_LENGTH('dbo.Orders','RestaurantId') IS NULL ALTER TABLE dbo.Orders ADD RestaurantId INT NULL;
GO
IF COL_LENGTH('dbo.Orders','RiderId') IS NULL ALTER TABLE dbo.Orders ADD RiderId INT NULL;
GO
IF COL_LENGTH('dbo.Orders','DeliveryStatus') IS NULL ALTER TABLE dbo.Orders ADD DeliveryStatus NVARCHAR(50) NOT NULL CONSTRAINT DF_Orders_DeliveryStatus_Migration DEFAULT 'Pending';
GO

IF OBJECT_ID(N'dbo.OrderDetails',N'U') IS NULL
CREATE TABLE dbo.OrderDetails(
 Id INT IDENTITY(1,1) PRIMARY KEY,
 OrderId INT NOT NULL,
 FoodItemId INT NOT NULL,
 Quantity INT NOT NULL,
 UnitPrice DECIMAL(18,2) NOT NULL,
 SubTotal AS (Quantity*UnitPrice) PERSISTED,
 CONSTRAINT FK_OrderDetails_Order FOREIGN KEY(OrderId) REFERENCES dbo.Orders(Id),
 CONSTRAINT FK_OrderDetails_FoodItem FOREIGN KEY(FoodItemId) REFERENCES dbo.FoodItems(Id)
);
GO

IF OBJECT_ID(N'dbo.Notifications',N'U') IS NULL
CREATE TABLE dbo.Notifications(
 Id INT IDENTITY(1,1) PRIMARY KEY,
 RecipientRole NVARCHAR(30) NOT NULL,
 RecipientId INT NOT NULL,
 Title NVARCHAR(200) NOT NULL,
 Message NVARCHAR(1000) NOT NULL,
 NotificationType NVARCHAR(50) NULL,
 RelatedOrderId INT NULL,
 IsRead BIT NOT NULL DEFAULT 0,
 CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
 ReadAt DATETIME2 NULL,
 CONSTRAINT FK_Notifications_Order FOREIGN KEY(RelatedOrderId) REFERENCES dbo.Orders(Id)
);
GO

IF OBJECT_ID(N'dbo.RiderAffiliations',N'U') IS NULL
CREATE TABLE dbo.RiderAffiliations(
 Id INT IDENTITY(1,1) PRIMARY KEY,
 RiderId INT NOT NULL,
 RestaurantId INT NOT NULL,
 DrivingLicenseNo NVARCHAR(100) NOT NULL,
 LicenseDocumentUrl NVARCHAR(500) NULL,
 VehicleType NVARCHAR(50) NOT NULL,
 VehicleNumber NVARCHAR(50) NULL,
 IsApprovedByOwner BIT NOT NULL DEFAULT 0,
 IsApprovedByAdmin BIT NOT NULL DEFAULT 0,
 IsActive BIT NOT NULL DEFAULT 1,
 CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
 UpdatedAt DATETIME2 NULL,
 CONSTRAINT FK_RiderAffiliations_Rider FOREIGN KEY(RiderId) REFERENCES dbo.Riders(Id),
 CONSTRAINT FK_RiderAffiliations_Restaurant FOREIGN KEY(RestaurantId) REFERENCES dbo.Restaurants(Id)
);
GO

IF OBJECT_ID(N'dbo.Transactions',N'U') IS NULL
CREATE TABLE dbo.Transactions(
 Id INT IDENTITY(1,1) PRIMARY KEY,
 OrderId INT NOT NULL,
 TransactionReference NVARCHAR(100) NULL,
 PaymentGateway NVARCHAR(50) NULL,
 PaymentMethod NVARCHAR(50) NOT NULL,
 GrossAmount DECIMAL(18,2) NOT NULL,
 PlatformFee DECIMAL(18,2) NOT NULL DEFAULT 0,
 DeliveryFee DECIMAL(18,2) NOT NULL DEFAULT 0,
 RestaurantShare DECIMAL(18,2) NOT NULL DEFAULT 0,
 RiderShare DECIMAL(18,2) NOT NULL DEFAULT 0,
 PaymentStatus NVARCHAR(50) NOT NULL DEFAULT 'Pending',
 TransactionDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
 Remarks NVARCHAR(500) NULL,
 CONSTRAINT FK_Transactions_Order FOREIGN KEY(OrderId) REFERENCES dbo.Orders(Id)
);
GO

IF OBJECT_ID(N'dbo.Bulletins',N'U') IS NULL
CREATE TABLE dbo.Bulletins(
 Id INT IDENTITY(1,1) PRIMARY KEY,
 Title NVARCHAR(250) NOT NULL,
 Message NVARCHAR(MAX) NOT NULL,
 TargetRole NVARCHAR(30) NOT NULL DEFAULT 'All',
 Priority NVARCHAR(30) NOT NULL DEFAULT 'Normal',
 IsPublished BIT NOT NULL DEFAULT 1,
 PublishFrom DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
 PublishUntil DATETIME2 NULL,
 CreatedByAdminId INT NULL,
 CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
 UpdatedAt DATETIME2 NULL,
 CONSTRAINT FK_Bulletins_Admin FOREIGN KEY(CreatedByAdminId) REFERENCES dbo.Admins(Id)
);
GO

/* ========================= INDEXES ========================== */
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='UX_Customers_Username' AND object_id=OBJECT_ID('dbo.Customers')) CREATE UNIQUE INDEX UX_Customers_Username ON dbo.Customers(Username) WHERE Username IS NOT NULL;
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='UX_Admins_Username' AND object_id=OBJECT_ID('dbo.Admins')) CREATE UNIQUE INDEX UX_Admins_Username ON dbo.Admins(Username) WHERE Username IS NOT NULL;
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='UX_Restaurants_Username' AND object_id=OBJECT_ID('dbo.Restaurants')) CREATE UNIQUE INDEX UX_Restaurants_Username ON dbo.Restaurants(Username);
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='UX_Riders_Username' AND object_id=OBJECT_ID('dbo.Riders')) CREATE UNIQUE INDEX UX_Riders_Username ON dbo.Riders(Username);
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='UX_RestaurantStaff_StaffCode' AND object_id=OBJECT_ID('dbo.RestaurantStaff')) CREATE UNIQUE INDEX UX_RestaurantStaff_StaffCode ON dbo.RestaurantStaff(StaffCode);
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='UX_Orders_OrderNumber' AND object_id=OBJECT_ID('dbo.Orders')) CREATE UNIQUE INDEX UX_Orders_OrderNumber ON dbo.Orders(OrderNumber);
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='IX_Orders_Customer' AND object_id=OBJECT_ID('dbo.Orders')) CREATE INDEX IX_Orders_Customer ON dbo.Orders(CustomerId,OrderedAt DESC);
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='IX_Orders_Restaurant_Status' AND object_id=OBJECT_ID('dbo.Orders')) CREATE INDEX IX_Orders_Restaurant_Status ON dbo.Orders(RestaurantId,OrderStatus,OrderedAt DESC);
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='IX_Notifications_Recipient' AND object_id=OBJECT_ID('dbo.Notifications')) CREATE INDEX IX_Notifications_Recipient ON dbo.Notifications(RecipientRole,RecipientId,IsRead,CreatedAt DESC);
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='UX_RiderAffiliation_RiderRestaurant' AND object_id=OBJECT_ID('dbo.RiderAffiliations')) CREATE UNIQUE INDEX UX_RiderAffiliation_RiderRestaurant ON dbo.RiderAffiliations(RiderId,RestaurantId);
GO

/* ========================= TVP ============================== */
IF TYPE_ID(N'dbo.OrderItemType') IS NULL
EXEC(N'CREATE TYPE dbo.OrderItemType AS TABLE(FoodItemId INT NOT NULL,Quantity INT NOT NULL,UnitPrice DECIMAL(18,2) NOT NULL);');
GO
IF OBJECT_ID(N'dbo.OrderSequence',N'SO') IS NULL EXEC(N'CREATE SEQUENCE dbo.OrderSequence AS INT START WITH 1 INCREMENT BY 1;');
GO

/* ========================= CUSTOMER ========================== */
CREATE OR ALTER PROCEDURE dbo.sp_Customer_Insert
 @Username NVARCHAR(100),@FullName NVARCHAR(150),@Email NVARCHAR(200),@Phone NVARCHAR(30)=NULL,@PasswordHash NVARCHAR(500),@Address NVARCHAR(500)=NULL
AS BEGIN SET NOCOUNT ON; IF EXISTS(SELECT 1 FROM dbo.Customers WHERE Username=@Username) THROW 50001,'Username already exists.',1; INSERT dbo.Customers(Username,FullName,Email,Phone,PasswordHash,Address) VALUES(@Username,@FullName,@Email,@Phone,@PasswordHash,@Address); SELECT CAST(SCOPE_IDENTITY() AS INT) CustomerId; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Customer_Login @Username NVARCHAR(100),@PasswordHash NVARCHAR(500) AS BEGIN SET NOCOUNT ON; SELECT Id,Username,FullName,Email,Phone,Address FROM dbo.Customers WHERE Username=@Username AND PasswordHash=@PasswordHash AND IsActive=1; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Customer_GetAll AS BEGIN SET NOCOUNT ON; SELECT * FROM dbo.Customers ORDER BY Id DESC; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Customer_GetById @Id INT AS BEGIN SET NOCOUNT ON; SELECT * FROM dbo.Customers WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Customer_Update @Id INT,@FullName NVARCHAR(150),@Email NVARCHAR(200),@Phone NVARCHAR(30)=NULL,@Address NVARCHAR(500)=NULL,@IsActive BIT=1 AS BEGIN UPDATE dbo.Customers SET FullName=@FullName,Email=@Email,Phone=@Phone,Address=@Address,IsActive=@IsActive,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Customer_Delete @Id INT AS BEGIN UPDATE dbo.Customers SET IsActive=0,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO

/* ========================= ADMIN ============================= */
CREATE OR ALTER PROCEDURE dbo.sp_Admin_Insert @Username NVARCHAR(100),@FullName NVARCHAR(150),@Email NVARCHAR(200),@PasswordHash NVARCHAR(500) AS BEGIN SET NOCOUNT ON; INSERT dbo.Admins(Username,FullName,Email,PasswordHash) VALUES(@Username,@FullName,@Email,@PasswordHash); SELECT CAST(SCOPE_IDENTITY() AS INT) AdminId; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Admin_Login @Username NVARCHAR(100),@PasswordHash NVARCHAR(500) AS BEGIN SET NOCOUNT ON; SELECT Id,Username,FullName,Email FROM dbo.Admins WHERE Username=@Username AND PasswordHash=@PasswordHash AND IsActive=1; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Admin_GetAll AS BEGIN SET NOCOUNT ON; SELECT Id,Username,FullName,Email,IsActive,CreatedAt,UpdatedAt FROM dbo.Admins ORDER BY Id DESC; END
GO

/* ========================= RESTAURANT ======================= */
CREATE OR ALTER PROCEDURE dbo.sp_Restaurant_Insert
 @OwnerName NVARCHAR(150),@RestaurantName NVARCHAR(200),@Username NVARCHAR(100),@Email NVARCHAR(200),@Phone NVARCHAR(30)=NULL,@PasswordHash NVARCHAR(500),@CuisineType NVARCHAR(150)=NULL,@Address NVARCHAR(500)=NULL,@City NVARCHAR(100)=NULL,@State NVARCHAR(100)=NULL,@Pincode NVARCHAR(20)=NULL
AS BEGIN SET NOCOUNT ON; IF EXISTS(SELECT 1 FROM dbo.Restaurants WHERE Username=@Username) THROW 50010,'Restaurant username already exists.',1; INSERT dbo.Restaurants(OwnerName,RestaurantName,Username,Email,Phone,PasswordHash,CuisineType,Address,City,State,Pincode) VALUES(@OwnerName,@RestaurantName,@Username,@Email,@Phone,@PasswordHash,@CuisineType,@Address,@City,@State,@Pincode); SELECT CAST(SCOPE_IDENTITY() AS INT) RestaurantId; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Restaurant_Login @Username NVARCHAR(100),@PasswordHash NVARCHAR(500) AS BEGIN SELECT Id,OwnerName,RestaurantName,Username,Email,Phone,CuisineType,Address,City,State,Pincode,Rating,IsVerified FROM dbo.Restaurants WHERE Username=@Username AND PasswordHash=@PasswordHash AND IsActive=1; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Restaurant_GetAll AS BEGIN SELECT * FROM dbo.Restaurants ORDER BY Id DESC; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Restaurant_GetById @Id INT AS BEGIN SELECT * FROM dbo.Restaurants WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Restaurant_Update @Id INT,@OwnerName NVARCHAR(150),@RestaurantName NVARCHAR(200),@Email NVARCHAR(200),@Phone NVARCHAR(30)=NULL,@CuisineType NVARCHAR(150)=NULL,@Address NVARCHAR(500)=NULL,@City NVARCHAR(100)=NULL,@State NVARCHAR(100)=NULL,@Pincode NVARCHAR(20)=NULL,@IsActive BIT=1 AS BEGIN UPDATE dbo.Restaurants SET OwnerName=@OwnerName,RestaurantName=@RestaurantName,Email=@Email,Phone=@Phone,CuisineType=@CuisineType,Address=@Address,City=@City,State=@State,Pincode=@Pincode,IsActive=@IsActive,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Restaurant_Verify @Id INT,@IsVerified BIT AS BEGIN UPDATE dbo.Restaurants SET IsVerified=@IsVerified,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Restaurant_Delete @Id INT AS BEGIN UPDATE dbo.Restaurants SET IsActive=0,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO

/* ========================= RIDER ============================= */
CREATE OR ALTER PROCEDURE dbo.sp_Rider_Insert @FullName NVARCHAR(150),@Username NVARCHAR(100),@Email NVARCHAR(200)=NULL,@Phone NVARCHAR(30),@PasswordHash NVARCHAR(500),@VehicleType NVARCHAR(50),@VehicleNumber NVARCHAR(50)=NULL AS BEGIN SET NOCOUNT ON; INSERT dbo.Riders(FullName,Username,Email,Phone,PasswordHash,VehicleType,VehicleNumber) VALUES(@FullName,@Username,@Email,@Phone,@PasswordHash,@VehicleType,@VehicleNumber); SELECT CAST(SCOPE_IDENTITY() AS INT) RiderId; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Rider_Login @Username NVARCHAR(100),@PasswordHash NVARCHAR(500) AS BEGIN SELECT Id,FullName,Username,Email,Phone,VehicleType,VehicleNumber,IsAvailable,IsVerified FROM dbo.Riders WHERE Username=@Username AND PasswordHash=@PasswordHash AND IsActive=1; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Rider_GetAll AS BEGIN SELECT * FROM dbo.Riders ORDER BY Id DESC; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Rider_GetById @Id INT AS BEGIN SELECT * FROM dbo.Riders WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Rider_Update @Id INT,@FullName NVARCHAR(150),@Email NVARCHAR(200)=NULL,@Phone NVARCHAR(30),@VehicleType NVARCHAR(50),@VehicleNumber NVARCHAR(50)=NULL AS BEGIN UPDATE dbo.Riders SET FullName=@FullName,Email=@Email,Phone=@Phone,VehicleType=@VehicleType,VehicleNumber=@VehicleNumber,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Rider_SetAvailability @Id INT,@IsAvailable BIT AS BEGIN UPDATE dbo.Riders SET IsAvailable=@IsAvailable,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Rider_Verify @Id INT,@IsVerified BIT AS BEGIN UPDATE dbo.Riders SET IsVerified=@IsVerified,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Rider_Delete @Id INT AS BEGIN UPDATE dbo.Riders SET IsActive=0,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO

/* ====================== RESTAURANT STAFF ==================== */
CREATE OR ALTER PROCEDURE dbo.sp_RestaurantStaff_Insert @RestaurantId INT,@FullName NVARCHAR(150),@Username NVARCHAR(100),@Email NVARCHAR(200)=NULL,@Phone NVARCHAR(30)=NULL,@PasswordHash NVARCHAR(500),@Designation NVARCHAR(100) AS BEGIN SET NOCOUNT ON; IF NOT EXISTS(SELECT 1 FROM dbo.Restaurants WHERE Id=@RestaurantId AND IsActive=1) THROW 50030,'Restaurant does not exist.',1; DECLARE @StaffCode NVARCHAR(50)=CONCAT('FR-STAFF-',@RestaurantId,'-',FORMAT(NEXT VALUE FOR dbo.OrderSequence,'000000')); INSERT dbo.RestaurantStaff(RestaurantId,StaffCode,FullName,Username,Email,Phone,PasswordHash,Designation) VALUES(@RestaurantId,@StaffCode,@FullName,@Username,@Email,@Phone,@PasswordHash,@Designation); SELECT CAST(SCOPE_IDENTITY() AS INT) StaffId,@StaffCode StaffCode; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_RestaurantStaff_Login @Username NVARCHAR(100),@PasswordHash NVARCHAR(500) AS BEGIN SELECT s.Id,s.RestaurantId,r.RestaurantName,s.StaffCode,s.FullName,s.Username,s.Email,s.Phone,s.Designation,s.PerformanceRating,s.PreparedOrdersCount FROM dbo.RestaurantStaff s JOIN dbo.Restaurants r ON r.Id=s.RestaurantId WHERE s.Username=@Username AND s.PasswordHash=@PasswordHash AND s.IsApproved=1 AND s.IsActive=1; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_RestaurantStaff_GetAll @RestaurantId INT=NULL AS BEGIN SELECT s.*,r.RestaurantName FROM dbo.RestaurantStaff s JOIN dbo.Restaurants r ON r.Id=s.RestaurantId WHERE @RestaurantId IS NULL OR s.RestaurantId=@RestaurantId ORDER BY s.Id DESC; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_RestaurantStaff_GetById @Id INT AS BEGIN SELECT s.*,r.RestaurantName FROM dbo.RestaurantStaff s JOIN dbo.Restaurants r ON r.Id=s.RestaurantId WHERE s.Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_RestaurantStaff_Update @Id INT,@FullName NVARCHAR(150),@Email NVARCHAR(200)=NULL,@Phone NVARCHAR(30)=NULL,@Designation NVARCHAR(100),@IsActive BIT=1 AS BEGIN UPDATE dbo.RestaurantStaff SET FullName=@FullName,Email=@Email,Phone=@Phone,Designation=@Designation,IsActive=@IsActive,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_RestaurantStaff_Approve @Id INT,@IsApproved BIT AS BEGIN UPDATE dbo.RestaurantStaff SET IsApproved=@IsApproved,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_RestaurantStaff_UpdatePerformance @Id INT,@PerformanceRating DECIMAL(3,2)=NULL,@IncrementPreparedOrders BIT=0 AS BEGIN UPDATE dbo.RestaurantStaff SET PerformanceRating=COALESCE(@PerformanceRating,PerformanceRating),PreparedOrdersCount=PreparedOrdersCount+CASE WHEN @IncrementPreparedOrders=1 THEN 1 ELSE 0 END,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_RestaurantStaff_Delete @Id INT AS BEGIN UPDATE dbo.RestaurantStaff SET IsActive=0,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO

/* ========================= FOOD ITEMS ======================== */
CREATE OR ALTER PROCEDURE dbo.sp_FoodItem_Insert @RestaurantId INT,@SubmittedByStaffId INT=NULL,@Name NVARCHAR(200),@Description NVARCHAR(500)=NULL,@Category NVARCHAR(100),@Price DECIMAL(18,2),@ImageUrl NVARCHAR(500)=NULL,@IsAvailable BIT=1 AS BEGIN SET NOCOUNT ON; INSERT dbo.FoodItems(RestaurantId,SubmittedByStaffId,Name,Description,Category,Price,ImageUrl,IsAvailable,IsVerified) VALUES(@RestaurantId,@SubmittedByStaffId,@Name,@Description,@Category,@Price,@ImageUrl,@IsAvailable,CASE WHEN @SubmittedByStaffId IS NULL THEN 1 ELSE 0 END); SELECT CAST(SCOPE_IDENTITY() AS INT) FoodItemId; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_FoodItem_GetAll @RestaurantId INT=NULL AS BEGIN SELECT f.*,r.RestaurantName,s.FullName SubmittedByStaffName FROM dbo.FoodItems f LEFT JOIN dbo.Restaurants r ON r.Id=f.RestaurantId LEFT JOIN dbo.RestaurantStaff s ON s.Id=f.SubmittedByStaffId WHERE @RestaurantId IS NULL OR f.RestaurantId=@RestaurantId ORDER BY f.Id DESC; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_FoodItem_GetAvailable @RestaurantId INT=NULL AS BEGIN SELECT f.*,r.RestaurantName FROM dbo.FoodItems f LEFT JOIN dbo.Restaurants r ON r.Id=f.RestaurantId WHERE f.IsAvailable=1 AND f.IsVerified=1 AND (@RestaurantId IS NULL OR f.RestaurantId=@RestaurantId) ORDER BY f.Category,f.Name; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_FoodItem_GetById @Id INT AS BEGIN SELECT f.*,r.RestaurantName FROM dbo.FoodItems f LEFT JOIN dbo.Restaurants r ON r.Id=f.RestaurantId WHERE f.Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_FoodItem_Update @Id INT,@Name NVARCHAR(200),@Description NVARCHAR(500)=NULL,@Category NVARCHAR(100),@Price DECIMAL(18,2),@ImageUrl NVARCHAR(500)=NULL,@IsAvailable BIT=1 AS BEGIN UPDATE dbo.FoodItems SET Name=@Name,Description=@Description,Category=@Category,Price=@Price,ImageUrl=@ImageUrl,IsAvailable=@IsAvailable,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_FoodItem_Verify @Id INT,@IsVerified BIT AS BEGIN UPDATE dbo.FoodItems SET IsVerified=@IsVerified,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_FoodItem_Delete @Id INT AS BEGIN UPDATE dbo.FoodItems SET IsAvailable=0,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_FoodItem_Search @SearchText NVARCHAR(200),@RestaurantId INT=NULL AS BEGIN SELECT f.*,r.RestaurantName FROM dbo.FoodItems f LEFT JOIN dbo.Restaurants r ON r.Id=f.RestaurantId WHERE f.IsAvailable=1 AND f.IsVerified=1 AND (@RestaurantId IS NULL OR f.RestaurantId=@RestaurantId) AND(f.Name LIKE '%'+@SearchText+'%' OR f.Category LIKE '%'+@SearchText+'%' OR r.RestaurantName LIKE '%'+@SearchText+'%') ORDER BY f.Name; END
GO

/* ===================== RIDER AFFILIATION ==================== */
CREATE OR ALTER PROCEDURE dbo.sp_RiderAffiliation_Insert @RiderId INT,@RestaurantId INT,@DrivingLicenseNo NVARCHAR(100),@LicenseDocumentUrl NVARCHAR(500)=NULL,@VehicleType NVARCHAR(50),@VehicleNumber NVARCHAR(50)=NULL AS BEGIN SET NOCOUNT ON; INSERT dbo.RiderAffiliations(RiderId,RestaurantId,DrivingLicenseNo,LicenseDocumentUrl,VehicleType,VehicleNumber) VALUES(@RiderId,@RestaurantId,@DrivingLicenseNo,@LicenseDocumentUrl,@VehicleType,@VehicleNumber); SELECT CAST(SCOPE_IDENTITY() AS INT) AffiliationId; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_RiderAffiliation_GetAll @RiderId INT=NULL,@RestaurantId INT=NULL AS BEGIN SELECT ra.*,r.FullName RiderName,r.Phone RiderPhone,rs.RestaurantName FROM dbo.RiderAffiliations ra JOIN dbo.Riders r ON r.Id=ra.RiderId JOIN dbo.Restaurants rs ON rs.Id=ra.RestaurantId WHERE(@RiderId IS NULL OR ra.RiderId=@RiderId) AND(@RestaurantId IS NULL OR ra.RestaurantId=@RestaurantId) ORDER BY ra.Id DESC; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_RiderAffiliation_ApproveByOwner @Id INT,@IsApproved BIT AS BEGIN UPDATE dbo.RiderAffiliations SET IsApprovedByOwner=@IsApproved,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_RiderAffiliation_ApproveByAdmin @Id INT,@IsApproved BIT AS BEGIN UPDATE dbo.RiderAffiliations SET IsApprovedByAdmin=@IsApproved,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_RiderAffiliation_SetActive @Id INT,@IsActive BIT AS BEGIN UPDATE dbo.RiderAffiliations SET IsActive=@IsActive,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_RiderAffiliation_Delete @Id INT AS BEGIN UPDATE dbo.RiderAffiliations SET IsActive=0,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO

/* ========================= ORDERS =========================== */
CREATE OR ALTER PROCEDURE dbo.sp_Order_Create @CustomerId INT,@RestaurantId INT,@DeliveryAddress NVARCHAR(500),@PaymentMethod NVARCHAR(50),@DeliveryFee DECIMAL(18,2),@FoodItemId INT,@Quantity INT AS BEGIN SET NOCOUNT ON; SET XACT_ABORT ON; BEGIN TRAN; DECLARE @Price DECIMAL(18,2),@OrderId INT,@No NVARCHAR(30); SELECT @Price=Price FROM dbo.FoodItems WHERE Id=@FoodItemId AND RestaurantId=@RestaurantId AND IsAvailable=1 AND IsVerified=1; IF @Price IS NULL BEGIN ROLLBACK; THROW 50060,'Food item unavailable.',1; END; SET @No=CONCAT('FR-',CONVERT(char(8),GETDATE(),112),'-',RIGHT('000000'+CAST(NEXT VALUE FOR dbo.OrderSequence AS varchar(20)),6)); INSERT dbo.Orders(OrderNumber,CustomerId,RestaurantId,TotalAmount,DeliveryFee,DeliveryAddress,PaymentMethod,PaymentStatus,OrderStatus,DeliveryStatus) VALUES(@No,@CustomerId,@RestaurantId,(@Price*@Quantity)+@DeliveryFee,@DeliveryFee,@DeliveryAddress,@PaymentMethod,'Pending','Pending','Pending'); SET @OrderId=SCOPE_IDENTITY(); INSERT dbo.OrderDetails(OrderId,FoodItemId,Quantity,UnitPrice) VALUES(@OrderId,@FoodItemId,@Quantity,@Price); COMMIT; SELECT @OrderId OrderId,@No OrderNumber,(@Price*@Quantity)+@DeliveryFee TotalAmount; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Order_CreateMultiple @CustomerId INT,@RestaurantId INT,@DeliveryAddress NVARCHAR(500),@PaymentMethod NVARCHAR(50),@DeliveryFee DECIMAL(18,2),@Items dbo.OrderItemType READONLY AS BEGIN SET NOCOUNT ON; SET XACT_ABORT ON; IF NOT EXISTS(SELECT 1 FROM @Items) THROW 50061,'Order must contain at least one item.',1; BEGIN TRAN; DECLARE @OrderId INT,@No NVARCHAR(30),@FoodTotal DECIMAL(18,2); IF EXISTS(SELECT 1 FROM @Items i LEFT JOIN dbo.FoodItems f ON f.Id=i.FoodItemId AND f.RestaurantId=@RestaurantId AND f.IsAvailable=1 AND f.IsVerified=1 WHERE f.Id IS NULL) BEGIN ROLLBACK; THROW 50062,'One or more food items are unavailable.',1; END; SELECT @FoodTotal=SUM(Quantity*UnitPrice) FROM @Items; SET @No=CONCAT('FR-',CONVERT(char(8),GETDATE(),112),'-',RIGHT('000000'+CAST(NEXT VALUE FOR dbo.OrderSequence AS varchar(20)),6)); INSERT dbo.Orders(OrderNumber,CustomerId,RestaurantId,TotalAmount,DeliveryFee,DeliveryAddress,PaymentMethod,PaymentStatus,OrderStatus,DeliveryStatus) VALUES(@No,@CustomerId,@RestaurantId,@FoodTotal+@DeliveryFee,@DeliveryFee,@DeliveryAddress,@PaymentMethod,'Pending','Pending','Pending'); SET @OrderId=SCOPE_IDENTITY(); INSERT dbo.OrderDetails(OrderId,FoodItemId,Quantity,UnitPrice) SELECT @OrderId,FoodItemId,Quantity,UnitPrice FROM @Items; COMMIT; SELECT @OrderId OrderId,@No OrderNumber,@FoodTotal+@DeliveryFee TotalAmount; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Order_GetByCustomer @CustomerId INT AS BEGIN SELECT o.*,r.RestaurantName FROM dbo.Orders o LEFT JOIN dbo.Restaurants r ON r.Id=o.RestaurantId WHERE o.CustomerId=@CustomerId ORDER BY o.OrderedAt DESC; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Order_GetDetails @OrderId INT AS BEGIN SELECT o.*,c.FullName CustomerName,c.Phone CustomerPhone,r.RestaurantName,rd.FullName RiderName,rd.Phone RiderPhone FROM dbo.Orders o JOIN dbo.Customers c ON c.Id=o.CustomerId LEFT JOIN dbo.Restaurants r ON r.Id=o.RestaurantId LEFT JOIN dbo.Riders rd ON rd.Id=o.RiderId WHERE o.Id=@OrderId; SELECT od.*,f.Name FoodName FROM dbo.OrderDetails od JOIN dbo.FoodItems f ON f.Id=od.FoodItemId WHERE od.OrderId=@OrderId; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Order_GetByRestaurant @RestaurantId INT,@OrderStatus NVARCHAR(50)=NULL AS BEGIN SELECT o.*,c.FullName CustomerName,c.Phone CustomerPhone,rd.FullName RiderName FROM dbo.Orders o JOIN dbo.Customers c ON c.Id=o.CustomerId LEFT JOIN dbo.Riders rd ON rd.Id=o.RiderId WHERE o.RestaurantId=@RestaurantId AND(@OrderStatus IS NULL OR o.OrderStatus=@OrderStatus) ORDER BY o.OrderedAt DESC; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Order_Accept @OrderId INT,@RestaurantId INT=NULL AS BEGIN UPDATE dbo.Orders SET OrderStatus='Accepted',DeliveryStatus='Accepted',AcceptedAt=SYSDATETIME() WHERE Id=@OrderId AND(@RestaurantId IS NULL OR RestaurantId=@RestaurantId) AND OrderStatus='Pending'; SELECT @@ROWCOUNT RowsAffected; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Order_Reject @OrderId INT,@RestaurantId INT=NULL,@RejectionReason NVARCHAR(500)=NULL AS BEGIN UPDATE dbo.Orders SET OrderStatus='Rejected',RejectionReason=@RejectionReason,RejectedAt=SYSDATETIME() WHERE Id=@OrderId AND(@RestaurantId IS NULL OR RestaurantId=@RestaurantId) AND OrderStatus='Pending'; SELECT @@ROWCOUNT RowsAffected; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Order_AssignRider @OrderId INT,@RiderId INT AS BEGIN IF NOT EXISTS(SELECT 1 FROM dbo.Riders WHERE Id=@RiderId AND IsActive=1 AND IsVerified=1 AND IsAvailable=1) THROW 50063,'Rider unavailable or not verified.',1; UPDATE o SET RiderId=@RiderId,DeliveryStatus='ReadyForPickup' FROM dbo.Orders o WHERE o.Id=@OrderId AND EXISTS(SELECT 1 FROM dbo.RiderAffiliations a WHERE a.RiderId=@RiderId AND a.RestaurantId=o.RestaurantId AND a.IsActive=1 AND a.IsApprovedByOwner=1 AND a.IsApprovedByAdmin=1); END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Order_UpdateDeliveryStatus @OrderId INT,@DeliveryStatus NVARCHAR(50),@RiderId INT=NULL AS BEGIN UPDATE dbo.Orders SET DeliveryStatus=@DeliveryStatus,RiderId=COALESCE(@RiderId,RiderId),DeliveredAt=CASE WHEN @DeliveryStatus='Delivered' THEN SYSDATETIME() ELSE DeliveredAt END WHERE Id=@OrderId AND OrderStatus<>'Rejected'; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Order_AutoReject @Minutes INT=5 AS BEGIN UPDATE dbo.Orders SET OrderStatus='Rejected',RejectionReason=CONCAT('Automatically rejected after ',@Minutes,' minutes.'),RejectedAt=SYSDATETIME() WHERE OrderStatus='Pending' AND OrderedAt<=DATEADD(MINUTE,-@Minutes,SYSDATETIME()); SELECT @@ROWCOUNT AutoRejectedOrders; END
GO

/* ======================= NOTIFICATIONS ====================== */
CREATE OR ALTER PROCEDURE dbo.sp_Notification_Create @RecipientRole NVARCHAR(30),@RecipientId INT,@Title NVARCHAR(200),@Message NVARCHAR(1000),@NotificationType NVARCHAR(50)=NULL,@RelatedOrderId INT=NULL AS BEGIN INSERT dbo.Notifications(RecipientRole,RecipientId,Title,Message,NotificationType,RelatedOrderId) VALUES(@RecipientRole,@RecipientId,@Title,@Message,@NotificationType,@RelatedOrderId); SELECT CAST(SCOPE_IDENTITY() AS INT) NotificationId; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Notification_GetByRecipient @RecipientRole NVARCHAR(30),@RecipientId INT,@UnreadOnly BIT=0 AS BEGIN SELECT * FROM dbo.Notifications WHERE RecipientRole=@RecipientRole AND RecipientId=@RecipientId AND(@UnreadOnly=0 OR IsRead=0) ORDER BY CreatedAt DESC; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Notification_MarkRead @Id INT AS BEGIN UPDATE dbo.Notifications SET IsRead=1,ReadAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Notification_MarkAllRead @RecipientRole NVARCHAR(30),@RecipientId INT AS BEGIN UPDATE dbo.Notifications SET IsRead=1,ReadAt=SYSDATETIME() WHERE RecipientRole=@RecipientRole AND RecipientId=@RecipientId AND IsRead=0; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Notification_Delete @Id INT AS BEGIN DELETE dbo.Notifications WHERE Id=@Id; END
GO

/* ======================== TRANSACTIONS ===================== */
CREATE OR ALTER PROCEDURE dbo.sp_Transaction_Create @OrderId INT,@TransactionReference NVARCHAR(100)=NULL,@PaymentGateway NVARCHAR(50)=NULL,@PaymentMethod NVARCHAR(50),@GrossAmount DECIMAL(18,2),@PlatformFee DECIMAL(18,2)=0,@DeliveryFee DECIMAL(18,2)=0,@RestaurantShare DECIMAL(18,2)=0,@RiderShare DECIMAL(18,2)=0,@PaymentStatus NVARCHAR(50)='Pending',@Remarks NVARCHAR(500)=NULL AS BEGIN INSERT dbo.Transactions(OrderId,TransactionReference,PaymentGateway,PaymentMethod,GrossAmount,PlatformFee,DeliveryFee,RestaurantShare,RiderShare,PaymentStatus,Remarks) VALUES(@OrderId,@TransactionReference,@PaymentGateway,@PaymentMethod,@GrossAmount,@PlatformFee,@DeliveryFee,@RestaurantShare,@RiderShare,@PaymentStatus,@Remarks); SELECT CAST(SCOPE_IDENTITY() AS INT) TransactionId; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Transaction_GetByOrder @OrderId INT AS BEGIN SELECT * FROM dbo.Transactions WHERE OrderId=@OrderId ORDER BY TransactionDate DESC; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Transaction_UpdateStatus @Id INT,@PaymentStatus NVARCHAR(50),@TransactionReference NVARCHAR(100)=NULL AS BEGIN UPDATE dbo.Transactions SET PaymentStatus=@PaymentStatus,TransactionReference=COALESCE(@TransactionReference,TransactionReference) WHERE Id=@Id; IF @PaymentStatus='Paid' UPDATE o SET PaymentStatus='Paid' FROM dbo.Orders o JOIN dbo.Transactions t ON t.OrderId=o.Id WHERE t.Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Transaction_GetAll AS BEGIN SELECT t.*,o.OrderNumber,r.RestaurantName,c.FullName CustomerName FROM dbo.Transactions t JOIN dbo.Orders o ON o.Id=t.OrderId LEFT JOIN dbo.Restaurants r ON r.Id=o.RestaurantId JOIN dbo.Customers c ON c.Id=o.CustomerId ORDER BY t.TransactionDate DESC; END
GO

/* ========================== BULLETINS ======================= */
CREATE OR ALTER PROCEDURE dbo.sp_Bulletin_Insert @Title NVARCHAR(250),@Message NVARCHAR(MAX),@TargetRole NVARCHAR(30)='All',@Priority NVARCHAR(30)='Normal',@IsPublished BIT=1,@PublishFrom DATETIME2=NULL,@PublishUntil DATETIME2=NULL,@CreatedByAdminId INT=NULL AS BEGIN INSERT dbo.Bulletins(Title,Message,TargetRole,Priority,IsPublished,PublishFrom,PublishUntil,CreatedByAdminId) VALUES(@Title,@Message,@TargetRole,@Priority,@IsPublished,COALESCE(@PublishFrom,SYSDATETIME()),@PublishUntil,@CreatedByAdminId); SELECT CAST(SCOPE_IDENTITY() AS INT) BulletinId; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Bulletin_GetAll AS BEGIN SELECT b.*,a.FullName CreatedByAdmin FROM dbo.Bulletins b LEFT JOIN dbo.Admins a ON a.Id=b.CreatedByAdminId ORDER BY b.CreatedAt DESC; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Bulletin_GetPublished @TargetRole NVARCHAR(30)='All' AS BEGIN SELECT * FROM dbo.Bulletins WHERE IsPublished=1 AND PublishFrom<=SYSDATETIME() AND(PublishUntil IS NULL OR PublishUntil>=SYSDATETIME()) AND(TargetRole='All' OR TargetRole=@TargetRole) ORDER BY CASE Priority WHEN 'Urgent' THEN 1 WHEN 'High' THEN 2 ELSE 3 END,PublishFrom DESC; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Bulletin_GetById @Id INT AS BEGIN SELECT * FROM dbo.Bulletins WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Bulletin_Update @Id INT,@Title NVARCHAR(250),@Message NVARCHAR(MAX),@TargetRole NVARCHAR(30),@Priority NVARCHAR(30),@IsPublished BIT,@PublishFrom DATETIME2,@PublishUntil DATETIME2=NULL AS BEGIN UPDATE dbo.Bulletins SET Title=@Title,Message=@Message,TargetRole=@TargetRole,Priority=@Priority,IsPublished=@IsPublished,PublishFrom=@PublishFrom,PublishUntil=@PublishUntil,UpdatedAt=SYSDATETIME() WHERE Id=@Id; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Bulletin_Delete @Id INT AS BEGIN DELETE dbo.Bulletins WHERE Id=@Id; END
GO

/* ======================== DASHBOARDS ======================== */
CREATE OR ALTER PROCEDURE dbo.sp_Admin_DashboardSummary AS BEGIN SELECT (SELECT COUNT(*) FROM dbo.Customers WHERE IsActive=1) TotalCustomers,(SELECT COUNT(*) FROM dbo.Restaurants WHERE IsActive=1) TotalRestaurants,(SELECT COUNT(*) FROM dbo.Riders WHERE IsActive=1) TotalRiders,(SELECT COUNT(*) FROM dbo.RestaurantStaff WHERE IsActive=1) TotalStaff,(SELECT COUNT(*) FROM dbo.FoodItems WHERE IsAvailable=1) TotalFoodItems,(SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus='Pending') PendingOrders,(SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus='Accepted') AcceptedOrders,(SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus='Rejected') RejectedOrders,(SELECT COUNT(*) FROM dbo.Orders WHERE DeliveryStatus='Delivered') DeliveredOrders,(SELECT ISNULL(SUM(GrossAmount),0) FROM dbo.Transactions WHERE PaymentStatus='Paid') TotalRevenue; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Restaurant_DashboardSummary @RestaurantId INT AS BEGIN SELECT @RestaurantId RestaurantId,(SELECT COUNT(*) FROM dbo.FoodItems WHERE RestaurantId=@RestaurantId) TotalFoodItems,(SELECT COUNT(*) FROM dbo.RestaurantStaff WHERE RestaurantId=@RestaurantId AND IsActive=1) TotalStaff,(SELECT COUNT(*) FROM dbo.Orders WHERE RestaurantId=@RestaurantId AND OrderStatus='Pending') PendingOrders,(SELECT COUNT(*) FROM dbo.Orders WHERE RestaurantId=@RestaurantId AND OrderStatus='Accepted') AcceptedOrders,(SELECT COUNT(*) FROM dbo.Orders WHERE RestaurantId=@RestaurantId AND DeliveryStatus='Delivered') DeliveredOrders,(SELECT ISNULL(SUM(t.RestaurantShare),0) FROM dbo.Transactions t JOIN dbo.Orders o ON o.Id=t.OrderId WHERE o.RestaurantId=@RestaurantId AND t.PaymentStatus='Paid') RestaurantRevenue; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Rider_DashboardSummary @RiderId INT AS BEGIN SELECT @RiderId RiderId,(SELECT COUNT(*) FROM dbo.Orders WHERE RiderId=@RiderId) TotalAssignedOrders,(SELECT COUNT(*) FROM dbo.Orders WHERE RiderId=@RiderId AND DeliveryStatus='Delivered') DeliveredOrders,(SELECT COUNT(*) FROM dbo.Orders WHERE RiderId=@RiderId AND DeliveryStatus IN('ReadyForPickup','OutForDelivery')) ActiveDeliveries,(SELECT ISNULL(SUM(t.RiderShare),0) FROM dbo.Transactions t JOIN dbo.Orders o ON o.Id=t.OrderId WHERE o.RiderId=@RiderId AND t.PaymentStatus='Paid') RiderEarnings; END
GO

/* ======================== SAMPLE DATA ====================== */
IF NOT EXISTS(SELECT 1 FROM dbo.Admins WHERE Username='admin') INSERT dbo.Admins(Username,FullName,Email,PasswordHash) VALUES('admin','FoodReady Admin','admin@foodready.com','admin123');
GO
IF NOT EXISTS(SELECT 1 FROM dbo.Customers WHERE Username='customer01') INSERT dbo.Customers(Username,FullName,Email,Phone,PasswordHash,Address) VALUES('customer01','Demo Customer','customer@foodready.com','9876543210','12345','Kolkata, West Bengal');
GO
IF NOT EXISTS(SELECT 1 FROM dbo.Restaurants WHERE Username='restaurant01') INSERT dbo.Restaurants(OwnerName,RestaurantName,Username,Email,Phone,PasswordHash,CuisineType,Address,City,State,Pincode,Rating,IsVerified) VALUES('Demo Owner','FoodReady Kitchen','restaurant01','restaurant@foodready.com','9876543211','12345','Indian, Chinese, Fast Food','Kolkata','Kolkata','West Bengal','700001',4.50,1);
GO
IF NOT EXISTS(SELECT 1 FROM dbo.Riders WHERE Username='rider01') INSERT dbo.Riders(FullName,Username,Email,Phone,PasswordHash,VehicleType,VehicleNumber,IsAvailable,IsActive,IsVerified) VALUES('Demo Rider','rider01','rider@foodready.com','9876543212','12345','Bike','WB01AB1234',1,1,1);
GO

/* ======================== VERIFY ============================ */
SELECT 'Customers' TableName,COUNT(*) TotalRows FROM dbo.Customers UNION ALL
SELECT 'Admins',COUNT(*) FROM dbo.Admins UNION ALL
SELECT 'Restaurants',COUNT(*) FROM dbo.Restaurants UNION ALL
SELECT 'Riders',COUNT(*) FROM dbo.Riders UNION ALL
SELECT 'RestaurantStaff',COUNT(*) FROM dbo.RestaurantStaff UNION ALL
SELECT 'FoodItems',COUNT(*) FROM dbo.FoodItems UNION ALL
SELECT 'Orders',COUNT(*) FROM dbo.Orders UNION ALL
SELECT 'OrderDetails',COUNT(*) FROM dbo.OrderDetails UNION ALL
SELECT 'Notifications',COUNT(*) FROM dbo.Notifications UNION ALL
SELECT 'RiderAffiliations',COUNT(*) FROM dbo.RiderAffiliations UNION ALL
SELECT 'Transactions',COUNT(*) FROM dbo.Transactions UNION ALL
SELECT 'Bulletins',COUNT(*) FROM dbo.Bulletins;
GO

/* NOTE: PasswordHash values above are demo placeholders only.
   Generate secure password hashes in the ASP.NET MVC application. */
