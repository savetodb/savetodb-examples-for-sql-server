-- =============================================
-- Application: Sample 16 - Symbol lists
-- Version 10.13, April 29, 2024
--
-- Copyright 2019-2024 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample16_user1 FOR LOGIN sample16_user1 WITH DEFAULT_SCHEMA=s16;
GO


GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s16   TO sample16_user1;
