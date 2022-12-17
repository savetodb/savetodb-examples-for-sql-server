-- =============================================
-- Application: Sample 12 - Using JSON
-- Version 10.6, December 13, 2022
--
-- Copyright 2018-2022 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON;
GO

IF OBJECT_ID('[s12].[view_json_test_1_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_1_delete];
GO
IF OBJECT_ID('[s12].[view_json_test_1_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_1_insert];
GO
IF OBJECT_ID('[s12].[view_json_test_1_update]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_1_update];
GO
IF OBJECT_ID('[s12].[view_json_test_2_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_2_delete];
GO
IF OBJECT_ID('[s12].[view_json_test_2_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_2_insert];
GO
IF OBJECT_ID('[s12].[view_json_test_2_update]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_2_update];
GO
IF OBJECT_ID('[s12].[view_json_test_3_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_3_delete];
GO
IF OBJECT_ID('[s12].[view_json_test_3_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_3_insert];
GO
IF OBJECT_ID('[s12].[view_json_test_3_update]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_3_update];
GO
IF OBJECT_ID('[s12].[view_json_test_4_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_4_delete];
GO
IF OBJECT_ID('[s12].[view_json_test_4_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_4_insert];
GO
IF OBJECT_ID('[s12].[view_json_test_4_update]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_4_update];
GO
IF OBJECT_ID('[s12].[view_json_test_5_update]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_5_update];
GO
IF OBJECT_ID('[s12].[view_json_test_6_update]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_6_update];
GO
IF OBJECT_ID('[s12].[view_json_test_7_update]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_7_update];
GO
IF OBJECT_ID('[s12].[view_json_test_8_update]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_8_update];
GO
IF OBJECT_ID('[s12].[view_json_test_9_update]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_9_update];
GO
IF OBJECT_ID('[s12].[view_json_test_a_update]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_a_update];
GO
IF OBJECT_ID('[s12].[view_json_test_b_merge]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_b_merge];
GO
IF OBJECT_ID('[s12].[view_json_test_c_merge]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_c_merge];
GO
IF OBJECT_ID('[s12].[view_json_test_d_update]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[view_json_test_d_update];
GO
IF OBJECT_ID('[s12].[xl_actions_set_test_records]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[xl_actions_set_test_records];
GO
IF OBJECT_ID('[s12].[xl_actions_set_test_records_100k]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[xl_actions_set_test_records_100k];
GO
IF OBJECT_ID('[s12].[xl_actions_set_test_records_10k]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[xl_actions_set_test_records_10k];
GO
IF OBJECT_ID('[s12].[xl_actions_set_test_records_5]', 'P') IS NOT NULL
DROP PROCEDURE [s12].[xl_actions_set_test_records_5];
GO

IF OBJECT_ID('[s12].[view_json_test_0]', 'V') IS NOT NULL
DROP VIEW [s12].[view_json_test_0];
GO
IF OBJECT_ID('[s12].[view_json_test_1]', 'V') IS NOT NULL
DROP VIEW [s12].[view_json_test_1];
GO
IF OBJECT_ID('[s12].[view_json_test_2]', 'V') IS NOT NULL
DROP VIEW [s12].[view_json_test_2];
GO
IF OBJECT_ID('[s12].[view_json_test_3]', 'V') IS NOT NULL
DROP VIEW [s12].[view_json_test_3];
GO
IF OBJECT_ID('[s12].[view_json_test_4]', 'V') IS NOT NULL
DROP VIEW [s12].[view_json_test_4];
GO
IF OBJECT_ID('[s12].[view_json_test_5]', 'V') IS NOT NULL
DROP VIEW [s12].[view_json_test_5];
GO
IF OBJECT_ID('[s12].[view_json_test_6]', 'V') IS NOT NULL
DROP VIEW [s12].[view_json_test_6];
GO
IF OBJECT_ID('[s12].[view_json_test_7]', 'V') IS NOT NULL
DROP VIEW [s12].[view_json_test_7];
GO
IF OBJECT_ID('[s12].[view_json_test_8]', 'V') IS NOT NULL
DROP VIEW [s12].[view_json_test_8];
GO
IF OBJECT_ID('[s12].[view_json_test_9]', 'V') IS NOT NULL
DROP VIEW [s12].[view_json_test_9];
GO
IF OBJECT_ID('[s12].[view_json_test_a]', 'V') IS NOT NULL
DROP VIEW [s12].[view_json_test_a];
GO
IF OBJECT_ID('[s12].[view_json_test_b]', 'V') IS NOT NULL
DROP VIEW [s12].[view_json_test_b];
GO
IF OBJECT_ID('[s12].[view_json_test_c]', 'V') IS NOT NULL
DROP VIEW [s12].[view_json_test_c];
GO
IF OBJECT_ID('[s12].[view_json_test_d]', 'V') IS NOT NULL
DROP VIEW [s12].[view_json_test_d];
GO

IF OBJECT_ID('[s12].[json_test]', 'U') IS NOT NULL
DROP TABLE [s12].[json_test];
GO
IF OBJECT_ID('[s12].[objects]', 'U') IS NOT NULL
DROP TABLE [s12].[objects];
GO

IF SCHEMA_ID('s12') IS NOT NULL
DROP SCHEMA [s12];
GO


IF DATABASE_PRINCIPAL_ID('sample12_user1') IS NOT NULL
DROP USER [sample12_user1];
GO

print 'Application removed';
