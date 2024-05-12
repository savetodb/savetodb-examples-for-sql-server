-- =============================================
-- Application: Sample 13 - Tests
-- Version 10.13, April 29, 2024
--
-- Copyright 2019-2024 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON;
GO

IF OBJECT_ID('[s13].[usp_datatypes]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_datatypes];
GO
IF OBJECT_ID('[s13].[usp_datatypes_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_datatypes_delete];
GO
IF OBJECT_ID('[s13].[usp_datatypes_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_datatypes_insert];
GO
IF OBJECT_ID('[s13].[usp_datatypes_update]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_datatypes_update];
GO
IF OBJECT_ID('[s13].[usp_odbc_datatypes]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_odbc_datatypes];
GO
IF OBJECT_ID('[s13].[usp_odbc_datatypes_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_odbc_datatypes_delete];
GO
IF OBJECT_ID('[s13].[usp_odbc_datatypes_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_odbc_datatypes_insert];
GO
IF OBJECT_ID('[s13].[usp_odbc_datatypes_update]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_odbc_datatypes_update];
GO
IF OBJECT_ID('[s13].[usp_parameters_test]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_parameters_test];
GO
IF OBJECT_ID('[s13].[usp_quotes]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_quotes];
GO
IF OBJECT_ID('[s13].[usp_quotes_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_quotes_delete];
GO
IF OBJECT_ID('[s13].[usp_quotes_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_quotes_insert];
GO
IF OBJECT_ID('[s13].[usp_quotes_update]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_quotes_update];
GO
IF OBJECT_ID('[s13].[usp_select_test_editable_rows]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_select_test_editable_rows];
GO
IF OBJECT_ID('[s13].[usp_select_test_editable_rows_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_select_test_editable_rows_delete];
GO
IF OBJECT_ID('[s13].[usp_select_test_editable_rows_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_select_test_editable_rows_insert];
GO
IF OBJECT_ID('[s13].[usp_select_test_editable_rows_update]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_select_test_editable_rows_update];
GO
IF OBJECT_ID('[s13].[usp_select_test_rows]', 'P') IS NOT NULL
DROP PROCEDURE [s13].[usp_select_test_rows];
GO

IF OBJECT_ID('[s13].[view_datatype_columns]', 'V') IS NOT NULL
DROP VIEW [s13].[view_datatype_columns];
GO
IF OBJECT_ID('[s13].[view_datatype_parameters]', 'V') IS NOT NULL
DROP VIEW [s13].[view_datatype_parameters];
GO

IF OBJECT_ID('[s13].[datatypes]', 'U') IS NOT NULL
DROP TABLE [s13].[datatypes];
GO
IF OBJECT_ID('[s13].[quotes]', 'U') IS NOT NULL
DROP TABLE [s13].[quotes];
GO

IF SCHEMA_ID('s13') IS NOT NULL
DROP SCHEMA [s13];
GO


IF DATABASE_PRINCIPAL_ID('sample13_user1') IS NOT NULL
DROP USER [sample13_user1];
GO

print 'Application removed';
