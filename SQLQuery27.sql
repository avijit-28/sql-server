SELECT TOP (1000) [formula_item_id]
      ,[formula_id]
      ,[material_id]
      ,[quantity]
      ,[addition_stage]
  FROM [assignment].[asg].[formula_items]

  select * from [asg].[formula_items] 
  order by [formula_id]
