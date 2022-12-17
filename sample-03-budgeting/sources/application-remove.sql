-- =============================================
-- Application: Sample 03 - Budgeting Example
-- Version 10.6, December 13, 2022
--
-- Copyright 2019-2022 Gartle LLC
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
    AND m.name LIKE 'sample03_user%'

IF LEN(@sql) > 1
    BEGIN
    EXEC (@sql);
    PRINT @sql
    END
GO

DELETE FROM [xls].[formats]                        WHERE TABLE_SCHEMA IN (N's03');
DELETE FROM [xls].[handlers]                       WHERE TABLE_SCHEMA IN (N's03');
DELETE FROM [xls].[objects]                        WHERE TABLE_SCHEMA IN (N's03');
DELETE FROM [xls].[translations]                   WHERE TABLE_SCHEMA IN (N's03');
DELETE FROM [xls].[workbooks]                      WHERE TABLE_SCHEMA IN (N's03');
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

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s03].[FK_members_dimensions]') AND parent_object_id = OBJECT_ID(N'[s03].[members]'))
    ALTER TABLE [s03].[members] DROP CONSTRAINT [FK_members_dimensions];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s03].[FK_reports_members_category_id]') AND parent_object_id = OBJECT_ID(N'[s03].[reports]'))
    ALTER TABLE [s03].[reports] DROP CONSTRAINT [FK_reports_members_category_id];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s03].[FK_reports_members_time_id]') AND parent_object_id = OBJECT_ID(N'[s03].[reports]'))
    ALTER TABLE [s03].[reports] DROP CONSTRAINT [FK_reports_members_time_id];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s03].[FK_requests_members_account_id]') AND parent_object_id = OBJECT_ID(N'[s03].[requests]'))
    ALTER TABLE [s03].[requests] DROP CONSTRAINT [FK_requests_members_account_id];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s03].[FK_requests_members_category_id]') AND parent_object_id = OBJECT_ID(N'[s03].[requests]'))
    ALTER TABLE [s03].[requests] DROP CONSTRAINT [FK_requests_members_category_id];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s03].[FK_requests_members_entity_id]') AND parent_object_id = OBJECT_ID(N'[s03].[requests]'))
    ALTER TABLE [s03].[requests] DROP CONSTRAINT [FK_requests_members_entity_id];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s03].[FK_requests_members_product_id]') AND parent_object_id = OBJECT_ID(N'[s03].[requests]'))
    ALTER TABLE [s03].[requests] DROP CONSTRAINT [FK_requests_members_product_id];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s03].[FK_requests_members_region_id]') AND parent_object_id = OBJECT_ID(N'[s03].[requests]'))
    ALTER TABLE [s03].[requests] DROP CONSTRAINT [FK_requests_members_region_id];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s03].[FK_requests_members_subaccount_id]') AND parent_object_id = OBJECT_ID(N'[s03].[requests]'))
    ALTER TABLE [s03].[requests] DROP CONSTRAINT [FK_requests_members_subaccount_id];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s03].[FK_requests_members_time_id]') AND parent_object_id = OBJECT_ID(N'[s03].[requests]'))
    ALTER TABLE [s03].[requests] DROP CONSTRAINT [FK_requests_members_time_id];
GO

IF OBJECT_ID('[s03].[usp_data]', 'P') IS NOT NULL
DROP PROCEDURE [s03].[usp_data];
GO
IF OBJECT_ID('[s03].[usp_report]', 'P') IS NOT NULL
DROP PROCEDURE [s03].[usp_report];
GO
IF OBJECT_ID('[s03].[usp_report_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s03].[usp_report_delete];
GO
IF OBJECT_ID('[s03].[usp_report_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s03].[usp_report_insert];
GO
IF OBJECT_ID('[s03].[usp_report_update]', 'P') IS NOT NULL
DROP PROCEDURE [s03].[usp_report_update];
GO
IF OBJECT_ID('[s03].[usp_request]', 'P') IS NOT NULL
DROP PROCEDURE [s03].[usp_request];
GO
IF OBJECT_ID('[s03].[usp_request_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s03].[usp_request_delete];
GO
IF OBJECT_ID('[s03].[usp_request_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s03].[usp_request_insert];
GO
IF OBJECT_ID('[s03].[usp_request_update]', 'P') IS NOT NULL
DROP PROCEDURE [s03].[usp_request_update];
GO
IF OBJECT_ID('[s03].[usp_requests]', 'P') IS NOT NULL
DROP PROCEDURE [s03].[usp_requests];
GO
IF OBJECT_ID('[s03].[xl_actions_clean_requests]', 'P') IS NOT NULL
DROP PROCEDURE [s03].[xl_actions_clean_requests];
GO
IF OBJECT_ID('[s03].[xl_actions_clone_requests]', 'P') IS NOT NULL
DROP PROCEDURE [s03].[xl_actions_clone_requests];
GO
IF OBJECT_ID('[s03].[xl_details_report_cell_data]', 'P') IS NOT NULL
DROP PROCEDURE [s03].[xl_details_report_cell_data];
GO
IF OBJECT_ID('[s03].[xl_list_member_id]', 'P') IS NOT NULL
DROP PROCEDURE [s03].[xl_list_member_id];
GO

IF OBJECT_ID('[s03].[dimensions]', 'U') IS NOT NULL
DROP TABLE [s03].[dimensions];
GO
IF OBJECT_ID('[s03].[members]', 'U') IS NOT NULL
DROP TABLE [s03].[members];
GO
IF OBJECT_ID('[s03].[reports]', 'U') IS NOT NULL
DROP TABLE [s03].[reports];
GO
IF OBJECT_ID('[s03].[requests]', 'U') IS NOT NULL
DROP TABLE [s03].[requests];
GO

IF SCHEMA_ID('s03') IS NOT NULL
DROP SCHEMA [s03];
GO


IF DATABASE_PRINCIPAL_ID('sample03_user1') IS NOT NULL
DROP USER [sample03_user1];
GO

print 'Application removed';
