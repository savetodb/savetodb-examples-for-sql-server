-- =============================================
-- Application: Sample 14 - Dynamic Columns
-- Version 10.8, January 9, 2023
--
-- Copyright 2019-2023 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample14_user1 FOR LOGIN sample14_user1 WITH DEFAULT_SCHEMA=s14;
GO

CREATE USER sample14_user2 FOR LOGIN sample14_user2 WITH DEFAULT_SCHEMA=s14;
GO

CREATE USER sample14_user3 FOR LOGIN sample14_user3 WITH DEFAULT_SCHEMA=s14;
GO


IF DATABASE_PRINCIPAL_ID('xls_users') IS NOT NULL
    EXEC sp_addrolemember N'xls_users', N'sample14_user1';

IF DATABASE_PRINCIPAL_ID('xls_users') IS NOT NULL
    EXEC sp_addrolemember N'xls_users', N'sample14_user2';

IF DATABASE_PRINCIPAL_ID('xls_users') IS NOT NULL
    EXEC sp_addrolemember N'xls_users', N'sample14_user3';

GRANT SELECT ON s14.dimensions              TO sample14_user1;

GRANT SELECT ON s14.view_aliases            TO sample14_user1;

GRANT SELECT ON s14.view_data               TO sample14_user1;

GRANT SELECT ON s14.view_members            TO sample14_user1;

GRANT SELECT ON s14.xl_list_client_id       TO sample14_user1;

GRANT EXECUTE ON s14.view_data_delete        TO sample14_user1;

GRANT EXECUTE ON s14.view_data_insert        TO sample14_user1;

GRANT EXECUTE ON s14.view_data_update        TO sample14_user1;

GRANT EXECUTE ON s14.view_members_delete     TO sample14_user1;

GRANT EXECUTE ON s14.view_members_insert     TO sample14_user1;

GRANT EXECUTE ON s14.view_members_update     TO sample14_user1;

GRANT EXECUTE ON s14.xl_list_member_id1      TO sample14_user1;

GRANT EXECUTE ON s14.xl_list_member_id2      TO sample14_user1;

GRANT EXECUTE ON s14.xl_list_member_id3      TO sample14_user1;

GRANT SELECT ON s14.dimensions              TO sample14_user2;

GRANT SELECT ON s14.view_aliases            TO sample14_user2;

GRANT SELECT ON s14.view_data               TO sample14_user2;

GRANT SELECT ON s14.view_members            TO sample14_user2;

GRANT SELECT ON s14.xl_list_client_id       TO sample14_user2;

GRANT EXECUTE ON s14.view_data_delete        TO sample14_user2;

GRANT EXECUTE ON s14.view_data_insert        TO sample14_user2;

GRANT EXECUTE ON s14.view_data_update        TO sample14_user2;

GRANT EXECUTE ON s14.view_members_delete     TO sample14_user2;

GRANT EXECUTE ON s14.view_members_insert     TO sample14_user2;

GRANT EXECUTE ON s14.view_members_update     TO sample14_user2;

GRANT EXECUTE ON s14.xl_list_member_id1      TO sample14_user2;

GRANT EXECUTE ON s14.xl_list_member_id2      TO sample14_user2;

GRANT EXECUTE ON s14.xl_list_member_id3      TO sample14_user2;

GRANT SELECT ON s14.dimensions              TO sample14_user3;

GRANT SELECT ON s14.view_aliases            TO sample14_user3;

GRANT SELECT ON s14.view_data               TO sample14_user3;

GRANT SELECT ON s14.view_members            TO sample14_user3;

GRANT SELECT ON s14.xl_list_client_id       TO sample14_user3;

GRANT EXECUTE ON s14.view_data_delete        TO sample14_user3;

GRANT EXECUTE ON s14.view_data_insert        TO sample14_user3;

GRANT EXECUTE ON s14.view_data_update        TO sample14_user3;

GRANT EXECUTE ON s14.view_members_delete     TO sample14_user3;

GRANT EXECUTE ON s14.view_members_insert     TO sample14_user3;

GRANT EXECUTE ON s14.view_members_update     TO sample14_user3;

GRANT EXECUTE ON s14.xl_list_member_id1      TO sample14_user3;

GRANT EXECUTE ON s14.xl_list_member_id2      TO sample14_user3;

GRANT EXECUTE ON s14.xl_list_member_id3      TO sample14_user3;

