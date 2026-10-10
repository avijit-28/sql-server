-- 1. Create the database
--CREATE DATABASE FleetDb;
--GO

---- 2. Switch to the database
--USE FleetDb;
--GO
--DROP TABLE IF EXISTS Vehicles;

-- 3. Create the Vehicles table
CREATE TABLE Vehicles (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    VIN VARCHAR(20) NOT NULL UNIQUE,            -- Changed from 17 to 20
    Make NVARCHAR(50) NOT NULL,
    Model NVARCHAR(50) NOT NULL,
    Year INT NOT NULL,
    OdometerReading DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active'
);
GO
-- 3. Insert sample test data
INSERT INTO Vehicles (VIN, Make, Model, Year, OdometerReading, Status)
VALUES 
('1FTFW1ED4KFA12345', 'Freightliner', 'Cascadia', 2022, 125400.50, 'Active'),
('2C3CDZAG7MH543210', 'Volvo', 'VNL 860', 2023, 78210.00, 'Active'),
('3C6UR5DL8LG987654', 'Kenworth', 'T680', 2021, 210850.75, 'InTransit');