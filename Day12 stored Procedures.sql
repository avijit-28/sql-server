--drop proc usp_getOrderByStaff

alter proc usp_getOrderByStaff
(
@staffid int,
@Order_year int,
@msg varchar(100) out
)
as 
begin 
	select count(order_id) as order_generated,staff_id from sales.orders
	where year(order_date) = @Order_year and @staffid = staff_id
	group by staff_id
	if(@@rowcount>0)
		set @msg ='success'
	else 
		set @msg = 'failed'

end

declare @m varchar(100)
exec usp_getOrderByStaff 3, 2016, @m out
print @m

-- create a table for course id identity colummn, course name, description, launch date,
-- insert the data using stored procedure and give a message that data has successfully inserted in the table

create table hr.[Course] (
id int primary key identity,
Course_name varchar(30),
[Description] varchar(100),
Launch_date date
)

Alter proc usp_setDataInserted 
( 
@Course_name varchar(30),
@Description varchar(100),
@Launch_date date,
@msg varchar(100) out
)
as 
begin 
insert into hr.[Course] values (@Course_name,@Description,@Launch_date)

if (@@ROWCOUNT > 0)
	set @msg = 'Successfully Inserted'
else
	set @msg = 'Data not Inserted'
Select * from hr.[Course] where @Course_name = Course_name	
end

declare @m varchar(100)
exec usp_setDataInserted 'E','start from October','2026/10/01',  @m out
print @m

--sp_helptext 'usp_setDataInserted'

--sp_depends 'usp_setDataInserted'

--- 1.Create a stored procedure to input store and display product count for each product.
alter proc usp_ProductCount(
@store_id int
)
as 
begin
select product_id,count(product_id) as P_count
from production.stocks
where store_id = @store_id
group by product_id
end

exec usp_ProductCount 2


--2 Get Orders by Customer (Basic Input Parameter)
--  Goal: Retrieve all orders placed by a specific customer.
Alter proc usp_getOrderPlaced( @customer int)
as
begin
select [order_id]
      ,[customer_id]
      ,[order_status]
      ,[order_date]
      ,[required_date]
      ,[shipped_date]
      ,[store_id]
      ,[staff_id]
from sales.orders 

where @customer = customer_id
--group by customer_id
end

exec usp_getOrderPlaced 1

-- 3 Get Order Details & Line Items (JOIN Query)
--   Goal: Return a combined view of an order along with its itemized list and total price per item.
alter proc usp_getOrderDetails(@id int)
as
begin
select order_id,item_id,product_id,quantity,list_price,(quantity*list_price*(1-discount)) as net_price 
from sales.order_items
where order_id = @id
end

exec usp_getOrderDetails 1

--4 Get Total Revenue for an Order (OUTPUT Parameter)
-- Goal: Calculate the net total price of an entire order and return it as an output variable for 
-- use in other scripts.

create proc get_TotalNetRevenue(
@orderId int, 
@netTotal int output 
)
as 
begin
set @netTotal = (select sum(quantity*list_price*(1-discount)) from sales.order_items
where order_id = @orderId)
end

declare @net int
exec get_TotalNetRevenue 1, @net out
print @net

--5 Update Order Shipping Date (DML Statement)
-- Goal: Update the shipped_date and status of an order safely.
create proc UpdateOrderShippingDate(@orderId int, @status int, @shipped_date date)
as
begin
update sales.orders set order_status = @status, shipped_date = @shipped_date
where order_id = @orderId
select * from sales.orders where order_id = @orderId
end

exec UpdateOrderShippingDate 245, 4, '2016-05-30'

--6 Store Inventory Search & Low-Stock Alert
--  Goal: Retrieve all stock levels for a specific store, filtering by items that are below a reorder threshold,
--  while including store contact information.
create proc lowStockAlert(@storeId int, @threshold int)
as
begin
select st.store_id,pd.product_name,st.phone, st.email, st.city,stk.quantity 
from sales.stores as st
join production.stocks as stk on st.store_id = stk.store_id
join production.products as pd on stk.product_id = pd.product_id
where stk.quantity < @threshold and st.store_id = @storeId
order by quantity
end

exec lowStockAlert 2,14


-- 7 Multi-Store Product Stock Aggregation
-- Goal: Summarize the distribution of a given product across all stores, returning store details 
-- alongside inventory numbers and total global stock as an OUTPUT parameter.
alter proc MultiStoreProductStockAggregation(@productId int, @totalGlobalStock int output)
as 
begin
select st.store_id,st.store_name,st.city,st.phone, stk.quantity,stk.product_id  from sales.stores as st
join production.stocks stk on st.store_id = stk.store_id
where stk.product_id = @productId

select @totalGlobalStock = sum(stk.quantity) from production.stocks as stk
where stk.product_id = @productId
end

declare @tgs int
exec MultiStoreProductStockAggregation 1, @tgs out
print @tgs

