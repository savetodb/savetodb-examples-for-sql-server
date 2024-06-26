-- =============================================
-- Application: Sample 09 - Outlook Integration
-- Version 10.13, April 29, 2024
--
-- Copyright 2018-2024 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample09_user1 FOR LOGIN sample09_user1 WITH DEFAULT_SCHEMA=s09;
GO


GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s09   TO sample09_user1;
