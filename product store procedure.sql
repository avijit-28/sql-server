--drop table ProductDetails
SELECT TOP (1000) [id]
      ,[name]
      ,[price]
      ,[stock]
  FROM [Assignmet].[dbo].[Products]

Create table Products
(
ID int primary key,
Name nvarchar(50),
Price int,
stock int
);

INSERT INTO Products VALUES (1, 'DVD', 10,50);
INSERT INTO Products VALUES (2, 'Clips', 20,100);
INSERT INTO Products VALUES (3, 'USB', 300,10);
INSERT INTO Products VALUES (4, 'CD Player',100, 25);
INSERT INTO Products VALUES (5, 'LCD', 120,50);


Create table ProductDetails
(
ProductID int foreign key references Products(ID),
Color nvarchar(20),
Size nvarchar(10),
Weight decimal(8,2),

Discontinued bit,
Supplier nvarchar(20)
)
INSERT INTO ProductDetails
VALUES (1, 'White', 'Normal', 10.00, 0, 'ABC Supplier');

INSERT INTO ProductDetails
VALUES (2, 'White', 'Large', 12.56, 0, 'XYZ Supplier');

INSERT INTO ProductDetails
VALUES (3, 'Black', 'Small', 5.50, 0, 'Pragim Technologies');

INSERT INTO ProductDetails
VALUES (4, 'Silver', 'Medium', 55.00, 0, 'ABC Supplier');

INSERT INTO ProductDetails
VALUES (5, 'Silver', 'Normal', 15.50, 0, 'XYZ Supplier');

select * from ProductDetails;


alter proc sp_GetBasicProductDetails
as
Begin
Select id, name, price,stock from Products
End;

alter proc sp_GetProductDetailsByID
@ID int
as
Begin
Select ProductID, Name, Price, Color, Size, Weight, stock, Discontinued, Supplier
from Products
join ProductDetails on Products.ID = ProductDetails.ProductID
where Products.ID =  @ID
End
