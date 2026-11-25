/* =================================================================
                    Author : Avijit Pakhira
                    Date Created : 25 Nov, 2026
                    Description : Assignment 2
=================================================================== */

--CREATE DATABASE MeterReconciliationDB;
--GO

USE MeterReconciliationDB;
GO

-- 1. Consumers
CREATE TABLE Consumers
(
    ConsumerId INT IDENTITY(1,1) PRIMARY KEY,
    ConsumerCode VARCHAR(30) NOT NULL UNIQUE,
    ConsumerName NVARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(15) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

-- 2. Meters
CREATE TABLE Meters
(
    MeterId INT IDENTITY(1,1) PRIMARY KEY,
    MeterSerialNumber VARCHAR(50) NOT NULL UNIQUE,
    ConsumerId INT NOT NULL,
    FeederId VARCHAR(30) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Meters_Consumers
        FOREIGN KEY (ConsumerId)
        REFERENCES Consumers(ConsumerId)
);
GO

-- 3. Meter Readings
CREATE TABLE MeterReadings
(
    ReadingId BIGINT IDENTITY(1,1) PRIMARY KEY,
    MeterId INT NOT NULL,
    ExternalReadingId VARCHAR(100) NULL,
    BatchId VARCHAR(100) NOT NULL,
    ReadingDate DATETIME2 NOT NULL,
    CumulativeKWh DECIMAL(18,3) NOT NULL,
    PreviousCumulativeKWh DECIMAL(18,3) NULL,
    ConsumptionKWh DECIMAL(18,3) NULL,
    ReadingStatus VARCHAR(20) NOT NULL DEFAULT 'Pending',
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_MeterReadings_Meters
        FOREIGN KEY (MeterId)
        REFERENCES Meters(MeterId),

    CONSTRAINT CK_MeterReadings_CumulativeKWh
        CHECK (CumulativeKWh >= 0),

    CONSTRAINT CK_MeterReadings_ConsumptionKWh
        CHECK (ConsumptionKWh IS NULL OR ConsumptionKWh >= 0)
);
GO

-- Prevent duplicate readings for the same meter and timestamp
CREATE UNIQUE INDEX UX_MeterReadings_MeterDate
ON MeterReadings(MeterId, ReadingDate);
GO

-- Prevent duplicate external reading IDs when supplied
CREATE UNIQUE INDEX UX_MeterReadings_ExternalReadingId
ON MeterReadings(ExternalReadingId)
WHERE ExternalReadingId IS NOT NULL;
GO

-- 4. Tariff Slabs
CREATE TABLE TariffSlabs
(
    TariffId INT IDENTITY(1,1) PRIMARY KEY,
    FeederId VARCHAR(30) NOT NULL,
    SlabName VARCHAR(50) NOT NULL,
    MinUnits DECIMAL(18,3) NOT NULL,
    MaxUnits DECIMAL(18,3) NULL,
    RatePerUnit DECIMAL(10,2) NOT NULL,
    EffectiveFrom DATE NOT NULL,
    EffectiveTo DATE NULL,
    IsActive BIT NOT NULL DEFAULT 1,

    CONSTRAINT CK_TariffSlabs_MinUnits
        CHECK (MinUnits >= 0),

    CONSTRAINT CK_TariffSlabs_Rate
        CHECK (RatePerUnit >= 0),

    CONSTRAINT CK_TariffSlabs_MaxUnits
        CHECK (MaxUnits IS NULL OR MaxUnits > MinUnits)
);
GO

-- 5. Reconciliation Audit Log
CREATE TABLE ReconciliationAuditLog
(
    AuditId BIGINT IDENTITY(1,1) PRIMARY KEY,
    RunId UNIQUEIDENTIFIER NOT NULL,
    BatchId VARCHAR(100) NULL,
    MeterSerialNumber VARCHAR(50) NULL,
    AuditType VARCHAR(30) NOT NULL,
    Message NVARCHAR(1000) NOT NULL,
    IsSuccess BIT NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

-- Indexes for common queries
CREATE INDEX IX_Meters_FeederId
ON Meters(FeederId);

CREATE INDEX IX_MeterReadings_ReadingDate
ON MeterReadings(ReadingDate);

CREATE INDEX IX_AuditLog_RunId
ON ReconciliationAuditLog(RunId);
GO
