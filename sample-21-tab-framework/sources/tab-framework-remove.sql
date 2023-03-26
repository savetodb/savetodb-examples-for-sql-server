-- =============================================
-- Tab Framework for Microsoft SQL Server
-- Version 10.8, January 9, 2023
--
-- Copyright 2021-2023 Gartle LLC
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
    AND m.name LIKE 'tab%'

IF LEN(@sql) > 1
    BEGIN
    EXEC (@sql);
    PRINT @sql
    END
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[tab].[FK_cells_columns]') AND parent_object_id = OBJECT_ID(N'[tab].[cells]'))
    ALTER TABLE [tab].[cells] DROP CONSTRAINT [FK_cells_columns];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[tab].[FK_cells_rows]') AND parent_object_id = OBJECT_ID(N'[tab].[cells]'))
    ALTER TABLE [tab].[cells] DROP CONSTRAINT [FK_cells_rows];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[tab].[FK_columns_tables]') AND parent_object_id = OBJECT_ID(N'[tab].[columns]'))
    ALTER TABLE [tab].[columns] DROP CONSTRAINT [FK_columns_tables];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[tab].[FK_columns_types]') AND parent_object_id = OBJECT_ID(N'[tab].[columns]'))
    ALTER TABLE [tab].[columns] DROP CONSTRAINT [FK_columns_types];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[tab].[FK_rows_tables]') AND parent_object_id = OBJECT_ID(N'[tab].[rows]'))
    ALTER TABLE [tab].[rows] DROP CONSTRAINT [FK_rows_tables];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[tab].[FK_translations_columns]') AND parent_object_id = OBJECT_ID(N'[tab].[translations]'))
    ALTER TABLE [tab].[translations] DROP CONSTRAINT [FK_translations_columns];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[tab].[FK_translations_languages]') AND parent_object_id = OBJECT_ID(N'[tab].[translations]'))
    ALTER TABLE [tab].[translations] DROP CONSTRAINT [FK_translations_languages];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[tab].[FK_translations_rows]') AND parent_object_id = OBJECT_ID(N'[tab].[translations]'))
    ALTER TABLE [tab].[translations] DROP CONSTRAINT [FK_translations_rows];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[tab].[FK_translations_tables]') AND parent_object_id = OBJECT_ID(N'[tab].[translations]'))
    ALTER TABLE [tab].[translations] DROP CONSTRAINT [FK_translations_tables];
GO

IF OBJECT_ID('[tab].[usp_select_table]', 'P') IS NOT NULL
DROP PROCEDURE [tab].[usp_select_table];
GO
IF OBJECT_ID('[tab].[usp_select_table_update]', 'P') IS NOT NULL
DROP PROCEDURE [tab].[usp_select_table_update];
GO
IF OBJECT_ID('[tab].[usp_select_translations]', 'P') IS NOT NULL
DROP PROCEDURE [tab].[usp_select_translations];
GO
IF OBJECT_ID('[tab].[usp_select_translations_change]', 'P') IS NOT NULL
DROP PROCEDURE [tab].[usp_select_translations_change];
GO
IF OBJECT_ID('[tab].[xl_actions_export_data]', 'P') IS NOT NULL
DROP PROCEDURE [tab].[xl_actions_export_data];
GO
IF OBJECT_ID('[tab].[xl_list_by_column_id]', 'P') IS NOT NULL
DROP PROCEDURE [tab].[xl_list_by_column_id];
GO
IF OBJECT_ID('[tab].[xl_list_table_id]', 'P') IS NOT NULL
DROP PROCEDURE [tab].[xl_list_table_id];
GO

IF OBJECT_ID('[tab].[users]', 'V') IS NOT NULL
DROP VIEW [tab].[users];
GO
IF OBJECT_ID('[tab].[xl_app_handlers]', 'V') IS NOT NULL
DROP VIEW [tab].[xl_app_handlers];
GO
IF OBJECT_ID('[tab].[xl_app_objects]', 'V') IS NOT NULL
DROP VIEW [tab].[xl_app_objects];
GO
IF OBJECT_ID('[tab].[xl_app_tables]', 'V') IS NOT NULL
DROP VIEW [tab].[xl_app_tables];
GO
IF OBJECT_ID('[tab].[xl_app_translations]', 'V') IS NOT NULL
DROP VIEW [tab].[xl_app_translations];
GO

IF OBJECT_ID('[tab].[get_typed_value]', 'FN') IS NOT NULL
DROP FUNCTION [tab].[get_typed_value];
GO

IF OBJECT_ID('[tab].[cells]', 'U') IS NOT NULL
DROP TABLE [tab].[cells];
GO
IF OBJECT_ID('[tab].[columns]', 'U') IS NOT NULL
DROP TABLE [tab].[columns];
GO
IF OBJECT_ID('[tab].[formats]', 'U') IS NOT NULL
DROP TABLE [tab].[formats];
GO
IF OBJECT_ID('[tab].[languages]', 'U') IS NOT NULL
DROP TABLE [tab].[languages];
GO
IF OBJECT_ID('[tab].[rows]', 'U') IS NOT NULL
DROP TABLE [tab].[rows];
GO
IF OBJECT_ID('[tab].[tables]', 'U') IS NOT NULL
DROP TABLE [tab].[tables];
GO
IF OBJECT_ID('[tab].[translations]', 'U') IS NOT NULL
DROP TABLE [tab].[translations];
GO
IF OBJECT_ID('[tab].[types]', 'U') IS NOT NULL
DROP TABLE [tab].[types];
GO
IF OBJECT_ID('[tab].[workbooks]', 'U') IS NOT NULL
DROP TABLE [tab].[workbooks];
GO


DECLARE @sql nvarchar(max) = ''

SELECT
    @sql = @sql + 'ALTER ROLE ' + QUOTENAME(r.name) + ' DROP MEMBER ' + QUOTENAME(m.name) + ';' + CHAR(13) + CHAR(10)
FROM
    sys.database_role_members rm
    INNER JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
    INNER JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE
    r.name IN ('tab_developers', 'tab_users')

IF LEN(@sql) > 1
    BEGIN
    EXEC (@sql);
    PRINT @sql
    END
GO

IF DATABASE_PRINCIPAL_ID('tab_developers') IS NOT NULL
DROP ROLE [tab_developers];
GO
IF DATABASE_PRINCIPAL_ID('tab_users') IS NOT NULL
DROP ROLE [tab_users];
GO

IF SCHEMA_ID('tab') IS NOT NULL
DROP SCHEMA [tab];
GO


print 'Tab Framework removed';
