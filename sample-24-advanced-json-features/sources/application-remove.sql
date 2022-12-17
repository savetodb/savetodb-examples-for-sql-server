-- =============================================
-- Application: Sample 24 - Advanced JSON Features
-- Version 10.6, December 13, 2022
--
-- Copyright 2021-2022 Gartle LLC
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
    AND m.name LIKE 'sample24_user%'

IF LEN(@sql) > 1
    BEGIN
    EXEC (@sql);
    PRINT @sql
    END
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s24].[FK_cashbook_accounts]') AND parent_object_id = OBJECT_ID(N'[s24].[cashbook]'))
    ALTER TABLE [s24].[cashbook] DROP CONSTRAINT [FK_cashbook_accounts];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s24].[FK_cashbook_companies]') AND parent_object_id = OBJECT_ID(N'[s24].[cashbook]'))
    ALTER TABLE [s24].[cashbook] DROP CONSTRAINT [FK_cashbook_companies];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s24].[FK_cashbook_items]') AND parent_object_id = OBJECT_ID(N'[s24].[cashbook]'))
    ALTER TABLE [s24].[cashbook] DROP CONSTRAINT [FK_cashbook_items];
GO

IF OBJECT_ID('[s24].[view_cashbook_json_changes_f1_update]', 'P') IS NOT NULL
DROP PROCEDURE [s24].[view_cashbook_json_changes_f1_update];
GO
IF OBJECT_ID('[s24].[view_cashbook_json_changes_f2_update]', 'P') IS NOT NULL
DROP PROCEDURE [s24].[view_cashbook_json_changes_f2_update];
GO
IF OBJECT_ID('[s24].[view_cashbook_json_generic_row_update]', 'P') IS NOT NULL
DROP PROCEDURE [s24].[view_cashbook_json_generic_row_update];
GO
IF OBJECT_ID('[s24].[view_cashbook_json_generic_table_update]', 'P') IS NOT NULL
DROP PROCEDURE [s24].[view_cashbook_json_generic_table_update];
GO
IF OBJECT_ID('[s24].[view_cashbook_json_values_f1_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s24].[view_cashbook_json_values_f1_delete];
GO
IF OBJECT_ID('[s24].[view_cashbook_json_values_f1_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s24].[view_cashbook_json_values_f1_insert];
GO
IF OBJECT_ID('[s24].[view_cashbook_json_values_f1_update]', 'P') IS NOT NULL
DROP PROCEDURE [s24].[view_cashbook_json_values_f1_update];
GO
IF OBJECT_ID('[s24].[view_cashbook_json_values_f2_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s24].[view_cashbook_json_values_f2_delete];
GO
IF OBJECT_ID('[s24].[view_cashbook_json_values_f2_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s24].[view_cashbook_json_values_f2_insert];
GO
IF OBJECT_ID('[s24].[view_cashbook_json_values_f2_update]', 'P') IS NOT NULL
DROP PROCEDURE [s24].[view_cashbook_json_values_f2_update];
GO
IF OBJECT_ID('[s24].[xl_update_generic_row]', 'P') IS NOT NULL
DROP PROCEDURE [s24].[xl_update_generic_row];
GO
IF OBJECT_ID('[s24].[xl_update_generic_table]', 'P') IS NOT NULL
DROP PROCEDURE [s24].[xl_update_generic_table];
GO

IF OBJECT_ID('[s24].[view_cashbook_json_changes_f1]', 'V') IS NOT NULL
DROP VIEW [s24].[view_cashbook_json_changes_f1];
GO
IF OBJECT_ID('[s24].[view_cashbook_json_changes_f2]', 'V') IS NOT NULL
DROP VIEW [s24].[view_cashbook_json_changes_f2];
GO
IF OBJECT_ID('[s24].[view_cashbook_json_generic_row]', 'V') IS NOT NULL
DROP VIEW [s24].[view_cashbook_json_generic_row];
GO
IF OBJECT_ID('[s24].[view_cashbook_json_generic_table]', 'V') IS NOT NULL
DROP VIEW [s24].[view_cashbook_json_generic_table];
GO
IF OBJECT_ID('[s24].[view_cashbook_json_values_f1]', 'V') IS NOT NULL
DROP VIEW [s24].[view_cashbook_json_values_f1];
GO
IF OBJECT_ID('[s24].[view_cashbook_json_values_f2]', 'V') IS NOT NULL
DROP VIEW [s24].[view_cashbook_json_values_f2];
GO

IF OBJECT_ID('[s24].[accounts]', 'U') IS NOT NULL
DROP TABLE [s24].[accounts];
GO
IF OBJECT_ID('[s24].[cashbook]', 'U') IS NOT NULL
DROP TABLE [s24].[cashbook];
GO
IF OBJECT_ID('[s24].[companies]', 'U') IS NOT NULL
DROP TABLE [s24].[companies];
GO
IF OBJECT_ID('[s24].[items]', 'U') IS NOT NULL
DROP TABLE [s24].[items];
GO

IF SCHEMA_ID('s24') IS NOT NULL
DROP SCHEMA [s24];
GO


IF DATABASE_PRINCIPAL_ID('sample24_user1') IS NOT NULL
DROP USER [sample24_user1];
GO

print 'Application removed';
