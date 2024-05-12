-- =============================================
-- Application: Sample 16 - Symbol lists
-- Version 10.13, April 29, 2024
--
-- Copyright 2019-2024 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON;
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s16].[FK_list_symbols_lists]') AND parent_object_id = OBJECT_ID(N'[s16].[list_symbols]'))
    ALTER TABLE [s16].[list_symbols] DROP CONSTRAINT [FK_list_symbols_lists];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s16].[FK_list_symbols_symbols]') AND parent_object_id = OBJECT_ID(N'[s16].[list_symbols]'))
    ALTER TABLE [s16].[list_symbols] DROP CONSTRAINT [FK_list_symbols_symbols];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s16].[FK_scheduled_lists_lists]') AND parent_object_id = OBJECT_ID(N'[s16].[scheduled_lists]'))
    ALTER TABLE [s16].[scheduled_lists] DROP CONSTRAINT [FK_scheduled_lists_lists];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s16].[FK_scheduled_lists_providers]') AND parent_object_id = OBJECT_ID(N'[s16].[scheduled_lists]'))
    ALTER TABLE [s16].[scheduled_lists] DROP CONSTRAINT [FK_scheduled_lists_providers];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s16].[FK_scheduled_lists_schedulers]') AND parent_object_id = OBJECT_ID(N'[s16].[scheduled_lists]'))
    ALTER TABLE [s16].[scheduled_lists] DROP CONSTRAINT [FK_scheduled_lists_schedulers];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s16].[FK_symbols_exchanges]') AND parent_object_id = OBJECT_ID(N'[s16].[symbols]'))
    ALTER TABLE [s16].[symbols] DROP CONSTRAINT [FK_symbols_exchanges];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s16].[FK_symbols_symbol_types]') AND parent_object_id = OBJECT_ID(N'[s16].[symbols]'))
    ALTER TABLE [s16].[symbols] DROP CONSTRAINT [FK_symbols_symbol_types];
GO

IF OBJECT_ID('[s16].[usp_scheduled_lists]', 'P') IS NOT NULL
DROP PROCEDURE [s16].[usp_scheduled_lists];
GO
IF OBJECT_ID('[s16].[usp_scheduled_lists_change]', 'P') IS NOT NULL
DROP PROCEDURE [s16].[usp_scheduled_lists_change];
GO
IF OBJECT_ID('[s16].[usp_symbol_lists]', 'P') IS NOT NULL
DROP PROCEDURE [s16].[usp_symbol_lists];
GO
IF OBJECT_ID('[s16].[usp_symbol_lists_change]', 'P') IS NOT NULL
DROP PROCEDURE [s16].[usp_symbol_lists_change];
GO

IF OBJECT_ID('[s16].[view_index]', 'V') IS NOT NULL
DROP VIEW [s16].[view_index];
GO
IF OBJECT_ID('[s16].[xl_app_handlers]', 'V') IS NOT NULL
DROP VIEW [s16].[xl_app_handlers];
GO

IF OBJECT_ID('[s16].[exchanges]', 'U') IS NOT NULL
DROP TABLE [s16].[exchanges];
GO
IF OBJECT_ID('[s16].[list_symbols]', 'U') IS NOT NULL
DROP TABLE [s16].[list_symbols];
GO
IF OBJECT_ID('[s16].[lists]', 'U') IS NOT NULL
DROP TABLE [s16].[lists];
GO
IF OBJECT_ID('[s16].[providers]', 'U') IS NOT NULL
DROP TABLE [s16].[providers];
GO
IF OBJECT_ID('[s16].[scheduled_lists]', 'U') IS NOT NULL
DROP TABLE [s16].[scheduled_lists];
GO
IF OBJECT_ID('[s16].[schedulers]', 'U') IS NOT NULL
DROP TABLE [s16].[schedulers];
GO
IF OBJECT_ID('[s16].[symbol_types]', 'U') IS NOT NULL
DROP TABLE [s16].[symbol_types];
GO
IF OBJECT_ID('[s16].[symbols]', 'U') IS NOT NULL
DROP TABLE [s16].[symbols];
GO

IF SCHEMA_ID('s16') IS NOT NULL
DROP SCHEMA [s16];
GO


IF DATABASE_PRINCIPAL_ID('sample16_user1') IS NOT NULL
DROP USER [sample16_user1];
GO

print 'Application removed';
