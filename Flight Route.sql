DROP TABLE IF EXISTS Flights;
CREATE TABLE Flights (
    FlightID INT PRIMARY KEY,
    DepartureCity VARCHAR(3) NOT NULL,
    ArrivalCity VARCHAR(3) NOT NULL,
    Price DECIMAL(10,2) NOT NULL
);

INSERT INTO Flights (FlightID, DepartureCity, ArrivalCity, Price) VALUES
(101, 'DEL', 'DXB', 18000.00),
(102, 'DXB', 'LHR', 32000.00),
(103, 'DEL', 'DOH', 17000.00),
(104, 'DOH', 'LHR', 31000.00),
(105, 'DEL', 'BOM',  5000.00),
(106, 'BOM', 'DXB', 16000.00),
(107, 'DEL', 'LHR', 58000.00);

/* Flight Route Pathfinding (DEL to LHR)
Task: Find all flight routes from 'DEL' to 'LHR', number of hops/stops,
      and total ticket price. Order by cheapest first. */

with cte_pathfinding 
as 
(
select FlightId, DepartureCity, ArrivalCity ,0 as stops,
CAST(DepartureCity + ' ->'+ ArrivalCity as varchar(max)) as Route
,CAST(Price AS DECIMAL(18,2)) as totalPrice
from dbo.Flights
where DepartureCity = 'DEL' 
union all
select f.FlightId, f.DepartureCity, f.ArrivalCity , pf.stops + 1 as stops,
CAST(pf.Route + ' ->'+ f.ArrivalCity as varchar(max)) as Route,
CAST(f.Price + pf.totalPrice AS DECIMAL(18,2))  as totalPrice 
from dbo.Flights f join cte_pathfinding pf on pf.ArrivalCity = f.DepartureCity

)
select Route,stops,totalPrice from cte_pathfinding where ArrivalCity = 'LHR' 
order by totalPrice --OPTION (MAXRECURSION 100);

