
--drop database [Assignment]
--CREATE DATABASE [PaintUpdated];
--GO
---------------------------------------------------
--USE [PaintUpdated];
--GO

--create schema [pup];


-------------------------------------------------

--drop table [pup].[product];

create table [pup].[product] (
[product_id] int primary key identity,
[product_name] varchar(100) not null,
[category] varchar(15) check([category] in ('exterior','interior','dual')) not null,
[finish_type] varchar(50) not null ,
[binder_type] varchar(50) not null,
[voc_level_g_l] decimal(5,2) not null,
[create_at] date default current_timestamp);


--sp_help [product];


SELECT * FROM [pup].[product];

INSERT INTO [pup].[product]
(
    product_name,
    category,
    finish_type,
    binder_type,
    voc_level_g_l
)
VALUES
('Weather Coat Max', 'Exterior', 'Satin', 'Pure Acrylic', 3.80),
('Royal Shine', 'Interior', 'Semi-Gloss', 'Styrene Acrylic', 4.10),
('Smart Protect', 'Exterior', 'Matte', 'Pure Acrylic', 5.50),
('Luxury Finish', 'Dual', 'Gloss', 'Vinyl Acetate', 6.00),
('Ultra Shield Pro', 'Exterior', 'Semi-Gloss', 'Pure Acrylic', 3.90),
('Home Beauty', 'Interior', 'Matte', 'Styrene Acrylic', 4.75),
('Weather Safe Plus', 'Exterior', 'Eggshell', 'Pure Acrylic', 5.10),
('Classic Interior', 'Interior', 'Satin', 'Vinyl Acetate', 4.20),
('Premium Coat', 'Dual', 'Gloss', 'Pure Acrylic', 3.60),
('Eco Paint', 'Interior', 'Matte', 'Vinyl Acetate', 2.90),
('Rain Guard', 'Exterior', 'Satin', 'Styrene Acrylic', 4.80),
('Super Gloss Premium', 'Dual', 'Gloss', 'Pure Acrylic', 5.75),
('Silky Touch', 'Interior', 'Eggshell', 'Vinyl Acetate', 3.50);


--drop table [pup].[product_varient]
create table [pup].[product_varient](
[varient_id] int primary key identity,
[product_id] int not null,
[base_type] varchar(20),
[pack_size_lt] decimal(5,2) ,
[sku_code] varchar(30) unique ,
[unit_cost] decimal(10,2) ,
[manufacturing_cost_mrp] decimal(10,2) ,
CONSTRAINT FK_product_variants_products foreign key ([product_id]) references [pup].[product] ([product_id]));


insert into [pup].[product_varient] values (2,'deep base', 4.00,'AS-INT-W-4',1000,4200),
										(1, 'White Base', 6.00, 'AS-DU-W-6', 1000, 6200);


SELECT * FROM [pup].[product_varient];

---------------------------------------------------

CREATE TABLE [pup].[raw_materials]
(
    [material_id] INT IDENTITY(1,1) PRIMARY KEY,
    [material_name] VARCHAR(100) NOT NULL,
    [material_type] VARCHAR(20) NOT NULL
        CHECK (material_type IN
        ('Pigment','Binder','Solvent','Additive')),
    [unit_of_measure] VARCHAR(10) NOT NULL,
    [reorder_level] DECIMAL(10,2) NOT NULL,
    [hazardous_flag] BIT NOT NULL DEFAULT(0)
);


INSERT INTO [pup].[raw_materials]
( 
material_name,material_type,unit_of_measure,reorder_level,hazardous_flag
)
VALUES
('Titanium Dioxide','Pigment','KG',500,0),
('Calcium Carbonate','Pigment','KG',1000,0),
('Pure Acrylic','Binder','KG',300,0),
('Water','Solvent','L',2000,0),
('Biocide','Additive','KG',50,1),
('Blue Colorant','Pigment','L',50,0),
('Red Oxide Colorant','Pigment','L',50,0);

SELECT *
FROM [pup].[raw_materials];

------------------------------------------------------------------------------------------

CREATE TABLE [pup].[formulas]
(
    [formula_id] INT IDENTITY(1,1) PRIMARY KEY,
    [product_id] INT NOT NULL,
    [base_type] VARCHAR(20) NOT NULL,
    [yield_liters] DECIMAL(10,2) NOT NULL,
    [version] VARCHAR(10) NOT NULL,
    CONSTRAINT FK_formulas_products
        FOREIGN KEY(product_id)
        REFERENCES [pup].[product]([product_id])
);

INSERT INTO [pup].[formulas]
(
    [product_id],
    [base_type],
    [yield_liters],
    [version]
)
VALUES
(2, 'Deep Base', 1200.00, 'V1.0'),
(3, 'Clear Base', 1500.00, 'V1.1'),
(4, 'White Base', 800.00, 'V1.0'),
(5, 'Deep Base', 1000.00, 'V2.0'),
(6, 'White Base', 2000.00, 'V1.2'),
(7, 'Clear Base', 1800.00, 'V2.1'),
(8, 'Deep Base', 900.00, 'V1.0'),
(9, 'White Base', 1100.00, 'V1.3'),
(10, 'Clear Base', 1400.00, 'V2.0'),
(11, 'Deep Base', 1700.00, 'V2.2');
SELECT *
FROM [pup].[formulas];
--------------------------------------------------------------------------------------------------
--drop table [pup].[formula_items];
CREATE TABLE [pup].[formula_items]
(
    [formula_item_id] INT IDENTITY(1,1) PRIMARY KEY,
    [formula_id] INT NOT NULL,
    [material_id] INT NOT NULL,
    [quantity] DECIMAL(10,4) NOT NULL,
    [addition_stage] VARCHAR(50) NOT NULL,
    CONSTRAINT FK_formula_items_formulas
    FOREIGN KEY(formula_id)
    REFERENCES [pup].[formulas]([formula_id]),

    CONSTRAINT FK_formula_items_materials
        FOREIGN KEY([material_id])
        REFERENCES [pup].[raw_materials]([material_id])
);

INSERT INTO [pup].[formula_items]
(
    [formula_id],
    [material_id],
    [quantity],
    [addition_stage]
)
VALUES
(1,1,100.0000,'Grinding'),
(1,2,200.0000,'Grinding'),
(1,3,150.0000,'Letting Down'),
(1,4,550.0000,'Letting Down'),
(2,1,120.0000,'Grinding'),
(2,2,180.0000,'Grinding'),
(2,3,160.0000,'Letting Down'),
(2,4,540.0000,'Letting Down'),
(3,1,130.0000,'Grinding'),
(3,2,220.0000,'Grinding'),
(3,3,170.0000,'Letting Down'),
(3,2,580.0000,'Post Addition'),
(4,1,90.0000,'Grinding'),
(4,2,210.0000,'Grinding'),
(4,3,120.0000,'Letting Down'),
(4,9,380.0000,'Letting Down'),
(5,1,150.0000,'Grinding'),
(5,2,250.0000,'Grinding'),
(5,3,180.0000,'Letting Down'),
(5,5,35.0000,'Post Addition'),
(6,6,200.0000,'Grinding'),
(6,2,300.0000,'Grinding'),
(6,3,250.0000,'Letting Down'),
(6,5,700.0000,'Letting Down');

SELECT *
FROM [pup].[formula_items];
----------------------------------------------------------------------------

CREATE TABLE [pup].[color_shades]
(
    [shade_id] INT IDENTITY(1,1) PRIMARY KEY,
    [shade_code] VARCHAR(20) NOT NULL UNIQUE,
    [shade_name] VARCHAR(100) NOT NULL,
    [hex_value] CHAR(7) NOT NULL,
    [is_exterior_durable] BIT NOT NULL
);

INSERT INTO [pup].[color_shades]
(
    [shade_code],
    [shade_name],
   [hex_value],
    [is_exterior_durable]
)
VALUES
('RAL-7016','Anthracite Grey','#383E42',1),
('RAL-9005','Jet Black','#000000',1),
('OCN-101','Ocean Blue','#0047AB',1),
('WT-205','Warm Terracotta','#D2691E',0);


CREATE TABLE [pup].[shade_recipes]
(
    [recipe_id] INT IDENTITY(1,1) PRIMARY KEY,
    [shade_id] INT NOT NULL,
    [product_id] INT NOT NULL,
    [colorant_id] INT NOT NULL,
    [shots_per_liter] DECIMAL(8,4) NOT NULL,
    CONSTRAINT FK_shade_recipes_shades
        FOREIGN KEY([shade_id])
        REFERENCES [pup].[color_shades]([shade_id]),
    CONSTRAINT FK_shade_recipes_products
        FOREIGN KEY([product_id])
        REFERENCES [pup].[product]([product_id]),
    CONSTRAINT FK_shade_recipes_materials
        FOREIGN KEY([colorant_id])
        REFERENCES [pup].[raw_materials]([material_id])
);

INSERT INTO [pup].[shade_recipes]
(
    [shade_id],
    [product_id],
    [colorant_id],
    [shots_per_liter]
)
VALUES
(3,1,6,4.5000),
(3,1,7,0.5000);

SELECT *
FROM [pup].[shade_recipes];

---------------------------------------------------------------------
CREATE TABLE [pup].[batch_production]
(
    [batch_id] INT IDENTITY(1,1) PRIMARY KEY,
    [batch_number] VARCHAR(30) NOT NULL UNIQUE,
    [formula_id] INT NOT NULL,
    [quantity_produced] DECIMAL(10,2) NOT NULL,
    [manufacture_date] DATE NOT NULL,
    [qc_status] VARCHAR(20)
    CONSTRAINT CHK_batch_production_qc_status
    CHECK ([qc_status] IN ('Pending','Approved','Rejected'))
    DEFAULT 'Pending',
    CONSTRAINT FK_batch_production_formulas
    FOREIGN KEY([formula_id])
    REFERENCES [pup].[formulas]([formula_id])
);

INSERT INTO [pup].[batch_production]
(
    [batch_number],
    [formula_id],
    [quantity_produced],
   [manufacture_date]
)
VALUES
    --'BATCH-001',
    --1,
    --1000.00,
    --GETDATE()

('BATCH-002', 2, 1200.00, '2026-09-01'),
('BATCH-003', 3, 1500.00, '2026-09-02'),
('BATCH-004', 4, 800.00, '2026-09-03'),
('BATCH-005', 5, 1000.00, '2026-09-04'),
('BATCH-006', 6, 2000.00, '2026-09-05'),
('BATCH-007', 7, 1800.00, '2026-09-06'),
('BATCH-008', 8, 900.00, '2026-09-07'),
('BATCH-009', 9, 1100.00, '2026-09-08'),
('BATCH-010', 10, 1400.00,'2026-09-09'),
('BATCH-011', 8, 1700.00,'2026-09-10'),
('BATCH-012', 2, 1300.00,'2026-09-11'),
('BATCH-013', 9, 1600.00,'2026-09-12'),
('BATCH-014', 7, 1900.00,'2026-09-13'),
('BATCH-015', 11, 2200.00,'2026-09-14')
;

SELECT *
FROM [pup].[batch_production];

-------------------------

CREATE TABLE [pup].[qc_test_logs]
(
    [log_id] INT IDENTITY(1,1) PRIMARY KEY,
    [batch_id] INT NOT NULL,
    [test_parameter] VARCHAR(50) NOT NULL,
    [measured_value] VARCHAR(50) NOT NULL,
    [passed] BIT NOT NULL,
    [tested_by] INT NOT NULL,
    CONSTRAINT FK_qc_test_logs_batch
        FOREIGN KEY([batch_id])
        REFERENCES [pup].[batch_production]([batch_id])
);

INSERT INTO [pup].[qc_test_logs]
(
    [batch_id],
    [test_parameter],
    [measured_value],
    [passed],
    [tested_by]
)
VALUES
--(1,'Viscosity','95 KU',1,101),
--(1,'pH','8.5',1,101),
--(1,'Drying Time','30 Minutes',1,102),
--(1,'Scrub Resistance','2500 Cycles',1,103);

(19,'Viscosity','97 KU',1,101),
(18,'pH','8.3',1,102),
(14,'Drying Time','32 Minutes',1,103),
(16,'Scrub Resistance','2400 Cycles',1,104),
-- Batch 3
(14,'Viscosity','92 KU',1,101),
(16,'pH','8.1',1,102),
(20,'Drying Time','35 Minutes',0,103),
(20,'Scrub Resistance','2200 Cycles',1,104),

-- Batch 4
(18,'Viscosity','94 KU',1,105),
(15,'pH','8.4',1,106),
(16,'Drying Time','28 Minutes',1,107),
(15,'Scrub Resistance','2600 Cycles',1,108),

-- Batch 5

(14,'Viscosity','96 KU',1,101),
(14,'pH','8.6',1,102),
(14,'Drying Time','31 Minutes',1,103),
(14,'Scrub Resistance','2550 Cycles',1,104),

-- Batch 6
(13,'Viscosity','90 KU',0,105),
(13,'pH','7.8',0,106),
(13,'Drying Time','40 Minutes',0,107),
(13,'Scrub Resistance','1800 Cycles',0,108);

select * from [pup].[qc_test_logs];



------------------------------------------------------
--1
SELECT
    p.[product_name],
    pv.[sku_code] AS sku,
    pv.[base_type] AS variant_name
FROM [pup].[product] p
INNER JOIN [pup].[product_varient] pv
    ON p.[product_id] = pv.[product_id];

--2
SELECT
    p.[product_name],
    COUNT(pv.[varient_id]) AS total_variants
FROM [pup].[product] p
INNER JOIN [pup].[product_varient] pv
    ON p.[product_id] = pv.[product_id]
GROUP BY p.[product_name]
HAVING COUNT(pv.[varient_id]) > 0;

--3
SELECT
    p.[product_name],
    pv.[sku_code] AS sku
FROM [pup].[product] p
LEFT JOIN [pup].[product_varient] pv
    ON p.[product_id] = pv.[product_id]
ORDER BY p.[product_name];


--4
SELECT
    p.[product_id],
    p.[product_name]
FROM [pup].[product] p
LEFT JOIN [pup].[product_varient] pv
    ON p.[product_id] = pv.[product_id]
WHERE pv.[product_id] IS NULL;

--5

SELECT
    p.[product_name],
    pv.[sku_code] AS sku
FROM [pup].[product] p
RIGHT JOIN [pup].[product_varient] pv
    ON p.[product_id] = pv.[product_id];

--6
CREATE TABLE [pup].[new_raw_material]
(
    [material_id] INT IDENTITY(1,1) PRIMARY KEY,
    [material_name] VARCHAR(100) NOT NULL,
    [material_type] VARCHAR(50) NOT NULL,
    [unit_of_measure] VARCHAR(20) NOT NULL,
    [reorder_level] DECIMAL(10,2) NOT NULL,
    [hazardous_flag] BIT NOT NULL,
    [parent_material_id] INT NULL,

    CONSTRAINT FK_new_raw_material_parent
    FOREIGN KEY ([parent_material_id])
    REFERENCES [pup].[new_raw_material]([material_id])
);
INSERT INTO [pup].[new_raw_material]
(
    [material_name],
    [material_type],
    [unit_of_measure],
    [reorder_level],
    [hazardous_flag],
    [parent_material_id]
)
VALUES
-- Parent Materials
('Pigments','Category','KG',500.00,0,NULL),
('Binders','Category','KG',300.00,0,NULL),
('Solvents','Category','L',1000.00,1,NULL),
('Additives','Category','KG',200.00,0,NULL),
-- Child Materials
('Titanium Dioxide','Pigment','KG',100.00,0,1),
('Calcium Carbonate','Pigment','KG',150.00,0,1),
('Blue Colorant','Pigment','L',50.00,0,1),
('Red Oxide','Pigment','L',50.00,0,1),
('Pure Acrylic','Binder','KG',120.00,0,2),
('Styrene Acrylic','Binder','KG',100.00,0,2),
('Water','Solvent','L',500.00,0,3),
('Mineral Spirit','Solvent','L',200.00,1,3),
('Biocide','Additive','KG',25.00,1,4),
('Defoamer','Additive','KG',30.00,0,4),
('Thickener','Additive','KG',40.00,0,4);


SELECT
    rm.[material_name],
    prm.[material_name] AS parent_material_name
FROM [pup].[new_raw_material] rm
LEFT JOIN [pup].[new_raw_material] prm
    ON rm.[parent_material_id] = prm.[material_id];


--7

SELECT
    pv1.product_id,
    pv1.sku_code AS sku_1,
    pv2.sku_code AS sku_2
FROM [pup].[product_varient] pv1
INNER JOIN [pup].[product_varient] pv2
    ON pv1.product_id = pv2.product_id
    AND pv1.varient_id != pv2.varient_id;
--WHERE pv1.manufacturing_cost_mrp <> pv2.manufacturing_cost_mrp;

--8

SELECT
    p.[product_name],
    rm.[material_name]
FROM [pup].[product] p
CROSS JOIN [pup].[raw_materials] rm
ORDER BY
    p.[product_name],
    rm.[material_name];

--9

CREATE TABLE [pup].[stg_raw_materials]
(
    [material_id] INT PRIMARY KEY,
    [material_name] VARCHAR(100),
    [material_type] VARCHAR(50),
    [unit_of_measure] VARCHAR(20),
    [reorder_level] DECIMAL(10,2),
    [hazardous_flag] BIT
);

INSERT INTO [pup].[stg_raw_materials]
(
    [material_id],
    [material_name],
    [material_type],
    [unit_of_measure],
    [reorder_level],
    [hazardous_flag]
)
VALUES
(1,'Titanium Dioxide','Pigment','KG',550,0),
(2,'Calcium Carbonate','Pigment','KG',1200,0),
(3,'Pure Acrylic','Binder','KG',350,0),
(4,'Water','Solvent','L',2200,0),
(5,'Biocide','Additive','KG',60,1);

SELECT
    p.[product_id],
    p.[product_name],
    rm.[material_id],
    rm.[material_name],
    rm.[reorder_level],
    srm.[material_name] AS stg_material_name,
    srm.[reorder_level] AS stg_reorder_level
FROM [pup].[raw_materials] rm
LEFT JOIN [pup].[stg_raw_materials] srm
    ON rm.[material_id] = srm.[material_id]
CROSS JOIN [pup].[product] p
ORDER BY
    p.[product_name],
    rm.[material_name];

-----------------------------23/09/2026---------------

-- Question 1: Write an SQL query using SUM() to calculate the total current inventory value across all items in raw_materials. Assume raw_materials contains unit_cost and quantity_in_stock columns.

CREATE TABLE [pup].[raw_materials1]
(
    [material_id] INT IDENTITY(1,1) PRIMARY KEY,
    [material_name] VARCHAR(100) ,
    [material_type] VARCHAR(50) ,
    [unit_of_measure] VARCHAR(20) ,
    [reorder_level] DECIMAL(10,2) ,
    [hazardous_flag] BIT ,
    [unit_cost] DECIMAL(10,2) ,
    [quantity_in_stock] DECIMAL(10,2) 
);

INSERT INTO [pup].[raw_materials1]
VALUES
('Titanium Dioxide','Pigment','KG',500,0,250.00,1200),
('Calcium Carbonate','Pigment','KG',1000,0,80.00,2500),
('Pure Acrylic','Binder','KG',300,0,180.00,800),
('Styrene Acrylic','Binder','KG',250,0,160.00,700),
('Water','Solvent','L',2000,0,10.00,5000),
('Mineral Spirit','Solvent','L',500,1,90.00,600),
('Biocide','Additive','KG',50,1,450.00,120),
('Defoamer','Additive','KG',40,0,320.00,150),
('Thickener','Additive','KG',60,0,275.00,180),
('Blue Colorant','Pigment','L',70,0,350.00,250),
('Red Oxide','Pigment','L',65,0,300.00,200),
('Yellow Oxide','Pigment','L',80,0,310.00,220),
('Black Colorant','Pigment','L',75,0,340.00,210),
('Silicone Additive','Additive','KG',35,0,500.00,90),
('Anti-Fungal Agent','Additive','KG',45,1,550.00,75);


SELECT
    material_type,
    
    sum(unit_cost * quantity_in_stock) AS inventory_value
FROM [pup].[raw_materials1]
GROUP BY material_type;

--Question 2: Write a query that computes the total combined weight or volume for each product in products by summing up the values of its associated variants in product_variants.
SELECT
    --p.[product_id],
    p.[product_name],
    SUM(pv.[pack_size_lt]) AS total_volume
FROM [pup].[product] p
INNER JOIN [pup].[product_varient] pv
    ON p.[product_id] = pv.[product_id]
GROUP BY
    --p.[product_id],
    p.[product_name];

  --Question 3: Write an SQL query using AVG() to calculate the average selling price of all product variants in product_variants grouped by product_id.
  SELECT
    pv.[product_id],
    AVG(pv.[manufacturing_cost_mrp]) AS average_selling_price
FROM [pup].[product_varient] pv
GROUP BY pv.[product_id];

--Question 4: Write a query to find the average reorder_level across all materials in raw_materials that are flagged as hazardous (hazardous_flag = 1).
SELECT [hazardous_flag],
    AVG([reorder_level]) AS average_reorder_level
FROM [pup].[raw_materials]
WHERE [hazardous_flag] = 1
group by [hazardous_flag];

--Question 5: Write an SQL query using COUNT() to display the number of active variants for each product, including only products that have more than 3 variants.

SELECT
    pv.[product_id],
    --p.[product_name],
    COUNT(pv.[varient_id]) AS variant_count
FROM [pup].[product_varient] pv
--INNER JOIN [pup].[product_varient] pv
--    ON p.[product_id] = pv.[product_id]
GROUP BY
    pv.[product_id]
HAVING COUNT(pv.[varient_id]) > 2;

--Question 6: Write a query using COUNT() to calculate the total number of distinct raw material IDs present in stg_raw_materials versus the main raw_materials table.
SELECT
    'stg_raw_materials' AS table_name,
    COUNT(distinct [material_name]) AS material_count
FROM [pup].[stg_raw_materials]

UNION all

SELECT
    'raw_materials',
    COUNT( distinct [material_name])
FROM [pup].[raw_materials];

--Question 7: Write an SQL query using MAX() to find the highest priced variant in product_variants for each product and display the product_id along with that maximum price.
SELECT
    [product_id],
    MAX([manufacturing_cost_mrp]) AS maximum_price
FROM [pup].[product_varient]
GROUP BY [product_id];

--Question 8: Write a query using MIN() to find the lowest reorder_level value present in the staging table stg_raw_materials.
SELECT
    MIN([reorder_level]) AS minimum_reorder_level
FROM [pup].[stg_raw_materials];

--Question 09: Write an SQL query using UNION to combine all unique material IDs from both raw_materials and stg_raw_materials into a single distinct list.

SELECT distinct [material_name]
FROM [pup].[raw_materials]

UNION

SELECT distinct [material_name]
FROM [pup].[stg_raw_materials];


--Question 10: Write a query using UNION to produce a consolidated list of distinct item names, combining product_name from products and material_name from raw_materials.

SELECT [product_name] AS item_name
FROM [pup].[product]

UNION 

SELECT [material_name] AS item_name
FROM [pup].[raw_materials];

--Question 11: Write a query using UNION ALL to extract all SKU values from product_variants and combine them with all material_id strings from raw_materials into a single output column labeled item_identifier.
SELECT [sku_code] AS item_identifier
FROM [pup].[product_varient]

UNION ALL

SELECT CAST([material_id] AS VARCHAR(50)) AS item_identifier
FROM [pup].[raw_materials];

--Question 12: Write a query using INTERSECT to find common reorder_level threshold values that are shared between raw_materials and stg_raw_materials.
SELECT [material_name], [reorder_level]
FROM [pup].[raw_materials]

INTERSECT

SELECT [material_name], [reorder_level]
FROM [pup].[stg_raw_materials];

--Question 13: Write an SQL query using EXCEPT to identify all material_id records present in stg_raw_materials that do not yet exist in the main raw_materials table.
SELECT [material_name],[material_id]
FROM [pup].[stg_raw_materials]

EXCEPT

SELECT [material_name], [material_id]
FROM [pup].[raw_materials];

--Question 14: Write a query using EXCEPT to find all material_id entries in raw_materials that have no corresponding updates waiting in stg_raw_materials.

SELECT [material_name],[material_id]
FROM [pup].[raw_materials]

EXCEPT

SELECT [material_name], [material_id]
FROM [pup].[stg_raw_materials];


-------------------------------------------24/09/2026----------------------------------------------------------------------

--1. Write an SQL query using CROSS APPLY with a table-valued function to retrieve each product_name from products alongside its single highest-priced variant from product_variants. Ensure products without any variants are excluded from the output.

--DROP FUNCTION [pup].[fn_HighestPricedVariant]

CREATE FUNCTION [pup].[fn_HighestPricedVariant2]( @product_id INT )
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1
    [manufacturing_cost_mrp],[pup].[product_varient].varient_id
    FROM [pup].[product_varient]
    WHERE [product_id] = @product_id
    ORDER BY manufacturing_cost_mrp DESC
);

SELECT p.[product_name], mrp.[manufacturing_cost_mrp],mrp.varient_id
FROM [pup].[product] p
cross apply 
    [pup].[fn_HighestPricedVariant2] (p.[product_id]) as mrp

--2
SELECT
    p.[product_name],
    v.[sku_code] AS sku,
    v.[manufacturing_cost_mrp] AS price
FROM [pup].[product] p
OUTER APPLY
(
    SELECT TOP 1
        pv.[sku_code],
        pv.[manufacturing_cost_mrp]
    FROM [pup].[product_varient] pv
    WHERE pv.[product_id] = p.[product_id]
    ORDER BY pv.[manufacturing_cost_mrp] ASC
) v;

--3.
ALTER TABLE [pup].[stg_raw_materials]
ADD [tags] VARCHAR(200);

UPDATE [pup].[stg_raw_materials]
SET [tags] = 'Metal,Hazardous,Imported'
WHERE [material_id] = 1;

UPDATE [pup].[stg_raw_materials]
SET [tags] = 'Pigment,Local,Organic'
WHERE [material_id] = 2;

UPDATE [pup].[stg_raw_materials]
SET [tags] = 'Binder,Chemical,Imported'
WHERE [material_id] = 3;

UPDATE [pup].[stg_raw_materials]
SET [tags] = 'Solvent,Hazardous,Industrial'
WHERE [material_id] = 4;

UPDATE [pup].[stg_raw_materials]
SET [tags] = 'Additive,Local,NonToxic'
WHERE [material_id] = 5;

UPDATE [pup].[stg_raw_materials]
SET [tags] = 'Colorant,Imported,Premium'
WHERE [material_id] = 6;


select * from [pup].[stg_raw_materials];

--sp_help '[pup].[stg_raw_materials]'

select s.[material_name], tg.[value] as tag
from [pup].[stg_raw_materials] as s
cross apply 
    string_split(s.[tags],',') as tg


----------------------------------------------------------------------
--1
ALTER TABLE [pup].[product_varient]
ADD [status] VARCHAR(20) NULL;
GO

UPDATE [pup].[product_varient]
SET [status] = CASE [varient_id]
    WHEN 1 THEN 'Active'
    WHEN 2 THEN 'Inactive'
END
WHERE [varient_id] IN (1, 2);

SELECT
    p.[product_name],
    pv.[sku_code] AS sku,
    pv.[manufacturing_cost_mrp] AS price
FROM [pup].[product] AS p
INNER JOIN [pup].[product_varient] AS pv
    ON pv.[product_id] = p.[product_id]
WHERE pv.[status] = 'Active';

--2

CREATE TABLE [pup].[product_varient_materials]
(
    [varient_id] INT NOT NULL,
    [material_id] INT NOT NULL,

    CONSTRAINT PK_product_varient_materials
        PRIMARY KEY ([varient_id], [material_id]),

    CONSTRAINT FK_pvm_variant
        FOREIGN KEY ([varient_id])
        REFERENCES [pup].[product_varient]([varient_id]),

    CONSTRAINT FK_pvm_material
        FOREIGN KEY ([material_id])
        REFERENCES [pup].[raw_materials]([material_id])
);
GO

INSERT INTO [pup].[product_varient_materials]
    ([varient_id], [material_id])
VALUES
    (1, 1),  -- Titanium Dioxide
    (1, 3),  -- Pure Acrylic
    (1, 5),  -- Biocide: hazardous
    (2, 2),  -- Calcium Carbonate
    (2, 5);  -- Biocide: hazardous


SELECT DISTINCT
    pv.[sku_code] AS sku
FROM [pup].[product_varient] AS pv
INNER JOIN [pup].[product_varient_materials] AS pvm
    ON pvm.[varient_id] = pv.[varient_id]
INNER JOIN [pup].[raw_materials] AS rm
    ON rm.[material_id] = pvm.[material_id]
WHERE rm.[hazardous_flag] = 1;

--3
SELECT
    p.[product_name],
    pv.[sku_code] AS sku
FROM [pup].[product] AS p
LEFT OUTER JOIN [pup].[product_varient] AS pv
    ON pv.[product_id] = p.[product_id]
WHERE pv.[varient_id] IS NULL;


--4
SELECT
    rm.[material_name],
    rm.[reorder_level] AS current_reorder_level,
    srm.[reorder_level] AS updated_reorder_level
FROM [pup].[raw_materials] AS rm
LEFT OUTER JOIN [pup].[stg_raw_materials] AS srm
    ON srm.[material_id] = rm.[material_id];


 --5
 SELECT
    pv.[sku_code] AS sku,
    pv.[manufacturing_cost_mrp] AS price,
    p.[product_name]
FROM [pup].[product] AS p
RIGHT OUTER JOIN [pup].[product_varient] AS pv
    ON pv.[product_id] = p.[product_id];


--6
  SELECT
    srm.[material_id],
    srm.[material_name] AS staging_material_name,
    rm.[material_name] AS target_material_name,
    srm.[reorder_level] AS staging_reorder_level
FROM [pup].[raw_materials] AS rm
RIGHT OUTER JOIN [pup].[stg_raw_materials] AS srm
    ON srm.[material_id] = rm.[material_id];


--7
SELECT
    p.[product_name],
    COALESCE(SUM(pv.[pack_size_lt]), 0) AS total_stock_count,
    COUNT(pv.[varient_id]) AS total_variants,
    SUM(CASE
            WHEN pv.[status] = 'Active' THEN 1
            ELSE 0
        END) AS active_variants,
    SUM(CASE
            WHEN pv.[pack_size_lt] = 0 THEN 1
            ELSE 0
        END) AS out_of_stock_variants
FROM [pup].[product] AS p
LEFT OUTER JOIN [pup].[product_varient] AS pv
    ON pv.[product_id] = p.[product_id]
GROUP BY
    p.[product_id],
    p.[product_name];


--8
SELECT
    COALESCE(rm.[material_id], srm.[material_id]) AS material_identifier,
    rm.[material_name] AS main_material_name,
    srm.[material_name] AS staging_material_name,
    rm.[reorder_level] AS main_reorder_level,
    srm.[reorder_level] AS staging_reorder_level,
    CASE
        WHEN rm.[material_id] IS NULL THEN 'NEW IN STAGING'
        WHEN srm.[material_id] IS NULL THEN 'MISSING IN STAGING'
        WHEN rm.[reorder_level] = srm.[reorder_level] THEN 'SYNCED'
        ELSE 'MISMATCH'
    END AS reconciliation_status
FROM [pup].[raw_materials] AS rm
FULL OUTER JOIN [pup].[stg_raw_materials] AS srm
    ON srm.[material_id] = rm.[material_id];