-- =============================================
-- Application: Sample 05 - Invoices
-- Version 10.13, April 29, 2024
--
-- Copyright 2018-2024 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample05_user1 FOR LOGIN sample05_user1 WITH DEFAULT_SCHEMA=s05;
GO


IF DATABASE_PRINCIPAL_ID('xls_users') IS NOT NULL
    EXEC sp_addrolemember N'xls_users', N'sample05_user1';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s05   TO sample05_user1;
