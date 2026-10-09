--CREATE DATABASE FleetManagementDB;

--use FleetManagementDB

create schema fm

CREATE TABLE fm.Vehicles
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    VIN VARCHAR(17) NOT NULL UNIQUE,
    Model NVARCHAR(100) NOT NULL,
    Odometer DECIMAL(12,2) NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE()
);

INSERT INTO fm.Vehicles
(VIN, Model, Odometer, IsActive)
VALUES
('1HGBH41JXMN109186', 'Tata Prima', 15000, 1);

select * from fm.Vehicles

