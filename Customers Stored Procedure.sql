CREATE TABLE dbo.Customers
(
    CustomerID  INT IDENTITY(1,1) PRIMARY KEY,
    ContactName NVARCHAR(100) NOT NULL,
    City        NVARCHAR(50)  NOT NULL,
    Country     NVARCHAR(50)  NOT NULL,
    Email       NVARCHAR(100) NULL,
    Phone       NVARCHAR(20)  NULL,
    CreatedAt   DATETIME      DEFAULT GETDATE()
);

INSERT INTO dbo.Customers (ContactName, City, Country, Email, Phone)
VALUES
('Maria Anders', 'Berlin', 'Germany', 'maria.anders@gmail.com', '030-0074321'),
('Ana Trujillo', 'Mexico D.F.', 'Mexico', 'ana.trujillo@yahoo.com', '(5) 555-4729'),
('Antonio Moreno', 'Mexico D.F.', 'Mexico', 'antonio.m@gmail.com', '(5) 555-3932'),
('Thomas Hardy', 'London', 'UK', 'thomas.hardy@outlook.com', '(171) 555-7788'),
('Christina Berglund', 'Lulea', 'Sweden', 'christina.b@domain.se', '0921-12 34 65'),
('Hanna Moos', 'Mannheim', 'Germany', 'hanna.moos@web.de', '0621-08460'),
('Frederique Citeaux', 'Strasbourg', 'France', 'frederique.c@free.fr', '88.60.15.31'),
('Martin Sommer', 'Madrid', 'Spain', 'martin.sommer@yahoo.es', '(91) 555 22 82'),
('Laurence Lebihan', 'Marseille', 'France', 'laurence.l@wanadoo.fr', '91.24.45.40'),
('Elizabeth Lincoln', 'Tsawwassen', 'Canada', 'elizabeth.l@domain.ca', '(604) 555-4729'),
('Victoria Ashworth', 'London', 'UK', 'victoria.a@gmail.com', '(171) 555-0110'),
('Patricio Simpson', 'Buenos Aires', 'Argentina', 'patricio.s@fibertel.com.ar', '(1) 135-5555'),
('Francisco Chang', 'Mexico D.F.', 'Mexico', 'francisco.c@chang.com', '(5) 555-3392'),
('Yang Wang', 'Bern', 'Switzerland', 'yang.wang@swiss.ch', '0452-076545'),
('Pedro Afonso', 'Sao Paulo', 'Brazil', 'pedro.afonso@uol.com.br', '(11) 555-7647'),
('Elizabeth Brown', 'London', 'UK', 'elizabeth.b@btconnect.com', '(171) 555-2282'),
('Sven Ottlieb', 'Aachen', 'Germany', 'sven.ottlieb@t-online.de', '0241-039123'),
('Janine Labrune', 'Nantes', 'France', 'janine.l@laposte.net', '40.67.88.88'),
('Ann Devon', 'London', 'UK', 'ann.devon@gmail.com', '(171) 555-0297'),
('Roland Mendel', 'Graz', 'Austria', 'roland.mendel@telecom.at', '7675-3425');
GO

CREATE OR ALTER PROCEDURE dbo.sp_InsertCustomer
    @ContactName NVARCHAR(100),
    @City        NVARCHAR(50),
    @Country     NVARCHAR(50),
    @Email       NVARCHAR(100) = NULL,
    @Phone       NVARCHAR(20)  = NULL,
    @NewId       INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Customers (ContactName, City, Country, Email, Phone)
    VALUES (@ContactName, @City, @Country, @Email, @Phone);

    SET @NewId = SCOPE_IDENTITY();
    SELECT @NewId AS CustomerID;
END;
GO


CREATE OR ALTER PROCEDURE dbo.sp_GetCustomerById
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        CustomerID,
        ContactName,
        City,
        Country,
        Email,
        Phone
    FROM dbo.Customers
    WHERE CustomerID = @CustomerID;
END;
GO


CREATE OR ALTER PROCEDURE dbo.sp_SearchCustomers
    @SearchTerm NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        CustomerID,
        ContactName,
        City,
        Country,
        Email,
        Phone
    FROM dbo.Customers
    WHERE (@SearchTerm IS NULL OR @SearchTerm = '')
       OR ContactName LIKE '%' + @SearchTerm + '%'
       OR City        LIKE '%' + @SearchTerm + '%'
       OR Country     LIKE '%' + @SearchTerm + '%'
    ORDER BY CustomerID ASC;
END;
GO