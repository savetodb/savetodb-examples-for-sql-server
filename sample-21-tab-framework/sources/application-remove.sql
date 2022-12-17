-- =============================================
-- Application: Sample 21 - Tab Framework
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
    r.name IN ('xls_admins', 'xls_developers', 'xls_formats', 'xls_users', 'tab_developers', 'tab_users')
    AND m.name LIKE 'sample21_user%'

IF LEN(@sql) > 1
    BEGIN
    EXEC (@sql);
    PRINT @sql
    END
GO

DELETE FROM tab.formats   WHERE TABLE_SCHEMA IN (N's21');
DELETE FROM tab.workbooks WHERE TABLE_SCHEMA IN (N's21');

DELETE FROM tab.translations WHERE row_id IN    (SELECT r.id FROM tab.rows r INNER JOIN tab.tables t ON t.id = r.table_id WHERE t.table_schema = 's21');
DELETE FROM tab.translations WHERE column_id IN (SELECT c.id FROM tab.columns c INNER JOIN tab.tables t ON t.id = c.table_id WHERE t.table_schema = 's21');
DELETE FROM tab.translations WHERE row_id IN    (SELECT t.id FROM tab.tables t WHERE t.table_schema = 's21');

DELETE FROM tab.rows    WHERE table_id IN (SELECT t.id FROM tab.tables t WHERE t.table_schema = 's21');
DELETE FROM tab.columns WHERE table_id IN (SELECT t.id FROM tab.tables t WHERE t.table_schema = 's21');
DELETE FROM tab.tables  WHERE t.table_schema = 's21';

DELETE FROM tab.languages;
GO

DECLARE @id int

SET @id = COALESCE((SELECT MAX(ID) FROM tab.formats), 0);

DBCC CHECKIDENT ('tab.formats', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM tab.workbooks), 0);

DBCC CHECKIDENT ('tab.workbooks', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM tab.handlers), 0);

DBCC CHECKIDENT ('tab.tables', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM tab.columns), 0);

DBCC CHECKIDENT ('tab.columns', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM tab.rows), 0);

DBCC CHECKIDENT ('tab.rows', RESEED, @id) WITH NO_INFOMSGS;
GO


IF DATABASE_PRINCIPAL_ID('sample21_user1') IS NOT NULL
DROP USER [sample21_user1];
GO
IF DATABASE_PRINCIPAL_ID('sample21_user2') IS NOT NULL
DROP USER [sample21_user2];
GO

print 'Application removed';
