USE [SmithBikes]
GO
----------------------------------
SELECT COUNT(*) AS BrandCount
FROM [dbo].[brands];
-- 
SELECT COUNT(*) AS CategoriesCount
FROM [dbo].[categories];
-- 
SELECT COUNT(*) AS CustomersCount
FROM [dbo].[customers];
-- 
SELECT COUNT(*) AS OrderItemsCount
FROM [dbo].[order_items];
-- 
SELECT COUNT(*) AS OrdersCount
FROM [dbo].[orders];
-- 
SELECT COUNT(*) AS ProductsCount
FROM [dbo].[products];
-- 
SELECT COUNT(*) AS StaffsCount
FROM [dbo].[staffs];
-- 
SELECT COUNT(*) AS StocksCount
FROM [dbo].[stocks];
-- 
SELECT COUNT(*) AS StoresCount
FROM [dbo].[stores];
----------------------------------
GO