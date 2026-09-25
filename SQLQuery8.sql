SELECT TOP (1000) [material_id]
      ,[material_name]
      ,[material_type]
      ,[unit_of_measure]
      ,[reorder_level]
      ,[hazardous_flag]
  FROM [PaintUpdated].[pup].[stg_raw_materials]

  insert into [pup].[stg_raw_materials] values (6,'Biocide','Additive','KG','60.00',1)
