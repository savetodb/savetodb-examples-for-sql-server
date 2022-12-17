-- =============================================
-- Application: Sample 02 - Advanced SaveToDB Features
-- Version 10.6, December 13, 2022
--
-- Copyright 2017-2022 Gartle LLC
--
-- License: MIT
--
-- Prerequisites: SaveToDB Framework 10.0 or higher
-- =============================================

SET NOCOUNT ON
GO

CREATE SCHEMA s02;
GO

CREATE TABLE s02.accounts (
    id int IDENTITY(1,1) NOT NULL
    , name nvarchar(50) NOT NULL
    , CONSTRAINT PK_accounts PRIMARY KEY (id)
    , CONSTRAINT IX_accounts_name UNIQUE (name)
);
GO

CREATE TABLE s02.companies (
    id int IDENTITY(1,1) NOT NULL
    , name nvarchar(50) NOT NULL
    , CONSTRAINT PK_companies PRIMARY KEY (id)
);
GO

CREATE INDEX IX_companies_name ON s02.companies (name);
GO

CREATE TABLE s02.items (
    id int IDENTITY(1,1) NOT NULL
    , name nvarchar(50) NOT NULL
    , CONSTRAINT PK_items PRIMARY KEY (id)
    , CONSTRAINT IX_items_name UNIQUE (name)
);
GO

CREATE TABLE s02.cashbook (
    id int IDENTITY(1,1) NOT NULL
    , date date NOT NULL
    , account_id int NOT NULL
    , item_id int NULL
    , company_id int NULL
    , debit money NULL
    , credit money NULL
    , checked bit NULL
    , CONSTRAINT PK_cashbook PRIMARY KEY (id)
);
GO

ALTER TABLE s02.cashbook ADD CONSTRAINT FK_cashbook_accounts FOREIGN KEY (account_id) REFERENCES s02.accounts (id) ON UPDATE CASCADE;
GO

ALTER TABLE s02.cashbook ADD CONSTRAINT FK_cashbook_companies FOREIGN KEY (company_id) REFERENCES s02.companies (id) ON UPDATE CASCADE;
GO

ALTER TABLE s02.cashbook ADD CONSTRAINT FK_cashbook_items FOREIGN KEY (item_id) REFERENCES s02.items (id) ON UPDATE CASCADE;
GO

CREATE TABLE s02.item_companies (
    item_id int NOT NULL
    , company_id int NOT NULL
    , CONSTRAINT PK_item_companies PRIMARY KEY (item_id, company_id)
);
GO

ALTER TABLE s02.item_companies ADD CONSTRAINT FK_item_companies_companies FOREIGN KEY (company_id) REFERENCES s02.companies (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

ALTER TABLE s02.item_companies ADD CONSTRAINT FK_item_companies_items FOREIGN KEY (item_id) REFERENCES s02.items (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE VIEW [s02].[view_cashbook]
AS

SELECT
    *
FROM
    s02.cashbook t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE VIEW [s02].[view_cashbook2]
AS

SELECT
    *
FROM
    s02.cashbook t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE VIEW [s02].[view_cashbook3]
AS

SELECT
    *
FROM
    s02.cashbook t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view select translations
-- =============================================

CREATE VIEW [s02].[view_translations]
AS

SELECT
    t.ID
    , t.TABLE_SCHEMA
    , t.TABLE_NAME
    , t.COLUMN_NAME
    , t.LANGUAGE_NAME
    , t.TRANSLATED_NAME
FROM
    xls.translations t
WHERE
    t.TABLE_SCHEMA = 's02'


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Online help actions
-- =============================================

CREATE VIEW [s02].[xl_actions_online_help]
AS
SELECT
    t.TABLE_SCHEMA
    , t.TABLE_NAME
    , CAST(NULL AS nvarchar(128)) AS COLUMN_NAME
    , 'Actions' AS EVENT_NAME
    , t.TABLE_SCHEMA AS HANDLER_SCHEMA
    , 'See Online Help' AS HANDLER_NAME
    , 'HTTP' AS HANDLER_TYPE
    , 'https://www.savetodb.com/samples/sample' + SUBSTRING(t.TABLE_SCHEMA, 2, 2) + '-' + t.TABLE_NAME + CASE WHEN USER_NAME() LIKE 'sample%' THEN '_' + USER_NAME() ELSE '' END AS HANDLER_CODE
    , CAST(NULL AS nvarchar(128)) AS TARGET_WORKSHEET
    , 1 AS MENU_ORDER
    , 0 AS EDIT_PARAMETERS
FROM
    INFORMATION_SCHEMA.TABLES t
WHERE
    t.TABLE_SCHEMA = 's02'
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
    , 'https://www.savetodb.com/samples/sample' + SUBSTRING(t.ROUTINE_SCHEMA, 2, 2) + '-' + t.ROUTINE_NAME+ CASE WHEN USER_NAME() LIKE 'sample%' THEN '_' + USER_NAME() ELSE '' END AS HANDLER_CODE
    , CAST(NULL AS nvarchar(128)) AS TARGET_WORKSHEET
    , 1 AS MENU_ORDER
    , 0 AS EDIT_PARAMETERS
FROM
    INFORMATION_SCHEMA.ROUTINES t
WHERE
    t.ROUTINE_SCHEMA = 's02'
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

CREATE PROCEDURE [s02].[usp_cash_by_months]
    @year int = NULL
    , @data_language varchar(10) = NULL
AS
BEGIN

SET NOCOUNT ON

IF @year IS NULL SET @year = YEAR((SELECT MAX([date]) FROM s02.cashbook))
IF @year IS NULL SET @year = YEAR(GETDATE())

SET LANGUAGE us_english;

WITH cte (record_side, item_id, company_id, period, [year], [month], [amount])
AS
    (
    SELECT
        CASE WHEN p.debit IS NOT NULL THEN 1 WHEN p.credit IS NOT NULL THEN -1 ELSE 0 END AS record_side
        , p.item_id
        , p.company_id
        , DATEADD(MONTH, DATEDIFF(MONTH, 0, p.[date]), 0) AS period
        , MAX(YEAR(p.[date])) AS [year]
        , MAX(LEFT(DATENAME(MONTH, p.[date]),3)) AS [month]
        , COALESCE(SUM(p.debit), 0) - COALESCE(SUM(p.credit), 0) AS amount
    FROM
        s02.cashbook p
    WHERE
        p.debit IS NOT NULL OR p.credit IS NOT NULL
    GROUP BY
        ROLLUP(DATEADD(MONTH, DATEDIFF(MONTH, 0, p.[date]), 0), CASE WHEN p.debit IS NOT NULL THEN 1 WHEN p.credit IS NOT NULL THEN -1 ELSE 0 END, p.item_id, p.company_id)
    )

SELECT
    ROW_NUMBER() OVER (ORDER BY section, item, company) AS sort_order
    , section
    , CASE WHEN item IS NULL THEN 0 WHEN company IS NULL THEN 1 ELSE 2 END AS [level]
    , item_id
    , company_id
    , COALESCE('    ' + COALESCE(t3.TRANSLATED_NAME, company), '  ' + COALESCE(t2.TRANSLATED_NAME, item), COALESCE(t1.TRANSLATED_NAME, item_type)) AS Name
    , CASE WHEN section = 1 THEN [Jan] WHEN section = 5 THEN [Dec] ELSE COALESCE([Jan], 0) + COALESCE([Feb], 0) + COALESCE([Mar], 0) + COALESCE([Apr], 0) + COALESCE([May], 0) + COALESCE([Jun], 0) + COALESCE([Jul], 0) + COALESCE([Aug], 0) + COALESCE([Sep], 0) + COALESCE([Oct], 0) + COALESCE([Nov], 0) + COALESCE([Dec], 0) END AS Total
    , [Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec]
FROM
    (
        SELECT
            1 AS section
            , N'Opening Balance' AS item_type
            , NULL AS item_id
            , NULL AS company_id
            , NULL AS item
            , NULL AS company
            , LEFT(DATENAME(MONTH, DATEFROMPARTS(@year, m.m, 1)),3) AS [month]
            , (
                SELECT SUM(amount) FROM cte t WHERE t.period < DATEFROMPARTS(@year, m.m, 1)
                    AND t.record_side IS NULL AND t.item_id IS NULL AND t.company_id IS NULL AND t.period IS NOT NULL
                ) AS amount
        FROM
            (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) m(m)

        UNION
        SELECT
            5 AS section
            , N'Closing Balance' AS item_type
            , NULL AS item_id
            , NULL AS company_id
            , NULL AS item
            , NULL AS company
            , LEFT(DATENAME(MONTH, DATEFROMPARTS(@year, m.m, 1)),3) AS [month]
            , (
                SELECT SUM(amount) FROM cte t WHERE t.period <= DATEFROMPARTS(@year, m.m, 1)
                    AND t.record_side IS NULL AND t.item_id IS NULL AND t.company_id IS NULL AND t.period IS NOT NULL
                ) AS amount
        FROM
            (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) m(m)

        UNION
        SELECT
            CASE record_side WHEN 1 THEN 2 WHEN -1 THEN 3 ELSE 4 END AS section
            , CASE record_side WHEN 1 THEN N'Total Income' WHEN -1 THEN 'Total Expenses' ELSE N'Net Change' END AS item_type
            , cte.item_id
            , cte.company_id
            , a.name AS item
            , c.name AS company
            , [month]
            , COALESCE(record_side, 1) * amount AS amount
        FROM
            cte
            LEFT OUTER JOIN s02.items a ON a.id = cte.item_id
            LEFT OUTER JOIN s02.companies c ON c.id = cte.company_id
        WHERE
            period IS NOT NULL
            AND [year] = @year
    ) s
    PIVOT
    (
        SUM(amount) FOR [month] IN ([Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec])
    ) p
    LEFT OUTER JOIN xls.translations t1 ON t1.TABLE_SCHEMA = 's02' AND t1.TABLE_NAME = 'strings'
            AND t1.LANGUAGE_NAME = @data_language AND t1.COLUMN_NAME = p.item_type
    LEFT OUTER JOIN xls.translations t2 ON t2.TABLE_SCHEMA = 's02' AND t2.TABLE_NAME = 'strings'
            AND t2.LANGUAGE_NAME = @data_language AND t2.COLUMN_NAME = p.item
    LEFT OUTER JOIN xls.translations t3 ON t3.TABLE_SCHEMA = 's02' AND t3.TABLE_NAME = 'strings'
            AND t3.LANGUAGE_NAME = @data_language AND t3.COLUMN_NAME = p.company
ORDER BY
    sort_order

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Change handler for s02.usp_cash_by_months
-- =============================================

CREATE PROCEDURE [s02].[usp_cash_by_months_change]
    @column_name nvarchar(255)
    , @cell_number_value money = NULL
    , @section int = NULL
    , @item_id int = NULL
    , @company_id int = NULL
    , @year int = NULL
AS
BEGIN

SET NOCOUNT ON

DECLARE @month int = CHARINDEX(' ' + @column_name + ' ', '    Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ') / 4

IF @month < 1 RETURN

IF @year IS NULL SET @year = YEAR((SELECT MAX([date]) FROM s02.cashbook))
IF @year IS NULL SET @year = YEAR(GETDATE())

DECLARE @start_date date = DATEADD(MONTH, @month - 1, DATEADD(YEAR, @year - 1900, 0))
DECLARE @end_date date = DATEADD(DAY, -1, DATEADD(MONTH, 1, @start_date))

DECLARE @id int
DECLARE @count int

SELECT TOP 1
    @id = MAX(id)
    , @count = COUNT(*)
FROM
    s02.cashbook t
WHERE
    t.item_id = @item_id AND COALESCE(t.company_id, 0) = COALESCE(@company_id, 0) AND t.[date] BETWEEN @start_date AND @end_date

IF @count = 0
    BEGIN
    IF @item_id IS NULL
        BEGIN
        RAISERROR (N'Select a row with an item', 11, 1)
        RETURN
        END

    SELECT TOP 1
        @id = MAX(id)
    FROM
        s02.cashbook t
    WHERE
        t.item_id = @item_id AND COALESCE(t.company_id, 0) = COALESCE(@company_id, 0) AND t.[date] < @end_date

    DECLARE @date date
    DECLARE @account_id int

    IF @id IS NOT NULL
        BEGIN
        SELECT @date = [date], @account_id = account_id FROM s02.cashbook WHERE id = @id
        IF DAY(@date) > DAY(@end_date)
            SET @date = @end_date
        ELSE
            SET @date = DATEFROMPARTS(@year, @month, DAY(@date))
        END
    ELSE
        SET @date = @end_date

    INSERT INTO s02.cashbook ([date], account_id, item_id, company_id, debit, credit)
        VALUES (@date, @account_id, @item_id, @company_id,
            CASE WHEN @section = 3 THEN NULL ELSE @cell_number_value END,
            CASE WHEN @section = 3 THEN @cell_number_value ELSE NULL END)
    RETURN
    END

IF @count > 1
    BEGIN
    RAISERROR (N'The cell has more than one underlying record', 11, 1)
    RETURN
    END

UPDATE s02.cashbook
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

CREATE PROCEDURE [s02].[usp_cashbook]
    @account_id int = NULL
    , @item_id int = NULL
    , @company_id int = NULL
AS
BEGIN

SET NOCOUNT ON

SELECT
    t.id
    , CAST(t.[date] AS datetime) AS [date]
    , t.account_id
    , t.item_id
    , t.company_id
    , t.debit
    , t.credit
    , t.checked
FROM
    s02.cashbook t
WHERE
    COALESCE(@account_id, t.account_id, -1) = COALESCE(t.account_id, -1)
    AND COALESCE(@item_id, t.item_id, -1) = COALESCE(t.item_id, -1)
    AND COALESCE(@company_id, t.company_id, -1) = COALESCE(t.company_id, -1)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE PROCEDURE [s02].[usp_cashbook2]
    @account_id int = NULL
    , @item_id int = NULL
    , @company_id int = NULL
    , @start_date date = NULL
    , @end_date date = NULL
    , @checked bit = NULL
AS
BEGIN

SET NOCOUNT ON

SELECT
    t.id
    , CAST(t.[date] AS datetime) AS [date]
    , t.account_id
    , t.item_id
    , t.company_id
    , t.debit
    , t.credit
    , t.checked
FROM
    s02.cashbook t
WHERE
    COALESCE(@account_id, t.account_id, -1) = COALESCE(t.account_id, -1)
    AND COALESCE(@item_id, t.item_id, -1) = COALESCE(t.item_id, -1)
    AND COALESCE(@company_id, t.company_id, -1) = COALESCE(t.company_id, -1)
    AND t.date BETWEEN COALESCE(@start_date, '20200101') AND COALESCE(@end_date, '20490101')
    AND (@checked IS NULL OR t.checked = @checked)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: DELETE procedure for cash book
-- =============================================

CREATE PROCEDURE [s02].[usp_cashbook2_delete]
    @id int = NULL
AS
BEGIN

DELETE FROM s02.cashbook WHERE id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: INSERT procedure for cash book
-- =============================================

CREATE PROCEDURE [s02].[usp_cashbook2_insert]
    @date date = NULL
    , @account_id int = NULL
    , @item_id int = NULL
    , @company_id int = NULL
    , @debit money = NULL
    , @credit money = NULL
    , @checked bit = NULL
AS
BEGIN

INSERT INTO s02.cashbook ([date], account_id, item_id, company_id, debit, credit, checked)
    VALUES (@date, @account_id, @item_id, @company_id, @debit, @credit, @checked)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: UPDATE procedure for cash book
-- =============================================

CREATE PROCEDURE [s02].[usp_cashbook2_update]
    @id int = NULL
    , @date date = NULL
    , @account_id int = NULL
    , @item_id int = NULL
    , @company_id int = NULL
    , @debit money = NULL
    , @credit money = NULL
    , @checked bit = NULL
AS
BEGIN

UPDATE s02.cashbook
SET
    [date] = @date,
    account_id = @account_id, item_id = @item_id, company_id = @company_id,
    debit = @debit, credit = @credit, checked = @checked
WHERE
    id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE PROCEDURE [s02].[usp_cashbook3]
    @account_id int = NULL
    , @item_id int = NULL
    , @company_id int = NULL
AS
BEGIN

SET NOCOUNT ON

SELECT
    t.id
    , CAST(t.[date] AS datetime) AS [date]
    , t.account_id
    , t.item_id
    , t.company_id
    , t.debit
    , t.credit
    , t.checked
FROM
    s02.cashbook t
WHERE
    COALESCE(@account_id, t.account_id, -1) = COALESCE(t.account_id, -1)
    AND COALESCE(@item_id, t.item_id, -1) = COALESCE(t.item_id, -1)
    AND COALESCE(@company_id, t.company_id, -1) = COALESCE(t.company_id, -1)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Change handler for s02.usp_cashbook3
-- =============================================

CREATE PROCEDURE [s02].[usp_cashbook3_change]
    @column_name nvarchar(255)
    , @cell_value nvarchar(255) = NULL
    , @cell_number_value money = NULL
    , @cell_datetime_value date = NULL
    , @id int = NULL
AS
BEGIN

IF @column_name = 'debit'
    UPDATE s02.cashbook SET debit = @cell_number_value WHERE id = @id
ELSE IF @column_name = 'credit'
    UPDATE s02.cashbook SET credit = @cell_number_value WHERE id = @id
ELSE IF @column_name = 'item_id'
    UPDATE s02.cashbook SET item_id = @cell_number_value WHERE id = @id
ELSE IF @column_name = 'company_id'
    UPDATE s02.cashbook SET company_id = @cell_number_value WHERE id = @id
ELSE IF @column_name = 'account_id'
    UPDATE s02.cashbook SET account_id = @cell_number_value WHERE id = @id
ELSE IF @column_name = 'date'
    UPDATE s02.cashbook SET [date] = @cell_datetime_value WHERE id = @id
ELSE IF @column_name = 'checked'
    UPDATE s02.cashbook SET [checked] = @cell_number_value WHERE id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE PROCEDURE [s02].[usp_cashbook4]
    @account_id int = NULL
    , @item_id int = NULL
    , @company_id int = NULL
AS
BEGIN

SET NOCOUNT ON

SELECT
    t.id
    , CAST(t.[date] AS datetime) AS [date]
    , t.account_id
    , t.item_id
    , t.company_id
    , t.debit
    , t.credit
    , t.checked
FROM
    s02.cashbook t
WHERE
    COALESCE(@account_id, t.account_id, -1) = COALESCE(t.account_id, -1)
    AND COALESCE(@item_id, t.item_id, -1) = COALESCE(t.item_id, -1)
    AND COALESCE(@company_id, t.company_id, -1) = COALESCE(t.company_id, -1)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: MERGE procedure for cash book
-- =============================================

CREATE PROCEDURE [s02].[usp_cashbook4_merge]
    @id int = NULL
    , @date date = NULL
    , @account_id int = NULL
    , @item_id int = NULL
    , @company_id int = NULL
    , @debit money = NULL
    , @credit money = NULL
    , @checked bit = NULL
AS
BEGIN

UPDATE s02.cashbook
SET
    [date] = @date, account_id = @account_id, item_id = @item_id, company_id = @company_id,
    debit = @debit, credit = @credit, checked = @checked
WHERE
    id = @id

IF @@ROWCOUNT = 0
    INSERT INTO s02.cashbook ([date], account_id, item_id, company_id, debit, credit, checked)
        VALUES (@date, @account_id, @item_id, @company_id, @debit, @credit, @checked)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE PROCEDURE [s02].[usp_cashbook5]
    @account_id int = NULL
    , @item_id int = NULL
    , @company_id int = NULL
    , @year int = NULL
    , @month int = NULL
    , @day int = NULL
AS
BEGIN

SET NOCOUNT ON

DECLARE @start_date date = '20010101'
DECLARE @end_date date = '20990101'

IF @year IS NULL AND (@month IS NOT NULL OR @day IS NOT NULL) SET @year = YEAR(GETDATE())

IF @year IS NOT NULL
    BEGIN
    IF @month IS NULL AND @day IS NULL
        BEGIN
        SET @start_date = DATEFROMPARTS(@year, 1, 1)
        SET @end_date = DATEFROMPARTS(@year, 12, 31)
        END
    ELSE IF @month IS NOT NULL AND @day IS NULL
        BEGIN
        SET @start_date = DATEFROMPARTS(@year, @month, 1)
        SET @end_date = DATEADD(DAY, -1, DATEADD(MONTH, 1, @start_date))
        END
    ELSE
        BEGIN
        SET @start_date = DATEFROMPARTS(@year, COALESCE(@month, MONTH(GETDATE())), @day)
        SET @end_date = @start_date
        END
    END

SELECT
    *
FROM
    (
        SELECT
            0 AS id
            , NULL AS [date]
            , NULL AS account_id
            , NULL AS item_id
            , NULL AS company_id
            , NULL AS debit
            , NULL AS credit
            , NULL AS checked
            , CAST(COALESCE(SUM(t.debit), 0) - COALESCE(SUM(t.credit), 0) AS sql_variant) AS balance
        FROM
            s02.cashbook t
        WHERE
            t.[date] < @start_date
        UNION ALL
        SELECT
            t.id
            , CAST(t.[date] AS datetime) AS [date]
            , t.account_id
            , t.item_id
            , t.company_id
            , t.debit
            , t.credit
            , t.checked
            , '=IFERROR(VALUE(OFFSET(RC,-1,0)),0)+[@debit]-[@credit]' AS balance
        FROM
            s02.cashbook t
        WHERE
            COALESCE(@account_id, t.account_id, -1) = COALESCE(t.account_id, -1)
            AND COALESCE(@item_id, t.item_id, -1) = COALESCE(t.item_id, -1)
            AND COALESCE(@company_id, t.company_id, -1) = COALESCE(t.company_id, -1)
            AND t.[date] BETWEEN @start_date AND @end_date
    ) t
ORDER BY
    t.[date]
    , t.account_id
    , CASE WHEN t.debit IS NOT NULL THEN -1 WHEN t.credit IS NOT NULL THEN 1 ELSE 0 END
    , t.item_id
    , t.company_id
    , t.debit
    , t.credit

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Shows details for usp_cash_by_months
-- =============================================

CREATE PROCEDURE [s02].[xl_details_cash_by_months]
    @column_name nvarchar(255)
    , @item_id int = NULL
    , @company_id int = NULL
    , @section int = NULL
    , @year int = NULL
AS
BEGIN

SET NOCOUNT ON

DECLARE @month int = CHARINDEX(' ' + @column_name + ' ', '    Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ') / 4

IF @month < 1 SET @month = NULL

IF @year IS NULL SET @year = YEAR((SELECT MAX([date]) FROM s02.cashbook))
IF @year IS NULL SET @year = YEAR(GETDATE())

DECLARE @start_date date = DATEADD(MONTH, COALESCE(@month, 1) - 1, DATEADD(YEAR, @year - 1900, 0))
DECLARE @end_date date = DATEADD(DAY, -1, DATEADD(MONTH, COALESCE(@month, 12), DATEADD(YEAR, @year - 1900, 0)))

SELECT
    t.id
    , t.[date]
    , a.name AS account
    , i.name AS item
    , c.name AS company
    , CAST(t.debit AS numeric(15,2)) AS debit
    , CAST(t.credit AS numeric(15,2)) AS credit
FROM
    s02.cashbook t
    LEFT OUTER JOIN s02.accounts a ON a.id = t.account_id
    LEFT OUTER JOIN s02.items i ON i.id = t.item_id
    LEFT OUTER JOIN s02.companies c ON c.id = t.company_id
WHERE
    COALESCE(t.item_id, 0) = COALESCE(@item_id, t.item_id, 0)
    AND COALESCE(t.company_id, 0) = COALESCE(@company_id, t.company_id, 0)
    AND t.[date] BETWEEN @start_date AND @end_date
    AND ((@section = 2 AND t.debit IS NOT NULL)
      OR (@section = 3 AND t.credit IS NOT NULL)
      OR (@section = 4))

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: List of account_id
-- =============================================

CREATE PROCEDURE [s02].[xl_list_account_id]
    @data_language varchar(10) = NULL
AS
BEGIN

SET NOCOUNT ON

SELECT
    m.id
    , COALESCE(t.TRANSLATED_NAME, m.name) AS name
FROM
    s02.accounts m
    LEFT OUTER JOIN xls.translations t ON t.TABLE_SCHEMA = 's02' AND t.TABLE_NAME = 'strings'
            AND t.LANGUAGE_NAME = @data_language AND t.COLUMN_NAME = m.name
ORDER BY
    name

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: List of company_id
-- =============================================

CREATE PROCEDURE [s02].[xl_list_company_id]
    @data_language varchar(10) = NULL
AS
BEGIN

SET NOCOUNT ON

SELECT
    c.id
    , COALESCE(t.TRANSLATED_NAME, c.name) AS name
FROM
    s02.companies c
    LEFT OUTER JOIN xls.translations t ON t.TABLE_SCHEMA = 's02' AND t.TABLE_NAME = 'strings'
            AND t.LANGUAGE_NAME = @data_language AND t.COLUMN_NAME = c.name
ORDER BY
    name
    , id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: List of company_id for item_id
-- =============================================

CREATE PROCEDURE [s02].[xl_list_company_id_for_item_id]
    @item_id int = NULL
    , @data_language varchar(10) = NULL
AS
BEGIN

SET NOCOUNT ON

SELECT NULL AS id, NULL AS name UNION ALL
SELECT
    m.id
    , COALESCE(t.TRANSLATED_NAME, m.name) AS name
FROM
    s02.companies m
    LEFT OUTER JOIN xls.translations t ON t.TABLE_SCHEMA = 's02' AND t.TABLE_NAME = 'strings'
            AND t.LANGUAGE_NAME = @data_language AND t.COLUMN_NAME = m.name
WHERE
    @item_id IS NULL
UNION ALL
SELECT
    c.id
    , COALESCE(t.TRANSLATED_NAME, c.name) AS name
FROM
    s02.item_companies ic
    INNER JOIN s02.companies c ON c.id = ic.company_id
    LEFT OUTER JOIN xls.translations t ON t.TABLE_SCHEMA = 's02' AND t.TABLE_NAME = 'strings'
            AND t.LANGUAGE_NAME = @data_language AND t.COLUMN_NAME = c.name
WHERE
    ic.item_id = @item_id
ORDER BY
    name

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: List of company_id with item_id
-- =============================================

CREATE PROCEDURE [s02].[xl_list_company_id_with_item_id]
    @data_language varchar(10) = NULL
AS
BEGIN

SET NOCOUNT ON

SELECT
    c.id
    , COALESCE(t.TRANSLATED_NAME, c.name) AS name
    , ic.item_id
FROM
    s02.item_companies ic
    INNER JOIN s02.companies c ON c.id = ic.company_id
    LEFT OUTER JOIN xls.translations t ON t.TABLE_SCHEMA = 's02' AND t.TABLE_NAME = 'strings'
            AND t.LANGUAGE_NAME = @data_language AND t.COLUMN_NAME = c.name
ORDER BY
    ic.item_id
    , name

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: List of days
-- =============================================

CREATE PROCEDURE [s02].[xl_list_day]
    @year int = NULL
    , @month int = NULL
AS
BEGIN

SET NOCOUNT ON

DECLARE @last_day int = 31

IF @month IS NOT NULL
    SET @last_day = DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, DATEFROMPARTS(COALESCE(@year, YEAR(GETDATE())), @month, 1))))

SELECT NULL AS v UNION ALL
SELECT
    v
FROM
    (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10)
        , (11), (12), (13), (14), (15), (16), (17), (18), (19), (20)
        , (21), (22), (23), (24), (25), (26), (27), (28), (29), (30)
        , (31)) v(v)
WHERE
    v <= @last_day
ORDER BY
    v

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: List of item_id
-- =============================================

CREATE PROCEDURE [s02].[xl_list_item_id]
    @data_language varchar(10) = NULL
AS
BEGIN

SET NOCOUNT ON

SELECT
    m.id
    , COALESCE(t.TRANSLATED_NAME, m.name) AS name
FROM
    s02.items m
    LEFT OUTER JOIN xls.translations t ON t.TABLE_SCHEMA = 's02' AND t.TABLE_NAME = 'strings'
            AND t.LANGUAGE_NAME = @data_language AND t.COLUMN_NAME = m.name
ORDER BY
    name

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: List of years
-- =============================================

CREATE PROCEDURE [s02].[xl_list_year]
AS
BEGIN

SET NOCOUNT ON

SELECT
    v.v
FROM
    (VALUES (NULL), (2019), (2020), (2021), (2022), (2023)) v(v)
WHERE
    v.v IS NULL OR v.v IN (SELECT DISTINCT YEAR(date) FROM s02.cashbook)
ORDER BY
    v

END


GO

SET IDENTITY_INSERT s02.accounts ON;
INSERT INTO s02.accounts (id, name) VALUES (1, N'Bank');
SET IDENTITY_INSERT s02.accounts OFF;
GO

SET IDENTITY_INSERT s02.companies ON;
INSERT INTO s02.companies (id, name) VALUES (1, N'Customer C1');
INSERT INTO s02.companies (id, name) VALUES (2, N'Customer C2');
INSERT INTO s02.companies (id, name) VALUES (3, N'Customer C3');
INSERT INTO s02.companies (id, name) VALUES (4, N'Customer C4');
INSERT INTO s02.companies (id, name) VALUES (5, N'Customer C5');
INSERT INTO s02.companies (id, name) VALUES (6, N'Customer C6');
INSERT INTO s02.companies (id, name) VALUES (7, N'Customer C7');
INSERT INTO s02.companies (id, name) VALUES (8, N'Supplier S1');
INSERT INTO s02.companies (id, name) VALUES (9, N'Supplier S2');
INSERT INTO s02.companies (id, name) VALUES (10, N'Supplier S3');
INSERT INTO s02.companies (id, name) VALUES (11, N'Supplier S4');
INSERT INTO s02.companies (id, name) VALUES (12, N'Supplier S5');
INSERT INTO s02.companies (id, name) VALUES (13, N'Supplier S6');
INSERT INTO s02.companies (id, name) VALUES (14, N'Supplier S7');
INSERT INTO s02.companies (id, name) VALUES (15, N'Corporate Income Tax');
INSERT INTO s02.companies (id, name) VALUES (16, N'Individual Income Tax');
INSERT INTO s02.companies (id, name) VALUES (17, N'Payroll Taxes');
SET IDENTITY_INSERT s02.companies OFF;
GO

SET IDENTITY_INSERT s02.items ON;
INSERT INTO s02.items (id, name) VALUES (1, N'Revenue');
INSERT INTO s02.items (id, name) VALUES (2, N'Expenses');
INSERT INTO s02.items (id, name) VALUES (3, N'Payroll');
INSERT INTO s02.items (id, name) VALUES (4, N'Taxes');
SET IDENTITY_INSERT s02.items OFF;
GO

SET IDENTITY_INSERT s02.cashbook ON;
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (1, '20220110', 1, 1, 1, 200000, NULL, 1);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (2, '20220110', 1, 2, 8, NULL, 50000, 1);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (3, '20220131', 1, 3, NULL, NULL, 85000, 1);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (4, '20220131', 1, 4, 16, NULL, 15000, 1);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (5, '20220131', 1, 4, 17, NULL, 15000, 1);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (6, '20220210', 1, 1, 1, 300000, NULL, 1);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (7, '20220210', 1, 1, 2, 100000, NULL, 1);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (8, '20220210', 1, 2, 9, NULL, 50000, 1);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (9, '20220210', 1, 2, 8, NULL, 100000, 1);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (10, '20220228', 1, 3, NULL, NULL, 85000, 1);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (11, '20220228', 1, 4, 16, NULL, 15000, 1);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (12, '20220228', 1, 4, 17, NULL, 15000, 1);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (13, '20220310', 1, 1, 1, 300000, NULL, 0);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (14, '20220310', 1, 1, 2, 200000, NULL, 0);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (15, '20220310', 1, 1, 3, 100000, NULL, 0);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (16, '20220315', 1, 4, 15, NULL, 100000, NULL);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (17, '20220331', 1, 3, NULL, NULL, 170000, NULL);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (18, '20220331', 1, 4, 16, NULL, 30000, NULL);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (19, '20220331', 1, 4, 17, NULL, 30000, NULL);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (20, '20220331', 1, 2, 9, NULL, 50000, NULL);
INSERT INTO s02.cashbook (id, date, account_id, item_id, company_id, debit, credit, checked) VALUES (21, '20220331', 1, 2, 8, NULL, 100000, NULL);
SET IDENTITY_INSERT s02.cashbook OFF;
GO

INSERT INTO s02.item_companies (item_id, company_id) VALUES (1, 1);
INSERT INTO s02.item_companies (item_id, company_id) VALUES (1, 2);
INSERT INTO s02.item_companies (item_id, company_id) VALUES (1, 3);
INSERT INTO s02.item_companies (item_id, company_id) VALUES (1, 4);
INSERT INTO s02.item_companies (item_id, company_id) VALUES (1, 5);
INSERT INTO s02.item_companies (item_id, company_id) VALUES (1, 6);
INSERT INTO s02.item_companies (item_id, company_id) VALUES (1, 7);
INSERT INTO s02.item_companies (item_id, company_id) VALUES (2, 8);
INSERT INTO s02.item_companies (item_id, company_id) VALUES (2, 9);
INSERT INTO s02.item_companies (item_id, company_id) VALUES (2, 10);
INSERT INTO s02.item_companies (item_id, company_id) VALUES (2, 11);
INSERT INTO s02.item_companies (item_id, company_id) VALUES (2, 12);
INSERT INTO s02.item_companies (item_id, company_id) VALUES (2, 13);
INSERT INTO s02.item_companies (item_id, company_id) VALUES (2, 14);
INSERT INTO s02.item_companies (item_id, company_id) VALUES (4, 15);
INSERT INTO s02.item_companies (item_id, company_id) VALUES (4, 16);
INSERT INTO s02.item_companies (item_id, company_id) VALUES (4, 17);
GO

INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's02', N'accounts', N'<table name="s02.accounts"><columnFormats><column name="" property="ListObjectName" value="accounts" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="5" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="name" property="Address" value="$D$4" type="String" /><column name="name" property="ColumnWidth" value="27.86" type="Double" /><column name="name" property="NumberFormat" value="General" type="String" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's02', N'cashbook', N'<table name="s02.cashbook"><columnFormats><column name="" property="ListObjectName" value="Sheet1_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="Address" value="$D$4" type="String" /><column name="date" property="ColumnWidth" value="11.43" type="Double" /><column name="date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="date" property="Validation.Type" value="4" type="Double" /><column name="date" property="Validation.Operator" value="5" type="Double" /><column name="date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="date" property="Validation.AlertStyle" value="1" type="Double" /><column name="date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="date" property="Validation.ShowError" value="True" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="Address" value="$E$4" type="String" /><column name="account_id" property="ColumnWidth" value="12.14" type="Double" /><column name="account_id" property="NumberFormat" value="General" type="String" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="Address" value="$F$4" type="String" /><column name="item_id" property="ColumnWidth" value="20.71" type="Double" /><column name="item_id" property="NumberFormat" value="General" type="String" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="Address" value="$G$4" type="String" /><column name="company_id" property="ColumnWidth" value="20.71" type="Double" /><column name="company_id" property="NumberFormat" value="General" type="String" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="Address" value="$H$4" type="String" /><column name="debit" property="ColumnWidth" value="11.43" type="Double" /><column name="debit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="debit" property="Validation.Type" value="2" type="Double" /><column name="debit" property="Validation.Operator" value="4" type="Double" /><column name="debit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="debit" property="Validation.AlertStyle" value="1" type="Double" /><column name="debit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="debit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="debit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="debit" property="Validation.ShowError" value="True" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="Address" value="$I$4" type="String" /><column name="credit" property="ColumnWidth" value="11.43" type="Double" /><column name="credit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="credit" property="Validation.Type" value="2" type="Double" /><column name="credit" property="Validation.Operator" value="4" type="Double" /><column name="credit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="credit" property="Validation.AlertStyle" value="1" type="Double" /><column name="credit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="credit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="credit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="credit" property="Validation.ShowError" value="True" type="Boolean" /><column name="checked" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="checked" property="Address" value="$J$4" type="String" /><column name="checked" property="ColumnWidth" value="10.14" type="Double" /><column name="checked" property="NumberFormat" value="General" type="String" /><column name="checked" property="HorizontalAlignment" value="-4108" type="Double" /><column name="checked" property="Font.Size" value="10" type="Double" /><column name="checked" property="FormatConditions(1).AppliesTo.Address" value="$J$4:$J$24" type="String" /><column name="checked" property="FormatConditions(1).Type" value="6" type="Double" /><column name="checked" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="checked" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean" /><column name="checked" property="FormatConditions(1).IconSet.ID" value="8" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Incomes"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view><view name="Expenses"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's02', N'code_cashbook', N'<table name="s02.code_cashbook"><columnFormats><column name="" property="ListObjectName" value="Sheet1_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="Address" value="$D$4" type="String" /><column name="date" property="ColumnWidth" value="11.43" type="Double" /><column name="date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="date" property="Validation.Type" value="4" type="Double" /><column name="date" property="Validation.Operator" value="5" type="Double" /><column name="date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="date" property="Validation.AlertStyle" value="1" type="Double" /><column name="date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="date" property="Validation.ShowError" value="True" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="Address" value="$E$4" type="String" /><column name="account_id" property="ColumnWidth" value="12.14" type="Double" /><column name="account_id" property="NumberFormat" value="General" type="String" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="Address" value="$F$4" type="String" /><column name="item_id" property="ColumnWidth" value="20.71" type="Double" /><column name="item_id" property="NumberFormat" value="General" type="String" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="Address" value="$G$4" type="String" /><column name="company_id" property="ColumnWidth" value="20.71" type="Double" /><column name="company_id" property="NumberFormat" value="General" type="String" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="Address" value="$H$4" type="String" /><column name="debit" property="ColumnWidth" value="11.43" type="Double" /><column name="debit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="debit" property="Validation.Type" value="2" type="Double" /><column name="debit" property="Validation.Operator" value="4" type="Double" /><column name="debit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="debit" property="Validation.AlertStyle" value="1" type="Double" /><column name="debit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="debit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="debit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="debit" property="Validation.ShowError" value="True" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="Address" value="$I$4" type="String" /><column name="credit" property="ColumnWidth" value="11.43" type="Double" /><column name="credit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="credit" property="Validation.Type" value="2" type="Double" /><column name="credit" property="Validation.Operator" value="4" type="Double" /><column name="credit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="credit" property="Validation.AlertStyle" value="1" type="Double" /><column name="credit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="credit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="credit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="credit" property="Validation.ShowError" value="True" type="Boolean" /><column name="checked" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="checked" property="Address" value="$J$4" type="String" /><column name="checked" property="ColumnWidth" value="9.86" type="Double" /><column name="checked" property="NumberFormat" value="General" type="String" /><column name="checked" property="HorizontalAlignment" value="-4108" type="Double" /><column name="checked" property="Font.Size" value="10" type="Double" /><column name="checked" property="FormatConditions(1).AppliesTo.Address" value="$J$4:$J$24" type="String" /><column name="checked" property="FormatConditions(1).Type" value="6" type="Double" /><column name="checked" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="checked" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean" /><column name="checked" property="FormatConditions(1).IconSet.ID" value="8" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Incomes"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view><view name="Expenses"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's02', N'companies', N'<table name="s02.companies"><columnFormats><column name="" property="ListObjectName" value="companies" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="5" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="name" property="Address" value="$D$4" type="String" /><column name="name" property="ColumnWidth" value="27.86" type="Double" /><column name="name" property="NumberFormat" value="General" type="String" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's02', N'item_companies', N'<table name="s02.item_companies"><columnFormats><column name="" property="ListObjectName" value="item_companies" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="Address" value="$C$4" type="String" /><column name="item_id" property="ColumnWidth" value="27.86" type="Double" /><column name="item_id" property="NumberFormat" value="General" type="String" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="Address" value="$D$4" type="String" /><column name="company_id" property="ColumnWidth" value="27.86" type="Double" /><column name="company_id" property="NumberFormat" value="General" type="String" /><column name="_State_" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_State_" property="Address" value="$E$4" type="String" /><column name="_State_" property="ColumnWidth" value="9.14" type="Double" /><column name="_State_" property="NumberFormat" value="General" type="String" /><column name="_State_" property="HorizontalAlignment" value="-4108" type="Double" /><column name="_State_" property="Font.Size" value="10" type="Double" /><column name="_State_" property="FormatConditions(1).AppliesTo.Address" value="$E$4:$E$20" type="String" /><column name="_State_" property="FormatConditions(1).Type" value="6" type="Double" /><column name="_State_" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="_State_" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean" /><column name="_State_" property="FormatConditions(1).IconSet.ID" value="8" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's02', N'items', N'<table name="s02.items"><columnFormats><column name="" property="ListObjectName" value="items" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="5" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="name" property="Address" value="$D$4" type="String" /><column name="name" property="ColumnWidth" value="27.86" type="Double" /><column name="name" property="NumberFormat" value="General" type="String" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's02', N'usp_cash_by_months', N'<table name="s02.usp_cash_by_months"><columnFormats><column name="" property="ListObjectName" value="cash_by_months" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="sort_order" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="sort_order" property="Address" value="$C$4" type="String" /><column name="sort_order" property="NumberFormat" value="General" type="String" /><column name="section" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="section" property="Address" value="$D$4" type="String" /><column name="section" property="NumberFormat" value="General" type="String" /><column name="level" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="level" property="Address" value="$E$4" type="String" /><column name="level" property="NumberFormat" value="General" type="String" /><column name="item_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="item_id" property="Address" value="$F$4" type="String" /><column name="item_id" property="NumberFormat" value="General" type="String" /><column name="company_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="company_id" property="Address" value="$G$4" type="String" /><column name="company_id" property="NumberFormat" value="General" type="String" /><column name="Name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Name" property="Address" value="$H$4" type="String" /><column name="Name" property="ColumnWidth" value="21.43" type="Double" /><column name="Name" property="NumberFormat" value="General" type="String" /><column name="Total" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Total" property="Address" value="$I$4" type="String" /><column name="Total" property="ColumnWidth" value="8.43" type="Double" /><column name="Total" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String" /><column name="Jan" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Jan" property="Address" value="$J$4" type="String" /><column name="Jan" property="ColumnWidth" value="10" type="Double" /><column name="Jan" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String" /><column name="Feb" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Feb" property="Address" value="$K$4" type="String" /><column name="Feb" property="ColumnWidth" value="10" type="Double" /><column name="Feb" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String" /><column name="Mar" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Mar" property="Address" value="$L$4" type="String" /><column name="Mar" property="ColumnWidth" value="10" type="Double" /><column name="Mar" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String" /><column name="Apr" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Apr" property="Address" value="$M$4" type="String" /><column name="Apr" property="ColumnWidth" value="10" type="Double" /><column name="Apr" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String" /><column name="May" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="May" property="Address" value="$N$4" type="String" /><column name="May" property="ColumnWidth" value="10" type="Double" /><column name="May" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String" /><column name="Jun" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Jun" property="Address" value="$O$4" type="String" /><column name="Jun" property="ColumnWidth" value="10" type="Double" /><column name="Jun" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String" /><column name="Jul" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Jul" property="Address" value="$P$4" type="String" /><column name="Jul" property="ColumnWidth" value="10" type="Double" /><column name="Jul" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String" /><column name="Aug" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Aug" property="Address" value="$Q$4" type="String" /><column name="Aug" property="ColumnWidth" value="10" type="Double" /><column name="Aug" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String" /><column name="Sep" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Sep" property="Address" value="$R$4" type="String" /><column name="Sep" property="ColumnWidth" value="10" type="Double" /><column name="Sep" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String" /><column name="Oct" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Oct" property="Address" value="$S$4" type="String" /><column name="Oct" property="ColumnWidth" value="10" type="Double" /><column name="Oct" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String" /><column name="Nov" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Nov" property="Address" value="$T$4" type="String" /><column name="Nov" property="ColumnWidth" value="10" type="Double" /><column name="Nov" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String" /><column name="Dec" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Dec" property="Address" value="$U$4" type="String" /><column name="Dec" property="ColumnWidth" value="10" type="Double" /><column name="Dec" property="NumberFormat" value="#,##0;[Red]-#,##0;" type="String" /><column name="_RowNum" property="FormatConditions(1).AppliesToTable" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(1).AppliesTo.Address" value="$B$4:$U$20" type="String" /><column name="_RowNum" property="FormatConditions(1).Type" value="2" type="Double" /><column name="_RowNum" property="FormatConditions(1).Priority" value="3" type="Double" /><column name="_RowNum" property="FormatConditions(1).Formula1" value="=$E4&lt;2" type="String" /><column name="_RowNum" property="FormatConditions(1).Font.Bold" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(2).AppliesToTable" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(2).AppliesTo.Address" value="$B$4:$U$20" type="String" /><column name="_RowNum" property="FormatConditions(2).Type" value="2" type="Double" /><column name="_RowNum" property="FormatConditions(2).Priority" value="4" type="Double" /><column name="_RowNum" property="FormatConditions(2).Formula1" value="=AND($E4=0,$D4&gt;1,$D4&lt;5)" type="String" /><column name="_RowNum" property="FormatConditions(2).Font.Bold" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(2).Font.Color" value="16777215" type="Double" /><column name="_RowNum" property="FormatConditions(2).Font.ThemeColor" value="1" type="Double" /><column name="_RowNum" property="FormatConditions(2).Font.TintAndShade" value="0" type="Double" /><column name="_RowNum" property="FormatConditions(2).Interior.Color" value="6773025" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats><views><view name="All columns"><column name="" property="ListObjectName" value="cash_by_month" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sort_order" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="section" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="level" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Jan" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Feb" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Mar" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Apr" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="May" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Jun" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Jul" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Aug" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Sep" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Oct" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Nov" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Dec" property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Default"><column name="" property="ListObjectName" value="cash_by_month" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="sort_order" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="section" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="level" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="Name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Jan" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Feb" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Mar" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Apr" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="May" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Jun" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Jul" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Aug" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Sep" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Oct" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Nov" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Dec" property="EntireColumn.Hidden" value="False" type="Boolean" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's02', N'usp_cashbook', N'<table name="s02.usp_cashbook"><columnFormats><column name="" property="ListObjectName" value="Sheet1_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="Address" value="$D$4" type="String" /><column name="date" property="ColumnWidth" value="11.43" type="Double" /><column name="date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="date" property="Validation.Type" value="4" type="Double" /><column name="date" property="Validation.Operator" value="5" type="Double" /><column name="date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="date" property="Validation.AlertStyle" value="1" type="Double" /><column name="date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="date" property="Validation.ShowError" value="True" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="Address" value="$E$4" type="String" /><column name="account_id" property="ColumnWidth" value="12.14" type="Double" /><column name="account_id" property="NumberFormat" value="General" type="String" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="Address" value="$F$4" type="String" /><column name="item_id" property="ColumnWidth" value="20.71" type="Double" /><column name="item_id" property="NumberFormat" value="General" type="String" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="Address" value="$G$4" type="String" /><column name="company_id" property="ColumnWidth" value="20.71" type="Double" /><column name="company_id" property="NumberFormat" value="General" type="String" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="Address" value="$H$4" type="String" /><column name="debit" property="ColumnWidth" value="11.43" type="Double" /><column name="debit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="debit" property="Validation.Type" value="2" type="Double" /><column name="debit" property="Validation.Operator" value="4" type="Double" /><column name="debit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="debit" property="Validation.AlertStyle" value="1" type="Double" /><column name="debit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="debit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="debit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="debit" property="Validation.ShowError" value="True" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="Address" value="$I$4" type="String" /><column name="credit" property="ColumnWidth" value="11.43" type="Double" /><column name="credit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="credit" property="Validation.Type" value="2" type="Double" /><column name="credit" property="Validation.Operator" value="4" type="Double" /><column name="credit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="credit" property="Validation.AlertStyle" value="1" type="Double" /><column name="credit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="credit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="credit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="credit" property="Validation.ShowError" value="True" type="Boolean" /><column name="checked" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="checked" property="Address" value="$J$4" type="String" /><column name="checked" property="ColumnWidth" value="9.86" type="Double" /><column name="checked" property="NumberFormat" value="General" type="String" /><column name="checked" property="HorizontalAlignment" value="-4108" type="Double" /><column name="checked" property="Font.Size" value="10" type="Double" /><column name="checked" property="FormatConditions(1).AppliesTo.Address" value="$J$4:$J$24" type="String" /><column name="checked" property="FormatConditions(1).Type" value="6" type="Double" /><column name="checked" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="checked" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean" /><column name="checked" property="FormatConditions(1).IconSet.ID" value="8" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Incomes"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view><view name="Expenses"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's02', N'usp_cashbook2', N'<table name="s02.usp_cashbook2"><columnFormats><column name="" property="ListObjectName" value="usp_cashbook2" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="Address" value="$D$4" type="String" /><column name="date" property="ColumnWidth" value="11.43" type="Double" /><column name="date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="date" property="Validation.Type" value="4" type="Double" /><column name="date" property="Validation.Operator" value="5" type="Double" /><column name="date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="date" property="Validation.AlertStyle" value="1" type="Double" /><column name="date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="date" property="Validation.ShowError" value="True" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="Address" value="$E$4" type="String" /><column name="account_id" property="ColumnWidth" value="12.14" type="Double" /><column name="account_id" property="NumberFormat" value="General" type="String" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="Address" value="$F$4" type="String" /><column name="item_id" property="ColumnWidth" value="20.71" type="Double" /><column name="item_id" property="NumberFormat" value="General" type="String" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="Address" value="$G$4" type="String" /><column name="company_id" property="ColumnWidth" value="20.71" type="Double" /><column name="company_id" property="NumberFormat" value="General" type="String" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="Address" value="$H$4" type="String" /><column name="debit" property="ColumnWidth" value="11.43" type="Double" /><column name="debit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="debit" property="Validation.Type" value="2" type="Double" /><column name="debit" property="Validation.Operator" value="4" type="Double" /><column name="debit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="debit" property="Validation.AlertStyle" value="1" type="Double" /><column name="debit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="debit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="debit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="debit" property="Validation.ShowError" value="True" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="Address" value="$I$4" type="String" /><column name="credit" property="ColumnWidth" value="11.43" type="Double" /><column name="credit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="credit" property="Validation.Type" value="2" type="Double" /><column name="credit" property="Validation.Operator" value="4" type="Double" /><column name="credit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="credit" property="Validation.AlertStyle" value="1" type="Double" /><column name="credit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="credit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="credit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="credit" property="Validation.ShowError" value="True" type="Boolean" /><column name="checked" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="checked" property="Address" value="$J$4" type="String" /><column name="checked" property="ColumnWidth" value="9.86" type="Double" /><column name="checked" property="NumberFormat" value="General" type="String" /><column name="checked" property="HorizontalAlignment" value="-4108" type="Double" /><column name="checked" property="Font.Size" value="10" type="Double" /><column name="checked" property="FormatConditions(1).AppliesTo.Address" value="$J$4:$J$24" type="String" /><column name="checked" property="FormatConditions(1).Type" value="6" type="Double" /><column name="checked" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="checked" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean" /><column name="checked" property="FormatConditions(1).IconSet.ID" value="8" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Incomes"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view><view name="Expenses"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's02', N'usp_cashbook3', N'<table name="s02.usp_cashbook3"><columnFormats><column name="" property="ListObjectName" value="Sheet1_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="Address" value="$D$4" type="String" /><column name="date" property="ColumnWidth" value="11.43" type="Double" /><column name="date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="date" property="Validation.Type" value="4" type="Double" /><column name="date" property="Validation.Operator" value="5" type="Double" /><column name="date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="date" property="Validation.AlertStyle" value="1" type="Double" /><column name="date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="date" property="Validation.ShowError" value="True" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="Address" value="$E$4" type="String" /><column name="account_id" property="ColumnWidth" value="12.14" type="Double" /><column name="account_id" property="NumberFormat" value="General" type="String" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="Address" value="$F$4" type="String" /><column name="item_id" property="ColumnWidth" value="20.71" type="Double" /><column name="item_id" property="NumberFormat" value="General" type="String" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="Address" value="$G$4" type="String" /><column name="company_id" property="ColumnWidth" value="20.71" type="Double" /><column name="company_id" property="NumberFormat" value="General" type="String" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="Address" value="$H$4" type="String" /><column name="debit" property="ColumnWidth" value="11.43" type="Double" /><column name="debit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="debit" property="Validation.Type" value="2" type="Double" /><column name="debit" property="Validation.Operator" value="4" type="Double" /><column name="debit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="debit" property="Validation.AlertStyle" value="1" type="Double" /><column name="debit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="debit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="debit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="debit" property="Validation.ShowError" value="True" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="Address" value="$I$4" type="String" /><column name="credit" property="ColumnWidth" value="11.43" type="Double" /><column name="credit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="credit" property="Validation.Type" value="2" type="Double" /><column name="credit" property="Validation.Operator" value="4" type="Double" /><column name="credit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="credit" property="Validation.AlertStyle" value="1" type="Double" /><column name="credit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="credit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="credit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="credit" property="Validation.ShowError" value="True" type="Boolean" /><column name="checked" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="checked" property="Address" value="$J$4" type="String" /><column name="checked" property="ColumnWidth" value="9.86" type="Double" /><column name="checked" property="NumberFormat" value="General" type="String" /><column name="checked" property="HorizontalAlignment" value="-4108" type="Double" /><column name="checked" property="Font.Size" value="10" type="Double" /><column name="checked" property="FormatConditions(1).AppliesTo.Address" value="$J$4:$J$24" type="String" /><column name="checked" property="FormatConditions(1).Type" value="6" type="Double" /><column name="checked" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="checked" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean" /><column name="checked" property="FormatConditions(1).IconSet.ID" value="8" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Incomes"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view><view name="Expenses"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's02', N'usp_cashbook4', N'<table name="s02.usp_cashbook4"><columnFormats><column name="" property="ListObjectName" value="Sheet1_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="Address" value="$D$4" type="String" /><column name="date" property="ColumnWidth" value="11.43" type="Double" /><column name="date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="date" property="Validation.Type" value="4" type="Double" /><column name="date" property="Validation.Operator" value="5" type="Double" /><column name="date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="date" property="Validation.AlertStyle" value="1" type="Double" /><column name="date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="date" property="Validation.ShowError" value="True" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="Address" value="$E$4" type="String" /><column name="account_id" property="ColumnWidth" value="12.14" type="Double" /><column name="account_id" property="NumberFormat" value="General" type="String" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="Address" value="$F$4" type="String" /><column name="item_id" property="ColumnWidth" value="20.71" type="Double" /><column name="item_id" property="NumberFormat" value="General" type="String" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="Address" value="$G$4" type="String" /><column name="company_id" property="ColumnWidth" value="20.71" type="Double" /><column name="company_id" property="NumberFormat" value="General" type="String" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="Address" value="$H$4" type="String" /><column name="debit" property="ColumnWidth" value="11.43" type="Double" /><column name="debit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="debit" property="Validation.Type" value="2" type="Double" /><column name="debit" property="Validation.Operator" value="4" type="Double" /><column name="debit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="debit" property="Validation.AlertStyle" value="1" type="Double" /><column name="debit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="debit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="debit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="debit" property="Validation.ShowError" value="True" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="Address" value="$I$4" type="String" /><column name="credit" property="ColumnWidth" value="11.43" type="Double" /><column name="credit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="credit" property="Validation.Type" value="2" type="Double" /><column name="credit" property="Validation.Operator" value="4" type="Double" /><column name="credit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="credit" property="Validation.AlertStyle" value="1" type="Double" /><column name="credit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="credit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="credit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="credit" property="Validation.ShowError" value="True" type="Boolean" /><column name="checked" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="checked" property="Address" value="$J$4" type="String" /><column name="checked" property="ColumnWidth" value="9.86" type="Double" /><column name="checked" property="NumberFormat" value="General" type="String" /><column name="checked" property="HorizontalAlignment" value="-4108" type="Double" /><column name="checked" property="Font.Size" value="10" type="Double" /><column name="checked" property="FormatConditions(1).AppliesTo.Address" value="$J$4:$J$24" type="String" /><column name="checked" property="FormatConditions(1).Type" value="6" type="Double" /><column name="checked" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="checked" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean" /><column name="checked" property="FormatConditions(1).IconSet.ID" value="8" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Incomes"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view><view name="Expenses"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's02', N'usp_cashbook5', N'<table name="s02.usp_cashbook5"><columnFormats><column name="" property="ListObjectName" value="Sheet1_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="Address" value="$D$4" type="String" /><column name="date" property="ColumnWidth" value="11.43" type="Double" /><column name="date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="date" property="Validation.Type" value="4" type="Double" /><column name="date" property="Validation.Operator" value="5" type="Double" /><column name="date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="date" property="Validation.AlertStyle" value="1" type="Double" /><column name="date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="date" property="Validation.ShowError" value="True" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="Address" value="$E$4" type="String" /><column name="account_id" property="ColumnWidth" value="12.14" type="Double" /><column name="account_id" property="NumberFormat" value="General" type="String" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="Address" value="$F$4" type="String" /><column name="item_id" property="ColumnWidth" value="20.71" type="Double" /><column name="item_id" property="NumberFormat" value="General" type="String" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="Address" value="$G$4" type="String" /><column name="company_id" property="ColumnWidth" value="20.71" type="Double" /><column name="company_id" property="NumberFormat" value="General" type="String" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="Address" value="$H$4" type="String" /><column name="debit" property="ColumnWidth" value="11.43" type="Double" /><column name="debit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="debit" property="Validation.Type" value="2" type="Double" /><column name="debit" property="Validation.Operator" value="4" type="Double" /><column name="debit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="debit" property="Validation.AlertStyle" value="1" type="Double" /><column name="debit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="debit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="debit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="debit" property="Validation.ShowError" value="True" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="Address" value="$I$4" type="String" /><column name="credit" property="ColumnWidth" value="11.43" type="Double" /><column name="credit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="credit" property="Validation.Type" value="2" type="Double" /><column name="credit" property="Validation.Operator" value="4" type="Double" /><column name="credit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="credit" property="Validation.AlertStyle" value="1" type="Double" /><column name="credit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="credit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="credit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="credit" property="Validation.ShowError" value="True" type="Boolean" /><column name="checked" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="checked" property="Address" value="$J$4" type="String" /><column name="checked" property="ColumnWidth" value="9.86" type="Double" /><column name="checked" property="NumberFormat" value="General" type="String" /><column name="checked" property="HorizontalAlignment" value="-4108" type="Double" /><column name="checked" property="Font.Size" value="10" type="Double" /><column name="balance" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="balance" property="Address" value="$K$4" type="String" /><column name="balance" property="ColumnWidth" value="11.43" type="Double" /><column name="balance" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="checked" property="FormatConditions(1).AppliesTo.Address" value="$J$4:$J$25" type="String" /><column name="checked" property="FormatConditions(1).Type" value="6" type="Double" /><column name="checked" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="checked" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean" /><column name="checked" property="FormatConditions(1).IconSet.ID" value="8" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Incomes"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view><view name="Expenses"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's02', N'view_cashbook', N'<table name="s02.view_cashbook"><columnFormats><column name="" property="ListObjectName" value="view_cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="Address" value="$D$4" type="String" /><column name="date" property="ColumnWidth" value="11.43" type="Double" /><column name="date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="date" property="Validation.Type" value="4" type="Double" /><column name="date" property="Validation.Operator" value="5" type="Double" /><column name="date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="date" property="Validation.AlertStyle" value="1" type="Double" /><column name="date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="date" property="Validation.ShowError" value="True" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="Address" value="$E$4" type="String" /><column name="account_id" property="ColumnWidth" value="12.14" type="Double" /><column name="account_id" property="NumberFormat" value="General" type="String" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="Address" value="$F$4" type="String" /><column name="item_id" property="ColumnWidth" value="20.71" type="Double" /><column name="item_id" property="NumberFormat" value="General" type="String" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="Address" value="$G$4" type="String" /><column name="company_id" property="ColumnWidth" value="20.71" type="Double" /><column name="company_id" property="NumberFormat" value="General" type="String" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="Address" value="$H$4" type="String" /><column name="debit" property="ColumnWidth" value="11.43" type="Double" /><column name="debit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="debit" property="Validation.Type" value="2" type="Double" /><column name="debit" property="Validation.Operator" value="4" type="Double" /><column name="debit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="debit" property="Validation.AlertStyle" value="1" type="Double" /><column name="debit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="debit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="debit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="debit" property="Validation.ShowError" value="True" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="Address" value="$I$4" type="String" /><column name="credit" property="ColumnWidth" value="11.43" type="Double" /><column name="credit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="credit" property="Validation.Type" value="2" type="Double" /><column name="credit" property="Validation.Operator" value="4" type="Double" /><column name="credit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="credit" property="Validation.AlertStyle" value="1" type="Double" /><column name="credit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="credit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="credit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="credit" property="Validation.ShowError" value="True" type="Boolean" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Incomes"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view><view name="Expenses"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's02', N'view_cashbook2', N'<table name="s02.view_cashbook2"><columnFormats><column name="" property="ListObjectName" value="view_cashbook2" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="Address" value="$D$4" type="String" /><column name="date" property="ColumnWidth" value="11.43" type="Double" /><column name="date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="date" property="Validation.Type" value="4" type="Double" /><column name="date" property="Validation.Operator" value="5" type="Double" /><column name="date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="date" property="Validation.AlertStyle" value="1" type="Double" /><column name="date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="date" property="Validation.ShowError" value="True" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="Address" value="$E$4" type="String" /><column name="account_id" property="ColumnWidth" value="12.14" type="Double" /><column name="account_id" property="NumberFormat" value="General" type="String" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="Address" value="$F$4" type="String" /><column name="item_id" property="ColumnWidth" value="20.71" type="Double" /><column name="item_id" property="NumberFormat" value="General" type="String" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="Address" value="$G$4" type="String" /><column name="company_id" property="ColumnWidth" value="20.71" type="Double" /><column name="company_id" property="NumberFormat" value="General" type="String" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="Address" value="$H$4" type="String" /><column name="debit" property="ColumnWidth" value="11.43" type="Double" /><column name="debit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="debit" property="Validation.Type" value="2" type="Double" /><column name="debit" property="Validation.Operator" value="4" type="Double" /><column name="debit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="debit" property="Validation.AlertStyle" value="1" type="Double" /><column name="debit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="debit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="debit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="debit" property="Validation.ShowError" value="True" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="Address" value="$I$4" type="String" /><column name="credit" property="ColumnWidth" value="11.43" type="Double" /><column name="credit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="credit" property="Validation.Type" value="2" type="Double" /><column name="credit" property="Validation.Operator" value="4" type="Double" /><column name="credit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="credit" property="Validation.AlertStyle" value="1" type="Double" /><column name="credit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="credit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="credit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="credit" property="Validation.ShowError" value="True" type="Boolean" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Incomes"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view><view name="Expenses"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's02', N'view_cashbook3', N'<table name="s02.view_cashbook3"><columnFormats><column name="" property="ListObjectName" value="Sheet1_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="Address" value="$D$4" type="String" /><column name="date" property="ColumnWidth" value="11.43" type="Double" /><column name="date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="date" property="Validation.Type" value="4" type="Double" /><column name="date" property="Validation.Operator" value="5" type="Double" /><column name="date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="date" property="Validation.AlertStyle" value="1" type="Double" /><column name="date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="date" property="Validation.ShowError" value="True" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="Address" value="$E$4" type="String" /><column name="account_id" property="ColumnWidth" value="12.14" type="Double" /><column name="account_id" property="NumberFormat" value="General" type="String" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="Address" value="$F$4" type="String" /><column name="item_id" property="ColumnWidth" value="20.71" type="Double" /><column name="item_id" property="NumberFormat" value="General" type="String" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="Address" value="$G$4" type="String" /><column name="company_id" property="ColumnWidth" value="20.71" type="Double" /><column name="company_id" property="NumberFormat" value="General" type="String" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="Address" value="$H$4" type="String" /><column name="debit" property="ColumnWidth" value="11.43" type="Double" /><column name="debit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="debit" property="Validation.Type" value="2" type="Double" /><column name="debit" property="Validation.Operator" value="4" type="Double" /><column name="debit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="debit" property="Validation.AlertStyle" value="1" type="Double" /><column name="debit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="debit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="debit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="debit" property="Validation.ShowError" value="True" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="Address" value="$I$4" type="String" /><column name="credit" property="ColumnWidth" value="11.43" type="Double" /><column name="credit" property="NumberFormat" value="#,##0.00_ ;[Red]-#,##0.00 " type="String" /><column name="credit" property="Validation.Type" value="2" type="Double" /><column name="credit" property="Validation.Operator" value="4" type="Double" /><column name="credit" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="credit" property="Validation.AlertStyle" value="1" type="Double" /><column name="credit" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="credit" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="credit" property="Validation.ShowInput" value="True" type="Boolean" /><column name="credit" property="Validation.ShowError" value="True" type="Boolean" /><column name="checked" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="checked" property="Address" value="$J$4" type="String" /><column name="checked" property="ColumnWidth" value="9.86" type="Double" /><column name="checked" property="NumberFormat" value="General" type="String" /><column name="checked" property="HorizontalAlignment" value="-4108" type="Double" /><column name="checked" property="Font.Size" value="10" type="Double" /><column name="checked" property="FormatConditions(1).AppliesTo.Address" value="$J$4:$J$24" type="String" /><column name="checked" property="FormatConditions(1).Type" value="6" type="Double" /><column name="checked" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="checked" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean" /><column name="checked" property="FormatConditions(1).IconSet.ID" value="8" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double" /><column name="checked" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Incomes"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view><view name="Expenses"><column name="" property="ListObjectName" value="cashbook" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="debit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="credit" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's02', N'view_translations', N'<table name="s02.view_translations"><columnFormats><column name="" property="ListObjectName" value="view_translations" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="ID" property="Address" value="$C$4" type="String" /><column name="ID" property="ColumnWidth" value="4.86" type="Double" /><column name="ID" property="NumberFormat" value="#,##0" type="String" /><column name="ID" property="Validation.Type" value="1" type="Double" /><column name="ID" property="Validation.Operator" value="1" type="Double" /><column name="ID" property="Validation.Formula1" value="-2147483648" type="String" /><column name="ID" property="Validation.Formula2" value="2147483647" type="String" /><column name="ID" property="Validation.AlertStyle" value="2" type="Double" /><column name="ID" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="ID" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="ID" property="Validation.ErrorTitle" value="Data Type Control" type="String" /><column name="ID" property="Validation.ErrorMessage" value="The column requires values of the int data type." type="String" /><column name="ID" property="Validation.ShowInput" value="True" type="Boolean" /><column name="ID" property="Validation.ShowError" value="True" type="Boolean" /><column name="TABLE_SCHEMA" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="TABLE_SCHEMA" property="Address" value="$D$4" type="String" /><column name="TABLE_SCHEMA" property="ColumnWidth" value="16.57" type="Double" /><column name="TABLE_SCHEMA" property="NumberFormat" value="General" type="String" /><column name="TABLE_SCHEMA" property="Validation.Type" value="6" type="Double" /><column name="TABLE_SCHEMA" property="Validation.Operator" value="8" type="Double" /><column name="TABLE_SCHEMA" property="Validation.Formula1" value="128" type="String" /><column name="TABLE_SCHEMA" property="Validation.AlertStyle" value="2" type="Double" /><column name="TABLE_SCHEMA" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="TABLE_SCHEMA" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="TABLE_SCHEMA" property="Validation.ErrorTitle" value="Data Type Control" type="String" /><column name="TABLE_SCHEMA" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(128) data type." type="String" /><column name="TABLE_SCHEMA" property="Validation.ShowInput" value="True" type="Boolean" /><column name="TABLE_SCHEMA" property="Validation.ShowError" value="True" type="Boolean" /><column name="TABLE_NAME" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="TABLE_NAME" property="Address" value="$E$4" type="String" /><column name="TABLE_NAME" property="ColumnWidth" value="25.14" type="Double" /><column name="TABLE_NAME" property="NumberFormat" value="General" type="String" /><column name="TABLE_NAME" property="Validation.Type" value="6" type="Double" /><column name="TABLE_NAME" property="Validation.Operator" value="8" type="Double" /><column name="TABLE_NAME" property="Validation.Formula1" value="128" type="String" /><column name="TABLE_NAME" property="Validation.AlertStyle" value="2" type="Double" /><column name="TABLE_NAME" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="TABLE_NAME" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="TABLE_NAME" property="Validation.ErrorTitle" value="Data Type Control" type="String" /><column name="TABLE_NAME" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(128) data type." type="String" /><column name="TABLE_NAME" property="Validation.ShowInput" value="True" type="Boolean" /><column name="TABLE_NAME" property="Validation.ShowError" value="True" type="Boolean" /><column name="COLUMN_NAME" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="COLUMN_NAME" property="Address" value="$F$4" type="String" /><column name="COLUMN_NAME" property="ColumnWidth" value="19.86" type="Double" /><column name="COLUMN_NAME" property="NumberFormat" value="General" type="String" /><column name="COLUMN_NAME" property="Validation.Type" value="6" type="Double" /><column name="COLUMN_NAME" property="Validation.Operator" value="8" type="Double" /><column name="COLUMN_NAME" property="Validation.Formula1" value="128" type="String" /><column name="COLUMN_NAME" property="Validation.AlertStyle" value="2" type="Double" /><column name="COLUMN_NAME" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="COLUMN_NAME" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="COLUMN_NAME" property="Validation.ErrorTitle" value="Data Type Control" type="String" /><column name="COLUMN_NAME" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(128) data type." type="String" /><column name="COLUMN_NAME" property="Validation.ShowInput" value="True" type="Boolean" /><column name="COLUMN_NAME" property="Validation.ShowError" value="True" type="Boolean" /><column name="LANGUAGE_NAME" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="LANGUAGE_NAME" property="Address" value="$G$4" type="String" /><column name="LANGUAGE_NAME" property="ColumnWidth" value="19.57" type="Double" /><column name="LANGUAGE_NAME" property="NumberFormat" value="General" type="String" /><column name="LANGUAGE_NAME" property="Validation.Type" value="6" type="Double" /><column name="LANGUAGE_NAME" property="Validation.Operator" value="8" type="Double" /><column name="LANGUAGE_NAME" property="Validation.Formula1" value="10" type="String" /><column name="LANGUAGE_NAME" property="Validation.AlertStyle" value="2" type="Double" /><column name="LANGUAGE_NAME" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="LANGUAGE_NAME" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="LANGUAGE_NAME" property="Validation.ErrorTitle" value="Data Type Control" type="String" /><column name="LANGUAGE_NAME" property="Validation.ErrorMessage" value="The column requires values of the varchar(10) data type." type="String" /><column name="LANGUAGE_NAME" property="Validation.ShowInput" value="True" type="Boolean" /><column name="LANGUAGE_NAME" property="Validation.ShowError" value="True" type="Boolean" /><column name="TRANSLATED_NAME" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="TRANSLATED_NAME" property="Address" value="$H$4" type="String" /><column name="TRANSLATED_NAME" property="ColumnWidth" value="31.14" type="Double" /><column name="TRANSLATED_NAME" property="NumberFormat" value="General" type="String" /><column name="TRANSLATED_NAME" property="Validation.Type" value="6" type="Double" /><column name="TRANSLATED_NAME" property="Validation.Operator" value="8" type="Double" /><column name="TRANSLATED_NAME" property="Validation.Formula1" value="128" type="String" /><column name="TRANSLATED_NAME" property="Validation.AlertStyle" value="2" type="Double" /><column name="TRANSLATED_NAME" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="TRANSLATED_NAME" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="TRANSLATED_NAME" property="Validation.ErrorTitle" value="Data Type Control" type="String" /><column name="TRANSLATED_NAME" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(128) data type." type="String" /><column name="TRANSLATED_NAME" property="Validation.ShowInput" value="True" type="Boolean" /><column name="TRANSLATED_NAME" property="Validation.ShowError" value="True" type="Boolean" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats></table>');
GO

INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'code_cashbook', NULL, N'Actions', N's02', N'See Online Help', N'HTTP', N'https://www.savetodb.com/samples/sample02-code_cashbook', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook3', NULL, N'Change', N's02', N'usp_cashbook3_change', N'PROCEDURE', NULL, N'_Commit', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook2', NULL, N'Change', N's02', N'view_cashbook2', N'VIEW', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook3', N'account_id', N'Change', N's02', N'view_cashbook3_account_id_change', N'CODE', N'UPDATE s02.cashbook SET account_id = @cell_number_value WHERE id = @id', N'_Commit', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook3', N'company_id', N'Change', N's02', N'view_cashbook3_company_id_change', N'CODE', N'UPDATE s02.cashbook SET company_id = @cell_number_value WHERE id = @id', N'_Commit', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook3', N'credit', N'Change', N's02', N'view_cashbook3_credit_change', N'CODE', N'UPDATE s02.cashbook SET credit = @cell_number_value WHERE id = @id', N'_Commit', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook3', N'date', N'Change', N's02', N'view_cashbook3_date_change', N'CODE', N'UPDATE s02.cashbook SET [date] = @cell_date_value WHERE id = @id', N'_Commit', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook3', N'debit', N'Change', N's02', N'view_cashbook3_debit_change', N'CODE', N'UPDATE s02.cashbook SET debit = @cell_number_value WHERE id = @id', N'_Commit', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook3', N'item_id', N'Change', N's02', N'view_cashbook3_item_id_change', N'CODE', N'UPDATE s02.cashbook SET item_id = @cell_number_value WHERE id = @id', N'_Commit', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cash_by_months', NULL, N'ContextMenu', N's02', N'xl_details_cash_by_months', N'PROCEDURE', NULL, NULL, 11, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cash_by_months', NULL, N'ContextMenu', N's02', N'MenuSeparator12', N'MENUSEPARATOR', NULL, NULL, 12, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cash_by_months', NULL, N'ContextMenu', N's02', N'usp_cashbook2', N'PROCEDURE', N'EXEC s02.usp_cashbook2 1, @item_id, @company_id', N'_New', 13, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook5', N'balance', N'ConvertFormulas', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'code_cashbook', N'item_id', N'DataTypeInt', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook5', N'balance', N'DoNotChange', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook3', NULL, N'DoNotSave', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook2', NULL, N'DoNotSave', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook3', NULL, N'DoNotSave', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'code_cashbook', N'account_id', N'ParameterValues', N's02', N'xl_list_account_id_code', N'CODE', N'SELECT
    m.id
    , COALESCE(t.TRANSLATED_NAME, m.name) AS name
FROM
    s02.accounts m
    LEFT OUTER JOIN s02.view_translations t ON t.TABLE_SCHEMA = ''s02'' AND t.TABLE_NAME = ''strings''
            AND t.LANGUAGE_NAME = @data_language AND t.COLUMN_NAME = m.name
ORDER BY
    name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'code_cashbook', N'company_id', N'ParameterValues', N's02', N'xl_list_company_id_for_item_id_code', N'CODE', N'SELECT
    m.id
    , COALESCE(t.TRANSLATED_NAME, m.name) AS name
FROM
    s02.companies m
    LEFT OUTER JOIN s02.view_translations t ON t.TABLE_SCHEMA = ''s02'' AND t.TABLE_NAME = ''strings''
            AND t.LANGUAGE_NAME = @data_language AND t.COLUMN_NAME = m.name
WHERE
    @item_id IS NULL
UNION ALL
SELECT
    c.id
    , COALESCE(t.TRANSLATED_NAME, c.name) AS name
FROM
    s02.item_companies ic
    INNER JOIN s02.companies c ON c.id = ic.company_id
    LEFT OUTER JOIN s02.view_translations t ON t.TABLE_SCHEMA = ''s02'' AND t.TABLE_NAME = ''strings''
            AND t.LANGUAGE_NAME = @data_language AND t.COLUMN_NAME = c.name
WHERE
    ic.item_id = @item_id
ORDER BY
    name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'code_cashbook', N'item_id', N'ParameterValues', N's02', N'xl_list_item_id_code', N'CODE', N'SELECT
    m.id
    , COALESCE(t.TRANSLATED_NAME, m.name) AS name
FROM
    s02.items m
    LEFT OUTER JOIN s02.view_translations t ON t.TABLE_SCHEMA = ''s02'' AND t.TABLE_NAME = ''strings''
            AND t.LANGUAGE_NAME = @data_language AND t.COLUMN_NAME = m.name
ORDER BY
    name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cash_by_months', N'year', N'ParameterValues', N's02', N'xl_list_year', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook', N'account_id', N'ParameterValues', N's02', N'accounts', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook', N'company_id', N'ParameterValues', N's02', N'companies', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook', N'item_id', N'ParameterValues', N's02', N'items', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook2', N'account_id', N'ParameterValues', N's02', N'xl_list_account_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook2', N'company_id', N'ParameterValues', N's02', N'xl_list_company_id_for_item_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook2', N'item_id', N'ParameterValues', N's02', N'xl_list_item_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook3', N'account_id', N'ParameterValues', N's02', N'xl_list_account_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook3', N'company_id', N'ParameterValues', N's02', N'xl_list_company_id_for_item_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook3', N'item_id', N'ParameterValues', N's02', N'xl_list_item_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook4', N'account_id', N'ParameterValues', N's02', N'xl_list_account_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook4', N'company_id', N'ParameterValues', N's02', N'xl_list_company_id_for_item_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook4', N'item_id', N'ParameterValues', N's02', N'xl_list_item_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook5', N'account_id', N'ParameterValues', N's02', N'xl_list_account_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook5', N'company_id', N'ParameterValues', N's02', N'xl_list_company_id_for_item_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook5', N'day', N'ParameterValues', N's02', N'xl_list_day', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook5', N'item_id', N'ParameterValues', N's02', N'xl_list_item_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook5', N'month', N'ParameterValues', NULL, NULL, N'VALUES', N',1,2,3,4,5,6,7,8,9,10,11,12', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook5', N'year', N'ParameterValues', N's02', N'xl_list_year', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook3', NULL, N'ProtectRows', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook2', NULL, N'ProtectRows', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook3', NULL, N'ProtectRows', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'cashbook', N'date', N'SelectPeriod', NULL, NULL, N'ATTRIBUTE', NULL, N'HideWeeks HideYears HideThisMonth', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'code_cashbook', N'start_date', N'SelectPeriod', NULL, NULL, N'ATTRIBUTE', NULL, N'end_date HideWeeks HideYears', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook2', N'start_date', N'SelectPeriod', NULL, NULL, N'ATTRIBUTE', NULL, N'end_date HideWeeks HideYears', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'cashbook', N'account_id', N'ValidationList', N's02', N'accounts', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'cashbook', N'company_id', N'ValidationList', N's02', N'companies', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'cashbook', N'item_id', N'ValidationList', N's02', N'items', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'code_cashbook', N'account_id', N'ValidationList', N's02', N'xl_list_account_id_code', N'CODE', N'SELECT
    m.id
    , COALESCE(t.TRANSLATED_NAME, m.name) AS name
FROM
    s02.accounts m
    LEFT OUTER JOIN s02.view_translations t ON t.TABLE_SCHEMA = ''s02'' AND t.TABLE_NAME = ''strings''
            AND t.LANGUAGE_NAME = @data_language AND t.COLUMN_NAME = m.name
ORDER BY
    name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'code_cashbook', N'company_id', N'ValidationList', N's02', N'xl_list_company_id_with_item_id_code', N'CODE', N'SELECT
    c.id
    , COALESCE(t.TRANSLATED_NAME, c.name) AS name
    , ic.item_id
FROM
    s02.item_companies ic
    INNER JOIN s02.companies c ON c.id = ic.company_id
    LEFT OUTER JOIN s02.view_translations t ON t.TABLE_SCHEMA = ''s02'' AND t.TABLE_NAME = ''strings''
            AND t.LANGUAGE_NAME = @data_language AND t.COLUMN_NAME = c.name
ORDER BY
    ic.item_id
    , name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'code_cashbook', N'item_id', N'ValidationList', N's02', N'xl_list_item_id_code', N'CODE', N'SELECT
    m.id
    , COALESCE(t.TRANSLATED_NAME, m.name) AS name
FROM
    s02.items m
    LEFT OUTER JOIN s02.view_translations t ON t.TABLE_SCHEMA = ''s02'' AND t.TABLE_NAME = ''strings''
            AND t.LANGUAGE_NAME = @data_language AND t.COLUMN_NAME = m.name
ORDER BY
    name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook', N'account_id', N'ValidationList', N's02', N'accounts', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook', N'company_id', N'ValidationList', N's02', N'companies', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook', N'item_id', N'ValidationList', N's02', N'items', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook2', N'account_id', N'ValidationList', N's02', N'xl_list_account_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook2', N'company_id', N'ValidationList', N's02', N'xl_list_company_id_with_item_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook2', N'item_id', N'ValidationList', N's02', N'xl_list_item_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook3', N'account_id', N'ValidationList', N's02', N'xl_list_account_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook3', N'company_id', N'ValidationList', N's02', N'xl_list_company_id_with_item_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook3', N'item_id', N'ValidationList', N's02', N'xl_list_item_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook4', N'account_id', N'ValidationList', N's02', N'xl_list_account_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook4', N'company_id', N'ValidationList', N's02', N'xl_list_company_id_with_item_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook4', N'item_id', N'ValidationList', N's02', N'xl_list_item_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook5', N'account_id', N'ValidationList', N's02', N'xl_list_account_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook5', N'company_id', N'ValidationList', N's02', N'xl_list_company_id_with_item_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'usp_cashbook5', N'item_id', N'ValidationList', N's02', N'xl_list_item_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook', N'account_id', N'ValidationList', N's02', N'accounts', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook', N'company_id', N'ValidationList', N's02', N'companies', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook', N'item_id', N'ValidationList', N's02', N'items', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook2', N'account_id', N'ValidationList', N's02', N'accounts', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook2', N'company_id', N'ValidationList', N's02', N'companies', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook2', N'item_id', N'ValidationList', N's02', N'items', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook3', N'account_id', N'ValidationList', N's02', N'accounts', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook3', N'company_id', N'ValidationList', N's02', N'companies', N'TABLE', N'id, +name', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's02', N'view_cashbook3', N'item_id', N'ValidationList', N's02', N'items', N'TABLE', N'id, +name', NULL, NULL, NULL);
GO

INSERT INTO xls.objects (TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE, TABLE_CODE, INSERT_OBJECT, UPDATE_OBJECT, DELETE_OBJECT) VALUES (N's02', N'code_cashbook', N'CODE', N'SELECT
    t.id
    , CAST(t.[date] AS datetime) AS [date]
    , t.account_id
    , t.item_id
    , t.company_id
    , t.debit
    , t.credit
    , t.checked
FROM
    s02.cashbook t
WHERE
    COALESCE(@account_id, t.account_id, -1) = COALESCE(t.account_id, -1)
    AND COALESCE(@item_id, t.item_id, -1) = COALESCE(t.item_id, -1)
    AND COALESCE(@company_id, t.company_id, -1) = COALESCE(t.company_id, -1)
    AND t.date BETWEEN COALESCE(@start_date, ''20200101'') AND COALESCE(@end_date, ''20490101'')
    AND (@checked IS NULL OR t.checked = @checked)', N'INSERT INTO s02.cashbook ([date], account_id, item_id, company_id, debit, credit, @checked) VALUES (@date, @account_id, @item_id, @company_id, @debit, @credit, @checked)', N'UPDATE s02.cashbook SET [date] = @date, account_id = @account_id, item_id = @item_id, company_id = @company_id, debit = @debit, credit = @credit, checked = @checked WHERE id = @id', N'DELETE FROM s02.cashbook WHERE id = @id');
INSERT INTO xls.objects (TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE, TABLE_CODE, INSERT_OBJECT, UPDATE_OBJECT, DELETE_OBJECT) VALUES (N's02', N'usp_cashbook', N'PROCEDURE', NULL, N's02.cashbook', N's02.cashbook', N's02.cashbook');
INSERT INTO xls.objects (TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE, TABLE_CODE, INSERT_OBJECT, UPDATE_OBJECT, DELETE_OBJECT) VALUES (N's02', N'usp_cashbook5', N'PROCEDURE', NULL, N's02.usp_cashbook2_insert', N's02.usp_cashbook2_update', N's02.usp_cashbook2_delete');
INSERT INTO xls.objects (TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE, TABLE_CODE, INSERT_OBJECT, UPDATE_OBJECT, DELETE_OBJECT) VALUES (N's02', N'view_cashbook', N'VIEW', NULL, N's02.view_cashbook', N's02.view_cashbook', N's02.view_cashbook');
GO

INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account', N'de', N'Konto', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account_id', N'de', N'Konto', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Apr', N'de', N'Apr.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Aug', N'de', N'Aug.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'balance', N'de', N'Balance', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'checked', N'de', N'Überprüft', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company', N'de', N'Unternehmen', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company_id', N'de', N'Unternehmen', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'credit', N'de', N'Kosten', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'date', N'de', N'Datum', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'day', N'de', N'Tag', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'debit', N'de', N'Einkommen', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Dec', N'de', N'Dez.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'end_date', N'de', N'Endtermin', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Feb', N'de', N'Feb.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'id', N'de', N'Id', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item', N'de', N'Artikel', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item_id', N'de', N'Artikel', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jan', N'de', N'Jan.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jul', N'de', N'Juli', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jun', N'de', N'Juni', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'level', N'de', N'Niveau', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Mar', N'de', N'März', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'May', N'de', N'Mai', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'month', N'de', N'Monat', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Name', N'de', N'Name', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Nov', N'de', N'Nov.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Oct', N'de', N'Okt.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'section', N'de', N'Sektion', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Sep', N'de', N'Sept.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'sort_order', N'de', N'Sortierung', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'start_date', N'de', N'Startdatum', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Total', N'de', N'Gesamt', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'year', N'de', N'Jahr', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'accounts', NULL, N'de', N'Konten', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'cashbook', NULL, N'de', N'Kassenbuch', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'code_cashbook', NULL, N'de', N'Kassenbuch (SQL-Code)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'companies', NULL, N'de', N'Unternehmen', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'item_companies', NULL, N'de', N'Artikel und Firmen', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'items', NULL, N'de', N'Artikel', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Bank', N'de', N'Bank', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Closing Balance', N'de', N'Schlussbilanz', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Corporate Income Tax', N'de', N'Körperschaftssteuer', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C1', N'de', N'Kunde C1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C2', N'de', N'Kunde C2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C3', N'de', N'Kunde C3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C4', N'de', N'Kunde C4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C5', N'de', N'Kunde C5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C6', N'de', N'Kunde C6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C7', N'de', N'Kunde C7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Expenses', N'de', N'Kosten', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Individual Income Tax', N'de', N'Lohnsteuer', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Net Change', N'de', N'Nettoveränderung', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Opening Balance', N'de', N'Anfangsbestand', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll', N'de', N'Lohn-und Gehaltsabrechnung', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll Taxes', N'de', N'Sozialabgaben', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Revenue', N'de', N'Einnahmen', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S1', N'de', N'Lieferant S1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S2', N'de', N'Lieferant S2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S3', N'de', N'Lieferant S3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S4', N'de', N'Lieferant S4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S5', N'de', N'Lieferant S5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S6', N'de', N'Lieferant S6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S7', N'de', N'Lieferant S7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Taxes', N'de', N'Steuern', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Expenses', N'de', N'Gesamtausgaben', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Income', N'de', N'Gesamteinkommen', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', NULL, N'de', N'Bargeld nach Monaten', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'company_id', N'de', N'Firmen-ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'item_id', N'de', N'Artikel-ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook', NULL, N'de', N'Kassenbuch (Prozedur)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook2', NULL, N'de', N'Kassenbuch (Prozedur, _edit)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook3', NULL, N'de', N'Kassenbuch (Prozedur, _change)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook4', NULL, N'de', N'Kassenbuch (Prozedur, _merge)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook5', NULL, N'de', N'Kassenbuch (Formeln)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook', NULL, N'de', N'Kassenbuch (Ansicht)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook2', NULL, N'de', N'Kassenbuch (Ansicht, _change)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook3', NULL, N'de', N'Kassenbuch (Ansicht, _change, SQL)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_translations', NULL, N'de', N'Translationen', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'xl_details_cash_by_months', NULL, N'de', N'Einzelheiten', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account', N'en', N'Account', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account_id', N'en', N'Account', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Apr', N'en', N'Apr', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Aug', N'en', N'Aug', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'balance', N'en', N'Balance', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'checked', N'en', N'Checked', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company', N'en', N'Company', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company_id', N'en', N'Company', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'credit', N'en', N'Expenses', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'date', N'en', N'Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'day', N'en', N'Day', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'debit', N'en', N'Income', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Dec', N'en', N'Dec', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'end_date', N'en', N'End Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Feb', N'en', N'Feb', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'id', N'en', N'Id', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item', N'en', N'Item', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item_id', N'en', N'Item', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jan', N'en', N'Jan', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jul', N'en', N'Jul', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jun', N'en', N'Jun', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'level', N'en', N'Level', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Mar', N'en', N'Mar', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'May', N'en', N'May', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'month', N'en', N'Month', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Name', N'en', N'Name', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Nov', N'en', N'Nov', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Oct', N'en', N'Oct', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'section', N'en', N'Section', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Sep', N'en', N'Sep', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'sort_order', N'en', N'Sort Order', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'start_date', N'en', N'Start Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Total', N'en', N'Total', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'year', N'en', N'Year', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'accounts', NULL, N'en', N'Accounts', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'cashbook', NULL, N'en', N'Cashbook', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'code_cashbook', NULL, N'en', N'Cashbook (SQL code)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'companies', NULL, N'en', N'Companies', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'item_companies', NULL, N'en', N'Item and Companies', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'items', NULL, N'en', N'Items', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Bank', N'en', N'Bank', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Closing Balance', N'en', N'Closing Balance', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Corporate Income Tax', N'en', N'Corporate Income Tax', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C1', N'en', N'Customer C1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C2', N'en', N'Customer C2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C3', N'en', N'Customer C3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C4', N'en', N'Customer C4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C5', N'en', N'Customer C5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C6', N'en', N'Customer C6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C7', N'en', N'Customer C7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Expenses', N'en', N'Expenses', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Individual Income Tax', N'en', N'Individual Income Tax', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Net Change', N'en', N'Net Change', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Opening Balance', N'en', N'Opening Balance', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll', N'en', N'Payroll', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll Taxes', N'en', N'Payroll Taxes', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Revenue', N'en', N'Revenue', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S1', N'en', N'Supplier S1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S2', N'en', N'Supplier S2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S3', N'en', N'Supplier S3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S4', N'en', N'Supplier S4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S5', N'en', N'Supplier S5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S6', N'en', N'Supplier S6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S7', N'en', N'Supplier S7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Taxes', N'en', N'Taxes', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Expenses', N'en', N'Total Expenses', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Income', N'en', N'Total Income', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', NULL, N'en', N'Cash by Months', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'company_id', N'en', N'Company Id', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'item_id', N'en', N'Item Id', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook', NULL, N'en', N'Cashbook (procedure)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook2', NULL, N'en', N'Cashbook (procedure, _edit)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook3', NULL, N'en', N'Cashbook (procedure, _change)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook4', NULL, N'en', N'Cashbook (procedure, _merge)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook5', NULL, N'en', N'Cashbook (formulas)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook', NULL, N'en', N'Cashbook (view)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook2', NULL, N'en', N'Cashbook (view, _change)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook3', NULL, N'en', N'Cashbook (view, _change, SQL)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_translations', NULL, N'en', N'Translations', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'xl_details_cash_by_months', NULL, N'en', N'Details', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account', N'es', N'Cuenta', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account_id', N'es', N'Cuenta', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Apr', N'es', N'Abr.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Aug', N'es', N'Agosto', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'balance', N'es', N'Equilibrio', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'checked', N'es', N'Comprobado', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company', N'es', N'Empresa', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company_id', N'es', N'Empresa', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'credit', N'es', N'Gasto', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'date', N'es', N'Fecha', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'day', N'es', N'Día', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'debit', N'es', N'Ingresos', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Dec', N'es', N'Dic.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'end_date', N'es', N'Fecha final', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Feb', N'es', N'Feb.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'id', N'es', N'Id', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item', N'es', N'Artículo', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item_id', N'es', N'Artículo', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jan', N'es', N'Enero', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jul', N'es', N'Jul.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jun', N'es', N'Jun.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'level', N'es', N'Nivel', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Mar', N'es', N'Marzo', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'May', N'es', N'Mayo', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'month', N'es', N'Mes', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Name', N'es', N'Nombre', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Nov', N'es', N'Nov.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Oct', N'es', N'Oct.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'section', N'es', N'Sección', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Sep', N'es', N'Sept.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'sort_order', N'es', N'Orden', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'start_date', N'es', N'Fecha de inicio', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Total', N'es', N'Total', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'year', N'es', N'Año', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'accounts', NULL, N'es', N'Cuentas', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'cashbook', NULL, N'es', N'Libro de caja', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'code_cashbook', NULL, N'es', N'Libro de caja (código SQL)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'companies', NULL, N'es', N'Compañías', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'item_companies', NULL, N'es', N'Artículo y empresas', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'items', NULL, N'es', N'Artículos', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Bank', N'es', N'Banco', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Closing Balance', N'es', N'Balance de cierre', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Corporate Income Tax', N'es', N'Impuesto sobre Sociedades', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C1', N'es', N'Cliente C1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C2', N'es', N'Cliente C2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C3', N'es', N'Cliente C3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C4', N'es', N'Cliente C4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C5', N'es', N'Cliente C5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C6', N'es', N'Cliente C6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C7', N'es', N'Cliente C7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Expenses', N'es', N'Gasto', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Individual Income Tax', N'es', N'IRPF', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Net Change', N'es', N'Cambio neto', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Opening Balance', N'es', N'Saldo de apertura', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll', N'es', N'Salario', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll Taxes', N'es', N'Cargas sociales', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Revenue', N'es', N'Ingresos', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S1', N'es', N'Abastecedor A1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S2', N'es', N'Abastecedor A2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S3', N'es', N'Abastecedor A3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S4', N'es', N'Abastecedor A4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S5', N'es', N'Abastecedor A5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S6', N'es', N'Abastecedor A6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S7', N'es', N'Abastecedor A7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Taxes', N'es', N'Impuestos', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Expenses', N'es', N'Gasto total', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Income', N'es', N'Ingresos totales', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', NULL, N'es', N'Efectivo por meses', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'company_id', N'es', N'ID de empresa', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'item_id', N'es', N'ID del artículo', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook', NULL, N'es', N'Libro de caja (proc)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook2', NULL, N'es', N'Libro de caja (proc, _edit)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook3', NULL, N'es', N'Libro de caja (proc, _change)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook4', NULL, N'es', N'Libro de caja (proc, _merge)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook5', NULL, N'es', N'Libro de caja (fórmulas)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook', NULL, N'es', N'Libro de caja (ver)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook2', NULL, N'es', N'Libro de caja (ver, _change)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook3', NULL, N'es', N'Libro de caja (ver, _change, SQL)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_translations', NULL, N'es', N'Traducciones', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'xl_details_cash_by_months', NULL, N'es', N'Detalles', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account', N'fr', N'Compte', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account_id', N'fr', N'Compte', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Apr', N'fr', N'Avril', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Aug', N'fr', N'Août', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'balance', N'fr', N'Solde', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'checked', N'fr', N'Vérifié', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company', N'fr', N'Entreprise', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company_id', N'fr', N'Entreprise', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'credit', N'fr', N'Dépenses', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'date', N'fr', N'Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'day', N'fr', N'Journée', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'debit', N'fr', N'Revenu', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Dec', N'fr', N'Déc.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'end_date', N'fr', N'Date de fin', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Feb', N'fr', N'Févr.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'id', N'fr', N'Id', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item', N'fr', N'Article', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item_id', N'fr', N'Article', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jan', N'fr', N'Janv.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jul', N'fr', N'Juil.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jun', N'fr', N'Juin', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'level', N'fr', N'Niveau', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Mar', N'fr', N'Mars', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'May', N'fr', N'Mai', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'month', N'fr', N'Mois', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Name', N'fr', N'Prénom', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Nov', N'fr', N'Nov.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Oct', N'fr', N'Oct.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'section', N'fr', N'Section', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Sep', N'fr', N'Sept.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'sort_order', N'fr', N'Ordre de tri', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'start_date', N'fr', N'Date de début', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Total', N'fr', N'Totale', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'year', N'fr', N'Année', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'accounts', NULL, N'fr', N'Comptes', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'cashbook', NULL, N'fr', N'Livre de caisse', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'code_cashbook', NULL, N'fr', N'Livre de caisse (code SQL)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'companies', NULL, N'fr', N'Entreprises', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'item_companies', NULL, N'fr', N'Article et sociétés', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'items', NULL, N'fr', N'Articles', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Bank', N'fr', N'Banque', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Closing Balance', N'fr', N'Solde de clôture', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Corporate Income Tax', N'fr', N'Impôt sur les sociétés', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C1', N'fr', N'Client 01', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C2', N'fr', N'Client 02', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C3', N'fr', N'Client 03', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C4', N'fr', N'Client 04', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C5', N'fr', N'Client 05', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C6', N'fr', N'Client 06', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C7', N'fr', N'Client 07', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Expenses', N'fr', N'Dépenses', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Individual Income Tax', N'fr', N'Impôt sur le revenu', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Net Change', N'fr', N'Changement net', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Opening Balance', N'fr', N'Solde d''ouverture', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll', N'fr', N'Paie', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll Taxes', N'fr', N'Charges sociales', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Revenue', N'fr', N'Revenu', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S1', N'fr', N'Fournisseur 01', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S2', N'fr', N'Fournisseur 02', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S3', N'fr', N'Fournisseur 03', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S4', N'fr', N'Fournisseur 04', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S5', N'fr', N'Fournisseur 05', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S6', N'fr', N'Fournisseur 06', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S7', N'fr', N'Fournisseur 07', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Taxes', N'fr', N'Taxes', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Expenses', N'fr', N'Dépenses totales', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Income', N'fr', N'Revenu total', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', NULL, N'fr', N'Cash par mois', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'company_id', N'fr', N'ID de l''entreprise', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'item_id', N'fr', N'ID de l''article', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook', NULL, N'fr', N'Livre de caisse (procédure)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook2', NULL, N'fr', N'Livre de caisse (procédure, _edit)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook3', NULL, N'fr', N'Livre de caisse (procédure, _change)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook4', NULL, N'fr', N'Livre de caisse (procédure, _merge)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook5', NULL, N'fr', N'Livre de caisse (formules)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook', NULL, N'fr', N'Livre de caisse (vue)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook2', NULL, N'fr', N'Livre de caisse (vue, _change)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook3', NULL, N'fr', N'Livre de caisse (vue, _change, SQL)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_translations', NULL, N'fr', N'Traductions', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'xl_details_cash_by_months', NULL, N'fr', N'Détails', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account', N'it', N'Conto', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account_id', N'it', N'Conto', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Apr', N'it', N'Apr.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Aug', N'it', N'Ag.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'balance', N'it', N'Saldo', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'checked', N'it', N'Controllato', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company', N'it', N'Azienda', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company_id', N'it', N'Azienda', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'credit', N'it', N'Credito', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'date', N'it', N'Data', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'day', N'it', N'Giorno', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'debit', N'it', N'Debito', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Dec', N'it', N'Dic.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'end_date', N'it', N'Data di fine', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Feb', N'it', N'Febbr.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'id', N'it', N'Id', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item', N'it', N'Articolo', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item_id', N'it', N'Articolo', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jan', N'it', N'Genn.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jul', N'it', N'Luglio', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jun', N'it', N'Giugno', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'level', N'it', N'Livello', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Mar', N'it', N'Mar.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'May', N'it', N'Magg.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'month', N'it', N'Mese', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Name', N'it', N'Conome', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Nov', N'it', N'Nov.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Oct', N'it', N'Ott.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'section', N'it', N'Sezione', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Sep', N'it', N'Sett.', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'sort_order', N'it', N'Ordinamento', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'start_date', N'it', N'Data d''inizio', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Total', N'it', N'Totale', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'year', N'it', N'Anno', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'accounts', NULL, N'it', N'Conti', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'cashbook', NULL, N'it', N'Cashbook', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'code_cashbook', NULL, N'it', N'Cashbook (codice SQL)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'companies', NULL, N'it', N'Aziende', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'item_companies', NULL, N'it', N'Articolo e società', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'items', NULL, N'it', N'Elementi', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Bank', N'it', N'Banca', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Closing Balance', N'it', N'Saldo finale', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Corporate Income Tax', N'it', N'Imposta sul reddito delle società', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C1', N'it', N'Cliente C1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C2', N'it', N'Cliente C2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C3', N'it', N'Cliente C3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C4', N'it', N'Cliente C4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C5', N'it', N'Cliente C5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C6', N'it', N'Cliente C6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C7', N'it', N'Cliente C7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Expenses', N'it', N'Spese', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Individual Income Tax', N'it', N'IRPEF', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Net Change', N'it', N'Cambio netto', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Opening Balance', N'it', N'Saldo iniziale', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll', N'it', N'Paga', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll Taxes', N'it', N'Imposte sui salari', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Revenue', N'it', N'Reddito', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S1', N'it', N'Fornitore F1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S2', N'it', N'Fornitore F2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S3', N'it', N'Fornitore F3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S4', N'it', N'Fornitore F4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S5', N'it', N'Fornitore F5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S6', N'it', N'Fornitore F6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S7', N'it', N'Fornitore F7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Taxes', N'it', N'Tasse', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Expenses', N'it', N'Spese totale', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Income', N'it', N'Reddito totale', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', NULL, N'it', N'Contanti per mesi', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'company_id', N'it', N'ID dell''azienda', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'item_id', N'it', N'ID articolo', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook', NULL, N'it', N'Cashbook (procedura)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook2', NULL, N'it', N'Cashbook (procedura, _edit)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook3', NULL, N'it', N'Cashbook (procedura, _change)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook4', NULL, N'it', N'Cashbook (procedura, _merge)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook5', NULL, N'it', N'Cashbook (formule)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook', NULL, N'it', N'Cashbook (visualizza)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook2', NULL, N'it', N'Cashbook (visualizza, _change)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook3', NULL, N'it', N'Cashbook (visualizza, _change, SQL)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_translations', NULL, N'it', N'Traduzioni', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'xl_details_cash_by_months', NULL, N'it', N'Dettagli', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account', N'ja', N'アカウント', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account_id', N'ja', N'アカウント', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Apr', N'ja', N'4月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Aug', N'ja', N'8月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'balance', N'ja', N'バランス', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'checked', N'ja', N'チェック済み', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company', N'ja', N'会社', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company_id', N'ja', N'会社', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'credit', N'ja', N'経費', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'date', N'ja', N'日付', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'day', N'ja', N'日', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'debit', N'ja', N'所得', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Dec', N'ja', N'12月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'end_date', N'ja', N'終了日', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Feb', N'ja', N'2月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'id', N'ja', N'Id', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item', N'ja', N'アイテム', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item_id', N'ja', N'アイテム', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jan', N'ja', N'1月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jul', N'ja', N'7月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jun', N'ja', N'6月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'level', N'ja', N'レベル', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Mar', N'ja', N'3月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'May', N'ja', N'5月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'month', N'ja', N'月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Name', N'ja', N'名', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Nov', N'ja', N'11月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Oct', N'ja', N'10月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'section', N'ja', N'セクション', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Sep', N'ja', N'9月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'sort_order', N'ja', N'並べ替え順序', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'start_date', N'ja', N'開始日', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Total', N'ja', N'合計', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'year', N'ja', N'年', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'accounts', NULL, N'ja', N'アカウント', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'cashbook', NULL, N'ja', N'キャッシュブック', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'code_cashbook', NULL, N'ja', N'キャッシュブック（SQLコード）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'companies', NULL, N'ja', N'会社', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'item_companies', NULL, N'ja', N'アイテムと会社', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'items', NULL, N'ja', N'アイテム', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Bank', N'ja', N'銀行', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Closing Balance', N'ja', N'クロージングバランス', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Corporate Income Tax', N'ja', N'法人所得税', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C1', N'ja', N'顧客C1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C2', N'ja', N'顧客C2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C3', N'ja', N'顧客C3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C4', N'ja', N'顧客C4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C5', N'ja', N'顧客C5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C6', N'ja', N'顧客C6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C7', N'ja', N'顧客C7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Expenses', N'ja', N'経費', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Individual Income Tax', N'ja', N'個人所得税', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Net Change', N'ja', N'正味変化', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Opening Balance', N'ja', N'オープニングバランス', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll', N'ja', N'給与', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll Taxes', N'ja', N'給与税', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Revenue', N'ja', N'収益', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S1', N'ja', N'サプライヤーS1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S2', N'ja', N'サプライヤーS2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S3', N'ja', N'サプライヤーS3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S4', N'ja', N'サプライヤーS4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S5', N'ja', N'サプライヤーS5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S6', N'ja', N'サプライヤーS6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S7', N'ja', N'サプライヤーS7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Taxes', N'ja', N'税金', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Expenses', N'ja', N'総費用', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Income', N'ja', N'総収入', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', NULL, N'ja', N'月ごとの現金', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'company_id', N'ja', N'会社ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'item_id', N'ja', N'アイテムID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook', NULL, N'ja', N'キャッシュブック（手順）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook2', NULL, N'ja', N'キャッシュブック（手順、_編集）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook3', NULL, N'ja', N'キャッシュブック（手順、_変更）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook4', NULL, N'ja', N'キャッシュブック（手順、_マージ）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook5', NULL, N'ja', N'キャッシュブック（数式）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook', NULL, N'ja', N'キャッシュブック（表示）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook2', NULL, N'ja', N'キャッシュブック（表示、_変更）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook3', NULL, N'ja', N'キャッシュブック（表示、_変更、SQL）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_translations', NULL, N'ja', N'翻訳', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'xl_details_cash_by_months', NULL, N'ja', N'詳細', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account', N'ko', N'계정', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account_id', N'ko', N'계정', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Apr', N'ko', N'4월', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Aug', N'ko', N'8월', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'balance', N'ko', N'균형', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'checked', N'ko', N'확인됨', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company', N'ko', N'회사', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company_id', N'ko', N'회사', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'credit', N'ko', N'소요 경비', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'date', N'ko', N'날짜', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'day', N'ko', N'하루', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'debit', N'ko', N'소득', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Dec', N'ko', N'12월', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'end_date', N'ko', N'종료일', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Feb', N'ko', N'2월', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'id', N'ko', N'ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item', N'ko', N'아이템', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item_id', N'ko', N'아이템', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jan', N'ko', N'1월', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jul', N'ko', N'7월', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jun', N'ko', N'6월', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'level', N'ko', N'수준', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Mar', N'ko', N'3월', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'May', N'ko', N'5월', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'month', N'ko', N'월', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Name', N'ko', N'이름', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Nov', N'ko', N'11월', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Oct', N'ko', N'10월', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'section', N'ko', N'섹션', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Sep', N'ko', N'9월', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'sort_order', N'ko', N'정렬 순서', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'start_date', N'ko', N'시작일', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Total', N'ko', N'계', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'year', N'ko', N'년', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'accounts', NULL, N'ko', N'계정', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'cashbook', NULL, N'ko', N'캐쉬북', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'code_cashbook', NULL, N'ko', N'캐쉬북(SQL 코드)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'companies', NULL, N'ko', N'회사', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'item_companies', NULL, N'ko', N'아이템 및 회사', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'items', NULL, N'ko', N'아이템', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Bank', N'ko', N'은행', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Closing Balance', N'ko', N'폐쇄 균형', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Corporate Income Tax', N'ko', N'법인 소득세', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C1', N'ko', N'고객 C1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C2', N'ko', N'고객 C2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C3', N'ko', N'고객 C3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C4', N'ko', N'고객 C4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C5', N'ko', N'고객 C5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C6', N'ko', N'고객 C6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C7', N'ko', N'고객 C7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Expenses', N'ko', N'소요 경비', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Individual Income Tax', N'ko', N'개인소득세', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Net Change', N'ko', N'순 변화', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Opening Balance', N'ko', N'기초 잔액', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll', N'ko', N'월급', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll Taxes', N'ko', N'급여 세금', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Revenue', N'ko', N'수익', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S1', N'ko', N'공급 업체 S1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S2', N'ko', N'공급 업체 S2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S3', N'ko', N'공급 업체 S3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S4', N'ko', N'공급 업체 S4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S5', N'ko', N'공급 업체 S5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S6', N'ko', N'공급 업체 S6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S7', N'ko', N'공급 업체 S7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Taxes', N'ko', N'세금', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Expenses', N'ko', N'총 경비', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Income', N'ko', N'총 수입', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', NULL, N'ko', N'월별 현금', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'company_id', N'ko', N'회사 ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'item_id', N'ko', N'항목 ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook', NULL, N'ko', N'캐쉬북(절차)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook2', NULL, N'ko', N'캐쉬북(절차, _edit)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook3', NULL, N'ko', N'캐쉬북(절차, _change)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook4', NULL, N'ko', N'캐쉬북(절차, _merge)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook5', NULL, N'ko', N'캐쉬북(공식)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook', NULL, N'ko', N'캐쉬북(보기)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook2', NULL, N'ko', N'캐쉬북(보기, _change)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook3', NULL, N'ko', N'캐쉬북(보기, _change, SQL)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_translations', NULL, N'ko', N'번역', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'xl_details_cash_by_months', NULL, N'ko', N'세부', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account', N'pt', N'Conta', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account_id', N'pt', N'Conta', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Apr', N'pt', N'Abr', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Aug', N'pt', N'Agosto', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'balance', N'pt', N'Saldo', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'checked', N'pt', N'Verificado', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company', N'pt', N'Companhia', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company_id', N'pt', N'Companhia', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'credit', N'pt', N'Despesas', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'date', N'pt', N'Encontro', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'day', N'pt', N'Dia', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'debit', N'pt', N'Renda', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Dec', N'pt', N'Dez', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'end_date', N'pt', N'Data final', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Feb', N'pt', N'Fev', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'id', N'pt', N'Id', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item', N'pt', N'Item', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item_id', N'pt', N'Item', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jan', N'pt', N'Jan', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jul', N'pt', N'Julho', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jun', N'pt', N'Junho', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'level', N'pt', N'Nível', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Mar', N'pt', N'Março', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'May', N'pt', N'Maio', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'month', N'pt', N'Mês', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Name', N'pt', N'Nome', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Nov', N'pt', N'Nov', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Oct', N'pt', N'Out', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'section', N'pt', N'Seção', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Sep', N'pt', N'Set', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'sort_order', N'pt', N'Ordem de classificação', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'start_date', N'pt', N'Data de início', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Total', N'pt', N'Total', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'year', N'pt', N'Ano', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'accounts', NULL, N'pt', N'Contas', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'cashbook', NULL, N'pt', N'Livro caixa', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'code_cashbook', NULL, N'pt', N'Livro caixa (código SQL)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'companies', NULL, N'pt', N'Empresas', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'item_companies', NULL, N'pt', N'Item e Empresas', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'items', NULL, N'pt', N'Itens', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Bank', N'pt', N'Banco', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Closing Balance', N'pt', N'Saldo final', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Corporate Income Tax', N'pt', N'Imposto de Renda', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C1', N'pt', N'Cliente C1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C2', N'pt', N'Cliente C2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C3', N'pt', N'Cliente C3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C4', N'pt', N'Cliente C4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C5', N'pt', N'Cliente C5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C6', N'pt', N'Cliente C6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C7', N'pt', N'Cliente C7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Expenses', N'pt', N'Despesas', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Individual Income Tax', N'pt', N'Imposto de renda individual', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Net Change', N'pt', N'Mudança de rede', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Opening Balance', N'pt', N'Saldo inicial', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll', N'pt', N'Folha de pagamento', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll Taxes', N'pt', N'Impostos sobre os salários', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Revenue', N'pt', N'Receita', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S1', N'pt', N'Fornecedor S1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S2', N'pt', N'Fornecedor S2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S3', N'pt', N'Fornecedor S3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S4', N'pt', N'Fornecedor S4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S5', N'pt', N'Fornecedor S5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S6', N'pt', N'Fornecedor S6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S7', N'pt', N'Fornecedor S7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Taxes', N'pt', N'Impostos', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Expenses', N'pt', N'Despesas totais', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Income', N'pt', N'Renda total', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', NULL, N'pt', N'Dinheiro por meses', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'company_id', N'pt', N'ID da empresa', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'item_id', N'pt', N'ID do item', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook', NULL, N'pt', N'Livro caixa (proc)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook2', NULL, N'pt', N'Livro caixa (proc, _edit)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook3', NULL, N'pt', N'Livro caixa (proc, _change)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook4', NULL, N'pt', N'Livro caixa (proc, _merge)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook5', NULL, N'pt', N'Livro caixa (fórmulas)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook', NULL, N'pt', N'Livro caixa (ver)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook2', NULL, N'pt', N'Livro caixa (ver, _change)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook3', NULL, N'pt', N'Livro caixa (ver, _change, SQL)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_translations', NULL, N'pt', N'Traduções', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'xl_details_cash_by_months', NULL, N'pt', N'Detalhes', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account', N'ru', N'Счет', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account_id', N'ru', N'Счет', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Apr', N'ru', N'Апр', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Aug', N'ru', N'Авг', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'balance', N'ru', N'Остаток', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'checked', N'ru', N'Проверено', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company', N'ru', N'Компания', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company_id', N'ru', N'Компания', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'credit', N'ru', N'Расходы', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'date', N'ru', N'Дата', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'day', N'ru', N'Число', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'debit', N'ru', N'Доходы', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Dec', N'ru', N'Дек', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'end_date', N'ru', N'Конечная дата', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Feb', N'ru', N'Фев', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'id', N'ru', N'Id', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item', N'ru', N'Статья', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item_id', N'ru', N'Статья', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jan', N'ru', N'Янв', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jul', N'ru', N'Июл', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jun', N'ru', N'Июн', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'level', N'ru', N'Уровень', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Mar', N'ru', N'Мар', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'May', N'ru', N'Май', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'month', N'ru', N'Месяц', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Name', N'ru', N'Наименование', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Nov', N'ru', N'Ноя', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Oct', N'ru', N'Окт', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'section', N'ru', N'Секция', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Sep', N'ru', N'Сен', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'sort_order', N'ru', N'Порядок', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'start_date', N'ru', N'Начальная дата', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Total', N'ru', N'Всего', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'year', N'ru', N'Год', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'accounts', NULL, N'ru', N'Счета', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'cashbook', NULL, N'ru', N'Кассовая книга', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'code_cashbook', NULL, N'ru', N'Кассовая книга (SQL код)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'companies', NULL, N'ru', N'Компании', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'item_companies', NULL, N'ru', N'Статьи и компании', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'items', NULL, N'ru', N'Статьи', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Bank', N'ru', N'Банк', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Closing Balance', N'ru', N'Конечное сальдо', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Corporate Income Tax', N'ru', N'Налог на прибыль', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C1', N'ru', N'Покупатель C1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C2', N'ru', N'Покупатель C2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C3', N'ru', N'Покупатель C3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C4', N'ru', N'Покупатель C4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C5', N'ru', N'Покупатель C5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C6', N'ru', N'Покупатель C6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C7', N'ru', N'Покупатель C7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Expenses', N'ru', N'Расходы', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Individual Income Tax', N'ru', N'НДФЛ', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Net Change', N'ru', N'Изменение', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Opening Balance', N'ru', N'Начальное сальдо', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll', N'ru', N'Заработная плата', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll Taxes', N'ru', N'Страховые взносы', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Revenue', N'ru', N'Выручка', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S1', N'ru', N'Поставщик S1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S2', N'ru', N'Поставщик S2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S3', N'ru', N'Поставщик S3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S4', N'ru', N'Поставщик S4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S5', N'ru', N'Поставщик S5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S6', N'ru', N'Поставщик S6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S7', N'ru', N'Поставщик S7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Taxes', N'ru', N'Налоги', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Expenses', N'ru', N'Всего выплаты', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Income', N'ru', N'Всего поступления', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', NULL, N'ru', N'ДДС по месяцам', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'company_id', N'ru', N'Id компании', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'item_id', N'ru', N'Id статьи', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook', NULL, N'ru', N'Кассовая книга (процедура)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook2', NULL, N'ru', N'Кассовая книга (процедура, _edit)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook3', NULL, N'ru', N'Кассовая книга (процедура, _change)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook4', NULL, N'ru', N'Кассовая книга (процедура, _merge)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook5', NULL, N'ru', N'Кассовая книга (с формулами)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook', NULL, N'ru', N'Кассовая книга (view)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook2', NULL, N'ru', N'Кассовая книга (view, _change)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook3', NULL, N'ru', N'Кассовая книга (view, _change, SQL)', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_translations', NULL, N'ru', N'Перевод', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'xl_details_cash_by_months', NULL, N'ru', N'Исходные данные', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account', N'zh-hans', N'帐户', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account_id', N'zh-hans', N'帐户', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Apr', N'zh-hans', N'四月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Aug', N'zh-hans', N'八月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'balance', N'zh-hans', N'平衡', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'checked', N'zh-hans', N'已检查', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company', N'zh-hans', N'公司', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company_id', N'zh-hans', N'公司', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'credit', N'zh-hans', N'花费', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'date', N'zh-hans', N'日期', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'day', N'zh-hans', N'日', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'debit', N'zh-hans', N'收入', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Dec', N'zh-hans', N'十二月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'end_date', N'zh-hans', N'结束日期', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Feb', N'zh-hans', N'二月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'id', N'zh-hans', N'ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item', N'zh-hans', N'项', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item_id', N'zh-hans', N'项', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jan', N'zh-hans', N'一月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jul', N'zh-hans', N'七月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jun', N'zh-hans', N'六月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'level', N'zh-hans', N'水平', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Mar', N'zh-hans', N'三月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'May', N'zh-hans', N'五月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'month', N'zh-hans', N'月份', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Name', N'zh-hans', N'名称', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Nov', N'zh-hans', N'十一月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Oct', N'zh-hans', N'十月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'section', N'zh-hans', N'部分', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Sep', N'zh-hans', N'九月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'sort_order', N'zh-hans', N'排序顺序', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'start_date', N'zh-hans', N'开始日期', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Total', N'zh-hans', N'总数', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'year', N'zh-hans', N'年', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'accounts', NULL, N'zh-hans', N'账户', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'cashbook', NULL, N'zh-hans', N'现金簿', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'code_cashbook', NULL, N'zh-hans', N'现金簿（SQL 代码）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'companies', NULL, N'zh-hans', N'公司', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'item_companies', NULL, N'zh-hans', N'物品和公司', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'items', NULL, N'zh-hans', N'物品', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Bank', N'zh-hans', N'银行', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Closing Balance', N'zh-hans', N'期末余额', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Corporate Income Tax', N'zh-hans', N'公司所得税', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C1', N'zh-hans', N'顾客C1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C2', N'zh-hans', N'顾客C2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C3', N'zh-hans', N'顾客C3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C4', N'zh-hans', N'顾客C4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C5', N'zh-hans', N'顾客C5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C6', N'zh-hans', N'顾客C6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C7', N'zh-hans', N'顾客C7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Expenses', N'zh-hans', N'花费', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Individual Income Tax', N'zh-hans', N'个人所得税', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Net Change', N'zh-hans', N'净变化', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Opening Balance', N'zh-hans', N'期初余额', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll', N'zh-hans', N'工资单', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll Taxes', N'zh-hans', N'工资税', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Revenue', N'zh-hans', N'营收', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S1', N'zh-hans', N'供应商 S1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S2', N'zh-hans', N'供应商 S2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S3', N'zh-hans', N'供应商 S3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S4', N'zh-hans', N'供应商 S4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S5', N'zh-hans', N'供应商 S5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S6', N'zh-hans', N'供应商 S6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S7', N'zh-hans', N'供应商 S7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Taxes', N'zh-hans', N'税收', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Expenses', N'zh-hans', N'总费用', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Income', N'zh-hans', N'总收入', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', NULL, N'zh-hans', N'每月现金', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'company_id', N'zh-hans', N'公司 ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'item_id', N'zh-hans', N'项目 ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook', NULL, N'zh-hans', N'现金簿（程序）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook2', NULL, N'zh-hans', N'现金簿（程序，_edit）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook3', NULL, N'zh-hans', N'现金簿（程序，_change）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook4', NULL, N'zh-hans', N'现金簿（程序，_merge）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook5', NULL, N'zh-hans', N'现金簿（公式）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook', NULL, N'zh-hans', N'现金簿（查看）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook2', NULL, N'zh-hans', N'现金簿（查看，_change）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook3', NULL, N'zh-hans', N'现金簿（视图、_change、SQL）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_translations', NULL, N'zh-hans', N'翻译', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'xl_details_cash_by_months', NULL, N'zh-hans', N'详情', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account', N'zh-hant', N'帳戶', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'account_id', N'zh-hant', N'帳戶', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Apr', N'zh-hant', N'四月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Aug', N'zh-hant', N'八月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'balance', N'zh-hant', N'平衡', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'checked', N'zh-hant', N'已檢查', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company', N'zh-hant', N'公司', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'company_id', N'zh-hant', N'公司', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'credit', N'zh-hant', N'花費', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'date', N'zh-hant', N'日期', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'day', N'zh-hant', N'日', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'debit', N'zh-hant', N'收入', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Dec', N'zh-hant', N'十二月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'end_date', N'zh-hant', N'結束日期', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Feb', N'zh-hant', N'二月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'id', N'zh-hant', N'ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item', N'zh-hant', N'項', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'item_id', N'zh-hant', N'項', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jan', N'zh-hant', N'一月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jul', N'zh-hant', N'七月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Jun', N'zh-hant', N'六月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'level', N'zh-hant', N'水平', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Mar', N'zh-hant', N'三月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'May', N'zh-hant', N'五月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'month', N'zh-hant', N'月份', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Name', N'zh-hant', N'名稱', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Nov', N'zh-hant', N'十一月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Oct', N'zh-hant', N'十月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'section', N'zh-hant', N'部分', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Sep', N'zh-hant', N'九月', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'sort_order', N'zh-hant', N'排序順序', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'start_date', N'zh-hant', N'開始日期', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'Total', N'zh-hant', N'總數', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', NULL, N'year', N'zh-hant', N'年', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'accounts', NULL, N'zh-hant', N'賬戶', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'cashbook', NULL, N'zh-hant', N'現金簿', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'code_cashbook', NULL, N'zh-hant', N'現金簿（SQL 代碼）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'companies', NULL, N'zh-hant', N'公司', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'item_companies', NULL, N'zh-hant', N'物品和公司', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'items', NULL, N'zh-hant', N'物品', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Bank', N'zh-hant', N'銀行', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Closing Balance', N'zh-hant', N'期末餘額', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Corporate Income Tax', N'zh-hant', N'公司所得稅', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C1', N'zh-hant', N'顧客C1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C2', N'zh-hant', N'顧客C2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C3', N'zh-hant', N'顧客C3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C4', N'zh-hant', N'顧客C4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C5', N'zh-hant', N'顧客C5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C6', N'zh-hant', N'顧客C6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Customer C7', N'zh-hant', N'顧客C7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Expenses', N'zh-hant', N'花費', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Individual Income Tax', N'zh-hant', N'個人所得稅', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Net Change', N'zh-hant', N'淨變化', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Opening Balance', N'zh-hant', N'期初餘額', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll', N'zh-hant', N'工資單', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Payroll Taxes', N'zh-hant', N'工資稅', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Revenue', N'zh-hant', N'營收', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S1', N'zh-hant', N'供應商 S1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S2', N'zh-hant', N'供應商 S2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S3', N'zh-hant', N'供應商 S3', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S4', N'zh-hant', N'供應商 S4', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S5', N'zh-hant', N'供應商 S5', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S6', N'zh-hant', N'供應商 S6', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Supplier S7', N'zh-hant', N'供應商 S7', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Taxes', N'zh-hant', N'稅收', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Expenses', N'zh-hant', N'總費用', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'strings', N'Total Income', N'zh-hant', N'總收入', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', NULL, N'zh-hant', N'每月現金', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'company_id', N'zh-hant', N'公司 ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cash_by_months', N'item_id', N'zh-hant', N'項目 ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook', NULL, N'zh-hant', N'现金簿（程序）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook2', NULL, N'zh-hant', N'现金簿（程序，_edit）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook3', NULL, N'zh-hant', N'现金簿（程序，_change）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook4', NULL, N'zh-hant', N'现金簿（程序，_merge）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'usp_cashbook5', NULL, N'zh-hant', N'现金簿（公式）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook', NULL, N'zh-hant', N'现金簿（查看）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook2', NULL, N'zh-hant', N'现金簿（查看，_change）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_cashbook3', NULL, N'zh-hant', N'现金簿（视图、_change、SQL）', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'view_translations', NULL, N'zh-hant', N'翻译', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's02', N'xl_details_cash_by_months', NULL, N'zh-hant', N'詳情', NULL, NULL);
GO

INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 02 - Advanced Features - User1.xlsx', N'https://www.savetodb.com/downloads/v10/sample02-user1.xlsx', N'cashbook=s02.cashbook,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"cashbook"}
view_cashbook=s02.view_cashbook,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"view_cashbook"}
usp_cashbook=s02.usp_cashbook,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"usp_cashbook"}
usp_cashbook2=s02.usp_cashbook2,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null,"start_date":null,"end_date":null,"checked":null},"ListObjectName":"usp_cashbook2"}
usp_cashbook3=s02.usp_cashbook3,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"usp_cashbook3"}
usp_cashbook4=s02.usp_cashbook4,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"usp_cashbook4"}
cash_by_months=s02.usp_cash_by_months,(Default),False,$B$3,,{"Parameters":{"year":2022},"ListObjectName":"cash_by_months"}', N's02');
INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 02 - Advanced Features - User2 (Restricted).xlsx', N'https://www.savetodb.com/downloads/v10/sample02-user2.xlsx', N'cashbook=s02.cashbook,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"cashbook"}
view_cashbook=s02.view_cashbook,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"view_cashbook"}
usp_cashbook=s02.usp_cashbook,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"usp_cashbook"}
usp_cashbook2=s02.usp_cashbook2,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null,"start_date":null,"end_date":null,"checked":null},"ListObjectName":"usp_cashbook2"}
usp_cashbook3=s02.usp_cashbook3,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"usp_cashbook3"}
usp_cashbook4=s02.usp_cashbook4,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"usp_cashbook4"}
cash_by_months=s02.usp_cash_by_months,(Default),False,$B$3,,{"Parameters":{"year":2022},"ListObjectName":"cash_by_months"}', N's02');
INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 02 - Advanced Features - User3 (SaveToDB Framework).xlsx', N'https://www.savetodb.com/downloads/v10/sample02-user3.xlsx', N'cashbook=s02.cashbook,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"cashbook"}
view_cashbook=s02.view_cashbook,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"view_cashbook"}
view_cashbook2=s02.view_cashbook2,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"view_cashbook2"}
view_cashbook3=s02.view_cashbook3,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"view_cashbook3"}
usp_cashbook=s02.usp_cashbook,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"usp_cashbook"}
usp_cashbook2=s02.usp_cashbook2,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null,"start_date":null,"end_date":null,"checked":null},"ListObjectName":"usp_cashbook2"}
usp_cashbook3=s02.usp_cashbook3,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"usp_cashbook3"}
usp_cashbook4=s02.usp_cashbook4,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"usp_cashbook4"}
usp_cashbook5=s02.usp_cashbook5,(Default),False,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"usp_cashbook5"}
code_cashbook=s02.code_cashbook,(Default),False,$B$3,,{"Parameters":{"account_id":1,"item_id":null,"company_id":null},"ListObjectName":"code_cashbook"}
cash_by_months=s02.usp_cash_by_months,(Default),False,$B$3,,{"Parameters":{"year":2022},"ListObjectName":"cash_by_months"}
objects=xls.view_objects,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","TABLE_NAME":null,"TABLE_TYPE":null},"ListObjectName":"objects"}
handlers=xls.view_handlers,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","EVENT_NAME":null,"HANDLER_TYPE":null},"ListObjectName":"handlers"}
translations=xls.view_translations,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","LANGUAGE_NAME":"en"},"ListObjectName":"translations"}
workbooks=xls.view_workbooks,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02"},"ListObjectName":"workbooks"}', N's02');
INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 02 - Advanced Features - User3 (Translation).xlsx', N'https://www.savetodb.com/downloads/v10/sample02-user3-en.xlsx', N'usp_cashbook2=s02.usp_cashbook2,(Default),False,$B$3,,{"Parameters":{"account_id":1,"item_id":null,"company_id":null,"start_date":null,"end_date":null,"checked":null},"ListObjectName":"usp_cashbook2","UseTranslatedName":true,"WorkbookLanguage":"en"}
cash_by_months=s02.usp_cash_by_months,(Default),False,$B$3,,{"Parameters":{"year":2022},"ListObjectName":"cash_by_months","UseTranslatedName":true,"WorkbookLanguage":"en"}
translations=s02.view_translations,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","LANGUAGE_NAME":"en"},"ListObjectName":"translations","UseTranslatedName":true,"WorkbookLanguage":"en"}', N's02');
INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 02 - Advanced Features - User3 (Translation, Chinese Simplified).xlsx', N'https://www.savetodb.com/downloads/v10/sample02-user3-zh-hans.xlsx', N'usp_cashbook2=s02.usp_cashbook2,(Default),False,$B$3,,{"Parameters":{"account_id":1,"item_id":null,"company_id":null,"start_date":null,"end_date":null,"checked":null},"ListObjectName":"usp_cashbook2","UseTranslatedName":true,"WorkbookLanguage":"zh-hans"}
cash_by_months=s02.usp_cash_by_months,(Default),False,$B$3,,{"Parameters":{"year":2022},"ListObjectName":"cash_by_months","UseTranslatedName":true,"WorkbookLanguage":"zh-hans"}
translations=s02.view_translations,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","LANGUAGE_NAME":"zh-hans"},"ListObjectName":"translations","UseTranslatedName":true,"WorkbookLanguage":"zh-hans"}', N's02');
INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 02 - Advanced Features - User3 (Translation, Chinese Traditional).xlsx', N'https://www.savetodb.com/downloads/v10/sample02-user3-zh-hant.xlsx', N'usp_cashbook2=s02.usp_cashbook2,(Default),False,$B$3,,{"Parameters":{"account_id":1,"item_id":null,"company_id":null,"start_date":null,"end_date":null,"checked":null},"ListObjectName":"usp_cashbook2","UseTranslatedName":true,"WorkbookLanguage":"zh-hant"}
cash_by_months=s02.usp_cash_by_months,(Default),False,$B$3,,{"Parameters":{"year":2022},"ListObjectName":"cash_by_months","UseTranslatedName":true,"WorkbookLanguage":"zh-hant"}
translations=s02.view_translations,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","LANGUAGE_NAME":"zh-hant"},"ListObjectName":"translations","UseTranslatedName":true,"WorkbookLanguage":"zh-hant"}', N's02');
INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 02 - Advanced Features - User3 (Translation, French).xlsx', N'https://www.savetodb.com/downloads/v10/sample02-user3-fr.xlsx', N'usp_cashbook2=s02.usp_cashbook2,(Default),False,$B$3,,{"Parameters":{"account_id":1,"item_id":null,"company_id":null,"start_date":null,"end_date":null,"checked":null},"ListObjectName":"usp_cashbook2","UseTranslatedName":true,"WorkbookLanguage":"fr"}
cash_by_months=s02.usp_cash_by_months,(Default),False,$B$3,,{"Parameters":{"year":2022},"ListObjectName":"cash_by_months","UseTranslatedName":true,"WorkbookLanguage":"fr"}
translations=s02.view_translations,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","LANGUAGE_NAME":"fr"},"ListObjectName":"translations","UseTranslatedName":true,"WorkbookLanguage":"fr"}', N's02');
INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 02 - Advanced Features - User3 (Translation, German).xlsx', N'https://www.savetodb.com/downloads/v10/sample02-user3-de.xlsx', N'usp_cashbook2=s02.usp_cashbook2,(Default),False,$B$3,,{"Parameters":{"account_id":1,"item_id":null,"company_id":null,"start_date":null,"end_date":null,"checked":null},"ListObjectName":"usp_cashbook2","UseTranslatedName":true,"WorkbookLanguage":"de"}
cash_by_months=s02.usp_cash_by_months,(Default),False,$B$3,,{"Parameters":{"year":2022},"ListObjectName":"cash_by_months","UseTranslatedName":true,"WorkbookLanguage":"de"}
translations=s02.view_translations,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","LANGUAGE_NAME":"de"},"ListObjectName":"translations","UseTranslatedName":true,"WorkbookLanguage":"de"}', N's02');
INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 02 - Advanced Features - User3 (Translation, Italian).xlsx', N'https://www.savetodb.com/downloads/v10/sample02-user3-it.xlsx', N'usp_cashbook2=s02.usp_cashbook2,(Default),False,$B$3,,{"Parameters":{"account_id":1,"item_id":null,"company_id":null,"start_date":null,"end_date":null,"checked":null},"ListObjectName":"usp_cashbook2","UseTranslatedName":true,"WorkbookLanguage":"it"}
cash_by_months=s02.usp_cash_by_months,(Default),False,$B$3,,{"Parameters":{"year":2022},"ListObjectName":"cash_by_months","UseTranslatedName":true,"WorkbookLanguage":"it"}
translations=s02.view_translations,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","LANGUAGE_NAME":"it"},"ListObjectName":"translations","UseTranslatedName":true,"WorkbookLanguage":"it"}', N's02');
INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 02 - Advanced Features - User3 (Translation, Japanese).xlsx', N'https://www.savetodb.com/downloads/v10/sample02-user3-ja.xlsx', N'usp_cashbook2=s02.usp_cashbook2,(Default),False,$B$3,,{"Parameters":{"account_id":1,"item_id":null,"company_id":null,"start_date":null,"end_date":null,"checked":null},"ListObjectName":"usp_cashbook2","UseTranslatedName":true,"WorkbookLanguage":"ja"}
cash_by_months=s02.usp_cash_by_months,(Default),False,$B$3,,{"Parameters":{"year":2022},"ListObjectName":"cash_by_months","UseTranslatedName":true,"WorkbookLanguage":"ja"}
translations=s02.view_translations,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","LANGUAGE_NAME":"ja"},"ListObjectName":"translations","UseTranslatedName":true,"WorkbookLanguage":"ja"}', N's02');
INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 02 - Advanced Features - User3 (Translation, Korean).xlsx', N'https://www.savetodb.com/downloads/v10/sample02-user3-ko.xlsx', N'usp_cashbook2=s02.usp_cashbook2,(Default),False,$B$3,,{"Parameters":{"account_id":1,"item_id":null,"company_id":null,"start_date":null,"end_date":null,"checked":null},"ListObjectName":"usp_cashbook2","UseTranslatedName":true,"WorkbookLanguage":"ko"}
cash_by_months=s02.usp_cash_by_months,(Default),False,$B$3,,{"Parameters":{"year":2022},"ListObjectName":"cash_by_months","UseTranslatedName":true,"WorkbookLanguage":"ko"}
translations=s02.view_translations,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","LANGUAGE_NAME":"ko"},"ListObjectName":"translations","UseTranslatedName":true,"WorkbookLanguage":"ko"}', N's02');
INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 02 - Advanced Features - User3 (Translation, Portuguese).xlsx', N'https://www.savetodb.com/downloads/v10/sample02-user3-pt.xlsx', N'usp_cashbook2=s02.usp_cashbook2,(Default),False,$B$3,,{"Parameters":{"account_id":1,"item_id":null,"company_id":null,"start_date":null,"end_date":null,"checked":null},"ListObjectName":"usp_cashbook2","UseTranslatedName":true,"WorkbookLanguage":"pt"}
cash_by_months=s02.usp_cash_by_months,(Default),False,$B$3,,{"Parameters":{"year":2022},"ListObjectName":"cash_by_months","UseTranslatedName":true,"WorkbookLanguage":"pt"}
translations=s02.view_translations,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","LANGUAGE_NAME":"pt"},"ListObjectName":"translations","UseTranslatedName":true,"WorkbookLanguage":"pt"}', N's02');
INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 02 - Advanced Features - User3 (Translation, Russian).xlsx', N'https://www.savetodb.com/downloads/v10/sample02-user3-ru.xlsx', N'usp_cashbook2=s02.usp_cashbook2,(Default),False,$B$3,,{"Parameters":{"account_id":1,"item_id":null,"company_id":null,"start_date":null,"end_date":null,"checked":null},"ListObjectName":"usp_cashbook2","UseTranslatedName":true,"WorkbookLanguage":"ru"}
cash_by_months=s02.usp_cash_by_months,(Default),False,$B$3,,{"Parameters":{"year":2022},"ListObjectName":"cash_by_months","UseTranslatedName":true,"WorkbookLanguage":"ru"}
translations=s02.view_translations,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","LANGUAGE_NAME":"ru"},"ListObjectName":"translations","UseTranslatedName":true,"WorkbookLanguage":"ru"}', N's02');
INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 02 - Advanced Features - User3 (Translation, Spanish).xlsx', N'https://www.savetodb.com/downloads/v10/sample02-user3-es.xlsx', N'usp_cashbook2=s02.usp_cashbook2,(Default),False,$B$3,,{"Parameters":{"account_id":1,"item_id":null,"company_id":null,"start_date":null,"end_date":null,"checked":null},"ListObjectName":"usp_cashbook2","UseTranslatedName":true,"WorkbookLanguage":"es"}
cash_by_months=s02.usp_cash_by_months,(Default),False,$B$3,,{"Parameters":{"year":2022},"ListObjectName":"cash_by_months","UseTranslatedName":true,"WorkbookLanguage":"es"}
translations=s02.view_translations,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","LANGUAGE_NAME":"es"},"ListObjectName":"translations","UseTranslatedName":true,"WorkbookLanguage":"es"}', N's02');
INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 02 - Advanced Features - User5 (Developer).xlsx', N'https://www.savetodb.com/downloads/v10/sample02-user5.xlsx', N'cashbook=s02.cashbook,(Default),True,$B$3,,{"Parameters":{"account_id":null,"item_id":null,"company_id":null},"ListObjectName":"cashbook"}
objects=xls.objects,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","TABLE_TYPE":null},"ListObjectName":"objects"}
handlers=xls.handlers,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","TABLE_NAME":null,"EVENT_NAME":null},"ListObjectName":"handlers"}
translations=xls.translations,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02","TABLE_NAME":null,"LANGUAGE_NAME":"en"},"ListObjectName":"translations"}
all_translations=xls.view_all_translations,(Default),False,$B$3,,{"Parameters":{"TRANSLATION_TYPE":null,"TABLE_TYPE":null,"TABLE_SCHEMA":"s02","LANGUAGE_NAME":"en"},"ListObjectName":"all_translations"}
translation_pivot=xls.usp_translations,(Default),False,$B$3,,{"Parameters":{"field":"TRANSLATED_NAME","schema":"s02"},"ListObjectName":"translation_pivot"}
workbooks=xls.workbooks,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s02"},"ListObjectName":"workbooks"}
primary_keys=xls.view_primary_keys,(Default),False,$B$3,,{"Parameters":{"SCHEMA":"s02"},"ListObjectName":"primary_keys"}
unique_keys=xls.view_unique_keys,(Default),False,$B$3,,{"Parameters":{"SCHEMA":"s02"},"ListObjectName":"unique_keys"}
foreign_keys=xls.view_foreign_keys,(Default),False,$B$3,,{"Parameters":{"SCHEMA":"s02"},"ListObjectName":"foreign_keys"}', N's02');
INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 02 - Advanced Features - User6 (Administrator).xlsx', N'https://www.savetodb.com/downloads/v10/sample02-user6.xlsx', N'database_permissions=xls.usp_database_permissions,(Default),False,$B$3,,{"Parameters":{},"ListObjectName":"database_permissions"}
principal_permissions=xls.usp_principal_permissions,(Default),False,$B$3,,{"Parameters":{"principal":null,"name":null,"has_any":1},"ListObjectName":"principal_permissions"}
object_permissions=xls.usp_object_permissions,(Default),False,$B$3,,{"Parameters":{"principal":null,"schema":null,"type":null,"has_any":null,"has_direct":1},"ListObjectName":"object_permissions"}
role_members=xls.usp_role_members,(Default),False,$B$3,,{"Parameters":{},"ListObjectName":"role_members"}', N's02');
GO

print 'Application installed';
