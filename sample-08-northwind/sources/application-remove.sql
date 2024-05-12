-- =============================================
-- Application: Sample 08 - Northwind
-- Version 10.13, April 29, 2024
--
-- Copyright 2015-2024 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON;
GO

DECLARE @sql nvarchar(max) = ''

SELECT
    @sql = @sql + 'ALTER ROLE ' + QUOTENAME(r.name) + ' DROP MEMBER ' + QUOTENAME(m.name) + ';' + CHAR(13) + CHAR(10)
FROM
    sys.database_role_members rm
    INNER JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
    INNER JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE
    r.name IN ('xls_admins', 'xls_developers', 'xls_formats', 'xls_users')
    AND m.name LIKE 'sample08_user%'

IF LEN(@sql) > 1
    BEGIN
    EXEC (@sql);
    PRINT @sql
    END
GO

DELETE FROM [xls].[formats]                        WHERE TABLE_SCHEMA IN (N's08');
DELETE FROM [xls].[handlers]                       WHERE TABLE_SCHEMA IN (N's08');
DELETE FROM [xls].[objects]                        WHERE TABLE_SCHEMA IN (N's08');
DELETE FROM [xls].[translations]                   WHERE TABLE_SCHEMA IN (N's08');
DELETE FROM [xls].[workbooks]                      WHERE TABLE_SCHEMA IN (N's08');
GO

DECLARE @id int

SET @id = COALESCE((SELECT MAX(ID) FROM xls.formats), 0);

DBCC CHECKIDENT ('xls.formats', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM xls.handlers), 0);

DBCC CHECKIDENT ('xls.handlers', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM xls.objects), 0);

DBCC CHECKIDENT ('xls.objects', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM xls.translations), 0);

DBCC CHECKIDENT ('xls.translations', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM xls.workbooks), 0);

DBCC CHECKIDENT ('xls.workbooks', RESEED, @id) WITH NO_INFOMSGS;
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s08].[FK_Employees_Employees]') AND parent_object_id = OBJECT_ID(N'[s08].[Employees]'))
    ALTER TABLE [s08].[Employees] DROP CONSTRAINT [FK_Employees_Employees];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s08].[FK_EmployeeTerritories_Employees]') AND parent_object_id = OBJECT_ID(N'[s08].[EmployeeTerritories]'))
    ALTER TABLE [s08].[EmployeeTerritories] DROP CONSTRAINT [FK_EmployeeTerritories_Employees];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s08].[FK_EmployeeTerritories_Territories]') AND parent_object_id = OBJECT_ID(N'[s08].[EmployeeTerritories]'))
    ALTER TABLE [s08].[EmployeeTerritories] DROP CONSTRAINT [FK_EmployeeTerritories_Territories];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s08].[FK_Order_Details_Orders]') AND parent_object_id = OBJECT_ID(N'[s08].[OrderDetails]'))
    ALTER TABLE [s08].[OrderDetails] DROP CONSTRAINT [FK_Order_Details_Orders];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s08].[FK_Order_Details_Products]') AND parent_object_id = OBJECT_ID(N'[s08].[OrderDetails]'))
    ALTER TABLE [s08].[OrderDetails] DROP CONSTRAINT [FK_Order_Details_Products];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s08].[FK_Orders_Customers]') AND parent_object_id = OBJECT_ID(N'[s08].[Orders]'))
    ALTER TABLE [s08].[Orders] DROP CONSTRAINT [FK_Orders_Customers];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s08].[FK_Orders_Employees]') AND parent_object_id = OBJECT_ID(N'[s08].[Orders]'))
    ALTER TABLE [s08].[Orders] DROP CONSTRAINT [FK_Orders_Employees];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s08].[FK_Orders_Shippers]') AND parent_object_id = OBJECT_ID(N'[s08].[Orders]'))
    ALTER TABLE [s08].[Orders] DROP CONSTRAINT [FK_Orders_Shippers];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s08].[FK_Products_Categories]') AND parent_object_id = OBJECT_ID(N'[s08].[Products]'))
    ALTER TABLE [s08].[Products] DROP CONSTRAINT [FK_Products_Categories];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s08].[FK_Products_Suppliers]') AND parent_object_id = OBJECT_ID(N'[s08].[Products]'))
    ALTER TABLE [s08].[Products] DROP CONSTRAINT [FK_Products_Suppliers];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s08].[FK_Territories_Region]') AND parent_object_id = OBJECT_ID(N'[s08].[Territories]'))
    ALTER TABLE [s08].[Territories] DROP CONSTRAINT [FK_Territories_Region];
GO


IF OBJECT_ID('[s08].[viewEmployees]', 'V') IS NOT NULL
DROP VIEW [s08].[viewEmployees];
GO
IF OBJECT_ID('[s08].[viewSales]', 'V') IS NOT NULL
DROP VIEW [s08].[viewSales];
GO

IF OBJECT_ID('[s08].[Categories]', 'U') IS NOT NULL
DROP TABLE [s08].[Categories];
GO
IF OBJECT_ID('[s08].[Customers]', 'U') IS NOT NULL
DROP TABLE [s08].[Customers];
GO
IF OBJECT_ID('[s08].[Employees]', 'U') IS NOT NULL
DROP TABLE [s08].[Employees];
GO
IF OBJECT_ID('[s08].[EmployeeTerritories]', 'U') IS NOT NULL
DROP TABLE [s08].[EmployeeTerritories];
GO
IF OBJECT_ID('[s08].[OrderDetails]', 'U') IS NOT NULL
DROP TABLE [s08].[OrderDetails];
GO
IF OBJECT_ID('[s08].[Orders]', 'U') IS NOT NULL
DROP TABLE [s08].[Orders];
GO
IF OBJECT_ID('[s08].[Products]', 'U') IS NOT NULL
DROP TABLE [s08].[Products];
GO
IF OBJECT_ID('[s08].[Region]', 'U') IS NOT NULL
DROP TABLE [s08].[Region];
GO
IF OBJECT_ID('[s08].[Shippers]', 'U') IS NOT NULL
DROP TABLE [s08].[Shippers];
GO
IF OBJECT_ID('[s08].[Suppliers]', 'U') IS NOT NULL
DROP TABLE [s08].[Suppliers];
GO
IF OBJECT_ID('[s08].[Territories]', 'U') IS NOT NULL
DROP TABLE [s08].[Territories];
GO

IF SCHEMA_ID('s08') IS NOT NULL
DROP SCHEMA [s08];
GO


IF DATABASE_PRINCIPAL_ID('sample08_user1') IS NOT NULL
DROP USER [sample08_user1];
GO

print 'Application removed';
