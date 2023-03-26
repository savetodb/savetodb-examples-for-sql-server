-- =============================================
-- Application: Sample 24 - Advanced JSON Features
-- Version 10.8, January 9, 2023
--
-- Copyright 2021-2023 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON
GO

CREATE SCHEMA s24;
GO

CREATE TABLE s24.accounts (
    id int IDENTITY(1,1) NOT NULL
    , name nvarchar(50) NOT NULL
    , CONSTRAINT PK_accounts PRIMARY KEY (id)
    , CONSTRAINT IX_accounts_name UNIQUE (name)
);
GO

CREATE TABLE s24.companies (
    id int IDENTITY(1,1) NOT NULL
    , name nvarchar(50) NOT NULL
    , CONSTRAINT PK_companies PRIMARY KEY (id)
);
GO

CREATE INDEX IX_companies_name ON s24.companies (name);
GO

CREATE TABLE s24.items (
    id int IDENTITY(1,1) NOT NULL
    , name nvarchar(50) NOT NULL
    , CONSTRAINT PK_items PRIMARY KEY (id)
    , CONSTRAINT IX_items_name UNIQUE (name)
);
GO

CREATE TABLE s24.cashbook (
    id int IDENTITY(1,1) NOT NULL
    , date date NOT NULL
    , account_id int NOT NULL
    , item_id int NULL
    , company_id int NULL
    , debit money NULL
    , credit money NULL
    , CONSTRAINT PK_cashbook PRIMARY KEY (id)
);
GO

ALTER TABLE s24.cashbook ADD CONSTRAINT FK_cashbook_accounts FOREIGN KEY (account_id) REFERENCES s24.accounts (id) ON UPDATE CASCADE;
GO

ALTER TABLE s24.cashbook ADD CONSTRAINT FK_cashbook_companies FOREIGN KEY (company_id) REFERENCES s24.companies (id) ON UPDATE CASCADE;
GO

ALTER TABLE s24.cashbook ADD CONSTRAINT FK_cashbook_items FOREIGN KEY (item_id) REFERENCES s24.items (id) ON UPDATE CASCADE;
GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE VIEW [s24].[view_cashbook_json_changes_f1]
AS

SELECT
    *
FROM
    s24.cashbook t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE VIEW [s24].[view_cashbook_json_changes_f2]
AS

SELECT
    *
FROM
    s24.cashbook t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE VIEW [s24].[view_cashbook_json_generic_row]
AS

SELECT
    *
FROM
    s24.cashbook t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE VIEW [s24].[view_cashbook_json_generic_table]
AS

SELECT
    *
FROM
    s24.cashbook t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE VIEW [s24].[view_cashbook_json_values_f1]
AS

SELECT
    *
FROM
    s24.cashbook t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cash book
-- =============================================

CREATE VIEW [s24].[view_cashbook_json_values_f2]
AS

SELECT
    *
FROM
    s24.cashbook t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Edit procedure for view_cashbook_json_changes_f1
--
-- This is a single procedure used to apply data changes using a single procedure call.
--
-- The procedure has the @json_changes_f1 parameter that gets all changes in JSON.
--
-- The procedure also has the @id parameter passed for DELETE operations.
--
-- Please note that single call procedures must be specified as a single UPDATE object,
-- using the _update suffix or using the UPDATE_OBJECT field in the xls.objects table.
-- =============================================

CREATE PROCEDURE [s24].[view_cashbook_json_changes_f1_update]
    @id int = NULL
    , @json_changes_f1 nvarchar(max) = NULL
AS
BEGIN
SET NOCOUNT ON

DECLARE @insert nvarchar(max),  @update nvarchar(max), @delete nvarchar(max)

SELECT
    @insert = t2.[insert]
    , @update = t2.[update]
    , @delete = t2.[delete]
FROM
    OPENJSON(@json_changes_f1) WITH (
        actions nvarchar(max) AS json
    ) t1
    CROSS APPLY OPENJSON(t1.actions) WITH (
        [insert] nvarchar(max) '$.insert' AS json
        , [update] nvarchar(max) '$.update' AS json
        , [delete] nvarchar(max) '$.delete' AS json
    ) t2

IF @insert IS NOT NULL
INSERT INTO s24.cashbook
    ([date], account_id, item_id, company_id, debit, credit)
SELECT
    t2.[date], t2.account_id, t2.item_id, t2.company_id, t2.debit, t2.credit
FROM
    OPENJSON(@insert) WITH (
        [rows] nvarchar(max) '$.rows' AS json
    ) t1
    CROSS APPLY OPENJSON(t1.[rows]) WITH (
        [id] int '$[0]'
        , [date] date '$[1]'
        , [account_id] int '$[2]'
        , [item_id] int '$[3]'
        , [company_id] int '$[4]'
        , [debit] float '$[5]'
        , [credit] float '$[6]'
    ) t2;

IF @update IS NOT NULL
UPDATE s24.cashbook
SET
    [date] = t2.[date]
    , account_id = t2.account_id
    , item_id = t2.item_id
    , company_id = t2.company_id
    , debit = t2.debit
    , credit = t2.credit
FROM
    s24.cashbook t
    INNER JOIN (
        SELECT
            t2.id AS id
            , t2.[date] AS [date]
            , t2.account_id AS account_id
            , t2.item_id AS item_id
            , t2.company_id AS company_id
            , t2.debit AS debit
            , t2.credit AS credit
        FROM
            OPENJSON(@update) WITH (
                [rows] nvarchar(max) '$.rows' AS json
            ) t1
            CROSS APPLY OPENJSON(t1.[rows]) WITH (
                [id] int '$[0]'
                , [date] date '$[1]'
                , [account_id] int '$[2]'
                , [item_id] int '$[3]'
                , [company_id] int '$[4]'
                , [debit] float '$[5]'
                , [credit] float '$[6]'
            ) t2
    ) t2 ON t2.id = t.id

IF @delete IS NOT NULL
DELETE FROM s24.cashbook
FROM
    s24.cashbook t
    INNER JOIN (
        SELECT
            t2.[id] AS [id]
        FROM
            OPENJSON(@delete) WITH (
                [rows] nvarchar(max) '$.rows' AS json
            ) t1
            CROSS APPLY OPENJSON(t1.[rows]) WITH (
                [id] int '$[0]'
            ) t2
    ) t2 ON t2.[id] = t.[id]

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Edit procedure for view_cashbook_json_changes_f2
--
-- This is a single procedure used to apply data changes using a single procedure call.
--
-- The procedure has the @json_changes_f2 parameter that gets all changes in JSON.
--
-- The procedure also has the @id parameter passed to DELETE operations.
--
-- Please note that single call procedures must be specified as a single UPDATE object,
-- using the _update suffix or using the UPDATE_OBJECT field in the xls.objects table.
-- =============================================

CREATE PROCEDURE [s24].[view_cashbook_json_changes_f2_update]
    @id int = NULL
    , @json_changes_f2 nvarchar(max) = NULL
AS
BEGIN
SET NOCOUNT ON

DECLARE @insert nvarchar(max),  @update nvarchar(max), @delete nvarchar(max)

SELECT
    @insert = t2.[insert]
    , @update = t2.[update]
    , @delete = t2.[delete]
FROM
    OPENJSON(@json_changes_f2) WITH (
        actions nvarchar(max) AS json
    ) t1
    CROSS APPLY OPENJSON(t1.actions) WITH (
        [insert] nvarchar(max) '$.insert' AS json
        , [update] nvarchar(max) '$.update' AS json
        , [delete] nvarchar(max) '$.delete' AS json
    ) t2

IF @insert IS NOT NULL
INSERT INTO s24.cashbook
    ([date], account_id, item_id, company_id, debit, credit)
SELECT
    t2.[date], t2.account_id, t2.item_id, t2.company_id, t2.debit, t2.credit
FROM
    OPENJSON(@insert) WITH (
        [rows] nvarchar(max) '$.rows' AS json
    ) t1
    CROSS APPLY OPENJSON(t1.[rows]) WITH (
        [id] int '$."id"'
        , [date] date '$."date"'
        , [account_id] int '$."account_id"'
        , [item_id] int '$."item_id"'
        , [company_id] int '$."company_id"'
        , [debit] float '$."debit"'
        , [credit] float '$."credit"'
    ) t2;

IF @update IS NOT NULL
UPDATE s24.cashbook
SET
    [date] = t2.[date]
    , account_id = t2.account_id
    , item_id = t2.item_id
    , company_id = t2.company_id
    , debit = t2.debit
    , credit = t2.credit
FROM
    s24.cashbook t
    INNER JOIN (
        SELECT
            t2.id AS id
            , t2.[date] AS [date]
            , t2.account_id AS account_id
            , t2.item_id AS item_id
            , t2.company_id AS company_id
            , t2.debit AS debit
            , t2.credit AS credit
        FROM
            OPENJSON(@update) WITH (
                [rows] nvarchar(max) '$.rows' AS json
            ) t1
            CROSS APPLY OPENJSON(t1.[rows]) WITH (
                [id] int '$."id"'
                , [date] date '$."date"'
                , [account_id] int '$."account_id"'
                , [item_id] int '$."item_id"'
                , [company_id] int '$."company_id"'
                , [debit] float '$."debit"'
                , [credit] float '$."credit"'
            ) t2
    ) t2 ON t2.id = t.id;

IF @delete IS NOT NULL
DELETE FROM s24.cashbook
FROM
    s24.cashbook t
    INNER JOIN (
        SELECT
            t2.[id] AS [id]
        FROM
            OPENJSON(@delete) WITH (
                [rows] nvarchar(max) '$.rows' AS json
            ) t1
            CROSS APPLY OPENJSON(t1.[rows]) WITH (
                [id] int '$."id"'
            ) t2
    ) t2 ON t2.id = t.id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: DELETE procedure for s24.view_cashbook_json_values_f1
-- =============================================

CREATE PROCEDURE [s24].[view_cashbook_json_values_f1_delete]
    @id int = NULL
AS
BEGIN

DELETE FROM s24.json_test WHERE id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: INSERT procedure for s24.view_cashbook_json_values_f1
--
-- This procedure shows how to use the @json_values_f1 parameter that contains an array of row values.
-- To use it, an Excel table must have columns in the right order as coded in the edit procedure.
-- You can use the @json_columns_f2 parameter that returns an object instead.
-- =============================================

CREATE PROCEDURE [s24].[view_cashbook_json_values_f1_insert]
    @json_columns nvarchar(max)
    , @json_values_f1 nvarchar(max)
AS
BEGIN

SET @json_values_f1 = '[' + @json_values_f1 + ']'    -- Fix for OPENJSON top-level array

INSERT INTO s24.cashbook
    ([date], account_id, item_id, company_id, debit, credit)
SELECT
    t2.[date], t2.account_id, t2.item_id, t2.company_id, t2.debit, t2.credit
FROM
    OPENJSON(@json_values_f1) WITH (
        [id] int '$[0]'
        , [date] date '$[1]'
        , [account_id] int '$[2]'
        , [item_id] int '$[3]'
        , [company_id] int '$[4]'
        , [debit] float '$[5]'
        , [credit] float '$[6]'
    ) t2;

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: UPDATE procedure for s24.view_cashbook_json_values_f1
--
-- This procedure shows how to use the @json_values_f1 parameter that contains an array of row values.
-- To use it, an Excel table must have columns in the right order as coded in the edit procedure.
-- You can use the @json_columns_f2 parameter that returns an object instead.
-- =============================================

CREATE PROCEDURE [s24].[view_cashbook_json_values_f1_update]
    @json_columns nvarchar(max)
    , @json_values_f1 nvarchar(max)
AS
BEGIN

SET @json_values_f1 = '[' + @json_values_f1 + ']'  -- Fix for OPENJSON top-level array

UPDATE s24.cashbook
SET
    [date] = t2.date
    , account_id = t2.account_id
    , item_id = t2.item_id
    , company_id = t2.company_id
    , debit = t2.debit
    , credit = t2.credit
FROM
    s24.cashbook t
    INNER JOIN OPENJSON(@json_values_f1) WITH (
        [id] int '$[0]'
        , [date] date '$[1]'
        , [account_id] int '$[2]'
        , [item_id] int '$[3]'
        , [company_id] int '$[4]'
        , [debit] float '$[5]'
        , [credit] float '$[6]'
    ) t2 ON t2.id = t.id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: DELETE procedure for s24.view_cashbook_json_values_f2
-- =============================================

CREATE PROCEDURE [s24].[view_cashbook_json_values_f2_delete]
    @id int = NULL
AS
BEGIN

DELETE FROM s24.cashbook WHERE id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: INSERT procedure for s24.view_cashbook_json_values_f2
--
-- This procedure shows how to use the @json_columns_f2 parameter that contains an object of row values.
-- =============================================

CREATE PROCEDURE [s24].[view_cashbook_json_values_f2_insert]
    @json_values_f2 nvarchar(max)
AS
BEGIN

INSERT INTO s24.cashbook
    ([date], account_id, item_id, company_id, debit, credit)
SELECT
    t2.[date], t2.account_id, t2.item_id, t2.company_id, t2.debit, t2.credit
FROM
    OPENJSON(@json_values_f2) WITH (
        [id] int '$."id"'
        , [date] date '$."date"'
        , [account_id] int '$."account_id"'
        , [item_id] int '$."item_id"'
        , [company_id] int '$."company_id"'
        , [debit] float '$."debit"'
        , [credit] float '$."credit"'
    ) t2

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: UPDATE procedure for s24.view_cashbook_json_values_f2
--
-- This procedure shows how to use the @json_columns_f2 parameter that contains an object of row values.
-- =============================================

CREATE PROCEDURE [s24].[view_cashbook_json_values_f2_update]
    @json_values_f2 nvarchar(max)
AS
BEGIN

UPDATE s24.cashbook
SET
    [date] = t2.date
    , account_id = t2.account_id
    , item_id = t2.item_id
    , company_id = t2.company_id
    , debit = t2.debit
    , credit = t2.credit
FROM
    s24.cashbook t
    INNER JOIN OPENJSON(@json_values_f2) WITH (
        [id] int '$."id"'
        , [date] date '$."date"'
        , [account_id] int '$."account_id"'
        , [item_id] int '$."item_id"'
        , [company_id] int '$."company_id"'
        , [debit] float '$."debit"'
        , [credit] float '$."credit"'
    ) t2 ON t2.id = t.id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Generic row update procedure using @json_values_f2
-- =============================================

CREATE PROCEDURE [s24].[xl_update_generic_row]
    @id int = NULL
    , @table_name nvarchar(255) = NULL
    , @edit_action nvarchar(6) = NULL
    , @json_values_f2 nvarchar(max) = NULL
AS
BEGIN
SET NOCOUNT ON

IF OBJECT_ID(@table_name) IS NULL
    RETURN

DECLARE @sql nvarchar(max)

IF @edit_action = 'INSERT'
    BEGIN
    WITH c (column_id, name, value, index_column_id, skip_value) AS (
        SELECT
            t.column_id
            , '[' + REPLACE(t.name, '''', '''''') + ']' AS name
            , CASE WHEN v.value IS NULL THEN 'NULL' WHEN v.[type] = 1 THEN '''' + REPLACE(v.value, '''', '''''') + '''' ELSE v.value END AS value
            , ic.index_column_id
            , CASE WHEN t.is_identity = 1 OR t.is_computed = 1 OR t.system_type_id = 189
                OR (t.system_type_id = 36 AND NOT t.default_object_id = 0) THEN 1 ELSE 0 END AS skip_value

        FROM
            OPENJSON(@json_values_f2) v
            INNER JOIN sys.columns t ON t.[object_id] = OBJECT_ID(@table_name) AND t.name = v.[key] COLLATE Latin1_General_BIN2
            LEFT OUTER JOIN sys.indexes i ON i.[object_id] = t.[object_id] AND i.is_primary_key = 1
            LEFT OUTER JOIN sys.index_columns ic ON ic.[object_id] = i.[object_id] AND ic.index_id = i.index_id AND ic.column_id = t.column_id
    )
    SELECT
        @sql = 'INSERT INTO ' + @table_name + ' ('
        + STUFF((
            SELECT ', ' + c.name FROM c WHERE c.skip_value = 0 ORDER BY c.column_id
                FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 2, '')
        + ') VALUES ('
        + STUFF((
            SELECT ', ' + c.value FROM c WHERE c.skip_value = 0 ORDER BY c.column_id
                FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 2, '')
        + ')'
    END

ELSE IF @edit_action = 'UPDATE'
    BEGIN
    ;WITH c (column_id, name, value, index_column_id, skip_value) AS (
        SELECT
            t.column_id
            , '[' + REPLACE(t.name, '''', '''''') + ']' AS name
            , CASE WHEN v.value IS NULL THEN 'NULL' WHEN v.[type] = 1 THEN '''' + REPLACE(v.value, '''', '''''') + '''' ELSE v.value END AS value
            , ic.index_column_id
            , CASE WHEN t.is_identity = 1 OR t.is_computed = 1 OR t.system_type_id = 189
                OR (t.system_type_id = 36 AND NOT t.default_object_id = 0) THEN 1 ELSE 0 END AS skip_value

        FROM
            OPENJSON(@json_values_f2) v
            INNER JOIN sys.columns t ON t.[object_id] = OBJECT_ID(@table_name) AND t.name = v.[key] COLLATE Latin1_General_BIN2
            LEFT OUTER JOIN sys.indexes i ON i.[object_id] = t.[object_id] AND i.is_primary_key = 1
            LEFT OUTER JOIN sys.index_columns ic ON ic.[object_id] = i.[object_id] AND ic.index_id = i.index_id AND ic.column_id = t.column_id
    )
    SELECT
        @sql = 'UPDATE ' + @table_name + '
SET
'    + STUFF((
            SELECT '    , ' + c.name + ' = ' + c.value + CHAR(13) + CHAR(10) FROM c
                WHERE c.skip_value = 0 AND c.index_column_id IS NULL ORDER BY c.column_id
                FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 5, '     ')
        + 'WHERE
'    + STUFF((
            SELECT '    AND ' + c.name + ' = ' + c.value + CHAR(13) + CHAR(10) FROM c
                WHERE c.index_column_id IS NOT NULL ORDER BY c.index_column_id
                FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 7, '     ')
    END
ELSE IF @edit_action = 'DELETE'
    BEGIN
    SELECT
        @sql = 'DELETE FROM ' + @table_name + ' WHERE id = ' + CAST(@id AS nvarchar(15))
    END
ELSE
    RETURN

-- PRINT @sql

SET NOCOUNT OFF

EXEC (@sql)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: UPDATE procedure for view_cashbook_json_values_f2_generic
-- =============================================

CREATE PROCEDURE [s24].[view_cashbook_json_generic_row_update]
    @id int = NULL
    , @table_name nvarchar(255) = NULL
    , @edit_action nvarchar(6) = NULL
    , @json_values_f2 nvarchar(max) = NULL
AS
BEGIN

EXEC s24.xl_update_generic_row @id, '[s24].[cashbook]', @edit_action, @json_values_f2

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Generic table update procedure using @json_changes_f2
-- =============================================

CREATE PROCEDURE [s24].[xl_update_generic_table]
    @table_name nvarchar(255) = NULL
    , @json_changes_f2 nvarchar(max) = NULL
AS
BEGIN
SET NOCOUNT ON

IF OBJECT_ID(@table_name) IS NULL
    RETURN

DECLARE @insert nvarchar(max),  @update nvarchar(max), @delete nvarchar(max)

SELECT
    @insert = t2.[insert]
    , @update = t2.[update]
    , @delete = t2.[delete]
FROM
    OPENJSON(@json_changes_f2) WITH (
        table_name nvarchar(255) '$.table_name'
        , actions nvarchar(max) AS json
    ) t1
    CROSS APPLY OPENJSON(t1.actions) WITH (
        [insert] nvarchar(max) '$.insert' AS json
        , [update] nvarchar(max) '$.update' AS json
        , [delete] nvarchar(max) '$.delete' AS json
    ) t2

DECLARE @insert_sql nvarchar(max), @update_sql nvarchar(max), @delete_sql nvarchar(max)

IF @insert IS NOT NULL
WITH c (column_id, column_name, datatype, index_column_id, skip_value) AS (
    SELECT
        c.column_id
        , c.[name] AS column_name
        , t.[name] + CASE
            WHEN c.max_length = -1 THEN '(max)'
            WHEN t.name IN ('nvarchar', 'nchar') THEN '(' + CAST(c.max_length/2 AS nvarchar) + ')'
            WHEN t.name IN ('varchar', 'char', 'binary', 'varbinary') THEN '(' + CAST(c.[max_length] AS nvarchar) + ')'
            WHEN t.name IN ('time', 'datetime2', 'datetimeoffset') THEN  '(' + CAST(c.[scale] AS nvarchar) + ')'
            WHEN t.name IN ('decimal', 'numeric') THEN '(' + CAST(c.[precision] AS nvarchar) + ',' + CAST(c.[scale] AS nvarchar) + ')'
            ELSE '' END AS datatype
        , ic.index_column_id
        , CASE WHEN c.is_identity = 1 OR c.is_computed = 1 OR c.system_type_id = 189
            OR (c.system_type_id = 36 AND NOT c.default_object_id = 0) THEN 1 ELSE 0 END AS skip_value
    FROM
        OPENJSON(@insert) WITH ([columns] nvarchar(max) '$.columns' AS json) t1
        CROSS APPLY OPENJSON(t1.[columns]) t2
        INNER JOIN sys.columns c ON c.[object_id] = OBJECT_ID(@table_name) AND c.[name] = t2.[value]
        INNER JOIN sys.types t ON t.user_type_id = c.user_type_id
        LEFT OUTER JOIN sys.indexes i ON i.[object_id] = c.[object_id] AND i.is_primary_key = 1
        LEFT OUTER JOIN sys.index_columns ic ON ic.[object_id] = i.[object_id] AND ic.index_id = i.index_id AND ic.column_id = c.column_id
)
SELECT
    @insert_sql = ''
    + 'INSERT INTO ' + @table_name + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '    , ' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10) FROM c WHERE c.skip_value = 0 ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 6, '    ( ')
    + '    )' + CHAR(13) + CHAR(10)
    + 'SELECT' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '    , t2.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c WHERE c.skip_value = 0 ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 6, '    ')
    + 'FROM
    OPENJSON(@insert) WITH (
        [rows] nvarchar(max) ''$.rows'' AS json
    ) t1
    CROSS APPLY OPENJSON(t1.[rows]) WITH (' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '        , ' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' ' + c.datatype + ' ''$."' + REPLACE(c.column_name, '''', '''''') + '"''' + CHAR(13) + CHAR(10)
            FROM c ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 10, '        ')
    + '    ) t2'

IF @update IS NOT NULL
WITH c (column_id, column_name, datatype, index_column_id, skip_value) AS (
    SELECT
        c.column_id
        , c.[name] AS column_name
        , t.[name] + CASE
            WHEN c.max_length = -1 THEN '(max)'
            WHEN t.name IN ('nvarchar', 'nchar') THEN '(' + CAST(c.max_length/2 AS nvarchar) + ')'
            WHEN t.name IN ('varchar', 'char', 'binary', 'varbinary') THEN '(' + CAST(c.[max_length] AS nvarchar) + ')'
            WHEN t.name IN ('time', 'datetime2', 'datetimeoffset') THEN  '(' + CAST(c.[scale] AS nvarchar) + ')'
            WHEN t.name IN ('decimal', 'numeric') THEN '(' + CAST(c.[precision] AS nvarchar) + ',' + CAST(c.[scale] AS nvarchar) + ')'
            ELSE '' END AS datatype
        , ic.index_column_id
        , CASE WHEN c.is_identity = 1 OR c.is_computed = 1 OR c.system_type_id = 189
            OR (c.system_type_id = 36 AND NOT c.default_object_id = 0) THEN 1 ELSE 0 END AS skip_value
    FROM
        OPENJSON(@update) WITH ([columns] nvarchar(max) '$.columns' AS json) t1
        CROSS APPLY OPENJSON(t1.[columns]) t2
        INNER JOIN sys.columns c ON c.[object_id] = OBJECT_ID(@table_name) AND c.[name] = t2.[value]
        INNER JOIN sys.types t ON t.user_type_id = c.user_type_id
        LEFT OUTER JOIN sys.indexes i ON i.[object_id] = c.[object_id] AND i.is_primary_key = 1
        LEFT OUTER JOIN sys.index_columns ic ON ic.[object_id] = i.[object_id] AND ic.index_id = i.index_id AND ic.column_id = c.column_id
)
SELECT
    @update_sql = ''
    + 'UPDATE ' + @table_name + CHAR(13) + CHAR(10)
    + 'SET' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '    , ' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' = t2.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c WHERE c.skip_value = 0 ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 6, '      ')
    + 'FROM' + CHAR(13) + CHAR(10)
    + '    ' + @table_name + ' t' + CHAR(13) + CHAR(10)
    + '    INNER JOIN (
        SELECT' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '            , t2.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 14, '            ')
    + '        FROM
            OPENJSON(@update) WITH (
                [rows] nvarchar(max) ''$.rows'' AS json
            ) t1
            CROSS APPLY OPENJSON(t1.[rows]) WITH (' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '                , ' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' ' + c.datatype + ' ''$."' + REPLACE(c.column_name, '''', '''''') + '"''' + CHAR(13) + CHAR(10)
            FROM c ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 18, '                ')
    + '            ) t2' + CHAR(13) + CHAR(10)
    + '    ) t2 ON '
    + STUFF((
        SELECT '    AND t.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' = t2.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c WHERE c.index_column_id IS NOT NULL ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 8, '')

IF @delete IS NOT NULL
WITH c (column_id, column_name, datatype, index_column_id, skip_value) AS (
    SELECT
        c.column_id
        , c.[name] AS column_name
        , t.[name] + CASE
            WHEN c.max_length = -1 THEN '(max)'
            WHEN t.name IN ('nvarchar', 'nchar') THEN '(' + CAST(c.max_length/2 AS nvarchar) + ')'
            WHEN t.name IN ('varchar', 'char', 'binary', 'varbinary') THEN '(' + CAST(c.[max_length] AS nvarchar) + ')'
            WHEN t.name IN ('time', 'datetime2', 'datetimeoffset') THEN  '(' + CAST(c.[scale] AS nvarchar) + ')'
            WHEN t.name IN ('decimal', 'numeric') THEN '(' + CAST(c.[precision] AS nvarchar) + ',' + CAST(c.[scale] AS nvarchar) + ')'
            ELSE '' END AS datatype
        , ic.index_column_id
        , CASE WHEN c.is_identity = 1 OR c.is_computed = 1 OR c.system_type_id = 189
            OR (c.system_type_id = 36 AND NOT c.default_object_id = 0) THEN 1 ELSE 0 END AS skip_value
    FROM
        OPENJSON(@delete) WITH ([columns] nvarchar(max) '$.columns' AS json) t1
        CROSS APPLY OPENJSON(t1.[columns]) t2
        INNER JOIN sys.columns c ON c.[object_id] = OBJECT_ID(@table_name) AND c.[name] = t2.[value]
        INNER JOIN sys.types t ON t.user_type_id = c.user_type_id
        LEFT OUTER JOIN sys.indexes i ON i.[object_id] = c.[object_id] AND i.is_primary_key = 1
        LEFT OUTER JOIN sys.index_columns ic ON ic.[object_id] = i.[object_id] AND ic.index_id = i.index_id AND ic.column_id = c.column_id
)
SELECT
    @delete_sql = ''
    + 'DELETE FROM ' + @table_name + CHAR(13) + CHAR(10)
    + 'FROM' + CHAR(13) + CHAR(10)
    + '    ' + @table_name + ' t' + CHAR(13) + CHAR(10)
    + '    INNER JOIN (
        SELECT' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '            , t2.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 14, '            ')
    + '        FROM
            OPENJSON(@delete) WITH (
                [rows] nvarchar(max) ''$.rows'' AS json
            ) t1
            CROSS APPLY OPENJSON(t1.[rows]) WITH (' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '                , ' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' ' + c.datatype + ' ''$."' + REPLACE(c.column_name, '''', '''''') + '"''' + CHAR(13) + CHAR(10)
            FROM c ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 18, '                ')
    + '            ) t2' + CHAR(13) + CHAR(10)
    + '    ) t2 ON '
    + STUFF((
        SELECT '    AND t.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' = t2.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c WHERE c.index_column_id IS NOT NULL ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 8, '')

-- PRINT @insert_sql
-- PRINT @update_sql
-- PRINT @delete_sql

IF @insert_sql IS NOT NULL
EXEC sp_executesql @insert_sql, N'@insert nvarchar(max)', @insert = @insert

IF @update_sql IS NOT NULL
EXEC sp_executesql @update_sql, N'@update nvarchar(max)', @update = @update

IF @delete_sql IS NOT NULL
EXEC sp_executesql @delete_sql, N'@delete nvarchar(max)', @delete = @delete

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Edit procedure for view_cashbook_json_changes_f2_generic
--
-- This is a single procedure used to apply data changes using a single procedure call.
--
-- @json_changes_f2 contains the table_name value.
-- However, this is the name of the database object used to select data.
-- In this example, it is the s24.view_cashbook_json_changes_f2_generic view.
-- You have to find the real underlying table using the object name or just code it like in the sample.
--
-- The procedure has the @id parameter passed for DELETE operations.
--
-- Please note that single call procedures must be specified as a single UPDATE object,
-- using the _update suffix or using the UPDATE_OBJECT field in the xls.objects table.
-- =============================================

CREATE PROCEDURE [s24].[view_cashbook_json_generic_table_update]
    @id int = NULL
    , @table_name nvarchar(255) = NULL
    , @json_changes_f2 nvarchar(max) = NULL
AS
BEGIN

EXEC s24.xl_update_generic_table '[s24].[cashbook]', @json_changes_f2

END


GO

SET IDENTITY_INSERT s24.accounts ON;
INSERT INTO s24.accounts (id, name) VALUES (1, N'Bank');
SET IDENTITY_INSERT s24.accounts OFF;
GO

SET IDENTITY_INSERT s24.companies ON;
INSERT INTO s24.companies (id, name) VALUES (1, N'Customer C1');
INSERT INTO s24.companies (id, name) VALUES (2, N'Customer C2');
INSERT INTO s24.companies (id, name) VALUES (3, N'Customer C3');
INSERT INTO s24.companies (id, name) VALUES (4, N'Customer C4');
INSERT INTO s24.companies (id, name) VALUES (5, N'Customer C5');
INSERT INTO s24.companies (id, name) VALUES (6, N'Customer C6');
INSERT INTO s24.companies (id, name) VALUES (7, N'Customer C7');
INSERT INTO s24.companies (id, name) VALUES (8, N'Supplier S1');
INSERT INTO s24.companies (id, name) VALUES (9, N'Supplier S2');
INSERT INTO s24.companies (id, name) VALUES (10, N'Supplier S3');
INSERT INTO s24.companies (id, name) VALUES (11, N'Supplier S4');
INSERT INTO s24.companies (id, name) VALUES (12, N'Supplier S5');
INSERT INTO s24.companies (id, name) VALUES (13, N'Supplier S6');
INSERT INTO s24.companies (id, name) VALUES (14, N'Supplier S7');
INSERT INTO s24.companies (id, name) VALUES (15, N'Corporate Income Tax');
INSERT INTO s24.companies (id, name) VALUES (16, N'Individual Income Tax');
INSERT INTO s24.companies (id, name) VALUES (17, N'Payroll Taxes');
SET IDENTITY_INSERT s24.companies OFF;
GO

SET IDENTITY_INSERT s24.items ON;
INSERT INTO s24.items (id, name) VALUES (1, N'Revenue');
INSERT INTO s24.items (id, name) VALUES (2, N'Expenses');
INSERT INTO s24.items (id, name) VALUES (3, N'Payroll');
INSERT INTO s24.items (id, name) VALUES (4, N'Taxes');
SET IDENTITY_INSERT s24.items OFF;
GO

SET IDENTITY_INSERT s24.cashbook ON;
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (1, '20230110', 1, 1, 1, 200000, NULL);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (2, '20230110', 1, 2, 8, NULL, 50000);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (3, '20230131', 1, 3, NULL, NULL, 85000);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (4, '20230131', 1, 4, 16, NULL, 15000);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (5, '20230131', 1, 4, 17, NULL, 15000);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (6, '20230210', 1, 1, 1, 300000, NULL);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (7, '20230210', 1, 1, 2, 100000, NULL);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (8, '20230210', 1, 2, 9, NULL, 50000);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (9, '20230210', 1, 2, 8, NULL, 100000);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (10, '20230228', 1, 3, NULL, NULL, 85000);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (11, '20230228', 1, 4, 16, NULL, 15000);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (12, '20230228', 1, 4, 17, NULL, 15000);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (13, '20230310', 1, 1, 1, 300000, NULL);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (14, '20230310', 1, 1, 2, 200000, NULL);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (15, '20230310', 1, 1, 3, 100000, NULL);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (16, '20230315', 1, 4, 15, NULL, 100000);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (17, '20230331', 1, 3, NULL, NULL, 170000);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (18, '20230331', 1, 4, 16, NULL, 30000);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (19, '20230331', 1, 4, 17, NULL, 30000);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (20, '20230331', 1, 2, 9, NULL, 50000);
INSERT INTO s24.cashbook (id, date, account_id, item_id, company_id, debit, credit) VALUES (21, '20230331', 1, 2, 8, NULL, 100000);
SET IDENTITY_INSERT s24.cashbook OFF;
GO

print 'Application installed';
