/*
================================================================================
 FOODREADY - COMPLETE DATABASE SCRIPTS DIRECTORY
 DIRECTORY: D:\avi\sql\FoodReady
 DATABASE: FoodArrivalDB / FoodReadyDB
 ENGINE: Microsoft SQL Server 2016+ / 2019 / 2022
================================================================================

This directory contains separated, table-by-table SQL scripts.
Each table has its own dedicated `.sql` file containing:
 1. CREATE TABLE with constraints (PK, FK, CHECK, UNIQUE, Defaults).
 2. Performance indexes.
 3. Stored Procedures (SPs) specific to that table/entity.
 4. Documented inline ADO.NET SQL queries used across the C# DAL Repositories.
 5. Initial sample seed data.

--------------------------------------------------------------------------------
EXECUTION ORDER (To respect Foreign Key dependencies):
--------------------------------------------------------------------------------
 1.  01_Customers.sql                  --> Base User table (Customers)
 2.  02_Admins.sql                     --> System Administrators
 3.  03_Restaurants.sql                --> Restaurant profiles and owners
 4.  04_Riders.sql                     --> Delivery partners & vehicles
 5.  05_RestaurantStaff.sql            --> Chefs/kitchen staff (FK to Restaurants)
 6.  06_FoodItems.sql                  --> Menu catalog (FK to Restaurants & Staff)
 7.  07_Orders.sql                     --> Master orders & OrderItemType TVP
 8.  08_OrderDetails.sql               --> Line items & computed subtotal
 9.  09_Notifications.sql              --> Multi-role alerts & badge counts
 10. 10_RiderRestaurantAffiliations.sql--> Rider to Restaurant mappings
 11. 11_Transactions.sql               --> Financial transactions & fee splits
 12. 12_Bulletins.sql                  --> Admin broadcasts & public notices
 13. 13_OrderSubOrders.sql             --> Multi-vendor kitchen sub-orders
 14. 14_OrderStatusHistory.sql         --> Immutable audit order timeline
================================================================================
*/

-- Ensure database exists
IF DB_ID('FoodArrivalDB') IS NULL
BEGIN
    CREATE DATABASE FoodArrivalDB;
END
GO

USE FoodArrivalDB;
GO

SELECT 'All Table SQL Files are ready in D:\avi\sql\FoodReady\' AS Message;
GO
