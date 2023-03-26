-- =============================================
-- Application: Sample 06 - Dynamic Lists
-- Version 10.8, January 9, 2023
--
-- Copyright 2018-2023 Gartle LLC
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
    AND m.name LIKE 'sample06_user%'

IF LEN(@sql) > 1
    BEGIN
    EXEC (@sql);
    PRINT @sql
    END
GO

DELETE FROM [xls].[formats]                        WHERE TABLE_SCHEMA IN (N's06');
DELETE FROM [xls].[handlers]                       WHERE TABLE_SCHEMA IN (N's06');
DELETE FROM [xls].[objects]                        WHERE TABLE_SCHEMA IN (N's06');
DELETE FROM [xls].[translations]                   WHERE TABLE_SCHEMA IN (N's06');
DELETE FROM [xls].[workbooks]                      WHERE TABLE_SCHEMA IN (N's06');
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

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s06].[FK_data_countries]') AND parent_object_id = OBJECT_ID(N'[s06].[data]'))
    ALTER TABLE [s06].[data] DROP CONSTRAINT [FK_data_countries];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s06].[FK_data_states]') AND parent_object_id = OBJECT_ID(N'[s06].[data]'))
    ALTER TABLE [s06].[data] DROP CONSTRAINT [FK_data_states];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s06].[FK_states_countries]') AND parent_object_id = OBJECT_ID(N'[s06].[states]'))
    ALTER TABLE [s06].[states] DROP CONSTRAINT [FK_states_countries];
GO

IF OBJECT_ID('[s06].[usp_data]', 'P') IS NOT NULL
DROP PROCEDURE [s06].[usp_data];
GO

IF OBJECT_ID('[s06].[countries]', 'U') IS NOT NULL
DROP TABLE [s06].[countries];
GO
IF OBJECT_ID('[s06].[data]', 'U') IS NOT NULL
DROP TABLE [s06].[data];
GO
IF OBJECT_ID('[s06].[states]', 'U') IS NOT NULL
DROP TABLE [s06].[states];
GO

IF SCHEMA_ID('s06') IS NOT NULL
DROP SCHEMA [s06];
GO


IF DATABASE_PRINCIPAL_ID('sample06_user1') IS NOT NULL
DROP USER [sample06_user1];
GO

print 'Application removed';
