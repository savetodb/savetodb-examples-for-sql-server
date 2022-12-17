-- =============================================
-- Application: Sample 08 - Northwind
-- Version 10.6, December 13, 2022
--
-- Copyright 2015-2022 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample08_user1 FOR LOGIN sample08_user1 WITH DEFAULT_SCHEMA=s08;
GO


IF DATABASE_PRINCIPAL_ID('xls_users') IS NOT NULL
    EXEC sp_addrolemember N'xls_users', N'sample08_user1';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s08   TO sample08_user1;
