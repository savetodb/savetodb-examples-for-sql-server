-- =============================================
-- Application: Sample 04 - Orders
-- Version 10.13, April 29, 2024
--
-- Copyright 2014-2024 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample04_user1 FOR LOGIN sample04_user1 WITH DEFAULT_SCHEMA=s04;
GO


IF DATABASE_PRINCIPAL_ID('xls_users') IS NOT NULL
    EXEC sp_addrolemember N'xls_users', N'sample04_user1';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s04   TO sample04_user1;
