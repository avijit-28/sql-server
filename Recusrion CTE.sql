WITH cte_numbers(n, weekday) 
AS (
SELECT 0, DATENAME(DW, 0)
UNION ALL
SELECT  n + 1, DATENAME(DW, n + 1)
FROM    cte_numbers
WHERE n < 6
)
SELECT weekday
FROM cte_numbers;


WITH cte_org AS (
SELECT    staff_id, first_name, manager_id
FROM   sales.staffs
WHERE manager_id IS NULL
UNION ALL
SELECT e.staff_id, e.first_name, e.manager_id
FROM sales.staffs e  INNER JOIN cte_org o 
ON o.staff_id = e.manager_id
)
SELECT * FROM cte_org;
----------------------------------------------------------------------------------------------------------

WITH EmployeesCTE
(
    employee_id,
    employee_name,
    manager_id,
    [Level]
)
AS
(
    SELECT
        employee_id,
        employee_name,
        manager_id,
        1 AS [Level]
    FROM hr.employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        c.[Level] + 1
    FROM hr.employees e
    INNER JOIN EmployeesCTE c
        ON e.manager_id = c.employee_id
)
--select * from EmployeesCTE 
SELECT
    EmpCTE.employee_name AS Employee,
    ISNULL(MgrCTE.employee_name, 'Super Boss') AS Manager,
    EmpCTE.[Level]
FROM EmployeesCTE EmpCTE
 left JOIN EmployeesCTE MgrCTE
    ON EmpCTE.manager_id = MgrCTE.employee_id
ORDER BY EmpCTE.[Level], EmpCTE.employee_name;