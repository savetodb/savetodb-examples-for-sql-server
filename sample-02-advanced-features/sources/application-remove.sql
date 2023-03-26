-- =============================================
-- Application: Sample 02 - Advanced SaveToDB Features
-- Version 10.8, January 9, 2023
--
-- Copyright 2017-2023 Gartle LLC
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
    AND m.name LIKE 'sample02_user%'

IF LEN(@sql) > 1
    BEGIN
    EXEC (@sql);
    PRINT @sql
    END
GO

IF DATABASE_PRINCIPAL_ID('sample02_user6') IS NOT NULL
DROP USER [sample02_user6];
GO

DELETE FROM [xls].[formats]                        WHERE TABLE_SCHEMA IN (N's02');
DELETE FROM [xls].[handlers]                       WHERE TABLE_SCHEMA IN (N's02');
DELETE FROM [xls].[objects]                        WHERE TABLE_SCHEMA IN (N's02');
DELETE FROM [xls].[translations]                   WHERE TABLE_SCHEMA IN (N's02');
DELETE FROM [xls].[workbooks]                      WHERE TABLE_SCHEMA IN (N's02');
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

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s02].[FK_cashbook_accounts]') AND parent_object_id = OBJECT_ID(N'[s02].[cashbook]'))
    ALTER TABLE [s02].[cashbook] DROP CONSTRAINT [FK_cashbook_accounts];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s02].[FK_cashbook_companies]') AND parent_object_id = OBJECT_ID(N'[s02].[cashbook]'))
    ALTER TABLE [s02].[cashbook] DROP CONSTRAINT [FK_cashbook_companies];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s02].[FK_cashbook_items]') AND parent_object_id = OBJECT_ID(N'[s02].[cashbook]'))
    ALTER TABLE [s02].[cashbook] DROP CONSTRAINT [FK_cashbook_items];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s02].[FK_item_companies_companies]') AND parent_object_id = OBJECT_ID(N'[s02].[item_companies]'))
    ALTER TABLE [s02].[item_companies] DROP CONSTRAINT [FK_item_companies_companies];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s02].[FK_item_companies_items]') AND parent_object_id = OBJECT_ID(N'[s02].[item_companies]'))
    ALTER TABLE [s02].[item_companies] DROP CONSTRAINT [FK_item_companies_items];
GO

IF OBJECT_ID('[s02].[usp_cash_by_months]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[usp_cash_by_months];
GO
IF OBJECT_ID('[s02].[usp_cash_by_months_change]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[usp_cash_by_months_change];
GO
IF OBJECT_ID('[s02].[usp_cashbook]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[usp_cashbook];
GO
IF OBJECT_ID('[s02].[usp_cashbook2]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[usp_cashbook2];
GO
IF OBJECT_ID('[s02].[usp_cashbook2_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[usp_cashbook2_delete];
GO
IF OBJECT_ID('[s02].[usp_cashbook2_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[usp_cashbook2_insert];
GO
IF OBJECT_ID('[s02].[usp_cashbook2_update]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[usp_cashbook2_update];
GO
IF OBJECT_ID('[s02].[usp_cashbook3]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[usp_cashbook3];
GO
IF OBJECT_ID('[s02].[usp_cashbook3_change]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[usp_cashbook3_change];
GO
IF OBJECT_ID('[s02].[usp_cashbook4]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[usp_cashbook4];
GO
IF OBJECT_ID('[s02].[usp_cashbook4_merge]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[usp_cashbook4_merge];
GO
IF OBJECT_ID('[s02].[usp_cashbook5]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[usp_cashbook5];
GO
IF OBJECT_ID('[s02].[xl_details_cash_by_months]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[xl_details_cash_by_months];
GO
IF OBJECT_ID('[s02].[xl_list_account_id]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[xl_list_account_id];
GO
IF OBJECT_ID('[s02].[xl_list_company_id]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[xl_list_company_id];
GO
IF OBJECT_ID('[s02].[xl_list_company_id_for_item_id]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[xl_list_company_id_for_item_id];
GO
IF OBJECT_ID('[s02].[xl_list_company_id_with_item_id]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[xl_list_company_id_with_item_id];
GO
IF OBJECT_ID('[s02].[xl_list_day]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[xl_list_day];
GO
IF OBJECT_ID('[s02].[xl_list_item_id]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[xl_list_item_id];
GO
IF OBJECT_ID('[s02].[xl_list_year]', 'P') IS NOT NULL
DROP PROCEDURE [s02].[xl_list_year];
GO

IF OBJECT_ID('[s02].[view_cashbook]', 'V') IS NOT NULL
DROP VIEW [s02].[view_cashbook];
GO
IF OBJECT_ID('[s02].[view_cashbook2]', 'V') IS NOT NULL
DROP VIEW [s02].[view_cashbook2];
GO
IF OBJECT_ID('[s02].[view_cashbook3]', 'V') IS NOT NULL
DROP VIEW [s02].[view_cashbook3];
GO
IF OBJECT_ID('[s02].[view_translations]', 'V') IS NOT NULL
DROP VIEW [s02].[view_translations];
GO
IF OBJECT_ID('[s02].[xl_actions_online_help]', 'V') IS NOT NULL
DROP VIEW [s02].[xl_actions_online_help];
GO

IF OBJECT_ID('[s02].[accounts]', 'U') IS NOT NULL
DROP TABLE [s02].[accounts];
GO
IF OBJECT_ID('[s02].[cashbook]', 'U') IS NOT NULL
DROP TABLE [s02].[cashbook];
GO
IF OBJECT_ID('[s02].[companies]', 'U') IS NOT NULL
DROP TABLE [s02].[companies];
GO
IF OBJECT_ID('[s02].[item_companies]', 'U') IS NOT NULL
DROP TABLE [s02].[item_companies];
GO
IF OBJECT_ID('[s02].[items]', 'U') IS NOT NULL
DROP TABLE [s02].[items];
GO

IF SCHEMA_ID('s02') IS NOT NULL
DROP SCHEMA [s02];
GO


IF DATABASE_PRINCIPAL_ID('sample02_user1') IS NOT NULL
DROP USER [sample02_user1];
GO
IF DATABASE_PRINCIPAL_ID('sample02_user2') IS NOT NULL
DROP USER [sample02_user2];
GO
IF DATABASE_PRINCIPAL_ID('sample02_user3') IS NOT NULL
DROP USER [sample02_user3];
GO
IF DATABASE_PRINCIPAL_ID('sample02_user5') IS NOT NULL
DROP USER [sample02_user5];
GO
IF DATABASE_PRINCIPAL_ID('sample02_user6') IS NOT NULL
DROP USER [sample02_user6];
GO

print 'Application removed';
