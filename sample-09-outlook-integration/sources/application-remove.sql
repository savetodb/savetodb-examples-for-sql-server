-- =============================================
-- Application: Sample 09 - Outlook Integration
-- Version 10.6, December 13, 2022
--
-- Copyright 2018-2022 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON;
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s09].[FK_Appointments_BusyStatus]') AND parent_object_id = OBJECT_ID(N'[s09].[Appointments]'))
    ALTER TABLE [s09].[Appointments] DROP CONSTRAINT [FK_Appointments_BusyStatus];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s09].[FK_Appointments_Categories]') AND parent_object_id = OBJECT_ID(N'[s09].[Appointments]'))
    ALTER TABLE [s09].[Appointments] DROP CONSTRAINT [FK_Appointments_Categories];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s09].[FK_Emails_Categories]') AND parent_object_id = OBJECT_ID(N'[s09].[Emails]'))
    ALTER TABLE [s09].[Emails] DROP CONSTRAINT [FK_Emails_Categories];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s09].[FK_Tasks_Categories]') AND parent_object_id = OBJECT_ID(N'[s09].[Tasks]'))
    ALTER TABLE [s09].[Tasks] DROP CONSTRAINT [FK_Tasks_Categories];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s09].[FK_Tasks_Importance]') AND parent_object_id = OBJECT_ID(N'[s09].[Tasks]'))
    ALTER TABLE [s09].[Tasks] DROP CONSTRAINT [FK_Tasks_Importance];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s09].[FK_Tasks_TaskStatus]') AND parent_object_id = OBJECT_ID(N'[s09].[Tasks]'))
    ALTER TABLE [s09].[Tasks] DROP CONSTRAINT [FK_Tasks_TaskStatus];
GO


IF OBJECT_ID('[s09].[Appointments]', 'U') IS NOT NULL
DROP TABLE [s09].[Appointments];
GO
IF OBJECT_ID('[s09].[BusyStatus]', 'U') IS NOT NULL
DROP TABLE [s09].[BusyStatus];
GO
IF OBJECT_ID('[s09].[Categories]', 'U') IS NOT NULL
DROP TABLE [s09].[Categories];
GO
IF OBJECT_ID('[s09].[Emails]', 'U') IS NOT NULL
DROP TABLE [s09].[Emails];
GO
IF OBJECT_ID('[s09].[Importance]', 'U') IS NOT NULL
DROP TABLE [s09].[Importance];
GO
IF OBJECT_ID('[s09].[Tasks]', 'U') IS NOT NULL
DROP TABLE [s09].[Tasks];
GO
IF OBJECT_ID('[s09].[TaskStatus]', 'U') IS NOT NULL
DROP TABLE [s09].[TaskStatus];
GO

IF SCHEMA_ID('s09') IS NOT NULL
DROP SCHEMA [s09];
GO


IF DATABASE_PRINCIPAL_ID('sample09_user1') IS NOT NULL
DROP USER [sample09_user1];
GO

print 'Application removed';
