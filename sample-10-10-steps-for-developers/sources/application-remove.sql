-- =============================================
-- Application: Sample 10 - 10 Steps for Developers
-- Version 10.6, December 13, 2022
--
-- Copyright 2019-2022 Sergey Vaselenko
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
    AND m.name LIKE 'sample10_user%'

IF LEN(@sql) > 1
    BEGIN
    EXEC (@sql);
    PRINT @sql
    END
GO

DELETE FROM [xls].[formats]                        WHERE TABLE_SCHEMA IN (N's10');
DELETE FROM [xls].[handlers]                       WHERE TABLE_SCHEMA IN (N's10');
DELETE FROM [xls].[objects]                        WHERE TABLE_SCHEMA IN (N's10');
DELETE FROM [xls].[translations]                   WHERE TABLE_SCHEMA IN (N's10');
DELETE FROM [xls].[workbooks]                      WHERE TABLE_SCHEMA IN (N's10');
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

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s10].[FK_Payments_Accounts]') AND parent_object_id = OBJECT_ID(N'[s10].[Payments]'))
    ALTER TABLE [s10].[Payments] DROP CONSTRAINT [FK_Payments_Accounts];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s10].[FK_Payments_Companies]') AND parent_object_id = OBJECT_ID(N'[s10].[Payments]'))
    ALTER TABLE [s10].[Payments] DROP CONSTRAINT [FK_Payments_Companies];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s10].[FK_Payments_Items]') AND parent_object_id = OBJECT_ID(N'[s10].[Payments]'))
    ALTER TABLE [s10].[Payments] DROP CONSTRAINT [FK_Payments_Items];
GO

IF OBJECT_ID('[s10].[uspPayments]', 'P') IS NOT NULL
DROP PROCEDURE [s10].[uspPayments];
GO
IF OBJECT_ID('[s10].[uspPayments_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s10].[uspPayments_delete];
GO
IF OBJECT_ID('[s10].[uspPayments_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s10].[uspPayments_insert];
GO
IF OBJECT_ID('[s10].[uspPayments_update]', 'P') IS NOT NULL
DROP PROCEDURE [s10].[uspPayments_update];
GO

IF OBJECT_ID('[s10].[viewPayments]', 'V') IS NOT NULL
DROP VIEW [s10].[viewPayments];
GO

IF OBJECT_ID('[s10].[Accounts]', 'U') IS NOT NULL
DROP TABLE [s10].[Accounts];
GO
IF OBJECT_ID('[s10].[Companies]', 'U') IS NOT NULL
DROP TABLE [s10].[Companies];
GO
IF OBJECT_ID('[s10].[Items]', 'U') IS NOT NULL
DROP TABLE [s10].[Items];
GO
IF OBJECT_ID('[s10].[Payments]', 'U') IS NOT NULL
DROP TABLE [s10].[Payments];
GO

IF SCHEMA_ID('s10') IS NOT NULL
DROP SCHEMA [s10];
GO


IF DATABASE_PRINCIPAL_ID('sample10_user1') IS NOT NULL
DROP USER [sample10_user1];
GO

print 'Application removed';
