/* ======================================================
		Name : Avijit Pakhira
		Date : 18 Nov, 2026	
		Description : Assignment 2 
=======================================================*/

/* 1. Write a query to fetch each customer's name, last order date along with 
		the total value of orders they have placed using inline sub query. */
		use BikeStores
		select c.customer_id
			   ,CONCAT(c.first_name,' ',c.last_name) as [Full Name] 
			   ,max(o.order_date) as [last order]
			   ,(select sum(oi.list_price) 
			   from [sales].[order_items] as oi
			   inner join [sales].[orders] as o
			   on o.order_id = oi.order_id
			   where c.customer_id = o.customer_id )
		from [sales].[customers] as c 
		inner join [sales].[orders] as o
		on c.customer_id = o.customer_id
		group by c.customer_id, CONCAT(c.first_name,' ',c.last_name)
		order by c.customer_id

/* 2. Print the following pattern in SQL Server                                                                                        2 
	
	* 
   * * 
  * * * 
 * * * *      
* * * * * 

*/

declare @r int = 1
declare @c int = 5
while @r < @c
begin 
print concat(space(@c-@r),replicate('* ',@r))
set @r = @r +1
end


/* 3. Write a SQL Query to find the first Week Day of the month   */

declare @firstDay date = datefromparts(year(getdate()),month(getdate()),1)
select
	@firstDay as FirstDate
	,DATENAME(WEEKDAY,@firstDay) as FirstDayOfMonth
	,case DATENAME(WEEKDAY,@firstDay)
		when 'saturday' then DATEADD(Day,2,@firstDay)
		when 'sunday' then DATEADD(Day,1,@firstDay)
		else @firstDay
	END AS FirstWorkingDateOfMonth,
	DATENAME(WEEKDAY, 
	DATEADD(DAY, 
	CASE DATENAME(WEEKDAY, @firstDay)
	WHEN 'Saturday' THEN 2 
	WHEN 'Sunday' THEN 1 
	ELSE 0 
	END, @firstDay)) AS FirstWorkingDayOfMonth;

/* 4. Write a query to find the 3rd highest salary in each department from the Employee table */
use Assignmet;
select 
	 Name
	,Salary
	,Dept
from (
	select
		 Name
		,Salary
		,Dept
		,(DENSE_RANK() over(
	partition by Dept 
	order by Salary desc
	)) as SalaryRank
	from [dbo].[Employee]) as RankedSalary
where SalaryRank = 3

/* 5. Write a query by using ANY & ALL operator? */
use Assignmet;
select avg( e.Salary) as avg_Salary,Dept
	from [dbo].[Employee] as e
	group by e.Dept 

-- ANY
select  e.ID,e.Name,e.Salary,e.Dept
from [dbo].[Employee] as e
where e.Salary > any ( 
	select avg( e.Salary) as avg_Salary
	from [dbo].[Employee] as e
	group by e.Dept 
	)order by e.Dept

--ALL
select  e.ID,e.Name,e.Salary,e.Dept
from [dbo].[Employee] as e
where e.Salary > ALL ( 
	select avg( e.Salary) as avg_Salary
	from [dbo].[Employee] as e
	group by e.Dept 
	)order by e.Dept;

/* 6. Assign a rank to each movie based on the ordering of their release dates. */
	
	use Assignmet;
	select MovieID
      ,Title
      ,Genre
      ,ReleaseDate
	  ,DENSE_RANK() over(order by ReleaseDate) as MovieRank
  FROM dbo.Movies

/* 7. Retrieve information about each book along with its author, publisher, and  
		genre details using apply operator.      */



/* 8. Write a query to retrieve each customer along with the total amount of all their 
		orders using cross apply with derived table.          */

/* 9. We want to analyse patient admissions and group them by department, month, and type of 
		treatment (e.g. inpatient, outpatient). Write query to display how many patients were 
		admitted for each treatment type across different months in various departments 
		PatientAdmissions ( AdmissionID INT, PatientID INT, Department VARCHAR(100), 
		E.g. 'Cardiology', 'Oncology', 'Emergency' TreatmentType VARCHAR(50), -- 'Inpatient', 
		'Outpatient' AdmissionDate DATE );      */

/* 10. Generate a report that displays Dealer phone numbers masked, showing only the last 4 digits, 
		while replacing the remaining digits with X. From the IssueDescription in the Complaint table, 
		extract the first 20 characters as a short Issue Summary for reporting.  */

/* 11. For each Dealer, list all their sales orders and assign a unique sequential order number based 
		on OrderDate (oldest first).  Rank paints based on total sales amount, such that paints with 
		the same total sales receive the same rank, and ranking numbers are continuous.   */

/* 12. Create a multi-statement table-valued function that returns a dealer-wise sales summary, 
		including: DealerID, DealerName,Total Orders,Total Sales Amount. The function should calculate 
		values internally and return them as a table.   /*