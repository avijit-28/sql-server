SELECT TOP (1000) [formula_item_id]
      ,[formula_id]
      ,[material_id]
      ,[quantity]
      ,[addition_stage]
  FROM [assignment].[asg].[formula_items]
  order by [formula_id];


  INSERT INTO [asg].[formula_items]
(
    [formula_id],
    [material_id],
    [quantity],
    [addition_stage]
)
VALUES

-- Formula 7
(6,1,110.0000,'Grinding'),
(6,2,190.0000,'Grinding'),
(6,3,140.0000,'Letting Down'),
(6,4,460.0000,'Post Addition'),

-- Formula 8
(8,1,125.0000,'Grinding'),
(8,2,225.0000,'Grinding'),
(7,3,175.0000,'Letting Down'),
(5,5,40.0000,'Post Addition'),

-- Formula 9
(9,1,145.0000,'Grinding'),
(4,2,235.0000,'Grinding'),
(9,3,195.0000,'Letting Down'),
(6,4,625.0000,'Letting Down'),

-- Formula 10
(10,1,155.0000,'Grinding'),
(10,2,255.0000,'Grinding'),
(10,3,205.0000,'Letting Down'),
(7,5,45.0000,'Post Addition'),

-- Formula 11
(9,1,165.0000,'Grinding'),
(11,2,265.0000,'Grinding'),
(6,3,215.0000,'Letting Down'),
(11,4,675.0000,'Post Addition'),

-- Formula 12
(6,1,175.0000,'Grinding'),
(11,2,275.0000,'Grinding'),
(6,3,225.0000,'Letting Down'),
(11,5,55.0000,'Post Addition'),

-- Formula 13
(7,1,185.0000,'Grinding'),
(6,2,285.0000,'Grinding'),
(11,3,235.0000,'Letting Down'),
(3,4,725.0000,'Letting Down'),

-- Formula 14
(1,1,195.0000,'Grinding'),
(1,2,295.0000,'Grinding'),
(4,3,245.0000,'Letting Down'),
(6,5,65.0000,'Post Addition'),

-- Formula 15
(5,1,205.0000,'Grinding'),
(6,2,305.0000,'Grinding'),
(5,3,255.0000,'Letting Down'),
(6,4,775.0000,'Letting Down');