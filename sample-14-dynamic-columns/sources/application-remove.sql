-- =============================================
-- Application: Sample 14 - Dynamic Columns
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
    AND m.name LIKE 'sample14_user%'

IF LEN(@sql) > 1
    BEGIN
    EXEC (@sql);
    PRINT @sql
    END
GO

DELETE FROM [xls].[formats]                        WHERE TABLE_SCHEMA IN (N's14');
DELETE FROM [xls].[handlers]                       WHERE TABLE_SCHEMA IN (N's14');
DELETE FROM [xls].[objects]                        WHERE TABLE_SCHEMA IN (N's14');
DELETE FROM [xls].[translations]                   WHERE TABLE_SCHEMA IN (N's14');
DELETE FROM [xls].[workbooks]                      WHERE TABLE_SCHEMA IN (N's14');
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

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s14].[FK_aliases_clients]') AND parent_object_id = OBJECT_ID(N'[s14].[aliases]'))
    ALTER TABLE [s14].[aliases] DROP CONSTRAINT [FK_aliases_clients];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s14].[FK_data_clients]') AND parent_object_id = OBJECT_ID(N'[s14].[data]'))
    ALTER TABLE [s14].[data] DROP CONSTRAINT [FK_data_clients];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s14].[FK_data_members_id1]') AND parent_object_id = OBJECT_ID(N'[s14].[data]'))
    ALTER TABLE [s14].[data] DROP CONSTRAINT [FK_data_members_id1];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s14].[FK_data_members_id2]') AND parent_object_id = OBJECT_ID(N'[s14].[data]'))
    ALTER TABLE [s14].[data] DROP CONSTRAINT [FK_data_members_id2];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s14].[FK_data_members_id3]') AND parent_object_id = OBJECT_ID(N'[s14].[data]'))
    ALTER TABLE [s14].[data] DROP CONSTRAINT [FK_data_members_id3];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s14].[FK_members_clients]') AND parent_object_id = OBJECT_ID(N'[s14].[members]'))
    ALTER TABLE [s14].[members] DROP CONSTRAINT [FK_members_clients];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s14].[FK_members_dimensions]') AND parent_object_id = OBJECT_ID(N'[s14].[members]'))
    ALTER TABLE [s14].[members] DROP CONSTRAINT [FK_members_dimensions];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s14].[FK_user_clients_clients]') AND parent_object_id = OBJECT_ID(N'[s14].[user_clients]'))
    ALTER TABLE [s14].[user_clients] DROP CONSTRAINT [FK_user_clients_clients];
GO

IF OBJECT_ID('[s14].[view_data_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s14].[view_data_delete];
GO
IF OBJECT_ID('[s14].[view_data_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s14].[view_data_insert];
GO
IF OBJECT_ID('[s14].[view_data_update]', 'P') IS NOT NULL
DROP PROCEDURE [s14].[view_data_update];
GO
IF OBJECT_ID('[s14].[view_members_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s14].[view_members_delete];
GO
IF OBJECT_ID('[s14].[view_members_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s14].[view_members_insert];
GO
IF OBJECT_ID('[s14].[view_members_update]', 'P') IS NOT NULL
DROP PROCEDURE [s14].[view_members_update];
GO
IF OBJECT_ID('[s14].[xl_list_member_id]', 'P') IS NOT NULL
DROP PROCEDURE [s14].[xl_list_member_id];
GO
IF OBJECT_ID('[s14].[xl_list_member_id1]', 'P') IS NOT NULL
DROP PROCEDURE [s14].[xl_list_member_id1];
GO
IF OBJECT_ID('[s14].[xl_list_member_id2]', 'P') IS NOT NULL
DROP PROCEDURE [s14].[xl_list_member_id2];
GO
IF OBJECT_ID('[s14].[xl_list_member_id3]', 'P') IS NOT NULL
DROP PROCEDURE [s14].[xl_list_member_id3];
GO

IF OBJECT_ID('[s14].[view_aliases]', 'V') IS NOT NULL
DROP VIEW [s14].[view_aliases];
GO
IF OBJECT_ID('[s14].[view_data]', 'V') IS NOT NULL
DROP VIEW [s14].[view_data];
GO
IF OBJECT_ID('[s14].[view_members]', 'V') IS NOT NULL
DROP VIEW [s14].[view_members];
GO
IF OBJECT_ID('[s14].[xl_list_client_id]', 'V') IS NOT NULL
DROP VIEW [s14].[xl_list_client_id];
GO

IF OBJECT_ID('[s14].[aliases]', 'U') IS NOT NULL
DROP TABLE [s14].[aliases];
GO
IF OBJECT_ID('[s14].[clients]', 'U') IS NOT NULL
DROP TABLE [s14].[clients];
GO
IF OBJECT_ID('[s14].[data]', 'U') IS NOT NULL
DROP TABLE [s14].[data];
GO
IF OBJECT_ID('[s14].[dimensions]', 'U') IS NOT NULL
DROP TABLE [s14].[dimensions];
GO
IF OBJECT_ID('[s14].[members]', 'U') IS NOT NULL
DROP TABLE [s14].[members];
GO
IF OBJECT_ID('[s14].[user_clients]', 'U') IS NOT NULL
DROP TABLE [s14].[user_clients];
GO

IF SCHEMA_ID('s14') IS NOT NULL
DROP SCHEMA [s14];
GO


IF DATABASE_PRINCIPAL_ID('sample14_user1') IS NOT NULL
DROP USER [sample14_user1];
GO
IF DATABASE_PRINCIPAL_ID('sample14_user2') IS NOT NULL
DROP USER [sample14_user2];
GO
IF DATABASE_PRINCIPAL_ID('sample14_user3') IS NOT NULL
DROP USER [sample14_user3];
GO

print 'Application removed';
