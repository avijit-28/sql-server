/* ======================================================
		Name : Avijit Pakhira
		DATE: 18 Nov, 2026	
		DescriptiON : ASsignment 2 
=======================================================*/

/* 1. Write a query to fetch each customer's name, lASt order DATEalONg with 
		the total value of orders they have placed using inline sub query. */
		USE BikeStores

		SELECT 
				c.customer_id
			   ,CONCAT(c.first_name,' ',c.last_name) AS [Full Name] 
			   ,MAX(o.order_date) AS [Last Order]
			   ,(SELECT SUM(oi.list_price)
			   FROM [sales].[order_items] AS oi
			   INNER JOIN [sales].[orders] AS o
			   ON o.order_id = oi.order_id
			   WHERE c.customer_id = o.customer_id ) as [Price]
		FROM [sales].[customers] AS c 
		INNER JOIN [sales].[orders] AS o
		ON c.customer_id = o.customer_id
		GROUP BY c.customer_id, CONCAT(c.first_name,' ',c.lASt_name)
		ORDER BY c.customer_id

/* 2. PRINT the following pattern in SQL Server                                                                                        2 
	
	* 
   * * 
  * * * 
 * * * *      
* * * * * 

*/

DECLARE @r INT = 1
DECLARE @c INT = 5
WHILE @r < @c
BEGIN 
PRINT CONCAT(space(@c-@r),replicate('* ',@r))
SET @r = @r +1
END


/* 3. Write a SQL Query to find the first Week Day of the MONTH   */

DECLARE @firstDay DATE= DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1)
SELECT
	@firstDay AS FirstDate
	,DATENAME(WEEKDAY,@firstDay) AS FirstDayOfMONTH
	,CASE DATENAME(WEEKDAY,@firstDay)
		when 'saturday' then DATEADD(Day,2,@firstDay)
		when 'sunday' then DATEADD(Day,1,@firstDay)
		else @firstDay
	END AS FirstWorkingDateOfMONTH,
	DATENAME(WEEKDAY, 
	DATEADD(DAY, 
	cASe DATENAME(WEEKDAY, @firstDay)
	when 'Saturday' THEN 2 
	when 'Sunday' THEN 1 
	else 0 
	END, @firstDay)) AS FirstWorkingDayOfMonth;

/* 4. Write a query to find the 3rd highest salary in each department FROM the Employee table */
USE Assignmet;
SELECT 
	 Name
	,Salary
	,Dept
FROM (
	SELECT
		 Name
		,Salary
		,Dept
		,(DENSE_RANK() over(
	PARTITION BY Dept 
	ORDER BY Salary desc
	)) AS SalaryRank
	FROM [dbo].[Employee]) AS RankedSalary
WHERE SalaryRank = 3

/* 5. Write a query by using ANY & ALL operator? */
USE Assignmet;
SELECT AVG(e.Salary) AS avg_Salary,Dept
	FROM [dbo].[Employee] AS e
	GROUP BY e.Dept 

-- ANY
SELECT  e.ID,e.Name,e.Salary,e.Dept
FROM [dbo].[Employee] AS e
WHERE e.Salary > any ( 
	SELECT AVG( e.Salary) AS avg_Salary
	FROM [dbo].[Employee] AS e
	GROUP BY e.Dept 
	)ORDER BY e.Dept

--ALL
SELECT  e.ID,e.Name,e.Salary,e.Dept
FROM [dbo].[Employee] AS e
WHERE e.Salary > ALL ( 
	SELECT AVG( e.Salary) AS avg_Salary
	FROM [dbo].[Employee] AS e
	GROUP BY e.Dept 
	)ORDER BY e.Dept;

/* 6. ASsign a rank to each movie bASed ON the ordering of their releASe dates. */
	
	USE Assignmet;
	SELECT MovieID
      ,Title
      ,Genre
      ,ReleASeDate
	  ,DENSE_RANK() over(ORDER BY ReleASeDate) AS MovieRank
	FROM [dbo].[Movies]

/* 7. Retrieve informatiON about each book alONg with its author, publisher, and  
		genre details using apply operator.      */

	USE Assignmet;
	SELECT  
		 b.BookID
		,b.BookTitle
		,b.Price
		,ISNULL(a.AuthorName, '--- No Author ---') AS Author
		,ISNULL(p.PublisherName, '--- Self-Published ---') AS Publisher
		,ISNULL(g.GenreName, '--- General ---') AS Genre
	FROM [dbo].[Books] AS b
	OUTER APPLY (
		SELECT AuthorName 
		FROM [dbo].[Authors]
		WHERE AuthorID = b.AuthorID
		)a
	OUTER APPLY (
    SELECT PublisherName 
    FROM [dbo].[Publishers] 
    WHERE PublisherID = b.PublisherID
		) p
	OUTER APPLY (
		SELECT GenreName 
		FROM [dbo].[Genres] 
		WHERE GenreID = b.GenreID
		) g
	ORDER BY b.BookID;

/* 8. Write a query to retrieve each customer alONg with the total amount of all their 
		orders using cross apply with derived table.          */

	USE BikeStores;

	SELECT 
		c.customer_id,
		CONCAT(c.first_name, ' ', c.lASt_name) AS [Full Name],
		tot.[Total Value]
		FROM [sales].[customers] AS c
	CROSS APPLY (
    SELECT 
        SUM(oi.list_price ) AS [Total Value]
    FROM [sales].[orders] AS o
    INNER JOIN [sales].[order_items] AS oi 
        ON o.order_id = oi.order_id
    WHERE o.customer_id = c.customer_id
    GROUP BY o.customer_id 
	) AS tot
	ORDER BY c.customer_id;


/* 9. We want to analyse patient admissiONs and group them by department, MONTH, and type of 
		treatment (e.g. inpatient, outpatient). Write query to display how many patients were 
		admitted for each treatment type across different MONTHs in various departments 
		PatientAdmissiONs ( AdmissiONID INT, PatientID INT, Department VARCHAR(100), 
		E.g. 'Cardiology', 'ONcology', 'Emergency' TreatmentType VARCHAR(50), -- 'Inpatient', 
		'Outpatient' AdmissiONDATEDATE);      */

		USE Hospital;
		SELECT 
			count(p.patient_id) AS Total_patients
			,count(a.appoINTment_id) AS Total_appoINTments
			,dp.department_name
			,a.status
			,MONTH(a.appoINTment_date)
		FROM
			[hpl].[Patients] p 
			INNER JOIN [hpl].[AppoINTments] a
			ON a.patient_id = p.patient_id
			INNER JOIN [hpl].[Doctors] dc
			ON a.doctor_id = dc.doctor_id
			INNER JOIN [hpl].[Departments] dp
			ON dp.department_id = dc.department_id
		GROUP BY MONTH(a.appoINTment_date),dp.department_name,a.status
			
/* 10. Generate a report that displays Dealer phONe numbers mASked, showing ONly the lASt 4 digits, 
		WHILE replacing the remaining digits with X. FROM the IssueDescriptiON in the ComplaINT table, 
		extract the first 20 characters AS a short Issue SUMmary for reporting.  */

		USE PAINTDB;
		SELECT 
			d.DealerName
			,CONCAT(REPLICATE('X', 6), RIGHT(d.PhoneNumber, 4)) AS PhoneNumber
			,LEFT(c.IssueDescriptiON,20) AS IssueDescriptiON
		FROM [dbo].[Dealers] AS d
		INNER JOIN [dbo].[Complaints] AS c
		ON d.DealerID = c.DealerID


/* 11. For each Dealer, list all their sales orders and ASsign a unique sequential order number bASed 
		ON OrderDATE(oldest first).  Rank paINTs bASed ON total sales amount, such that paINTs with 
		the same total sales receive the same rank, and ranking numbers are cONtinuous.   */
		
		USE PaINTDB;
		with  DealerOrders_CTE AS (
			SELECT 
				o.DealerID,
				o.OrderID,
				o.OrderDate,
				ROW_NUMBER() over(
					PARTITION BY o.DealerID
					ORDER BY o.OrderDATEASC
				) AS DealerOrderSeq
			FROM [dbo].[Orders] o
		),
		PaINTSales_CTE AS (
    SELECT 
        p.PaINTID,
        p.PaINTName,
        SUM(oi.SaleAmount) AS TotalPaINTSales,
        DENSE_RANK() OVER (
            ORDER BY SUM(oi.SaleAmount) DESC
        ) AS PaINTRank
    FROM [dbo].[PaINTs] AS p
	INNER JOIN [dbo].[OrderItems] AS oi
	ON p.PaINTID = oi.PaINTID
	GROUP BY p.PaINTID, p.PaINTName
)

SELECT 
    d.DealerID,
    d.DealerName,
    o.OrderID,
    o.OrderDate,
    doc.DealerOrderSeq,
    p.PaINTName,
    oi.SaleAmount,
    psc.TotalPaINTSales,
    psc.PaINTRank
FROM [dbo].[Orders] o
INNER JOIN [dbo].[Dealers] d           ON o.DealerID = d.DealerID
INNER JOIN DealerOrders_CTE doc    ON o.OrderID = doc.OrderID
INNER JOIN [dbo].[OrderItems] oi       ON o.OrderID = oi.OrderID
INNER JOIN [dbo].[Paints] p            ON oi.PaINTID = p.PaINTID
INNER JOIN PaintSales_CTE psc      ON p.PaINTID = psc.PaINTID
ORDER BY d.DealerID, doc.DealerOrderSeq;
			

/* 12. Create a multi-statement table-valued functiON that returns a dealer-wise sales SUMmary, 
		including: DealerID, DealerName,Total Orders,Total Sales Amount. The functiON should calculate 
		values INTernally and return them AS a table.  */
		
		
		CREATE FUNCTION udf_GetDealerSalesSUMmary()
		RETURNS @DealerSUMmary TABLE (
			DealerID INT,
			DealerName VARCHAR(50),
			TotalOrders INT,
			TotalSalesAmount DECIMAL(18,2)
		)
		AS
		BEGIN
		INSERT INTO @DealerSUMmary(DealerID, DealerName, TotalOrders, TotalSalesAmount)
		SELECT 
			d.DealerID,
			d.DealerName,
			COUNT(DISTINCT o.OrderID) AS TotalOrders,
			ISNULL(SUM(oi.SaleAmount), 0.00) AS TotalSalesAmount
		FROM [dbo].[Dealers] d
		LEFT JOIN [dbo].[Orders] o ON d.DealerID = o.DealerID
		LEFT JOIN [dbo].[OrderItems] oi ON o.OrderID = oi.OrderID
		GROUP BY d.DealerID, d.DealerName;
		RETURN;
	END;
	
	use PaintDB;
	SELECT * 
	FROM udf_GetDealerSalesSUMmary()



		