-- =============================================
-- Application: Sample 12 - Using JSON
-- Version 10.6, December 13, 2022
--
-- Copyright 2018-2022 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample12_user1 FOR LOGIN sample12_user1 WITH DEFAULT_SCHEMA=s12;
GO


GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s12   TO sample12_user1;
