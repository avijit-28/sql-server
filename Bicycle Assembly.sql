--use Assignmet


CREATE TABLE bill_of_materials (
    parent_part_id INT,
    child_part_id  INT,
    quantity       DECIMAL(10, 2) NOT NULL DEFAULT 1.00,
    PRIMARY KEY (parent_part_id, child_part_id)
);

CREATE TABLE parts (
    part_id   INT PRIMARY KEY,
    part_name VARCHAR(100) NOT NULL,
    part_type VARCHAR(20) CHECK (part_type IN ('Assembly', 'Sub-Assembly', 'Component'))
);

INSERT INTO parts (part_id, part_name, part_type) VALUES
(100, 'Bicycle', 'Assembly'),
(200, 'Frame Assembly', 'Sub-Assembly'),
(201, 'Frame Tube', 'Component'),
(202, 'Front Fork', 'Component'),
(300, 'Wheel Assembly', 'Sub-Assembly'),
(301, 'Rim', 'Component'),
(302, 'Tire', 'Component'),
(303, 'Spoke', 'Component');

INSERT INTO bill_of_materials (parent_part_id, child_part_id, quantity) VALUES
(100, 200, 1.00), -- 1 Frame per Bicycle
(100, 300, 2.00), -- 2 Wheels per Bicycle
(200, 201, 1.00), -- 1 Tube per Frame
(200, 202, 1.00), -- 1 Fork per Frame
(300, 301, 1.00), -- 1 Rim per Wheel
(300, 302, 1.00), -- 1 Tire per Wheel
(300, 303, 32.00); -- 32 Spokes per Wheel


select * from dbo.parts
select * from dbo.bill_of_materials;


-- Write a recursive CTE query that finds only the sub-components required to build a single Wheel Assembly (part_id = 300).
WITH PartsHierarchy AS
(

    SELECT
        b.parent_part_id,
        b.child_part_id,
        p.part_name,
        1 AS [Level]
    FROM bill_of_materials b
    JOIN parts p
        ON b.child_part_id = p.part_id
    WHERE b.parent_part_id = 300

    UNION ALL

    SELECT
        b.parent_part_id,
        b.child_part_id,
        p.part_name,
        ph.[Level] + 1
    FROM bill_of_materials b
    JOIN parts p
        ON b.child_part_id = p.part_id
    JOIN PartsHierarchy ph
        ON b.parent_part_id = ph.child_part_id
)
SELECT
    child_part_id AS PartID,
    part_name AS PartName
FROM PartsHierarchy;

-- Generate numbers from 1 to 10.

with cte_generate (n)
as
(
 select 1 
  union all
  select n+1
  from cte_generate

  where n<10
)
select * from cte_generate


-- Generate dates for a month

DECLARE @Year INT = 2025;
DECLARE @Month INT = 10;

WITH cte_Dates(dt)
AS
(
    SELECT DATEFROMPARTS(@Year, @Month, 1)

    UNION ALL

    SELECT DATEADD(DAY, 1, dt)
    FROM cte_Dates
    WHERE dt < EOMONTH(DATEFROMPARTS(@Year, @Month, 1))
)
SELECT dt
FROM cte_Dates;




