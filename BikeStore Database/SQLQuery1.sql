--use BikeStores;

--Multi-statement table-valued function 
--1

create function fn_GetOrderFulfillmentStatus (@storeID int)
returns @details table(
    order_id int,
    customer_id int,
    order_date date,
    required_date date,
    shipped_date date,
    fulfillment_category VARCHAR(30)
)
as 
begin
insert into @details (
order_id,
customer_id ,
order_date ,
required_date ,
shipped_date ,
fulfillment_category )
select 
order_id,
customer_id ,
order_date ,
required_date ,
shipped_date ,

case 
when shipped_date > required_date then 'Late'
when shipped_date <= required_date then 'On-Time'
when shipped_date IS NULL and current_date > required_date then 'Overdue Pending'
when shipped_date IS NULL and current_date <= required_date then 'In Progress'
end as fulfillment_category
from Sales.orders
where store_id =@storeID 
return;
end;

select * from Sales.orders;


select * from fn_GetOrderFulfillmentStatus(1);


--2

create function fn_GetStaffOrderSummary(@start_date date, @end_date date)
returns @StaffSummary table(
[staff_id] int,
[Total_orders_handled] int,
[completed_orders] int,
[delayed_orders] int,
[avg_days_to_ship] decimal(10,2)
)
as 
begin
insert into @StaffSummary 
select [staff_id],
count(*) as Total_orders_handled,
sum(case when shipped_date is null then 0 else 1 end) as completed_orders,
Sum(case when shipped_date > required_date then 1 else 0 end) as delayed_orders,
AVG(DATEDIFF(day,order_date,shipped_date)) as avg_days_to_ship
from [sales].[orders]
where order_date between @start_date and @end_date
group by [staff_id];

return;
end;


select * from fn_GetStaffOrderSummary ('2016-01-01','2016-08-26');


-- inline table-valued function 
--3
create function fn_GetStoreFulfilledOrders (@store_id  int, @max_processing_days int)
returns table 
as 
return(
select [order_id],[customer_id],[order_date],[shipped_date],[store_id],
    DATEDIFF(day,order_date,shipped_date) as processing_days
    from [sales].[orders]
    where @store_id = store_id and DATEDIFF(day,order_date,shipped_date) <= @max_processing_days 
    and shipped_date is not null
);

select * from fn_GetStoreFulfilledOrders(1,3)

--4
--drop function fn_GetCustomerDelayedOrders
create function fn_GetCustomerDelayedOrders( @customer_id int)
returns table
as 
return(
select order_id from [sales].[orders]
where (datediff(day,required_date,shipped_date) >=1 or shipped_date is null)  and customer_id = @customer_id  
);
select * from fn_GetCustomerDelayedOrders(91)