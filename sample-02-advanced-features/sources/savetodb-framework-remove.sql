-- =============================================
-- SaveToDB Framework for Microsoft SQL Server
-- Version 10.8, January 9, 2023
--
-- This code removes SaveToDB Administrator Framework and SaveToDB Developer Framework also
-- as the frameworks require SaveToDB Framework.
--
-- Copyright 2011-2023 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON
GO

-- Removing SaveToDB Developer Framework

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
IF OBJECT_ID('[xls].[xl_actions_set_role_permissions]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_actions_set_role_permissions];
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

-- Removing SaveToDB Administrator Framework

IF OBJECT_ID('[xls].[usp_database_permissions]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[usp_database_permissions];
GO
IF OBJECT_ID('[xls].[usp_database_permissions_change]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[usp_database_permissions_change];
GO
IF OBJECT_ID('[xls].[usp_object_permissions]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[usp_object_permissions];
GO
IF OBJECT_ID('[xls].[usp_object_permissions_change]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[usp_object_permissions_change];
GO
IF OBJECT_ID('[xls].[usp_principal_permissions]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[usp_principal_permissions];
GO
IF OBJECT_ID('[xls].[usp_principal_permissions_change]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[usp_principal_permissions_change];
GO
IF OBJECT_ID('[xls].[usp_role_members]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[usp_role_members];
GO
IF OBJECT_ID('[xls].[usp_role_members_change]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[usp_role_members_change];
GO
IF OBJECT_ID('[xls].[xl_parameter_values_principal]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_parameter_values_principal];
GO
IF OBJECT_ID('[xls].[xl_parameter_values_schema]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_parameter_values_schema];
GO

-- Removing SaveToDB Framework

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
IF OBJECT_ID('[xls].[xl_actions_set_role_permissions]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_actions_set_role_permissions];
GO
IF OBJECT_ID('[xls].[xl_update_table_format]', 'P') IS NOT NULL
DROP PROCEDURE [xls].[xl_update_table_format];
GO

IF OBJECT_ID('[xls].[queries]', 'V') IS NOT NULL
DROP VIEW [xls].[queries];
GO
IF OBJECT_ID('[xls].[users]', 'V') IS NOT NULL
DROP VIEW [xls].[users];
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

IF OBJECT_ID('[xls].[columns]', 'U') IS NOT NULL
DROP TABLE [xls].[columns];
GO
IF OBJECT_ID('[xls].[formats]', 'U') IS NOT NULL
DROP TABLE [xls].[formats];
GO
IF OBJECT_ID('[xls].[handlers]', 'U') IS NOT NULL
DROP TABLE [xls].[handlers];
GO
IF OBJECT_ID('[xls].[objects]', 'U') IS NOT NULL
DROP TABLE [xls].[objects];
GO
IF OBJECT_ID('[xls].[translations]', 'U') IS NOT NULL
DROP TABLE [xls].[translations];
GO
IF OBJECT_ID('[xls].[workbooks]', 'U') IS NOT NULL
DROP TABLE [xls].[workbooks];
GO


DECLARE @sql nvarchar(max) = ''

SELECT
    @sql = @sql + 'ALTER ROLE ' + QUOTENAME(r.name) + ' DROP MEMBER ' + QUOTENAME(m.name) + ';' + CHAR(13) + CHAR(10)
FROM
    sys.database_role_members rm
    INNER JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
    INNER JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE
    r.name IN ('xls_admins', 'xls_developers', 'xls_formats', 'xls_users')

IF LEN(@sql) > 1
    BEGIN
    EXEC (@sql);
    PRINT @sql
    END
GO

IF DATABASE_PRINCIPAL_ID('xls_admins') IS NOT NULL
DROP ROLE [xls_admins];
GO
IF DATABASE_PRINCIPAL_ID('xls_developers') IS NOT NULL
DROP ROLE [xls_developers];
GO
IF DATABASE_PRINCIPAL_ID('xls_formats') IS NOT NULL
DROP ROLE [xls_formats];
GO
IF DATABASE_PRINCIPAL_ID('xls_users') IS NOT NULL
DROP ROLE [xls_users];
GO

IF SCHEMA_ID('xls') IS NOT NULL
DROP SCHEMA [xls];
GO

print 'SaveToDB Framework removed';
