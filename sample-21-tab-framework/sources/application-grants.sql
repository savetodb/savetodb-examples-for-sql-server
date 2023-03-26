-- =============================================
-- Application: Sample 21 - Tab Framework
-- Version 10.8, January 9, 2023
--
-- Copyright 2021-2023 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample21_user1 FOR LOGIN sample21_user1 WITH DEFAULT_SCHEMA=tab;
GO

CREATE USER sample21_user2 FOR LOGIN sample21_user2 WITH DEFAULT_SCHEMA=tab;
GO

ALTER ROLE tab_developers   ADD MEMBER sample21_user1;

ALTER ROLE tab_users        ADD MEMBER sample21_user2;
GO

GRANT VIEW DEFINITION ON USER::sample21_user2         TO sample21_user1;
GO
