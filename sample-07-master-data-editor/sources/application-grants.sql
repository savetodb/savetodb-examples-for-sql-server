-- =============================================
-- Application: Sample 07 - Master Data Editor
-- Version 10.13, April 29, 2024
--
-- Copyright 2017-2024 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample07_user1 FOR LOGIN sample07_user1 WITH DEFAULT_SCHEMA=s07;
GO


GRANT SELECT, EXECUTE, VIEW DEFINITION ON SCHEMA::s07   TO sample07_user1;
