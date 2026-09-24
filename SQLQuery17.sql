SELECT TOP (1000) [varient_id]
      ,[product_id]
      ,[base_type]
      ,[pack_size_lt]
      ,[sku_code]
      ,[unit_cost]
      ,[manufacturing_cost_mrp]
  FROM [assignment].[asg].[product_varient]


  INSERT INTO [assignment].[asg].[product_varient]
(
    [product_id],
    [base_type],
    [pack_size_lt],
    [sku_code],
    [unit_cost],
    [manufacturing_cost_mrp]
)
VALUES
(1,'White Base',1.00,'SKU001',150.00,250.00),
(1,'White Base',4.00,'SKU002',550.00,850.00),
(2,'Deep Base',1.00,'SKU003',160.00,270.00),
(2,'Deep Base',4.00,'SKU004',600.00,920.00),
(3,'Clear Base',1.00,'SKU005',170.00,280.00),
(3,'Clear Base',10.00,'SKU006',1200.00,1800.00),
(4,'White Base',1.00,'SKU007',145.00,240.00),
(4,'White Base',20.00,'SKU008',2200.00,3200.00),
(5,'Deep Base',4.00,'SKU009',580.00,890.00),
(5,'Deep Base',10.00,'SKU010',1300.00,1950.00),
(6,'Clear Base',1.00,'SKU011',175.00,295.00),
(6,'Clear Base',4.00,'SKU012',650.00,980.00),
(7,'White Base',1.00,'SKU013',155.00,260.00),
(7,'White Base',10.00,'SKU014',1250.00,1880.00),
(8,'Deep Base',4.00,'SKU015',610.00,930.00),
(8,'Deep Base',20.00,'SKU016',2350.00,3450.00),
(9,'Clear Base',1.00,'SKU017',180.00,300.00),
(9,'Clear Base',4.00,'SKU018',670.00,1010.00),
(10,'White Base',1.00,'SKU019',165.00,275.00),
(10,'White Base',10.00,'SKU020',1350.00,2000.00),
(11,'Deep Base',1.00,'SKU021',185.00,310.00),
(11,'Deep Base',4.00,'SKU022',690.00,1040.00),
(12,'Clear Base',1.00,'SKU023',190.00,320.00),
(12,'Clear Base',20.00,'SKU024',2450.00,3550.00),
(13,'White Base',4.00,'SKU025',620.00,950.00),
(13,'White Base',10.00,'SKU026',1400.00,2100.00),
(14,'Deep Base',1.00,'SKU027',195.00,330.00),
(14,'Deep Base',4.00,'SKU028',720.00,1080.00),
(15,'Clear Base',1.00,'SKU029',200.00,340.00),
(15,'Clear Base',10.00,'SKU030',1450.00,2150.00);