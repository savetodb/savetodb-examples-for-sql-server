-- =============================================
-- Application: Sample 10 - 10 Steps for Developers
-- Version 10.8, January 9, 2023
--
-- Copyright 2019-2023 Sergey Vaselenko
--
-- License: MIT
--
-- Prerequisites: SaveToDB Framework 8.19 or higher
-- =============================================

SET NOCOUNT ON
GO

CREATE SCHEMA [s10];
GO

CREATE TABLE [s10].[Accounts] (
      [ID] int IDENTITY(1,1) NOT NULL
    , [Name] nvarchar(50) NOT NULL
    , CONSTRAINT [PK_Accounts] PRIMARY KEY ([ID])
    , CONSTRAINT [IX_Accounts] UNIQUE ([Name])
);
GO

CREATE TABLE [s10].[Companies] (
      [ID] int IDENTITY(1,1) NOT NULL
    , [Name] nvarchar(50) NOT NULL
    , CONSTRAINT [PK_Companies] PRIMARY KEY ([ID])
    , CONSTRAINT [IX_Companies] UNIQUE ([Name])
);
GO

CREATE TABLE [s10].[Items] (
      [ID] int IDENTITY(1,1) NOT NULL
    , [Name] nvarchar(50) NOT NULL
    , CONSTRAINT [PK_Items] PRIMARY KEY ([ID])
    , CONSTRAINT [IX_Items] UNIQUE ([Name])
);
GO

CREATE TABLE [s10].[Payments] (
      [ID] int IDENTITY(1,1) NOT NULL
    , [Date] datetime NULL
    , [Amount] money NULL
    , [AccountID] int NULL
    , [ItemID] int NULL
    , [CompanyID] int NULL
    , [Comment] nvarchar(255) NULL
    , CONSTRAINT [PK_Payments] PRIMARY KEY ([ID])
);
GO

ALTER TABLE [s10].[Payments] ADD CONSTRAINT [FK_Payments_Accounts] FOREIGN KEY ([AccountID]) REFERENCES [s10].[Accounts] ([ID]) ON UPDATE CASCADE;
GO

ALTER TABLE [s10].[Payments] ADD CONSTRAINT [FK_Payments_Companies] FOREIGN KEY ([CompanyID]) REFERENCES [s10].[Companies] ([ID]) ON UPDATE CASCADE;
GO

ALTER TABLE [s10].[Payments] ADD CONSTRAINT [FK_Payments_Items] FOREIGN KEY ([ItemID]) REFERENCES [s10].[Items] ([ID]) ON UPDATE CASCADE;
GO

-- =============================================
-- Author:      Sergey Vaselenko
-- Release:     10.0, 2022-07-05
-- Description: Payments view
-- =============================================

CREATE VIEW [s10].[viewPayments]
AS

SELECT
    p.ID
    , p.[Date]
    , p.Amount
    , p.AccountID
    , p.ItemID
    , p.CompanyID
    , p.Comment

FROM
    s10.Payments p


GO

-- =============================================
-- Author:      Sergey Vaselenko
-- Release:     10.0, 2022-07-05
-- Description: Payments stored procedure
-- =============================================

CREATE PROCEDURE [s10].[uspPayments]
    @AccountID int = NULL
    , @ItemID int = NULL
    , @CompanyID int = NULL
AS
BEGIN

SET NOCOUNT ON

SELECT
    p.ID
    , p.[Date]
    , p.Amount
    , p.AccountID
    , p.ItemID
    , p.CompanyID
    , p.Comment

FROM
    s10.Payments p
WHERE
    COALESCE(@AccountID, p.AccountID, 0) = COALESCE(p.AccountID, 0)
    AND COALESCE(@ItemID, p.ItemID, 0) = COALESCE(p.ItemID, 0)
    AND COALESCE(@CompanyID, p.CompanyID, 0) = COALESCE(p.CompanyID, 0)

END


GO

CREATE PROCEDURE [s10].[uspPayments_delete]
    @ID int
AS
BEGIN

DELETE s10.Payments
WHERE
    ID = @ID

END


GO

CREATE PROCEDURE [s10].[uspPayments_insert]
    @Date datetime = NULL
    , @Amount money = NULL
    , @AccountID int = NULL
    , @ItemID int = NULL
    , @CompanyID int = NULL
    , @Comment nvarchar(255) = NULL
AS
BEGIN

INSERT INTO s10.Payments
    ( [Date]
    , [Amount]
    , AccountID
    , ItemID
    , CompanyID
    , Comment
    )
VALUES
    ( @Date
    , @Amount
    , @AccountID
    , @ItemID
    , @CompanyID
    , @Comment
    )

END


GO

CREATE PROCEDURE [s10].[uspPayments_update]
      @ID int
    , @Date datetime = NULL
    , @Amount money = NULL
    , @AccountID int = NULL
    , @ItemID int = NULL
    , @CompanyID int = NULL
    , @Comment nvarchar(255) = NULL
AS
BEGIN

UPDATE s10.Payments
SET
    [Date] = @Date
    , [Amount] = @Amount
    , AccountID = @AccountID
    , ItemID = @ItemID
    , CompanyID = @CompanyID
    , Comment = @Comment
WHERE
    ID = @ID

END


GO

SET IDENTITY_INSERT [s10].[Accounts] ON;
INSERT INTO [s10].[Accounts] ([ID], [Name]) VALUES (1, N'Bank');
SET IDENTITY_INSERT [s10].[Accounts] OFF;
GO

SET IDENTITY_INSERT [s10].[Companies] ON;
INSERT INTO [s10].[Companies] ([ID], [Name]) VALUES (3, N'Corporate Income Tax');
INSERT INTO [s10].[Companies] ([ID], [Name]) VALUES (6, N'Customer C1');
INSERT INTO [s10].[Companies] ([ID], [Name]) VALUES (1, N'Customer C2');
INSERT INTO [s10].[Companies] ([ID], [Name]) VALUES (2, N'Customer C3');
INSERT INTO [s10].[Companies] ([ID], [Name]) VALUES (4, N'Individual Income Tax');
INSERT INTO [s10].[Companies] ([ID], [Name]) VALUES (7, N'Payroll Taxes');
INSERT INTO [s10].[Companies] ([ID], [Name]) VALUES (5, N'Supplier S1');
INSERT INTO [s10].[Companies] ([ID], [Name]) VALUES (8, N'Supplier S2');
SET IDENTITY_INSERT [s10].[Companies] OFF;
GO

SET IDENTITY_INSERT [s10].[Items] ON;
INSERT INTO [s10].[Items] ([ID], [Name]) VALUES (1, N'Expenses');
INSERT INTO [s10].[Items] ([ID], [Name]) VALUES (2, N'Payroll');
INSERT INTO [s10].[Items] ([ID], [Name]) VALUES (3, N'Revenue');
INSERT INTO [s10].[Items] ([ID], [Name]) VALUES (4, N'Taxes');
SET IDENTITY_INSERT [s10].[Items] OFF;
GO

SET IDENTITY_INSERT [s10].[Payments] ON;
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (1, '20230110 00:00:00.000', 200000, 1, 3, 6, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (2, '20230110 00:00:00.000', -50000, 1, 1, 5, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (3, '20230131 00:00:00.000', -85000, 1, 2, NULL, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (4, '20230131 00:00:00.000', -15000, 1, 4, 4, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (5, '20230131 00:00:00.000', -15000, 1, 4, 7, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (6, '20230210 00:00:00.000', 300000, 1, 3, 6, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (7, '20230210 00:00:00.000', 100000, 1, 3, 1, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (8, '20230210 00:00:00.000', -50000, 1, 1, 8, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (9, '20230210 00:00:00.000', -100000, 1, 1, 5, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (10, '20230228 00:00:00.000', -85000, 1, 2, NULL, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (11, '20230228 00:00:00.000', -15000, 1, 4, 4, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (12, '20230228 00:00:00.000', -15000, 1, 4, 7, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (13, '20230310 00:00:00.000', 300000, 1, 3, 6, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (14, '20230310 00:00:00.000', 200000, 1, 3, 1, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (15, '20230310 00:00:00.000', 100000, 1, 3, 2, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (16, '20230315 00:00:00.000', -100000, 1, 4, 3, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (17, '20230331 00:00:00.000', -170000, 1, 2, NULL, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (18, '20230331 00:00:00.000', -30000, 1, 4, 4, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (19, '20230331 00:00:00.000', -30000, 1, 4, 7, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (20, '20230331 00:00:00.000', -50000, 1, 1, 8, NULL);
INSERT INTO [s10].[Payments] ([ID], [Date], [Amount], [AccountID], [ItemID], [CompanyID], [Comment]) VALUES (21, '20230331 00:00:00.000', -100000, 1, 1, 5, NULL);
SET IDENTITY_INSERT [s10].[Payments] OFF;
GO

INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's10', N'Accounts', N'<table name="s10.Accounts"><columnFormats><column name="" property="ListObjectName" value="Accounts_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ID" property="Address" value="$C$4" type="String" /><column name="ID" property="ColumnWidth" value="4.43" type="Double" /><column name="ID" property="NumberFormat" value="General" type="String" /><column name="ID" property="Validation.Type" value="1" type="Double" /><column name="ID" property="Validation.Operator" value="1" type="Double" /><column name="ID" property="Validation.Formula1" value="-2147483648" type="String" /><column name="ID" property="Validation.Formula2" value="2147483647" type="String" /><column name="ID" property="Validation.AlertStyle" value="1" type="Double" /><column name="ID" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="ID" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="ID" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="ID" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String" /><column name="ID" property="Validation.ShowInput" value="True" type="Boolean" /><column name="ID" property="Validation.ShowError" value="True" type="Boolean" /><column name="Name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Name" property="Address" value="$D$4" type="String" /><column name="Name" property="ColumnWidth" value="20.71" type="Double" /><column name="Name" property="NumberFormat" value="General" type="String" /><column name="Name" property="Validation.Type" value="6" type="Double" /><column name="Name" property="Validation.Operator" value="8" type="Double" /><column name="Name" property="Validation.Formula1" value="50" type="String" /><column name="Name" property="Validation.AlertStyle" value="1" type="Double" /><column name="Name" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="Name" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="Name" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="Name" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(50) datatype." type="String" /><column name="Name" property="Validation.ShowInput" value="True" type="Boolean" /><column name="Name" property="Validation.ShowError" value="True" type="Boolean" /><column name="Name" property="FormatConditions(1).AppliesTo.Address" value="$D$4" type="String" /><column name="Name" property="FormatConditions(1).Type" value="2" type="Double" /><column name="Name" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="Name" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String" /><column name="Name" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="Name" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's10', N'Companies', N'<table name="s10.Companies"><columnFormats><column name="" property="ListObjectName" value="Companies_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ID" property="Address" value="$C$4" type="String" /><column name="ID" property="ColumnWidth" value="4.43" type="Double" /><column name="ID" property="NumberFormat" value="General" type="String" /><column name="ID" property="Validation.Type" value="1" type="Double" /><column name="ID" property="Validation.Operator" value="1" type="Double" /><column name="ID" property="Validation.Formula1" value="-2147483648" type="String" /><column name="ID" property="Validation.Formula2" value="2147483647" type="String" /><column name="ID" property="Validation.AlertStyle" value="1" type="Double" /><column name="ID" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="ID" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="ID" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="ID" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String" /><column name="ID" property="Validation.ShowInput" value="True" type="Boolean" /><column name="ID" property="Validation.ShowError" value="True" type="Boolean" /><column name="Name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Name" property="Address" value="$D$4" type="String" /><column name="Name" property="ColumnWidth" value="20.71" type="Double" /><column name="Name" property="NumberFormat" value="General" type="String" /><column name="Name" property="Validation.Type" value="6" type="Double" /><column name="Name" property="Validation.Operator" value="8" type="Double" /><column name="Name" property="Validation.Formula1" value="50" type="String" /><column name="Name" property="Validation.AlertStyle" value="1" type="Double" /><column name="Name" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="Name" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="Name" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="Name" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(50) datatype." type="String" /><column name="Name" property="Validation.ShowInput" value="True" type="Boolean" /><column name="Name" property="Validation.ShowError" value="True" type="Boolean" /><column name="Name" property="FormatConditions(1).AppliesTo.Address" value="$D$4:$D$11" type="String" /><column name="Name" property="FormatConditions(1).Type" value="2" type="Double" /><column name="Name" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="Name" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String" /><column name="Name" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="Name" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's10', N'Items', N'<table name="s10.Items"><columnFormats><column name="" property="ListObjectName" value="Items_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ID" property="Address" value="$C$4" type="String" /><column name="ID" property="ColumnWidth" value="4.43" type="Double" /><column name="ID" property="NumberFormat" value="General" type="String" /><column name="ID" property="Validation.Type" value="1" type="Double" /><column name="ID" property="Validation.Operator" value="1" type="Double" /><column name="ID" property="Validation.Formula1" value="-2147483648" type="String" /><column name="ID" property="Validation.Formula2" value="2147483647" type="String" /><column name="ID" property="Validation.AlertStyle" value="1" type="Double" /><column name="ID" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="ID" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="ID" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="ID" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String" /><column name="ID" property="Validation.ShowInput" value="True" type="Boolean" /><column name="ID" property="Validation.ShowError" value="True" type="Boolean" /><column name="Name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Name" property="Address" value="$D$4" type="String" /><column name="Name" property="ColumnWidth" value="20.71" type="Double" /><column name="Name" property="NumberFormat" value="General" type="String" /><column name="Name" property="Validation.Type" value="6" type="Double" /><column name="Name" property="Validation.Operator" value="8" type="Double" /><column name="Name" property="Validation.Formula1" value="50" type="String" /><column name="Name" property="Validation.AlertStyle" value="1" type="Double" /><column name="Name" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="Name" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="Name" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="Name" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(50) datatype." type="String" /><column name="Name" property="Validation.ShowInput" value="True" type="Boolean" /><column name="Name" property="Validation.ShowError" value="True" type="Boolean" /><column name="Name" property="FormatConditions(1).AppliesTo.Address" value="$D$4:$D$7" type="String" /><column name="Name" property="FormatConditions(1).Type" value="2" type="Double" /><column name="Name" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="Name" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String" /><column name="Name" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="Name" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's10', N'Payments', N'<table name="s10.Payments"><columnFormats><column name="" property="ListObjectName" value="Payments_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ID" property="Address" value="$C$4" type="String" /><column name="ID" property="ColumnWidth" value="4.43" type="Double" /><column name="ID" property="NumberFormat" value="General" type="String" /><column name="ID" property="Validation.Type" value="1" type="Double" /><column name="ID" property="Validation.Operator" value="1" type="Double" /><column name="ID" property="Validation.Formula1" value="-2147483648" type="String" /><column name="ID" property="Validation.Formula2" value="2147483647" type="String" /><column name="ID" property="Validation.AlertStyle" value="1" type="Double" /><column name="ID" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="ID" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="ID" property="Validation.ShowInput" value="True" type="Boolean" /><column name="ID" property="Validation.ShowError" value="True" type="Boolean" /><column name="Date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Date" property="Address" value="$D$4" type="String" /><column name="Date" property="ColumnWidth" value="10.71" type="Double" /><column name="Date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="Date" property="Validation.Type" value="4" type="Double" /><column name="Date" property="Validation.Operator" value="5" type="Double" /><column name="Date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="Date" property="Validation.AlertStyle" value="1" type="Double" /><column name="Date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="Date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="Date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="Date" property="Validation.ShowError" value="True" type="Boolean" /><column name="Amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Amount" property="Address" value="$E$4" type="String" /><column name="Amount" property="ColumnWidth" value="12.14" type="Double" /><column name="Amount" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="Amount" property="Validation.Type" value="6" type="Double" /><column name="Amount" property="Validation.Operator" value="8" type="Double" /><column name="Amount" property="Validation.Formula1" value="255" type="String" /><column name="Amount" property="Validation.AlertStyle" value="1" type="Double" /><column name="Amount" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="Amount" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="Amount" property="Validation.ShowInput" value="True" type="Boolean" /><column name="Amount" property="Validation.ShowError" value="True" type="Boolean" /><column name="AccountID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="AccountID" property="Address" value="$F$4" type="String" /><column name="AccountID" property="ColumnWidth" value="12.14" type="Double" /><column name="AccountID" property="NumberFormat" value="General" type="String" /><column name="AccountID" property="Validation.Type" value="3" type="Double" /><column name="AccountID" property="Validation.Operator" value="1" type="Double" /><column name="AccountID" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s10_Accounts_ID_Name[Name]&quot;)" type="String" /><column name="AccountID" property="Validation.AlertStyle" value="1" type="Double" /><column name="AccountID" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="AccountID" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="AccountID" property="Validation.ShowInput" value="True" type="Boolean" /><column name="AccountID" property="Validation.ShowError" value="True" type="Boolean" /><column name="ItemID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ItemID" property="Address" value="$G$4" type="String" /><column name="ItemID" property="ColumnWidth" value="20.71" type="Double" /><column name="ItemID" property="NumberFormat" value="General" type="String" /><column name="ItemID" property="Validation.Type" value="3" type="Double" /><column name="ItemID" property="Validation.Operator" value="1" type="Double" /><column name="ItemID" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s10_Items_ID_Name[Name]&quot;)" type="String" /><column name="ItemID" property="Validation.AlertStyle" value="1" type="Double" /><column name="ItemID" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="ItemID" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="ItemID" property="Validation.ShowInput" value="True" type="Boolean" /><column name="ItemID" property="Validation.ShowError" value="True" type="Boolean" /><column name="CompanyID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="CompanyID" property="Address" value="$H$4" type="String" /><column name="CompanyID" property="ColumnWidth" value="20.71" type="Double" /><column name="CompanyID" property="NumberFormat" value="General" type="String" /><column name="CompanyID" property="Validation.Type" value="3" type="Double" /><column name="CompanyID" property="Validation.Operator" value="1" type="Double" /><column name="CompanyID" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s10_Companies_ID_Name[Name]&quot;)" type="String" /><column name="CompanyID" property="Validation.AlertStyle" value="1" type="Double" /><column name="CompanyID" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="CompanyID" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="CompanyID" property="Validation.ShowInput" value="True" type="Boolean" /><column name="CompanyID" property="Validation.ShowError" value="True" type="Boolean" /><column name="Comment" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Comment" property="Address" value="$I$4" type="String" /><column name="Comment" property="ColumnWidth" value="20.71" type="Double" /><column name="Comment" property="NumberFormat" value="General" type="String" /><column name="Comment" property="Validation.Type" value="6" type="Double" /><column name="Comment" property="Validation.Operator" value="8" type="Double" /><column name="Comment" property="Validation.Formula1" value="255" type="String" /><column name="Comment" property="Validation.AlertStyle" value="1" type="Double" /><column name="Comment" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="Comment" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="Comment" property="Validation.ShowInput" value="True" type="Boolean" /><column name="Comment" property="Validation.ShowError" value="True" type="Boolean" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats><views><view name="All Payments"><column name="" property="ListObjectName" value="Payments_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Sum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="AccountID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="CompanyID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ItemID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Comment" property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Incomes"><column name="" property="ListObjectName" value="Payments_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Sum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="AccountID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="CompanyID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ItemID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Comment" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Sum" property="AutoFilter.Criteria1" value="&gt;0" type="String" /></view><view name="Expenses"><column name="" property="ListObjectName" value="Payments_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Sum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="AccountID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="CompanyID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ItemID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Comment" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Sum" property="AutoFilter.Criteria1" value="&lt;0" type="String" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's10', N'uspPayments', N'<table name="s10.uspPayments"><columnFormats><column name="" property="ListObjectName" value="Reports_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ID" property="Address" value="$C$4" type="String" /><column name="ID" property="ColumnWidth" value="4.43" type="Double" /><column name="ID" property="NumberFormat" value="General" type="String" /><column name="Date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Date" property="Address" value="$D$4" type="String" /><column name="Date" property="ColumnWidth" value="10.71" type="Double" /><column name="Date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="Amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Amount" property="Address" value="$E$4" type="String" /><column name="Amount" property="ColumnWidth" value="12.14" type="Double" /><column name="Amount" property="NumberFormat" value="#,##0.00_);[Red](#,##0.00)" type="String" /><column name="AccountID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="AccountID" property="Address" value="$F$4" type="String" /><column name="AccountID" property="ColumnWidth" value="12.14" type="Double" /><column name="AccountID" property="NumberFormat" value="General" type="String" /><column name="AccountID" property="Validation.Type" value="3" type="Double" /><column name="AccountID" property="Validation.Operator" value="1" type="Double" /><column name="AccountID" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s10_Accounts_ID_Name[Name]&quot;)" type="String" /><column name="AccountID" property="Validation.AlertStyle" value="1" type="Double" /><column name="AccountID" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="AccountID" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="AccountID" property="Validation.ShowInput" value="True" type="Boolean" /><column name="AccountID" property="Validation.ShowError" value="True" type="Boolean" /><column name="ItemID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ItemID" property="Address" value="$G$4" type="String" /><column name="ItemID" property="ColumnWidth" value="20.71" type="Double" /><column name="ItemID" property="NumberFormat" value="General" type="String" /><column name="ItemID" property="Validation.Type" value="3" type="Double" /><column name="ItemID" property="Validation.Operator" value="1" type="Double" /><column name="ItemID" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s10_Items_ID_Name[Name]&quot;)" type="String" /><column name="ItemID" property="Validation.AlertStyle" value="1" type="Double" /><column name="ItemID" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="ItemID" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="ItemID" property="Validation.ShowInput" value="True" type="Boolean" /><column name="ItemID" property="Validation.ShowError" value="True" type="Boolean" /><column name="CompanyID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="CompanyID" property="Address" value="$H$4" type="String" /><column name="CompanyID" property="ColumnWidth" value="20.71" type="Double" /><column name="CompanyID" property="NumberFormat" value="General" type="String" /><column name="CompanyID" property="Validation.Type" value="3" type="Double" /><column name="CompanyID" property="Validation.Operator" value="1" type="Double" /><column name="CompanyID" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s10_Companies_ID_Name[Name]&quot;)" type="String" /><column name="CompanyID" property="Validation.AlertStyle" value="1" type="Double" /><column name="CompanyID" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="CompanyID" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="CompanyID" property="Validation.ShowInput" value="True" type="Boolean" /><column name="CompanyID" property="Validation.ShowError" value="True" type="Boolean" /><column name="Comment" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Comment" property="Address" value="$I$4" type="String" /><column name="Comment" property="ColumnWidth" value="20.71" type="Double" /><column name="Comment" property="NumberFormat" value="General" type="String" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats><views><view name="All Payments"><column name="" property="ListObjectName" value="Reports_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="AccountID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="CompanyID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ItemID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Comment" property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Incomes"><column name="" property="ListObjectName" value="Reports_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="AccountID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="CompanyID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ItemID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Comment" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Amount" property="AutoFilter.Criteria1" value="&gt;0" type="String" /></view><view name="Expenses"><column name="" property="ListObjectName" value="Reports_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="AccountID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="CompanyID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ItemID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Comment" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Amount" property="AutoFilter.Criteria1" value="&lt;0" type="String" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's10', N'viewPayments', N'<table name="s10.viewPayments"><columnFormats><column name="" property="ListObjectName" value="Reports_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ID" property="Address" value="$C$4" type="String" /><column name="ID" property="ColumnWidth" value="4.43" type="Double" /><column name="ID" property="NumberFormat" value="General" type="String" /><column name="ID" property="Validation.Type" value="1" type="Double" /><column name="ID" property="Validation.Operator" value="1" type="Double" /><column name="ID" property="Validation.Formula1" value="-2147483648" type="String" /><column name="ID" property="Validation.Formula2" value="2147483647" type="String" /><column name="ID" property="Validation.AlertStyle" value="1" type="Double" /><column name="ID" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="ID" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="ID" property="Validation.ShowInput" value="True" type="Boolean" /><column name="ID" property="Validation.ShowError" value="True" type="Boolean" /><column name="Date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Date" property="Address" value="$D$4" type="String" /><column name="Date" property="ColumnWidth" value="10.57" type="Double" /><column name="Date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="Date" property="Validation.Type" value="4" type="Double" /><column name="Date" property="Validation.Operator" value="5" type="Double" /><column name="Date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="Date" property="Validation.AlertStyle" value="1" type="Double" /><column name="Date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="Date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="Date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="Date" property="Validation.ShowError" value="True" type="Boolean" /><column name="Amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Amount" property="Address" value="$E$4" type="String" /><column name="Amount" property="ColumnWidth" value="11.43" type="Double" /><column name="Amount" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="Amount" property="Validation.Type" value="6" type="Double" /><column name="Amount" property="Validation.Operator" value="8" type="Double" /><column name="Amount" property="Validation.Formula1" value="255" type="String" /><column name="Amount" property="Validation.AlertStyle" value="1" type="Double" /><column name="Amount" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="Amount" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="Amount" property="Validation.ShowInput" value="True" type="Boolean" /><column name="Amount" property="Validation.ShowError" value="True" type="Boolean" /><column name="AccountID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="AccountID" property="Address" value="$F$4" type="String" /><column name="AccountID" property="ColumnWidth" value="20.71" type="Double" /><column name="AccountID" property="NumberFormat" value="General" type="String" /><column name="AccountID" property="Validation.Type" value="3" type="Double" /><column name="AccountID" property="Validation.Operator" value="1" type="Double" /><column name="AccountID" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s10_Accounts_ID_Name[Name]&quot;)" type="String" /><column name="AccountID" property="Validation.AlertStyle" value="1" type="Double" /><column name="AccountID" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="AccountID" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="AccountID" property="Validation.ShowInput" value="True" type="Boolean" /><column name="AccountID" property="Validation.ShowError" value="True" type="Boolean" /><column name="ItemID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ItemID" property="Address" value="$G$4" type="String" /><column name="ItemID" property="ColumnWidth" value="20.71" type="Double" /><column name="ItemID" property="NumberFormat" value="General" type="String" /><column name="ItemID" property="Validation.Type" value="3" type="Double" /><column name="ItemID" property="Validation.Operator" value="1" type="Double" /><column name="ItemID" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s10_Items_ID_Name[Name]&quot;)" type="String" /><column name="ItemID" property="Validation.AlertStyle" value="1" type="Double" /><column name="ItemID" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="ItemID" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="ItemID" property="Validation.ShowInput" value="True" type="Boolean" /><column name="ItemID" property="Validation.ShowError" value="True" type="Boolean" /><column name="CompanyID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="CompanyID" property="Address" value="$H$4" type="String" /><column name="CompanyID" property="ColumnWidth" value="20.71" type="Double" /><column name="CompanyID" property="NumberFormat" value="General" type="String" /><column name="CompanyID" property="Validation.Type" value="3" type="Double" /><column name="CompanyID" property="Validation.Operator" value="1" type="Double" /><column name="CompanyID" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s10_Companies_ID_Name[Name]&quot;)" type="String" /><column name="CompanyID" property="Validation.AlertStyle" value="1" type="Double" /><column name="CompanyID" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="CompanyID" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="CompanyID" property="Validation.ShowInput" value="True" type="Boolean" /><column name="CompanyID" property="Validation.ShowError" value="True" type="Boolean" /><column name="Comment" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Comment" property="Address" value="$I$4" type="String" /><column name="Comment" property="ColumnWidth" value="20.71" type="Double" /><column name="Comment" property="NumberFormat" value="General" type="String" /><column name="Comment" property="Validation.Type" value="6" type="Double" /><column name="Comment" property="Validation.Operator" value="8" type="Double" /><column name="Comment" property="Validation.Formula1" value="255" type="String" /><column name="Comment" property="Validation.AlertStyle" value="1" type="Double" /><column name="Comment" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="Comment" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="Comment" property="Validation.ShowInput" value="True" type="Boolean" /><column name="Comment" property="Validation.ShowError" value="True" type="Boolean" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats><views><view name="All Payments"><column name="" property="ListObjectName" value="Reports_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Sum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="AccountID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="CompanyID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ItemID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Comment" property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Incomes"><column name="" property="ListObjectName" value="Reports_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Sum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="AccountID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="CompanyID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ItemID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Comment" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Sum" property="AutoFilter.Criteria1" value="&gt;0" type="String" /></view><view name="Expenses"><column name="" property="ListObjectName" value="Reports_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Sum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="AccountID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="CompanyID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ItemID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Comment" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Sum" property="AutoFilter.Criteria1" value="&lt;0" type="String" /></view></views></table>');
GO

INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'Payments', NULL, N'Actions', N's10', N'Instruction', N'HTTP', N'https://www.savetodb.com/10-steps-for-developers/chapter-20.htm', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'uspPayments', NULL, N'Actions', N's10', N'Instruction', N'HTTP', N'https://www.savetodb.com/10-steps-for-developers/chapter-20.htm', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'viewPayments', NULL, N'Actions', N's10', N'Instruction', N'HTTP', N'https://www.savetodb.com/10-steps-for-developers/chapter-20.htm', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'Payments', NULL, N'ContextMenu', N's10', N'Company Payments', N'CODE', N'SELECT
    p.[Date]
    , p.Amount
    , i.Name AS Item
    , c.Name AS Company
    , p.Comment
FROM
    s10.Payments p
    LEFT OUTER JOIN s10.Items i ON i.ID = p.ItemID
    INNER JOIN s10.Companies c ON c.ID = p.CompanyID
WHERE
    p.CompanyID = @CompanyID', N'_TaskPane', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'Payments', NULL, N'ContextMenu', N's10', N'Item Payments', N'CODE', N'SELECT
    p.[Date]
    , p.Amount
    , i.Name AS Item
    , c.Name AS Company
    , p.Comment
FROM
    s10.Payments p
    INNER JOIN s10.Items i ON i.ID = p.ItemID
    LEFT OUTER JOIN s10.Companies c ON c.ID = p.CompanyID
WHERE
    p.ItemID = @ItemID', N'_TaskPane', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'uspPayments', N'AccountID', N'ParameterValues', N's10', N'Accounts', N'TABLE', N'ID,Name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'uspPayments', N'CompanyID', N'ParameterValues', N's10', N'Companies', N'TABLE', N'ID,Name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'uspPayments', N'ItemID', N'ParameterValues', N's10', N'Items', N'TABLE', N'ID,Name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'uspPayments', NULL, N'SelectionChange', N's10', N'Company Payments', N'CODE', N'SELECT
    p.[Date]
    , p.Amount
    , i.Name AS Item
    , c.Name AS Company
    , p.Comment
FROM
    s10.Payments p
    LEFT OUTER JOIN s10.Items i ON i.ID = p.ItemID
    INNER JOIN s10.Companies c ON c.ID = p.CompanyID
WHERE
    p.CompanyID = @CompanyID', N'_TaskPane', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'uspPayments', NULL, N'SelectionChange', N's10', N'Item Payments', N'CODE', N'SELECT
    p.[Date]
    , p.Amount
    , i.Name AS Item
    , c.Name AS Company
    , p.Comment
FROM
    s10.Payments p
    INNER JOIN s10.Items i ON i.ID = p.ItemID
    LEFT OUTER JOIN s10.Companies c ON c.ID = p.CompanyID
WHERE
    p.ItemID = @ItemID', N'_TaskPane', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'viewPayments', NULL, N'SelectionChange', N's10', N'Company Payments', N'CODE', N'SELECT
    p.[Date]
    , p.Amount
    , i.Name AS Item
    , c.Name AS Company
    , p.Comment
FROM
    s10.Payments p
    LEFT OUTER JOIN s10.Items i ON i.ID = p.ItemID
    INNER JOIN s10.Companies c ON c.ID = p.CompanyID
WHERE
    p.CompanyID = @CompanyID', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'viewPayments', NULL, N'SelectionChange', N's10', N'Item Payments', N'CODE', N'SELECT
    p.[Date]
    , p.Amount
    , i.Name AS Item
    , c.Name AS Company
    , p.Comment
FROM
    s10.Payments p
    INNER JOIN s10.Items i ON i.ID = p.ItemID
    LEFT OUTER JOIN s10.Companies c ON c.ID = p.CompanyID
WHERE
    p.ItemID = @ItemID', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'Payments', N'AccountID', N'ValidationList', N's10', N'Accounts', N'TABLE', N'ID,Name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'Payments', N'CompanyID', N'ValidationList', N's10', N'Companies', N'TABLE', N'ID,Name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'Payments', N'ItemID', N'ValidationList', N's10', N'Items', N'TABLE', N'ID,Name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'uspPayments', N'AccountID', N'ValidationList', N's10', N'Accounts', N'TABLE', N'ID,Name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'uspPayments', N'CompanyID', N'ValidationList', N's10', N'Companies', N'TABLE', N'ID,Name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'uspPayments', N'ItemID', N'ValidationList', N's10', N'Items', N'TABLE', N'ID,Name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'viewPayments', N'AccountID', N'ValidationList', N's10', N'Accounts', N'TABLE', N'ID,Name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'viewPayments', N'CompanyID', N'ValidationList', N's10', N'Companies', N'TABLE', N'ID,Name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's10', N'viewPayments', N'ItemID', N'ValidationList', N's10', N'Items', N'TABLE', N'ID,Name', NULL, NULL, NULL);
GO

INSERT INTO xls.objects (TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE, TABLE_CODE, INSERT_OBJECT, UPDATE_OBJECT, DELETE_OBJECT) VALUES (N's10', N'uspPayments', N'PROCEDURE', NULL, N's10.uspPayments_insert', N's10.uspPayments_update', N's10.uspPayments_delete');
GO

INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's10', N'Accounts', NULL, N'en', N'Accounts', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's10', N'Companies', NULL, N'en', N'Companies', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's10', N'Items', NULL, N'en', N'Items', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's10', N'Payments', NULL, N'en', N'Payments', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's10', N'Payments', N'AccountID', N'en', N'Account', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's10', N'Payments', N'CompanyID', N'en', N'Company', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's10', N'Payments', N'ItemID', N'en', N'Item', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's10', N'uspPayments', NULL, N'en', N'Payments (sp)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's10', N'uspPayments', N'AccountID', N'en', N'Account', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's10', N'uspPayments', N'CompanyID', N'en', N'Company', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's10', N'uspPayments', N'ItemID', N'en', N'Item', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's10', N'viewPayments', NULL, N'en', N'Payments (view)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's10', N'viewPayments', N'AccountID', N'en', N'Account', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's10', N'viewPayments', N'CompanyID', N'en', N'Company', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's10', N'viewPayments', N'ItemID', N'en', N'Item', NULL, NULL);
GO

INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 10 - 10 Steps for Developers.xlsx', N'Sample 10 - 10 Steps for Developers.xlsx', N'CompanyPayments=s10.Companies,xls01.viewQueryList,False,$B$3,,{"Parameters":{},"ListObjectName":"CompanyPayments_Table1"}
CompanyPayments=s10.viewPayments,xls.queries,False,$F$3,,{"Parameters":{},"ListObjectName":"CompanyPayments_Table2"}
Reports=s10.uspPayments,xls.queries,True,$B$3,,{"Parameters":{"AccountID":null,"ItemID":null,"CompanyID":null},"ListObjectName":"Reports_Table1"}
Payments=s10.Payments,(Default),False,$B$3,,{"Parameters":{},"ListObjectName":"Payments_Table1"}
Companies=s10.Companies,(Default),False,$B$3,,{"Parameters":{},"ListObjectName":"Companies_Table1"}
Items=s10.Items,(Default),False,$B$3,,{"Parameters":{},"ListObjectName":"Items_Table1"}
Accounts=s10.Accounts,(Default),False,$B$3,,{"Parameters":{},"ListObjectName":"Accounts_Table1"}', N's10');
GO

print 'Application installed';
