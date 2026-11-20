CREATE TABLE dbo.Accounts (
    AccountID INT PRIMARY KEY IDENTITY(1001, 1),
    AccountHolder VARCHAR(100) NOT NULL,
    Balance DECIMAL(12, 2) NOT NULL CHECK (Balance >= 0)
);
-- 2. Create Transactions Table
CREATE TABLE dbo.AccountTransactions (
    TransactionID INT PRIMARY KEY IDENTITY(1, 1),
    AccountID INT NOT NULL,
    TransactionType VARCHAR(20) NOT NULL CHECK (TransactionType IN ('Deposit', 'Withdrawal')),
    Amount DECIMAL(12, 2) NOT NULL CHECK (Amount > 0),
    TransactionDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Trans_Accounts FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID)
);
GO
-- Seed 3 Accounts
INSERT INTO dbo.Accounts (AccountHolder, Balance)
VALUES 
    ('Avijit Pakhira', 50000.00),  -- AccountID: 1001
    ('Rahul Sharma',  30000.00),  -- AccountID: 1002
    ('Priya Sen',     75000.00);  -- AccountID: 1003
GO


CREATE TABLE dbo.trains (
    train_id INT PRIMARY KEY IDENTITY(101, 1),
    train_name VARCHAR(100) NOT NULL,
    total_seats INT NOT NULL,
    available_seats INT NOT NULL CHECK (available_seats >= 0)
);
-- 2. Reservations Table
CREATE TABLE dbo.reservations (
    reservation_id INT PRIMARY KEY IDENTITY(1, 1),
    train_id INT NOT NULL,
    passenger_name VARCHAR(100) NOT NULL,
    seats_booked INT NOT NULL CHECK (seats_booked > 0),
    status VARCHAR(20) NOT NULL CHECK (status IN ('Confirmed', 'Canceled')),
    is_processed BIT DEFAULT 0, -- Prevents processing the same reservation twice
    CONSTRAINT FK_Reservations_Trains FOREIGN KEY (train_id) REFERENCES dbo.trains(train_id)
);
GO
-- Seed 3 Trains
INSERT INTO dbo.trains (train_name, total_seats, available_seats)
VALUES 
    ('Rajdhani Express', 100, 100), -- TrainID: 101
    ('Vande Bharat',      80,  80), -- TrainID: 102
    ('Shatabdi Express', 120, 120); -- TrainID: 103
-- Seed Pending Reservations (Some Confirmed, Some Canceled)
INSERT INTO dbo.reservations (train_id, passenger_name, seats_booked, status, is_processed)
VALUES
    (101, 'Avijit Pakhira', 4, 'Confirmed', 0),  -- Should decrease 101 by 4 (100 -> 96)
    (101, 'Rahul Sharma',   2, 'Confirmed', 0),  -- Should decrease 101 by 2 (96 -> 94)
    (101, 'Rahul Sharma',   2, 'Canceled',  0),  -- Should increase 101 by 2 (94 -> 96)
    (102, 'Priya Sen',      5, 'Confirmed', 0),  -- Should decrease 102 by 5 (80 -> 75)
    (103, 'Amit Das',       10,'Confirmed', 0),  -- Should decrease 103 by 10 (120 -> 110)
    (103, 'Amit Das',       3, 'Canceled',  0);  -- Should increase 103 by 3 (110 -> 113)
GO

IF OBJECT_ID('dbo.bill_of_materials', 'U') IS NOT NULL DROP TABLE dbo.bill_of_materials;
IF OBJECT_ID('dbo.parts', 'U')              IS NOT NULL DROP TABLE dbo.parts;
GO


use Assignment2
-- 1. Parts Master Table
CREATE TABLE dbo.parts (
    part_id   INT PRIMARY KEY,
    part_name VARCHAR(100) NOT NULL,
    part_type VARCHAR(20) CHECK (part_type IN ('Assembly', 'Sub-Assembly', 'Component'))
);

-- 2. Bill of Materials (BOM) Relationship Table
CREATE TABLE dbo.bill_of_materials (
    parent_part_id INT,
    child_part_id  INT,
    quantity       DECIMAL(10, 2) NOT NULL DEFAULT 1.00,
    PRIMARY KEY (parent_part_id, child_part_id),
    CONSTRAINT FK_BOM_Parent FOREIGN KEY (parent_part_id) REFERENCES dbo.parts(part_id),
    CONSTRAINT FK_BOM_Child  FOREIGN KEY (child_part_id)  REFERENCES dbo.parts(part_id)
);
GO

--------------------------------------------------------------------------------
-- INSERT PARTS (Top Assembly -> Sub-Assemblies -> Individual Components)
--------------------------------------------------------------------------------
INSERT INTO dbo.parts (part_id, part_name, part_type)
VALUES
    -- Top-Level Finished Product
    (1000, 'Smartphone Galaxy X', 'Assembly'),

    -- Level 1 Sub-Assemblies
    (2000, 'Display Assembly',       'Sub-Assembly'),
    (3000, 'Motherboard (PCB) Unit', 'Sub-Assembly'),
    (4000, 'Camera Module',          'Sub-Assembly'),
    (5000, 'Battery Unit',           'Sub-Assembly'),
    (6000, 'Chassis & Housing',      'Sub-Assembly'),

    -- Level 2 Components (Display)
    (2001, '6.7" OLED Screen Panel', 'Component'),
    (2002, 'Gorilla Glass Victus',   'Component'),
    (2003, 'Touch Digitizer IC',     'Component'),

    -- Level 2 Components (Motherboard)
    (3001, 'Octa-Core Processor SoC', 'Component'),
    (3002, '12GB LPDDR5 RAM Chip',    'Component'),
    (3003, '256GB UFS Storage Chip',  'Component'),
    (3004, '5G Baseband Modem',       'Component'),

    -- Level 2 Components (Camera)
    (4001, '50MP Primary Image Sensor', 'Component'),
    (4002, 'Periscope Telephoto Lens',  'Component'),

    -- Level 2 Components (Battery)
    (5001, '5000 mAh Li-Po Cell',       'Component'),
    (5002, 'Power Management IC (PMIC)','Component'),

    -- Level 2 Components (Chassis)
    (6001, 'Titanium Side Frame',       'Component'),
    (6002, 'Ceramic Back Cover',        'Component'),
    (6003, 'Micro Screws',              'Component');

--------------------------------------------------------------------------------
-- INSERT BILL OF MATERIALS QUANTITIES
--------------------------------------------------------------------------------
INSERT INTO dbo.bill_of_materials (parent_part_id, child_part_id, quantity)
VALUES
    -- Smartphone consists of:
    (1000, 2000, 1.00),  -- 1 Display Assembly
    (1000, 3000, 1.00),  -- 1 Motherboard Unit
    (1000, 4000, 1.00),  -- 1 Camera Module
    (1000, 5000, 1.00),  -- 1 Battery Unit
    (1000, 6000, 1.00),  -- 1 Chassis

    -- Display Assembly breakdown:
    (2000, 2001, 1.00),  -- 1 OLED Panel
    (2000, 2002, 1.00),  -- 1 Gorilla Glass
    (2000, 2003, 1.00),  -- 1 Digitizer

    -- Motherboard breakdown:
    (3000, 3001, 1.00),  -- 1 Processor
    (3000, 3002, 1.00),  -- 1 RAM Chip
    (3000, 3003, 1.00),  -- 1 Storage Chip
    (3000, 3004, 1.00),  -- 1 5G Modem

    -- Camera Module breakdown:
    (4000, 4001, 1.00),  -- 1 Main Sensor
    (4000, 4002, 3.00),  -- 3 Lenses

    -- Battery Unit breakdown:
    (5000, 5001, 1.00),  -- 1 Battery Cell
    (5000, 5002, 1.00),  -- 1 PMIC Board

    -- Chassis breakdown:
    (6000, 6001, 1.00),  -- 1 Frame
    (6000, 6002, 1.00),  -- 1 Back Cover
    (6000, 6003, 16.00); -- 16 Micro Screws
GO


ALTER TABLE dbo.Products 
ADD StockQuantity INT NOT NULL DEFAULT 50;

UPDATE dbo.Products SET StockQuantity = 50 WHERE ProductID = 1;
UPDATE dbo.Products SET StockQuantity = 30 WHERE ProductID = 2;
UPDATE dbo.Products SET StockQuantity = 25 WHERE ProductID = 3;
UPDATE dbo.Products SET StockQuantity = 15 WHERE ProductID = 4;
GO

SELECT ProductID, ProductName, UnitPrice, StockQuantity FROM dbo.Products;

CREATE TABLE dbo.Transactions (
    TransactionID   INT IDENTITY(1,1) PRIMARY KEY,
    ProductID       INT NOT NULL FOREIGN KEY REFERENCES dbo.Products(ProductID),
    TransactionType VARCHAR(20) NOT NULL, -- 'IN' (Purchase/Restock) or 'OUT' (Sale)
    Quantity        INT NOT NULL,
    TransactionDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsProcessed     BIT NOT NULL DEFAULT 0  -- Prevents updating the same transaction twice
);
GO
-- Insert sample transactions for testing
INSERT INTO dbo.Transactions (ProductID, TransactionType, Quantity, TransactionDate, IsProcessed)
VALUES
    (1, 'IN',  20, '2026-11-20 10:00:00', 0),  -- Product 1: 50 + 20 = 70
    (1, 'OUT', 15, '2026-11-20 11:30:00', 0),  -- Product 1: 70 - 15 = 55
    (2, 'OUT',  5, '2026-11-20 12:00:00', 0),  -- Product 2: 30 -  5 = 25
    (3, 'IN',  10, '2026-11-20 13:15:00', 0),  -- Product 3: 25 + 10 = 35
    (2, 'IN',   8, '2026-11-20 14:00:00', 0);  -- Product 2: 25 +  8 = 33
GO

use PaintDB

ALTER TABLE dbo.Complaints ADD Status VARCHAR(20) NOT NULL DEFAULT 'Open';
ALTER TABLE dbo.Complaints ADD EscalationDate DATETIME NULL;

CREATE TABLE dbo.ComplaintEscalationLog (
        LogID          INT IDENTITY(1,1) PRIMARY KEY,
        ComplaintID    INT NOT NULL,
        OldStatus      VARCHAR(20),
        NewStatus      VARCHAR(20),
        EscalationDate DATETIME
    );

    INSERT INTO dbo.Complaints (DealerID, IssueDescription, ComplaintDate, Status, EscalationDate)
VALUES
    -- Case 6: Logged today (0 days old) & 'Open' -> Fresh complaint -> SHOULD NOT ESCALATE
    (2, 'Urgent inquiry about primer drying time',         GETDATE(),                    'Open', NULL),
    -- Case 7: 25 days old, but status is 'In Progress' -> Under review -> SHOULD NOT ESCALATE
    (2, 'Lab testing requested for waterproof coating',    DATEADD(DAY, -25, GETDATE()), 'In Progress', NULL),
    -- Case 8: 10 days old & 'Open' from Dealer 3 -> SHOULD ESCALATE
    (3, 'Missing 5 buckets of Super Lustre Shine',         DATEADD(DAY, -10, GETDATE()), 'Open', NULL),
    -- Case 9: 60 days old, but status is 'Closed' -> Old resolved issue -> SHOULD NOT ESCALATE
    (2, 'Credit note adjustment for returned thinner',     DATEADD(DAY, -60, GETDATE()), 'Closed', NULL),
    -- Case 10: Exactly 8 days old & 'Open' (Just crossed threshold) -> SHOULD ESCALATE
    (3, 'Wrong base coat finish supplied (Gloss vs Matte)',DATEADD(DAY, -8,  GETDATE()), 'Open', NULL),
    -- Case 11: 30 days old & 'Open' from Dealer 1 (Severely overdue) -> SHOULD ESCALATE
    (1, 'Unresponsive sales rep regarding defective batch',DATEADD(DAY, -30, GETDATE()), 'Open', NULL),
    -- Case 12: 1 day old & 'Open' -> Just logged yesterday -> SHOULD NOT ESCALATE
    (2, 'Request for updated product catalog and price list',DATEADD(DAY, -1, GETDATE()), 'Open', NULL);