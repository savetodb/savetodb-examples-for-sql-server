-- =============================================
-- Application: Sample 02 - Advanced SaveToDB Features
-- Version 10.13, April 29, 2024
--
-- Copyright 2017-2024 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample02_user1 FOR LOGIN sample02_user1 WITH DEFAULT_SCHEMA=s02;
GO

CREATE USER sample02_user2 FOR LOGIN sample02_user2 WITH DEFAULT_SCHEMA=s02;
GO

CREATE USER sample02_user3 FOR LOGIN sample02_user3 WITH DEFAULT_SCHEMA=s02;
GO

CREATE USER sample02_user5 FOR LOGIN sample02_user5 WITH DEFAULT_SCHEMA=s02;
GO

CREATE USER sample02_user6 FOR LOGIN sample02_user6 WITH DEFAULT_SCHEMA=s02;
GO


IF DATABASE_PRINCIPAL_ID('xls_users') IS NOT NULL
    EXEC sp_addrolemember N'xls_users', N'sample02_user3';

IF DATABASE_PRINCIPAL_ID('xls_developers') IS NOT NULL
    EXEC sp_addrolemember N'xls_developers', N'sample02_user5';

IF DATABASE_PRINCIPAL_ID('xls_users') IS NOT NULL
    EXEC sp_addrolemember N'xls_users', N'sample02_user6';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s02   TO sample02_user1;

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE                  ON SCHEMA::s02   TO sample02_user2;

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE                  ON SCHEMA::s02   TO sample02_user3;

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s02   TO sample02_user5;

GRANT VIEW DEFINITION ON USER::sample02_user1         TO sample02_user6;

GRANT VIEW DEFINITION ON USER::sample02_user2         TO sample02_user6;

GRANT VIEW DEFINITION ON USER::sample02_user3         TO sample02_user6;

GRANT VIEW DEFINITION ON USER::sample02_user5         TO sample02_user6;

GRANT VIEW DEFINITION ON SCHEMA::s02   TO sample02_user6;


IF DATABASE_PRINCIPAL_ID('xls_admins') IS NOT NULL
    EXEC sp_addrolemember N'xls_admins', N'sample02_user6';
