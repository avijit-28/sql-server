SELECT TOP (1000) [std_id]
      ,[std_name]
      ,[std_ph]
  FROM [BikeStores].[hr].[student]


create view vwStudent 
as
select [std_id]
      ,[std_name]
      ,[std_ph]
from [hr].[student]

--view
select [std_id]
      ,[std_name]
      ,[std_ph]
from vwStudent

--actual table 
select * from [hr].[student]

-- insert into 
insert into vwStudent values ('Nishat','9595945143');

--update
update vwStudent set std_name = 'Avijit' where std_id = 3

-- Delete
Delete from vwStudent where std_id = 3


