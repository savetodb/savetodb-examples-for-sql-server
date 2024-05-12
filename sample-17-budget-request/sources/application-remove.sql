-- =============================================
-- Application: Sample 17 - Budget Request
-- Version 10.13, April 29, 2024
--
-- Copyright 2019-2024 Gartle LLC
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
    AND m.name LIKE 'sample17_user%'

IF LEN(@sql) > 1
    BEGIN
    EXEC (@sql);
    PRINT @sql
    END
GO

DELETE FROM [xls].[formats]                        WHERE TABLE_SCHEMA IN (N's17');
DELETE FROM [xls].[handlers]                       WHERE TABLE_SCHEMA IN (N's17');
DELETE FROM [xls].[objects]                        WHERE TABLE_SCHEMA IN (N's17');
DELETE FROM [xls].[translations]                   WHERE TABLE_SCHEMA IN (N's17');
DELETE FROM [xls].[workbooks]                      WHERE TABLE_SCHEMA IN (N's17');
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

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s17].[FK_requests_accounts]') AND parent_object_id = OBJECT_ID(N'[s17].[requests]'))
    ALTER TABLE [s17].[requests] DROP CONSTRAINT [FK_requests_accounts];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s17].[FK_requests_categories]') AND parent_object_id = OBJECT_ID(N'[s17].[requests]'))
    ALTER TABLE [s17].[requests] DROP CONSTRAINT [FK_requests_categories];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s17].[FK_requests_entities]') AND parent_object_id = OBJECT_ID(N'[s17].[requests]'))
    ALTER TABLE [s17].[requests] DROP CONSTRAINT [FK_requests_entities];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s17].[FK_requests_products]') AND parent_object_id = OBJECT_ID(N'[s17].[requests]'))
    ALTER TABLE [s17].[requests] DROP CONSTRAINT [FK_requests_products];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s17].[FK_requests_regions]') AND parent_object_id = OBJECT_ID(N'[s17].[requests]'))
    ALTER TABLE [s17].[requests] DROP CONSTRAINT [FK_requests_regions];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s17].[FK_requests_subaccounts]') AND parent_object_id = OBJECT_ID(N'[s17].[requests]'))
    ALTER TABLE [s17].[requests] DROP CONSTRAINT [FK_requests_subaccounts];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s17].[FK_requests_times]') AND parent_object_id = OBJECT_ID(N'[s17].[requests]'))
    ALTER TABLE [s17].[requests] DROP CONSTRAINT [FK_requests_times];
GO

IF OBJECT_ID('[s17].[usp_data]', 'P') IS NOT NULL
DROP PROCEDURE [s17].[usp_data];
GO
IF OBJECT_ID('[s17].[usp_request]', 'P') IS NOT NULL
DROP PROCEDURE [s17].[usp_request];
GO
IF OBJECT_ID('[s17].[usp_request_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s17].[usp_request_delete];
GO
IF OBJECT_ID('[s17].[usp_request_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s17].[usp_request_insert];
GO
IF OBJECT_ID('[s17].[usp_request_update]', 'P') IS NOT NULL
DROP PROCEDURE [s17].[usp_request_update];
GO
IF OBJECT_ID('[s17].[usp_requests]', 'P') IS NOT NULL
DROP PROCEDURE [s17].[usp_requests];
GO
IF OBJECT_ID('[s17].[xl_actions_clean_requests]', 'P') IS NOT NULL
DROP PROCEDURE [s17].[xl_actions_clean_requests];
GO
IF OBJECT_ID('[s17].[xl_actions_clone_requests]', 'P') IS NOT NULL
DROP PROCEDURE [s17].[xl_actions_clone_requests];
GO

IF OBJECT_ID('[s17].[accounts]', 'U') IS NOT NULL
DROP TABLE [s17].[accounts];
GO
IF OBJECT_ID('[s17].[categories]', 'U') IS NOT NULL
DROP TABLE [s17].[categories];
GO
IF OBJECT_ID('[s17].[entities]', 'U') IS NOT NULL
DROP TABLE [s17].[entities];
GO
IF OBJECT_ID('[s17].[products]', 'U') IS NOT NULL
DROP TABLE [s17].[products];
GO
IF OBJECT_ID('[s17].[regions]', 'U') IS NOT NULL
DROP TABLE [s17].[regions];
GO
IF OBJECT_ID('[s17].[requests]', 'U') IS NOT NULL
DROP TABLE [s17].[requests];
GO
IF OBJECT_ID('[s17].[subaccounts]', 'U') IS NOT NULL
DROP TABLE [s17].[subaccounts];
GO
IF OBJECT_ID('[s17].[times]', 'U') IS NOT NULL
DROP TABLE [s17].[times];
GO

IF SCHEMA_ID('s17') IS NOT NULL
DROP SCHEMA [s17];
GO


IF DATABASE_PRINCIPAL_ID('sample17_user1') IS NOT NULL
DROP USER [sample17_user1];
GO

print 'Application removed';
