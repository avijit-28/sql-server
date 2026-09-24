SELECT TOP (1000) [formula_id]
      ,[product_id]
      ,[base_type]
      ,[yield_liters]
      ,[version]
  FROM [assignment].[asg].[formulas]

  INSERT INTO [asg].[formula_items]
(
    [formula_id],
    [material_id],
    [quantity],
    [addition_stage]
)
VALUES

-- Formula 7
(7,1,110.0000,'Grinding'),
(7,2,190.0000,'Grinding'),
(7,3,140.0000,'Letting Down'),
(7,4,460.0000,'Post Addition'),

-- Formula 8
(8,1,125.0000,'Grinding'),
(8,2,225.0000,'Grinding'),
(8,3,175.0000,'Letting Down'),
(8,5,40.0000,'Post Addition'),

-- Formula 9
(9,1,145.0000,'Grinding'),
(9,2,235.0000,'Grinding'),
(9,3,195.0000,'Letting Down'),
(9,4,625.0000,'Letting Down'),

-- Formula 10
(10,1,155.0000,'Grinding'),
(10,2,255.0000,'Grinding'),
(10,3,205.0000,'Letting Down'),
(10,5,45.0000,'Post Addition'),

-- Formula 11
(11,1,165.0000,'Grinding'),
(11,2,265.0000,'Grinding'),
(11,3,215.0000,'Letting Down'),
(11,4,675.0000,'Post Addition'),

-- Formula 12
(10,1,175.0000,'Grinding'),
(7,9,275.0000,'Grinding'),
(8,8,225.0000,'Letting Down'),
(10,5,55.0000,'Post Addition'),

-- Formula 13
(6,6,185.0000,'Grinding'),
(8,2,285.0000,'Grinding'),
(11,5,235.0000,'Letting Down'),
(6,7,725.0000,'Letting Down'),

-- Formula 14
(7,1,195.0000,'Grinding'),
(6,8,295.0000,'Grinding'),
(9,11,245.0000,'Letting Down'),
(10,5,65.0000,'Post Addition'),

-- Formula 15
(11,7,205.0000,'Grinding'),
(6,9,305.0000,'Grinding'),
(11,3,255.0000,'Letting Down'),
(6,4,775.0000,'Letting Down');
