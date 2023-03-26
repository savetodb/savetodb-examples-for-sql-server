-- =============================================
-- Application: Sample 09 - Outlook Integration
-- Version 10.8, January 9, 2023
--
-- Copyright 2018-2023 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON
GO

CREATE SCHEMA [s09];
GO

CREATE TABLE [s09].[BusyStatus] (
      [ID] tinyint NOT NULL
    , [BusyStatus] nvarchar(100) NOT NULL
    , CONSTRAINT [PK_BusyStatus] PRIMARY KEY ([ID])
    , CONSTRAINT [IX_BusyStatus_BusyStatus] UNIQUE ([BusyStatus])
);
GO

CREATE TABLE [s09].[Categories] (
      [ID] tinyint NOT NULL
    , [Categories] nvarchar(100) NOT NULL
    , CONSTRAINT [PK_Categories] PRIMARY KEY ([ID])
    , CONSTRAINT [IX_Categories_Category] UNIQUE ([Categories])
);
GO

CREATE TABLE [s09].[Importance] (
      [ID] tinyint NOT NULL
    , [Importance] nvarchar(100) NOT NULL
    , CONSTRAINT [PK_Importance] PRIMARY KEY ([ID])
    , CONSTRAINT [IX_Importance_Importance] UNIQUE ([Importance])
);
GO

CREATE TABLE [s09].[TaskStatus] (
      [ID] tinyint NOT NULL
    , [TaskStatus] nvarchar(100) NOT NULL
    , CONSTRAINT [PK_TaskStatus] PRIMARY KEY ([ID])
    , CONSTRAINT [IX_TaskStatus_TaskStatus] UNIQUE ([TaskStatus])
);
GO

CREATE TABLE [s09].[Appointments] (
      [ID] int IDENTITY(1,1) NOT NULL
    , [Subject] nvarchar(100) NOT NULL
    , [Body] nvarchar(1000) NULL
    , [Attachments] nvarchar(255) NULL
    , [Categories] tinyint NULL
    , [RequiredAttendees] nvarchar(100) NULL
    , [StartTime] datetime NOT NULL
    , [EndTime] datetime NULL
    , [ReminderSet] bit NULL
    , [AllDayEvent] bit NULL
    , [BusyStatus] tinyint NULL
    , [Location] nvarchar(255) NULL
    , CONSTRAINT [PK_Appointments] PRIMARY KEY ([ID])
);
GO

ALTER TABLE [s09].[Appointments] ADD CONSTRAINT [FK_Appointments_BusyStatus] FOREIGN KEY ([BusyStatus]) REFERENCES [s09].[BusyStatus] ([ID]);
GO

ALTER TABLE [s09].[Appointments] ADD CONSTRAINT [FK_Appointments_Categories] FOREIGN KEY ([Categories]) REFERENCES [s09].[Categories] ([ID]);
GO

CREATE TABLE [s09].[Emails] (
      [ID] int IDENTITY(1,1) NOT NULL
    , [Subject] nvarchar(100) NOT NULL
    , [Body] nvarchar(1000) NULL
    , [Attachments] nvarchar(255) NULL
    , [Categories] tinyint NULL
    , [Recipients] nvarchar(100) NOT NULL
    , [SentOnBehalfOfName] nvarchar(100) NULL
    , CONSTRAINT [PK_Emails] PRIMARY KEY ([ID])
);
GO

ALTER TABLE [s09].[Emails] ADD CONSTRAINT [FK_Emails_Categories] FOREIGN KEY ([Categories]) REFERENCES [s09].[Categories] ([ID]);
GO

CREATE TABLE [s09].[Tasks] (
      [ID] int IDENTITY(1,1) NOT NULL
    , [Subject] nvarchar(100) NOT NULL
    , [Body] nvarchar(1000) NULL
    , [Attachments] nvarchar(255) NULL
    , [Categories] tinyint NULL
    , [Recipients] nvarchar(100) NULL
    , [StartDate] datetime NOT NULL
    , [DueDate] datetime NULL
    , [ReminderSet] bit NULL
    , [Importance] tinyint NULL
    , [Status] tinyint NULL
    , CONSTRAINT [PK_Tasks] PRIMARY KEY ([ID])
);
GO

ALTER TABLE [s09].[Tasks] ADD CONSTRAINT [FK_Tasks_Categories] FOREIGN KEY ([Categories]) REFERENCES [s09].[Categories] ([ID]);
GO

ALTER TABLE [s09].[Tasks] ADD CONSTRAINT [FK_Tasks_Importance] FOREIGN KEY ([Importance]) REFERENCES [s09].[Importance] ([ID]);
GO

ALTER TABLE [s09].[Tasks] ADD CONSTRAINT [FK_Tasks_TaskStatus] FOREIGN KEY ([Status]) REFERENCES [s09].[TaskStatus] ([ID]);
GO

INSERT INTO [s09].[BusyStatus] ([ID], [BusyStatus]) VALUES (2, N'Busy');
INSERT INTO [s09].[BusyStatus] ([ID], [BusyStatus]) VALUES (0, N'Free');
INSERT INTO [s09].[BusyStatus] ([ID], [BusyStatus]) VALUES (3, N'OutOfOffice');
INSERT INTO [s09].[BusyStatus] ([ID], [BusyStatus]) VALUES (1, N'Tentative');
INSERT INTO [s09].[BusyStatus] ([ID], [BusyStatus]) VALUES (4, N'WorkingElsewhere');
GO

INSERT INTO [s09].[Categories] ([ID], [Categories]) VALUES (1, N'Account');
GO

INSERT INTO [s09].[Importance] ([ID], [Importance]) VALUES (2, N'High');
INSERT INTO [s09].[Importance] ([ID], [Importance]) VALUES (0, N'Low');
INSERT INTO [s09].[Importance] ([ID], [Importance]) VALUES (1, N'Normal');
GO

INSERT INTO [s09].[TaskStatus] ([ID], [TaskStatus]) VALUES (2, N'Complete');
INSERT INTO [s09].[TaskStatus] ([ID], [TaskStatus]) VALUES (4, N'Deferred');
INSERT INTO [s09].[TaskStatus] ([ID], [TaskStatus]) VALUES (1, N'InProgress');
INSERT INTO [s09].[TaskStatus] ([ID], [TaskStatus]) VALUES (0, N'NotStarted');
INSERT INTO [s09].[TaskStatus] ([ID], [TaskStatus]) VALUES (3, N'Waiting');
GO

SET IDENTITY_INSERT [s09].[Appointments] ON;
INSERT INTO [s09].[Appointments] ([ID], [Subject], [Body], [Attachments], [Categories], [RequiredAttendees], [StartTime], [EndTime], [ReminderSet], [AllDayEvent], [BusyStatus], [Location]) VALUES (1, N'Test appointment', N'Test body', N'D:\outlook-integration-example.xlsx', 1, N'john.doe@savetodb.com', '20210424 14:00:00.000', '20210424 14:30:00.000', 1, 0, 2, N'Skype');
SET IDENTITY_INSERT [s09].[Appointments] OFF;
GO

SET IDENTITY_INSERT [s09].[Emails] ON;
INSERT INTO [s09].[Emails] ([ID], [Subject], [Body], [Attachments], [Categories], [Recipients], [SentOnBehalfOfName]) VALUES (1, N'Test email', N'Test body', N'D:\outlook-integration-example.xlsx', 1, N'john.doe@savetodb.com', NULL);
SET IDENTITY_INSERT [s09].[Emails] OFF;
GO

SET IDENTITY_INSERT [s09].[Tasks] ON;
INSERT INTO [s09].[Tasks] ([ID], [Subject], [Body], [Attachments], [Categories], [Recipients], [StartDate], [DueDate], [ReminderSet], [Importance], [Status]) VALUES (1, N'Test task', N'Test body', N'D:\outlook-integration-example.xlsx', 1, N'john.doe@savetodb.com', '20210424 00:00:00.000', '20210424 00:00:00.000', 1, 1, 0);
SET IDENTITY_INSERT [s09].[Tasks] OFF;
GO

print 'Application installed';
