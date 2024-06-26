-- =============================================
-- Application: Sample 03 - Budgeting Example
-- Version 10.13, April 29, 2024
--
-- Copyright 2019-2024 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample03_user1 FOR LOGIN sample03_user1 WITH DEFAULT_SCHEMA=s03;
GO


IF DATABASE_PRINCIPAL_ID('xls_users') IS NOT NULL
    EXEC sp_addrolemember N'xls_users', N'sample03_user1';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s03   TO sample03_user1;
