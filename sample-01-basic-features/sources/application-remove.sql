-- =============================================
-- Application: Sample 01 - Basic SaveToDB Features
-- Version 10.13, April 29, 2024
--
-- Copyright 2011-2024 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON;
GO

IF OBJECT_ID('[s01].[usp_cash_by_months]', 'P') IS NOT NULL
DROP PROCEDURE [s01].[usp_cash_by_months];
GO
IF OBJECT_ID('[s01].[usp_cash_by_months_change]', 'P') IS NOT NULL
DROP PROCEDURE [s01].[usp_cash_by_months_change];
GO
IF OBJECT_ID('[s01].[usp_cashbook]', 'P') IS NOT NULL
DROP PROCEDURE [s01].[usp_cashbook];
GO
IF OBJECT_ID('[s01].[usp_cashbook2]', 'P') IS NOT NULL
DROP PROCEDURE [s01].[usp_cashbook2];
GO
IF OBJECT_ID('[s01].[usp_cashbook2_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s01].[usp_cashbook2_delete];
GO
IF OBJECT_ID('[s01].[usp_cashbook2_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s01].[usp_cashbook2_insert];
GO
IF OBJECT_ID('[s01].[usp_cashbook2_update]', 'P') IS NOT NULL
DROP PROCEDURE [s01].[usp_cashbook2_update];
GO
IF OBJECT_ID('[s01].[usp_cashbook3]', 'P') IS NOT NULL
DROP PROCEDURE [s01].[usp_cashbook3];
GO
IF OBJECT_ID('[s01].[usp_cashbook3_change]', 'P') IS NOT NULL
DROP PROCEDURE [s01].[usp_cashbook3_change];
GO
IF OBJECT_ID('[s01].[usp_cashbook4]', 'P') IS NOT NULL
DROP PROCEDURE [s01].[usp_cashbook4];
GO
IF OBJECT_ID('[s01].[usp_cashbook4_merge]', 'P') IS NOT NULL
DROP PROCEDURE [s01].[usp_cashbook4_merge];
GO

IF OBJECT_ID('[s01].[view_cashbook]', 'V') IS NOT NULL
DROP VIEW [s01].[view_cashbook];
GO
IF OBJECT_ID('[s01].[xl_actions_online_help]', 'V') IS NOT NULL
DROP VIEW [s01].[xl_actions_online_help];
GO

IF OBJECT_ID('[s01].[cashbook]', 'U') IS NOT NULL
DROP TABLE [s01].[cashbook];
GO
IF OBJECT_ID('[s01].[formats]', 'U') IS NOT NULL
DROP TABLE [s01].[formats];
GO
IF OBJECT_ID('[s01].[workbooks]', 'U') IS NOT NULL
DROP TABLE [s01].[workbooks];
GO

IF SCHEMA_ID('s01') IS NOT NULL
DROP SCHEMA [s01];
GO


IF DATABASE_PRINCIPAL_ID('sample01_user1') IS NOT NULL
DROP USER [sample01_user1];
GO
IF DATABASE_PRINCIPAL_ID('sample01_user2') IS NOT NULL
DROP USER [sample01_user2];
GO

print 'Application removed';
