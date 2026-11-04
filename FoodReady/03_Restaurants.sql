/*
================================================================================
 DATABASE OBJECT: dbo.Restaurants
 APPLICATION: FoodReady (ASP.NET MVC 5)
 LOCATION: D:\avi\sql\FoodReady\03_Restaurants.sql
 DESCRIPTION:
     Table definition, indexes, default central restaurant seed, and
     ADO.NET inline queries used for Restaurant Owner onboarding, admin verification,
     storefront profiles, and restaurant operations.
================================================================================
*/

USE FoodArrivalDB;
GO

--------------------------------------------------------------------------------
-- 1. TABLE DEFINITION
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Restaurants', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Restaurants
    (
        RestaurantId    INT IDENTITY(1,1) PRIMARY KEY,
        RestaurantName  NVARCHAR(150) NOT NULL,
        OwnerName       NVARCHAR(150) NULL,
        Username        NVARCHAR(100) NULL,
        Email           NVARCHAR(150) NOT NULL,
        PasswordHash    NVARCHAR(255) NOT NULL,
        PhoneNumber     NVARCHAR(20) NULL,
        Address         NVARCHAR(500) NULL,
        Cuisine         NVARCHAR(150) NULL,
        Rating          DECIMAL(2,1) NOT NULL DEFAULT 4.5,
        ImageUrl        NVARCHAR(500) NULL,
        IsVerified      BIT NOT NULL DEFAULT 0,
        VerifiedBy      INT NULL,
        VerifiedAt      DATETIME2 NULL,
        IsActive        BIT NOT NULL DEFAULT 1,
        CreatedAt       DATETIME2 NOT NULL DEFAULT GETDATE(),

        CONSTRAINT UQ_Restaurants_Email UNIQUE (Email)
    );
END
GO

--------------------------------------------------------------------------------
-- 2. INDEXES
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Restaurants_Email' AND object_id = OBJECT_ID('dbo.Restaurants'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Restaurants_Email ON dbo.Restaurants(Email);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Restaurants_Username' AND object_id = OBJECT_ID('dbo.Restaurants'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Restaurants_Username ON dbo.Restaurants(Username) WHERE Username IS NOT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Restaurants_IsActive_IsVerified' AND object_id = OBJECT_ID('dbo.Restaurants'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Restaurants_IsActive_IsVerified ON dbo.Restaurants(IsActive, IsVerified);
END
GO

--------------------------------------------------------------------------------
-- 3. DEFAULT RESTAURANT SEED
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Restaurants WHERE RestaurantId = 1 OR Email = 'restaurant@example.com')
BEGIN
    SET IDENTITY_INSERT dbo.Restaurants ON;

    INSERT INTO dbo.Restaurants 
        (RestaurantId, RestaurantName, OwnerName, Username, Email, PasswordHash, PhoneNumber, Address, Cuisine, Rating, ImageUrl, IsVerified, IsActive)
    VALUES 
        (1, 'FoodReady Central Kitchen', 'Head Chef Marco', 'central_kitchen', 'restaurant@example.com', 'rest123', '9876500001', '124 Food Street, Downtown', 'Multi-Cuisine, Italian, Burgers', 4.8, 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&q=80', 1, 1);

    SET IDENTITY_INSERT dbo.Restaurants OFF;
END
GO

--------------------------------------------------------------------------------
-- 4. INLINE ADO.NET SQL QUERIES (Used directly in C# RestaurantRepository.cs)
--------------------------------------------------------------------------------

/*
--- QUERY A: Duplicate Check Across All Platform Roles ---
SELECT 1 FROM dbo.Restaurants WHERE LOWER(Email) = @Email OR LOWER(Username) = @Username
UNION ALL
SELECT 1 FROM dbo.Customers WHERE LOWER(Email) = @Email OR LOWER(Username) = @Username
UNION ALL
SELECT 1 FROM dbo.Riders WHERE LOWER(Email) = @Email OR LOWER(Username) = @Username
UNION ALL
SELECT 1 FROM dbo.RestaurantStaff WHERE LOWER(Email) = @Email OR LOWER(Username) = @Username
UNION ALL
SELECT 1 FROM dbo.Admins WHERE LOWER(Username) = @Username;

--- QUERY B: Register New Restaurant (Awaiting Admin Verification) ---
INSERT INTO dbo.Restaurants 
    (RestaurantName, OwnerName, Username, Email, PasswordHash, PhoneNumber, Address, Cuisine, Rating, ImageUrl, IsVerified, IsActive)
VALUES 
    (@Name, @OwnerName, @Username, @Email, @Password, @Phone, @Address, @Cuisine, 4.5, @ImageUrl, 0, 1);
SELECT CAST(SCOPE_IDENTITY() AS INT);

--- QUERY C: Restaurant Login by Username OR Email ---
SELECT RestaurantId, RestaurantName, OwnerName, Username, Email, PasswordHash, PhoneNumber, Address, Cuisine, Rating, ImageUrl, IsVerified, IsActive
FROM dbo.Restaurants
WHERE (LOWER(Email) = @LoginId OR LOWER(Username) = @LoginId)
  AND IsActive = 1;

--- QUERY D: Get Restaurant By ID ---
SELECT RestaurantId, RestaurantName, OwnerName, Username, Email, PhoneNumber, Address, Cuisine, Rating, ImageUrl, IsVerified, IsActive, CreatedAt
FROM dbo.Restaurants
WHERE RestaurantId = @RestaurantId;

--- QUERY E: Get All Active & Verified Restaurants (For Public Customer Browse) ---
SELECT RestaurantId, RestaurantName, OwnerName, Username, Email, PhoneNumber, Address, Cuisine, Rating, ImageUrl, IsVerified, IsActive, CreatedAt
FROM dbo.Restaurants
WHERE IsActive = 1 AND IsVerified = 1
ORDER BY Rating DESC, RestaurantName ASC;

--- QUERY F: Get Pending Restaurants (For Admin Approval Screen) ---
SELECT RestaurantId, RestaurantName, OwnerName, Username, Email, PhoneNumber, Address, Cuisine, Rating, ImageUrl, IsVerified, IsActive, CreatedAt
FROM dbo.Restaurants
WHERE IsVerified = 0 AND IsActive = 1
ORDER BY RestaurantId DESC;

--- QUERY G: Admin Verify / Approve Restaurant ---
UPDATE dbo.Restaurants
SET IsVerified = 1,
    VerifiedBy = @AdminId,
    VerifiedAt = GETDATE()
WHERE RestaurantId = @RestaurantId;

--- QUERY H: Update Restaurant Profile & Cuisine ---
UPDATE dbo.Restaurants
SET RestaurantName = @Name,
    OwnerName = @OwnerName,
    PhoneNumber = @Phone,
    Address = @Address,
    Cuisine = @Cuisine,
    ImageUrl = @ImageUrl
WHERE RestaurantId = @RestaurantId;

--- QUERY I: Soft Delete / Deactivate Restaurant ---
UPDATE dbo.Restaurants 
SET IsActive = 0 
WHERE RestaurantId = @RestaurantId;

--- QUERY J: Change Password ---
UPDATE dbo.Restaurants 
SET PasswordHash = @Password 
WHERE RestaurantId = @RestaurantId;
*/
GO
