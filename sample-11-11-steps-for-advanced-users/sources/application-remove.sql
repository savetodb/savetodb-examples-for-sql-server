-- =============================================
-- Application: Sample 11 - 11 Steps for Advanced Users
-- Version 10.8, January 9, 2023
--
-- Copyright 2019-2023 Sergey Vaselenko
--
-- License: MIT
-- =============================================

SET NOCOUNT ON;
GO


IF OBJECT_ID('[s11].[Companies]', 'U') IS NOT NULL
DROP TABLE [s11].[Companies];
GO
IF OBJECT_ID('[s11].[formats]', 'U') IS NOT NULL
DROP TABLE [s11].[formats];
GO
IF OBJECT_ID('[s11].[handlers]', 'U') IS NOT NULL
DROP TABLE [s11].[handlers];
GO
IF OBJECT_ID('[s11].[Payments]', 'U') IS NOT NULL
DROP TABLE [s11].[Payments];
GO


DECLARE @sql nvarchar(max) = ''

SELECT
    @sql = @sql + 'ALTER ROLE ' + QUOTENAME(r.name) + ' DROP MEMBER ' + QUOTENAME(m.name) + ';' + CHAR(13) + CHAR(10)
FROM
    sys.database_role_members rm
    INNER JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
    INNER JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE
    r.name IN ('sample11_Alex_Team')

IF LEN(@sql) > 1
    BEGIN
    EXEC (@sql);
    PRINT @sql
    END
GO

IF DATABASE_PRINCIPAL_ID('sample11_Alex_Team') IS NOT NULL
DROP ROLE [sample11_Alex_Team];
GO

IF SCHEMA_ID('s11') IS NOT NULL
DROP SCHEMA [s11];
GO


IF DATABASE_PRINCIPAL_ID('sample11_Alex') IS NOT NULL
DROP USER [sample11_Alex];
GO
IF DATABASE_PRINCIPAL_ID('sample11_Lora') IS NOT NULL
DROP USER [sample11_Lora];
GO
IF DATABASE_PRINCIPAL_ID('sample11_Nick') IS NOT NULL
DROP USER [sample11_Nick];
GO

print 'Application removed';
