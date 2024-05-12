-- =============================================
-- Application: Sample 17 - Budget Request
-- Version 10.13, April 29, 2024
--
-- Copyright 2019-2024 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample17_user1 FOR LOGIN sample17_user1 WITH DEFAULT_SCHEMA=s17;
GO


IF DATABASE_PRINCIPAL_ID('xls_users') IS NOT NULL
    EXEC sp_addrolemember N'xls_users', N'sample17_user1';

IF DATABASE_PRINCIPAL_ID('xls_formats') IS NOT NULL
    EXEC sp_addrolemember N'xls_formats', N'sample17_user1';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s17   TO sample17_user1;
