-- =============================================
-- Application: Sample 01 - Basic SaveToDB Features
-- Version 10.6, December 13, 2022
--
-- Copyright 2011-2022 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample01_user1 FOR LOGIN sample01_user1 WITH DEFAULT_SCHEMA=s01;
GO

CREATE USER sample01_user2 FOR LOGIN sample01_user2 WITH DEFAULT_SCHEMA=s01;
GO


GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s01   TO sample01_user1;

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE                  ON SCHEMA::s01   TO sample01_user2;

