-- =============================================
-- Application: Sample 10 - 10 Steps for Developers
-- Version 10.13, April 29, 2024
--
-- Copyright 2019-2024 Sergey Vaselenko
--
-- License: MIT
-- =============================================

CREATE USER sample10_user1 FOR LOGIN sample10_user1 WITH DEFAULT_SCHEMA=s10;
GO


IF DATABASE_PRINCIPAL_ID('xls_developers') IS NOT NULL
    EXEC sp_addrolemember N'xls_developers', N'sample10_user1';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s10   TO sample10_user1;
