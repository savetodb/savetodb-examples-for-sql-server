-- =============================================
-- Application: Sample 06 - Dynamic Lists
-- Version 10.8, January 9, 2023
--
-- Copyright 2018-2023 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample06_user1 FOR LOGIN sample06_user1 WITH DEFAULT_SCHEMA=s06;
GO


IF DATABASE_PRINCIPAL_ID('xls_users') IS NOT NULL
    EXEC sp_addrolemember N'xls_users', N'sample06_user1';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s06   TO sample06_user1;
