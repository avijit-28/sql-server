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