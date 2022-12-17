-- =============================================
-- SaveToDB Developer Framework for Microsoft SQL Server
-- Version 10.6, December 13, 2022
--
-- Copyright 2018-2022 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON
GO

DELETE FROM xls.formats   WHERE TABLE_SCHEMA = 'xls' AND TABLE_NAME IN ('usp_translations', 'view_primary_keys', 'view_unique_keys', 'view_foreign_keys', 'view_all_translations');
DELETE FROM xls.handlers  WHERE TABLE_SCHEMA = 'xls' AND TABLE_NAME IN ('developer_framework', 'usp_translations', 'view_primary_keys', 'view_unique_keys', 'view_foreign_keys', 'view_all_translations');
DELETE FROM xls.objects   WHERE TABLE_SCHEMA = 'xls' AND TABLE_NAME IN ('view_all_translations');
DELETE FROM xls.workbooks WHERE TABLE_SCHEMA = 'xls' AND NAME IN ('savetodb_developer.xlsx');
GO

DECLARE @id int

SET @id = COALESCE((SELECT MAX(ID) FROM xls.formats), 0);

DBCC CHECKIDENT ('xls.formats', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM xls.handlers), 0);

DBCC CHECKIDENT ('xls.handlers', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM xls.objects), 0);

DBCC CHECKIDENT ('xls.objects', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM xls.translations), 0);

DBCC CHECKIDENT ('xls.translations', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM xls.workbooks), 0);

DBCC CHECKIDENT ('xls.workbooks', RESEED, @id) WITH NO_INFOMSGS;
GO

IF OBJECT_ID('[xls].[usp_translations]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[usp_translations];
GO
IF OBJECT_ID('[xls].[usp_translations_change]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[usp_translations_change];
GO
IF OBJECT_ID('[xls].[xl_actions_generate_constraints]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_actions_generate_constraints];
GO
IF OBJECT_ID('[xls].[xl_actions_generate_handlers]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_actions_generate_handlers];
GO
IF OBJECT_ID('[xls].[xl_actions_generate_procedures]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_actions_generate_procedures];
GO
IF OBJECT_ID('[xls].[xl_delete_translation]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_delete_translation];
GO
IF OBJECT_ID('[xls].[xl_export_settings]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_export_settings];
GO
IF OBJECT_ID('[xls].[xl_import_formats]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_import_formats];
GO
IF OBJECT_ID('[xls].[xl_import_handlers]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_import_handlers];
GO
IF OBJECT_ID('[xls].[xl_import_objects]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_import_objects];
GO
IF OBJECT_ID('[xls].[xl_import_translations]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_import_translations];
GO
IF OBJECT_ID('[xls].[xl_import_workbooks]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_import_workbooks];
GO

IF OBJECT_ID('[xls].[view_all_translations]', 'V') IS NOT NULL
DROP VIEW [xls].[view_all_translations];
GO
IF OBJECT_ID('[xls].[view_developer_handlers]', 'V') IS NOT NULL
DROP VIEW [xls].[view_developer_handlers];
GO
IF OBJECT_ID('[xls].[view_foreign_keys]', 'V') IS NOT NULL
DROP VIEW [xls].[view_foreign_keys];
GO
IF OBJECT_ID('[xls].[view_framework_objects]', 'V') IS NOT NULL
DROP VIEW [xls].[view_framework_objects];
GO
IF OBJECT_ID('[xls].[view_primary_keys]', 'V') IS NOT NULL
DROP VIEW [xls].[view_primary_keys];
GO
IF OBJECT_ID('[xls].[view_unique_keys]', 'V') IS NOT NULL
DROP VIEW [xls].[view_unique_keys];
GO

IF OBJECT_ID('[xls].[get_escaped_parameter_name]', 'FN') IS NOT NULL
DROP FUNCTION [xls].[get_escaped_parameter_name];
GO
IF OBJECT_ID('[xls].[get_friendly_column_name]', 'FN') IS NOT NULL
DROP FUNCTION [xls].[get_friendly_column_name];
GO
IF OBJECT_ID('[xls].[get_procedure_underlying_table]', 'FN') IS NOT NULL
DROP FUNCTION [xls].[get_procedure_underlying_table];
GO
IF OBJECT_ID('[xls].[get_translated_string]', 'FN') IS NOT NULL
DROP FUNCTION [xls].[get_translated_string];
GO
IF OBJECT_ID('[xls].[get_unescaped_parameter_name]', 'FN') IS NOT NULL
DROP FUNCTION [xls].[get_unescaped_parameter_name];
GO
IF OBJECT_ID('[xls].[get_view_underlying_table]', 'FN') IS NOT NULL
DROP FUNCTION [xls].[get_view_underlying_table];
GO

print 'SaveToDB Developer Framework removed';
