-- =============================================
-- Application: Sample 24 - Advanced JSON Features
-- Version 10.6, December 13, 2022
--
-- Copyright 2021-2022 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample24_user1 FOR LOGIN sample24_user1 WITH DEFAULT_SCHEMA=s24;
GO


GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s24   TO sample24_user1;
