/*
================================================================================
 DATABASE OBJECT: dbo.RiderRestaurantAffiliations
 APPLICATION: FoodReady (ASP.NET MVC 5)
 LOCATION: D:\avi\sql\FoodReady\10_RiderRestaurantAffiliations.sql
 DESCRIPTION:
     Table definition, foreign keys, indexes, and ADO.NET inline queries
     for multi-restaurant delivery partner affiliations, driving license verification,
     and restaurant fleet management.
================================================================================
*/

USE FoodArrivalDB;
GO

--------------------------------------------------------------------------------
-- 1. TABLE DEFINITION
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.RiderRestaurantAffiliations', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RiderRestaurantAffiliations
    (
        AffiliationId       INT IDENTITY(1,1) PRIMARY KEY,
        RiderId             INT NOT NULL,
        RestaurantId        INT NOT NULL,
        VehicleType         NVARCHAR(100) NULL,
        LicenseNumber       NVARCHAR(100) NULL,
        LicenseDocumentUrl  NVARCHAR(500) NULL,
        IsVerified          BIT NOT NULL DEFAULT 0,
        VerifiedByRole      NVARCHAR(50) NULL, -- 'RestaurantOwner' or 'Admin'
        VerifiedBy          INT NULL,
        VerifiedAt          DATETIME2 NULL,
        AffiliatedAt        DATETIME2 NOT NULL DEFAULT GETDATE(),

        CONSTRAINT FK_RiderAffiliations_Riders FOREIGN KEY (RiderId) REFERENCES dbo.Riders(RiderId),
        CONSTRAINT FK_RiderAffiliations_Restaurants FOREIGN KEY (RestaurantId) REFERENCES dbo.Restaurants(RestaurantId),
        CONSTRAINT UQ_Rider_Restaurant UNIQUE (RiderId, RestaurantId)
    );
END
GO

--------------------------------------------------------------------------------
-- 2. INDEXES
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_RiderAffiliations_RiderId' AND object_id = OBJECT_ID('dbo.RiderRestaurantAffiliations'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_RiderAffiliations_RiderId ON dbo.RiderRestaurantAffiliations(RiderId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_RiderAffiliations_RestaurantId' AND object_id = OBJECT_ID('dbo.RiderRestaurantAffiliations'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_RiderAffiliations_RestaurantId ON dbo.RiderRestaurantAffiliations(RestaurantId);
END
GO

--------------------------------------------------------------------------------
-- 3. DEFAULT SEED
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.RiderRestaurantAffiliations WHERE RiderId = 1 AND RestaurantId = 1)
BEGIN
    INSERT INTO dbo.RiderRestaurantAffiliations 
        (RiderId, RestaurantId, VehicleType, LicenseNumber, LicenseDocumentUrl, IsVerified, VerifiedByRole, VerifiedBy, VerifiedAt, AffiliatedAt)
    VALUES 
        (1, 1, 'Hero Splendor Plus', 'DL-09-2022-887712', '/Content/images/rider-avatar.png', 1, 'Admin', 1, GETDATE(), GETDATE());
END
GO

--------------------------------------------------------------------------------
-- 4. INLINE ADO.NET SQL QUERIES (Used directly in C# RiderRepository.cs)
--------------------------------------------------------------------------------

/*
--- QUERY A: Check Existing Affiliation Between Rider & Restaurant ---
SELECT 1 
FROM dbo.RiderRestaurantAffiliations 
WHERE RiderId = @RiderId AND RestaurantId = @RestaurantId;

--- QUERY B: Register / Apply Rider to Restaurant Fleet ---
INSERT INTO dbo.RiderRestaurantAffiliations (RiderId, RestaurantId, VehicleType, LicenseNumber, LicenseDocumentUrl, IsVerified, AffiliatedAt)
VALUES (@RiderId, @RestaurantId, @VehicleType, @LicenseNumber, @LicenseUrl, 0, GETDATE());
SELECT CAST(SCOPE_IDENTITY() AS INT);

--- QUERY C: Get All Affiliated Restaurants for a Rider ---
SELECT a.AffiliationId, a.RiderId, rd.RiderName, rd.Username, rd.Email, rd.PhoneNumber,
       rd.VehicleType, rd.LicenseNumber, rd.LicenseDocumentUrl,
       a.RestaurantId, r.RestaurantName, a.IsVerified, a.VerifiedByRole, a.VerifiedBy, a.VerifiedAt, a.AffiliatedAt
FROM dbo.RiderRestaurantAffiliations a
INNER JOIN dbo.Riders rd ON a.RiderId = rd.RiderId
INNER JOIN dbo.Restaurants r ON a.RestaurantId = r.RestaurantId
WHERE a.RiderId = @RiderId
ORDER BY a.AffiliationId DESC;

--- QUERY D: Get All Affiliated Riders for a Restaurant Fleet ---
SELECT a.AffiliationId, a.RiderId, rd.RiderName, rd.Username, rd.Email, rd.PhoneNumber,
       rd.VehicleType, rd.LicenseNumber, rd.LicenseDocumentUrl,
       a.RestaurantId, r.RestaurantName, a.IsVerified, a.VerifiedByRole, a.VerifiedBy, a.VerifiedAt, a.AffiliatedAt
FROM dbo.RiderRestaurantAffiliations a
INNER JOIN dbo.Riders rd ON a.RiderId = rd.RiderId
INNER JOIN dbo.Restaurants r ON a.RestaurantId = r.RestaurantId
WHERE a.RestaurantId = @RestaurantId
ORDER BY a.AffiliationId DESC;

--- QUERY E: Owner or Admin Verify Rider Affiliation & License ---
UPDATE dbo.RiderRestaurantAffiliations
SET IsVerified = 1,
    VerifiedByRole = @ApproverRole,
    VerifiedBy = @ApproverId,
    VerifiedAt = GETDATE()
WHERE AffiliationId = @AffiliationId;

--- QUERY F: Remove Rider Affiliation ---
DELETE FROM dbo.RiderRestaurantAffiliations 
WHERE AffiliationId = @AffiliationId;
*/
GO
