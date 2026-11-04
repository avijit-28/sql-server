/*
================================================================================
 DATABASE OBJECT: dbo.RestaurantStaff
 APPLICATION: FoodReady (ASP.NET MVC 5)
 LOCATION: D:\avi\sql\FoodReady\05_RestaurantStaff.sql
 DESCRIPTION:
     Table definition, indexes, foreign keys, and ADO.NET inline queries
     used for Kitchen Staff / Chef onboarding, unique StaffCode generation,
     Performance Management System (PMS), and dual-approval workflow.
================================================================================
*/

USE FoodArrivalDB;
GO

--------------------------------------------------------------------------------
-- 1. TABLE DEFINITION
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.RestaurantStaff', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RestaurantStaff
    (
        StaffId             INT IDENTITY(1,1) PRIMARY KEY,
        StaffCode           NVARCHAR(50) NOT NULL, -- e.g., STF-REST1-001
        StaffName           NVARCHAR(150) NOT NULL,
        Username            NVARCHAR(100) NOT NULL,
        Email               NVARCHAR(150) NOT NULL,
        PasswordHash        NVARCHAR(255) NOT NULL,
        PhoneNumber         NVARCHAR(20) NOT NULL,
        RestaurantId        INT NOT NULL,
        RoleTitle           NVARCHAR(100) NOT NULL DEFAULT 'Kitchen Staff', -- Head Chef, Sous Chef, Kitchen Staff
        IsVerified          BIT NOT NULL DEFAULT 0,
        VerifiedByRole      NVARCHAR(50) NULL, -- 'RestaurantOwner' or 'Admin'
        VerifiedBy          INT NULL,
        VerifiedAt          DATETIME2 NULL,
        IsActive            BIT NOT NULL DEFAULT 1,
        OrdersPrepared      INT NOT NULL DEFAULT 0,
        PerformanceRating   DECIMAL(2,1) NOT NULL DEFAULT 4.8,
        CreatedAt           DATETIME2 NOT NULL DEFAULT GETDATE(),

        CONSTRAINT UQ_RestaurantStaff_Email UNIQUE (Email),
        CONSTRAINT UQ_RestaurantStaff_StaffCode UNIQUE (StaffCode),
        CONSTRAINT FK_RestaurantStaff_Restaurants FOREIGN KEY (RestaurantId) REFERENCES dbo.Restaurants(RestaurantId)
    );
END
GO

--------------------------------------------------------------------------------
-- 2. INDEXES
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_RestaurantStaff_RestaurantId' AND object_id = OBJECT_ID('dbo.RestaurantStaff'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_RestaurantStaff_RestaurantId ON dbo.RestaurantStaff(RestaurantId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_RestaurantStaff_Email' AND object_id = OBJECT_ID('dbo.RestaurantStaff'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_RestaurantStaff_Email ON dbo.RestaurantStaff(Email);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_RestaurantStaff_Username' AND object_id = OBJECT_ID('dbo.RestaurantStaff'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_RestaurantStaff_Username ON dbo.RestaurantStaff(Username);
END
GO

--------------------------------------------------------------------------------
-- 3. DEFAULT STAFF SEED
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.RestaurantStaff WHERE StaffId = 1 OR Email = 'chef.vikram@example.com')
BEGIN
    INSERT INTO dbo.RestaurantStaff 
        (StaffCode, StaffName, Username, Email, PasswordHash, PhoneNumber, RestaurantId, RoleTitle, IsVerified, VerifiedByRole, VerifiedBy, VerifiedAt, IsActive, OrdersPrepared, PerformanceRating)
    VALUES 
        ('STF-REST1-001', 'Chef Vikram Joshi', 'chef_vikram', 'chef.vikram@example.com', 'chef123', '9876511111', 1, 'Executive Chef', 1, 'Admin', 1, GETDATE(), 1, 142, 4.9);
END
GO

--------------------------------------------------------------------------------
-- 4. INLINE ADO.NET SQL QUERIES (Used directly in C# StaffRepository.cs)
--------------------------------------------------------------------------------

/*
--- QUERY A: Duplicate Check Across All System Entities ---
SELECT 1 FROM dbo.RestaurantStaff WHERE Email = @Email OR Username = @Username
UNION ALL
SELECT 1 FROM dbo.Customers WHERE Email = @Email OR Username = @Username
UNION ALL
SELECT 1 FROM dbo.Restaurants WHERE Email = @Email OR Username = @Username
UNION ALL
SELECT 1 FROM dbo.Riders WHERE Email = @Email OR Username = @Username;

--- QUERY B: Count Staff for Automatic Staff Code Generation ---
SELECT COUNT(*) FROM dbo.RestaurantStaff WHERE RestaurantId = @RestId;

--- QUERY C: Register Staff (Awaiting Restaurant Owner or Admin Verification) ---
INSERT INTO dbo.RestaurantStaff 
    (StaffCode, StaffName, Username, Email, PasswordHash, PhoneNumber, RestaurantId, RoleTitle, IsVerified, IsActive, OrdersPrepared, PerformanceRating)
VALUES 
    (@StaffCode, @StaffName, @Username, @Email, @Password, @PhoneNumber, @RestaurantId, @RoleTitle, 0, 1, 0, 4.8);
SELECT CAST(SCOPE_IDENTITY() AS INT);

--- QUERY D: Staff Login by Username OR Email ---
SELECT s.StaffId, s.StaffCode, s.StaffName, s.Username, s.Email, s.PasswordHash, s.PhoneNumber,
       s.RestaurantId, r.RestaurantName, s.RoleTitle, s.IsVerified, s.IsActive, s.OrdersPrepared, s.PerformanceRating
FROM dbo.RestaurantStaff s
INNER JOIN dbo.Restaurants r ON s.RestaurantId = r.RestaurantId
WHERE (LOWER(s.Email) = @LoginId OR LOWER(s.Username) = @LoginId)
  AND s.IsActive = 1;

--- QUERY E: Get Staff By ID ---
SELECT s.StaffId, s.StaffCode, s.StaffName, s.Username, s.Email, s.PhoneNumber,
       s.RestaurantId, r.RestaurantName, s.RoleTitle, s.IsVerified, s.VerifiedByRole, s.IsActive, s.OrdersPrepared, s.PerformanceRating, s.CreatedAt
FROM dbo.RestaurantStaff s
INNER JOIN dbo.Restaurants r ON s.RestaurantId = r.RestaurantId
WHERE s.StaffId = @StaffId;

--- QUERY F: Get Staff List for Restaurant Dashboard ---
SELECT s.StaffId, s.StaffCode, s.StaffName, s.Username, s.Email, s.PhoneNumber,
       s.RestaurantId, r.RestaurantName, s.RoleTitle, s.IsVerified, s.VerifiedByRole, s.IsActive, s.OrdersPrepared, s.PerformanceRating, s.CreatedAt
FROM dbo.RestaurantStaff s
INNER JOIN dbo.Restaurants r ON s.RestaurantId = r.RestaurantId
WHERE s.RestaurantId = @RestaurantId AND s.IsActive = 1
ORDER BY s.StaffId DESC;

--- QUERY G: Get All Pending Staff Awaiting Verification ---
SELECT s.StaffId, s.StaffCode, s.StaffName, s.Username, s.Email, s.PhoneNumber,
       s.RestaurantId, r.RestaurantName, s.RoleTitle, s.IsVerified, s.CreatedAt
FROM dbo.RestaurantStaff s
INNER JOIN dbo.Restaurants r ON s.RestaurantId = r.RestaurantId
WHERE s.IsVerified = 0 AND s.IsActive = 1
ORDER BY s.StaffId DESC;

--- QUERY H: Approve / Verify Staff (By Owner or Admin) ---
UPDATE dbo.RestaurantStaff 
SET IsVerified = 1,
    VerifiedByRole = @ApproverRole,
    VerifiedBy = @ApproverId,
    VerifiedAt = GETDATE()
WHERE StaffId = @StaffId;

--- QUERY I: Update Staff Performance Metrics (PMS) on Order Preparation ---
UPDATE dbo.RestaurantStaff
SET OrdersPrepared = OrdersPrepared + 1
WHERE StaffId = @StaffId;

--- QUERY J: Soft Delete Staff ---
UPDATE dbo.RestaurantStaff 
SET IsActive = 0 
WHERE StaffId = @StaffId;

--- QUERY K: Change Staff Password ---
UPDATE dbo.RestaurantStaff 
SET PasswordHash = @Password 
WHERE StaffId = @StaffId;
*/
GO
