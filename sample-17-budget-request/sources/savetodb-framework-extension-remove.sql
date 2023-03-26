-- =============================================
-- SaveToDB Framework Extension for Microsoft SQL Server
-- Version 10.8, January 9, 2023
--
-- Copyright 2022-2023 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON
GO

DELETE FROM xls.formats   WHERE TABLE_SCHEMA = 'xls' AND TABLE_NAME IN ('view_columns', 'view_formats', 'view_handlers', 'view_objects', 'view_queries', 'view_translations', 'view_workbooks');
DELETE FROM xls.handlers  WHERE TABLE_SCHEMA = 'xls' AND TABLE_NAME IN ('view_columns', 'view_formats', 'view_handlers', 'view_objects', 'view_queries', 'view_translations', 'view_workbooks', 'savetodb_framework_extension');
DELETE FROM xls.workbooks WHERE TABLE_SCHEMA = 'xls' AND NAME IN ('savetodb_user_configuration.xlsx');

DELETE FROM xls.handlers  WHERE TABLE_SCHEMA = 'xls' AND TABLE_NAME = 'users' AND HANDLER_NAME IN ('xl_actions_set_framework_10_mode', 'xl_actions_set_framework_9_mode', 'xl_actions_set_extended_role_permissions', 'xl_actions_revoke_extended_role_permissions');
GO

DECLARE @id int

SET @id = COALESCE((SELECT MAX(ID) FROM xls.formats), 0);

DBCC CHECKIDENT ('xls.formats', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM xls.handlers), 0);

DBCC CHECKIDENT ('xls.handlers', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM xls.workbooks), 0);

DBCC CHECKIDENT ('xls.workbooks', RESEED, @id) WITH NO_INFOMSGS;
GO


IF OBJECT_ID('[xls].[xl_actions_set_framework_10_mode]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_actions_set_framework_10_mode];
GO
IF OBJECT_ID('[xls].[xl_actions_set_framework_9_mode]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_actions_set_framework_9_mode];
GO
IF OBJECT_ID('[xls].[xl_actions_set_extended_role_permissions]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_actions_set_extended_role_permissions];
GO
IF OBJECT_ID('[xls].[xl_actions_revoke_extended_role_permissions]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_actions_revoke_extended_role_permissions];
GO
IF OBJECT_ID('[xls].[xl_update_table_format]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_update_table_format];
GO

IF OBJECT_ID('[xls].[view_columns]', 'V') IS NOT NULL
DROP VIEW [xls].[view_columns];
GO
IF OBJECT_ID('[xls].[view_formats]', 'V') IS NOT NULL
DROP VIEW [xls].[view_formats];
GO
IF OBJECT_ID('[xls].[view_handlers]', 'V') IS NOT NULL
DROP VIEW [xls].[view_handlers];
GO
IF OBJECT_ID('[xls].[view_objects]', 'V') IS NOT NULL
DROP VIEW [xls].[view_objects];
GO
IF OBJECT_ID('[xls].[view_queries]', 'V') IS NOT NULL
DROP VIEW [xls].[view_queries];
GO
IF OBJECT_ID('[xls].[view_translations]', 'V') IS NOT NULL
DROP VIEW [xls].[view_translations];
GO
IF OBJECT_ID('[xls].[view_workbooks]', 'V') IS NOT NULL
DROP VIEW [xls].[view_workbooks];
GO

print 'SaveToDB Framework Extension removed';
