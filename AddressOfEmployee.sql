CREATE TABLE Address
(
    AddressId INT IDENTITY(1,1) PRIMARY KEY,
    Country NVARCHAR(100) NOT NULL,
    State NVARCHAR(100) NOT NULL,
    City NVARCHAR(100) NOT NULL,
    Pin NVARCHAR(10) NOT NULL
);

INSERT INTO Address
(
    Country,
    State,
    City,
    Pin
)
VALUES
('India', 'West Bengal', 'Kolkata', '700001'),
('India', 'Maharashtra', 'Mumbai', '400001'),
('India', 'Karnataka', 'Bangalore', '560001'),
('India', 'Delhi', 'New Delhi', '110001'),
('India', 'Tamil Nadu', 'Chennai', '600001'),
('India', 'Telangana', 'Hyderabad', '500001'),
('India', 'Uttar Pradesh', 'Lucknow', '226001'),
('India', 'Rajasthan', 'Jaipur', '302001');


select * from Address

-- insert data
CREATE PROCEDURE InsertAddress
    @Country NVARCHAR(100),
    @State NVARCHAR(100),
    @City NVARCHAR(100),
    @Pin NVARCHAR(10)
AS
BEGIN
    INSERT INTO Address
    (
        Country,
        State,
        City,
        Pin
    )
    VALUES
    (
        @Country,
        @State,
        @City,
        @Pin
    );
END


-- get all address

CREATE PROCEDURE GetAllAddress
AS
BEGIN
    SELECT
        AddressId,
        Country,
        State,
        City,
        Pin
    FROM Address;
END


-- get address by id
CREATE PROCEDURE GetAddressById
    @AddressId INT
AS
BEGIN
    SELECT
        AddressId,
        Country,
        State,
        City,
        Pin
    FROM Address
    WHERE AddressId = @AddressId;
END


-- udate address 
CREATE OR ALTER PROCEDURE UpdateAddress
    @AddressId INT,
    @Country NVARCHAR(100) = NULL,
    @State NVARCHAR(100) = NULL,
    @City NVARCHAR(100) = NULL,
    @Pin NVARCHAR(10) = NULL
AS
BEGIN
    UPDATE Address
    SET
        Country = ISNULL(@Country, Country),
        State = ISNULL(@State, State),
        City = ISNULL(@City, City),
        Pin = ISNULL(@Pin, Pin)
    WHERE AddressId = @AddressId;
END


-- delete address
CREATE PROCEDURE DeleteAddress
    @AddressId INT
AS
BEGIN
    DELETE FROM Address
    WHERE AddressId = @AddressId;
END
