/*
================================================================================
 DATABASE OBJECT: dbo.FoodItems
 APPLICATION: FoodReady (ASP.NET MVC 5)
 LOCATION: D:\avi\sql\FoodReady\06_FoodItems.sql
 DESCRIPTION:
     Table definition, indexes, category filters, food catalog seed data,
     stored procedures, and inline queries for menu management and staff dish approvals.
================================================================================
*/

USE FoodArrivalDB;
GO

--------------------------------------------------------------------------------
-- 1. TABLE DEFINITION
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.FoodItems', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FoodItems
    (
        FoodItemId          INT IDENTITY(1,1) PRIMARY KEY,
        RestaurantId        INT NULL,
        SubmittedByStaffId  INT NULL,
        ItemName            NVARCHAR(150) NOT NULL,
        Description         NVARCHAR(500) NULL,
        Price               DECIMAL(10,2) NOT NULL,
        ImageUrl            NVARCHAR(500) NULL,
        Category            NVARCHAR(100) NOT NULL DEFAULT 'Snacks',
        IsAvailable         BIT NOT NULL DEFAULT 1,
        IsVerified          BIT NOT NULL DEFAULT 1,
        CreatedAt           DATETIME2 NOT NULL DEFAULT GETDATE(),
        UpdatedAt           DATETIME2 NULL,

        CONSTRAINT CK_FoodItems_Price CHECK (Price >= 0),
        CONSTRAINT FK_FoodItems_Restaurants FOREIGN KEY (RestaurantId) REFERENCES dbo.Restaurants(RestaurantId),
        CONSTRAINT FK_FoodItems_Staff FOREIGN KEY (SubmittedByStaffId) REFERENCES dbo.RestaurantStaff(StaffId)
    );
END
GO

--------------------------------------------------------------------------------
-- 2. INDEXES
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FoodItems_Category' AND object_id = OBJECT_ID('dbo.FoodItems'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_FoodItems_Category ON dbo.FoodItems(Category);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FoodItems_IsAvailable' AND object_id = OBJECT_ID('dbo.FoodItems'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_FoodItems_IsAvailable ON dbo.FoodItems(IsAvailable) WHERE IsAvailable = 1;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FoodItems_RestaurantId' AND object_id = OBJECT_ID('dbo.FoodItems'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_FoodItems_RestaurantId ON dbo.FoodItems(RestaurantId);
END
GO

--------------------------------------------------------------------------------
-- 3. STORED PROCEDURES
--------------------------------------------------------------------------------

-- SP 1: Insert Food Item
IF OBJECT_ID('dbo.sp_FoodItem_Insert', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_FoodItem_Insert;
GO

CREATE PROCEDURE dbo.sp_FoodItem_Insert
(
    @ItemName    NVARCHAR(150),
    @Description NVARCHAR(500),
    @Price       DECIMAL(10,2),
    @ImageUrl    NVARCHAR(500),
    @IsAvailable BIT,
    @Category    NVARCHAR(100) = 'Snacks'
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @Price < 0
    BEGIN
        SELECT 0 AS Result, 'Price cannot be negative.' AS Message, NULL AS FoodItemId;
        RETURN;
    END;

    INSERT INTO dbo.FoodItems (RestaurantId, ItemName, Description, Price, ImageUrl, IsAvailable, Category, IsVerified)
    VALUES (1, @ItemName, @Description, @Price, @ImageUrl, @IsAvailable, ISNULL(@Category, 'Snacks'), 1);

    SELECT 1 AS Result, 'Food item inserted successfully.' AS Message, CAST(SCOPE_IDENTITY() AS INT) AS FoodItemId;
END;
GO

-- SP 2: Get All Food Items
IF OBJECT_ID('dbo.sp_FoodItem_GetAll', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_FoodItem_GetAll;
GO

CREATE PROCEDURE dbo.sp_FoodItem_GetAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT FoodItemId, RestaurantId, ItemName, Description, Price, ImageUrl, Category, IsAvailable, IsVerified, CreatedAt, UpdatedAt
    FROM dbo.FoodItems
    ORDER BY FoodItemId DESC;
END;
GO

-- SP 3: Get Available Food Items (For Public Customer Catalog)
IF OBJECT_ID('dbo.sp_FoodItem_GetAvailable', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_FoodItem_GetAvailable;
GO

CREATE PROCEDURE dbo.sp_FoodItem_GetAvailable
AS
BEGIN
    SET NOCOUNT ON;

    SELECT FoodItemId, RestaurantId, ItemName, Description, Price, ImageUrl, Category, IsAvailable
    FROM dbo.FoodItems
    WHERE IsAvailable = 1 AND IsVerified = 1
    ORDER BY ItemName;
END;
GO

-- SP 4: Get Food Item By ID
IF OBJECT_ID('dbo.sp_FoodItem_GetById', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_FoodItem_GetById;
GO

CREATE PROCEDURE dbo.sp_FoodItem_GetById
(
    @FoodItemId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT FoodItemId, RestaurantId, ItemName, Description, Price, ImageUrl, Category, IsAvailable, IsVerified, CreatedAt, UpdatedAt
    FROM dbo.FoodItems
    WHERE FoodItemId = @FoodItemId;
END;
GO

-- SP 5: Update Food Item
IF OBJECT_ID('dbo.sp_FoodItem_Update', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_FoodItem_Update;
GO

CREATE PROCEDURE dbo.sp_FoodItem_Update
(
    @FoodItemId  INT,
    @ItemName    NVARCHAR(150),
    @Description NVARCHAR(500),
    @Price       DECIMAL(10,2),
    @ImageUrl    NVARCHAR(500),
    @IsAvailable BIT,
    @Category    NVARCHAR(100) = 'Snacks'
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @Price < 0
    BEGIN
        SELECT 0 AS Result, 'Price cannot be negative.' AS Message;
        RETURN;
    END;

    UPDATE dbo.FoodItems
    SET ItemName    = @ItemName,
        Description = @Description,
        Price       = @Price,
        ImageUrl    = @ImageUrl,
        IsAvailable = @IsAvailable,
        Category    = ISNULL(@Category, 'Snacks'),
        UpdatedAt   = GETDATE()
    WHERE FoodItemId = @FoodItemId;

    IF @@ROWCOUNT = 0
    BEGIN
        SELECT 0 AS Result, 'Food item not found.' AS Message;
        RETURN;
    END;

    SELECT 1 AS Result, 'Food item updated successfully.' AS Message;
END;
GO

-- SP 6: Soft Delete / Deactivate Food Item
IF OBJECT_ID('dbo.sp_FoodItem_Delete', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_FoodItem_Delete;
GO

CREATE PROCEDURE dbo.sp_FoodItem_Delete
(
    @FoodItemId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.FoodItems 
    SET IsAvailable = 0, 
        UpdatedAt   = GETDATE() 
    WHERE FoodItemId = @FoodItemId;

    IF @@ROWCOUNT = 0
    BEGIN
        SELECT 0 AS Result, 'Food item not found.' AS Message;
        RETURN;
    END;

    SELECT 1 AS Result, 'Food item removed successfully.' AS Message;
END;
GO

-- SP 7: Search Food Items
IF OBJECT_ID('dbo.sp_FoodItem_Search', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_FoodItem_Search;
GO

CREATE PROCEDURE dbo.sp_FoodItem_Search
(
    @Search NVARCHAR(150)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT FoodItemId, RestaurantId, ItemName, Description, Price, ImageUrl, Category, IsAvailable
    FROM dbo.FoodItems
    WHERE IsAvailable = 1 AND IsVerified = 1
      AND (ItemName LIKE '%' + @Search + '%' OR Description LIKE '%' + @Search + '%' OR Category LIKE '%' + @Search + '%')
    ORDER BY ItemName;
END;
GO

--------------------------------------------------------------------------------
-- 4. INLINE ADO.NET SQL QUERIES (Used in StaffRepository.cs & FoodItemRepository.cs)
--------------------------------------------------------------------------------

/*
--- QUERY A: Staff Submit New Dish (Requires Restaurant Owner Approval) ---
INSERT INTO dbo.FoodItems (RestaurantId, SubmittedByStaffId, ItemName, Description, Price, ImageUrl, Category, IsAvailable, IsVerified)
VALUES (@RestaurantId, @StaffId, @ItemName, @Description, @Price, @ImageUrl, @Category, 1, 0);
SELECT CAST(SCOPE_IDENTITY() AS INT);

--- QUERY B: Get Menu Items Submitted by Specific Staff Member ---
SELECT f.FoodItemId, f.RestaurantId, f.ItemName, f.Description, f.Price, f.ImageUrl, f.Category, f.IsAvailable, f.IsVerified, f.CreatedAt
FROM dbo.FoodItems f
WHERE f.SubmittedByStaffId = @StaffId
ORDER BY f.FoodItemId DESC;

--- QUERY C: Restaurant Owner / Admin Approve Dish ---
UPDATE dbo.FoodItems
SET IsVerified = 1,
    UpdatedAt = GETDATE()
WHERE FoodItemId = @FoodItemId;

--- QUERY D: Get Verified Menu for a Specific Restaurant ---
SELECT f.FoodItemId, f.RestaurantId, r.RestaurantName, f.ItemName, f.Description, f.Price, f.ImageUrl, f.Category, f.IsAvailable
FROM dbo.FoodItems f
INNER JOIN dbo.Restaurants r ON f.RestaurantId = r.RestaurantId
WHERE f.RestaurantId = @RestaurantId AND f.IsAvailable = 1 AND f.IsVerified = 1
ORDER BY f.Category, f.ItemName;
*/
GO
