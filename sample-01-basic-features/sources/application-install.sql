-- =============================================
-- Application: Sample 01 - Basic SaveToDB Features
-- Version 10.13, April 29, 2024
--
-- Copyright 2011-2024 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON
GO

CREATE SCHEMA s01;
GO

CREATE TABLE s01.cashbook (
    id int IDENTITY(1,1) NOT NULL
    , date date NULL
    , account nvarchar(50) NULL
    , item nvarchar(50) NULL
    , company nvarchar(50) NULL
    , debit money NULL
    , credit money NULL
    , CONSTRAINT PK_cashbook PRIMARY KEY (id)
);
GO

CREATE TABLE s01.formats (
    ID int IDENTITY(1,1) NOT NULL
    , TABLE_SCHEMA nvarchar(128) NOT NULL
    , TABLE_NAME nvarchar(128) NOT NULL
    , TABLE_EXCEL_FORMAT_XML xml NULL
    , CONSTRAINT PK_formats PRIMARY KEY (ID)
    , CONSTRAINT IX_formats UNIQUE (TABLE_NAME, TABLE_SCHEMA)
);
GO

CREATE TABLE s01.workbooks (
    ID int IDENTITY(1,1) NOT NULL
    , NAME nvarchar(128) NOT NULL
    , TEMPLATE nvarchar(255) NULL
    , DEFINITION nvarchar(max) NOT NULL
    , TABLE_SCHEMA nvarchar(128) NULL
    , CONSTRAINT PK_workbooks PRIMARY KEY (ID)
    , CONSTRAINT IX_workbooks UNIQUE (NAME)
);
GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE VIEW [s01].[view_cashbook]
AS

SELECT
    *
FROM
    s01.cashbook t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Online help actions
-- =============================================

CREATE VIEW [s01].[xl_actions_online_help]
AS
SELECT
    t.TABLE_SCHEMA
    , t.TABLE_NAME
    , CAST(NULL AS nvarchar(128)) AS COLUMN_NAME
    , 'Actions' AS EVENT_NAME
    , t.TABLE_SCHEMA AS HANDLER_SCHEMA
    , 'See Online Help' AS HANDLER_NAME
    , 'HTTP' AS HANDLER_TYPE
    , 'https://www.savetodb.com/samples/sample01-' + t.TABLE_NAME AS HANDLER_CODE
    , CAST(NULL AS nvarchar(128)) AS TARGET_WORKSHEET
    , 1 AS MENU_ORDER
    , 0 AS EDIT_PARAMETERS
FROM
    INFORMATION_SCHEMA.TABLES t
WHERE
    t.TABLE_SCHEMA = 's01'
    AND NOT t.TABLE_NAME LIKE 'xl_%'
UNION ALL
SELECT
    t.ROUTINE_SCHEMA AS TABLE_SCHEMA
    , t.ROUTINE_NAME AS TABLE_NAME
    , CAST(NULL AS nvarchar(128)) AS COLUMN_NAME
    , 'Actions' AS EVENT_NAME
    , t.ROUTINE_SCHEMA AS HANDLER_SCHEMA
    , 'See Online Help' AS HANDLER_NAME
    , 'HTTP' AS HANDLER_TYPE
    , 'https://www.savetodb.com/samples/sample01-' + t.ROUTINE_NAME AS HANDLER_CODE
    , CAST(NULL AS nvarchar(128)) AS TARGET_WORKSHEET
    , 1 AS MENU_ORDER
    , 0 AS EDIT_PARAMETERS
FROM
    INFORMATION_SCHEMA.ROUTINES t
WHERE
    t.ROUTINE_SCHEMA = 's01'
    AND NOT t.ROUTINE_NAME LIKE 'xl_%'
    AND NOT t.ROUTINE_NAME LIKE '%_insert'
    AND NOT t.ROUTINE_NAME LIKE '%_update'
    AND NOT t.ROUTINE_NAME LIKE '%_delete'
    AND NOT t.ROUTINE_NAME LIKE '%_change'
    AND NOT t.ROUTINE_NAME LIKE '%_merge'


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash report by months
-- =============================================

CREATE PROCEDURE [s01].[usp_cash_by_months]
    @year int = NULL
    WITH EXECUTE AS SELF
AS
BEGIN

SET NOCOUNT ON

IF @year IS NULL SET @year = YEAR((SELECT MAX([date]) FROM s01.cashbook))
IF @year IS NULL SET @year = YEAR(GETDATE())

SET LANGUAGE us_english;

WITH cte (record_side, item, company, period, [year], [month], amount)
AS
    (
    SELECT
        CASE WHEN p.debit IS NOT NULL THEN 1 WHEN p.credit IS NOT NULL THEN -1 ELSE 0 END AS record_side
        , p.item
        , p.company
        , DATEADD(MONTH, DATEDIFF(MONTH, 0, p.[date]), 0) AS period
        , MAX(YEAR(p.[date])) AS [year]
        , MAX(LEFT(DATENAME(MONTH, p.[date]),3)) AS [month]
        , COALESCE(SUM(p.debit), 0) - COALESCE(SUM(p.credit), 0) AS amount
    FROM
        s01.cashbook p
    GROUP BY
        ROLLUP(DATEADD(MONTH, DATEDIFF(MONTH, 0, p.[date]), 0), CASE WHEN p.debit IS NOT NULL THEN 1 WHEN p.credit IS NOT NULL THEN -1 ELSE 0 END, p.item, p.company)
    )

SELECT
    ROW_NUMBER() OVER (ORDER BY section, item, company) AS sort_order
    , section
    , CASE WHEN item IS NULL THEN 0 WHEN company IS NULL THEN 1 ELSE 2 END AS [level]
    , item
    , company
    , COALESCE('    ' + company, '  ' + item, item_type) AS Name
    , CASE WHEN section = 1 THEN [Jan] WHEN section = 5 THEN [Dec] ELSE COALESCE([Jan], 0) + COALESCE([Feb], 0) + COALESCE([Mar], 0) + COALESCE([Apr], 0) + COALESCE([May], 0) + COALESCE([Jun], 0) + COALESCE([Jul], 0) + COALESCE([Aug], 0) + COALESCE([Sep], 0) + COALESCE([Oct], 0) + COALESCE([Nov], 0) + COALESCE([Dec], 0) END AS Total
    , [Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec]
FROM
    (
        SELECT
            1 AS section
            , N'Opening Balance' AS item_type
            , NULL AS item
            , NULL AS company
            , LEFT(DATENAME(MONTH, DATEFROMPARTS(@year, m.m, 1)),3) AS [month]
            , (
                SELECT SUM(amount) FROM cte t WHERE t.period < DATEFROMPARTS(@year, m.m, 1)
                    AND t.record_side IS NULL AND t.item IS NULL AND t.company IS NULL AND t.period IS NOT NULL
                ) AS amount
        FROM
            (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) m(m)

        UNION
        SELECT
            5 AS section
            , N'Closing Balance' AS item_type
            , NULL AS item
            , NULL AS company
            , LEFT(DATENAME(MONTH, DATEFROMPARTS(@year, m.m, 1)),3) AS [month]
            , (
                SELECT SUM(amount) FROM cte t WHERE t.period <= DATEFROMPARTS(@year, m.m, 1)
                    AND t.record_side IS NULL AND t.item IS NULL AND t.company IS NULL AND t.period IS NOT NULL
                ) AS amount
        FROM
            (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) m(m)

        UNION
        SELECT
            CASE record_side WHEN 1 THEN 2 WHEN -1 THEN 3 ELSE 4 END AS section
            , CASE record_side WHEN 1 THEN N'Total Income' WHEN -1 THEN 'Total Expenses' ELSE N'Net Change' END AS item_type
            , item
            , company
            , [month]
            , COALESCE(record_side, 1) * amount AS amount
        FROM
            cte
        WHERE
            period IS NOT NULL
            AND [year] = @year
    ) s
    PIVOT
    (
        SUM(amount) FOR [month] IN ([Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec])
    ) p
ORDER BY
    sort_order

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Change handler for s01.usp_cash_by_months
-- =============================================

CREATE PROCEDURE [s01].[usp_cash_by_months_change]
    @column_name nvarchar(255)
    , @cell_number_value money = NULL
    , @section int = NULL
    , @item nvarchar(50) = NULL
    , @company nvarchar(50) = NULL
    , @year int = NULL
AS
BEGIN

SET NOCOUNT ON

DECLARE @month int = CHARINDEX(' ' + @column_name + ' ', '    Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ') / 4

IF @month < 1 RETURN

IF @year IS NULL SET @year = YEAR((SELECT MAX([date]) FROM s01.cashbook))
IF @year IS NULL SET @year = YEAR(GETDATE())

DECLARE @start_date date = DATEADD(MONTH, @month - 1, DATEADD(YEAR, @year - 1900, 0))
DECLARE @end_date date = DATEADD(DAY, -1, DATEADD(MONTH, 1, @start_date))

DECLARE @id int
DECLARE @count int

SELECT TOP 1
    @id = MAX(id)
    , @count = COUNT(*)
FROM
    s01.cashbook t
WHERE
    t.item = @item AND COALESCE(t.company, '') = COALESCE(@company, '') AND t.[date] BETWEEN @start_date AND @end_date

IF @count = 0
    BEGIN

    IF @item IS NULL
        BEGIN
        RAISERROR (N'Select a row with an item', 11, 1)
        RETURN
        END

    SELECT TOP 1
        @id = MAX(id)
    FROM
        s01.cashbook t
    WHERE
        t.item = @item AND COALESCE(t.company, '') = COALESCE(@company, '') AND t.[date] < @end_date

    DECLARE @date date
    DECLARE @account nvarchar(50)

    IF @id IS NOT NULL
        BEGIN
        SELECT @date = [date], @account = account FROM s01.cashbook WHERE id = @id
        IF DAY(@date) > DAY(@end_date)
            SET @date = @end_date
        ELSE
            SET @date = DATEFROMPARTS(@year, @month, DAY(@date))
        END
    ELSE
        SET @date = @end_date

    INSERT INTO s01.cashbook ([date], account, item, company, debit, credit)
        VALUES (@date, @account, @item, @company,
            CASE WHEN @section = 3 THEN NULL ELSE @cell_number_value END,
            CASE WHEN @section = 3 THEN @cell_number_value ELSE NULL END)
    RETURN
    END

IF @count > 1
    BEGIN
    RAISERROR (N'The cell has more than one underlying record', 11, 1)
    RETURN
    END

UPDATE s01.cashbook
SET
    debit = CASE WHEN @section = 3 THEN NULL ELSE @cell_number_value END
    , credit = CASE WHEN @section = 3 THEN @cell_number_value ELSE NULL END
WHERE
    id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE PROCEDURE [s01].[usp_cashbook]
    @account nvarchar(50) = NULL
    , @item nvarchar(50) = NULL
    , @company nvarchar(50) = NULL
AS
BEGIN

SELECT
    t.id
    , CAST(t.[date] AS datetime) AS [date]
    , t.account
    , t.item
    , t.company
    , t.debit
    , t.credit
FROM
    s01.cashbook t
WHERE
    COALESCE(t.account, '') = COALESCE(@account, t.account, '')
    AND COALESCE(t.item, '') = COALESCE(@item, t.item, '')
    AND COALESCE(t.company, '') = COALESCE(@company, t.company, '')

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE PROCEDURE [s01].[usp_cashbook2]
    @account nvarchar(50) = NULL
    , @item nvarchar(50) = NULL
    , @company nvarchar(50) = NULL
AS
BEGIN

SELECT
    t.id
    , CAST(t.[date] AS datetime) AS [date]
    , t.account
    , t.item
    , t.company
    , t.debit
    , t.credit
FROM
    s01.cashbook t
WHERE
    COALESCE(t.account, '') = COALESCE(@account, t.account, '')
    AND COALESCE(t.item, '') = COALESCE(@item, t.item, '')
    AND COALESCE(t.company, '') = COALESCE(@company, t.company, '')

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure deleted data from s01.cashbook
-- =============================================

CREATE PROCEDURE [s01].[usp_cashbook2_delete]
    @id int
AS
BEGIN

DELETE FROM s01.cashbook
WHERE
    id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure inserts data into s01.cashbook
-- =============================================

CREATE PROCEDURE [s01].[usp_cashbook2_insert]
    @date date = NULL
    , @account nvarchar(50) = NULL
    , @item nvarchar(50) = NULL
    , @company nvarchar(50) = NULL
    , @debit money = NULL
    , @credit money = NULL
AS
BEGIN

INSERT INTO s01.cashbook
    ( [date]
    , account
    , item
    , company
    , debit
    , credit
    )
VALUES
    ( @date
    , @account
    , @item
    , @company
    , @debit
    , @credit
    )

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure updates data of s01.cashbook
-- =============================================

CREATE PROCEDURE [s01].[usp_cashbook2_update]
    @id int
    , @date date = NULL
    , @account nvarchar(50) = NULL
    , @item nvarchar(50) = NULL
    , @company nvarchar(50) = NULL
    , @debit money = NULL
    , @credit money = NULL
AS
BEGIN

UPDATE s01.cashbook
SET
    [date] = @date
    , account = @account
    , item = @item
    , company = @company
    , debit = @debit
    , credit = @credit
WHERE
    id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE PROCEDURE [s01].[usp_cashbook3]
    @account nvarchar(50) = NULL
    , @item nvarchar(50) = NULL
    , @company nvarchar(50) = NULL
AS
BEGIN

SELECT
    t.id
    , CAST(t.[date] AS datetime) AS [date]
    , t.account
    , t.item
    , t.company
    , t.debit
    , t.credit
FROM
    s01.cashbook t
WHERE
    COALESCE(t.account, '') = COALESCE(@account, t.account, '')
    AND COALESCE(t.item, '') = COALESCE(@item, t.item, '')
    AND COALESCE(t.company, '') = COALESCE(@company, t.company, '')

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure processes cell changes of s01.usp_cashbook
-- =============================================

CREATE PROCEDURE [s01].[usp_cashbook3_change]
    @column_name nvarchar(128) = NULL
    , @cell_value nvarchar(255) = NULL
    , @cell_number_value money = NULL
    , @cell_datetime_value datetime = NULL
    , @id int = NULL
AS
BEGIN

IF @column_name = N'id'
    RETURN

ELSE IF @column_name = N'date'
    BEGIN
    IF @cell_number_value IS NULL AND @cell_value IS NOT NULL
        RAISERROR (N'Date requires a date value', 11, 1)

    UPDATE s01.cashbook SET [date] = @cell_datetime_value WHERE id = @id
    END

ELSE IF @column_name = N'account'
    UPDATE s01.cashbook SET account = @cell_value WHERE id = @id

ELSE IF @column_name = N'item'
    UPDATE s01.cashbook SET item = @cell_value WHERE id = @id

ELSE IF @column_name = N'company'
    UPDATE s01.cashbook SET company = @cell_value WHERE id = @id

ELSE IF @column_name = N'debit'
    BEGIN
    IF @cell_number_value IS NULL AND @cell_value IS NOT NULL
        RAISERROR (N'Debit requires a number value', 11, 1)

    UPDATE s01.cashbook SET debit = @cell_number_value WHERE id = @id
    END

ELSE IF @column_name = N'credit'
    BEGIN
    IF @cell_number_value IS NULL AND @cell_value IS NOT NULL
        RAISERROR (N'Credit requires a number value', 11, 1)

    UPDATE s01.cashbook SET credit = @cell_number_value WHERE id = @id
    END

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE PROCEDURE [s01].[usp_cashbook4]
    @account nvarchar(50) = NULL
    , @item nvarchar(50) = NULL
    , @company nvarchar(50) = NULL
AS
BEGIN

SELECT
    t.id
    , CAST(t.[date] AS datetime) AS [date]
    , t.account
    , t.item
    , t.company
    , t.debit
    , t.credit
FROM
    s01.cashbook t
WHERE
    COALESCE(t.account, '') = COALESCE(@account, t.account, '')
    AND COALESCE(t.item, '') = COALESCE(@item, t.item, '')
    AND COALESCE(t.company, '') = COALESCE(@company, t.company, '')

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: MERGE procedure for cash book
-- =============================================

CREATE PROCEDURE [s01].[usp_cashbook4_merge]
    @id int
    , @date date = NULL
    , @account nvarchar(50) = NULL
    , @item nvarchar(50) = NULL
    , @company nvarchar(50) = NULL
    , @debit money = NULL
    , @credit money = NULL
AS
BEGIN

UPDATE s01.cashbook
SET
    [date] = @date
    , account = @account
    , item = @item
    , company = @company
    , debit = @debit
    , credit = @credit
WHERE
    id = @id

IF @@ROWCOUNT = 0
INSERT INTO s01.cashbook
    ( [date]
    , account
    , item
    , company
    , debit
    , credit
    )
VALUES
    ( @date
    , @account
    , @item
    , @company
    , @debit
    , @credit
    )

END


GO

SET IDENTITY_INSERT s01.cashbook ON;
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (1, '20240110', N'Bank', N'Revenue', N'Customer C1', 200000, NULL);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (2, '20240110', N'Bank', N'Expenses', N'Supplier S1', NULL, 50000);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (3, '20240131', N'Bank', N'Payroll', NULL, NULL, 85000);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (4, '20240131', N'Bank', N'Taxes', N'Individual Income Tax', NULL, 15000);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (5, '20240131', N'Bank', N'Taxes', N'Payroll Taxes', NULL, 15000);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (6, '20240210', N'Bank', N'Revenue', N'Customer C1', 300000, NULL);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (7, '20240210', N'Bank', N'Revenue', N'Customer C2', 100000, NULL);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (8, '20240210', N'Bank', N'Expenses', N'Supplier S1', NULL, 100000);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (9, '20240210', N'Bank', N'Expenses', N'Supplier S2', NULL, 50000);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (10, '20240228', N'Bank', N'Payroll', NULL, NULL, 85000);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (11, '20240228', N'Bank', N'Taxes', N'Individual Income Tax', NULL, 15000);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (12, '20240228', N'Bank', N'Taxes', N'Payroll Taxes', NULL, 15000);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (13, '20240310', N'Bank', N'Revenue', N'Customer C1', 300000, NULL);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (14, '20240310', N'Bank', N'Revenue', N'Customer C2', 200000, NULL);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (15, '20240310', N'Bank', N'Revenue', N'Customer C3', 100000, NULL);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (16, '20240315', N'Bank', N'Taxes', N'Corporate Income Tax', NULL, 100000);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (17, '20240331', N'Bank', N'Payroll', NULL, NULL, 170000);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (18, '20240331', N'Bank', N'Taxes', N'Individual Income Tax', NULL, 30000);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (19, '20240331', N'Bank', N'Taxes', N'Payroll Taxes', NULL, 30000);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (20, '20240331', N'Bank', N'Expenses', N'Supplier S1', NULL, 100000);
INSERT INTO s01.cashbook (id, date, account, item, company, debit, credit) VALUES (21, '20240331', N'Bank', N'Expenses', N'Supplier S2', NULL, 50000);
SET IDENTITY_INSERT s01.cashbook OFF;
GO

SET IDENTITY_INSERT s01.formats ON;
INSERT INTO s01.formats (ID, TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (1, N's01', N'usp_cash_by_months', N'<table name="s01.usp_cash_by_months"><columnFormats><column name="" property="ListObjectName" value="cash_by_months" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="sort_order" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="sort_order" property="Address" value="$C$4" type="String"/><column name="sort_order" property="NumberFormat" value="General" type="String"/><column name="section" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="section" property="Address" value="$D$4" type="String"/><column name="section" property="NumberFormat" value="General" type="String"/><column name="level" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="level" property="Address" value="$E$4" type="String"/><column name="level" property="NumberFormat" value="General" type="String"/><column name="item" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="item" property="Address" value="$F$4" type="String"/><column name="item" property="NumberFormat" value="General" type="String"/><column name="company" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="company" property="Address" value="$G$4" type="String"/><column name="company" property="NumberFormat" value="General" type="String"/><column name="Name" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Name" property="Address" value="$H$4" type="String"/><column name="Name" property="ColumnWidth" value="21.43" type="Double"/><column name="Name" property="NumberFormat" value="General" type="String"/><column name="Total" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Total" property="Address" value="$I$4" type="String"/><column name="Total" property="ColumnWidth" value="8.43" type="Double"/><column name="Total" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String"/><column name="Jan" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Jan" property="Address" value="$J$4" type="String"/><column name="Jan" property="ColumnWidth" value="10" type="Double"/><column name="Jan" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String"/><column name="Feb" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Feb" property="Address" value="$K$4" type="String"/><column name="Feb" property="ColumnWidth" value="10" type="Double"/><column name="Feb" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String"/><column name="Mar" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Mar" property="Address" value="$L$4" type="String"/><column name="Mar" property="ColumnWidth" value="10" type="Double"/><column name="Mar" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String"/><column name="Apr" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Apr" property="Address" value="$M$4" type="String"/><column name="Apr" property="ColumnWidth" value="10" type="Double"/><column name="Apr" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String"/><column name="May" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="May" property="Address" value="$N$4" type="String"/><column name="May" property="ColumnWidth" value="10" type="Double"/><column name="May" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String"/><column name="Jun" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Jun" property="Address" value="$O$4" type="String"/><column name="Jun" property="ColumnWidth" value="10" type="Double"/><column name="Jun" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String"/><column name="Jul" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Jul" property="Address" value="$P$4" type="String"/><column name="Jul" property="ColumnWidth" value="10" type="Double"/><column name="Jul" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String"/><column name="Aug" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Aug" property="Address" value="$Q$4" type="String"/><column name="Aug" property="ColumnWidth" value="10" type="Double"/><column name="Aug" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String"/><column name="Sep" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Sep" property="Address" value="$R$4" type="String"/><column name="Sep" property="ColumnWidth" value="10" type="Double"/><column name="Sep" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String"/><column name="Oct" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Oct" property="Address" value="$S$4" type="String"/><column name="Oct" property="ColumnWidth" value="10" type="Double"/><column name="Oct" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String"/><column name="Nov" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Nov" property="Address" value="$T$4" type="String"/><column name="Nov" property="ColumnWidth" value="10" type="Double"/><column name="Nov" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String"/><column name="Dec" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Dec" property="Address" value="$U$4" type="String"/><column name="Dec" property="ColumnWidth" value="10" type="Double"/><column name="Dec" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String"/><column name="_RowNum" property="FormatConditions(1).AppliesToTable" value="True" type="Boolean"/><column name="_RowNum" property="FormatConditions(1).AppliesTo.Address" value="$B$4:$U$20" type="String"/><column name="_RowNum" property="FormatConditions(1).Type" value="2" type="Double"/><column name="_RowNum" property="FormatConditions(1).Priority" value="3" type="Double"/><column name="_RowNum" property="FormatConditions(1).Formula1" value="=$E4&lt;2" type="String"/><column name="_RowNum" property="FormatConditions(1).Font.Bold" value="True" type="Boolean"/><column name="_RowNum" property="FormatConditions(2).AppliesToTable" value="True" type="Boolean"/><column name="_RowNum" property="FormatConditions(2).AppliesTo.Address" value="$B$4:$U$20" type="String"/><column name="_RowNum" property="FormatConditions(2).Type" value="2" type="Double"/><column name="_RowNum" property="FormatConditions(2).Priority" value="4" type="Double"/><column name="_RowNum" property="FormatConditions(2).Formula1" value="=AND($E4=0,$D4&gt;1,$D4&lt;5)" type="String"/><column name="_RowNum" property="FormatConditions(2).Font.Bold" value="True" type="Boolean"/><column name="_RowNum" property="FormatConditions(2).Font.Color" value="16777215" type="Double"/><column name="_RowNum" property="FormatConditions(2).Font.ThemeColor" value="1" type="Double"/><column name="_RowNum" property="FormatConditions(2).Font.TintAndShade" value="0" type="Double"/><column name="_RowNum" property="FormatConditions(2).Interior.Color" value="6773025" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats><views><view name="All columns"><column name="" property="ListObjectName" value="cash_by_month" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="sort_order" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="section" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="level" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Name" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Jan" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Feb" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Mar" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Apr" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="May" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Jun" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Jul" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Aug" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Sep" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Oct" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Nov" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Dec" property="EntireColumn.Hidden" value="False" type="Boolean"/></view><view name="Default"><column name="" property="ListObjectName" value="cash_by_month" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="sort_order" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="section" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="level" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="Name" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Jan" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Feb" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Mar" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Apr" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="May" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Jun" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Jul" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Aug" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Sep" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Oct" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Nov" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="Dec" property="EntireColumn.Hidden" value="False" type="Boolean"/></view></views></table>');
INSERT INTO s01.formats (ID, TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (2, N's01', N'cashbook', N'<table name="s01.cashbook"><columnFormats><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="Address" value="$C$4" type="String"/><column name="id" property="ColumnWidth" value="4.29" type="Double"/><column name="id" property="NumberFormat" value="General" type="String"/><column name="id" property="Validation.Type" value="1" type="Double"/><column name="id" property="Validation.Operator" value="1" type="Double"/><column name="id" property="Validation.Formula1" value="-2147483648" type="String"/><column name="id" property="Validation.Formula2" value="2147483647" type="String"/><column name="id" property="Validation.AlertStyle" value="1" type="Double"/><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="id" property="Validation.ShowInput" value="True" type="Boolean"/><column name="id" property="Validation.ShowError" value="True" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="Address" value="$D$4" type="String"/><column name="date" property="ColumnWidth" value="11.43" type="Double"/><column name="date" property="NumberFormat" value="m/d/yyyy" type="String"/><column name="date" property="Validation.Type" value="4" type="Double"/><column name="date" property="Validation.Operator" value="5" type="Double"/><column name="date" property="Validation.Formula1" value="12/31/1899" type="String"/><column name="date" property="Validation.AlertStyle" value="1" type="Double"/><column name="date" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="date" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="date" property="Validation.ShowInput" value="True" type="Boolean"/><column name="date" property="Validation.ShowError" value="True" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="Address" value="$E$4" type="String"/><column name="account" property="ColumnWidth" value="12.14" type="Double"/><column name="account" property="NumberFormat" value="General" type="String"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="Address" value="$F$4" type="String"/><column name="item" property="ColumnWidth" value="20.71" type="Double"/><column name="item" property="NumberFormat" value="General" type="String"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="Address" value="$G$4" type="String"/><column name="company" property="ColumnWidth" value="20.71" type="Double"/><column name="company" property="NumberFormat" value="General" type="String"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="Address" value="$H$4" type="String"/><column name="debit" property="ColumnWidth" value="11.43" type="Double"/><column name="debit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String"/><column name="debit" property="Validation.Type" value="2" type="Double"/><column name="debit" property="Validation.Operator" value="4" type="Double"/><column name="debit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String"/><column name="debit" property="Validation.AlertStyle" value="1" type="Double"/><column name="debit" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="debit" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="debit" property="Validation.ShowInput" value="True" type="Boolean"/><column name="debit" property="Validation.ShowError" value="True" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="Address" value="$I$4" type="String"/><column name="credit" property="ColumnWidth" value="11.43" type="Double"/><column name="credit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String"/><column name="credit" property="Validation.Type" value="2" type="Double"/><column name="credit" property="Validation.Operator" value="4" type="Double"/><column name="credit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String"/><column name="credit" property="Validation.AlertStyle" value="1" type="Double"/><column name="credit" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="credit" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="credit" property="Validation.ShowInput" value="True" type="Boolean"/><column name="credit" property="Validation.ShowError" value="True" type="Boolean"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/></view><view name="Incomes"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String"/></view><view name="Expenses"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String"/></view></views></table>');
INSERT INTO s01.formats (ID, TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (3, N's01', N'view_cashbook', N'<table name="s01.view_cashbook"><columnFormats><column name="" property="ListObjectName" value="view_cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="Address" value="$C$4" type="String"/><column name="id" property="ColumnWidth" value="4.29" type="Double"/><column name="id" property="NumberFormat" value="General" type="String"/><column name="id" property="Validation.Type" value="1" type="Double"/><column name="id" property="Validation.Operator" value="1" type="Double"/><column name="id" property="Validation.Formula1" value="-2147483648" type="String"/><column name="id" property="Validation.Formula2" value="2147483647" type="String"/><column name="id" property="Validation.AlertStyle" value="1" type="Double"/><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="id" property="Validation.ShowInput" value="True" type="Boolean"/><column name="id" property="Validation.ShowError" value="True" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="Address" value="$D$4" type="String"/><column name="date" property="ColumnWidth" value="11.43" type="Double"/><column name="date" property="NumberFormat" value="m/d/yyyy" type="String"/><column name="date" property="Validation.Type" value="4" type="Double"/><column name="date" property="Validation.Operator" value="5" type="Double"/><column name="date" property="Validation.Formula1" value="12/31/1899" type="String"/><column name="date" property="Validation.AlertStyle" value="1" type="Double"/><column name="date" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="date" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="date" property="Validation.ShowInput" value="True" type="Boolean"/><column name="date" property="Validation.ShowError" value="True" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="Address" value="$E$4" type="String"/><column name="account" property="ColumnWidth" value="12.14" type="Double"/><column name="account" property="NumberFormat" value="General" type="String"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="Address" value="$F$4" type="String"/><column name="item" property="ColumnWidth" value="20.71" type="Double"/><column name="item" property="NumberFormat" value="General" type="String"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="Address" value="$G$4" type="String"/><column name="company" property="ColumnWidth" value="20.71" type="Double"/><column name="company" property="NumberFormat" value="General" type="String"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="Address" value="$H$4" type="String"/><column name="debit" property="ColumnWidth" value="11.43" type="Double"/><column name="debit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String"/><column name="debit" property="Validation.Type" value="2" type="Double"/><column name="debit" property="Validation.Operator" value="4" type="Double"/><column name="debit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String"/><column name="debit" property="Validation.AlertStyle" value="1" type="Double"/><column name="debit" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="debit" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="debit" property="Validation.ShowInput" value="True" type="Boolean"/><column name="debit" property="Validation.ShowError" value="True" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="Address" value="$I$4" type="String"/><column name="credit" property="ColumnWidth" value="11.43" type="Double"/><column name="credit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String"/><column name="credit" property="Validation.Type" value="2" type="Double"/><column name="credit" property="Validation.Operator" value="4" type="Double"/><column name="credit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String"/><column name="credit" property="Validation.AlertStyle" value="1" type="Double"/><column name="credit" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="credit" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="credit" property="Validation.ShowInput" value="True" type="Boolean"/><column name="credit" property="Validation.ShowError" value="True" type="Boolean"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/></view><view name="Incomes"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String"/></view><view name="Expenses"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String"/></view></views></table>');
INSERT INTO s01.formats (ID, TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (4, N's01', N'usp_cashbook', N'<table name="s01.usp_cashbook"><columnFormats><column name="" property="ListObjectName" value="usp_cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="Address" value="$C$4" type="String"/><column name="id" property="ColumnWidth" value="4.29" type="Double"/><column name="id" property="NumberFormat" value="General" type="String"/><column name="id" property="Validation.Type" value="1" type="Double"/><column name="id" property="Validation.Operator" value="1" type="Double"/><column name="id" property="Validation.Formula1" value="-2147483648" type="String"/><column name="id" property="Validation.Formula2" value="2147483647" type="String"/><column name="id" property="Validation.AlertStyle" value="1" type="Double"/><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="id" property="Validation.ShowInput" value="True" type="Boolean"/><column name="id" property="Validation.ShowError" value="True" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="Address" value="$D$4" type="String"/><column name="date" property="ColumnWidth" value="11.43" type="Double"/><column name="date" property="NumberFormat" value="m/d/yyyy" type="String"/><column name="date" property="Validation.Type" value="4" type="Double"/><column name="date" property="Validation.Operator" value="5" type="Double"/><column name="date" property="Validation.Formula1" value="12/31/1899" type="String"/><column name="date" property="Validation.AlertStyle" value="1" type="Double"/><column name="date" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="date" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="date" property="Validation.ShowInput" value="True" type="Boolean"/><column name="date" property="Validation.ShowError" value="True" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="Address" value="$E$4" type="String"/><column name="account" property="ColumnWidth" value="12.14" type="Double"/><column name="account" property="NumberFormat" value="General" type="String"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="Address" value="$F$4" type="String"/><column name="item" property="ColumnWidth" value="20.71" type="Double"/><column name="item" property="NumberFormat" value="General" type="String"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="Address" value="$G$4" type="String"/><column name="company" property="ColumnWidth" value="20.71" type="Double"/><column name="company" property="NumberFormat" value="General" type="String"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="Address" value="$H$4" type="String"/><column name="debit" property="ColumnWidth" value="11.43" type="Double"/><column name="debit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String"/><column name="debit" property="Validation.Type" value="2" type="Double"/><column name="debit" property="Validation.Operator" value="4" type="Double"/><column name="debit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String"/><column name="debit" property="Validation.AlertStyle" value="1" type="Double"/><column name="debit" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="debit" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="debit" property="Validation.ShowInput" value="True" type="Boolean"/><column name="debit" property="Validation.ShowError" value="True" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="Address" value="$I$4" type="String"/><column name="credit" property="ColumnWidth" value="11.43" type="Double"/><column name="credit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String"/><column name="credit" property="Validation.Type" value="2" type="Double"/><column name="credit" property="Validation.Operator" value="4" type="Double"/><column name="credit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String"/><column name="credit" property="Validation.AlertStyle" value="1" type="Double"/><column name="credit" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="credit" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="credit" property="Validation.ShowInput" value="True" type="Boolean"/><column name="credit" property="Validation.ShowError" value="True" type="Boolean"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/></view><view name="Incomes"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String"/></view><view name="Expenses"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String"/></view></views></table>');
INSERT INTO s01.formats (ID, TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (5, N's01', N'usp_cashbook2', N'<table name="s01.usp_cashbook2"><columnFormats><column name="" property="ListObjectName" value="usp_cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="Address" value="$C$4" type="String"/><column name="id" property="ColumnWidth" value="4.29" type="Double"/><column name="id" property="NumberFormat" value="General" type="String"/><column name="id" property="Validation.Type" value="1" type="Double"/><column name="id" property="Validation.Operator" value="1" type="Double"/><column name="id" property="Validation.Formula1" value="-2147483648" type="String"/><column name="id" property="Validation.Formula2" value="2147483647" type="String"/><column name="id" property="Validation.AlertStyle" value="1" type="Double"/><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="id" property="Validation.ShowInput" value="True" type="Boolean"/><column name="id" property="Validation.ShowError" value="True" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="Address" value="$D$4" type="String"/><column name="date" property="ColumnWidth" value="11.43" type="Double"/><column name="date" property="NumberFormat" value="m/d/yyyy" type="String"/><column name="date" property="Validation.Type" value="4" type="Double"/><column name="date" property="Validation.Operator" value="5" type="Double"/><column name="date" property="Validation.Formula1" value="12/31/1899" type="String"/><column name="date" property="Validation.AlertStyle" value="1" type="Double"/><column name="date" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="date" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="date" property="Validation.ShowInput" value="True" type="Boolean"/><column name="date" property="Validation.ShowError" value="True" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="Address" value="$E$4" type="String"/><column name="account" property="ColumnWidth" value="12.14" type="Double"/><column name="account" property="NumberFormat" value="General" type="String"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="Address" value="$F$4" type="String"/><column name="item" property="ColumnWidth" value="20.71" type="Double"/><column name="item" property="NumberFormat" value="General" type="String"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="Address" value="$G$4" type="String"/><column name="company" property="ColumnWidth" value="20.71" type="Double"/><column name="company" property="NumberFormat" value="General" type="String"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="Address" value="$H$4" type="String"/><column name="debit" property="ColumnWidth" value="11.43" type="Double"/><column name="debit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String"/><column name="debit" property="Validation.Type" value="2" type="Double"/><column name="debit" property="Validation.Operator" value="4" type="Double"/><column name="debit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String"/><column name="debit" property="Validation.AlertStyle" value="1" type="Double"/><column name="debit" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="debit" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="debit" property="Validation.ShowInput" value="True" type="Boolean"/><column name="debit" property="Validation.ShowError" value="True" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="Address" value="$I$4" type="String"/><column name="credit" property="ColumnWidth" value="11.43" type="Double"/><column name="credit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String"/><column name="credit" property="Validation.Type" value="2" type="Double"/><column name="credit" property="Validation.Operator" value="4" type="Double"/><column name="credit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String"/><column name="credit" property="Validation.AlertStyle" value="1" type="Double"/><column name="credit" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="credit" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="credit" property="Validation.ShowInput" value="True" type="Boolean"/><column name="credit" property="Validation.ShowError" value="True" type="Boolean"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/></view><view name="Incomes"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String"/></view><view name="Expenses"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String"/></view></views></table>');
INSERT INTO s01.formats (ID, TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (6, N's01', N'usp_cashbook3', N'<table name="s01.usp_cashbook3"><columnFormats><column name="" property="ListObjectName" value="usp_cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="Address" value="$C$4" type="String"/><column name="id" property="ColumnWidth" value="4.29" type="Double"/><column name="id" property="NumberFormat" value="General" type="String"/><column name="id" property="Validation.Type" value="1" type="Double"/><column name="id" property="Validation.Operator" value="1" type="Double"/><column name="id" property="Validation.Formula1" value="-2147483648" type="String"/><column name="id" property="Validation.Formula2" value="2147483647" type="String"/><column name="id" property="Validation.AlertStyle" value="1" type="Double"/><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="id" property="Validation.ShowInput" value="True" type="Boolean"/><column name="id" property="Validation.ShowError" value="True" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="Address" value="$D$4" type="String"/><column name="date" property="ColumnWidth" value="11.43" type="Double"/><column name="date" property="NumberFormat" value="m/d/yyyy" type="String"/><column name="date" property="Validation.Type" value="4" type="Double"/><column name="date" property="Validation.Operator" value="5" type="Double"/><column name="date" property="Validation.Formula1" value="12/31/1899" type="String"/><column name="date" property="Validation.AlertStyle" value="1" type="Double"/><column name="date" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="date" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="date" property="Validation.ShowInput" value="True" type="Boolean"/><column name="date" property="Validation.ShowError" value="True" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="Address" value="$E$4" type="String"/><column name="account" property="ColumnWidth" value="12.14" type="Double"/><column name="account" property="NumberFormat" value="General" type="String"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="Address" value="$F$4" type="String"/><column name="item" property="ColumnWidth" value="20.71" type="Double"/><column name="item" property="NumberFormat" value="General" type="String"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="Address" value="$G$4" type="String"/><column name="company" property="ColumnWidth" value="20.71" type="Double"/><column name="company" property="NumberFormat" value="General" type="String"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="Address" value="$H$4" type="String"/><column name="debit" property="ColumnWidth" value="11.43" type="Double"/><column name="debit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String"/><column name="debit" property="Validation.Type" value="2" type="Double"/><column name="debit" property="Validation.Operator" value="4" type="Double"/><column name="debit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String"/><column name="debit" property="Validation.AlertStyle" value="1" type="Double"/><column name="debit" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="debit" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="debit" property="Validation.ShowInput" value="True" type="Boolean"/><column name="debit" property="Validation.ShowError" value="True" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="Address" value="$I$4" type="String"/><column name="credit" property="ColumnWidth" value="11.43" type="Double"/><column name="credit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String"/><column name="credit" property="Validation.Type" value="2" type="Double"/><column name="credit" property="Validation.Operator" value="4" type="Double"/><column name="credit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String"/><column name="credit" property="Validation.AlertStyle" value="1" type="Double"/><column name="credit" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="credit" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="credit" property="Validation.ShowInput" value="True" type="Boolean"/><column name="credit" property="Validation.ShowError" value="True" type="Boolean"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/></view><view name="Incomes"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String"/></view><view name="Expenses"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String"/></view></views></table>');
INSERT INTO s01.formats (ID, TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (7, N's01', N'usp_cashbook4', N'<table name="s01.usp_cashbook4"><columnFormats><column name="" property="ListObjectName" value="usp_cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="Address" value="$C$4" type="String"/><column name="id" property="ColumnWidth" value="4.29" type="Double"/><column name="id" property="NumberFormat" value="General" type="String"/><column name="id" property="Validation.Type" value="1" type="Double"/><column name="id" property="Validation.Operator" value="1" type="Double"/><column name="id" property="Validation.Formula1" value="-2147483648" type="String"/><column name="id" property="Validation.Formula2" value="2147483647" type="String"/><column name="id" property="Validation.AlertStyle" value="1" type="Double"/><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="id" property="Validation.ShowInput" value="True" type="Boolean"/><column name="id" property="Validation.ShowError" value="True" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="Address" value="$D$4" type="String"/><column name="date" property="ColumnWidth" value="11.43" type="Double"/><column name="date" property="NumberFormat" value="m/d/yyyy" type="String"/><column name="date" property="Validation.Type" value="4" type="Double"/><column name="date" property="Validation.Operator" value="5" type="Double"/><column name="date" property="Validation.Formula1" value="12/31/1899" type="String"/><column name="date" property="Validation.AlertStyle" value="1" type="Double"/><column name="date" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="date" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="date" property="Validation.ShowInput" value="True" type="Boolean"/><column name="date" property="Validation.ShowError" value="True" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="Address" value="$E$4" type="String"/><column name="account" property="ColumnWidth" value="12.14" type="Double"/><column name="account" property="NumberFormat" value="General" type="String"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="Address" value="$F$4" type="String"/><column name="item" property="ColumnWidth" value="20.71" type="Double"/><column name="item" property="NumberFormat" value="General" type="String"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="Address" value="$G$4" type="String"/><column name="company" property="ColumnWidth" value="20.71" type="Double"/><column name="company" property="NumberFormat" value="General" type="String"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="Address" value="$H$4" type="String"/><column name="debit" property="ColumnWidth" value="11.43" type="Double"/><column name="debit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String"/><column name="debit" property="Validation.Type" value="2" type="Double"/><column name="debit" property="Validation.Operator" value="4" type="Double"/><column name="debit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String"/><column name="debit" property="Validation.AlertStyle" value="1" type="Double"/><column name="debit" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="debit" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="debit" property="Validation.ShowInput" value="True" type="Boolean"/><column name="debit" property="Validation.ShowError" value="True" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="Address" value="$I$4" type="String"/><column name="credit" property="ColumnWidth" value="11.43" type="Double"/><column name="credit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String"/><column name="credit" property="Validation.Type" value="2" type="Double"/><column name="credit" property="Validation.Operator" value="4" type="Double"/><column name="credit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String"/><column name="credit" property="Validation.AlertStyle" value="1" type="Double"/><column name="credit" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="credit" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="credit" property="Validation.ShowInput" value="True" type="Boolean"/><column name="credit" property="Validation.ShowError" value="True" type="Boolean"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/></view><view name="Incomes"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String"/></view><view name="Expenses"><column name="" property="ListObjectName" value="cashbook" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="account" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="credit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String"/></view></views></table>');
SET IDENTITY_INSERT s01.formats OFF;
GO

SET IDENTITY_INSERT s01.workbooks ON;
INSERT INTO s01.workbooks (ID, NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (1, N'Sample 01 - Basic Features - User1.xlsx', N'https://www.savetodb.com/downloads/v10/sample01-user1.xlsx', N'cashbook=s01.cashbook,(Default),False,$B$3,,{"Parameters":{"account":null,"item":null,"company":null},"ListObjectName":"cashbook"}
view_cashbook=s01.view_cashbook,(Default),False,$B$3,,{"Parameters":{"account":null,"item":null,"company":null},"ListObjectName":"view_cashbook"}
usp_cashbook=s01.usp_cashbook,(Default),False,$B$3,,{"Parameters":{"account":null,"item":null,"company":null},"ListObjectName":"usp_cashbook"}
usp_cashbook2=s01.usp_cashbook2,(Default),False,$B$3,,{"Parameters":{"account":null,"item":null,"company":null},"ListObjectName":"usp_cashbook2"}
usp_cashbook3=s01.usp_cashbook3,(Default),False,$B$3,,{"Parameters":{"account":null,"item":null,"company":null},"ListObjectName":"usp_cashbook3"}
usp_cashbook4=s01.usp_cashbook4,(Default),False,$B$3,,{"Parameters":{"account":null,"item":null,"company":null},"ListObjectName":"usp_cashbook4"}
cash_by_months=s01.usp_cash_by_months,(Default),False,$B$3,,{"Parameters":{"year":2021},"ListObjectName":"cash_by_months"}', N's01');
INSERT INTO s01.workbooks (ID, NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (2, N'Sample 01 - Basic Features - User2 (Restricted).xlsx', N'https://www.savetodb.com/downloads/v10/sample01-user2.xlsx', N'cashbook=s01.cashbook,(Default),False,$B$3,,{"Parameters":{"account":null,"item":null,"company":null},"ListObjectName":"cashbook"}
view_cashbook=s01.view_cashbook,(Default),False,$B$3,,{"Parameters":{"account":null,"item":null,"company":null},"ListObjectName":"view_cashbook"}
usp_cashbook=s01.usp_cashbook,(Default),False,$B$3,,{"Parameters":{"account":null,"item":null,"company":null},"ListObjectName":"usp_cashbook"}
usp_cashbook2=s01.usp_cashbook2,(Default),False,$B$3,,{"Parameters":{"account":null,"item":null,"company":null},"ListObjectName":"usp_cashbook2"}
usp_cashbook3=s01.usp_cashbook3,(Default),False,$B$3,,{"Parameters":{"account":null,"item":null,"company":null},"ListObjectName":"usp_cashbook3"}
usp_cashbook4=s01.usp_cashbook4,(Default),False,$B$3,,{"Parameters":{"account":null,"item":null,"company":null},"ListObjectName":"usp_cashbook4"}
cash_by_months=s01.usp_cash_by_months,(Default),False,$B$3,,{"Parameters":{"year":2021},"ListObjectName":"cash_by_months"}', N's01');
SET IDENTITY_INSERT s01.workbooks OFF;
GO

print 'Application installed';
