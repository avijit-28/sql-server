--CREATE DATABASE [Assignmet];
--GO
---------------------------------------------------
--USE [assignment];
--GO

--create schema [asg];


-------------------------------------------------

--drop table [asg].[product];

create table [asg].[product] (
[product_id] int primary key identity,
[product_name] varchar(100) not null,
[category] varchar(15) check([category] in ('exterior','interior','dual')) not null,
[finish_type] varchar(50) not null ,
[binder_type] varchar(50) not null,
[voc_level_g_l] decimal(5,2) not null,
[create_at] date default current_timestamp);


--sp_help [product];


SELECT * FROM [asg].[product];

INSERT INTO [asg].[product]
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


--drop table [asg].[product_varient]
create table [asg].[product_varient](
[varient_id] int primary key identity,
[product_id] int not null,
[base_type] varchar(20),
[pack_size_lt] decimal(5,2) ,
[sku_code] varchar(30) unique ,
[unit_cost] decimal(10,2) ,
[manufacturing_cost_mrp] decimal(10,2) ,
CONSTRAINT FK_product_variants_products foreign key ([product_id]) references [asg].[product] ([product_id]));


insert into [asg].[product_varient] values (2,'deep base', 4.00,'AS-INT-W-4',1000,4200),
										(1, 'White Base', 6.00, 'AS-DU-W-6', 1000, 6200);


SELECT * FROM [asg].[product_varient];

---------------------------------------------------

CREATE TABLE [asg].[raw_materials]
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


INSERT INTO [asg].[raw_materials]
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
FROM [asg].[raw_materials];

------------------------------------------------------------------------------------------

CREATE TABLE [asg].[formulas]
(
    [formula_id] INT IDENTITY(1,1) PRIMARY KEY,
    [product_id] INT NOT NULL,
    [base_type] VARCHAR(20) NOT NULL,
    [yield_liters] DECIMAL(10,2) NOT NULL,
    [version] VARCHAR(10) NOT NULL,
    CONSTRAINT FK_formulas_products
        FOREIGN KEY(product_id)
        REFERENCES [asg].[product]([product_id])
);

INSERT INTO [asg].[formulas]
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
FROM [asg].[formulas];
--------------------------------------------------------------------------------------------------
--drop table [asg].[formula_items];
CREATE TABLE [asg].[formula_items]
(
    [formula_item_id] INT IDENTITY(1,1) PRIMARY KEY,
    [formula_id] INT NOT NULL,
    [material_id] INT NOT NULL,
    [quantity] DECIMAL(10,4) NOT NULL,
    [addition_stage] VARCHAR(50) NOT NULL,
    CONSTRAINT FK_formula_items_formulas
    FOREIGN KEY(formula_id)
    REFERENCES [asg].[formulas]([formula_id]),

    CONSTRAINT FK_formula_items_materials
        FOREIGN KEY([material_id])
        REFERENCES [asg].[raw_materials]([material_id])
);

INSERT INTO [asg].[formula_items]
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
FROM [asg].[formula_items];
----------------------------------------------------------------------------

CREATE TABLE [asg].[color_shades]
(
    [shade_id] INT IDENTITY(1,1) PRIMARY KEY,
    [shade_code] VARCHAR(20) NOT NULL UNIQUE,
    [shade_name] VARCHAR(100) NOT NULL,
    [hex_value] CHAR(7) NOT NULL,
    [is_exterior_durable] BIT NOT NULL
);

INSERT INTO [asg].[color_shades]
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


CREATE TABLE [asg].[shade_recipes]
(
    [recipe_id] INT IDENTITY(1,1) PRIMARY KEY,
    [shade_id] INT NOT NULL,
    [product_id] INT NOT NULL,
    [colorant_id] INT NOT NULL,
    [shots_per_liter] DECIMAL(8,4) NOT NULL,
    CONSTRAINT FK_shade_recipes_shades
        FOREIGN KEY([shade_id])
        REFERENCES [asg].[color_shades]([shade_id]),
    CONSTRAINT FK_shade_recipes_products
        FOREIGN KEY([product_id])
        REFERENCES [asg].[product]([product_id]),
    CONSTRAINT FK_shade_recipes_materials
        FOREIGN KEY([colorant_id])
        REFERENCES [asg].[raw_materials]([material_id])
);

INSERT INTO [asg].[shade_recipes]
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
FROM [asg].[shade_recipes];

---------------------------------------------------------------------
CREATE TABLE [asg].[batch_production]
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
    REFERENCES [asg].[formulas]([formula_id])
);

INSERT INTO [asg].[batch_production]
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
FROM [asg].[batch_production];

-------------------------

CREATE TABLE [asg].[qc_test_logs]
(
    [log_id] INT IDENTITY(1,1) PRIMARY KEY,
    [batch_id] INT NOT NULL,
    [test_parameter] VARCHAR(50) NOT NULL,
    [measured_value] VARCHAR(50) NOT NULL,
    [passed] BIT NOT NULL,
    [tested_by] INT NOT NULL,
    CONSTRAINT FK_qc_test_logs_batch
        FOREIGN KEY([batch_id])
        REFERENCES [asg].[batch_production]([batch_id])
);

INSERT INTO [asg].[qc_test_logs]
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

select * from [asg].[qc_test_logs];



-----------------------------------------------------------------------------------------------------------
----- Assignment-------------------------------------
---------------------------------------------------------------------------------------------------


--drop table [asg].[exterior_premium_products];
--1
create table [asg].[exterior_premium_products] (
[product_id] int primary key identity,
[product_name] varchar(100) not null,
[category] varchar(15) check([category] in ('exterior','interior','dual')) not null,
[finish_type] varchar(50) not null ,
[binder_type] varchar(50) not null,
[voc_level_g_l] decimal(5,2) not null,
[create_at] date default current_timestamp);



INSERT INTO [asg].[exterior_premium_products]
SELECT 
[product_name],
[category],
[finish_type],
[binder_type],
[voc_level_g_l],
[create_at]
FROM [asg].[product]
WHERE [category] = 'exterior'
  AND [voc_level_g_l] < 50.00;

SELECT * FROM [asg].[exterior_premium_products];

--2 

SELECT *
INTO [asg].[high_cost_raw_materials]
FROM [asg].[raw_materials]
WHERE [reorder_level] > 500.00;

SELECT * 
FROM [asg].[high_cost_raw_materials];


/* SELECT INTO command can directly create the structure of table and insert the 
values in single step where as INSERT INTO command, first we need to create 
the table as per the structure and insert the values in two steps */

--3

--sp_help '[asg].[raw_materials]';


BULK INSERT [asg].[raw_materials]
FROM 'D:\avi\raw_material_imports.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'

);

SELECT * 
FROM [asg].[raw_materials];

---------------------------------------------------------
--4

SELECT [p].[product_id], COUNT(DISTINCT [fi].[material_id]) AS [total_raw_materials]
FROM [asg].[product] AS p
INNER JOIN [asg].[formulas] as f ON [p].[product_id] = [f].[product_id] 
INNER JOIN [asg].[formula_items] as fi ON [f].[formula_id] = [fi].[formula_id]
GROUP BY [p].[product_id] 
HAVING COUNT(DISTINCT [fi].[material_id]) > 5;

----------------------------------------------------------
---5

SELECT
    [batch_id],
    [test_parameter],
    AVG(TRY_CAST([measured_value] AS DECIMAL(10,2))) AS [avg_measured_value]
FROM [asg].[qc_test_logs]
GROUP BY
    [batch_id],
    [test_parameter]
HAVING
    SUM(CASE WHEN [passed] = 0 THEN 1 ELSE 0 END) >= 2;

sp_help 'asg.qc_test_logs';

---------------------------------------------------------------
--6

SELECT *
FROM [asg].[product_varient]
ORDER BY [manufacturing_cost_mrp] DESC, [varient_id] ASC
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY;

---------------------------------------------
--7.1

--DROP TABLE [asg].[stg_raw_materials];
CREATE TABLE [asg].[stg_raw_materials]
(
    [material_id] INT PRIMARY KEY,
    [material_name] VARCHAR(100),
    [material_type] VARCHAR(50),
    [unit_of_measure]VARCHAR(10),
    [reorder_level] DECIMAL(10,2),
    [hazardous_flag] BIT
);

INSERT INTO [asg].[stg_raw_materials]
(
    [material_id],
    [material_name],
    [material_type],
    [unit_of_measure],
    [reorder_level],
    [hazardous_flag]
)
VALUES
(1, 'Titanium Dioxide', 'Pigment', 'KG', 700.00, 0),
(2, 'Acrylic Resin', 'Binder', 'KG', 500.00, 0),
(3, 'Calcium Carbonate', 'Filler', 'KG', 600.00, 0),
(11, 'Blue Pigment', 'Pigment', 'KG', 300.00, 0),
(12, 'Red Pigment', 'Pigment', 'KG', 400.00, 1);


MERGE [asg].[raw_materials] AS TARGET
USING [asg].[stg_raw_materials] AS SOURCE
ON TARGET.material_id = SOURCE.material_id

WHEN MATCHED THEN
    UPDATE SET
        TARGET.reorder_level = SOURCE.reorder_level,
        TARGET.hazardous_flag = SOURCE.hazardous_flag

WHEN NOT MATCHED BY TARGET THEN
    INSERT
    (
        
        material_name,
        material_type,
        unit_of_measure,
        reorder_level,
        hazardous_flag
    )
    VALUES
    (
      
        SOURCE.material_name,
        SOURCE.material_type,
        SOURCE.unit_of_measure,
        SOURCE.reorder_level,
        SOURCE.hazardous_flag
    );


    SELECT * 
    FROM [asg].[stg_raw_materials];

    SELECT * 
    FROM [asg].[raw_materials];

--7.2

INSERT INTO [asg].[product_varient]
(
    [product_id],
   [sku_code],
    [manufacturing_cost_mrp]
)
VALUES
(
    (
        SELECT [product_id]
        FROM [asg].[product]
        WHERE [product_name] = 'Apex Shield'
    ),
    'EX-PNT-10L',
    1500.00
);

select * from [asg].[product_varient];


-----------------------------------------------------------

-- 8

SELECT
    [shade_name],
    [shade_code]
FROM [asg].[color_shades]
WHERE is_exterior_durable = 1
AND shade_id IN
(
    SELECT sr.shade_id
    FROM [asg].[shade_recipes] sr
    INNER JOIN [asg].[raw_materials] rm
        ON sr.[colorant_id] = rm.[material_id]
    WHERE rm.material_type = 'Pigment'
);

-----------------------------------------------------
--9
CREATE TABLE [asg].[formula_items_new]
(
    [formula_item_id] INT IDENTITY(1,1) PRIMARY KEY,

    [formula_id] INT NOT NULL,

    [material_id] INT NOT NULL,

    [quantity_required] DECIMAL(10,4) NOT NULL,

    CONSTRAINT FK_formula_items_formulas_new
    FOREIGN KEY ([formula_id])
    REFERENCES [asg].[formulas]([formula_id])
    ON DELETE CASCADE,

    CONSTRAINT FK_formula_items_raw_materials_new
    FOREIGN KEY ([material_id])
    REFERENCES [asg].[raw_materials]([material_id])
    ON UPDATE CASCADE
    ON DELETE NO ACTION
);

--------------------------------------------------------------------------------
--10

CREATE TABLE [asg].[batch_production_history]
(
    [batch_id] INT IDENTITY(1,1) PRIMARY KEY,

    [batch_number] VARCHAR(50) NOT NULL,

    [formula_id] INT NULL,

    [quantity_produced] DECIMAL(10,2) NOT NULL,

    [manufacture_date] DATE NOT NULL,

    CONSTRAINT FK_batch_production_history_formula
    FOREIGN KEY ([formula_id])
    REFERENCES [asg].[formulas] ([formula_id])
    ON DELETE SET NULL
);






















