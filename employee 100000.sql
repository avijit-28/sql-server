SELECT  [ID]
      ,[Name]
      ,[Salary]
      ,[Gender]
      ,[City]
      ,[Dept]
  FROM [PaintUpdated].[pup].[Employee]

  WITH Numbers AS
(
    SELECT TOP 10000
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO Employee (ID, Name, Salary, Gender, City, Dept)
SELECT
    ID,
    'Emp' + CAST(ID AS VARCHAR(10)),
    20000 + (ID % 80000),
    CASE WHEN ID % 2 = 0 THEN 'Male' ELSE 'Female' END,
    CASE ID % 5
         WHEN 0 THEN 'Delhi'
         WHEN 1 THEN 'Mumbai'
         WHEN 2 THEN 'Kolkata'
         WHEN 3 THEN 'Chennai'
         ELSE 'Bangalore'
    END,
    CASE ID % 4
         WHEN 0 THEN 'IT'
         WHEN 1 THEN 'HR'
         WHEN 2 THEN 'Finance'
         ELSE 'Sales'
    END
FROM Numbers;


SELECT *
FROM pup.Employee order by ID


SELECT *
FROM pup.Employee  WITH (NOLOCK) 
order by ID ;

BEGIN TRAN
UPDATE pup.Employee
SET Salary = 95000
WHERE ID = 1;

rollback
commit