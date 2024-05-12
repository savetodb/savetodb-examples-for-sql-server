-- =============================================
-- Application: Sample 20 - Cube App
-- Version 10.13, April 29, 2024
--
-- Copyright 2020-2024 Gartle LLC
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
    AND m.name LIKE 'sample20_user%'

IF LEN(@sql) > 1
    BEGIN
    EXEC (@sql);
    PRINT @sql
    END
GO

DELETE FROM [xls].[formats]                        WHERE TABLE_SCHEMA IN (N's20');
DELETE FROM [xls].[handlers]                       WHERE TABLE_SCHEMA IN (N's20');
DELETE FROM [xls].[objects]                        WHERE TABLE_SCHEMA IN (N's20');
DELETE FROM [xls].[translations]                   WHERE TABLE_SCHEMA IN (N's20');
DELETE FROM [xls].[workbooks]                      WHERE TABLE_SCHEMA IN (N's20');
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

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s20].[FK_category_times_categories]') AND parent_object_id = OBJECT_ID(N'[s20].[category_times]'))
    ALTER TABLE [s20].[category_times] DROP CONSTRAINT [FK_category_times_categories];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s20].[FK_category_times_permissions]') AND parent_object_id = OBJECT_ID(N'[s20].[category_times]'))
    ALTER TABLE [s20].[category_times] DROP CONSTRAINT [FK_category_times_permissions];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s20].[FK_category_times_times]') AND parent_object_id = OBJECT_ID(N'[s20].[category_times]'))
    ALTER TABLE [s20].[category_times] DROP CONSTRAINT [FK_category_times_times];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s20].[FK_category_users_categories]') AND parent_object_id = OBJECT_ID(N'[s20].[category_users]'))
    ALTER TABLE [s20].[category_users] DROP CONSTRAINT [FK_category_users_categories];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s20].[FK_category_users_permissions]') AND parent_object_id = OBJECT_ID(N'[s20].[category_users]'))
    ALTER TABLE [s20].[category_users] DROP CONSTRAINT [FK_category_users_permissions];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s20].[FK_category_users_users]') AND parent_object_id = OBJECT_ID(N'[s20].[category_users]'))
    ALTER TABLE [s20].[category_users] DROP CONSTRAINT [FK_category_users_users];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s20].[FK_comments_facts]') AND parent_object_id = OBJECT_ID(N'[s20].[comments]'))
    ALTER TABLE [s20].[comments] DROP CONSTRAINT [FK_comments_facts];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s20].[FK_comments_users]') AND parent_object_id = OBJECT_ID(N'[s20].[comments]'))
    ALTER TABLE [s20].[comments] DROP CONSTRAINT [FK_comments_users];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s20].[FK_entity_users_entities]') AND parent_object_id = OBJECT_ID(N'[s20].[entity_users]'))
    ALTER TABLE [s20].[entity_users] DROP CONSTRAINT [FK_entity_users_entities];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s20].[FK_entity_users_permissions]') AND parent_object_id = OBJECT_ID(N'[s20].[entity_users]'))
    ALTER TABLE [s20].[entity_users] DROP CONSTRAINT [FK_entity_users_permissions];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s20].[FK_entity_users_users]') AND parent_object_id = OBJECT_ID(N'[s20].[entity_users]'))
    ALTER TABLE [s20].[entity_users] DROP CONSTRAINT [FK_entity_users_users];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s20].[FK_facts_accounts]') AND parent_object_id = OBJECT_ID(N'[s20].[facts]'))
    ALTER TABLE [s20].[facts] DROP CONSTRAINT [FK_facts_accounts];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s20].[FK_facts_categories]') AND parent_object_id = OBJECT_ID(N'[s20].[facts]'))
    ALTER TABLE [s20].[facts] DROP CONSTRAINT [FK_facts_categories];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s20].[FK_facts_entities]') AND parent_object_id = OBJECT_ID(N'[s20].[facts]'))
    ALTER TABLE [s20].[facts] DROP CONSTRAINT [FK_facts_entities];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s20].[FK_facts_times]') AND parent_object_id = OBJECT_ID(N'[s20].[facts]'))
    ALTER TABLE [s20].[facts] DROP CONSTRAINT [FK_facts_times];
GO

IF OBJECT_ID('[s20].[usp_form_01]', 'P') IS NOT NULL
DROP PROCEDURE [s20].[usp_form_01];
GO
IF OBJECT_ID('[s20].[usp_form_01_change]', 'P') IS NOT NULL
DROP PROCEDURE [s20].[usp_form_01_change];
GO
IF OBJECT_ID('[s20].[usp_web_category_times]', 'P') IS NOT NULL
DROP PROCEDURE [s20].[usp_web_category_times];
GO
IF OBJECT_ID('[s20].[usp_web_category_times_change]', 'P') IS NOT NULL
DROP PROCEDURE [s20].[usp_web_category_times_change];
GO
IF OBJECT_ID('[s20].[usp_web_category_users]', 'P') IS NOT NULL
DROP PROCEDURE [s20].[usp_web_category_users];
GO
IF OBJECT_ID('[s20].[usp_web_category_users_change]', 'P') IS NOT NULL
DROP PROCEDURE [s20].[usp_web_category_users_change];
GO
IF OBJECT_ID('[s20].[usp_web_entity_users]', 'P') IS NOT NULL
DROP PROCEDURE [s20].[usp_web_entity_users];
GO
IF OBJECT_ID('[s20].[usp_web_entity_users_change]', 'P') IS NOT NULL
DROP PROCEDURE [s20].[usp_web_entity_users_change];
GO
IF OBJECT_ID('[s20].[usp_web_form_01]', 'P') IS NOT NULL
DROP PROCEDURE [s20].[usp_web_form_01];
GO
IF OBJECT_ID('[s20].[usp_web_form_01_change]', 'P') IS NOT NULL
DROP PROCEDURE [s20].[usp_web_form_01_change];
GO

IF OBJECT_ID('[s20].[xl_app_handlers]', 'V') IS NOT NULL
DROP VIEW [s20].[xl_app_handlers];
GO
IF OBJECT_ID('[s20].[xl_list_category_id]', 'V') IS NOT NULL
DROP VIEW [s20].[xl_list_category_id];
GO
IF OBJECT_ID('[s20].[xl_list_entity_id]', 'V') IS NOT NULL
DROP VIEW [s20].[xl_list_entity_id];
GO

IF OBJECT_ID('[s20].[accounts]', 'U') IS NOT NULL
DROP TABLE [s20].[accounts];
GO
IF OBJECT_ID('[s20].[categories]', 'U') IS NOT NULL
DROP TABLE [s20].[categories];
GO
IF OBJECT_ID('[s20].[category_times]', 'U') IS NOT NULL
DROP TABLE [s20].[category_times];
GO
IF OBJECT_ID('[s20].[category_users]', 'U') IS NOT NULL
DROP TABLE [s20].[category_users];
GO
IF OBJECT_ID('[s20].[comments]', 'U') IS NOT NULL
DROP TABLE [s20].[comments];
GO
IF OBJECT_ID('[s20].[entities]', 'U') IS NOT NULL
DROP TABLE [s20].[entities];
GO
IF OBJECT_ID('[s20].[entity_users]', 'U') IS NOT NULL
DROP TABLE [s20].[entity_users];
GO
IF OBJECT_ID('[s20].[facts]', 'U') IS NOT NULL
DROP TABLE [s20].[facts];
GO
IF OBJECT_ID('[s20].[permissions]', 'U') IS NOT NULL
DROP TABLE [s20].[permissions];
GO
IF OBJECT_ID('[s20].[times]', 'U') IS NOT NULL
DROP TABLE [s20].[times];
GO
IF OBJECT_ID('[s20].[users]', 'U') IS NOT NULL
DROP TABLE [s20].[users];
GO

IF SCHEMA_ID('s20') IS NOT NULL
DROP SCHEMA [s20];
GO


IF DATABASE_PRINCIPAL_ID('sample20_user1') IS NOT NULL
DROP USER [sample20_user1];
GO
IF DATABASE_PRINCIPAL_ID('sample20_user2') IS NOT NULL
DROP USER [sample20_user2];
GO

print 'Application removed';
