-- =============================================
-- Application: Sample 12 - Using JSON
-- Version 10.13, April 29, 2024
--
-- Copyright 2018-2024 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample12_user1 FOR LOGIN sample12_user1 WITH DEFAULT_SCHEMA=s12;
GO


GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s12   TO sample12_user1;
