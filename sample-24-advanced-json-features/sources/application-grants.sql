-- =============================================
-- Application: Sample 24 - Advanced JSON Features
-- Version 10.13, April 29, 2024
--
-- Copyright 2021-2024 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample24_user1 FOR LOGIN sample24_user1 WITH DEFAULT_SCHEMA=s24;
GO


GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s24   TO sample24_user1;
