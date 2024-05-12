-- =============================================
-- Application: Sample 20 - Cube App
-- Version 10.13, April 29, 2024
--
-- Copyright 2020-2024 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample20_user1 FOR LOGIN sample20_user1 WITH DEFAULT_SCHEMA=s20;
GO

CREATE USER sample20_user2 FOR LOGIN sample20_user2 WITH DEFAULT_SCHEMA=s20;
GO


IF DATABASE_PRINCIPAL_ID('xls_users') IS NOT NULL
    EXEC sp_addrolemember N'xls_users', N'sample20_user1';

IF DATABASE_PRINCIPAL_ID('xls_users') IS NOT NULL
    EXEC sp_addrolemember N'xls_users', N'sample20_user2';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s20   TO sample20_user1;

GRANT SELECT ON s20.xl_list_category_id     TO sample20_user2;

GRANT SELECT ON s20.xl_list_entity_id       TO sample20_user2;

GRANT EXECUTE ON s20.usp_form_01             TO sample20_user2;

GRANT EXECUTE ON s20.usp_form_01_change      TO sample20_user2;

GRANT EXECUTE ON s20.usp_web_form_01         TO sample20_user2;

GRANT EXECUTE ON s20.usp_web_form_01_change  TO sample20_user2;

