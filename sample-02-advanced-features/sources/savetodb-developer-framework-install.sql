-- =============================================
-- SaveToDB Developer Framework for Microsoft SQL Server
-- Version 10.6, December 13, 2022
--
-- Copyright 2018-2022 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON
GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Returns the escaped parameter name
-- =============================================

CREATE FUNCTION [xls].[get_escaped_parameter_name]
(
    @name nvarchar(128) = NULL
)
RETURNS nvarchar(255)
AS
BEGIN

RETURN
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(@name
    , ' ', '_x0020_'), '!', '_x0021_'), '"', '_x0022_'), '#', '_x0023_'), '$', '_x0024_')
    , '%', '_x0025_'), '&', '_x0026_'), '''', '_x0027_'), '(', '_x0028_'), ')', '_x0029_')
    , '*', '_x002A_'), '+', '_x002B_'), ',', '_x002C_'), '-', '_x002D_'), '.', '_x002E_')
    , '/', '_x002F_'), ':', '_x003A_'), ';', '_x003B_'), '<', '_x003C_'), '=', '_x003D_')
    , '>', '_x003E_'), '?', '_x003F_'), '@', '_x0040_'), '[', '_x005B_'), '\', '_x005C_')
    , ']', '_x005D_'), '^', '_x005E_'), '`', '_x0060_'), '{', '_x007B_'), '|', '_x007C_')
    , '}', '_x007D_'), '~', '_x007E_')

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Returns a column friendly name
-- =============================================

CREATE FUNCTION [xls].[get_friendly_column_name]
(
    @name nvarchar(128) = NULL
)
RETURNS nvarchar(255)
AS
BEGIN

RETURN
    CASE WHEN xls.get_escaped_parameter_name(@name) = @name
        AND NOT LOWER(@name) IN ('date', 'time', 'datetime', 'day', 'month', 'year', 'sum',
            'file_name', 'object_id', 'schema_id', 'schema_name', 'type_id', 'type_name', 'version',
            'rank', 'row_number', 'is_member', 'permissions', 'user', 'user_id', 'user_name',
            'format', 'host_id', 'host_name', 'session_id',
            'select', 'insert', 'update', 'delete', 'values', 'set', 'where', 'order', 'by', 'group',
            'next', 'procedure', 'function', 'table', 'view')
        THEN @name
        ELSE QUOTENAME(@name)
        END

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Returns the best procedure underlying table
-- =============================================

CREATE FUNCTION [xls].[get_procedure_underlying_table]
(
    @schema nvarchar(128) = NULL
    , @name nvarchar(128) = NULL
)
RETURNS nvarchar(255)
AS
BEGIN

DECLARE @result nvarchar(255)

;WITH vtu (TABLE_SCHEMA, TABLE_NAME) AS (
    SELECT
        s.name AS TABLE_SCHEMA
        , o.name AS TABLE_NAME
    FROM
        sys.sql_expression_dependencies d
        INNER JOIN sys.objects o ON o.[object_id] = d.referenced_id
        INNER JOIN sys.schemas s ON s.[schema_id] = o.[schema_id]
    WHERE
        d.referencing_id = OBJECT_ID(QUOTENAME(@schema) + '.' + QUOTENAME(@name))
), vcu (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME) AS (
    SELECT
        s.name AS TABLE_SCHEMA
        , o.name AS TABLE_NAME
        , c.name AS COLUMN_NAME
    FROM
        sys.sql_dependencies d
        INNER JOIN sys.objects o ON o.[object_id] = d.referenced_major_id
        INNER JOIN sys.schemas s ON s.[schema_id] = o.[schema_id]
        INNER JOIN sys.columns c ON c.[object_id] = d.referenced_major_id AND c.column_id = d.referenced_minor_id
    WHERE
        d.[object_id] = OBJECT_ID(QUOTENAME(@schema) + '.' + QUOTENAME(@name))
)

SELECT
    TOP 1
    @result = QUOTENAME(vtu.TABLE_SCHEMA) + '.' + QUOTENAME(vtu.TABLE_NAME)
    --vtu.TABLE_SCHEMA
    --, vtu.TABLE_NAME
    --, CASE WHEN f.TABLE_SCHEMA IS NOT NULL THEN 0 ELSE 1 END AS IS_FIRST_LEVEL
    --, p.TABLE_COLUMN_COUNT
    --, p.USED_COLUMN_COUNT
    --, p.ABSENT_COLUMN_COUNT
    --, p.PRIMARY_KEY_COUNT
    --, p.USED_PRIMARY_KEY_COUNT
FROM
    vtu
    LEFT OUTER JOIN (
        SELECT
            DISTINCT
            rtu.TABLE_SCHEMA
            , rtu.TABLE_NAME
        FROM
            vtu
            INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE ctu ON
                ctu.TABLE_SCHEMA = vtu.TABLE_SCHEMA AND ctu.TABLE_NAME = vtu.TABLE_NAME
            INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc ON
                rc.CONSTRAINT_SCHEMA = ctu.CONSTRAINT_SCHEMA AND rc.CONSTRAINT_NAME = ctu.CONSTRAINT_NAME
            INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE rtu ON
                rtu.CONSTRAINT_SCHEMA = rc.UNIQUE_CONSTRAINT_SCHEMA AND rtu.CONSTRAINT_NAME = rc.UNIQUE_CONSTRAINT_NAME
    ) f ON f.TABLE_SCHEMA = vtu.TABLE_SCHEMA AND f.TABLE_NAME = vtu.TABLE_NAME
    INNER JOIN (
        SELECT
            t.TABLE_SCHEMA
            , t.TABLE_NAME
            , COUNT(t.COLUMN_NAME) AS TABLE_COLUMN_COUNT
            , SUM(IS_SELECTED) AS USED_COLUMN_COUNT
            , COUNT(t.COLUMN_NAME) - SUM(IS_SELECTED) AS ABSENT_COLUMN_COUNT
            , SUM(IS_PRIMARY_KEY) AS PRIMARY_KEY_COUNT
            , SUM(IS_USED_PRIMARY_KEY) AS USED_PRIMARY_KEY_COUNT
        FROM
            (
                SELECT
                    vtu.TABLE_SCHEMA
                    , vtu.TABLE_NAME
                    , c.COLUMN_NAME
                    , CASE WHEN vcu.COLUMN_NAME IS NOT NULL THEN 1 ELSE 0 END AS IS_SELECTED
                    , CASE WHEN kcu.COLUMN_NAME IS NOT NULL THEN 1 ELSE 0 END AS IS_PRIMARY_KEY
                    , CASE WHEN kcu.COLUMN_NAME IS NOT NULL AND vcu.COLUMN_NAME IS NOT NULL THEN 1 ELSE 0 END AS IS_USED_PRIMARY_KEY
                FROM
                    vtu
                    INNER JOIN INFORMATION_SCHEMA.COLUMNS c ON
                        c.TABLE_SCHEMA = vtu.TABLE_SCHEMA AND c.TABLE_NAME = vtu.TABLE_NAME
                    LEFT OUTER JOIN vcu ON
                        vcu.TABLE_SCHEMA = vtu.TABLE_SCHEMA AND vcu.TABLE_NAME = vtu.TABLE_NAME
                        AND vcu.COLUMN_NAME = c.COLUMN_NAME
                    LEFT OUTER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON
                        tc.TABLE_SCHEMA = vtu.TABLE_SCHEMA AND tc.TABLE_NAME = vtu.TABLE_NAME
                        AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                    LEFT OUTER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON
                        kcu.CONSTRAINT_SCHEMA = tc.CONSTRAINT_SCHEMA AND kcu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
                        AND kcu.TABLE_SCHEMA = tc.TABLE_SCHEMA AND kcu.TABLE_NAME = tc.TABLE_NAME
                        AND kcu.COLUMN_NAME = c.COLUMN_NAME
            ) t
        GROUP BY
            t.TABLE_SCHEMA
            , t.TABLE_NAME
    ) p ON p.TABLE_SCHEMA = vtu.TABLE_SCHEMA AND p.TABLE_NAME = vtu.TABLE_NAME
WHERE
    p.PRIMARY_KEY_COUNT = p.USED_PRIMARY_KEY_COUNT
ORDER BY
    CASE WHEN p.USED_COLUMN_COUNT > 10 THEN 0 ELSE 1 END
    , CASE WHEN f.TABLE_SCHEMA IS NOT NULL THEN 1 ELSE 0 END
    , p.USED_COLUMN_COUNT DESC
    , p.ABSENT_COLUMN_COUNT
    , p.PRIMARY_KEY_COUNT

RETURN @result

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Returns the translated string
-- =============================================

CREATE FUNCTION [xls].[get_translated_string]
(
    @string nvarchar(128) = NULL
    , @data_language varchar(10) = NULL
)
RETURNS nvarchar(128)
AS
BEGIN

RETURN COALESCE((
    SELECT
        COALESCE(TRANSLATED_DESC, TRANSLATED_NAME)
    FROM
        xls.translations
    WHERE
        TABLE_SCHEMA = 'xls' AND TABLE_NAME = 'strings'
        AND COLUMN_NAME = @string AND LANGUAGE_NAME = COALESCE(@data_language, 'en')
    ), @string)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Returns the unescaped parameter name
-- =============================================

CREATE FUNCTION [xls].[get_unescaped_parameter_name]
(
    @name nvarchar(255) = NULL
)
RETURNS nvarchar(128)
AS
BEGIN

RETURN
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(@name
    , '_x0020_', ' '), '_x0021_', '!'), '_x0022_', '"'), '_x0023_', '#'), '_x0024_', '$')
    , '_x0025_', '%'), '_x0026_', '&'), '_x0027_', ''''), '_x0028_', '('), '_x0029_', ')')
    , '_x002A_', '*'), '_x002B_', '+'), '_x002C_', ','), '_x002D_', '-'), '_x002E_', '.')
    , '_x002F_', '/'), '_x003A_', ':'), '_x003B_', ';'), '_x003C_', '<'), '_x003D_', '=')
    , '_x003E_', '>'), '_x003F_', '?'), '_x0040_', '@'), '_x005B_', '['), '_x005C_', '\')
    , '_x005D_', ']'), '_x005E_', '^'), '_x0060_', '`'), '_x007B_', '{'), '_x007C_', '|')
    , '_x007D_', '}'), '_x007E_', '~')

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Returns the best view underlying table
-- =============================================

CREATE FUNCTION [xls].[get_view_underlying_table]
(
    @schema nvarchar(128) = NULL
    , @name nvarchar(128) = NULL
)
RETURNS nvarchar(255)
AS
BEGIN

DECLARE @result nvarchar(255)

;WITH vtu (TABLE_SCHEMA, TABLE_NAME) AS (
    SELECT
        vtu.TABLE_SCHEMA
        , vtu.TABLE_NAME
    FROM
        INFORMATION_SCHEMA.VIEW_TABLE_USAGE vtu
    WHERE
        vtu.VIEW_SCHEMA = @schema AND vtu.VIEW_NAME = @name
), vcu (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME) AS (
    SELECT
        vcu.TABLE_SCHEMA
        , vcu.TABLE_NAME
        , vcu.COLUMN_NAME
    FROM
        INFORMATION_SCHEMA.VIEW_COLUMN_USAGE vcu
    WHERE
        vcu.VIEW_SCHEMA = @schema AND vcu.VIEW_NAME = @name
)

SELECT
    TOP 1
    @result = QUOTENAME(vtu.TABLE_SCHEMA) + '.' + QUOTENAME(vtu.TABLE_NAME)
    --vtu.TABLE_SCHEMA
    --, vtu.TABLE_NAME
    --, CASE WHEN f.TABLE_SCHEMA IS NOT NULL THEN 0 ELSE 1 END AS IS_FIRST_LEVEL
    --, p.TABLE_COLUMN_COUNT
    --, p.USED_COLUMN_COUNT
    --, p.ABSENT_COLUMN_COUNT
    --, p.PRIMARY_KEY_COUNT
    --, p.USED_PRIMARY_KEY_COUNT
FROM
    vtu
    LEFT OUTER JOIN (
        SELECT
            DISTINCT
            rtu.TABLE_SCHEMA
            , rtu.TABLE_NAME
        FROM
            vtu
            INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE ctu ON
                ctu.TABLE_SCHEMA = vtu.TABLE_SCHEMA AND ctu.TABLE_NAME = vtu.TABLE_NAME
            INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc ON
                rc.CONSTRAINT_SCHEMA = ctu.CONSTRAINT_SCHEMA AND rc.CONSTRAINT_NAME = ctu.CONSTRAINT_NAME
            INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE rtu ON
                rtu.CONSTRAINT_SCHEMA = rc.UNIQUE_CONSTRAINT_SCHEMA AND rtu.CONSTRAINT_NAME = rc.UNIQUE_CONSTRAINT_NAME
    ) f ON f.TABLE_SCHEMA = vtu.TABLE_SCHEMA AND f.TABLE_NAME = vtu.TABLE_NAME
    INNER JOIN (
        SELECT
            t.TABLE_SCHEMA
            , t.TABLE_NAME
            , COUNT(t.COLUMN_NAME) AS TABLE_COLUMN_COUNT
            , SUM(IS_SELECTED) AS USED_COLUMN_COUNT
            , COUNT(t.COLUMN_NAME) - SUM(IS_SELECTED) AS ABSENT_COLUMN_COUNT
            , SUM(IS_PRIMARY_KEY) AS PRIMARY_KEY_COUNT
            , SUM(IS_USED_PRIMARY_KEY) AS USED_PRIMARY_KEY_COUNT
        FROM
            (
                SELECT
                    vtu.TABLE_SCHEMA
                    , vtu.TABLE_NAME
                    , c.COLUMN_NAME
                    , CASE WHEN vcu.COLUMN_NAME IS NOT NULL THEN 1 ELSE 0 END AS IS_SELECTED
                    , CASE WHEN kcu.COLUMN_NAME IS NOT NULL THEN 1 ELSE 0 END AS IS_PRIMARY_KEY
                    , CASE WHEN kcu.COLUMN_NAME IS NOT NULL AND vcu.COLUMN_NAME IS NOT NULL THEN 1 ELSE 0 END AS IS_USED_PRIMARY_KEY
                FROM
                    vtu
                    INNER JOIN INFORMATION_SCHEMA.COLUMNS c ON
                        c.TABLE_SCHEMA = vtu.TABLE_SCHEMA AND c.TABLE_NAME = vtu.TABLE_NAME
                    LEFT OUTER JOIN vcu ON
                        vcu.TABLE_SCHEMA = vtu.TABLE_SCHEMA AND vcu.TABLE_NAME = vtu.TABLE_NAME
                        AND vcu.COLUMN_NAME = c.COLUMN_NAME
                    LEFT OUTER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON
                        tc.TABLE_SCHEMA = vtu.TABLE_SCHEMA AND tc.TABLE_NAME = vtu.TABLE_NAME
                        AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                    LEFT OUTER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON
                        kcu.CONSTRAINT_SCHEMA = tc.CONSTRAINT_SCHEMA AND kcu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
                        AND kcu.TABLE_SCHEMA = tc.TABLE_SCHEMA AND kcu.TABLE_NAME = tc.TABLE_NAME
                        AND kcu.COLUMN_NAME = c.COLUMN_NAME
            ) t
        GROUP BY
            t.TABLE_SCHEMA
            , t.TABLE_NAME
    ) p ON p.TABLE_SCHEMA = vtu.TABLE_SCHEMA AND p.TABLE_NAME = vtu.TABLE_NAME
WHERE
    p.PRIMARY_KEY_COUNT = p.USED_PRIMARY_KEY_COUNT
ORDER BY
    CASE WHEN p.USED_COLUMN_COUNT > 10 THEN 0 ELSE 1 END
    , CASE WHEN f.TABLE_SCHEMA IS NOT NULL THEN 1 ELSE 0 END
    , p.USED_COLUMN_COUNT DESC
    , p.ABSENT_COLUMN_COUNT
    , p.PRIMARY_KEY_COUNT

RETURN @result

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view selects SaveToDB Framework objects
--
-- This code is used in the SaveToDB Add-In, DBEdit, ODataDB, and DBGate
-- to detect SaveToDB Framework objects
-- =============================================

CREATE VIEW [xls].[view_framework_objects]
AS

SELECT
    MAX(s.name) AS TABLE_SCHEMA
    , MAX(o.name) AS TABLE_NAME
    , 81 AS TABLE_VERSION
FROM
    sys.columns c
    INNER JOIN sys.objects o ON o.[object_id] = c.[object_id]
    INNER JOIN sys.schemas s ON s.[schema_id] = o.[schema_id]
WHERE
       c.name = 'TABLE_SCHEMA'      COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'TABLE_NAME'        COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'TABLE_TYPE'        COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'TABLE_CODE'        COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'INSERT_OBJECT'     COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'UPDATE_OBJECT'     COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'DELETE_OBJECT'     COLLATE SQL_Latin1_General_CP1_CI_AI
GROUP BY
    c.[object_id]
HAVING
    COUNT(*) = 7
    AND MAX(c.column_id) <= 8
UNION ALL
SELECT
    MAX(s.name) AS TABLE_SCHEMA
    , MAX(o.name) AS TABLE_NAME
    , 51 AS TABLE_VERSION
FROM
    sys.columns c
    INNER JOIN sys.objects o ON o.[object_id] = c.[object_id]
    INNER JOIN sys.schemas s ON s.[schema_id] = o.[schema_id]
WHERE
       c.name = 'TABLE_SCHEMA'      COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'TABLE_NAME'        COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'TABLE_TYPE'        COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'TABLE_CODE'        COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'INSERT_PROCEDURE'  COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'UPDATE_PROCEDURE'  COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'DELETE_PROCEDURE'  COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'PROCEDURE_TYPE'    COLLATE SQL_Latin1_General_CP1_CI_AI
GROUP BY
    c.[object_id]
HAVING
    COUNT(*) IN (8)
    AND MAX(c.column_id) <= 9
UNION ALL
SELECT
    MAX(s.name) AS TABLE_SCHEMA
    , MAX(o.name) AS TABLE_NAME
    , 52 AS TABLE_VERSION
FROM
    sys.columns c
    INNER JOIN sys.objects o ON o.[object_id] = c.[object_id]
    INNER JOIN sys.schemas s ON s.[schema_id] = o.[schema_id]
WHERE
       c.name = 'TABLE_SCHEMA'      COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'TABLE_NAME'        COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'COLUMN_NAME'       COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'EVENT_NAME'        COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'HANDLER_SCHEMA'    COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'HANDLER_NAME'      COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'HANDLER_TYPE'      COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'HANDLER_CODE'      COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'TARGET_WORKSHEET'  COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'MENU_ORDER'        COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'EDIT_PARAMETERS'   COLLATE SQL_Latin1_General_CP1_CI_AI
GROUP BY
    c.[object_id]
HAVING
    COUNT(*) IN (11)
    AND MAX(c.column_id) <= 12
UNION ALL
SELECT
    MAX(s.name) AS TABLE_SCHEMA
    , MAX(o.name) AS TABLE_NAME
    , 53 AS TABLE_VERSION
FROM
    sys.columns c
    INNER JOIN sys.objects o ON o.[object_id] = c.[object_id]
    INNER JOIN sys.schemas s ON s.[schema_id] = o.[schema_id]
WHERE
    c.name = 'TABLE_SCHEMA'         COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'TABLE_NAME'        COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'PARAMETER_NAME'    COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'SELECT_SCHEMA'     COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'SELECT_NAME'       COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'SELECT_TYPE'       COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'SELECT_CODE'       COLLATE SQL_Latin1_General_CP1_CI_AI
GROUP BY
    c.[object_id]
HAVING
    COUNT(*) IN (7)
    AND MAX(c.column_id) <= 8
UNION ALL
SELECT
    MAX(s.name) AS TABLE_SCHEMA
    , MAX(o.name) AS TABLE_NAME
    , CASE WHEN COUNT(*) = 7 THEN 85 WHEN MIN(c.name) = 'COLUMN_NAME' THEN 25 ELSE 24 END AS TABLE_VERSION
FROM
    sys.columns c
    INNER JOIN sys.objects o ON o.[object_id] = c.[object_id]
    INNER JOIN sys.schemas s ON s.[schema_id] = o.[schema_id]
WHERE
       c.name = 'TABLE_SCHEMA'          COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'TABLE_NAME'            COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'COLUMN_NAME'           COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'LANGUAGE_NAME'         COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'TRANSLATED_NAME'       COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'TRANSLATED_DESC'       COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'TRANSLATED_COMMENT'    COLLATE SQL_Latin1_General_CP1_CI_AI
GROUP BY
    c.[object_id]
HAVING
    COUNT(*) = 7 AND MAX(c.column_id) <= 8
    OR COUNT(*) = 6 AND MAX(c.column_id) <= 7
UNION ALL
SELECT
    MAX(s.name) AS TABLE_SCHEMA
    , MAX(o.name) AS TABLE_NAME
    , 26 AS TABLE_VERSION
FROM
    sys.columns c
    INNER JOIN sys.objects o ON o.[object_id] = c.[object_id]
    INNER JOIN sys.schemas s ON s.[schema_id] = o.[schema_id]
WHERE
       c.name = 'TABLE_SCHEMA'              COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'TABLE_NAME'                COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'TABLE_EXCEL_FORMAT_XML'    COLLATE SQL_Latin1_General_CP1_CI_AI
GROUP BY
    c.[object_id]
HAVING
    COUNT(*) = 3
    AND MAX(c.column_id) <= 4
UNION ALL
SELECT
    MAX(s.name) AS TABLE_SCHEMA
    , MAX(o.name) AS TABLE_NAME
    , 27 AS TABLE_VERSION
FROM
    sys.parameters c
    INNER JOIN sys.objects o ON o.[object_id] = c.[object_id]
    INNER JOIN sys.schemas s ON s.[schema_id] = o.[schema_id]
WHERE
       c.name = '@SCHEMA'           COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = '@NAME'             COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = '@EXCELFORMATXML'   COLLATE SQL_Latin1_General_CP1_CI_AI
GROUP BY
    c.[object_id]
HAVING
    COUNT(*) = 3
    AND MAX(c.parameter_id) <= 3
UNION ALL
SELECT
    MAX(s.name) AS TABLE_SCHEMA
    , MAX(o.name) AS TABLE_NAME
    , 88 AS TABLE_VERSION
FROM
    sys.columns c
    INNER JOIN sys.objects o ON o.[object_id] = c.[object_id]
    INNER JOIN sys.schemas s ON s.[schema_id] = o.[schema_id]
WHERE
       c.name = 'NAME'          COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'TEMPLATE'      COLLATE SQL_Latin1_General_CP1_CI_AI
    OR c.name = 'DEFINITION'    COLLATE SQL_Latin1_General_CP1_CI_AI
GROUP BY
    c.[object_id]
HAVING
    COUNT(*) = 3
    AND MAX(c.column_id) <= 4


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view selects translations of all objects
-- =============================================

CREATE VIEW [xls].[view_all_translations]
AS

WITH cte AS (SELECT TABLE_SCHEMA, TABLE_NAME FROM xls.view_framework_objects)

SELECT
    1 AS SECTION
    , ROW_NUMBER() OVER (ORDER BY t.TABLE_TYPE, t.TABLE_SCHEMA, t.TABLE_NAME, g.LANGUAGE_NAME) AS SORT_ORDER
    , 'object' AS TRANSLATION_TYPE
    , CASE WHEN t.TABLE_TYPE = 'BASE TABLE' THEN 'table' ELSE LOWER(t.TABLE_TYPE) END AS TABLE_TYPE
    , t.TABLE_SCHEMA
    , t.TABLE_NAME
    , CAST(NULL AS nvarchar(128)) AS COLUMN_NAME
    , g.LANGUAGE_NAME
    , tr.TRANSLATED_NAME
    , tr.TRANSLATED_DESC
FROM
    INFORMATION_SCHEMA.TABLES t
    LEFT OUTER JOIN cte f ON f.TABLE_SCHEMA = t.TABLE_SCHEMA AND f.TABLE_NAME = t.TABLE_NAME

    CROSS JOIN (SELECT LANGUAGE_NAME FROM xls.translations UNION SELECT 'en' AS LANGUAGE_NAME) g

    LEFT OUTER JOIN xls.translations tr
        ON tr.TABLE_SCHEMA = t.TABLE_SCHEMA AND tr.TABLE_NAME = t.TABLE_NAME
            AND tr.COLUMN_NAME IS NULL AND tr.LANGUAGE_NAME = g.LANGUAGE_NAME
WHERE
    NOT t.TABLE_NAME IN ('sysdiagrams')
    AND NOT t.TABLE_SCHEMA IN ('sys', 'dbo01', 'etl01', 'xls01', 'savetodb_dev', 'savetodb_xls', 'savetodb_etl', 'SAVETODB_DEV', 'SAVETODB_XLS', 'SAVETODB_ETL', 'xls', 'doc', 'logs')
    AND f.TABLE_NAME IS NULL

UNION ALL
SELECT
    2 AS SECTION
    , ROW_NUMBER() OVER (ORDER BY p.ROUTINE_TYPE, p.SPECIFIC_SCHEMA, p.SPECIFIC_NAME, g.LANGUAGE_NAME) AS SORT_ORDER
    , 'object' AS TRANSLATION_TYPE
    , LOWER(p.ROUTINE_TYPE) AS TABLE_TYPE
    , p.SPECIFIC_SCHEMA AS TABLE_SCHEMA
    , p.SPECIFIC_NAME AS TABLE_NAME
    , CAST(NULL AS nvarchar(128)) AS COLUMN_NAME
    , g.LANGUAGE_NAME
    , tr.TRANSLATED_NAME
    , tr.TRANSLATED_DESC
FROM
    INFORMATION_SCHEMA.ROUTINES p
    LEFT OUTER JOIN cte f ON f.TABLE_SCHEMA = p.SPECIFIC_SCHEMA AND f.TABLE_NAME = p.SPECIFIC_NAME

    CROSS JOIN (SELECT LANGUAGE_NAME FROM xls.translations UNION SELECT 'en' AS LANGUAGE_NAME) g

    LEFT OUTER JOIN xls.translations tr
        ON tr.TABLE_SCHEMA = p.SPECIFIC_SCHEMA AND tr.TABLE_NAME = p.SPECIFIC_NAME
            AND tr.COLUMN_NAME IS NULL AND tr.LANGUAGE_NAME = g.LANGUAGE_NAME
WHERE
    NOT p.SPECIFIC_NAME LIKE 'sp_%'
    AND NOT p.SPECIFIC_NAME LIKE 'fn_%'
    AND p.ROUTINE_TYPE = 'PROCEDURE'
    AND NOT p.SPECIFIC_SCHEMA IN ('sys', 'dbo01', 'etl01', 'xls01', 'savetodb_dev', 'savetodb_xls', 'savetodb_etl', 'SAVETODB_DEV', 'SAVETODB_XLS', 'SAVETODB_ETL', 'xls', 'doc', 'logs')
    AND NOT p.SPECIFIC_NAME LIKE '%_insert'
    AND NOT p.SPECIFIC_NAME LIKE '%_update'
    AND NOT p.SPECIFIC_NAME LIKE '%_delete'
    AND NOT p.SPECIFIC_NAME LIKE '%_change'
    AND NOT p.SPECIFIC_NAME LIKE '%_merge'
    AND NOT p.SPECIFIC_NAME LIKE 'usp_import_%'
    AND NOT p.SPECIFIC_NAME LIKE 'usp_export_%'
    AND NOT p.SPECIFIC_NAME LIKE 'xl_parameter_values_%'
    AND NOT p.SPECIFIC_NAME LIKE 'xl_validation_list_%'
    AND f.TABLE_NAME IS NULL

UNION ALL
SELECT
    3 AS SECTION
    , ROW_NUMBER() OVER (ORDER BY c.TABLE_SCHEMA, g.LANGUAGE_NAME) AS SORT_ORDER
    , 'schema' AS TRANSLATION_TYPE
    , 'column' AS TABLE_TYPE
    , c.TABLE_SCHEMA
    , CAST(NULL AS nvarchar(128)) AS TABLE_NAME
    , c.COLUMN_NAME
    , g.LANGUAGE_NAME
    , tr.TRANSLATED_NAME
    , tr.TRANSLATED_DESC
FROM
    (
        SELECT
            c.TABLE_SCHEMA
            , c.COLUMN_NAME
        FROM
            INFORMATION_SCHEMA.COLUMNS c
            LEFT OUTER JOIN cte f ON f.TABLE_SCHEMA = c.TABLE_SCHEMA AND f.TABLE_NAME = c.TABLE_NAME
        WHERE
            NOT c.TABLE_NAME IN ('sysdiagrams')
            AND NOT c.TABLE_SCHEMA IN ('sys', 'dbo01', 'etl01', 'xls01', 'savetodb_dev', 'savetodb_xls', 'savetodb_etl', 'SAVETODB_DEV', 'SAVETODB_XLS', 'SAVETODB_ETL', 'xls', 'doc', 'logs')
            AND f.TABLE_NAME IS NULL
        UNION
        SELECT
            p.TABLE_SCHEMA
            , p.COLUMN_NAME
        FROM
            INFORMATION_SCHEMA.ROUTINE_COLUMNS p
            LEFT OUTER JOIN cte f ON f.TABLE_SCHEMA = p.TABLE_SCHEMA AND f.TABLE_NAME = p.TABLE_NAME
        WHERE
            NOT p.TABLE_NAME LIKE 'fn_%'
            AND NOT p.TABLE_SCHEMA IN ('sys', 'dbo01', 'etl01', 'xls01', 'savetodb_dev', 'savetodb_xls', 'savetodb_etl', 'SAVETODB_DEV', 'SAVETODB_XLS', 'SAVETODB_ETL', 'xls', 'doc', 'logs')
            AND f.TABLE_NAME IS NULL
        UNION
        SELECT
            p.SPECIFIC_SCHEMA AS TABLE_SCHEMA
            , SUBSTRING(p.PARAMETER_NAME, 2, 127) AS COLUMN_NAME
        FROM
            INFORMATION_SCHEMA.PARAMETERS p
            INNER JOIN INFORMATION_SCHEMA.ROUTINES r ON r.SPECIFIC_SCHEMA = p.SPECIFIC_SCHEMA AND r.SPECIFIC_NAME = p.SPECIFIC_NAME
            LEFT OUTER JOIN cte f ON f.TABLE_SCHEMA = p.SPECIFIC_SCHEMA AND f.TABLE_NAME = p.SPECIFIC_NAME
        WHERE
            NOT p.SPECIFIC_NAME LIKE 'sp_%'
            AND NOT p.SPECIFIC_NAME LIKE 'fn_%'
            AND r.ROUTINE_TYPE = 'PROCEDURE'
            AND p.ORDINAL_POSITION > 0
            AND NOT p.SPECIFIC_SCHEMA IN ('sys', 'dbo01', 'etl01', 'xls01', 'savetodb_dev', 'savetodb_xls', 'savetodb_etl', 'SAVETODB_DEV', 'SAVETODB_XLS', 'SAVETODB_ETL', 'xls', 'doc', 'logs')
            AND NOT p.SPECIFIC_NAME LIKE '%_insert'
            AND NOT p.SPECIFIC_NAME LIKE '%_update'
            AND NOT p.SPECIFIC_NAME LIKE '%_delete'
            AND NOT p.SPECIFIC_NAME LIKE '%_change'
            AND NOT p.SPECIFIC_NAME LIKE '%_merge'
            AND NOT p.SPECIFIC_NAME LIKE 'usp_import_%'
            AND NOT p.SPECIFIC_NAME LIKE 'usp_export_%'
            AND NOT p.SPECIFIC_NAME LIKE 'xl_parameter_values_%'
            AND NOT p.SPECIFIC_NAME LIKE 'xl_validation_list_%'
            AND NOT p.PARAMETER_NAME IN ('@data_language')
            AND f.TABLE_NAME IS NULL
    ) c
    CROSS JOIN (SELECT LANGUAGE_NAME FROM xls.translations UNION SELECT 'en' AS LANGUAGE_NAME) g

    LEFT OUTER JOIN xls.translations tr
        ON tr.TABLE_SCHEMA = c.TABLE_SCHEMA AND tr.TABLE_NAME IS NULL
            AND tr.COLUMN_NAME = c.COLUMN_NAME AND tr.LANGUAGE_NAME = g.LANGUAGE_NAME

UNION ALL
SELECT
    4 AS SECTION
    , ROW_NUMBER() OVER (ORDER BY c.TABLE_SCHEMA, c.TABLE_NAME, c.ORDINAL_POSITION, g.LANGUAGE_NAME) AS SORT_ORDER
    , 'column' AS TRANSLATION_TYPE
    , CASE WHEN t.TABLE_TYPE = 'BASE TABLE' THEN 'table' ELSE LOWER(t.TABLE_TYPE) END AS TABLE_TYPE
    , c.TABLE_SCHEMA
    , c.TABLE_NAME
    , c.COLUMN_NAME
    , g.LANGUAGE_NAME
    , tr.TRANSLATED_NAME
    , tr.TRANSLATED_DESC
FROM
    INFORMATION_SCHEMA.COLUMNS c
    INNER JOIN INFORMATION_SCHEMA.TABLES t ON t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
    LEFT OUTER JOIN cte f ON f.TABLE_SCHEMA = t.TABLE_SCHEMA AND f.TABLE_NAME = t.TABLE_NAME

    CROSS JOIN (SELECT LANGUAGE_NAME FROM xls.translations UNION SELECT 'en' AS LANGUAGE_NAME) g

    LEFT OUTER JOIN xls.translations tr
        ON tr.TABLE_SCHEMA = c.TABLE_SCHEMA AND tr.TABLE_NAME = c.TABLE_NAME
            AND tr.COLUMN_NAME = c.COLUMN_NAME AND tr.LANGUAGE_NAME = g.LANGUAGE_NAME

WHERE
    NOT c.TABLE_NAME IN ('sysdiagrams')
    AND NOT c.TABLE_SCHEMA IN ('sys', 'dbo01', 'etl01', 'xls01', 'savetodb_dev', 'savetodb_xls', 'savetodb_etl', 'SAVETODB_DEV', 'SAVETODB_XLS', 'SAVETODB_ETL', 'xls', 'doc', 'logs')
    AND f.TABLE_NAME IS NULL

UNION ALL
SELECT
    5 AS SECTION
    , ROW_NUMBER() OVER (ORDER BY p.TABLE_SCHEMA, p.TABLE_NAME, p.ORDINAL_POSITION, g.LANGUAGE_NAME) AS SORT_ORDER
    , 'column' AS TRANSLATION_TYPE
    , 'function' AS TABLE_TYPE
    , p.TABLE_SCHEMA
    , p.TABLE_NAME
    , p.COLUMN_NAME
    , g.LANGUAGE_NAME
    , tr.TRANSLATED_NAME
    , tr.TRANSLATED_DESC
FROM
    INFORMATION_SCHEMA.ROUTINE_COLUMNS p
    LEFT OUTER JOIN cte f ON f.TABLE_SCHEMA = p.TABLE_SCHEMA AND f.TABLE_NAME = p.TABLE_NAME

    CROSS JOIN (SELECT LANGUAGE_NAME FROM xls.translations UNION SELECT 'en' AS LANGUAGE_NAME) g

    LEFT OUTER JOIN xls.translations tr
        ON tr.TABLE_SCHEMA = p.TABLE_SCHEMA AND tr.TABLE_NAME = p.TABLE_NAME AND tr.COLUMN_NAME = p.COLUMN_NAME AND tr.LANGUAGE_NAME = g.LANGUAGE_NAME
WHERE
    NOT p.TABLE_NAME LIKE 'fn_%'
    AND NOT p.TABLE_SCHEMA IN ('sys', 'dbo01', 'etl01', 'xls01', 'savetodb_dev', 'savetodb_xls', 'savetodb_etl', 'SAVETODB_DEV', 'SAVETODB_XLS', 'SAVETODB_ETL', 'xls', 'doc', 'logs')
    AND f.TABLE_NAME IS NULL

UNION ALL
SELECT
    6 AS SECTION
    , ROW_NUMBER() OVER (ORDER BY p.SPECIFIC_SCHEMA, p.SPECIFIC_NAME, p.ORDINAL_POSITION, g.LANGUAGE_NAME) AS SORT_ORDER
    , 'parameter' AS TRANSLATION_TYPE
    , LOWER(r.ROUTINE_TYPE) AS TABLE_TYPE
    , p.SPECIFIC_SCHEMA AS TABLE_SCHEMA
    , p.SPECIFIC_NAME AS TABLE_NAME
    , SUBSTRING(p.PARAMETER_NAME, 2, 127) AS COLUMN_NAME
    , g.LANGUAGE_NAME
    , tr.TRANSLATED_NAME
    , tr.TRANSLATED_DESC
FROM
    INFORMATION_SCHEMA.PARAMETERS p
    INNER JOIN INFORMATION_SCHEMA.ROUTINES r ON r.SPECIFIC_SCHEMA = p.SPECIFIC_SCHEMA AND r.SPECIFIC_NAME = p.SPECIFIC_NAME
    LEFT OUTER JOIN cte f ON f.TABLE_SCHEMA = p.SPECIFIC_SCHEMA AND f.TABLE_NAME = p.SPECIFIC_NAME

    CROSS JOIN (SELECT LANGUAGE_NAME FROM xls.translations UNION SELECT 'en' AS LANGUAGE_NAME) g

    LEFT OUTER JOIN xls.translations tr
        ON tr.TABLE_SCHEMA = p.SPECIFIC_SCHEMA AND tr.TABLE_NAME = p.SPECIFIC_NAME
            AND tr.COLUMN_NAME = p.PARAMETER_NAME AND tr.LANGUAGE_NAME = g.LANGUAGE_NAME
WHERE
    NOT p.SPECIFIC_NAME LIKE 'sp_%'
    AND NOT p.SPECIFIC_NAME LIKE 'fn_%'
    AND r.ROUTINE_TYPE = 'PROCEDURE'
    AND p.ORDINAL_POSITION > 0
    AND NOT p.SPECIFIC_SCHEMA IN ('sys', 'dbo01', 'etl01', 'xls01', 'savetodb_dev', 'savetodb_xls', 'savetodb_etl', 'SAVETODB_DEV', 'SAVETODB_XLS', 'SAVETODB_ETL', 'xls', 'doc', 'logs')
    AND NOT p.SPECIFIC_NAME LIKE '%_insert'
    AND NOT p.SPECIFIC_NAME LIKE '%_update'
    AND NOT p.SPECIFIC_NAME LIKE '%_delete'
    AND NOT p.SPECIFIC_NAME LIKE '%_change'
    AND NOT p.SPECIFIC_NAME LIKE '%_merge'
    AND NOT p.SPECIFIC_NAME LIKE 'usp_import_%'
    AND NOT p.SPECIFIC_NAME LIKE 'usp_export_%'
    AND NOT p.SPECIFIC_NAME LIKE 'xl_parameter_values_%'
    AND NOT p.SPECIFIC_NAME LIKE 'xl_validation_list_%'
    AND NOT p.PARAMETER_NAME IN ('@data_language')
    AND f.TABLE_NAME IS NULL


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Generated event handlers for developer actions
--
-- 9.1 MySqlStyle
-- =============================================

CREATE VIEW [xls].[view_developer_handlers]
AS

SELECT
    t.TABLE_SCHEMA
    , t.TABLE_NAME
    , CAST(NULL AS nvarchar(128)) AS COLUMN_NAME
    , 'Actions' AS EVENT_NAME
    , v.handler_schema AS HANDLER_SCHEMA
    , v.handler_name AS HANDLER_NAME
    , v.handler_type AS HANDLER_TYPE
    , CAST(v.handler_code AS nvarchar(max)) AS HANDLER_CODE
    , CAST(NULL AS nvarchar(128)) AS TARGET_WORKSHEET
    , v.menu_order AS MENU_ORDER
    , CAST(1 AS bit) AS EDIT_PARAMETERS
FROM
    INFORMATION_SCHEMA.TABLES t
    CROSS JOIN (VALUES
        (200, 'xls', 'MenuSeparator200', 'MENUSEPARATOR', NULL),
        (201, 'xls', 'Generate Select Procedure', 'CODE', 'EXEC xls.xl_actions_generate_procedures NULL, @TableName, @SelectObjectSchema, @SelectObjectName, 1, 0, 0, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (202, 'xls', 'Generate Select and Edit Procedures', 'CODE', 'EXEC xls.xl_actions_generate_procedures NULL, @TableName, @SelectObjectSchema, @SelectObjectName, 1, 1, 0, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (203, 'xls', 'Generate Select and Change Procedures', 'CODE', 'EXEC xls.xl_actions_generate_procedures NULL, @TableName, @SelectObjectSchema, @SelectObjectName, 1, 0, 1, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (204, 'xls', 'MenuSeparator204', 'MENUSEPARATOR', NULL),
        (205, 'xls', 'Generate View', 'CODE', 'EXEC xls.xl_actions_generate_procedures NULL, @TableName, @SelectObjectSchema, @SelectObjectName, 1, 0, 0, 1, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (206, 'xls', 'Generate View and Edit Procedures', 'CODE', 'EXEC xls.xl_actions_generate_procedures NULL, @TableName, @SelectObjectSchema, @SelectObjectName, 1, 1, 0, 1, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (207, 'xls', 'Generate View and Change Handler', 'CODE', 'EXEC xls.xl_actions_generate_procedures NULL, @TableName, @SelectObjectSchema, @SelectObjectName, 1, 0, 1, 1, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (208, 'xls', 'MenuSeparator208', 'MENUSEPARATOR', NULL),
        (209, 'xls', 'Generate Edit Procedures', 'CODE', 'EXEC xls.xl_actions_generate_procedures NULL, @TableName, @SelectObjectSchema, @SelectObjectName, 0, 1, 0, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (210, 'xls', 'Generate Change Handler', 'CODE', 'EXEC xls.xl_actions_generate_procedures NULL, @TableName, @SelectObjectSchema, @SelectObjectName, 0, 0, 1, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (211, 'xls', 'MenuSeparator211', 'MENUSEPARATOR', NULL),
        (212, 'xls', 'Generate Validation List View', 'CODE', 'EXEC xls.xl_actions_generate_handlers NULL, @TableName, @TargetObjectSchema, @TargetObjectName, 1, 1, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (213, 'xls', 'Generate Validation List Procedure', 'CODE', 'EXEC xls.xl_actions_generate_handlers NULL, @TableName, @TargetObjectSchema, @TargetObjectName, 1, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (214, 'xls', 'Generate Parameter Values', 'CODE', 'EXEC xls.xl_actions_generate_handlers NULL, @TableName, @TargetObjectSchema, @TargetObjectName, 2, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (215, 'xls', 'Generate Parameter Values with Empty', 'CODE', 'EXEC xls.xl_actions_generate_handlers NULL, @TableName, @TargetObjectSchema, @TargetObjectName, 3, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (216, 'xls', 'MenuSeparator216', 'MENUSEPARATOR', NULL),
        (217, 'xls', 'Generate Actions Handler', 'CODE', 'EXEC xls.xl_actions_generate_handlers NULL, @TableName, @TargetObjectSchema, @TargetObjectName, 7, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (218, 'xls', 'Generate ContextMenu Handler', 'CODE', 'EXEC xls.xl_actions_generate_handlers NULL, @TableName, @TargetObjectSchema, @TargetObjectName, 4, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (219, 'xls', 'Generate DoubleClick Handler', 'CODE', 'EXEC xls.xl_actions_generate_handlers NULL, @TableName, @TargetObjectSchema, @TargetObjectName, 5, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (220, 'xls', 'Generate SelectionChange Handler', 'CODE', 'EXEC xls.xl_actions_generate_handlers NULL, @TableName, @TargetObjectSchema, @TargetObjectName, 6, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle')
        ) v(menu_order, handler_schema, handler_name, handler_type, handler_code)
WHERE
    (t.TABLE_TYPE = 'BASE TABLE'
    OR t.TABLE_TYPE = 'VIEW' AND v.menu_order IN (200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 216, 217, 218, 219, 220))
    AND NOT t.TABLE_SCHEMA IN ('xls', 'dbo01', 'dbo02', 'savetodb_dev', 'logs', 'doc')
    AND NOT t.TABLE_NAME LIKE 'sys%'
    AND NOT t.TABLE_NAME LIKE 'xl_%'
    AND NOT t.TABLE_NAME LIKE 'viewQueryList%'
    AND NOT t.TABLE_NAME LIKE 'viewParameterValues%'
    AND NOT t.TABLE_NAME LIKE 'viewValidationList%'
    AND NOT t.TABLE_NAME LIKE 'view_query_list%'
    AND NOT t.TABLE_NAME LIKE 'view_xl_%'
    AND EXISTS(SELECT TOP 1 r.ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES r WHERE
        r.ROUTINE_SCHEMA = 'xls' AND r.ROUTINE_NAME = 'xl_actions_generate_procedures' AND r.ROUTINE_TYPE = 'PROCEDURE')

UNION ALL
SELECT
    t.ROUTINE_SCHEMA AS TABLE_SCHEMA
    , t.ROUTINE_NAME AS TABLE_NAME
    , CAST(NULL AS nvarchar(128)) AS COLUMN_NAME
    , 'Actions' AS EVENT_NAME
    , v.handler_schema AS HANDLER_SCHEMA
    , v.handler_name AS HANDLER_NAME
    , v.handler_type AS HANDLER_TYPE
    , v.handler_code AS HANDLER_CODE
    , CAST(NULL AS nvarchar(128)) AS TARGET_WORKSHEET
    , v.menu_order AS MENU_ORDER
    , CAST(1 AS bit) AS EDIT_PARAMETERS
FROM
    INFORMATION_SCHEMA.ROUTINES t
    CROSS JOIN (VALUES
        (208, 'xls', 'MenuSeparator208', 'MENUSEPARATOR', NULL),
        (209, 'xls', 'Generate Edit Procedures', 'CODE', 'EXEC xls.xl_actions_generate_procedures NULL, @TableName, @SelectObjectSchema, @SelectObjectName, 0, 1, 0, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (210, 'xls', 'Generate Change Handler', 'CODE', 'EXEC xls.xl_actions_generate_procedures NULL, @TableName, @SelectObjectSchema, @SelectObjectName, 0, 0, 1, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (216, 'xls', 'MenuSeparator216', 'MENUSEPARATOR', NULL),
        (217, 'xls', 'Generate Actions Handler', 'CODE', 'EXEC xls.xl_actions_generate_handlers NULL, @TableName, @TargetObjectSchema, @TargetObjectName, 7, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (218, 'xls', 'Generate ContextMenu Handler', 'CODE', 'EXEC xls.xl_actions_generate_handlers NULL, @TableName, @TargetObjectSchema, @TargetObjectName, 4, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (219, 'xls', 'Generate DoubleClick Handler', 'CODE', 'EXEC xls.xl_actions_generate_handlers NULL, @TableName, @TargetObjectSchema, @TargetObjectName, 5, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle'),
        (220, 'xls', 'Generate SelectionChange Handler', 'CODE', 'EXEC xls.xl_actions_generate_handlers NULL, @TableName, @TargetObjectSchema, @TargetObjectName, 6, 0, @ExecuteScript, @RecreateProceduresIfExist, @DataLanguage, NULL, NULL, @MySqlStyle')
        ) v(menu_order, handler_schema, handler_name, handler_type, handler_code)
WHERE
    t.ROUTINE_TYPE = 'PROCEDURE'
    AND NOT t.ROUTINE_SCHEMA IN ('xls', 'dbo01', 'dbo02', 'savetodb_dev', 'logs', 'doc')
    AND NOT t.ROUTINE_NAME LIKE 'sp%'
    AND NOT t.ROUTINE_NAME LIKE 'xl%'
    AND NOT t.ROUTINE_NAME LIKE '%_insert'
    AND NOT t.ROUTINE_NAME LIKE '%_update'
    AND NOT t.ROUTINE_NAME LIKE '%_delete'
    AND NOT t.ROUTINE_NAME LIKE '%_merge'
    AND NOT t.ROUTINE_NAME LIKE '%_change'
    AND NOT t.ROUTINE_NAME LIKE 'uspExcelEvent%'
    AND NOT t.ROUTINE_NAME LIKE 'uspParameterValues%'
    AND NOT t.ROUTINE_NAME LIKE 'uspValidationList%'
    AND NOT t.ROUTINE_NAME LIKE 'uspAdd%'
    AND NOT t.ROUTINE_NAME LIKE 'uspSet%'
    AND NOT t.ROUTINE_NAME LIKE 'uspInsert%'
    AND NOT t.ROUTINE_NAME LIKE 'uspUpdate%'
    AND NOT t.ROUTINE_NAME LIKE 'uspDelete%'
    AND NOT t.ROUTINE_NAME LIKE 'Add%'
    AND NOT t.ROUTINE_NAME LIKE 'Set%'
    AND NOT t.ROUTINE_NAME LIKE 'Insert%'
    AND NOT t.ROUTINE_NAME LIKE 'Update%'
    AND NOT t.ROUTINE_NAME LIKE 'Delete%'
    AND NOT t.ROUTINE_NAME LIKE 'usp_xl_%'
    AND NOT t.ROUTINE_NAME LIKE 'usp_import_%'
    AND NOT t.ROUTINE_NAME LIKE 'usp_export_%'
    AND EXISTS(SELECT TOP 1 r.ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES r WHERE
        r.ROUTINE_SCHEMA = 'xls' AND r.ROUTINE_NAME = 'xl_actions_generate_procedures' AND r.ROUTINE_TYPE = 'PROCEDURE')


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view selects foreign key columns
-- =============================================

CREATE VIEW [xls].[view_foreign_keys]
AS

SELECT
    ROW_NUMBER() OVER (ORDER BY s.name, o.name, c.column_id) AS SORT_ORDER
    , s.name AS [SCHEMA]
    , o.name AS [TABLE]
    , c.name AS [COLUMN]
    , c.column_id AS POSITION
    , r.REFERENTIAL_SCHEMA
    , r.REFERENTIAL_TABLE
    , r.REFERENTIAL_COLUMN
    , r.[CONSTRAINT]
    , r.ON_UPDATE
    , r.ON_DELETE
FROM
    sys.columns c
    INNER JOIN sys.objects o ON o.[object_id] = c.[object_id]
    INNER JOIN sys.schemas s ON s.[schema_id] = o.[schema_id]
    LEFT OUTER JOIN (
        SELECT
            o.[object_id]
            , c.column_id
            , rs.name AS REFERENTIAL_SCHEMA
            , ro.name AS REFERENTIAL_TABLE
            , rc.name AS REFERENTIAL_COLUMN
            , fk.name AS [CONSTRAINT]
            , CASE
                WHEN fk.update_referential_action = 0 THEN NULL
                WHEN fk.update_referential_action = 1 THEN 'CASCADE'
                WHEN fk.update_referential_action = 2 THEN 'SET NULL'
                WHEN fk.update_referential_action = 3 THEN 'SET DEFAULT'
                ELSE fk.update_referential_action_desc
                END ON_UPDATE
            , CASE
                WHEN fk.delete_referential_action = 0 THEN NULL
                WHEN fk.delete_referential_action = 1 THEN 'CASCADE'
                WHEN fk.delete_referential_action = 2 THEN 'SET NULL'
                WHEN fk.delete_referential_action = 3 THEN 'SET DEFAULT'
                ELSE fk.delete_referential_action_desc
                END AS ON_DELETE
        FROM
            sys.foreign_keys fk
            INNER JOIN sys.objects o ON o.[object_id] = fk.parent_object_id
            INNER JOIN sys.objects ro ON ro.[object_id] = fk.referenced_object_id
            INNER JOIN sys.schemas rs ON rs.[schema_id] = ro.[schema_id]
            INNER JOIN sys.foreign_key_columns k ON k.constraint_object_id = fk.[object_id]
            INNER JOIN sys.columns c ON c.[object_id] = k.parent_object_id AND c.column_id = k.parent_column_id
            INNER JOIN sys.columns rc ON rc.[object_id] = k.referenced_object_id AND rc.column_id = k.referenced_column_id
    ) r ON r.[object_id] = c.[object_id] AND r.column_id = c.column_id
WHERE
    NOT s.name IN ('dbo01', 'etl01', 'xls01', 'savetodb_dev', 'savetodb_xls', 'savetodb_etl', 'SAVETODB_DEV', 'SAVETODB_XLS', 'SAVETODB_ETL', 'xls', 'doc', 'logs')
    AND NOT (s.name = 'dbo' AND (o.name LIKE 'sys%'))
    AND o.[type] = 'U'


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view selects primary key columns
-- =============================================

CREATE VIEW [xls].[view_primary_keys]
AS

SELECT
    ROW_NUMBER() OVER (ORDER BY s.name, o.name, c.column_id) AS SORT_ORDER
    , s.name AS [SCHEMA]
    , o.name AS [TABLE]
    , c.name AS [COLUMN]
    , c.column_id AS POSITION
    , p.[CONSTRAINT]
    , p.INDEX_POSITION
    , p.IS_DESCENDING
    -- , p.IS_INCLUDED
FROM
    sys.columns c
    INNER JOIN sys.objects o ON o.[object_id] = c.[object_id]
    INNER JOIN sys.schemas s ON s.[schema_id] = o.[schema_id]
    LEFT OUTER JOIN (
        SELECT
            c.[object_id]
            , c.column_id
            , i.name AS [CONSTRAINT]
            , ic.index_column_id AS INDEX_POSITION
            , CASE WHEN ic.is_descending_key = 1 THEN ic.is_descending_key ELSE NULL END AS IS_DESCENDING
            , CASE WHEN ic.is_included_column = 1 THEN ic.is_included_column ELSE NULL END AS IS_INCLUDED
        FROM
            sys.columns c
            INNER JOIN sys.indexes i ON i.[object_id] = c.[object_id] AND i.is_unique = 1 AND i.is_primary_key = 1
            INNER JOIN sys.index_columns ic ON ic.[object_id] = c.[object_id]
                AND ic.index_id = i.index_id AND ic.column_id = c.column_id
    ) p ON p.[object_id] = c.[object_id] AND p.column_id = c.column_id
WHERE
    NOT s.name IN ('dbo01', 'etl01', 'xls01', 'savetodb_dev', 'savetodb_xls', 'savetodb_etl', 'SAVETODB_DEV', 'SAVETODB_XLS', 'SAVETODB_ETL', 'xls', 'doc', 'logs')
    AND NOT (s.name = 'dbo' AND (o.name LIKE 'sys%'))
    AND o.[type] = 'U'


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view selects unique key columns
-- =============================================

CREATE VIEW [xls].[view_unique_keys]
AS

SELECT
    ROW_NUMBER() OVER (ORDER BY s.name, o.name, c.column_id) AS SORT_ORDER
    , s.name AS [SCHEMA]
    , o.name AS [TABLE]
    , c.name AS [COLUMN]
    , c.column_id AS POSITION
    , p.[CONSTRAINT]
    , p.INDEX_POSITION
    , p.IS_DESCENDING
    , p.IS_INCLUDED
FROM
    sys.columns c
    INNER JOIN sys.objects o ON o.[object_id] = c.[object_id]
    INNER JOIN sys.schemas s ON s.[schema_id] = o.[schema_id]
    LEFT OUTER JOIN (
        SELECT
            c.[object_id]
            , c.column_id
            , i.name AS [CONSTRAINT]
            , ic.index_column_id AS INDEX_POSITION
            , CASE WHEN ic.is_descending_key = 1 THEN ic.is_descending_key ELSE NULL END AS IS_DESCENDING
            , CASE WHEN ic.is_included_column = 1 THEN ic.is_included_column ELSE NULL END AS IS_INCLUDED
        FROM
            sys.columns c
            INNER JOIN sys.indexes i ON i.[object_id] = c.[object_id] AND i.is_unique = 1 AND i.is_primary_key = 0
            INNER JOIN sys.index_columns ic ON ic.[object_id] = c.[object_id]
                AND ic.index_id = i.index_id AND ic.column_id = c.column_id
    ) p ON p.[object_id] = c.[object_id] AND p.column_id = c.column_id
WHERE
    NOT s.name IN ('dbo01', 'etl01', 'xls01', 'savetodb_dev', 'savetodb_xls', 'savetodb_etl', 'SAVETODB_DEV', 'SAVETODB_XLS', 'SAVETODB_ETL', 'xls', 'doc', 'logs')
    AND NOT (s.name = 'dbo' AND (o.name LIKE 'sys%'))
    AND o.[type] = 'U'


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects translations
-- =============================================

CREATE PROCEDURE [xls].[usp_translations]
    @field nvarchar(128) = NULL
    , @schema nvarchar(128) = NULL
    , @is_complete bit = NULL
AS
BEGIN

SET NOCOUNT ON;

IF @field IS NULL
    SET @field = 'TRANSLATED_NAME'
ELSE IF @field NOT IN ('TRANSLATED_NAME', 'TRANSLATED_DESC', 'TRANSLATED_COMMENT')
    BEGIN
    DECLARE @message nvarchar(max) = N'Invalid column name: %s' + CHAR(13) + CHAR(10)
         + 'Use TRANSLATED_NAME, TRANSLATED_DESC, or TRANSLATED_COMMENT'
    RAISERROR(@message, 11, 0, @field);
    RETURN
    END

DECLARE @sql nvarchar(max)
DECLARE @languages nvarchar(max)
DECLARE @complete nvarchar(max)

SELECT @languages = STUFF((
    SELECT
        t.name
    FROM
        (
        SELECT
            DISTINCT
            ', [' + t.LANGUAGE_NAME + ']' AS name
            , CASE
                WHEN t.LANGUAGE_NAME = 'en' THEN '1'
                WHEN t.LANGUAGE_NAME = 'fr' THEN '2'
                WHEN t.LANGUAGE_NAME = 'it' THEN '3'
                WHEN t.LANGUAGE_NAME = 'es' THEN '4'
                WHEN t.LANGUAGE_NAME = 'pt' THEN '5'
                WHEN t.LANGUAGE_NAME = 'de' THEN '6'
                WHEN t.LANGUAGE_NAME = 'ru' THEN '7'
                ELSE t.LANGUAGE_NAME
                END AS sort_order
        FROM
            xls.translations t
        ) t
    ORDER BY
        t.sort_order
    FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 2, '')

IF @languages IS NULL SET @languages = '[en]'

SELECT @complete = STUFF((
    SELECT
        t.name
    FROM
        (
        SELECT
            DISTINCT
            ' OR [' + t.LANGUAGE_NAME + '] IS NULL' AS name
            , CASE
                WHEN t.LANGUAGE_NAME = 'en' THEN '1'
                WHEN t.LANGUAGE_NAME = 'fr' THEN '2'
                WHEN t.LANGUAGE_NAME = 'it' THEN '3'
                WHEN t.LANGUAGE_NAME = 'es' THEN '4'
                WHEN t.LANGUAGE_NAME = 'pt' THEN '5'
                WHEN t.LANGUAGE_NAME = 'de' THEN '6'
                WHEN t.LANGUAGE_NAME = 'ru' THEN '7'
                ELSE t.LANGUAGE_NAME
                END AS sort_order
        FROM
            xls.translations t
        ) t
    ORDER BY
        t.sort_order
    FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 4, '')

IF @complete IS NULL SET @complete = '[en] IS NULL'

SET @sql = 'SELECT
    t.TABLE_SCHEMA
    , t.TABLE_NAME
    , t.COLUMN_NAME AS [COLUMN]
    , ' + @languages + '
    , CASE WHEN ' + @complete + ' THEN 0 ELSE 1 END AS is_complete
FROM
    (
        SELECT
            t.TABLE_SCHEMA
            , t.TABLE_NAME
            , t.COLUMN_NAME
            , t.LANGUAGE_NAME
            , t.' + @field + ' AS name
        FROM
            xls.translations t'
        + CASE WHEN @schema IS NULL THEN '' ELSE '
        WHERE
            ' + CASE WHEN LEFT(@schema, 1) = '(' AND RIGHT(@schema, 1) = ')' THEN 't.TABLE_SCHEMA IN ' + @schema
                ELSE 'COALESCE(t.TABLE_SCHEMA, '''') = COALESCE(' + COALESCE('''' + @schema + '''', 'NULL') + ', t.TABLE_SCHEMA, '''')'
                END
            END + '
    ) s PIVOT (
        MAX(name) FOR LANGUAGE_NAME IN (' + @languages + ')
    ) t'
    + CASE WHEN @is_complete IS NULL THEN '' WHEN @is_complete = 1 THEN '
WHERE
    NOT (' + @complete + ')'
    ELSE '
WHERE
    ' + @complete END + '
ORDER BY
    t.TABLE_SCHEMA
    , t.TABLE_NAME
    , t.COLUMN_NAME'

-- PRINT @sql

EXEC (@sql)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cell change event handler for usp_translations
--
-- @column_name is a column name of the edited cell
-- @cell_value is a new cell value
-- @field is a value of the field parameter of the usp_translations
-- @TABLE_SCHEMA, @TABLE_NAME, and @COLUMN are values of the Excel table columns
-- =============================================

CREATE PROCEDURE [xls].[usp_translations_change]
    @column_name nvarchar(128) = NULL
    , @cell_value nvarchar(max) = NULL
    , @TABLE_SCHEMA nvarchar(128) = NULL
    , @TABLE_NAME nvarchar(128) = NULL
    , @COLUMN nvarchar(128) = NULL
    , @field nvarchar(128) = NULL
AS
BEGIN

SET NOCOUNT ON

DECLARE @message nvarchar(max)

IF NOT EXISTS(SELECT TOP 1 ID FROM xls.translations WHERE LANGUAGE_NAME = @column_name)
    RETURN

IF @field IS NULL SET @field = 'TRANSLATED_NAME'

IF @field = 'TRANSLATED_NAME'
    UPDATE xls.translations SET TRANSLATED_NAME = @cell_value
        WHERE COALESCE(TABLE_SCHEMA, '') = COALESCE(@TABLE_SCHEMA, '') AND COALESCE(TABLE_NAME, '') = COALESCE(@TABLE_NAME, '')
            AND COALESCE(COLUMN_NAME, '') = COALESCE(@COLUMN, '') AND LANGUAGE_NAME = @column_name
ELSE IF @field = 'TRANSLATED_DESC'
    UPDATE xls.translations SET TRANSLATED_DESC = @cell_value
        WHERE COALESCE(TABLE_SCHEMA, '') = COALESCE(@TABLE_SCHEMA, '') AND COALESCE(TABLE_NAME, '') = COALESCE(@TABLE_NAME, '')
            AND COALESCE(COLUMN_NAME, '') = COALESCE(@COLUMN, '') AND LANGUAGE_NAME = @column_name
ELSE IF @field = 'TRANSLATED_COMMENT'
    UPDATE xls.translations SET TRANSLATED_COMMENT = @cell_value
        WHERE COALESCE(TABLE_SCHEMA, '') = COALESCE(@TABLE_SCHEMA, '') AND COALESCE(TABLE_NAME, '') = COALESCE(@TABLE_NAME, '')
            AND COALESCE(COLUMN_NAME, '') = COALESCE(@COLUMN, '') AND LANGUAGE_NAME = @column_name
ELSE
    BEGIN
    SET @message = N'Invalid column name: %s' + CHAR(13) + CHAR(10)
         + 'Use TRANSLATED_NAME, TRANSLATED_DESC, or TRANSLATED_COMMENT'
    RAISERROR(@message, 11, 0, @field);
    RETURN
    END

IF @@ROWCOUNT > 0 RETURN

IF @cell_value IS NULL RETURN

IF @field = 'TRANSLATED_NAME'
    INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME)
        VALUES (@TABLE_SCHEMA, @TABLE_NAME, @COLUMN, @column_name, @cell_value)
ELSE IF @field = 'TRANSLATED_DESC'
    INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_DESC)
        VALUES (@TABLE_SCHEMA, @TABLE_NAME, @COLUMN, @column_name, @cell_value)
ELSE IF @field = 'TRANSLATED_COMMENT'
    INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_COMMENT)
        VALUES (@TABLE_SCHEMA, @TABLE_NAME, @COLUMN, @column_name, @cell_value)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure creates or drops constraints
-- =============================================

CREATE PROCEDURE [xls].[xl_actions_generate_constraints]
    @Drop bit = 0
    , @Create bit = 0
    , @ConstraintType tinyint = NULL
    , @SCHEMA nvarchar(128) = NULL
    , @TABLE nvarchar(128) = NULL
    , @COLUMN nvarchar(128) = NULL
    , @REFERENTIAL_SCHEMA nvarchar(128) = NULL
    , @REFERENTIAL_NAME nvarchar(128) = NULL
    , @REFERENTIAL_COLUMN nvarchar(128) = NULL
    , @ON_UPDATE nvarchar(128) = NULL
    , @ON_DELETE nvarchar(128) = NULL
    , @CONSTRAINT nvarchar(128) = NULL
    , @ExecuteScript bit = 0
    , @DataLanguage varchar(10) = NULL
    , @SelectCommands bit = NULL
    , @PrintCommands bit = NULL
AS
BEGIN

SET NOCOUNT ON

IF @ExecuteScript IS NULL SET @ExecuteScript = 0
IF @DataLanguage IS NULL SET @DataLanguage = 'en'

DECLARE @message nvarchar(max)

DECLARE @Tab char(4) = REPLICATE(' ', 4)
DECLARE @CrLf char(2) = CHAR(13) + CHAR(10)

IF @Drop IS NULL AND @Create IS NULL
    BEGIN
    SET @message = xls.get_translated_string('Specify', @DataLanguage)
        + ' @Create:' + @CrLf + @CrLf
        + '1 - CREATE' + @CrLf
        + '0 - skip' + @CrLf
    RAISERROR(@message, 11, 0);
    RETURN
    END

IF @Drop IS NULL AND @Create = 0
    BEGIN
    SET @message = xls.get_translated_string('Specify', @DataLanguage)
        + ' @Drop:' + @CrLf + @CrLf
        + '1 - DROP' + @CrLf
        + '0 - skip' + @CrLf
    RAISERROR(@message, 11, 0);
    RETURN
    END

IF @Drop = 0 AND @Create = 0
    RETURN

IF @ConstraintType NOT IN (1, 2, 3, 4)
    BEGIN
    SET @message = xls.get_translated_string('Specify', @DataLanguage)
        + ' @ConstraintType:' + @CrLf + @CrLf
        + '1 - PRIMARY KEY' + @CrLf
        + '2 - UNIQUE' + @CrLf
        + '3 - INDEX' + @CrLf
        + '4 - FOREIGN KEY' + @CrLf
    RAISERROR(@message, 11, 0);
    RETURN
    END

IF @SCHEMA IS NULL
    BEGIN
    SET @message = xls.get_translated_string('Specify', @DataLanguage) + ' @SCHEMA'
    RAISERROR(@message, 11, 0);
    RETURN
    END

IF @TABLE IS NULL
    BEGIN
    SET @message = xls.get_translated_string('Specify', @DataLanguage) + ' @TABLE'
    RAISERROR(@message, 11, 0);
    RETURN
    END

IF @COLUMN IS NULL AND @Create = 1
    BEGIN
    SET @message = xls.get_translated_string('Specify', @DataLanguage) + ' @COLUMN'
    RAISERROR(@message, 11, 0);
    RETURN
    END

IF @ConstraintType = 4 AND @Create = 1 AND @REFERENTIAL_SCHEMA IS NULL
    BEGIN
    SET @message = xls.get_translated_string('Specify', @DataLanguage) + ' @REFERENTIAL_SCHEMA'
    RAISERROR(@message, 11, 0);
    RETURN
    END

IF @ConstraintType = 4 AND @Create = 1 AND @REFERENTIAL_NAME IS NULL
    BEGIN
    SET @message = xls.get_translated_string('Specify', @DataLanguage) + ' @REFERENTIAL_NAME'
    RAISERROR(@message, 11, 0);
    RETURN
    END

IF @ConstraintType = 4 AND @Create = 1 AND @REFERENTIAL_COLUMN IS NULL
    BEGIN
    SET @message = xls.get_translated_string('Specify', @DataLanguage) + ' @REFERENTIAL_COLUMN'
    RAISERROR(@message, 11, 0);
    RETURN
    END

IF @Drop = 1 AND @CONSTRAINT IS NULL
    BEGIN
    SET @message = xls.get_translated_string('Specify', @DataLanguage) + ' @CONSTRAINT'
    RAISERROR(@message, 11, 0);
    RETURN
    END

IF @CONSTRAINT IS NULL
    BEGIN
    IF @ConstraintType = 1
        SET @CONSTRAINT = 'PK_' + @TABLE + '_' + @SCHEMA
    ELSE IF @ConstraintType = 2
        SET @CONSTRAINT = 'IX_' + @TABLE + '_' + @COLUMN + '_' + @SCHEMA
    ELSE IF @ConstraintType = 3
        SET @CONSTRAINT = 'IX_' + @TABLE + '_' + @COLUMN + '_' + @SCHEMA
    ELSE IF @ConstraintType = 4
        SET @CONSTRAINT = 'FK_' + @TABLE + '_' + @REFERENTIAL_NAME + '_' + @COLUMN + '_' + @SCHEMA
    END

DECLARE @sql nvarchar(max)

SET @sql = CASE WHEN @Drop = 0 THEN '' ELSE
    CASE WHEN @ConstraintType = 3 THEN
        'DROP INDEX ' + QUOTENAME(REPLACE(@CONSTRAINT, '''', ''''''))
        + ' ON ' + QUOTENAME(REPLACE(@SCHEMA, '''', ''''''))+ '.' + QUOTENAME(REPLACE(@TABLE, '''', '''''')) + ';' + @CrLf
        ELSE
        'ALTER TABLE ' + QUOTENAME(REPLACE(@SCHEMA, '''', ''''''))+ '.' + QUOTENAME(REPLACE(@TABLE, '''', ''''''))
        + ' DROP CONSTRAINT ' + QUOTENAME(REPLACE(@CONSTRAINT, '''', '''''')) + ';' + @CrLf
        END
    END

    + CASE WHEN @Create = 0 THEN '' ELSE
    CASE WHEN @ConstraintType = 3 THEN
        'CREATE INDEX ' + QUOTENAME(REPLACE(@CONSTRAINT, '''', ''''''))
        + ' ON ' + QUOTENAME(REPLACE(@SCHEMA, '''', ''''''))+ '.' + QUOTENAME(REPLACE(@TABLE, '''', ''''''))
        + ' (' + QUOTENAME(REPLACE(@COLUMN, '''', '''''')) + ');' + @CrLf
        ELSE
        'ALTER TABLE ' + QUOTENAME(REPLACE(@SCHEMA, '''', ''''''))+ '.' + QUOTENAME(REPLACE(@TABLE, '''', ''''''))
        + ' ADD CONSTRAINT ' + QUOTENAME(REPLACE(@CONSTRAINT, '''', ''''''))
        + ' ' + CASE @ConstraintType
                WHEN 1 THEN 'PRIMARY KEY'
                WHEN 2 THEN 'UNIQUE'
                WHEN 4 THEN 'FOREIGN KEY'
                ELSE '?'
                END
        + ' (' + QUOTENAME(REPLACE(@COLUMN, '''', '''''')) + ')'
        + CASE WHEN @ConstraintType = 4 THEN
            + ' REFERENCES ' + QUOTENAME(REPLACE(@REFERENTIAL_SCHEMA, '''', ''''''))+ '.' + QUOTENAME(REPLACE(@REFERENTIAL_NAME, '''', ''''''))
            + ' (' + QUOTENAME(REPLACE(@REFERENTIAL_COLUMN, '''', '''''')) + ')'
            + CASE UPPER(@ON_UPDATE)
                    WHEN 'CASCADE' THEN ' ON UPDATE CASCADE'
                    WHEN 'SET NULL' THEN ' ON UPDATE SET NULL'
                    WHEN 'SET DEFAULT' THEN ' ON UPDATE SET NULL'
                    ELSE ''
                END
            + CASE UPPER(@ON_DELETE)
                    WHEN 'CASCADE' THEN ' ON DELETE CASCADE'
                    WHEN 'SET NULL' THEN ' ON DELETE SET NULL'
                    WHEN 'SET DEFAULT' THEN ' ON DELETE SET NULL'
                    ELSE ''
                END
            ELSE ''
            END
        + ';' + @CrLf
        END
        END

IF @SelectCommands IS NULL AND @PrintCommands IS NULL SET @SelectCommands = 1

IF @PrintCommands = 1
    BEGIN
    PRINT @sql + @CrLf + 'GO' + @CrLf + @CrLf
    END

IF @ExecuteScript = 1
    BEGIN
    EXEC (@sql)

    IF @SelectCommands = 1
        IF @Drop = 1 AND @Create = 1
            SELECT @sql + @CrLf + xls.get_translated_string('Dropped and created', @DataLanguage) AS [message]
        ELSE IF @Drop = 1
            SELECT @sql + @CrLf + xls.get_translated_string('Dropped', @DataLanguage) AS [message]
        ELSE
            SELECT @sql + @CrLf + xls.get_translated_string('Created', @DataLanguage) AS [message]
    END

ELSE IF @SelectCommands = 1
    BEGIN
    SELECT
        @sql
        + 'GO' + @CrLf + @CrLf
        AS [message]
    END

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure generates SaveToDB handler objects
--
-- @HandlerType
-- 1 - ValidationList
-- 2 - ParameterValues
-- 3 - ParameterValues with the null value
-- 4 - ContextMenu
-- 5 - DoubleClick
-- 6 - SelectionChange
-- 7 - Actions
--
-- 9.1 MySQL style
-- =============================================

CREATE PROCEDURE [xls].[xl_actions_generate_handlers]
    @BaseTableSchema nvarchar(128) = NULL
    , @BaseTableName nvarchar(128) = NULL
    , @TargetObjectSchema nvarchar(128) = NULL
    , @TargetObjectName nvarchar(128) = NULL
    , @HandlerType int = NULL
    , @GenerateTargetAsView bit = 0
    , @ExecuteScript bit = 0
    , @RecreateProceduresIfExist bit = 0
    , @DataLanguage varchar(10) = NULL
    , @SelectCommands bit = NULL
    , @PrintCommands bit = NULL
    , @MySqlStyle bit = 0
AS
BEGIN

BEGIN -- CHECKS --

SET NOCOUNT ON

IF @ExecuteScript IS NULL SET @ExecuteScript = 0
IF @RecreateProceduresIfExist IS NULL SET @RecreateProceduresIfExist = 0
IF @DataLanguage IS NULL SET @DataLanguage = 'en'

IF @BaseTableSchema IS NULL AND @BaseTableName IS NOT NULL AND CHARINDEX('.', @BaseTableName) > 1
    BEGIN
    SET @BaseTableSchema = LEFT(@BaseTableName, CHARINDEX('.', @BaseTableName) - 1)
    SET @BaseTableName = SUBSTRING(@BaseTableName, CHARINDEX('.', @BaseTableName) + 1, LEN(@BaseTableName))
    END

DECLARE @message nvarchar(max)

DECLARE @Tab char(4) = REPLICATE(' ', 4)
DECLARE @CrLf char(2) = CHAR(13) + CHAR(10)

IF @BaseTableSchema IS NULL
    BEGIN
    SET @message = xls.get_translated_string('Specify', @DataLanguage) + ' @BaseTableSchema'
    RAISERROR(@message, 11, 0);
    RETURN
    END

IF @BaseTableName IS NULL
    BEGIN
    SET @message = xls.get_translated_string('Specify', @DataLanguage) + ' @BaseTableName'
    RAISERROR(@message, 11, 0);
    RETURN
    END

IF LEFT(@BaseTableSchema, 1) = '[' AND RIGHT(@BaseTableSchema, 1) = ']'
    SET @BaseTableSchema = REPLACE(SUBSTRING(@BaseTableSchema, 2, LEN(@BaseTableSchema) - 2), ']]', ']')

IF LEFT(@BaseTableName, 1) = '[' AND RIGHT(@BaseTableName, 1) = ']'
    SET @BaseTableName = REPLACE(SUBSTRING(@BaseTableName, 2, LEN(@BaseTableName) - 2), ']]', ']')

IF @TargetObjectSchema IS NULL
    SET @TargetObjectSchema = @BaseTableSchema

DECLARE @BaseTable nvarchar(255)

IF xls.get_escaped_parameter_name(@BaseTableSchema) = @BaseTableSchema
    AND xls.get_escaped_parameter_name(@BaseTableName) = @BaseTableName
    SET @BaseTable = @BaseTableSchema + '.' + @BaseTableName
ELSE
    SET @BaseTable = QUOTENAME(@BaseTableSchema) + '.' + QUOTENAME(@BaseTableName)

IF OBJECT_ID(@BaseTable) IS NULL
    BEGIN
    SET @message = xls.get_translated_string('Table ''%s'' does not exist', @DataLanguage)
    RAISERROR(@message, 11, 0, @BaseTable);
    RETURN
    END

IF SCHEMA_ID(@TargetObjectSchema) IS NULL AND @ExecuteScript = 1
    BEGIN
    SET @message = xls.get_translated_string('Target schema ''%s'' does not exist', @DataLanguage)
    RAISERROR(@message, 11, 0, @TargetObjectSchema);
    RETURN
    END

IF NOT @HandlerType IN (1, 2, 3, 4, 5, 6, 7)
    BEGIN
    SET @message = xls.get_translated_string('Unknown handler type: %i', @DataLanguage) + @CrLf + @CrLf
        + xls.get_translated_string('Specify', @DataLanguage)
        + ' @HandlerType:' + @CrLf + @CrLf
        + '1 - ValidationList' + @CrLf
        + '2 - ParameterValues' + @CrLf
        + '3 - ParameterValues with the null value' + @CrLf
        + '4 - ContextMenu' + @CrLf
        + '5 - DoubleClick' + @CrLf
        + '6 - SelectionChange' + @CrLf
        + '7 - Actions' + @CrLf
    RAISERROR(@message, 11, 0, @HandlerType);
    RETURN
    END

END

BEGIN -- PRIMARY KEY AND UNIQUE COLUMNS --

DECLARE @PrimaryColumnCount int
DECLARE @PrimaryColumn nvarchar(128)
DECLARE @UniqueColumn nvarchar(128)
DECLARE @ExampleColumn nvarchar(128)

IF @HandlerType IN (1, 2, 3)
    BEGIN
    SELECT
        @PrimaryColumnCount = COUNT(ccu.COLUMN_NAME)
        , @PrimaryColumn = MAX(ccu.COLUMN_NAME)
    FROM
        INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
        INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
            ON tc.TABLE_SCHEMA = ccu.TABLE_SCHEMA AND tc.TABLE_NAME = ccu.TABLE_NAME
                AND tc.CONSTRAINT_SCHEMA = ccu.CONSTRAINT_SCHEMA AND tc.CONSTRAINT_NAME = ccu.CONSTRAINT_NAME
                AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
    WHERE
        ccu.TABLE_SCHEMA = @BaseTableSchema
        AND ccu.TABLE_NAME = @BaseTableName

    IF @PrimaryColumnCount = 0
        BEGIN
        SET @message = xls.get_translated_string('''%s.%s'' has no primary key', @DataLanguage)
        RAISERROR(@message, 11, 0, @BaseTableSchema, @BaseTableName);
        RETURN
        END

    IF @PrimaryColumnCount > 1
        BEGIN
        SET @message = xls.get_translated_string('''%s.%s'' has more than one primary key column', @DataLanguage)
        RAISERROR(@message, 11, 0, @BaseTableSchema, @BaseTableName);
        RETURN
        END

    SELECT
        TOP 1
        @UniqueColumn = COLUMN_NAME
    FROM
        (
            SELECT
                MAX(ccu.COLUMN_NAME) AS COLUMN_NAME
                , MAX(CASE
                    WHEN c.CHARACTER_MAXIMUM_LENGTH BETWEEN 10 AND 50 THEN 0
                    WHEN c.CHARACTER_MAXIMUM_LENGTH > 50 THEN 1
                    WHEN c.CHARACTER_MAXIMUM_LENGTH < 10 THEN 2
                    ELSE 3 END) AS LENGTH_RANK
            FROM
                INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
                    ON tc.TABLE_SCHEMA = ccu.TABLE_SCHEMA AND tc.TABLE_NAME = ccu.TABLE_NAME
                        AND tc.CONSTRAINT_SCHEMA = ccu.CONSTRAINT_SCHEMA AND tc.CONSTRAINT_NAME = ccu.CONSTRAINT_NAME
                        AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                INNER JOIN INFORMATION_SCHEMA.COLUMNS c
                    ON c.TABLE_SCHEMA = ccu.TABLE_SCHEMA AND c.TABLE_NAME = ccu.TABLE_NAME AND c.COLUMN_NAME = ccu.COLUMN_NAME
            WHERE
                ccu.TABLE_SCHEMA = @BaseTableSchema
                AND ccu.TABLE_NAME = @BaseTableName
            GROUP BY
                ccu.TABLE_SCHEMA
                , ccu.TABLE_NAME
            HAVING
                COUNT(*) = 1
        ) t
    ORDER BY
        t.LENGTH_RANK

    IF @UniqueColumn IS NULL
        BEGIN
        SELECT
            TOP 1
            @UniqueColumn = COLUMN_NAME
        FROM
            (
                SELECT
                    c.COLUMN_NAME
                    , CASE
                        WHEN c.CHARACTER_MAXIMUM_LENGTH BETWEEN 10 AND 50 THEN 0
                        WHEN c.CHARACTER_MAXIMUM_LENGTH > 50 THEN 1
                        WHEN c.CHARACTER_MAXIMUM_LENGTH < 10 THEN 2
                        ELSE 3 END AS LENGTH_RANK
                FROM
                    INFORMATION_SCHEMA.COLUMNS c
                WHERE
                    c.TABLE_SCHEMA = @BaseTableSchema
                    AND c.TABLE_NAME = @BaseTableName
                    AND c.CHARACTER_MAXIMUM_LENGTH IS NOT NULL
            ) t
        ORDER BY
            t.LENGTH_RANK
        END

    SET @ExampleColumn = @UniqueColumn
    END
ELSE IF OBJECT_ID(@BaseTable, 'P') IS NOT NULL
    SET @ExampleColumn = 'id'
ELSE
    BEGIN
    SELECT
        TOP 1
        @ExampleColumn = COLUMN_NAME
    FROM
        INFORMATION_SCHEMA.COLUMNS c
    WHERE
        c.TABLE_SCHEMA = @BaseTableSchema
        AND c.TABLE_NAME = @BaseTableName
    ORDER BY
        c.ORDINAL_POSITION
    END

END

BEGIN -- HANDLER PARAMETERS --

DECLARE @termColumnName nvarchar(128) = '@ColumnName'
DECLARE @termCellValue nvarchar(128) = '@CellValue'
DECLARE @termCellNumberValue nvarchar(128) = '@CellNumberValue'
DECLARE @termCellDateTimeValue nvarchar(128) = '@CellDateTimeValue'
DECLARE @termDataLanguage nvarchar(128) = '@DataLanguage'

IF @MySqlStyle = 1
    BEGIN
    SET @termColumnName = '@column_name'
    SET @termCellValue = '@cell_value'
    SET @termCellNumberValue = '@cell_number_value'
    SET @termCellDateTimeValue = '@cell_datetime_value'
    SET @termDataLanguage = '@data_language'
    END

DECLARE @HasDates bit
DECLARE @HasNumbers bit

DECLARE @HandlerParameters nvarchar(max) = ''

DECLARE @sql nvarchar(max)

IF OBJECT_ID(@BaseTable, 'P') IS NOT NULL
    BEGIN
    SET @HasDates = 1
    SET @HasNumbers = 1

    IF OBJECT_ID('sys.dm_exec_describe_first_result_set') IS NOT NULL
        BEGIN
        SET @sql = 'SELECT @HandlerParameters = STUFF((
    SELECT ''
    , @'' + xls.get_escaped_parameter_name(c.name)
        + '' '' + c.system_type_name
        + '' = NULL''
    FROM
        sys.dm_exec_describe_first_result_set(N''' + REPLACE(@BaseTable, '''', '''''') + ''', NULL, 0) c
    WHERE
        c.is_hidden = 0
        AND NOT c.system_type_name IN (''geography'', ''geometry'', ''image'')
    ORDER BY
        c.column_ordinal
    FOR XML PATH(''''), TYPE).value(''.'', ''nvarchar(MAX)''), 1, 2, '''')'

        EXEC sys.sp_executesql @stmt = @sql, @params = N'@HandlerParameters nvarchar(max) out', @HandlerParameters = @HandlerParameters out
        END
    END
ELSE
    BEGIN
    SELECT
        @HasDates =    MAX(CASE WHEN c.DATETIME_PRECISION IS NULL THEN 0 ELSE 1 END)
        , @HasNumbers = MAX(CASE WHEN c.NUMERIC_PRECISION IS NULL THEN 0 WHEN c.DATA_TYPE IN ('bit') THEN 1 ELSE 1 END)
    FROM
        INFORMATION_SCHEMA.COLUMNS c
    WHERE
        c.TABLE_SCHEMA = @BaseTableSchema
        AND c.TABLE_NAME = @BaseTableName

    SELECT @HandlerParameters = STUFF((
        SELECT
            @CrLf + '    , @' + xls.get_escaped_parameter_name(c.COLUMN_NAME)
            + ' ' + c.DATA_TYPE
            + CASE WHEN c.CHARACTER_MAXIMUM_LENGTH IS NULL THEN '' ELSE '(' + CAST(c.CHARACTER_MAXIMUM_LENGTH AS varchar(5)) + ')' END
            + ' = NULL'
        FROM
            INFORMATION_SCHEMA.COLUMNS c
        WHERE
            c.TABLE_SCHEMA = @BaseTableSchema
            AND c.TABLE_NAME = @BaseTableName
            AND NOT c.DATA_TYPE IN ('geography', 'geometry', 'image')
        ORDER BY
            c.ORDINAL_POSITION
        FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 2, '')
    END

DECLARE @LanguageParameters nvarchar(max) =
    + @termDataLanguage + ' varchar(10) = NULL' + @CrLf

DECLARE @ContextParameters nvarchar(max) =
    '    ' + @termColumnName + ' nvarchar(128) = NULL' + @CrLf
    + '    , ' + @termCellValue + ' nvarchar(255) = NULL' + @CrLf
    + CASE WHEN @HasNumbers = 1 THEN '    , ' + @termCellNumberValue + ' float = NULL' + @CrLf ELSE '' END
    + CASE WHEN @HasDates = 1 THEN '    , ' + @termCellDateTimeValue + ' datetime = NULL' + @CrLf ELSE '' END
    + '    , ' + @LanguageParameters

END

BEGIN -- PROCEDURE NAMES --

DECLARE @TargetObject nvarchar(255)

IF @TargetObjectName IS NULL
    BEGIN
    IF @HandlerType = 1
        SET @TargetObjectName = 'xl_validation_list_' + @BaseTableName + '_' + @PrimaryColumn
    ELSE IF @HandlerType = 2
        SET @TargetObjectName = 'xl_parameter_values_' + @BaseTableName + '_' + @PrimaryColumn
    ELSE IF @HandlerType = 3
        SET @TargetObjectName = 'xl_parameter_values_' + @BaseTableName + '_' + @PrimaryColumn + '_or_null'
    ELSE IF @HandlerType = 4
        SET @TargetObjectName = 'xl_context_menu_' + @BaseTableName
    ELSE IF @HandlerType = 5
        SET @TargetObjectName = 'xl_double_click_' + @BaseTableName
    ELSE IF @HandlerType = 6
        SET @TargetObjectName = 'xl_selection_change_' + @BaseTableName
    ELSE IF @HandlerType = 7
        SET @TargetObjectName = 'xl_actions_' + @BaseTableName
    END

IF xls.get_escaped_parameter_name(@TargetObjectSchema) = @TargetObjectSchema
    AND xls.get_escaped_parameter_name(@TargetObjectName) = @TargetObjectName
    SET @TargetObject = @TargetObjectSchema + '.' + @TargetObjectName
ELSE
    SET @TargetObject = QUOTENAME(@TargetObjectSchema) + '.' + QUOTENAME(@TargetObjectName)

END

BEGIN -- HEADERS --

DECLARE @HeaderText nvarchar(max) = '
-- =============================================
-- Author:      ' + xls.get_translated_string('<Author>', 'en') + '
-- Release:     ' + xls.get_translated_string('<Release>', 'en') + ', ' + CONVERT(char(10), GETDATE(), 120)
    + CASE
        WHEN @HandlerType = 1 THEN '
-- Description: Validation list of ' + @BaseTableSchema + '.' + @BaseTableName + '.' + @PrimaryColumn
        WHEN @HandlerType IN (2, 3) THEN '
-- Description: Parameter values of ' + @BaseTableSchema + '.' + @BaseTableName + '.' + @PrimaryColumn
        WHEN @HandlerType = 4 THEN '
-- Description: Context menu handler for ' + @BaseTableSchema + '.' + @BaseTableName
        WHEN @HandlerType = 5 THEN '
-- Description: Double-click handler for ' + @BaseTableSchema + '.' + @BaseTableName
        WHEN @HandlerType = 6 THEN '
-- Description: Selection change handler for ' + @BaseTableSchema + '.' + @BaseTableName
        WHEN @HandlerType = 7 THEN '
-- Description: Actions menu handler for ' + @BaseTableSchema + '.' + @BaseTableName
        ELSE '
-- Description: '
        END + '
-- =============================================

'

END

BEGIN -- PROCEDURE DEFINITIONS --

DECLARE @DeleteSQL nvarchar(max) =
    CASE WHEN @GenerateTargetAsView = 1 THEN
        'IF OBJECT_ID(N''' + REPLACE(@TargetObject, '''', '''''') + ''', ''V'') IS NOT NULL' + @CrLf
        + @Tab + 'DROP VIEW '+ @TargetObject + @CrLf
    ELSE
        'IF OBJECT_ID(N''' + REPLACE(@TargetObject, '''', '''''') + ''', ''P'') IS NOT NULL' + @CrLf
        + @Tab + 'DROP PROCEDURE '+ @TargetObject + @CrLf
    END

DECLARE @Body nvarchar(max)

IF @HandlerType IN (1, 2, 3)
    BEGIN
    SET @Body =
    CASE WHEN @HandlerType = 3 THEN
        'SELECT NULL AS ' + xls.get_friendly_column_name(@PrimaryColumn) + COALESCE(', NULL AS ' + xls.get_friendly_column_name(@UniqueColumn), '') + ' UNION ALL' + @CrLf
        ELSE '' END
    + 'SELECT' + @CrLf
    + @Tab + 't.' + xls.get_friendly_column_name(@PrimaryColumn) + @CrLf
    + COALESCE(@Tab + ', t.' + xls.get_friendly_column_name(@UniqueColumn) + @CrLf, '')
    + 'FROM'+ @CrLf
    + @Tab + @BaseTable + ' t' + @CrLf
    + CASE WHEN @GenerateTargetAsView = 1 THEN '' ELSE
      'ORDER BY' + @CrLf
       + @Tab + CASE WHEN @UniqueColumn IS NOT NULL THEN 't.' + xls.get_friendly_column_name(@UniqueColumn) + @CrLf + @Tab + ', ' ELSE '' END
       + 't.' + xls.get_friendly_column_name(@PrimaryColumn) + @CrLf
       END
    END
ELSE IF @HandlerType IN (4)
    BEGIN
    SET @Body = xls.get_translated_string('-- Place your code for the context menu handler here', @DataLanguage) + @CrLf
        + @CrLf
        + xls.get_translated_string('-- You may execute SELECT, INSERT, UPDATE and DELETE commands', @DataLanguage) + @CrLf
        + @CrLf
        + xls.get_translated_string('-- You may use predefined parameters like @ColumnName or @CellValue', @DataLanguage) + @CrLf
        + xls.get_translated_string('-- and values of the current row using table-specific parameters like ', @DataLanguage)
        + '@' + xls.get_escaped_parameter_name(@ExampleColumn) + @CrLf
    END
ELSE IF @HandlerType IN (5)
    BEGIN
    SET @Body = xls.get_translated_string('-- Place your code for the double-click handler here', @DataLanguage) + @CrLf
        + @CrLf
        + xls.get_translated_string('-- You may execute SELECT commands', @DataLanguage) + @CrLf
        + @CrLf
        + xls.get_translated_string('-- You may use predefined parameters like @ColumnName or @CellValue', @DataLanguage) + @CrLf
        + xls.get_translated_string('-- and values of the current row using table-specific parameters like ', @DataLanguage)
        + '@' + xls.get_escaped_parameter_name(@ExampleColumn) + @CrLf
    END
ELSE IF @HandlerType IN (6)
    BEGIN
    SET @Body = xls.get_translated_string('-- Place your code for the selection change handler here', @DataLanguage) + @CrLf
        + @CrLf
        + xls.get_translated_string('-- You may execute SELECT commands', @DataLanguage) + @CrLf
        + @CrLf
        + xls.get_translated_string('-- You may use predefined parameters like @ColumnName or @CellValue', @DataLanguage) + @CrLf
        + xls.get_translated_string('-- and values of the current row using table-specific parameters like ', @DataLanguage)
        + '@' + xls.get_escaped_parameter_name(@ExampleColumn) + @CrLf
    END
ELSE IF @HandlerType IN (7)
    BEGIN
    SET @Body = xls.get_translated_string('-- Place your code for the Actions menu handler here', @DataLanguage) + @CrLf
        + @CrLf
        + xls.get_translated_string('-- You may execute any command', @DataLanguage) + @CrLf
        + @CrLf
        + xls.get_translated_string('-- Unlike the context menu handlers, these handlers have no row context values', @DataLanguage) + @CrLf
        + xls.get_translated_string('-- when the active cell is outside of the table', @DataLanguage) + @CrLf
    END
ELSE
    SET @Body = xls.get_translated_string('-- Place your code here', @DataLanguage) + @CrLf

DECLARE @ProcedureSQL nvarchar(max) =
    @HeaderText
    + CASE WHEN @GenerateTargetAsView = 1 THEN
        'CREATE' + ' VIEW ' + @TargetObject + @CrLf
        ELSE
        'CREATE' + ' PROCEDURE ' + @TargetObject + @CrLf
        + CASE
            WHEN @HandlerType IN (4, 5, 6, 7) THEN @ContextParameters + @HandlerParameters + @CrLf
            ELSE '' END
        END
    + 'AS' + @CrLf
    + CASE WHEN @GenerateTargetAsView = 1 THEN '' ELSE 'BEGIN' + @CrLf + @CrLf + 'SET NOCOUNT ON' + @CrLf END
    + @CrLf
    + @Body
    + @CrLf
    + CASE WHEN @GenerateTargetAsView = 1 THEN '' ELSE 'END' + @CrLf END
    + @CrLf

END

BEGIN -- HELP --

DECLARE @GoLine nvarchar(10) = 'GO' + @CrLf + @CrLf

DECLARE @Help nvarchar(max) =
    CASE WHEN xls.get_translated_string('<Author>', 'en') = '<Author>' THEN
    '-- You may define the <Author> and <Release> values in the xls.translations table:' + @CrLf
    + @CrLf
    + '-- TABLE_SCHEMA TABLE_NAME COLUMN_NAME LANGUAGE_NAME TRANSLATED_NAME' + @CrLf
    + '-- ------------ ---------- ----------- ------------- ---------------' + @CrLf
    + '-- xls          strings    <Author>    en            <Your value>' + @CrLf
    + '-- xls          strings    <Release>   en            <Your value>' + @CrLf
    + @CrLf
    ELSE '' END

    + '-- Use the following code to attach the handler to the target object:'+ @CrLf
    + @CrLf
    + '-- INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE)' + @CrLf
    + '--     VALUES('
    + CASE @HandlerType
        WHEN 1 THEN 'N''<target object schema>'', N''<target object name>'''
        WHEN 2 THEN 'N''<target object schema>'', N''<target object name>'''
        WHEN 3 THEN 'N''<target object schema>'', N''<target object name>'''
        WHEN 4 THEN 'N''' + REPLACE(@BaseTableSchema, '''', '''''') + ''', N''' + REPLACE(@BaseTableName, '''', '''''') + ''''
        WHEN 5 THEN 'N''' + REPLACE(@BaseTableSchema, '''', '''''') + ''', N''' + REPLACE(@BaseTableName, '''', '''''') + ''''
        WHEN 6 THEN 'N''' + REPLACE(@BaseTableSchema, '''', '''''') + ''', N''' + REPLACE(@BaseTableName, '''', '''''') + ''''
        WHEN 7 THEN 'N''' + REPLACE(@BaseTableSchema, '''', '''''') + ''', N''' + REPLACE(@BaseTableName, '''', '''''') + ''''
        ELSE 'N''<target object schema>'', N''<target object name>'''
        END + ', '
    + CASE @HandlerType
        WHEN 1 THEN 'N''<target column>'''
        WHEN 2 THEN 'N''<target parameter>'''
        WHEN 3 THEN 'N''<target parameter>'''
        WHEN 4 THEN 'N''<target column or NULL>'''
        WHEN 5 THEN 'N''<target column or NULL>'''
        WHEN 6 THEN 'N''<target column or NULL>'''
        WHEN 7 THEN 'NULL'
        ELSE 'N''<target column>'''
        END + ', '
    + '''' + CASE @HandlerType
        WHEN 1 THEN 'ValidationList'
        WHEN 2 THEN 'ParameterValues'
        WHEN 3 THEN 'ParameterValues'
        WHEN 4 THEN 'ContextMenu'
        WHEN 5 THEN 'DoubleClick'
        WHEN 6 THEN 'SelectionChange'
        WHEN 7 THEN 'Actions'
        ELSE 'N''<target event>'''
        END + ''', '
    + 'N''' + REPLACE(@TargetObjectSchema, '''', '''''') + ''', N''' + @TargetObjectName + ''', '''
    + CASE WHEN @GenerateTargetAsView = 1 THEN 'VIEW' ELSE 'PROCEDURE' END + ''')' + @CrLf
    + @CrLf

    + @GoLine

END

BEGIN -- EXECUTE GENERATED CODES --

IF @SelectCommands IS NULL AND @PrintCommands IS NULL SET @SelectCommands = 1

IF @PrintCommands = 1
    BEGIN
    RAISERROR(@Help, 0, 1) WITH NOWAIT
    RAISERROR(@DeleteSQL, 0, 1) WITH NOWAIT
    RAISERROR(@GoLine,  0, 1) WITH NOWAIT
    RAISERROR(@ProcedureSQL, 0, 1) WITH NOWAIT
    RAISERROR(@GoLine,  0, 1) WITH NOWAIT
    END

IF @ExecuteScript = 1
    BEGIN
    IF @RecreateProceduresIfExist = 1
        EXEC (@DeleteSQL)

    IF OBJECT_ID(@TargetObject, 'P') IS NULL
        EXEC (@ProcedureSQL)

    IF @SelectCommands = 1
        SELECT 'Created' AS [message]
    END

ELSE IF @SelectCommands = 1
    BEGIN
    SELECT
        @Help
        + @DeleteSQL
        + 'GO' + @CrLf + @CrLf
        + @ProcedureSQL
        + 'GO' + @CrLf + @CrLf
        AS [message]
    END

END

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure generates SELECT, INSERT, UPDATE, DELETE, and CHANGE procedures
--
-- 9.1 MySQL style; improved cell change handlers.
-- =============================================

CREATE PROCEDURE [xls].[xl_actions_generate_procedures]
    @BaseTableSchema nvarchar(128) = NULL
    , @BaseTableName nvarchar(128) = NULL
    , @SelectObjectSchema nvarchar(128) = NULL
    , @SelectObjectName nvarchar(128) = NULL
    , @GenerateSelectObject bit = 1
    , @GenerateEditProcedures bit = 1
    , @GenerateChangeHandler bit = 0
    , @GenerateSelectAsView bit = 0
    , @ExecuteScript bit = 0
    , @RecreateProceduresIfExist bit = 0
    , @DataLanguage varchar(10) = NULL
    , @SelectCommands bit = NULL
    , @PrintCommands bit = NULL
    , @MySqlStyle bit = 0
AS
BEGIN

BEGIN -- CHECKS --

SET NOCOUNT ON

IF @ExecuteScript IS NULL SET @ExecuteScript = 0
IF @RecreateProceduresIfExist IS NULL SET @RecreateProceduresIfExist = 0
IF @GenerateSelectObject IS NULL SET @GenerateSelectObject = 1
IF @GenerateEditProcedures IS NULL SET @GenerateEditProcedures = 1
IF @GenerateChangeHandler IS NULL SET @GenerateChangeHandler = 0
IF @DataLanguage IS NULL SET @DataLanguage = 'en'

IF @BaseTableSchema IS NULL AND @BaseTableName IS NOT NULL AND CHARINDEX('.', @BaseTableName) > 1
    BEGIN
    SET @BaseTableSchema = LEFT(@BaseTableName, CHARINDEX('.', @BaseTableName) - 1)
    SET @BaseTableName = SUBSTRING(@BaseTableName, CHARINDEX('.', @BaseTableName) + 1, LEN(@BaseTableName))
    END

DECLARE @message nvarchar(max)

IF @BaseTableSchema IS NULL
    BEGIN
    SET @message = xls.get_translated_string('Specify', @DataLanguage) + ' @BaseTableSchema'
    RAISERROR(@message, 11, 0);
    RETURN
    END

IF @BaseTableName IS NULL
    BEGIN
    SET @message = xls.get_translated_string('Specify', @DataLanguage) + ' @BaseTableName'
    RAISERROR(@message, 11, 0);
    RETURN
    END

IF LEFT(@BaseTableSchema, 1) = '[' AND RIGHT(@BaseTableSchema, 1) = ']'
    SET @BaseTableSchema = REPLACE(SUBSTRING(@BaseTableSchema, 2, LEN(@BaseTableSchema) - 2), ']]', ']')

IF LEFT(@BaseTableName, 1) = '[' AND RIGHT(@BaseTableName, 1) = ']'
    SET @BaseTableName = REPLACE(SUBSTRING(@BaseTableName, 2, LEN(@BaseTableName) - 2), ']]', ']')

IF @SelectObjectSchema IS NULL
    SET @SelectObjectSchema = @BaseTableSchema

DECLARE @BaseTable nvarchar(255)

IF xls.get_escaped_parameter_name(@BaseTableSchema) = @BaseTableSchema
    AND xls.get_escaped_parameter_name(@BaseTableName) = @BaseTableName
    SET @BaseTable = @BaseTableSchema + '.' + @BaseTableName
ELSE
    SET @BaseTable = QUOTENAME(@BaseTableSchema) + '.' + QUOTENAME(@BaseTableName)

IF OBJECT_ID(@BaseTable) IS NULL
    BEGIN
    SET @message = xls.get_translated_string('Table ''%s'' does not exist', @DataLanguage)
    RAISERROR(@message, 11, 0, @BaseTable);
    RETURN
    END

IF SCHEMA_ID(@SelectObjectSchema) IS NULL AND @ExecuteScript = 1
    BEGIN
    SET @message = xls.get_translated_string('Target schema ''%s'' does not exist', @DataLanguage)
    RAISERROR(@message, 11, 0, @SelectObjectSchema);
    RETURN
    END

DECLARE @UnderlyingTableSchema nvarchar(128) = @BaseTableSchema
DECLARE @UnderlyingTableName nvarchar(128) = @BaseTableName
DECLARE @UnderlyingTable nvarchar(255) = @BaseTable

IF OBJECT_ID(@BaseTable, 'V') IS NOT NULL
    BEGIN
    SET @UnderlyingTable = xls.get_view_underlying_table(@BaseTableSchema, @BaseTableName)
    IF @UnderlyingTable IS NOT NULL
        BEGIN
        SET @UnderlyingTableSchema = OBJECT_SCHEMA_NAME(OBJECT_ID(@UnderlyingTable))
        SET @UnderlyingTableName = OBJECT_NAME(OBJECT_ID(@UnderlyingTable))
        END
    END
ELSE IF OBJECT_ID(@BaseTable, 'P') IS NOT NULL
    BEGIN
    SET @UnderlyingTable = xls.get_procedure_underlying_table(@BaseTableSchema, @BaseTableName)
    IF @UnderlyingTable IS NOT NULL
        BEGIN
        SET @UnderlyingTableSchema = OBJECT_SCHEMA_NAME(OBJECT_ID(@UnderlyingTable))
        SET @UnderlyingTableName = OBJECT_NAME(OBJECT_ID(@UnderlyingTable))
        END
    END

IF (
    SELECT
        COUNT(*)
    FROM
        INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    WHERE
        tc.TABLE_SCHEMA = @UnderlyingTableSchema
        AND tc.TABLE_NAME = @UnderlyingTableName
        AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
    ) = 0
    BEGIN
    SET @message = xls.get_translated_string('''%s.%s'' has no primary key', @DataLanguage)
    RAISERROR(@message, 11, 0, @UnderlyingTableSchema, @UnderlyingTableName);
    RETURN
    END

END

BEGIN -- DECLARATIONS --

DECLARE @SelectFields nvarchar(max) = ''
DECLARE @UpdateFields nvarchar(max) = ''
DECLARE @InsertFields nvarchar(max) = ''
DECLARE @InsertValues nvarchar(max) = ''
DECLARE @InsertParameters nvarchar(max) = ''
DECLARE @UpdateParameters nvarchar(max) = ''
DECLARE @DeleteParameters nvarchar(max) = ''
DECLARE @DeleteWhere nvarchar(max) = ''
DECLARE @SelectJoin nvarchar(max) = ''
DECLARE @JoinNumber int = 0
DECLARE @QuotedColumnName nvarchar(128)
DECLARE @ParameterSQL nvarchar(255)

DECLARE @COLUMN_NAME nvarchar(128)
DECLARE @ORDINAL_POSITION int
DECLARE @DATA_TYPE nvarchar(128)
DECLARE @CHARACTER_MAXIMUM_LENGTH int

DECLARE @COLUMN_EXISTS bit
DECLARE @IS_NULLABLE nvarchar(3)
DECLARE @IS_PRIMARY_KEY bit
DECLARE @IS_IDENTITY bit
DECLARE @IS_ROWGUIDCOL bit
DECLARE @IS_COMPUTED bit

DECLARE @LINKED_TABLE_SCHEMA nvarchar(128)
DECLARE @LINKED_TABLE_NAME nvarchar(128)
DECLARE @LINKED_COLUMN_NAME nvarchar(128)

DECLARE @Tab char(4) = REPLICATE(' ', 4)
DECLARE @CrLf char(2) = CHAR(13) + CHAR(10)

END

BEGIN -- COLUMNS --

DECLARE @t TABLE (ORDINAL_POSITION int PRIMARY KEY, COLUMN_NAME nvarchar(128), DATA_TYPE nvarchar(128), CHARACTER_MAXIMUM_LENGTH int, IS_NULLABLE char(3), SOURCE_COLUMN nvarchar(128))
DECLARE @sql nvarchar(max)

IF OBJECT_ID(@BaseTable, 'P') IS NOT NULL
    BEGIN
    SET @sql = '
        SELECT
            c.column_ordinal
            , c.name
            , c.system_type_name
            , NULL AS CHARACTER_MAXIMUM_LENGTH
            , CASE WHEN c.is_nullable = 1 THEN ''YES'' ELSE ''NO'' END AS IS_NULLABLE
            , CASE WHEN c.source_schema = ''' + REPLACE(@UnderlyingTableSchema, '''', '''''') + ''' AND c.source_table = ''' + REPLACE(@UnderlyingTableName, '''', '''''') + ''' THEN c.source_column ELSE NULL END AS SOURCE_COLUMN
        FROM
            sys.dm_exec_describe_first_result_set(N''EXEC ' + REPLACE(@BaseTable, '''', '''''')  +''', NULL, 1) c
        WHERE
            c.is_hidden = 0'

    INSERT INTO @t (ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, SOURCE_COLUMN) EXEC (@sql)
    END
ELSE
    BEGIN
    INSERT INTO @t (ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, SOURCE_COLUMN)
    SELECT
        c.ORDINAL_POSITION
        , c.COLUMN_NAME
        , c.DATA_TYPE
        , c.CHARACTER_MAXIMUM_LENGTH
        , c.IS_NULLABLE
        , c.COLUMN_NAME
    FROM
        INFORMATION_SCHEMA.COLUMNS c
    WHERE
        c.TABLE_SCHEMA = @BaseTableSchema
        AND c.TABLE_NAME = @BaseTableName
    END

END

BEGIN -- FIELD CURSOR --

DECLARE FieldCursor CURSOR FORWARD_ONLY LOCAL READ_ONLY FOR
    SELECT
        c.COLUMN_NAME
        , c.ORDINAL_POSITION
        , c.DATA_TYPE
        , c.CHARACTER_MAXIMUM_LENGTH
        , c.IS_NULLABLE

        , c.COLUMN_EXISTS
        , c.IS_PRIMARY_KEY
        , c.is_identity AS IS_IDENTITY
        , c.is_rowguidcol AS IS_ROWGUIDCOL
        , c.is_computed AS IS_COMPUTED

        , c.LINKED_TABLE_SCHEMA
        , c.LINKED_TABLE_NAME
        , c.LINKED_COLUMN_NAME
    FROM
    (
    SELECT
        c.COLUMN_NAME
        , c.ORDINAL_POSITION
        , c.DATA_TYPE
        , c.CHARACTER_MAXIMUM_LENGTH
        , c.IS_NULLABLE

        , CASE WHEN uc.COLUMN_NAME IS NULL THEN 0 ELSE 1 END COLUMN_EXISTS
        , CASE WHEN ccu.COLUMN_NAME IS NULL THEN 0 ELSE 1 END AS IS_PRIMARY_KEY
        , COALESCE(sc.is_identity, 0) AS is_identity
        , COALESCE(sc.is_rowguidcol, 0) AS is_rowguidcol
        , COALESCE(sc.is_computed, 0) AS is_computed

        , r.LINKED_TABLE_SCHEMA
        , r.LINKED_TABLE_NAME
        , r.LINKED_COLUMN_NAME
    FROM
        @t c

        LEFT OUTER JOIN INFORMATION_SCHEMA.COLUMNS uc ON
            uc.TABLE_SCHEMA = @UnderlyingTableSchema AND uc.TABLE_NAME = @UnderlyingTableName
            AND uc.COLUMN_NAME = c.SOURCE_COLUMN

        LEFT OUTER JOIN sys.columns sc ON sc.[object_id] = OBJECT_ID(@UnderlyingTable) AND sc.name = c.SOURCE_COLUMN

        LEFT OUTER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON
            tc.TABLE_SCHEMA = uc.TABLE_SCHEMA AND tc.TABLE_NAME = uc.TABLE_NAME
            AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
        LEFT OUTER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON
            ccu.TABLE_SCHEMA = uc.TABLE_SCHEMA AND ccu.TABLE_NAME = uc.TABLE_NAME AND ccu.COLUMN_NAME = uc.COLUMN_NAME
            AND tc.CONSTRAINT_SCHEMA = ccu.CONSTRAINT_SCHEMA AND tc.CONSTRAINT_NAME = ccu.CONSTRAINT_NAME

        LEFT OUTER JOIN (
            SELECT
                uc.COLUMN_NAME

                , rcu.TABLE_SCHEMA  AS LINKED_TABLE_SCHEMA
                , rcu.TABLE_NAME    AS LINKED_TABLE_NAME
                , rcu.COLUMN_NAME   AS LINKED_COLUMN_NAME
            FROM
                INFORMATION_SCHEMA.COLUMNS uc

                INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON
                    ccu.TABLE_SCHEMA = uc.TABLE_SCHEMA AND ccu.TABLE_NAME = uc.TABLE_NAME
                    AND ccu.COLUMN_NAME = uc.COLUMN_NAME
                INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON
                    tc.TABLE_SCHEMA = uc.TABLE_SCHEMA AND tc.TABLE_NAME = uc.TABLE_NAME
                    AND tc.CONSTRAINT_SCHEMA = ccu.CONSTRAINT_SCHEMA AND tc.CONSTRAINT_NAME = ccu.CONSTRAINT_NAME
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'

                INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc ON
                    rc.CONSTRAINT_SCHEMA = ccu.CONSTRAINT_SCHEMA AND rc.CONSTRAINT_NAME = ccu.CONSTRAINT_NAME
                INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE rcu ON
                    rcu.CONSTRAINT_SCHEMA = rc.UNIQUE_CONSTRAINT_SCHEMA AND rcu.CONSTRAINT_NAME = rc.UNIQUE_CONSTRAINT_NAME
            WHERE
                uc.TABLE_SCHEMA = @UnderlyingTableSchema AND uc.TABLE_NAME = @UnderlyingTableName
        ) r ON r.COLUMN_NAME = c.COLUMN_NAME
    ) c
    ORDER BY
        c.ORDINAL_POSITION

END

BEGIN -- OPENING CURSOR --

OPEN FieldCursor
FETCH NEXT FROM FieldCursor
INTO
    @COLUMN_NAME
    , @ORDINAL_POSITION
    , @DATA_TYPE
    , @CHARACTER_MAXIMUM_LENGTH
    , @IS_NULLABLE

    , @COLUMN_EXISTS
    , @IS_PRIMARY_KEY
    , @IS_IDENTITY
    , @IS_ROWGUIDCOL
    , @IS_COMPUTED

    , @LINKED_TABLE_SCHEMA
    , @LINKED_TABLE_NAME
    , @LINKED_COLUMN_NAME

END

BEGIN -- GENERATING FIELDS --

WHILE @@FETCH_STATUS = 0
    BEGIN

    SET @QuotedColumnName = xls.get_friendly_column_name(@COLUMN_NAME)

    IF @DATA_TYPE = 'uniqueidentifier'
        SET @SelectFields = @SelectFields + @Tab + ', CAST(t.' + @QuotedColumnName +' AS varchar(56))'
    ELSE
        SET @SelectFields = @SelectFields + @Tab + ', t.' + @QuotedColumnName

    -- SET @SelectFields = @SelectFields + ' AS ' + @QuotedColumnName

    SET @SelectFields = @SelectFields + @CrLf

    SET @ParameterSQL = @Tab + ', @' + xls.get_escaped_parameter_name(@COLUMN_NAME) + ' ' + @DATA_TYPE

    IF ISNULL(@CHARACTER_MAXIMUM_LENGTH, 0) > 0
        SET @ParameterSQL = @ParameterSQL + '(' + CAST(@CHARACTER_MAXIMUM_LENGTH AS nvarchar(10)) + ')'

    IF @IS_NULLABLE = 'YES'
        SET @ParameterSQL = @ParameterSQL + ' = NULL'

    IF @IS_IDENTITY = 0
        SET @InsertParameters = @InsertParameters + @ParameterSQL + @CrLf

    SET @UpdateParameters = @UpdateParameters + @ParameterSQL + @CrLf

    IF @LINKED_COLUMN_NAME IS NOT NULL
        BEGIN
        SET @JoinNumber = @JoinNumber + 1

        SET @SelectJoin = @SelectJoin
                + @Tab + CASE WHEN @IS_NULLABLE = 'YES' THEN 'LEFT OUTER JOIN ' ELSE 'INNER JOIN ' END
                + CASE WHEN xls.get_escaped_parameter_name(@LINKED_TABLE_SCHEMA) = @LINKED_TABLE_SCHEMA
                    AND xls.get_escaped_parameter_name(@LINKED_TABLE_NAME) = @LINKED_TABLE_NAME
                    THEN @LINKED_TABLE_SCHEMA + '.' + @LINKED_TABLE_NAME
                    ELSE QUOTENAME(@LINKED_TABLE_SCHEMA) + '.' + QUOTENAME(@LINKED_TABLE_NAME)
                    END
                + ' t' + CAST(@JoinNumber AS nvarchar(128))
                + ' ON t' + CAST(@JoinNumber AS nvarchar(128)) + '.' + xls.get_friendly_column_name(@LINKED_COLUMN_NAME)
                + ' = t.' + @QuotedColumnName + @CrLf
        END

    IF NOT (@IS_IDENTITY = 1 OR @IS_COMPUTED = 1) AND @COLUMN_EXISTS = 1
        BEGIN
        SET @InsertFields = @InsertFields + @Tab + ', ' + @QuotedColumnName + @CrLf
        SET @InsertValues = @InsertValues + @Tab + ', @' + xls.get_escaped_parameter_name(@COLUMN_NAME) + @CrLf
        END

    IF @IS_PRIMARY_KEY = 1
        BEGIN
        SET @DeleteParameters = @DeleteParameters + @Tab + ', @' + xls.get_escaped_parameter_name(@COLUMN_NAME) + ' ' + @DATA_TYPE

        IF NOT @CHARACTER_MAXIMUM_LENGTH IS NULL
            SET @DeleteParameters = @DeleteParameters + '(' + CAST(@CHARACTER_MAXIMUM_LENGTH AS varchar(10)) + ')'

        SET @DeleteParameters = @DeleteParameters + @CrLf

        SET @DeleteWhere = @DeleteWhere + @Tab + 'AND ' + @QuotedColumnName + ' = @' + xls.get_escaped_parameter_name(@COLUMN_NAME) + @CrLf
        END
    ELSE IF @COLUMN_EXISTS = 1
        BEGIN
        SET @UpdateFields = @UpdateFields + @Tab + ', ' + @QuotedColumnName + ' = @' + xls.get_escaped_parameter_name(@COLUMN_NAME) + @CrLf
        END

    FETCH NEXT FROM FieldCursor
    INTO
        @COLUMN_NAME
        , @ORDINAL_POSITION
        , @DATA_TYPE
        , @CHARACTER_MAXIMUM_LENGTH
        , @IS_NULLABLE

        , @COLUMN_EXISTS
        , @IS_PRIMARY_KEY
        , @IS_IDENTITY
        , @IS_ROWGUIDCOL
        , @IS_COMPUTED

        , @LINKED_TABLE_SCHEMA
        , @LINKED_TABLE_NAME
        , @LINKED_COLUMN_NAME
    END

CLOSE FieldCursor
DEALLOCATE FieldCursor

END

BEGIN -- FINISH FIELDS --

SET @SelectFields = @Tab + ' ' + SUBSTRING(@SelectFields, 6, LEN(@SelectFields))
SET @InsertFields = @Tab + '(' + SUBSTRING(@InsertFields, 6, LEN(@InsertFields)) + @Tab + ')' + @CrLf
SET @InsertValues = @Tab + '(' + SUBSTRING(@InsertValues, 6, LEN(@InsertValues)) + @Tab + ')' + @CrLf
SET @UpdateFields = @Tab       + SUBSTRING(@UpdateFields, 7, LEN(@UpdateFields))
SET @InsertParameters = @Tab + ' ' + SUBSTRING(@InsertParameters, 6, LEN(@InsertParameters))
SET @UpdateParameters = @Tab + ' ' + SUBSTRING(@UpdateParameters, 6, LEN(@UpdateParameters))
SET @DeleteParameters = @Tab + ' ' + SUBSTRING(@DeleteParameters, 6, LEN(@DeleteParameters))
SET @DeleteWhere = @Tab          + SUBSTRING(@DeleteWhere, 9, LEN(@DeleteWhere))

IF CHARINDEX(@InsertParameters, CHAR(13)) = 0 SET @InsertParameters = SUBSTRING(@InsertParameters, 3, LEN(@InsertParameters))
IF CHARINDEX(@UpdateParameters, CHAR(13)) = 0 SET @UpdateParameters = SUBSTRING(@UpdateParameters, 3, LEN(@UpdateParameters))
IF CHARINDEX(@DeleteParameters, CHAR(13)) = 0 SET @DeleteParameters = SUBSTRING(@DeleteParameters, 3, LEN(@DeleteParameters))

END

BEGIN -- CHANGE HANDLER --

DECLARE @ChangeWhere nvarchar(max) = ''

SET @ChangeWhere = STUFF((
        SELECT
            ' AND ' + xls.get_friendly_column_name(c.SOURCE_COLUMN) + ' = @' + xls.get_escaped_parameter_name(c.COLUMN_NAME)
        FROM
            INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
            INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON
                kcu.CONSTRAINT_SCHEMA = tc.CONSTRAINT_SCHEMA AND kcu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
            INNER JOIN @t c ON c.SOURCE_COLUMN = kcu.COLUMN_NAME
        WHERE
            tc.TABLE_SCHEMA = @UnderlyingTableSchema
            AND tc.TABLE_NAME = @UnderlyingTableName
            AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
        ORDER BY
            c.ORDINAL_POSITION
        FOR XML PATH('')
    ), 1, 5, '')

DECLARE @HasDates bit
DECLARE @HasNumbers bit

SELECT
    @HasDates =    MAX(CASE WHEN c.DATETIME_PRECISION IS NULL THEN 0 ELSE 1 END)
    , @HasNumbers = MAX(CASE WHEN c.NUMERIC_PRECISION IS NULL THEN 0 WHEN c.DATA_TYPE IN ('bit') THEN 1 ELSE 1 END)
FROM
    INFORMATION_SCHEMA.COLUMNS c
WHERE
    c.TABLE_SCHEMA = @UnderlyingTableSchema AND c.TABLE_NAME = @UnderlyingTableName
    OR (c.TABLE_SCHEMA = @BaseTableSchema AND c.TABLE_NAME = @BaseTableName)

DECLARE @termColumnName nvarchar(128) = '@ColumnName'
DECLARE @termCellValue nvarchar(128) = '@CellValue'
DECLARE @termCellNumberValue nvarchar(128) = '@CellNumberValue'
DECLARE @termCellDateTimeValue nvarchar(128) = '@CellDateTimeValue'
DECLARE @termChangedCellAction nvarchar(128) = '@ChangedCellAction'
DECLARE @termChangedCellCount nvarchar(128) = '@ChangedCellCount'
DECLARE @termChangedCellIndex nvarchar(128) = '@ChangedCellIndex'
DECLARE @termDataLanguage nvarchar(128) = '@DataLanguage'

IF @MySqlStyle = 1
    BEGIN
    SET @termColumnName = '@column_name'
    SET @termCellValue = '@cell_value'
    SET @termCellNumberValue = '@cell_number_value'
    SET @termCellDateTimeValue = '@cell_datetime_value'
    SET @termChangedCellAction = '@changed_cell_ction'
    SET @termChangedCellCount = '@changed_cell_count'
    SET @termChangedCellIndex = '@changed_cell_index'
    SET @termDataLanguage = '@data_language'
    END

DECLARE @ContextParameters nvarchar(max) =
    '    ' + @termColumnName + ' nvarchar(128) = NULL' + @CrLf
    + '    , ' + @termCellValue + ' nvarchar(255) = NULL' + @CrLf
    + CASE WHEN @HasNumbers = 1 THEN '    , ' + @termCellNumberValue + ' float = NULL' + @CrLf ELSE '' END
    + CASE WHEN @HasDates = 1 THEN '    , ' + @termCellDateTimeValue + ' datetime = NULL' + @CrLf ELSE '' END
    + '    , ' + @termChangedCellAction + ' nvarchar(255) = NULL' + @CrLf
    + '    , ' + @termChangedCellCount + ' int = NULL' + @CrLf
    + '    , ' + @termChangedCellIndex + ' int = NULL' + @CrLf
    + '    , ' + @termDataLanguage + ' varchar(10) = NULL' + @CrLf

DECLARE @ChangeParameters nvarchar(max)

SELECT @ChangeParameters = STUFF((
    SELECT
        @CrLf + '    , @' + xls.get_escaped_parameter_name(c.COLUMN_NAME)
        + ' ' + c.DATA_TYPE
        + CASE WHEN c.CHARACTER_MAXIMUM_LENGTH IS NULL THEN '' ELSE '(' + CAST(c.CHARACTER_MAXIMUM_LENGTH AS varchar(5)) + ')' END
        + ' = NULL'
    FROM
        @t c
    WHERE
        NOT c.DATA_TYPE IN ('geography', 'geometry', 'image')
    ORDER BY
        c.ORDINAL_POSITION
    FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '')

DECLARE @ChangeBody nvarchar(max)

SELECT @ChangeBody = COALESCE(STUFF((
    SELECT
        'ELSE IF ' + @termColumnName + ' = N''' + REPLACE(c.COLUMN_NAME, '''', '''''') + '''' + @CrLf
        + @Tab
        + CASE
            WHEN sc.name IS NULL THEN 'RETURN'
            WHEN sc.is_identity = 1 OR sc.is_computed = 1 THEN 'RETURN'
            WHEN @ChangeWhere IS NULL THEN 'RETURN'
            ELSE
                'UPDATE ' + @UnderlyingTable
                + ' SET '
                + xls.get_friendly_column_name(c.COLUMN_NAME)
                + ' = '
                + CASE
                    WHEN t.name IN ('date', 'time', 'datetime', 'datetime2', 'smalldatetime', 'datetimeoffset') THEN @termCellDateTimeValue
                    WHEN t.name IN ('bit', 'tinyint', 'smallint', 'int', 'bigint', 'real', 'float', 'money', 'smallmoney', 'decimal', 'numeric') THEN @termCellNumberValue
                    ELSE @termCellValue
                    END
                + ' WHERE '
                + @ChangeWhere
            END
        + @CrLf + @CrLf
    FROM
        @t c
        LEFT OUTER JOIN sys.columns sc
            ON sc.[object_id] = OBJECT_ID(@UnderlyingTable) AND sc.name = c.SOURCE_COLUMN
        LEFT OUTER JOIN sys.types t ON t.user_type_id = sc.user_type_id
    WHERE
        NOT c.DATA_TYPE IN ('timestamp', 'geography', 'geometry', 'image')
    ORDER BY
        c.ORDINAL_POSITION
    FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 5, ''), '')

END

BEGIN -- PROCEDURE NAMES --

DECLARE @SelectProcedureName nvarchar(255)
DECLARE @InsertProcedureName nvarchar(255)
DECLARE @UpdateProcedureName nvarchar(255)
DECLARE @DeleteProcedureName nvarchar(255)
DECLARE @ChangeProcedureName nvarchar(255)

IF @SelectObjectName IS NULL
    BEGIN
    IF OBJECT_ID(@BaseTable, 'V') IS NOT NULL
        AND @GenerateSelectObject = 0
        BEGIN
        SET @SelectObjectSchema = @BaseTableSchema
        SET @SelectObjectName = @BaseTableName
        END
    ELSE IF OBJECT_ID(@BaseTable, 'P') IS NOT NULL
        AND @GenerateSelectObject = 0
        BEGIN
        SET @SelectObjectSchema = @BaseTableSchema
        SET @SelectObjectName = @BaseTableName
        END
    ELSE
        BEGIN
        IF LOWER(@BaseTableName) = @BaseTableName
            SET @SelectObjectName = CASE WHEN @GenerateSelectAsView = 1 THEN 'view_' ELSE 'usp_' END + @BaseTableName
        ELSE
            SET @SelectObjectName = CASE WHEN @GenerateSelectAsView = 1 THEN 'view' ELSE 'usp' END + @BaseTableName
        END
    END

IF xls.get_escaped_parameter_name(@SelectObjectSchema) = @SelectObjectSchema
    AND xls.get_escaped_parameter_name(@SelectObjectName) = @SelectObjectName
    BEGIN
    SET @SelectProcedureName = @SelectObjectSchema + '.' + @SelectObjectName
    SET @InsertProcedureName = @SelectObjectSchema + '.' + @SelectObjectName + '_insert'
    SET @UpdateProcedureName = @SelectObjectSchema + '.' + @SelectObjectName + '_update'
    SET @DeleteProcedureName = @SelectObjectSchema + '.' + @SelectObjectName + '_delete'
    SET @ChangeProcedureName = @SelectObjectSchema + '.' + @SelectObjectName + '_change'
    END
ELSE
    BEGIN
    SET @SelectProcedureName = QUOTENAME(@SelectObjectSchema) + '.' + QUOTENAME(@SelectObjectName)
    SET @InsertProcedureName = QUOTENAME(@SelectObjectSchema) + '.' + QUOTENAME(@SelectObjectName + '_insert')
    SET @UpdateProcedureName = QUOTENAME(@SelectObjectSchema) + '.' + QUOTENAME(@SelectObjectName + '_update')
    SET @DeleteProcedureName = QUOTENAME(@SelectObjectSchema) + '.' + QUOTENAME(@SelectObjectName + '_delete')
    SET @ChangeProcedureName = QUOTENAME(@SelectObjectSchema) + '.' + QUOTENAME(@SelectObjectName + '_change')
    END

END

BEGIN -- HEADERS --

DECLARE @SelectHeaderText nvarchar(max) = '
-- =============================================
-- Author:      ' + xls.get_translated_string('<Author>', 'en') + '
-- Release:     ' + xls.get_translated_string('<Release>', 'en') + ', ' + CONVERT(char(10), GETDATE(), 120)

DECLARE @ChangeHeaderText nvarchar(max) = @SelectHeaderText + '
-- Description: The procedure processes cell changes of ' + @SelectObjectSchema + '.' + @SelectObjectName + '
-- =============================================

'

SET @SelectHeaderText = @SelectHeaderText + '
-- Description: The procedure selects data from ' + @BaseTableSchema + '.' + @BaseTableName + '
-- =============================================

'

DECLARE @InsertHeaderText nvarchar(max) = REPLACE(@SelectHeaderText, 'selects data from', 'inserts data into')
DECLARE @UpdateHeaderText nvarchar(max) = REPLACE(@SelectHeaderText, 'selects data from', 'updates data of')
DECLARE @DeleteHeaderText nvarchar(max) = REPLACE(@SelectHeaderText, 'selects data from', 'deleted data from')

IF @GenerateSelectAsView = 1
    SET @SelectHeaderText = REPLACE(@SelectHeaderText, 'The procedure', 'The view')

END

BEGIN -- PROCEDURE DEFINITIONS --

DECLARE @DeleteSelectSQL nvarchar(max) =
    CASE WHEN @GenerateSelectAsView = 1 THEN
    'IF OBJECT_ID(N''' + REPLACE(@SelectProcedureName, '''', '''''') + ''', ''V'') IS NOT NULL' + @CrLf
    + @Tab + 'DROP VIEW '+ @SelectProcedureName + @CrLf
    ELSE
    'IF OBJECT_ID(N''' + REPLACE(@SelectProcedureName, '''', '''''') + ''', ''P'') IS NOT NULL' + @CrLf
    + @Tab + 'DROP PROCEDURE '+ @SelectProcedureName + @CrLf
    END

DECLARE @DeleteInsertSQL nvarchar(max) =
    'IF OBJECT_ID(N''' + REPLACE(@InsertProcedureName, '''', '''''') + ''', ''P'') IS NOT NULL' + @CrLf
    + @Tab + 'DROP PROCEDURE '+ @InsertProcedureName + @CrLf

DECLARE @DeleteUpdateSQL nvarchar(max) =
    'IF OBJECT_ID(N''' + REPLACE(@UpdateProcedureName, '''', '''''') + ''', ''P'') IS NOT NULL' + @CrLf
    + @Tab + 'DROP PROCEDURE '+ @UpdateProcedureName + @CrLf

DECLARE @DeleteDeleteSQL nvarchar(max) =
    'IF OBJECT_ID(N''' + REPLACE(@DeleteProcedureName, '''', '''''') + ''', ''P'') IS NOT NULL' + @CrLf
    + @Tab + 'DROP PROCEDURE '+ @DeleteProcedureName + @CrLf

DECLARE @DeleteChangeSQL nvarchar(max) =
    'IF OBJECT_ID(N''' + REPLACE(@ChangeProcedureName, '''', '''''') + ''', ''P'') IS NOT NULL' + @CrLf
    + @Tab + 'DROP PROCEDURE '+ @ChangeProcedureName + @CrLf

DECLARE @SelectProcedureSQL nvarchar(max) = ''
        + @SelectHeaderText
        + CASE WHEN @GenerateSelectAsView = 1 THEN
          'CREATE' + ' VIEW ' + @SelectProcedureName + @CrLf
          ELSE
          'CREATE' + ' PROCEDURE ' + @SelectProcedureName + @CrLf
          END
        + 'AS' + @CrLf
        + CASE WHEN @GenerateSelectAsView = 1 THEN '' ELSE 'BEGIN' + @CrLf + @CrLf + 'SET NOCOUNT ON' + @CrLf END
        + @CrLf
        + 'SELECT' + @CrLf
        + @SelectFields
        + 'FROM'+ @CrLf
        + @Tab + @BaseTable + ' t' + @CrLf
        + @SelectJoin
        + @CrLf
        + CASE WHEN @GenerateSelectAsView = 1 THEN '' ELSE 'END' + @CrLf END
        + @CrLf

DECLARE @InsertProcedureSQL nvarchar(max) = ''
        + @InsertHeaderText
        + 'CREATE' + ' PROCEDURE ' + @InsertProcedureName + @CrLf
        + @InsertParameters
        + 'AS' + @CrLf
        + 'BEGIN' + @CrLf
        + @CrLf
        + 'INSERT INTO ' + @UnderlyingTable + @CrLf
        + @InsertFields
        + 'VALUES' + @CrLf
        + @InsertValues
        + @CrLf
        + 'END' + @CrLf + @CrLf

DECLARE @UpdateProcedureSQL nvarchar(max) = ''
        + @UpdateHeaderText
        + 'CREATE' + ' PROCEDURE ' + @UpdateProcedureName + @CrLf
        + @UpdateParameters
        + 'AS' + @CrLf
        + 'BEGIN' + @CrLf
        + @CrLf
        + 'UPDATE ' + @UnderlyingTable + @CrLf
        + 'SET' + @CrLf
        + @UpdateFields
        + 'WHERE' + @CrLf
        + @DeleteWhere
        + @CrLf
        + 'END' + @CrLf + @CrLf

DECLARE @DeleteProcedureSQL nvarchar(max) = ''
        + @DeleteHeaderText
        + 'CREATE' + ' PROCEDURE ' + @DeleteProcedureName + @CrLf
        + @DeleteParameters
        + 'AS' + @CrLf
        + 'BEGIN' + @CrLf
        + @CrLf
        + 'DELETE FROM ' + @UnderlyingTable + @CrLf
        + 'WHERE' + @CrLf
        + @DeleteWhere
        + @CrLf
        + 'END' + @CrLf + @CrLf

DECLARE @ChangeProcedureSql nvarchar(max) = ''
        + @ChangeHeaderText
        + 'CREATE' + ' PROCEDURE ' + @ChangeProcedureName + @CrLf
        + @ContextParameters
        + @ChangeParameters + @CrLf
        + 'AS' + @CrLf
        + 'BEGIN' + @CrLf
        + @CrLf
        + 'SET NOCOUNT ON' + @CrLf
        + @CrLf
        + @ChangeBody
        + 'END' + @CrLf
        + @CrLf

END

BEGIN -- HELP --

DECLARE @GoLine nvarchar(10) = 'GO' + @CrLf + @CrLf

DECLARE @Help nvarchar(max) =
    CASE WHEN xls.get_translated_string('<Author>', 'en') = '<Author>' THEN
        '-- You may define the <Author> and <Release> values in the xls.translations table:' + @CrLf
        + @CrLf
        + '-- TABLE_SCHEMA TABLE_NAME COLUMN_NAME LANGUAGE_NAME TRANSLATED_NAME' + @CrLf
        + '-- ------------ ---------- ----------- ------------- ---------------' + @CrLf
        + '-- xls          strings    <Author>    en            <Your value>' + @CrLf
        + '-- xls          strings    <Release>   en            <Your value>' + @CrLf
        + @CrLf
        ELSE '' END

    + CASE WHEN @GenerateEditProcedures = 1 THEN
        + '-- The SaveToDB add-in uses the insert, update, and delete procedures for ' +  @SelectProcedureName + @CrLf
        + '-- automatically due to the same name with the special _insert, _update, and _delete suffixes.'+ @CrLf
        + @CrLf
        + '-- You may use these edit procedures with appropriate objects using the configuration like this:'+ @CrLf
        + @CrLf
        + '-- INSERT INTO xls.objects (TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE, INSERT_OBJECT, UPDATE_OBJECT, DELETE_OBJECT)' + @CrLf
        + '--     VALUES('
        + 'N''' + REPLACE(@SelectObjectSchema, '''', '''''') + ''', N''' + @SelectObjectName + ''', '''
        +  CASE WHEN @GenerateSelectAsView = 1 THEN 'VIEW' ELSE 'PROCEDURE' END + ''', '
        + 'N''' + REPLACE(@InsertProcedureName, '''', '''''') + ''', N''' + @UpdateProcedureName + ''', N''' + @DeleteProcedureName + ''')' + @CrLf
        + @CrLf
        ELSE '' END

    + CASE WHEN @GenerateChangeHandler = 1 THEN
        + '-- The SaveToDB add-in attaches ' + @ChangeProcedureName + ' as a change handler for' + @CrLf
        + '-- ' +  @SelectProcedureName + ' automatically due to the same name with the _change suffix.'+ @CrLf
        + @CrLf
        + '-- You may attach it to any object using the configuration like this:'+ @CrLf
        + @CrLf
        + '-- INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE)' + @CrLf
        + '--     VALUES('
        + 'N''' + REPLACE(@SelectObjectSchema, '''', '''''') + ''', N''' + @SelectObjectName + ''', ''Change'', '
        + 'N''' + REPLACE(@SelectObjectSchema, '''', '''''') + ''', N''' + @BaseTableName + '_change'', ''PROCEDURE'')' + @CrLf
        + @CrLf
        ELSE '' END

    + @GoLine

END

BEGIN -- EXECUTE GENERATED CODES --

IF @SelectCommands IS NULL AND @PrintCommands IS NULL SET @SelectCommands = 1

IF @PrintCommands = 1
    BEGIN

    RAISERROR(@Help, 0, 1) WITH NOWAIT

    IF @GenerateSelectObject = 1
        BEGIN
        RAISERROR(@DeleteSelectSQL, 0, 1) WITH NOWAIT
        RAISERROR(@GoLine, 0, 1) WITH NOWAIT
        END

    IF @GenerateEditProcedures = 1
        BEGIN
        RAISERROR(@DeleteInsertSQL, 0, 1) WITH NOWAIT
        RAISERROR(@GoLine, 0, 1) WITH NOWAIT
        RAISERROR(@DeleteUpdateSQL, 0, 1) WITH NOWAIT
        RAISERROR(@GoLine, 0, 1) WITH NOWAIT
        RAISERROR(@DeleteDeleteSQL, 0, 1) WITH NOWAIT
        RAISERROR(@GoLine, 0, 1) WITH NOWAIT
        END

    IF @GenerateChangeHandler = 1
        BEGIN
        RAISERROR(@DeleteChangeSQL, 0, 1) WITH NOWAIT
        RAISERROR(@GoLine, 0, 1) WITH NOWAIT
        END

    IF @GenerateSelectObject = 1
        BEGIN
        RAISERROR(@SelectProcedureSQL, 0, 1) WITH NOWAIT
        RAISERROR(@GoLine, 0, 1) WITH NOWAIT
        END

    IF @GenerateEditProcedures = 1
        BEGIN
        RAISERROR(@InsertProcedureSQL, 0, 1) WITH NOWAIT
        RAISERROR(@GoLine, 0, 1) WITH NOWAIT
        RAISERROR(@UpdateProcedureSQL, 0, 1) WITH NOWAIT
        RAISERROR(@GoLine, 0, 1) WITH NOWAIT
        RAISERROR(@DeleteProcedureSQL, 0, 1) WITH NOWAIT
        RAISERROR(@GoLine, 0, 1) WITH NOWAIT
        END

    IF @GenerateChangeHandler = 1
        BEGIN
        RAISERROR(@ChangeProcedureSQL, 0, 1) WITH NOWAIT
        RAISERROR(@GoLine, 0, 1) WITH NOWAIT
        END
    END

IF @ExecuteScript = 1
    BEGIN
    IF @RecreateProceduresIfExist = 1
        BEGIN
        IF @GenerateSelectObject = 1
            EXEC (@DeleteSelectSQL)
        IF @GenerateEditProcedures = 1
            BEGIN
            EXEC (@DeleteInsertSQL)
            EXEC (@DeleteUpdateSQL)
            EXEC (@DeleteDeleteSQL)
            END
        IF @GenerateChangeHandler = 1
            EXEC (@DeleteChangeSQL)
        END

    IF @GenerateSelectObject = 1 AND OBJECT_ID(@SelectProcedureName, 'P') IS NULL
        EXEC (@SelectProcedureSQL)

    IF @GenerateEditProcedures = 1 AND OBJECT_ID(@InsertProcedureName, 'P') IS NULL
        EXEC (@InsertProcedureSQL)
    IF @GenerateEditProcedures = 1 AND OBJECT_ID(@UpdateProcedureName, 'P') IS NULL
        EXEC (@UpdateProcedureSQL)
    IF @GenerateEditProcedures = 1 AND OBJECT_ID(@DeleteProcedureName, 'P') IS NULL
        EXEC (@DeleteProcedureSQL)

    IF @GenerateChangeHandler = 1 AND OBJECT_ID(@ChangeProcedureName, 'P') IS NULL
        EXEC (@ChangeProcedureSQL)

    IF @SelectCommands = 1
        SELECT 'Created' AS [message]
    END

ELSE IF @SelectCommands = 1
    BEGIN
    SELECT
        @Help
        + CASE WHEN @GenerateSelectObject = 1 THEN
            @DeleteSelectSQL
            + @GoLine
            ELSE '' END
        + CASE WHEN @GenerateEditProcedures = 1 THEN
            @DeleteInsertSQL
            + @GoLine
            + @DeleteUpdateSQL
            + @GoLine
            + @DeleteDeleteSQL
            + @GoLine
            ELSE '' END
        + CASE WHEN @GenerateChangeHandler = 1 THEN
            @DeleteChangeSQL
            + @GoLine
            ELSE '' END
        + CASE WHEN @GenerateSelectObject = 1 THEN
            @SelectProcedureSQL
            + @GoLine
            ELSE '' END
        + CASE WHEN @GenerateEditProcedures = 1 THEN
            @InsertProcedureSQL
            + @GoLine
            + @UpdateProcedureSQL
            + @GoLine
            + @DeleteProcedureSQL
            + @GoLine
            ELSE '' END
        + CASE WHEN @GenerateChangeHandler = 1 THEN
            @ChangeProcedureSQL
            + @GoLine
            ELSE '' END
        AS [message]
    END

END

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Deletes the translation
-- =============================================

CREATE PROCEDURE [xls].[xl_delete_translation]
    @TABLE_SCHEMA nvarchar(128) = NULL
    , @TABLE_NAME nvarchar(128) = NULL
    , @COLUMN_NAME nvarchar(255) = NULL
    , @LANGUAGE_NAME varchar(10) = NULL
AS
BEGIN

DELETE FROM xls.translations
WHERE
    COALESCE(TABLE_SCHEMA, '') = COALESCE(@TABLE_SCHEMA, '')
    AND COALESCE(TABLE_NAME, '') = COALESCE(@TABLE_NAME, '')
    AND COALESCE(COLUMN_NAME, '') = COALESCE(@COLUMN_NAME, '')
    AND LANGUAGE_NAME = @LANGUAGE_NAME

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Exports SaveToDB Framework data
-- =============================================

CREATE PROCEDURE [xls].[xl_export_settings]
    @part tinyint = NULL
    , @as_exec_import bit = 0
    , @sort_by_names bit = 0
    , @schema nvarchar(128) = NULL
    , @language varchar(10) = NULL
    , @use_go bit = 0
AS
BEGIN

SET NOCOUNT ON;

IF @as_exec_import IS NULL SET @as_exec_import = 0

DECLARE @app_schema_only bit = 0

IF @schema = 'x'
    BEGIN
    SET @schema = NULL
    SET @app_schema_only = 1
    END

DECLARE @GoLine nvarchar(10) = CASE WHEN @use_go = 1 THEN 'GO' + CHAR(13) + CHAR(10) ELSE '' END

DECLARE @cmd0 nvarchar(1024), @cmd1 nvarchar(1024), @cmd2 nvarchar(1024), @cmd3 nvarchar(1024), @cmd4 nvarchar(1024), @cmd5 nvarchar(1024)

IF @as_exec_import = 1
    BEGIN
    SET @cmd0 = ';'
    SET @cmd1 = 'EXEC xls.xl_import_objects '
    SET @cmd2 = 'EXEC xls.xl_import_handlers '
    SET @cmd3 = 'EXEC xls.xl_import_translations '
    SET @cmd4 = 'EXEC xls.xl_import_formats '
    SET @cmd5 = 'EXEC xls.xl_import_workbooks '
    END
ELSE
    BEGIN
    SET @cmd0 = ');'
    SET @cmd1 = 'INSERT INTO xls.objects (TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE, TABLE_CODE, INSERT_OBJECT, UPDATE_OBJECT, DELETE_OBJECT) VALUES ('
    SET @cmd2 = 'INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES ('
    SET @cmd3 = 'INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES ('
    SET @cmd4 = 'INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES ('
    SET @cmd5 = 'INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES ('
    END

SELECT
    t.command
FROM
    (
SELECT
    1 AS part
    , CASE WHEN @sort_by_names = 1 THEN ROW_NUMBER() OVER(ORDER BY TABLE_SCHEMA, TABLE_NAME) ELSE ID END AS ID
    , @cmd1
           + CASE WHEN TABLE_SCHEMA              IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TABLE_SCHEMA, '''', '''''') + '''' END
    + ', ' + CASE WHEN TABLE_NAME                IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TABLE_NAME, '''', '''''') + '''' END
    + ', ' + CASE WHEN TABLE_TYPE                IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TABLE_TYPE, '''', '''''') + '''' END
    + ', ' + CASE WHEN TABLE_CODE                IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TABLE_CODE, '''', '''''') + '''' END
    + ', ' + CASE WHEN INSERT_OBJECT             IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(INSERT_OBJECT, '''', '''''') + '''' END
    + ', ' + CASE WHEN UPDATE_OBJECT             IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(UPDATE_OBJECT, '''', '''''') + '''' END
    + ', ' + CASE WHEN DELETE_OBJECT             IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(DELETE_OBJECT, '''', '''''') + '''' END
    + @cmd0 AS command
FROM
    xls.objects
WHERE
    TABLE_SCHEMA LIKE COALESCE(@schema, TABLE_SCHEMA)
    AND (@app_schema_only = 0 OR NOT TABLE_SCHEMA IN ('xls'))

UNION ALL SELECT 2 AS part, -1 AS ID, @GoLine AS command
    WHERE EXISTS(
        SELECT
            ID
        FROM
            xls.objects
        WHERE
            TABLE_SCHEMA LIKE COALESCE(@schema, TABLE_SCHEMA)
            AND (@app_schema_only = 0 OR NOT TABLE_SCHEMA IN ('xls'))
    )

UNION ALL
SELECT
    2 AS part
    , CASE WHEN @sort_by_names = 1 THEN ROW_NUMBER() OVER(ORDER BY TABLE_SCHEMA, TABLE_NAME, EVENT_NAME, CASE WHEN COLUMN_NAME IS NULL THEN 0 ELSE 1 END, COLUMN_NAME, HANDLER_SCHEMA, HANDLER_NAME, MENU_ORDER) ELSE ID END AS ID
    , @cmd2
           + CASE WHEN TABLE_SCHEMA              IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TABLE_SCHEMA, '''', '''''') + '''' END
    + ', ' + CASE WHEN TABLE_NAME                IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TABLE_NAME, '''', '''''') + '''' END
    + ', ' + CASE WHEN COLUMN_NAME               IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(COLUMN_NAME, '''', '''''') + '''' END
    + ', ' + CASE WHEN EVENT_NAME                IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(EVENT_NAME, '''', '''''') + '''' END
    + ', ' + CASE WHEN HANDLER_SCHEMA            IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(HANDLER_SCHEMA, '''', '''''') + '''' END
    + ', ' + CASE WHEN HANDLER_NAME              IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(HANDLER_NAME, '''', '''''') + '''' END
    + ', ' + CASE WHEN HANDLER_TYPE              IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(HANDLER_TYPE, '''', '''''') + '''' END
    + ', ' + CASE WHEN HANDLER_CODE              IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(HANDLER_CODE, '''', '''''') + '''' END
    + ', ' + CASE WHEN TARGET_WORKSHEET          IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TARGET_WORKSHEET, '''', '''''') + '''' END
    + ', ' + CASE WHEN MENU_ORDER                IS NULL THEN 'NULL' ELSE CAST(MENU_ORDER AS nvarchar(128))  END
    + ', ' + CASE WHEN EDIT_PARAMETERS           IS NULL THEN 'NULL' ELSE CAST(EDIT_PARAMETERS AS nvarchar(128))  END
    + @cmd0 AS command
FROM
    xls.handlers
WHERE
    TABLE_SCHEMA LIKE COALESCE(@schema, TABLE_SCHEMA)
    AND (@app_schema_only = 0 OR NOT TABLE_SCHEMA IN ('xls'))

UNION ALL SELECT 3 AS part, -1 AS ID, @GoLine AS command
    WHERE EXISTS(
        SELECT
            ID
        FROM
            xls.handlers
        WHERE
            TABLE_SCHEMA LIKE COALESCE(@schema, TABLE_SCHEMA)
            AND (@app_schema_only = 0 OR NOT TABLE_SCHEMA IN ('xls'))
    )

UNION ALL
SELECT
    3 AS part
    , CASE WHEN @sort_by_names = 1 THEN ROW_NUMBER() OVER(ORDER BY LANGUAGE_NAME, CASE WHEN COLUMN_NAME IS NULL THEN 0 ELSE 1 END, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME) ELSE ID END AS ID
    , @cmd3
           + CASE WHEN TABLE_SCHEMA              IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TABLE_SCHEMA, '''', '''''') + '''' END
    + ', ' + CASE WHEN TABLE_NAME                IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TABLE_NAME, '''', '''''') + '''' END
    + ', ' + CASE WHEN COLUMN_NAME               IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(COLUMN_NAME, '''', '''''') + '''' END
    + ', ' + CASE WHEN LANGUAGE_NAME             IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(LANGUAGE_NAME, '''', '''''') + '''' END
    + ', ' + CASE WHEN TRANSLATED_NAME           IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TRANSLATED_NAME, '''', '''''') + '''' END
    + ', ' + CASE WHEN TRANSLATED_DESC           IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TRANSLATED_DESC, '''', '''''') + '''' END
    + ', ' + CASE WHEN TRANSLATED_COMMENT        IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TRANSLATED_COMMENT, '''', '''''') + '''' END
    + @cmd0 AS command
FROM
    xls.translations
WHERE
    TABLE_SCHEMA LIKE COALESCE(@schema, TABLE_SCHEMA)
    AND COALESCE(LANGUAGE_NAME, '') = COALESCE(@language, LANGUAGE_NAME, '')
    AND (@app_schema_only = 0 OR NOT TABLE_SCHEMA IN ('xls'))

UNION ALL SELECT 4 AS part, -1 AS ID, @GoLine AS command
    WHERE EXISTS(
        SELECT
            ID
        FROM
            xls.translations
        WHERE
            TABLE_SCHEMA LIKE COALESCE(@schema, TABLE_SCHEMA)
            AND COALESCE(LANGUAGE_NAME, '') = COALESCE(@language, LANGUAGE_NAME, '')
            AND (@app_schema_only = 0 OR NOT TABLE_SCHEMA IN ('xls'))
    )

UNION ALL
SELECT
    4 AS part
    , CASE WHEN @sort_by_names = 1 THEN ROW_NUMBER() OVER(ORDER BY TABLE_SCHEMA, TABLE_NAME) ELSE ID END AS ID
    , @cmd4
           + CASE WHEN TABLE_SCHEMA              IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TABLE_SCHEMA, '''', '''''') + '''' END
    + ', ' + CASE WHEN TABLE_NAME                IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TABLE_NAME, '''', '''''') + '''' END
    + ', ' + CASE WHEN TABLE_EXCEL_FORMAT_XML    IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(CAST(TABLE_EXCEL_FORMAT_XML AS nvarchar(max)), '''', '''''') + '''' END
    + @cmd0 AS command
FROM
    xls.formats
WHERE
    TABLE_SCHEMA LIKE COALESCE(@schema, TABLE_SCHEMA)
    AND (@app_schema_only = 0 OR NOT TABLE_SCHEMA IN ('xls'))

UNION ALL SELECT 5 AS part, -1 AS ID, @GoLine AS command
    WHERE EXISTS(
        SELECT
            ID
        FROM
            xls.formats
        WHERE
            TABLE_SCHEMA LIKE COALESCE(@schema, TABLE_SCHEMA)
            AND (@app_schema_only = 0 OR NOT TABLE_SCHEMA IN ('xls'))
    )

UNION ALL
SELECT
    5 AS part
    , CASE WHEN @sort_by_names = 1 THEN ROW_NUMBER() OVER(ORDER BY NAME) ELSE ID END AS ID
    , @cmd5
           + CASE WHEN NAME                      IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(NAME, '''', '''''') + '''' END
    + ', ' + CASE WHEN TEMPLATE                  IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TEMPLATE, '''', '''''') + '''' END
    + ', ' + CASE WHEN DEFINITION                IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(DEFINITION, '''', '''''') + '''' END
    + ', ' + CASE WHEN TABLE_SCHEMA              IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TABLE_SCHEMA, '''', '''''') + '''' END
    + @cmd0 AS command
FROM
    xls.workbooks
WHERE
    COALESCE(TABLE_SCHEMA, '') LIKE COALESCE(@schema, TABLE_SCHEMA, '')
    AND (@app_schema_only = 0 OR NOT TABLE_SCHEMA IN ('xls'))

UNION ALL SELECT 6 AS part, -1 AS ID, @GoLine AS command
    WHERE EXISTS(
        SELECT
            ID
        FROM
            xls.workbooks
        WHERE
            TABLE_SCHEMA LIKE COALESCE(@schema, TABLE_SCHEMA)
            AND (@app_schema_only = 0 OR NOT TABLE_SCHEMA IN ('xls'))
    )
    ) t
WHERE
    t.part = COALESCE(@part, t.part)
    AND (@part IS NULL OR NOT t.command = '')
ORDER BY
    t.part
    , t.ID

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Imports SaveToDB Framework formats
-- =============================================

CREATE PROCEDURE [xls].[xl_import_formats]
    @TABLE_SCHEMA nvarchar(128) = NULL
    , @TABLE_NAME nvarchar(128) = NULL
    , @TABLE_EXCEL_FORMAT_XML xml = NULL
AS
BEGIN

SET NOCOUNT ON;

UPDATE xls.formats
SET
    TABLE_EXCEL_FORMAT_XML = @TABLE_EXCEL_FORMAT_XML
WHERE
    TABLE_SCHEMA = @TABLE_SCHEMA
    AND TABLE_NAME = @TABLE_NAME

IF @@ROWCOUNT = 0
    INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML)
        VALUES (@TABLE_SCHEMA, @TABLE_NAME, @TABLE_EXCEL_FORMAT_XML)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Imports SaveToDB Framework handlers
-- =============================================

CREATE PROCEDURE [xls].[xl_import_handlers]
    @TABLE_SCHEMA nvarchar(20) = NULL
    , @TABLE_NAME nvarchar(128) = NULL
    , @COLUMN_NAME nvarchar(128) = NULL
    , @EVENT_NAME varchar(25) = NULL
    , @HANDLER_SCHEMA nvarchar(20) = NULL
    , @HANDLER_NAME nvarchar(128) = NULL
    , @HANDLER_TYPE nvarchar(25) = NULL
    , @HANDLER_CODE nvarchar(max) = NULL
    , @TARGET_WORKSHEET nvarchar(128) = NULL
    , @MENU_ORDER int = NULL
    , @EDIT_PARAMETERS bit = NULL
AS
BEGIN

SET NOCOUNT ON;

UPDATE xls.handlers
SET
    HANDLER_CODE = @HANDLER_CODE
    , TARGET_WORKSHEET = @TARGET_WORKSHEET
    , MENU_ORDER = @MENU_ORDER
    , EDIT_PARAMETERS = @EDIT_PARAMETERS
WHERE
    TABLE_SCHEMA = @TABLE_SCHEMA
    AND TABLE_NAME = @TABLE_NAME
    AND COALESCE(COLUMN_NAME, '') = COALESCE(@COLUMN_NAME, '')
    AND EVENT_NAME = @EVENT_NAME
    AND COALESCE(HANDLER_SCHEMA, '') = COALESCE(@HANDLER_SCHEMA, '')
    AND COALESCE(HANDLER_NAME, '') = COALESCE(@HANDLER_NAME, '')
    AND COALESCE(HANDLER_TYPE, '') = COALESCE(@HANDLER_TYPE, '')

IF @@ROWCOUNT = 0
    INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS)
        VALUES (@TABLE_SCHEMA, @TABLE_NAME, @COLUMN_NAME, @EVENT_NAME, @HANDLER_SCHEMA, @HANDLER_NAME, @HANDLER_TYPE, @HANDLER_CODE, @TARGET_WORKSHEET, @MENU_ORDER, @EDIT_PARAMETERS)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Imports SaveToDB Framework objects
-- =============================================

CREATE PROCEDURE [xls].[xl_import_objects]
    @TABLE_SCHEMA nvarchar(128) = NULL
    , @TABLE_NAME nvarchar(128) = NULL
    , @TABLE_TYPE nvarchar(128) = NULL
    , @TABLE_CODE nvarchar(max) = NULL
    , @INSERT_OBJECT nvarchar(max) = NULL
    , @UPDATE_OBJECT nvarchar(max) = NULL
    , @DELETE_OBJECT nvarchar(max) = NULL
AS
BEGIN

SET NOCOUNT ON;

UPDATE xls.objects
SET
    TABLE_TYPE = @TABLE_TYPE
    , TABLE_CODE = @TABLE_CODE
    , INSERT_OBJECT = @INSERT_OBJECT
    , UPDATE_OBJECT = @UPDATE_OBJECT
    , DELETE_OBJECT = @DELETE_OBJECT
WHERE
    TABLE_SCHEMA = @TABLE_SCHEMA
    AND TABLE_NAME = @TABLE_NAME

IF @@ROWCOUNT = 0
    INSERT INTO xls.objects (TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE, TABLE_CODE, INSERT_OBJECT, UPDATE_OBJECT, DELETE_OBJECT)
        VALUES (@TABLE_SCHEMA, @TABLE_NAME, @TABLE_TYPE, @TABLE_CODE, @INSERT_OBJECT, @UPDATE_OBJECT, @DELETE_OBJECT)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Imports SaveToDB Framework translations
-- =============================================

CREATE PROCEDURE [xls].[xl_import_translations]
    @TABLE_SCHEMA nvarchar(128) = NULL
    , @TABLE_NAME nvarchar(128) = NULL
    , @COLUMN_NAME nvarchar(128) = NULL
    , @LANGUAGE_NAME varchar(10) = NULL
    , @TRANSLATED_NAME nvarchar(128) = NULL
    , @TRANSLATED_DESC nvarchar(1024) = NULL
    , @TRANSLATED_COMMENT nvarchar(2000) = NULL
AS
BEGIN

SET NOCOUNT ON;

UPDATE xls.translations
SET
    TRANSLATED_NAME = @TRANSLATED_NAME
    , TRANSLATED_DESC = @TRANSLATED_DESC
    , TRANSLATED_COMMENT = @TRANSLATED_COMMENT
WHERE
    COALESCE(TABLE_SCHEMA, '') = COALESCE(@TABLE_SCHEMA, '')
    AND COALESCE(TABLE_NAME, '') = COALESCE(@TABLE_NAME, '')
    AND COALESCE(COLUMN_NAME, '') = COALESCE(@COLUMN_NAME, '')
    AND LANGUAGE_NAME = @LANGUAGE_NAME

IF @@ROWCOUNT = 0
    INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT)
        VALUES (@TABLE_SCHEMA, @TABLE_NAME, @COLUMN_NAME, @LANGUAGE_NAME, @TRANSLATED_NAME, @TRANSLATED_DESC, @TRANSLATED_COMMENT)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Imports SaveToDB Framework workbooks
-- =============================================

CREATE PROCEDURE [xls].[xl_import_workbooks]
    @NAME nvarchar(128) = NULL
    , @TEMPLATE nvarchar(255) = NULL
    , @DEFINITION nvarchar(max) = NULL
    , @TABLE_SCHEMA nvarchar(128) = NULL
AS
BEGIN

SET NOCOUNT ON;

UPDATE xls.workbooks
SET
    TEMPLATE = @TEMPLATE
    , DEFINITION = @DEFINITION
    , TABLE_SCHEMA = @TABLE_SCHEMA
WHERE
    NAME = @NAME

IF @@ROWCOUNT = 0
    INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA)
        VALUES (@NAME, @TEMPLATE, @DEFINITION, @TABLE_SCHEMA)

END


GO

INSERT INTO xls.objects (TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE, TABLE_CODE, INSERT_OBJECT, UPDATE_OBJECT, DELETE_OBJECT) VALUES (N'xls', N'view_all_translations', N'VIEW', NULL, N'xls.xl_import_translations', N'xls.xl_import_translations', N'xls.xl_delete_translation');
GO

INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES ('xls', 'developer_framework', 'version', 'Information', NULL, NULL, 'ATTRIBUTE', '10.0', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_unique_keys', NULL, N'ContextMenu', N'xls', N'Add Unique Constraint', N'CODE', N'EXEC xls.xl_actions_generate_constraints 0, 1, 2, @SCHEMA, @TABLE, @COLUMN, @CONSTRAINT= @CONSTRAINT, @ExecuteScript= @ExecuteScript, @PrintCommands=1', N'_reload', 11, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_unique_keys', NULL, N'ContextMenu', N'xls', N'Drop Unique Constraint', N'CODE', N'EXEC xls.xl_actions_generate_constraints 1, 0, 2, @SCHEMA, @TABLE, @COLUMN, @CONSTRAINT= @CONSTRAINT, @ExecuteScript= @ExecuteScript, @PrintCommands=1', N'_reload', 12, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_unique_keys', NULL, N'Actions', N'xls', N'Add Unique Constraint', N'CODE', N'EXEC xls.xl_actions_generate_constraints 0, 1, 2, @SCHEMA, @TABLE, @COLUMN, @CONSTRAINT= @CONSTRAINT, @ExecuteScript= @ExecuteScript, @PrintCommands=1', N'_reload', 11, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_unique_keys', NULL, N'Actions', N'xls', N'Drop Unique Constraint', N'CODE', N'EXEC xls.xl_actions_generate_constraints 1, 0, 2, @SCHEMA, @TABLE, @COLUMN, @CONSTRAINT= @CONSTRAINT, @ExecuteScript= @ExecuteScript, @PrintCommands=1', N'_reload', 12, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_unique_keys', NULL, N'Actions', N'xls', N'MenuSeparator20', N'MENUSEPARATOR', NULL, NULL, 20, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_unique_keys', NULL, N'Actions', N'xls', N'Unique Constraints at MSDN', N'HTTP', N'https://docs.microsoft.com/en-us/sql/relational-databases/tables/unique-constraints-and-check-constraints', NULL, 21, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_primary_keys', NULL, N'ContextMenu', N'xls', N'Add Primary Key Constraint', N'CODE', N'EXEC xls.xl_actions_generate_constraints 0, 1, 1, @SCHEMA, @TABLE, @COLUMN, @CONSTRAINT= @CONSTRAINT, @ExecuteScript= @ExecuteScript, @PrintCommands=1', N'_reload', 11, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_primary_keys', NULL, N'ContextMenu', N'xls', N'Drop Primary Key Constraint', N'CODE', N'EXEC xls.xl_actions_generate_constraints 1, 0, 1, @SCHEMA, @TABLE, @COLUMN, @CONSTRAINT= @CONSTRAINT, @ExecuteScript= @ExecuteScript, @PrintCommands=1', N'_reload', 12, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_primary_keys', NULL, N'Actions', N'xls', N'Add Primary Key Constraint', N'CODE', N'EXEC xls.xl_actions_generate_constraints 0, 1, 1, @SCHEMA, @TABLE, @COLUMN, @CONSTRAINT= @CONSTRAINT, @ExecuteScript= @ExecuteScript, @PrintCommands=1', N'_reload', 11, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_primary_keys', NULL, N'Actions', N'xls', N'Drop Primary Key Constraint', N'CODE', N'EXEC xls.xl_actions_generate_constraints 1, 0, 1, @SCHEMA, @TABLE, @COLUMN, @CONSTRAINT= @CONSTRAINT, @ExecuteScript= @ExecuteScript, @PrintCommands=1', N'_reload', 12, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_primary_keys', NULL, N'Actions', N'xls', N'MenuSeparator20', N'MENUSEPARATOR', NULL, NULL, 20, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_primary_keys', NULL, N'Actions', N'xls', N'Primary and Foreign Key Constraints at MSDN', N'HTTP', N'https://docs.microsoft.com/en-us/sql/relational-databases/tables/primary-and-foreign-key-constraints', NULL, 21, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_foreign_keys', NULL, N'ContextMenu', N'xls', N'Add Foreign Key Constraint', N'CODE', N'EXEC xls.xl_actions_generate_constraints 0, 1, 4, @SCHEMA, @TABLE, @COLUMN, @REFERENTIAL_SCHEMA, @REFERENTIAL_TABLE, @REFERENTIAL_COLUMN, @ON_UPDATE, @ON_DELETE, @CONSTRAINT, @ExecuteScript= @ExecuteScript, @PrintCommands=1', N'_reload', 11, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_foreign_keys', NULL, N'ContextMenu', N'xls', N'Drop Foreign Key Constraint', N'CODE', N'EXEC xls.xl_actions_generate_constraints 1, 0, 4, @SCHEMA, @TABLE, @COLUMN, @REFERENTIAL_SCHEMA, @REFERENTIAL_TABLE, @REFERENTIAL_COLUMN, @ON_UPDATE, @ON_DELETE, @CONSTRAINT, @ExecuteScript= @ExecuteScript, @PrintCommands=1', N'_reload', 12, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_foreign_keys', NULL, N'Actions', N'xls', N'Add Foreign Key Constraint', N'CODE', N'EXEC xls.xl_actions_generate_constraints 0, 1, 4, @SCHEMA, @TABLE, @COLUMN, @REFERENTIAL_SCHEMA, @REFERENTIAL_TABLE, @REFERENTIAL_COLUMN, @ON_UPDATE, @ON_DELETE, @CONSTRAINT, @ExecuteScript= @ExecuteScript, @PrintCommands=1', N'_reload', 11, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_foreign_keys', NULL, N'Actions', N'xls', N'Drop Foreign Key Constraint', N'CODE', N'EXEC xls.xl_actions_generate_constraints 1, 0, 4, @SCHEMA, @TABLE, @COLUMN, @REFERENTIAL_SCHEMA, @REFERENTIAL_TABLE, @REFERENTIAL_COLUMN, @ON_UPDATE, @ON_DELETE, @CONSTRAINT, @ExecuteScript= @ExecuteScript, @PrintCommands=1', N'_reload', 12, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_foreign_keys', NULL, N'Actions', N'xls', N'MenuSeparator20', N'MENUSEPARATOR', NULL, NULL, 20, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_foreign_keys', NULL, N'Actions', N'xls', N'Primary and Foreign Key Constraints at MSDN', N'HTTP', N'https://docs.microsoft.com/en-us/sql/relational-databases/tables/primary-and-foreign-key-constraints', NULL, 21, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'usp_translations', N'field', N'ParameterValues', NULL, NULL, N'VALUES', N'TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'usp_translations', N'schema', N'ParameterValues', N'xls', N'translations', N'TABLE', N'TABLE_SCHEMA', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'usp_translations', NULL, N'Actions', N'xls', N'MenuSeparator90', N'MENUSEPARATOR', NULL, NULL, 90, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'usp_translations', NULL, N'Actions', N'xls', N'SaveToDB Framework Online Help', N'HTTP', N'https://www.savetodb.com/help/savetodb-framework-procedures.htm#xls.usp_translations', NULL, 91, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_all_translations', NULL, N'Actions', N'xls', N'MenuSeparator90', N'MENUSEPARATOR', NULL, NULL, 90, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_all_translations', NULL, N'Actions', N'xls', N'SaveToDB Framework Online Help', N'HTTP', N'https://www.savetodb.com/help/savetodb-framework-views.htm#xls.view_all_translations', NULL, 91, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_foreign_keys', NULL, N'Actions', N'xls', N'MenuSeparator90', N'MENUSEPARATOR', NULL, NULL, 90, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_foreign_keys', NULL, N'Actions', N'xls', N'SaveToDB Framework Online Help', N'HTTP', N'https://www.savetodb.com/help/savetodb-framework-views.htm#xls.view_foreign_keys', NULL, 91, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_primary_keys', NULL, N'Actions', N'xls', N'MenuSeparator90', N'MENUSEPARATOR', NULL, NULL, 90, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_primary_keys', NULL, N'Actions', N'xls', N'SaveToDB Framework Online Help', N'HTTP', N'https://www.savetodb.com/help/savetodb-framework-views.htm#xls.view_primary_keys', NULL, 91, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_unique_keys', NULL, N'Actions', N'xls', N'MenuSeparator90', N'MENUSEPARATOR', NULL, NULL, 90, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_unique_keys', NULL, N'Actions', N'xls', N'SaveToDB Framework Online Help', N'HTTP', N'https://www.savetodb.com/help/savetodb-framework-views.htm#xls.view_unique_keys', NULL, 91, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'usp_translations', NULL, N'License', NULL, NULL, N'ATTRIBUTE', N'Qk2DbSbKRNh+J1ggAJXUdJelhLwjerKlbWkwzFd3vehZKIaatIun1W2G5wFxboaBe7fofD1WaVDls7m2eAsgJ2ukffCwJ4OanMoN2NapGhknRMZOkElAoB1jJCeoxx8qzCCcPzQtx1ChxmOJxIgqlVpAz7Swtm2764TKZHvbysU=', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_all_translations', NULL, N'License', NULL, NULL, N'ATTRIBUTE', N'DuDdxJu6cbtH8oRAhcpmZE8xW51MoJlJYcnjZ1UzNSObX/0gQ5ayac9ZW7eAeAopOtT35rPqfbZjW6B9lBY6YER3FnoQIShlVBXFvNXpig1UUMuYAiqGg4LNCnZjHHd7LxDrjzI5kVf0DN5GYasFpjJ32VU0fw5FRwgCBFCW0eE=', NULL, NULL, NULL);
GO

INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'xls', N'usp_translations', N'<table name="xls.usp_translations"><columnFormats><column name="" property="ListObjectName" value="translation_pivot" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="TABLE_SCHEMA" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_SCHEMA" property="Address" value="$C$4" type="String"/><column name="TABLE_SCHEMA" property="ColumnWidth" value="9.29" type="Double"/><column name="TABLE_SCHEMA" property="NumberFormat" value="General" type="String"/><column name="TABLE_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_NAME" property="Address" value="$D$4" type="String"/><column name="TABLE_NAME" property="ColumnWidth" value="30" type="Double"/><column name="TABLE_NAME" property="NumberFormat" value="General" type="String"/><column name="COLUMN" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="COLUMN" property="Address" value="$E$4" type="String"/><column name="COLUMN" property="ColumnWidth" value="19.14" type="Double"/><column name="COLUMN" property="NumberFormat" value="General" type="String"/><column name="en" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="en" property="Address" value="$F$4" type="String"/><column name="en" property="ColumnWidth" value="20.71" type="Double"/><column name="en" property="NumberFormat" value="General" type="String"/><column name="fr" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="fr" property="Address" value="$G$4" type="String"/><column name="fr" property="ColumnWidth" value="20.71" type="Double"/><column name="fr" property="NumberFormat" value="General" type="String"/><column name="it" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="it" property="Address" value="$H$4" type="String"/><column name="it" property="ColumnWidth" value="20.71" type="Double"/><column name="it" property="NumberFormat" value="General" type="String"/><column name="es" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="es" property="Address" value="$I$4" type="String"/><column name="es" property="ColumnWidth" value="20.71" type="Double"/><column name="es" property="NumberFormat" value="General" type="String"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'xls', N'view_primary_keys', N'<table name="xls.view_primary_keys"><columnFormats><column name="" property="ListObjectName" value="primary_keys" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="SORT_ORDER" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="SORT_ORDER" property="Address" value="$C$4" type="String"/><column name="SORT_ORDER" property="NumberFormat" value="General" type="String"/><column name="SCHEMA" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="SCHEMA" property="Address" value="$D$4" type="String"/><column name="SCHEMA" property="ColumnWidth" value="10.14" type="Double"/><column name="SCHEMA" property="NumberFormat" value="General" type="String"/><column name="TABLE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE" property="Address" value="$E$4" type="String"/><column name="TABLE" property="ColumnWidth" value="20.14" type="Double"/><column name="TABLE" property="NumberFormat" value="General" type="String"/><column name="COLUMN" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="COLUMN" property="Address" value="$F$4" type="String"/><column name="COLUMN" property="ColumnWidth" value="25.43" type="Double"/><column name="COLUMN" property="NumberFormat" value="General" type="String"/><column name="POSITION" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="POSITION" property="Address" value="$G$4" type="String"/><column name="POSITION" property="NumberFormat" value="General" type="String"/><column name="CONSTRAINT" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="CONSTRAINT" property="Address" value="$H$4" type="String"/><column name="CONSTRAINT" property="ColumnWidth" value="30.29" type="Double"/><column name="CONSTRAINT" property="NumberFormat" value="General" type="String"/><column name="INDEX_POSITION" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="INDEX_POSITION" property="Address" value="$I$4" type="String"/><column name="INDEX_POSITION" property="ColumnWidth" value="17.71" type="Double"/><column name="INDEX_POSITION" property="NumberFormat" value="General" type="String"/><column name="IS_DESCENDING" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="IS_DESCENDING" property="Address" value="$J$4" type="String"/><column name="IS_DESCENDING" property="ColumnWidth" value="16.86" type="Double"/><column name="IS_DESCENDING" property="NumberFormat" value="General" type="String"/><column name="IS_DESCENDING" property="HorizontalAlignment" value="-4108" type="Double"/><column name="IS_DESCENDING" property="Font.Size" value="10" type="Double"/><column name="SCHEMA" property="FormatConditions(1).AppliesTo.Address" value="$D$4:$D$486" type="String"/><column name="SCHEMA" property="FormatConditions(1).Type" value="2" type="Double"/><column name="SCHEMA" property="FormatConditions(1).Priority" value="2" type="Double"/><column name="SCHEMA" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String"/><column name="SCHEMA" property="FormatConditions(1).NumberFormat" value="General" type="String"/><column name="SCHEMA" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="SCHEMA" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="TABLE" property="FormatConditions(1).AppliesTo.Address" value="$E$4:$E$486" type="String"/><column name="TABLE" property="FormatConditions(1).Type" value="2" type="Double"/><column name="TABLE" property="FormatConditions(1).Priority" value="3" type="Double"/><column name="TABLE" property="FormatConditions(1).Formula1" value="=ISBLANK(E4)" type="String"/><column name="TABLE" property="FormatConditions(1).NumberFormat" value="General" type="String"/><column name="TABLE" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="TABLE" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="POSITION" property="FormatConditions(1).AppliesTo.Address" value="$G$4:$G$486" type="String"/><column name="POSITION" property="FormatConditions(1).Type" value="2" type="Double"/><column name="POSITION" property="FormatConditions(1).Priority" value="4" type="Double"/><column name="POSITION" property="FormatConditions(1).Formula1" value="=ISBLANK(G4)" type="String"/><column name="POSITION" property="FormatConditions(1).NumberFormat" value="General" type="String"/><column name="POSITION" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="POSITION" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).AppliesTo.Address" value="$J$4:$J$486" type="String"/><column name="IS_DESCENDING" property="FormatConditions(1).Type" value="6" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).Priority" value="1" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean"/><column name="IS_DESCENDING" property="FormatConditions(1).IconSet.ID" value="8" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'xls', N'view_unique_keys', N'<table name="xls.view_unique_keys"><columnFormats><column name="" property="ListObjectName" value="unique_keys" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="SORT_ORDER" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="SORT_ORDER" property="Address" value="$C$4" type="String"/><column name="SORT_ORDER" property="NumberFormat" value="General" type="String"/><column name="SCHEMA" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="SCHEMA" property="Address" value="$D$4" type="String"/><column name="SCHEMA" property="ColumnWidth" value="10.14" type="Double"/><column name="SCHEMA" property="NumberFormat" value="General" type="String"/><column name="TABLE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE" property="Address" value="$E$4" type="String"/><column name="TABLE" property="ColumnWidth" value="20.14" type="Double"/><column name="TABLE" property="NumberFormat" value="General" type="String"/><column name="COLUMN" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="COLUMN" property="Address" value="$F$4" type="String"/><column name="COLUMN" property="ColumnWidth" value="25.43" type="Double"/><column name="COLUMN" property="NumberFormat" value="General" type="String"/><column name="POSITION" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="POSITION" property="Address" value="$G$4" type="String"/><column name="POSITION" property="NumberFormat" value="General" type="String"/><column name="CONSTRAINT" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="CONSTRAINT" property="Address" value="$H$4" type="String"/><column name="CONSTRAINT" property="ColumnWidth" value="29" type="Double"/><column name="CONSTRAINT" property="NumberFormat" value="General" type="String"/><column name="INDEX_POSITION" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="INDEX_POSITION" property="Address" value="$I$4" type="String"/><column name="INDEX_POSITION" property="ColumnWidth" value="17.71" type="Double"/><column name="INDEX_POSITION" property="NumberFormat" value="General" type="String"/><column name="IS_DESCENDING" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="IS_DESCENDING" property="Address" value="$J$4" type="String"/><column name="IS_DESCENDING" property="ColumnWidth" value="16.86" type="Double"/><column name="IS_DESCENDING" property="NumberFormat" value="General" type="String"/><column name="IS_DESCENDING" property="HorizontalAlignment" value="-4108" type="Double"/><column name="IS_DESCENDING" property="Font.Size" value="10" type="Double"/><column name="IS_INCLUDED" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="IS_INCLUDED" property="Address" value="$K$4" type="String"/><column name="IS_INCLUDED" property="ColumnWidth" value="14.14" type="Double"/><column name="IS_INCLUDED" property="NumberFormat" value="General" type="String"/><column name="IS_INCLUDED" property="HorizontalAlignment" value="-4108" type="Double"/><column name="IS_INCLUDED" property="Font.Size" value="10" type="Double"/><column name="SCHEMA" property="FormatConditions(1).AppliesTo.Address" value="$D$4:$D$486" type="String"/><column name="SCHEMA" property="FormatConditions(1).Type" value="2" type="Double"/><column name="SCHEMA" property="FormatConditions(1).Priority" value="3" type="Double"/><column name="SCHEMA" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String"/><column name="SCHEMA" property="FormatConditions(1).NumberFormat" value="General" type="String"/><column name="SCHEMA" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="SCHEMA" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="TABLE" property="FormatConditions(1).AppliesTo.Address" value="$E$4:$E$486" type="String"/><column name="TABLE" property="FormatConditions(1).Type" value="2" type="Double"/><column name="TABLE" property="FormatConditions(1).Priority" value="4" type="Double"/><column name="TABLE" property="FormatConditions(1).Formula1" value="=ISBLANK(E4)" type="String"/><column name="TABLE" property="FormatConditions(1).NumberFormat" value="General" type="String"/><column name="TABLE" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="TABLE" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="POSITION" property="FormatConditions(1).AppliesTo.Address" value="$G$4:$G$486" type="String"/><column name="POSITION" property="FormatConditions(1).Type" value="2" type="Double"/><column name="POSITION" property="FormatConditions(1).Priority" value="5" type="Double"/><column name="POSITION" property="FormatConditions(1).Formula1" value="=ISBLANK(G4)" type="String"/><column name="POSITION" property="FormatConditions(1).NumberFormat" value="General" type="String"/><column name="POSITION" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="POSITION" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).AppliesTo.Address" value="$J$4:$J$486" type="String"/><column name="IS_DESCENDING" property="FormatConditions(1).Type" value="6" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).Priority" value="2" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean"/><column name="IS_DESCENDING" property="FormatConditions(1).IconSet.ID" value="8" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double"/><column name="IS_DESCENDING" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double"/><column name="IS_INCLUDED" property="FormatConditions(1).AppliesTo.Address" value="$K$4:$K$486" type="String"/><column name="IS_INCLUDED" property="FormatConditions(1).Type" value="6" type="Double"/><column name="IS_INCLUDED" property="FormatConditions(1).Priority" value="1" type="Double"/><column name="IS_INCLUDED" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean"/><column name="IS_INCLUDED" property="FormatConditions(1).IconSet.ID" value="8" type="Double"/><column name="IS_INCLUDED" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double"/><column name="IS_INCLUDED" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double"/><column name="IS_INCLUDED" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double"/><column name="IS_INCLUDED" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double"/><column name="IS_INCLUDED" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double"/><column name="IS_INCLUDED" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double"/><column name="IS_INCLUDED" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double"/><column name="IS_INCLUDED" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'xls', N'view_foreign_keys', N'<table name="xls.view_foreign_keys"><columnFormats><column name="" property="ListObjectName" value="foreign_keys" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="SORT_ORDER" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="SORT_ORDER" property="Address" value="$C$4" type="String"/><column name="SORT_ORDER" property="NumberFormat" value="General" type="String"/><column name="SCHEMA" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="SCHEMA" property="Address" value="$D$4" type="String"/><column name="SCHEMA" property="ColumnWidth" value="10.14" type="Double"/><column name="SCHEMA" property="NumberFormat" value="General" type="String"/><column name="TABLE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE" property="Address" value="$E$4" type="String"/><column name="TABLE" property="ColumnWidth" value="20.14" type="Double"/><column name="TABLE" property="NumberFormat" value="General" type="String"/><column name="COLUMN" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="COLUMN" property="Address" value="$F$4" type="String"/><column name="COLUMN" property="ColumnWidth" value="25.43" type="Double"/><column name="COLUMN" property="NumberFormat" value="General" type="String"/><column name="POSITION" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="POSITION" property="Address" value="$G$4" type="String"/><column name="POSITION" property="NumberFormat" value="General" type="String"/><column name="REFERENTIAL_SCHEMA" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="REFERENTIAL_SCHEMA" property="Address" value="$H$4" type="String"/><column name="REFERENTIAL_SCHEMA" property="ColumnWidth" value="9.43" type="Double"/><column name="REFERENTIAL_SCHEMA" property="NumberFormat" value="General" type="String"/><column name="REFERENTIAL_TABLE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="REFERENTIAL_TABLE" property="Address" value="$I$4" type="String"/><column name="REFERENTIAL_TABLE" property="ColumnWidth" value="20.57" type="Double"/><column name="REFERENTIAL_TABLE" property="NumberFormat" value="General" type="String"/><column name="REFERENTIAL_COLUMN" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="REFERENTIAL_COLUMN" property="Address" value="$J$4" type="String"/><column name="REFERENTIAL_COLUMN" property="ColumnWidth" value="23.57" type="Double"/><column name="REFERENTIAL_COLUMN" property="NumberFormat" value="General" type="String"/><column name="CONSTRAINT" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="CONSTRAINT" property="Address" value="$K$4" type="String"/><column name="CONSTRAINT" property="ColumnWidth" value="51.29" type="Double"/><column name="CONSTRAINT" property="NumberFormat" value="General" type="String"/><column name="ON_UPDATE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="ON_UPDATE" property="Address" value="$L$4" type="String"/><column name="ON_UPDATE" property="ColumnWidth" value="13.57" type="Double"/><column name="ON_UPDATE" property="NumberFormat" value="General" type="String"/><column name="ON_DELETE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="ON_DELETE" property="Address" value="$M$4" type="String"/><column name="ON_DELETE" property="ColumnWidth" value="12.57" type="Double"/><column name="ON_DELETE" property="NumberFormat" value="General" type="String"/><column name="SCHEMA" property="FormatConditions(1).AppliesTo.Address" value="$D$4:$D$486" type="String"/><column name="SCHEMA" property="FormatConditions(1).Type" value="2" type="Double"/><column name="SCHEMA" property="FormatConditions(1).Priority" value="1" type="Double"/><column name="SCHEMA" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String"/><column name="SCHEMA" property="FormatConditions(1).NumberFormat" value="General" type="String"/><column name="SCHEMA" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="SCHEMA" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="TABLE" property="FormatConditions(1).AppliesTo.Address" value="$E$4:$E$486" type="String"/><column name="TABLE" property="FormatConditions(1).Type" value="2" type="Double"/><column name="TABLE" property="FormatConditions(1).Priority" value="2" type="Double"/><column name="TABLE" property="FormatConditions(1).Formula1" value="=ISBLANK(E4)" type="String"/><column name="TABLE" property="FormatConditions(1).NumberFormat" value="General" type="String"/><column name="TABLE" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="TABLE" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="POSITION" property="FormatConditions(1).AppliesTo.Address" value="$G$4:$G$486" type="String"/><column name="POSITION" property="FormatConditions(1).Type" value="2" type="Double"/><column name="POSITION" property="FormatConditions(1).Priority" value="3" type="Double"/><column name="POSITION" property="FormatConditions(1).Formula1" value="=ISBLANK(G4)" type="String"/><column name="POSITION" property="FormatConditions(1).NumberFormat" value="General" type="String"/><column name="POSITION" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="POSITION" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'xls', N'view_all_translations', N'<table name="xls.view_all_translations"><columnFormats><column name="" property="ListObjectName" value="all_translations" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="SECTION" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="SECTION" property="Address" value="$C$4" type="String"/><column name="SECTION" property="NumberFormat" value="General" type="String"/><column name="SORT_ORDER" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="SORT_ORDER" property="Address" value="$D$4" type="String"/><column name="SORT_ORDER" property="NumberFormat" value="General" type="String"/><column name="TRANSLATION_TYPE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TRANSLATION_TYPE" property="Address" value="$E$4" type="String"/><column name="TRANSLATION_TYPE" property="ColumnWidth" value="11.43" type="Double"/><column name="TRANSLATION_TYPE" property="NumberFormat" value="General" type="String"/><column name="TABLE_TYPE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_TYPE" property="Address" value="$F$4" type="String"/><column name="TABLE_TYPE" property="ColumnWidth" value="13.14" type="Double"/><column name="TABLE_TYPE" property="NumberFormat" value="General" type="String"/><column name="TABLE_SCHEMA" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_SCHEMA" property="Address" value="$G$4" type="String"/><column name="TABLE_SCHEMA" property="ColumnWidth" value="9.29" type="Double"/><column name="TABLE_SCHEMA" property="NumberFormat" value="General" type="String"/><column name="TABLE_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_NAME" property="Address" value="$H$4" type="String"/><column name="TABLE_NAME" property="ColumnWidth" value="51.43" type="Double"/><column name="TABLE_NAME" property="NumberFormat" value="General" type="String"/><column name="COLUMN_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="COLUMN_NAME" property="Address" value="$I$4" type="String"/><column name="COLUMN_NAME" property="ColumnWidth" value="25.57" type="Double"/><column name="COLUMN_NAME" property="NumberFormat" value="General" type="String"/><column name="LANGUAGE_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="LANGUAGE_NAME" property="Address" value="$J$4" type="String"/><column name="LANGUAGE_NAME" property="ColumnWidth" value="2.86" type="Double"/><column name="LANGUAGE_NAME" property="NumberFormat" value="General" type="String"/><column name="TRANSLATED_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TRANSLATED_NAME" property="Address" value="$K$4" type="String"/><column name="TRANSLATED_NAME" property="ColumnWidth" value="29.14" type="Double"/><column name="TRANSLATED_NAME" property="NumberFormat" value="General" type="String"/><column name="TRANSLATED_DESC" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TRANSLATED_DESC" property="Address" value="$L$4" type="String"/><column name="TRANSLATED_DESC" property="ColumnWidth" value="19.57" type="Double"/><column name="TRANSLATED_DESC" property="NumberFormat" value="General" type="String"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
GO

INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'savetodb_developer.xlsx', NULL,
N'objects=xls.objects,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":null,"TABLE_TYPE":null},"ListObjectName":"objects","WorkbookLanguage":"en"}
handlers=xls.handlers,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":null,"TABLE_NAME":null,"EVENT_NAME":null},"ListObjectName":"handlers","WorkbookLanguage":"en"}
translations=xls.translations,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":null,"TABLE_NAME":null,"LANGUAGE_NAME":null},"ListObjectName":"translations","WorkbookLanguage":"en"}
all_translations=xls.view_all_translations,(Default),False,$B$3,,{"Parameters":{"TRANSLATION_TYPE":null,"TABLE_TYPE":null,"TABLE_SCHEMA":null,"LANGUAGE_NAME":"en"},"ListObjectName":"all_translations","WorkbookLanguage":"en"}
translation_pivot=xls.usp_translations,(Default),False,$B$3,,{"Parameters":{"field":"TRANSLATED_NAME"},"ListObjectName":"translation_pivot","WorkbookLanguage":"en"}
workbooks=xls.workbooks,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":null},"ListObjectName":"workbooks","WorkbookLanguage":"en"}
primary_keys=xls.view_primary_keys,(Default),False,$B$3,,{"Parameters":{"SCHEMA":null},"ListObjectName":"primary_keys","WorkbookLanguage":"en"}
unique_keys=xls.view_unique_keys,(Default),False,$B$3,,{"Parameters":{"SCHEMA":null},"ListObjectName":"unique_keys","WorkbookLanguage":"en"}
foreign_keys=xls.view_foreign_keys,(Default),False,$B$3,,{"Parameters":{"SCHEMA":null},"ListObjectName":"foreign_keys","WorkbookLanguage":"en"}', N'xls');
GO

EXEC xls.xl_actions_set_role_permissions
GO

print 'SaveToDB Developer Framework installed'
