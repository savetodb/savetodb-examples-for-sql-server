-- =============================================
-- Application: Sample 16 - Symbol lists
-- Version 10.8, January 9, 2023
--
-- Copyright 2019-2023 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON
GO

CREATE SCHEMA s16;
GO

CREATE TABLE s16.exchanges (
    id int NOT NULL
    , exchange nvarchar(50) NOT NULL
    , CONSTRAINT PK_exchanges PRIMARY KEY (id)
    , CONSTRAINT IX_exchanges_exchange UNIQUE (exchange)
);
GO

CREATE TABLE s16.lists (
    id int NOT NULL
    , name nvarchar(50) NOT NULL
    , is_active bit NOT NULL CONSTRAINT DF_lists_is_active DEFAULT((1))
    , CONSTRAINT PK_lists PRIMARY KEY (id)
    , CONSTRAINT IX_lists UNIQUE (name)
);
GO

CREATE TABLE s16.providers (
    id int NOT NULL
    , provider nvarchar(50) NOT NULL
    , is_active bit NOT NULL CONSTRAINT DF_providers_is_active DEFAULT((1))
    , CONSTRAINT PK_providers PRIMARY KEY (id)
    , CONSTRAINT IX_providers UNIQUE (provider)
);
GO

CREATE TABLE s16.schedulers (
    id int NOT NULL
    , name nvarchar(50) NOT NULL
    , CONSTRAINT PK_schedulers PRIMARY KEY (id)
    , CONSTRAINT IX_schedulers_name UNIQUE (name)
);
GO

CREATE TABLE s16.symbol_types (
    id tinyint NOT NULL
    , symbol_type nvarchar(50) NOT NULL
    , CONSTRAINT PK_symbol_types PRIMARY KEY (id)
    , CONSTRAINT IX_symbol_types UNIQUE (symbol_type)
);
GO

CREATE TABLE s16.scheduled_lists (
    provider_id int NOT NULL
    , list_id int NOT NULL
    , scheduler_id int NULL
    , CONSTRAINT PK_scheduled_lists PRIMARY KEY (provider_id, list_id)
);
GO

ALTER TABLE s16.scheduled_lists ADD CONSTRAINT FK_scheduled_lists_lists FOREIGN KEY (list_id) REFERENCES s16.lists (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

ALTER TABLE s16.scheduled_lists ADD CONSTRAINT FK_scheduled_lists_providers FOREIGN KEY (provider_id) REFERENCES s16.providers (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

ALTER TABLE s16.scheduled_lists ADD CONSTRAINT FK_scheduled_lists_schedulers FOREIGN KEY (scheduler_id) REFERENCES s16.schedulers (id) ON DELETE SET NULL ON UPDATE CASCADE;
GO

CREATE TABLE s16.symbols (
    id int IDENTITY(1,1) NOT NULL
    , symbol nvarchar(50) NOT NULL
    , exchange_id int NULL
    , symbol_type_id tinyint NULL
    , is_active bit NOT NULL CONSTRAINT DF_symbols_is_active DEFAULT((1))
    , CONSTRAINT PK_symbols PRIMARY KEY (id)
    , CONSTRAINT IX_symbols UNIQUE (symbol)
);
GO

ALTER TABLE s16.symbols ADD CONSTRAINT FK_symbols_exchanges FOREIGN KEY (exchange_id) REFERENCES s16.exchanges (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

ALTER TABLE s16.symbols ADD CONSTRAINT FK_symbols_symbol_types FOREIGN KEY (symbol_type_id) REFERENCES s16.symbol_types (id) ON DELETE SET NULL ON UPDATE CASCADE;
GO

CREATE TABLE s16.list_symbols (
    list_id int NOT NULL
    , symbol_id int NOT NULL
    , CONSTRAINT PK_list_symbols PRIMARY KEY (list_id, symbol_id)
);
GO

ALTER TABLE s16.list_symbols ADD CONSTRAINT FK_list_symbols_lists FOREIGN KEY (list_id) REFERENCES s16.lists (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

ALTER TABLE s16.list_symbols ADD CONSTRAINT FK_list_symbols_symbols FOREIGN KEY (symbol_id) REFERENCES s16.symbols (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects an index of database objects for Excel worksheets
-- =============================================

CREATE VIEW [s16].[view_index]
AS

SELECT
    ROW_NUMBER() OVER(ORDER BY s.name, o.name) AS [#]
    , s.name + '.' + o.name AS [object]
FROM
    sys.objects o
    INNER JOIN sys.schemas s ON s.[schema_id] = o.[schema_id]
WHERE
    s.name IN ('s16')
    AND o.name IN (
          'exchanges'
        , 'lists'
        , 'providers'
        , 'schedulers'
        , 'symbol_types'
        , 'symbols'
        , 'usp_scheduled_lists'
        , 'usp_symbol_lists'
        )


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view generates application handlers
-- =============================================

CREATE VIEW [s16].[xl_app_handlers]
AS

SELECT
    's16' AS TABLE_SCHEMA
    , 'usp_scheduled_lists' TABLE_NAME
    , l.name AS COLUMN_NAME
    , 'ValidationList' AS EVENT_NAME
    , 's16' AS HANDLER_SCHEMA
    , 'schedulers' AS HANDLER_NAME
    , 'TABLE' AS HANDLER_TYPE
    , 'id, name' HANDLER_CODE
    , CAST(NULL AS nvarchar) AS TARGET_WORKSHEET
    , CAST(NULL AS int) AS MENU_ORDER
    , CAST(NULL AS bit) AS EDIT_PARAMETERS
FROM
    s16.lists l
UNION ALL
SELECT
    's16' AS TABLE_SCHEMA
    , 'usp_symbol_lists' TABLE_NAME
    , l.name AS COLUMN_NAME
    , 'BitColumn' AS EVENT_NAME
    , CAST(NULL AS nvarchar) AS HANDLER_SCHEMA
    , CAST(NULL AS nvarchar) AS HANDLER_NAME
    , CAST(NULL AS nvarchar) AS HANDLER_TYPE
    , CAST(NULL AS nvarchar) HANDLER_CODE
    , CAST(NULL AS nvarchar) AS TARGET_WORKSHEET
    , CAST(NULL AS int) AS MENU_ORDER
    , CAST(NULL AS bit) AS EDIT_PARAMETERS
FROM
    s16.lists l
UNION ALL
SELECT
    's16' AS TABLE_SCHEMA
    , 'usp_symbol_lists' TABLE_NAME
    , 'exchange_id' AS COLUMN_NAME
    , 'ParameterValues' AS EVENT_NAME
    , 's16' AS HANDLER_SCHEMA
    , 'exchanges' AS HANDLER_NAME
    , 'TABLE' AS HANDLER_TYPE
    , '+id, exchange' HANDLER_CODE
    , CAST(NULL AS nvarchar) AS TARGET_WORKSHEET
    , CAST(NULL AS int) AS MENU_ORDER
    , CAST(NULL AS bit) AS EDIT_PARAMETERS
UNION ALL
SELECT
    's16' AS TABLE_SCHEMA
    , 'usp_symbol_lists' TABLE_NAME
    , 'symbol_type_id' AS COLUMN_NAME
    , 'ParameterValues' AS EVENT_NAME
    , 's16' AS HANDLER_SCHEMA
    , 'symbol_types' AS HANDLER_NAME
    , 'TABLE' AS HANDLER_TYPE
    , '+id, symbol_type' AS HANDLER_CODE
    , CAST(NULL AS nvarchar) AS TARGET_WORKSHEET
    , CAST(NULL AS int) AS MENU_ORDER
    , CAST(NULL AS bit) AS EDIT_PARAMETERS
UNION ALL
SELECT
    's16' AS TABLE_SCHEMA
    , 'usp_symbol_lists' TABLE_NAME
    , 'exchange_id' AS COLUMN_NAME
    , 'ValidationList' AS EVENT_NAME
    , 's16' AS HANDLER_SCHEMA
    , 'exchanges' AS HANDLER_NAME
    , 'TABLE' AS HANDLER_TYPE
    , '+id, exchange' HANDLER_CODE
    , CAST(NULL AS nvarchar) AS TARGET_WORKSHEET
    , CAST(NULL AS int) AS MENU_ORDER
    , CAST(NULL AS bit) AS EDIT_PARAMETERS
UNION ALL
SELECT
    's16' AS TABLE_SCHEMA
    , 'usp_symbol_lists' TABLE_NAME
    , 'symbol_type_id' AS COLUMN_NAME
    , 'ValidationList' AS EVENT_NAME
    , 's16' AS HANDLER_SCHEMA
    , 'symbol_types' AS HANDLER_NAME
    , 'TABLE' AS HANDLER_TYPE
    , '+id, symbol_type' AS HANDLER_CODE
    , CAST(NULL AS nvarchar) AS TARGET_WORKSHEET
    , CAST(NULL AS int) AS MENU_ORDER
    , CAST(NULL AS bit) AS EDIT_PARAMETERS
UNION ALL
SELECT
    's16' AS TABLE_SCHEMA
    , 'view_index' TABLE_NAME
    , 'object' AS COLUMN_NAME
    , 'AddHyperlinks' AS EVENT_NAME
    , CAST(NULL AS nvarchar) AS HANDLER_SCHEMA
    , CAST(NULL AS nvarchar) AS HANDLER_NAME
    , CAST(NULL AS nvarchar) AS HANDLER_TYPE
    , CAST(NULL AS nvarchar) AS HANDLER_CODE
    , CAST(NULL AS nvarchar) AS TARGET_WORKSHEET
    , CAST(NULL AS int) AS MENU_ORDER
    , CAST(NULL AS bit) AS EDIT_PARAMETERS


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects scheduled lists
-- =============================================

CREATE PROCEDURE [s16].[usp_scheduled_lists]
AS
BEGIN

SET NOCOUNT ON

DECLARE @sql nvarchar(max)
DECLARE @lists nvarchar(max)

SELECT @lists = STUFF((
    SELECT
        ', [' + f.name + ']' AS name
    FROM
        s16.lists f
    ORDER BY
        f.id
    FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 2, '')

SET @sql = 'SELECT
    s.id
    , s.provider
    , ' + @lists + '
FROM
    s16.providers s
    LEFT OUTER JOIN (
        SELECT
            ls.provider_id
            , l.name
            , ls.scheduler_id AS value
        FROM
            s16.scheduled_lists ls
            INNER JOIN s16.lists l ON l.id = ls.list_id
    ) s PIVOT (
        MAX(value) FOR name IN (' + @lists + ')
    ) p ON p.provider_id = s.id
ORDER BY
    s.id
    , s.provider'

-- PRINT @sql
EXEC (@sql)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Updates scheduled lists
-- =============================================

CREATE PROCEDURE [s16].[usp_scheduled_lists_change]
    @column_name nvarchar(128) = NULL
    , @cell_number_value int = NULL
    , @id int = NULL
AS
BEGIN

SET NOCOUNT ON

DECLARE @list_id int = (SELECT id FROM s16.lists WHERE name = @column_name)
DECLARE @scheduler_id int = (SELECT id FROM s16.schedulers WHERE id = @cell_number_value)

IF @list_id IS NULL OR @id IS NULL
    RETURN

SET NOCOUNT OFF;

IF @scheduler_id IS NULL
    DELETE FROM s16.scheduled_lists WHERE list_id = @list_id AND provider_id = @id
ELSE
    MERGE s16.scheduled_lists t
    USING (SELECT @id AS provider_id, @list_id AS list_id) s ON s.provider_id = t.provider_id AND s.list_id = t.list_id
    WHEN MATCHED THEN
        UPDATE SET scheduler_id = @scheduler_id
    WHEN NOT MATCHED THEN
        INSERT (provider_id, list_id, scheduler_id) VALUES (provider_id, list_id, @scheduler_id);

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects symbol lists
-- =============================================

CREATE PROCEDURE [s16].[usp_symbol_lists]
    @exchange_id int = NULL
    , @symbol_type_id tinyint = NULL
AS
BEGIN

SET NOCOUNT ON

DECLARE @sql nvarchar(max)
DECLARE @lists nvarchar(max)

SELECT @lists = STUFF((
    SELECT
        ', [' + f.name + ']' AS name
    FROM
        s16.lists f
    ORDER BY
        f.id
    FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 2, '')

SET @sql = 'SELECT
    s.id
    , s.symbol
    , s.exchange_id
    , s.symbol_type_id
    , ' + @lists + '
FROM
    s16.symbols s
    LEFT OUTER JOIN (
        SELECT
            ls.symbol_id
            , l.name
            , 1 AS value
        FROM
            s16.list_symbols ls
            INNER JOIN s16.lists l ON l.id = ls.list_id
    ) s PIVOT (
        MAX(value) FOR name IN (' + @lists + ')
    ) p ON p.symbol_id = s.id
' + CASE WHEN @exchange_id IS NOT NULL OR @symbol_type_id IS NOT NULL THEN 'WHERE
' ELSE '' END
    + CASE WHEN @exchange_id IS NOT NULL THEN '    s.exchange_id = ' + CAST(@exchange_id AS nvarchar) ELSE '' END
    + CASE WHEN @symbol_type_id IS NOT NULL THEN '    ' + CASE WHEN @exchange_id IS NOT NULL THEN 'AND ' ELSE '' END
        + 's.symbol_type_id = ' + CAST(@symbol_type_id AS nvarchar) ELSE '' END
    + '
ORDER BY
    s.symbol_type_id
    , s.symbol'

-- PRINT @sql
EXEC (@sql)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Updates symbol lists
-- =============================================

CREATE PROCEDURE [s16].[usp_symbol_lists_change]
    @column_name nvarchar(128) = NULL
    , @cell_number_value int = NULL
    , @id int = NULL
AS
BEGIN

IF @column_name = 'exchange_id'
    BEGIN
    UPDATE s16.symbols SET exchange_id = @cell_number_value WHERE id = @id
    RETURN
    END

IF @column_name = 'symbol_type_id'
    BEGIN
    UPDATE s16.symbols SET symbol_type_id = @cell_number_value WHERE id = @id
    RETURN
    END

SET NOCOUNT OFF;

MERGE s16.list_symbols t
USING (
    SELECT id AS list_id, @id AS symbol_id, @cell_number_value AS value FROM s16.lists WHERE name = @column_name
) s ON s.list_id = t.list_id AND s.symbol_id = t.symbol_id
WHEN MATCHED AND (s.value IS NULL OR s.value = 0) THEN
    DELETE
WHEN NOT MATCHED AND s.list_id IS NOT NULL AND s.symbol_id IS NOT NULL AND s.value = 1 THEN
    INSERT (list_id, symbol_id) VALUES (list_id, symbol_id);

END


GO

INSERT INTO s16.exchanges (id, exchange) VALUES (1, N'Forex');
INSERT INTO s16.exchanges (id, exchange) VALUES (2, N'NASDAQ');
INSERT INTO s16.exchanges (id, exchange) VALUES (3, N'NYSE');
GO

INSERT INTO s16.lists (id, name, is_active) VALUES (1, N'Intraday', 1);
INSERT INTO s16.lists (id, name, is_active) VALUES (2, N'Quotes', 1);
INSERT INTO s16.lists (id, name, is_active) VALUES (3, N'Historical Prices', 1);
INSERT INTO s16.lists (id, name, is_active) VALUES (4, N'Options', 1);
INSERT INTO s16.lists (id, name, is_active) VALUES (5, N'Currencies', 1);
GO

INSERT INTO s16.providers (id, provider, is_active) VALUES (1, N'Yahoo Finance Historical Prices', 1);
INSERT INTO s16.providers (id, provider, is_active) VALUES (2, N'Yahoo Finance Options', 1);
INSERT INTO s16.providers (id, provider, is_active) VALUES (3, N'Yahoo Finance Quotes', 1);
INSERT INTO s16.providers (id, provider, is_active) VALUES (4, N'MSN Money Historical Prices', 1);
INSERT INTO s16.providers (id, provider, is_active) VALUES (5, N'MSN Money Options', 1);
INSERT INTO s16.providers (id, provider, is_active) VALUES (6, N'MSN Money Quotes', 1);
INSERT INTO s16.providers (id, provider, is_active) VALUES (7, N'TD Ameritrade Historical Prices', 1);
INSERT INTO s16.providers (id, provider, is_active) VALUES (8, N'TD Ameritrade Options', 1);
INSERT INTO s16.providers (id, provider, is_active) VALUES (9, N'TD Ameritrade Quotes', 1);
GO

INSERT INTO s16.schedulers (id, name) VALUES (4, N'Daily');
INSERT INTO s16.schedulers (id, name) VALUES (2, N'Intraday');
INSERT INTO s16.schedulers (id, name) VALUES (7, N'Monthly');
INSERT INTO s16.schedulers (id, name) VALUES (1, N'None');
INSERT INTO s16.schedulers (id, name) VALUES (5, N'On Saturday');
INSERT INTO s16.schedulers (id, name) VALUES (6, N'On Sunday');
INSERT INTO s16.schedulers (id, name) VALUES (3, N'Weekdays');
GO

INSERT INTO s16.symbol_types (id, symbol_type) VALUES (7, N'Currency');
INSERT INTO s16.symbol_types (id, symbol_type) VALUES (2, N'ETF');
INSERT INTO s16.symbol_types (id, symbol_type) VALUES (6, N'Future');
INSERT INTO s16.symbol_types (id, symbol_type) VALUES (4, N'Index');
INSERT INTO s16.symbol_types (id, symbol_type) VALUES (3, N'Mutual Fund');
INSERT INTO s16.symbol_types (id, symbol_type) VALUES (5, N'Option');
INSERT INTO s16.symbol_types (id, symbol_type) VALUES (1, N'Stock');
INSERT INTO s16.symbol_types (id, symbol_type) VALUES (0, N'Unknown');
GO

INSERT INTO s16.scheduled_lists (provider_id, list_id, scheduler_id) VALUES (1, 3, 4);
INSERT INTO s16.scheduled_lists (provider_id, list_id, scheduler_id) VALUES (2, 4, 4);
INSERT INTO s16.scheduled_lists (provider_id, list_id, scheduler_id) VALUES (3, 2, 4);
INSERT INTO s16.scheduled_lists (provider_id, list_id, scheduler_id) VALUES (4, 3, 4);
INSERT INTO s16.scheduled_lists (provider_id, list_id, scheduler_id) VALUES (5, 4, 4);
INSERT INTO s16.scheduled_lists (provider_id, list_id, scheduler_id) VALUES (6, 2, 4);
INSERT INTO s16.scheduled_lists (provider_id, list_id, scheduler_id) VALUES (7, 3, 4);
INSERT INTO s16.scheduled_lists (provider_id, list_id, scheduler_id) VALUES (8, 4, 4);
INSERT INTO s16.scheduled_lists (provider_id, list_id, scheduler_id) VALUES (9, 2, 4);
GO

SET IDENTITY_INSERT s16.symbols ON;
INSERT INTO s16.symbols (id, symbol, exchange_id, symbol_type_id, is_active) VALUES (1, N'AAPL', 2, 1, 1);
INSERT INTO s16.symbols (id, symbol, exchange_id, symbol_type_id, is_active) VALUES (2, N'AMZN', 2, 1, 1);
INSERT INTO s16.symbols (id, symbol, exchange_id, symbol_type_id, is_active) VALUES (3, N'MSFT', 2, 1, 1);
INSERT INTO s16.symbols (id, symbol, exchange_id, symbol_type_id, is_active) VALUES (4, N'USD/EUR', 1, 7, 1);
INSERT INTO s16.symbols (id, symbol, exchange_id, symbol_type_id, is_active) VALUES (5, N'USD/JPY', 1, 7, 1);
INSERT INTO s16.symbols (id, symbol, exchange_id, symbol_type_id, is_active) VALUES (6, N'GBP/USD', 1, 7, 1);
INSERT INTO s16.symbols (id, symbol, exchange_id, symbol_type_id, is_active) VALUES (7, N'USD/CHF', 1, 7, 1);
SET IDENTITY_INSERT s16.symbols OFF;
GO

INSERT INTO s16.list_symbols (list_id, symbol_id) VALUES (2, 1);
INSERT INTO s16.list_symbols (list_id, symbol_id) VALUES (2, 2);
INSERT INTO s16.list_symbols (list_id, symbol_id) VALUES (2, 3);
INSERT INTO s16.list_symbols (list_id, symbol_id) VALUES (5, 4);
INSERT INTO s16.list_symbols (list_id, symbol_id) VALUES (5, 5);
INSERT INTO s16.list_symbols (list_id, symbol_id) VALUES (5, 6);
INSERT INTO s16.list_symbols (list_id, symbol_id) VALUES (5, 7);
GO

print 'Application installed';
