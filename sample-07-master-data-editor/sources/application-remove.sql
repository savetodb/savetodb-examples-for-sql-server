-- =============================================
-- Application: Sample 07 - Master Data Editor
-- Version 10.8, January 9, 2023
--
-- Copyright 2017-2023 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON;
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s07].[FK_employee_territories_employees]') AND parent_object_id = OBJECT_ID(N'[s07].[employee_territories]'))
    ALTER TABLE [s07].[employee_territories] DROP CONSTRAINT [FK_employee_territories_employees];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s07].[FK_employee_territories_territories]') AND parent_object_id = OBJECT_ID(N'[s07].[employee_territories]'))
    ALTER TABLE [s07].[employee_territories] DROP CONSTRAINT [FK_employee_territories_territories];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s07].[FK_employees_employees]') AND parent_object_id = OBJECT_ID(N'[s07].[employees]'))
    ALTER TABLE [s07].[employees] DROP CONSTRAINT [FK_employees_employees];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s07].[FK_territories_region]') AND parent_object_id = OBJECT_ID(N'[s07].[territories]'))
    ALTER TABLE [s07].[territories] DROP CONSTRAINT [FK_territories_region];
GO


IF OBJECT_ID('[s07].[employee_territories]', 'U') IS NOT NULL
DROP TABLE [s07].[employee_territories];
GO
IF OBJECT_ID('[s07].[employees]', 'U') IS NOT NULL
DROP TABLE [s07].[employees];
GO
IF OBJECT_ID('[s07].[regions]', 'U') IS NOT NULL
DROP TABLE [s07].[regions];
GO
IF OBJECT_ID('[s07].[territories]', 'U') IS NOT NULL
DROP TABLE [s07].[territories];
GO

IF SCHEMA_ID('s07') IS NOT NULL
DROP SCHEMA [s07];
GO


IF DATABASE_PRINCIPAL_ID('sample07_user1') IS NOT NULL
DROP USER [sample07_user1];
GO

print 'Application removed';
