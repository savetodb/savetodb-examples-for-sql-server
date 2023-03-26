-- =============================================
-- Tab Framework for Microsoft SQL Server
-- Version 10.8, January 9, 2023
--
-- Copyright 2021-2023 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON
GO

CREATE SCHEMA tab;
GO

CREATE TABLE tab.formats (
    ID int IDENTITY(1,1) NOT NULL
    , TABLE_SCHEMA nvarchar(128) NOT NULL
    , TABLE_NAME nvarchar(128) NOT NULL
    , TABLE_EXCEL_FORMAT_XML xml NULL
    , APP nvarchar(50) NULL
    , CONSTRAINT PK_formats PRIMARY KEY (ID)
    , CONSTRAINT IX_formats UNIQUE (TABLE_SCHEMA, TABLE_NAME, APP)
);
GO

CREATE TABLE tab.languages (
    language varchar(10) NOT NULL
    , sort_order tinyint NULL
    , CONSTRAINT PK_languages PRIMARY KEY (language)
);
GO

CREATE TABLE tab.tables (
    id int IDENTITY(1,1) NOT NULL
    , table_schema nvarchar(20) NOT NULL
    , table_name nvarchar(128) NOT NULL
    , store_formulas bit NULL CONSTRAINT DF_tables_store_formulas DEFAULT((0))
    , protect_rows bit NULL CONSTRAINT DF_tables_protect_rows DEFAULT((0))
    , do_not_save bit NULL CONSTRAINT DF_tables_do_not_save DEFAULT((0))
    , CONSTRAINT PK_tables PRIMARY KEY (id)
    , CONSTRAINT IX_tables_name UNIQUE (table_name)
);
GO

CREATE TABLE tab.types (
    id int NOT NULL
    , name nvarchar(50) NOT NULL
    , datatype nvarchar(50) NULL
    , translation_supported bit NULL
    , CONSTRAINT PK_types PRIMARY KEY (id)
    , CONSTRAINT IX_types_name UNIQUE (name)
);
GO

CREATE TABLE tab.workbooks (
    ID int IDENTITY(1,1) NOT NULL
    , NAME nvarchar(128) NOT NULL
    , TEMPLATE nvarchar(255) NULL
    , DEFINITION nvarchar(max) NOT NULL
    , TABLE_SCHEMA nvarchar(128) NULL
    , CONSTRAINT PK_workbooks PRIMARY KEY (ID)
    , CONSTRAINT IX_workbooks_name UNIQUE (NAME)
);
GO

CREATE TABLE tab.columns (
    id int IDENTITY(1,1) NOT NULL
    , table_id int NOT NULL
    , name nvarchar(50) NOT NULL
    , column_id int NOT NULL
    , type_id int NOT NULL
    , max_length int NULL
    , value_table_id int NULL
    , value_column_id int NULL
    , parameter_name nvarchar(50) NULL
    , translation_supported bit NULL
    , do_not_change bit NULL CONSTRAINT DF_columns_do_not_change DEFAULT((0))
    , CONSTRAINT PK_columns PRIMARY KEY (id)
    , CONSTRAINT IX_columns_name UNIQUE (table_id, name)
);
GO

ALTER TABLE tab.columns ADD CONSTRAINT FK_columns_tables FOREIGN KEY (table_id) REFERENCES tab.tables (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

ALTER TABLE tab.columns ADD CONSTRAINT FK_columns_types FOREIGN KEY (type_id) REFERENCES tab.types (id) ON UPDATE CASCADE;
GO

CREATE TABLE tab.rows (
    id int IDENTITY(1,1) NOT NULL
    , table_id int NOT NULL
    , cell_formulas nvarchar(max) NULL
    , cell_comments nvarchar(max) NULL
    , CONSTRAINT PK_rows PRIMARY KEY (id)
);
GO

ALTER TABLE tab.rows ADD CONSTRAINT FK_rows_tables FOREIGN KEY (table_id) REFERENCES tab.tables (id);
GO

CREATE TABLE tab.cells (
    row_id int NOT NULL
    , column_id int NOT NULL
    , value sql_variant NULL
    , CONSTRAINT PK_cells PRIMARY KEY (row_id, column_id)
);
GO

CREATE INDEX IX_cells_column_id_value ON tab.cells (column_id, value);
GO

ALTER TABLE tab.cells ADD CONSTRAINT FK_cells_columns FOREIGN KEY (column_id) REFERENCES tab.columns (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

ALTER TABLE tab.cells ADD CONSTRAINT FK_cells_rows FOREIGN KEY (row_id) REFERENCES tab.rows (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

CREATE TABLE tab.translations (
    id int IDENTITY(1,1) NOT NULL
    , type_id tinyint NOT NULL
    , table_id int NULL
    , column_id int NULL
    , row_id int NULL
    , language varchar(10) NOT NULL
    , name nvarchar(255) NOT NULL
    , CONSTRAINT PK_translations PRIMARY KEY (id)
    , CONSTRAINT IX_translations UNIQUE (type_id, table_id, column_id, row_id, language)
);
GO

ALTER TABLE tab.translations ADD CONSTRAINT FK_translations_columns FOREIGN KEY (column_id) REFERENCES tab.columns (id);
GO

ALTER TABLE tab.translations ADD CONSTRAINT FK_translations_languages FOREIGN KEY (language) REFERENCES tab.languages (language) ON DELETE CASCADE ON UPDATE CASCADE;
GO

ALTER TABLE tab.translations ADD CONSTRAINT FK_translations_rows FOREIGN KEY (row_id) REFERENCES tab.rows (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

ALTER TABLE tab.translations ADD CONSTRAINT FK_translations_tables FOREIGN KEY (table_id) REFERENCES tab.tables (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Returns a typed value
-- =============================================

CREATE FUNCTION [tab].[get_typed_value]
(
    @value sql_variant = NULL
    , @type_id int = NULL
)
RETURNS sql_variant
AS
BEGIN

RETURN
    CASE @type_id
        WHEN 56 THEN CAST(TRY_CONVERT(int, @value) AS sql_variant)
        WHEN 60 THEN CAST(TRY_CONVERT(money, @value) AS sql_variant)
        WHEN 231 THEN CAST(TRY_CONVERT(nvarchar, @value) AS sql_variant)
        WHEN 40 THEN CAST(TRY_CONVERT(date, @value) AS sql_variant)
        WHEN 61 THEN CAST(TRY_CONVERT(datetime, @value) AS sql_variant)

        WHEN 36 THEN CAST(TRY_CONVERT(uniqueidentifier, @value) AS sql_variant)
        WHEN 41 THEN CAST(TRY_CONVERT(time, @value) AS sql_variant)
        WHEN 42 THEN CAST(TRY_CONVERT(datetime2, @value) AS sql_variant)
        WHEN 43 THEN CAST(TRY_CONVERT(datetimeoffset, @value) AS sql_variant)
        WHEN 48 THEN CAST(TRY_CONVERT(tinyint, @value) AS sql_variant)
        WHEN 52 THEN CAST(TRY_CONVERT(smallint, @value) AS sql_variant)
        WHEN 58 THEN CAST(TRY_CONVERT(smalldatetime, @value) AS sql_variant)
        WHEN 62 THEN CAST(TRY_CONVERT(float, @value) AS sql_variant)
        WHEN 104 THEN CAST(TRY_CONVERT(bit, @value) AS sql_variant)
        WHEN 106 THEN CAST(TRY_CONVERT(decimal, @value) AS sql_variant)
        WHEN 108 THEN CAST(TRY_CONVERT(numeric, @value) AS sql_variant)
        WHEN 122 THEN CAST(TRY_CONVERT(smallmoney, @value) AS sql_variant)
        WHEN 127 THEN CAST(TRY_CONVERT(bigint, @value) AS sql_variant)
        WHEN 167 THEN CAST(TRY_CONVERT(varchar, @value) AS sql_variant)
        WHEN 175 THEN CAST(TRY_CONVERT(char, @value) AS sql_variant)
        WHEN 239 THEN CAST(TRY_CONVERT(nchar, @value) AS sql_variant)

        ELSE CAST(CAST(@value AS nvarchar) AS sql_variant) END
END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view select users
-- =============================================

CREATE VIEW [tab].[users]
AS

SELECT
    m.name AS [user]
    , r.name AS [role]
FROM
    sys.database_principals m
    LEFT JOIN sys.database_role_members rm ON rm.member_principal_id = m.principal_id
    LEFT JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
WHERE
    m.[type] IN ('S', 'U', 'R')
    AND m.is_fixed_role = 0
    AND NOT m.name IN ('dbo', 'sys', 'guest', 'public', 'INFORMATION_SCHEMA', 'xls_users', 'xls_developers', 'xls_formats', 'xls_admins', 'doc_readers', 'doc_writers', 'log_app', 'log_admins', 'log_administrators', 'log_users')
    AND (r.name IN ('tab_users', 'tab_developers') OR r.name IS NULL AND m.type IN ('S', 'U'))


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.1, 2022-08-17
-- Description: The view generates application handlers
-- =============================================

CREATE VIEW [tab].[xl_app_handlers]
AS

SELECT
    CAST(s.TABLE_SCHEMA AS nvarchar(20)) AS TABLE_SCHEMA
    , CAST(s.TABLE_NAME AS nvarchar(128)) AS TABLE_NAME
    , CAST(s.COLUMN_NAME AS nvarchar(128)) AS COLUMN_NAME
    , CAST(s.EVENT_NAME AS nvarchar(25)) AS EVENT_NAME
    , CAST(s.HANDLER_SCHEMA AS nvarchar(20)) AS HANDLER_SCHEMA
    , CAST(s.HANDLER_NAME AS nvarchar(128)) AS HANDLER_NAME
    , CAST(s.HANDLER_TYPE AS nvarchar(25)) AS HANDLER_TYPE
    , CAST(s.HANDLER_CODE AS nvarchar(max)) HANDLER_CODE
    , CAST(s.TARGET_WORKSHEET AS nvarchar(128)) AS TARGET_WORKSHEET
    , CAST(s.MENU_ORDER AS int) AS MENU_ORDER
    , CAST(s.EDIT_PARAMETERS AS bit) AS EDIT_PARAMETERS
FROM
    (VALUES
        ('tab', 'columns', 'table_id', 'ValidationList', 'tab', 'table_id', 'CODE', 'SELECT id, table_schema + ''.'' + table_name AS name FROM tab.tables ORDER BY table_schema, table_name', NULL, NULL, NULL)
        , ('tab', 'columns', 'type_id', 'ValidationList', 'tab', 'type_id', 'CODE', 'SELECT id, name FROM tab.types WHERE datatype IS NOT NULL ORDER BY name', NULL, NULL, NULL)
        , ('tab', 'columns', 'value_table_id', 'ValidationList', 'tab', 'table_id', 'CODE', 'SELECT id, table_schema + ''.'' + table_name AS name FROM tab.tables ORDER BY table_schema, table_name', NULL, NULL, NULL)
        , ('tab', 'columns', 'value_column_id', 'ValidationList', 'tab', 'value_column_id', 'CODE', 'SELECT c.id, table_schema + ''.'' + table_name + ''.'' + c.name AS name, c.table_id AS value_table_id FROM tab.columns c INNER JOIN tab.tables t ON t.id = c.table_id ORDER BY c.value_table_id, c.column_id, c.name', NULL, NULL, NULL)
        , ('tab', 'columns', 'parameter_name', 'ValidationList', 'tab', 'parameter_name', 'VALUES', ', p1, p2, p3, p4, p5, p6', NULL, NULL, NULL)
        , ('tab', 'usp_select_table', 'table_id', 'ParameterValues', 'tab', 'xl_list_table_id', 'PROCEDURE', NULL, '_NotNull', NULL, NULL)
        , ('tab', 'usp_select_table', NULL, 'JsonForm', NULL, NULL, 'ATTRIBUTE', NULL, NULL, NULL, NULL)
        , ('tab', 'usp_select_table', 'cell_formulas', 'KeepFormulas', NULL, NULL, 'ATTRIBUTE', NULL, NULL, NULL, NULL)
        , ('tab', 'usp_select_table', 'cell_comments', 'KeepComments', NULL, NULL, 'ATTRIBUTE', NULL, NULL, NULL, NULL)
        , ('tab', 'usp_select_translations', NULL, 'JsonForm', NULL, NULL, 'ATTRIBUTE', NULL, NULL, NULL, NULL)
        , ('tab', 'usp_select_translations', NULL, 'ProtectRows', NULL, NULL, 'ATTRIBUTE', NULL, NULL, NULL, NULL)
        , ('tab', 'rows', NULL, 'DoNotAddValidation', NULL, NULL, 'ATTRIBUTE', NULL, NULL, NULL, NULL)
        , ('tab', 'cells', NULL, 'DoNotAddValidation', NULL, NULL, 'ATTRIBUTE', NULL, NULL, NULL, NULL)
        , ('tab', 'cells', NULL, 'DoNotAddManyToMany', NULL, NULL, 'ATTRIBUTE', NULL, NULL, NULL, NULL)
        , ('tab', 'translations', NULL, 'DoNotAddValidation', NULL, NULL, 'ATTRIBUTE', NULL, NULL, NULL, NULL)
        , ('tab', 'tables', NULL, 'License', NULL, NULL, 'ATTRIBUTE', 'QFsOXa3retQAOu4EdB4JRfWDExZ3MovBq1ytjtSxn6gJAGG480B86wzldn8VqJA3icmRZ2x1hlNdyn1F5Xeu1B88jXwnVXHrJr8URaSciVB5OzscmIongev0muuy5eOuR4hFWwb1HAKNJfnGoFxLYNsU79yLRlTiXVPcdTEiPN4=', NULL, NULL, NULL)
        , ('tab', 'columns', NULL, 'License', NULL, NULL, 'ATTRIBUTE', 'ga6j2jOOyR5HtB01NSRWf5bSOMC9qkxpuFmY/X4k8V9b2gqY7SEdFVYPKHVZht2Lo7p5GRFUgiEA5hVtF3kM4wW4S1wghHqrwfxCEcTf7095h0SUAwjBz7WVwbBmHNOSFeib/JDGo3MIxiPehoCEFPD7UMXrzR5TNou4y9x225I=', NULL, NULL, NULL)
        , ('tab', 'languages', NULL, 'License', NULL, NULL, 'ATTRIBUTE', 'xPheHHnyU0PI4CXdf9fIf2T+APWWtbp0Txsz95etKhS1cFSeWEGepMw4fdwEew4y7vs7/YXWWQbVJqc4uFFDxHoSQVhzNajYCLopMYsd85hJHLRVAlvrgwpQUUMKGv/fC2moQnlGNDvrsy+yuOEvYI94oB9IzJyJkqqMsDN4bUo=', NULL, NULL, NULL)
        , ('tab', 'usp_select_table', NULL, 'License', NULL, NULL, 'ATTRIBUTE', 'QXT0BUCJn40gUHKwL4XO2pBvL4V/QjsX0tQJTiqQA3djoIjYn4PambHY9EfjJpb9uAHZOVt170xdkkuhk9Yoj+GfD9N/mrXvJwL2bDfNl/t1nH2uFFO6hvm8zD+hyvh/EHfeUxtXkekT1Z5c8HHVuRN9IAQFtASKc6VCFbcAr7g=', NULL, NULL, NULL)
        , ('tab', 'usp_select_translations', NULL, 'License', NULL, NULL, 'ATTRIBUTE', 'uyjegG3w2S2P1ypzDceg+euiBOYnslyEAl0I2rWOmoi5wQ5R49rnPrmIEs6c2BtXktMBrL0cM/3GDOMVKTokS7QkUglCkvAEnt2vUqUM98jrhbQMicGbFA+ujX14QURnNULveGV116MUDDdvAKm6eV2YUo8uYGx8+eL2Ro10CwM=', NULL, NULL, NULL)
        , ('tab', 'users', NULL, 'ContextMenu', NULL, 'Add {user} to tab_users', 'CODE', 'ALTER ROLE tab_users ADD MEMBER @user', NULL, 1, NULL)
        , ('tab', 'users', NULL, 'ContextMenu', NULL, 'Add {user} to tab_developers', 'CODE', 'ALTER ROLE tab_developers ADD MEMBER @user', NULL, 2, NULL)
        , ('tab', 'users', NULL, 'ContextMenu', NULL, NULL, 'MENUSEPARATOR', NULL, NULL, 3, NULL)
        , ('tab', 'users', NULL, 'ContextMenu', NULL, 'Remove {user} from tab_users', 'CODE', 'ALTER ROLE tab_users DROP MEMBER @user', NULL, 4, NULL)
        , ('tab', 'users', NULL, 'ContextMenu', NULL, 'Remove {user} from tab_developers', 'CODE', 'ALTER ROLE tab_developers DROP MEMBER @user', NULL, 5, NULL)
    ) s(TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS)

UNION ALL
SELECT
    CAST(t.table_schema AS nvarchar(20)) AS TABLE_SCHEMA
    , CAST(t.table_name AS nvarchar(128)) AS TABLE_NAME
    , CAST(s.COLUMN_NAME AS nvarchar(128)) AS COLUMN_NAME
    , CAST(s.EVENT_NAME AS nvarchar(25)) AS EVENT_NAME
    , CAST(s.HANDLER_SCHEMA AS nvarchar(20)) AS HANDLER_SCHEMA
    , CAST(s.HANDLER_NAME AS nvarchar(128)) AS HANDLER_NAME
    , CAST(s.HANDLER_TYPE AS nvarchar(25)) AS HANDLER_TYPE
    , CAST(s.HANDLER_CODE AS nvarchar(max)) HANDLER_CODE
    , CAST(NULL AS nvarchar(128)) AS TARGET_WORKSHEET
    , CAST(NULL AS int) AS MENU_ORDER
    , CAST(NULL AS bit) AS EDIT_PARAMETERS
FROM
    tab.tables t
    CROSS JOIN (VALUES
        (NULL, 'JsonForm', NULL, NULL, 'ATTRIBUTE', NULL, NULL, NULL, NULL)
        , ('cell_formulas', 'KeepFormulas', NULL, NULL, 'ATTRIBUTE', NULL, NULL, NULL, NULL)
        , ('cell_comments', 'KeepComments', NULL, NULL, 'ATTRIBUTE', NULL, NULL, NULL, NULL)
        , (NULL, 'LoadFormat', 'tab', 'formats', 'TABLE', NULL, NULL, NULL, NULL)
    ) s(COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS)
WHERE
    t.store_formulas = 1 OR NOT s.EVENT_NAME IN ('KeepFormulas', 'KeepComments')

UNION ALL
SELECT
    CAST(t.table_schema AS nvarchar(20)) AS TABLE_SCHEMA
    , CAST(t.table_name AS nvarchar(128)) AS TABLE_NAME
    , CAST(s.COLUMN_NAME AS nvarchar(128)) AS COLUMN_NAME
    , CAST(s.EVENT_NAME AS nvarchar(25)) AS EVENT_NAME
    , CAST(s.HANDLER_SCHEMA AS nvarchar(20)) AS HANDLER_SCHEMA
    , CAST(s.HANDLER_NAME AS nvarchar(128)) AS HANDLER_NAME
    , CAST(s.HANDLER_TYPE AS nvarchar(25)) AS HANDLER_TYPE
    , CAST(s.HANDLER_CODE AS nvarchar(max)) HANDLER_CODE
    , CAST(NULL AS nvarchar(128)) AS TARGET_WORKSHEET
    , CAST(NULL AS int) AS MENU_ORDER
    , CAST(NULL AS bit) AS EDIT_PARAMETERS
FROM
    tab.tables t
    CROSS JOIN (VALUES
        (NULL, 'ProtectRows', NULL, NULL, 'ATTRIBUTE', NULL, NULL, NULL, NULL)
        , (NULL, 'DoNotSave', NULL, NULL, 'ATTRIBUTE', NULL, NULL, NULL, NULL)
    ) s(COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS)
WHERE
    (t.protect_rows = 1 AND s.EVENT_NAME IN ('ProtectRows')
    OR t.do_not_save = 1 AND s.EVENT_NAME IN ('DoNotSave')
    ) AND EXISTS (
            SELECT
                p.name
            FROM
                sys.database_principals p
                INNER JOIN sys.database_role_members rm ON rm.member_principal_id = p.principal_id
            WHERE
                p.name = USER_NAME()
                AND rm.role_principal_id = USER_ID('tab_users')
                AND NOT rm.role_principal_id = USER_ID('tab_developers')
            )

UNION ALL
SELECT
    CAST(t.table_schema AS nvarchar(20)) AS TABLE_SCHEMA
    , CAST(t.table_name AS nvarchar(128)) AS TABLE_NAME
    , CAST(c.name AS nvarchar(128)) AS COLUMN_NAME
    , CAST('ValidationList' AS nvarchar(25)) AS EVENT_NAME
    , vt.table_schema AS HANDLER_SCHEMA
    , 'list_' + vt.table_name AS HANDLER_NAME
    , 'CODE' AS HANDLER_TYPE
    , 'EXEC tab.xl_list_by_column_id @column_id=' + CAST(vc.id AS nvarchar) + ', @data_language= @data_language' AS HANDLER_CODE
    , CAST(NULL AS nvarchar(128)) AS TARGET_WORKSHEET
    , CAST(NULL AS int) AS MENU_ORDER
    , CAST(NULL AS bit) AS EDIT_PARAMETERS
FROM
    tab.columns c
    INNER JOIN tab.tables t ON t.id = c.table_id
    INNER JOIN tab.columns vc ON vc.id = c.value_column_id
    INNER JOIN tab.tables vt ON vt.id = vc.table_id

UNION ALL
SELECT
    CAST(t.table_schema AS nvarchar(20)) AS TABLE_SCHEMA
    , CAST(t.table_name AS nvarchar(128)) AS TABLE_NAME
    , CAST(c.name AS nvarchar(128)) AS COLUMN_NAME
    , CAST(s.EVENT_NAME AS nvarchar(25)) AS EVENT_NAME
    , CAST(s.HANDLER_SCHEMA AS nvarchar(20)) AS HANDLER_SCHEMA
    , CAST(s.HANDLER_NAME AS nvarchar(128)) AS HANDLER_NAME
    , CAST(s.HANDLER_TYPE AS nvarchar(25)) AS HANDLER_TYPE
    , CAST(s.HANDLER_CODE AS nvarchar(max)) HANDLER_CODE
    , CAST(NULL AS nvarchar(128)) AS TARGET_WORKSHEET
    , CAST(NULL AS int) AS MENU_ORDER
    , CAST(NULL AS bit) AS EDIT_PARAMETERS
FROM
    tab.columns c
    INNER JOIN tab.tables t ON t.id = c.table_id
    CROSS JOIN (VALUES
        ('DoNotChange', NULL, NULL, 'ATTRIBUTE', NULL, NULL, NULL, NULL)
    ) s(EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS)
WHERE
    (c.do_not_change = 1 AND s.EVENT_NAME IN ('DoNotChange')
    ) AND EXISTS (
            SELECT
                p.name
            FROM
                sys.database_principals p
                INNER JOIN sys.database_role_members rm ON rm.member_principal_id = p.principal_id
            WHERE
                p.name = USER_NAME()
                AND rm.role_principal_id = USER_ID('tab_users')
                AND NOT rm.role_principal_id = USER_ID('tab_developers')
            )

UNION ALL
SELECT
    CAST(t.table_schema AS nvarchar(20)) AS TABLE_SCHEMA
    , CAST(t.table_name AS nvarchar(128)) AS TABLE_NAME
    , CAST(c.name AS nvarchar(128)) AS COLUMN_NAME
    , CAST(ct.datatype AS nvarchar(25)) AS EVENT_NAME
    , CAST(NULL AS nvarchar(20)) AS HANDLER_SCHEMA
    , CAST(NULL AS nvarchar(128)) AS HANDLER_NAME
    , CAST('ATTRIBUTE' AS nvarchar(25)) AS HANDLER_TYPE
    , CAST(NULL AS nvarchar(max)) HANDLER_CODE
    , CAST(NULL AS nvarchar(128)) AS TARGET_WORKSHEET
    , CAST(NULL AS int) AS MENU_ORDER
    , CAST(NULL AS bit) AS EDIT_PARAMETERS
FROM
    tab.columns c
    INNER JOIN tab.tables t ON t.id = c.table_id
    INNER JOIN tab.types ct ON ct.id = c.type_id
WHERE
    ct.datatype IS NOT NULL

UNION ALL
SELECT
    CAST(t.table_schema AS nvarchar(20)) AS TABLE_SCHEMA
    , CAST(t.table_name AS nvarchar(128)) AS TABLE_NAME
    , CAST(c.parameter_name AS nvarchar(128)) AS COLUMN_NAME
    , CAST(ct.datatype AS nvarchar(25)) AS EVENT_NAME
    , CAST(NULL AS nvarchar(20)) AS HANDLER_SCHEMA
    , CAST(NULL AS nvarchar(128)) AS HANDLER_NAME
    , CAST('ATTRIBUTE' AS nvarchar(25)) AS HANDLER_TYPE
    , CAST(NULL AS nvarchar(max)) HANDLER_CODE
    , CAST(NULL AS nvarchar(128)) AS TARGET_WORKSHEET
    , CAST(NULL AS int) AS MENU_ORDER
    , CAST(NULL AS bit) AS EDIT_PARAMETERS
FROM
    tab.columns c
    INNER JOIN tab.tables t ON t.id = c.table_id
    INNER JOIN tab.types ct ON ct.id = c.type_id
WHERE
    ct.datatype IS NOT NULL
    AND c.parameter_name IS NOT NULL


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Object configuration
-- =============================================

CREATE VIEW [tab].[xl_app_objects]
AS

SELECT
    'tab' AS TABLE_SCHEMA
    , o.name AS TABLE_NAME
    , 'HIDDEN' AS TABLE_TYPE
    , CAST(NULL AS nvarchar(max)) AS TABLE_CODE
    , CAST(NULL AS nvarchar(max)) AS INSERT_OBJECT
    , CAST(NULL AS nvarchar(max)) AS UPDATE_OBJECT
    , CAST(NULL AS nvarchar(max)) AS DELETE_OBJECT
FROM
    (VALUES
        ('formats'),
        ('workbooks'),
        ('usp_select_table')
        ) o(name)
WHERE
    EXISTS (
        SELECT
            p.name
        FROM
            sys.database_principals p
            INNER JOIN sys.database_role_members rm ON rm.member_principal_id = p.principal_id
        WHERE
            p.name = USER_NAME()
            AND rm.role_principal_id = USER_ID('tab_users')
            AND NOT rm.role_principal_id = USER_ID('tab_developers')
        )


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Query list of dynamic tables
-- =============================================

CREATE VIEW [tab].[xl_app_tables]
AS

SELECT
    t.table_schema AS TABLE_SCHEMA
    , t.table_name AS TABLE_NAME
    , CAST('CODE' AS nvarchar(128)) AS TABLE_TYPE
    , CAST(
        'EXEC tab.usp_select_table @table_id=' + CAST(t.id AS nvarchar)
        + (SELECT ', @' + p.name + COALESCE('= @' + c.parameter_name, '=NULL') FROM (VALUES ('p1'), ('p2'), ('p3'), ('p4'), ('p5'), ('p6')) p(name) LEFT OUTER JOIN tab.columns c ON c.parameter_name = p.name AND c.table_id = t.id FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)')
        + ', @data_language= @data_language'
        AS nvarchar(max)) AS TABLE_CODE
    , CAST(NULL AS nvarchar(max)) AS INSERT_PROCEDURE
    , CAST('EXEC tab.usp_select_table_update @id, ' + CAST(t.id AS nvarchar) + ', @json_changes_f2' AS nvarchar(max)) AS UPDATE_PROCEDURE
    , CAST(NULL AS nvarchar(max)) AS DELETE_PROCEDURE
    , CAST(NULL AS nvarchar(50)) AS PROCEDURE_TYPE
FROM
    tab.tables t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view generates application translation
-- =============================================

CREATE VIEW [tab].[xl_app_translations]
AS

SELECT
    t.table_schema AS TABLE_SCHEMA
    , t.table_name AS TABLE_NAME
    , CAST(NULL AS nvarchar) AS COLUMN_NAME
    , tr.language AS LANGUAGE_NAME
    , tr.name AS TRANSLATED_NAME
    , CAST(NULL AS nvarchar) AS TRANSLATED_DESC
    , CAST(NULL AS nvarchar) AS TRANSLATED_COMMENT
FROM
    tab.translations tr
    INNER JOIN tab.tables t ON t.id = tr.table_id
WHERE
    tr.type_id = 1
UNION ALL
SELECT
    t.table_schema AS TABLE_SCHEMA
    , t.table_name AS TABLE_NAME
    , c.name AS COLUMN_NAME
    , tr.language AS LANGUAGE_NAME
    , tr.name AS TRANSLATED_NAME
    , CAST(NULL AS nvarchar) AS TRANSLATED_DESC
    , CAST(NULL AS nvarchar) AS TRANSLATED_COMMENT
FROM
    tab.translations tr
    INNER JOIN tab.columns c ON c.id = tr.column_id
    INNER JOIN tab.tables t ON t.id = c.table_id
WHERE
    tr.type_id = 2

UNION ALL
SELECT
    t.table_schema AS TABLE_SCHEMA
    , t.table_name AS TABLE_NAME
    , c.parameter_name AS COLUMN_NAME
    , tr.language AS LANGUAGE_NAME
    , tr.name AS TRANSLATED_NAME
    , CAST(NULL AS nvarchar) AS TRANSLATED_DESC
    , CAST(NULL AS nvarchar) AS TRANSLATED_COMMENT
FROM
    tab.translations tr
    INNER JOIN tab.columns c ON c.id = tr.column_id
    INNER JOIN tab.tables t ON t.id = c.table_id
WHERE
    c.parameter_name IS NOT NULL
    AND tr.type_id = 2


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects data from dynamic tables
-- =============================================

CREATE PROCEDURE [tab].[usp_select_table]
    @table_id int = NULL
    , @p1 sql_variant = NULL
    , @p2 sql_variant = NULL
    , @p3 sql_variant = NULL
    , @p4 sql_variant = NULL
    , @p5 sql_variant = NULL
    , @p6 sql_variant = NULL
    , @data_language varchar(10) = NULL
AS
BEGIN

SET NOCOUNT ON;

IF @table_id IS NULL SET @table_id = (SELECT MIN(id) FROM tab.tables)

DECLARE @store_formulas int

SELECT @store_formulas = store_formulas FROM tab.tables WHERE id = @table_id

DECLARE @c1 int, @c2 int, @c3 int, @c4 int, @c5 int, @c6 int

IF @p1 IS NOT NULL OR @p2 IS NOT NULL OR @p3 IS NOT NULL OR @p4 IS NOT NULL OR @p5 IS NOT NULL OR @p6 IS NOT NULL
    BEGIN
    SELECT
        @c1 = p.p1, @c2 = p.p2, @c3 = p.p3, @c4 = p.p4, @c5 = p.p5, @c6 = p.p6
    FROM
        (
            SELECT
                c.parameter_name, c.id
            FROM
                tab.columns c
            WHERE
                c.table_id = @table_id AND c.parameter_name IS NOT NULL
        ) s
        PIVOT (MAX(id) FOR parameter_name IN ([p1], [p2], [p3], [p4], [p5], [p6])) p

    SELECT
        @p1 = tab.get_typed_value(@p1, [p1])
        , @p2 = tab.get_typed_value(@p2, [p2])
        , @p3 = tab.get_typed_value(@p3, [p3])
        , @p4 = tab.get_typed_value(@p4, [p4])
        , @p5 = tab.get_typed_value(@p5, [p5])
        , @p6 = tab.get_typed_value(@p6, [p6])
    FROM
        (
            SELECT
                c.parameter_name
                , c.type_id
            FROM
                tab.columns c
            WHERE
                c.table_id = @table_id AND c.parameter_name IS NOT NULL
            ) s
        PIVOT (MAX(type_id) FOR parameter_name IN ([p1], [p2], [p3], [p4], [p5], [p6])) p
    END

SELECT '{"parameters":'
    + '[{"name":"table_id"' + COALESCE(',"value":' + CAST(@table_id AS nvarchar(10)), '') + ',"is_nullable":0,"items":' + COALESCE((

    SELECT t.id, t.table_schema + '.' + t.table_name AS name FROM tab.tables t ORDER BY t.table_schema, t.table_name
    FOR JSON AUTO

    ), 'null') + '}' + COALESCE(',' + (

    SELECT
        v.name
        , COALESCE(p.name, v.name) AS caption
        , t.name AS datatype
        , CASE WHEN p.parameter_name IS NULL THEN 0 ELSE 1 END  AS is_nullable
        , CASE WHEN p.parameter_name IS NULL THEN 1 ELSE 0 END AS is_hidden
        , (
            SELECT
                DISTINCT
                CASE WHEN vc.id IS NULL THEN NULL ELSE c.row_id END AS id
                , CASE WHEN vc.id IS NULL THEN NULL ELSE COALESCE(t.name, c.value) END AS name
                , CASE WHEN vc.id IS NULL THEN CASE WHEN p.type_id = 40 THEN CONVERT(char(10), c.value, 23) ELSE c.value END ELSE NULL END AS value
            FROM
                tab.cells c
                LEFT OUTER JOIN tab.translations t ON
                    vc.translation_supported = 1 AND @data_language IS NOT NULL
                    AND t.type_id = 3 AND t.table_id IS NULL AND t.column_id = c.column_id AND t.row_id = c.row_id AND t.language = @data_language
            WHERE
                c.column_id = COALESCE(vc.id, p.id)
            ORDER BY
                name, id, value
            FOR JSON AUTO
            ) AS items
    FROM
        (VALUES ('p1'), ('p2'), ('p3'), ('p4'), ('p5'), ('p6')) v(name)
        LEFT OUTER JOIN tab.columns p ON p.table_id = @table_id AND p.parameter_name = v.name
        LEFT OUTER JOIN tab.types t ON t.id = p.type_id
        LEFT OUTER JOIN tab.columns vc ON vc.id = p.value_column_id
    --WHERE
    --    p.table_id = @table_id AND p.parameter_name IS NOT NULL
    ORDER BY
        v.name, p.column_id, p.id
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

    ), '') + ']'
    + ',"columns":' + COALESCE((

    SELECT c.id AS column_id, c.name, t.name AS datatype FROM tab.columns c INNER JOIN tab.types t ON t.id = c.type_id WHERE c.table_id = @table_id ORDER BY c.column_id, c.id
    FOR JSON PATH

    ), 'null')
    + ',"rows":' + CASE WHEN @store_formulas = 1 THEN COALESCE((

    SELECT r.id, r.cell_formulas, r.cell_comments FROM tab.rows r WHERE r.table_id = @table_id
        AND (@p1 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c1 AND value = @p1))
        AND (@p2 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c2 AND value = @p2))
        AND (@p3 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c3 AND value = @p3))
        AND (@p4 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c4 AND value = @p4))
        AND (@p5 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c5 AND value = @p5))
        AND (@p6 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c6 AND value = @p6))
    FOR JSON AUTO, INCLUDE_NULL_VALUES

    ), '[{"id":null,"cell_formulas":null,"cell_comments":null}]') ELSE COALESCE((

    SELECT r.id FROM tab.rows r WHERE r.table_id = @table_id
        AND (@p1 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c1 AND value = @p1))
        AND (@p2 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c2 AND value = @p2))
        AND (@p3 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c3 AND value = @p3))
        AND (@p4 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c4 AND value = @p4))
        AND (@p5 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c5 AND value = @p5))
        AND (@p6 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c6 AND value = @p6))
    FOR JSON AUTO

    ), '[{"id":null}]') END
    + ',"cells":' + COALESCE((

    SELECT
        c.row_id AS id
        , c.column_id
        , CAST(CASE WHEN p.type_id = 40 THEN CONVERT(char(10), c.value, 23) ELSE c.value END AS sql_variant) AS value
    FROM
        tab.cells c
        INNER JOIN tab.rows r ON r.id = c.row_id
        INNER JOIN tab.columns p ON p.id = c.column_id
    WHERE
        r.table_id = @table_id
        AND (@p1 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c1 AND value = @p1))
        AND (@p2 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c2 AND value = @p2))
        AND (@p3 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c3 AND value = @p3))
        AND (@p4 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c4 AND value = @p4))
        AND (@p5 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c5 AND value = @p5))
        AND (@p6 IS NULL OR r.id IN (SELECT row_id FROM tab.cells WHERE column_id = @c6 AND value = @p6))
    FOR JSON AUTO

    ),'[{"id":null,"column_id":null,"value":null}]') + '}' AS data

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Edit procedure for usp_select_table
-- =============================================

CREATE PROCEDURE [tab].[usp_select_table_update]
    @id int = NULL
    , @table_id int = NULL
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

IF @delete IS NOT NULL
    BEGIN

    DELETE FROM tab.rows
    FROM
        tab.rows t
        INNER JOIN (
            SELECT
                t2.[id] AS [id]
            FROM
                OPENJSON(@delete) WITH ([rows] nvarchar(max) '$.rows' AS json) t1
                CROSS APPLY OPENJSON(t1.[rows]) WITH ([id] int '$."id"') t2
        ) t2 ON t2.id = t.id
    END

IF @update IS NOT NULL
    BEGIN

    WITH cte (row_id, column_id, value) AS (
        SELECT
            t3.id AS row_id
            , f.id AS column_id
            , tab.get_typed_value(CAST(t4.value AS nvarchar), f.type_id) AS value
        FROM
            OPENJSON(@update) WITH ([rows] nvarchar(max) '$.rows' AS json) t1
            CROSS APPLY OPENJSON(t1.[rows]) t2
            CROSS APPLY OPENJSON(t2.[value]) WITH (id int '$."id"', cells nvarchar(max) '$.cells' AS json) t3
            CROSS APPLY OPENJSON(t3.[cells]) WITH (column_id int '$.column_id', value nvarchar(4000) '$.value') t4
            INNER JOIN tab.columns f ON f.table_id = @table_id AND f.id = t4.column_id
    )
    MERGE INTO tab.cells AS t
    USING cte AS s ON s.row_id = t.row_id AND s.column_id = t.column_id
    WHEN MATCHED THEN UPDATE SET value = s.value
    WHEN NOT MATCHED BY TARGET THEN INSERT (row_id, column_id, value) VALUES (s.row_id, s.column_id, s.value);

    UPDATE tab.rows
    SET
        cell_formulas = t2.cell_formulas
        , cell_comments = t2.cell_comments
    FROM
        OPENJSON(@update) WITH ([rows] nvarchar(max) '$.rows' AS json) t1
        CROSS APPLY OPENJSON(t1.[rows]) WITH ([id] int '$."id"', cell_formulas nvarchar(max) '$."cell_formulas"', cell_comments nvarchar(max) '$."cell_comments"') t2
        INNER JOIN tab.rows r ON r.id = t2.id
    WHERE
        NOT COALESCE(r.cell_formulas, '') = COALESCE(t2.cell_formulas, '')
        OR NOT COALESCE(r.cell_comments, '') = COALESCE(t2.cell_comments, '')

    END

IF @insert IS NOT NULL
    BEGIN

    DECLARE @ids TABLE (id int PRIMARY KEY)

    INSERT INTO tab.rows (table_id, cell_formulas, cell_comments)
    OUTPUT INSERTED.id INTO @ids (id)
    SELECT
        @table_id AS table_id
        , t2.cell_formulas
        , t2.cell_comments
    FROM
        OPENJSON(@insert) WITH ([rows] nvarchar(max) '$.rows' AS json) t1
        CROSS APPLY OPENJSON(t1.[rows]) WITH (cell_formulas nvarchar(max) '$."cell_formulas"', cell_comments nvarchar(max) '$."cell_comments"') t2

    DECLARE @base_id AS int = (SELECT MIN(id) FROM @ids);

    WITH cte (row_id, column_id, value) AS (
        SELECT
            @base_id + CAST(t2.[key] AS int) AS row_id
            , f.id AS column_id
            , tab.get_typed_value(t4.value, f.type_id) AS value
        FROM
            OPENJSON(@insert) WITH ([rows] nvarchar(max) '$.rows' AS json) t1
            CROSS APPLY OPENJSON(t1.[rows]) t2
            CROSS APPLY OPENJSON(t2.[value]) WITH (cells nvarchar(max) '$.cells' AS json) t3
            CROSS APPLY OPENJSON(t3.[cells]) WITH (column_id int '$.column_id', [value] nvarchar(4000) '$.value') t4
            INNER JOIN tab.columns f ON f.table_id = @table_id AND f.id = t4.column_id
    )
    INSERT INTO tab.cells (row_id, column_id, value)
    SELECT cte.row_id, column_id, value FROM cte;

    END

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects data translations
-- =============================================

CREATE PROCEDURE [tab].[usp_select_translations]
    @type_id int = NULL
    , @table_id int = NULL
    , @language varchar(10) = NULL
AS
BEGIN

SET NOCOUNT ON;

SELECT '{"parameters":['
    + '{"name":"type_id","is_nullable":true,"items":[{"id":1,"name":"Tables"},{"id":2,"name":"Columns"},{"id":3,"name":"Cells"}]}'
    + ',{"name":"table_id","is_nullable":true,"items":' + COALESCE((

    SELECT t.id, t.table_schema + '.' + t.table_name AS name FROM tab.tables t ORDER BY t.table_schema, t.table_name
    FOR JSON AUTO

    ), 'null') + '}'
    + ',{"name":"language","is_nullable":true,"items":' + COALESCE((

    SELECT t.language FROM tab.languages t ORDER BY t.sort_order, t.language
    FOR JSON AUTO

    ), 'null') + '}'
    + '],"rows":' + COALESCE((

    SELECT type_id, table_id, column_id, row_id, table_schema, table_name, column_name, value AS name FROM (
        SELECT
            1 AS type_id, t.id AS table_id, NULL AS column_id, NULL AS row_id, t.table_schema, t.table_name, NULL AS column_name, NULL AS value
        FROM
            tab.tables t
        WHERE
            COALESCE(@type_id, 1) = 1
            AND t.id = COALESCE(@table_id, t.id)
        UNION ALL
        SELECT
            2 AS type_id, NULL AS table_id, c.id AS column_id, NULL AS row_id, t.table_schema, t.table_name, c.name AS column_name, NULL AS value
        FROM
            tab.columns c
            INNER JOIN tab.tables t ON t.id = c.table_id
        WHERE
            COALESCE(@type_id, 2) = 2
            AND c.table_id = COALESCE(@table_id, c.table_id)
        UNION ALL
        SELECT
            3 AS type_id, NULL AS table_id, c.id AS column_id, d.row_id, t.table_schema, t.table_name, c.name AS column_name, d.value
        FROM
            tab.cells d
            INNER JOIN tab.columns c ON c.id = d.column_id
            INNER JOIN tab.types ct ON ct.id = c.type_id
            INNER JOIN tab.tables t ON t.id = c.table_id
        WHERE
            COALESCE(@type_id, 3) = 3
            AND c.table_id = COALESCE(@table_id, c.table_id)
            AND c.translation_supported = 1
            AND ct.translation_supported = 1
    ) t
    ORDER BY type_id, table_schema, table_name, column_name, name
    FOR JSON AUTO, INCLUDE_NULL_VALUES

    ), '[{"type_id":null,"table_id":null,"column_id":null,"row_id":null,"table_schema":null,"table_name":null,"column_name":null,"name":null}]')
    + ',"columns":' + COALESCE((

    SELECT language FROM tab.languages WHERE language = COALESCE(@language, language) ORDER BY sort_order, language
    FOR JSON AUTO

    ), 'null') + ',"cells":' + COALESCE((

    SELECT
        t.type_id, t.table_id, t.column_id, t.row_id, t.language, t.name AS value
    FROM
        tab.translations t
        LEFT OUTER JOIN tab.columns c ON c.id = t.column_id
    WHERE
        t.type_id = COALESCE(@type_id, t.type_id)
        AND COALESCE(t.table_id, c.table_id) = COALESCE(@table_id, t.table_id, c.table_id)
        AND t.language = COALESCE(@language, language)
    FOR JSON AUTO

    ),'[{"type_id":null,"table_id":null,"column_id":null,"row_id":null,"language":null,"value":null}]') + '}' AS data

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Cell change handler for usp_select_translations
-- =============================================

CREATE PROCEDURE [tab].[usp_select_translations_change]
    @type_id tinyint = NULL
    , @table_id int = NULL
    , @column_id int = NULL
    , @row_id int = NULL
    , @columnname nvarchar(128) = NULL
    , @cell_value nvarchar(255) = NULL
    , @changed_cell_count int = NULL
AS
BEGIN
SET NOCOUNT ON

IF @columnname IS NULL
    RETURN
IF @type_id = 1 AND (@table_id IS NULL OR @column_id IS NOT NULL OR @row_id IS NOT NULL)
    RETURN
IF @type_id = 2 AND (@column_id IS NULL OR @row_id IS NOT NULL)
    RETURN
IF @type_id = 3 AND (@column_id IS NULL OR @row_id IS NULL)
    RETURN

IF NOT EXISTS (SELECT language FROM tab.languages WHERE language = @columnname)
    BEGIN
    -- IF @changed_cell_count = 1
    RAISERROR('Do not change the %s column', 11, 1, @columnname)
    RETURN
    END

MERGE tab.translations AS t
USING (
    SELECT
        @type_id AS type_id
        , CASE WHEN @type_id = 1 THEN @table_id ELSE NULL END AS table_id
        , @column_id AS column_id
        , @row_id AS row_id
        , @columnname AS language
        , @cell_value AS name
) s ON t.type_id = s.type_id
    AND (t.table_id = s.table_id OR t.table_id IS NULL AND s.table_id IS NULL)
    AND (t.column_id = s.column_id OR t.column_id IS NULL AND s.column_id IS NULL)
    AND (t.row_id = s.row_id OR t.row_id IS NULL AND s.row_id IS NULL)
    AND t.language = s.language
WHEN MATCHED AND s.name IS NULL THEN DELETE
WHEN MATCHED THEN UPDATE SET name = s.name
WHEN NOT MATCHED THEN INSERT (type_id, table_id, column_id, row_id, language, name) VALUES (s.type_id, s.table_id, s.column_id, s.row_id, s.language, s.name)
;

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects dynamic tables
-- =============================================

CREATE PROCEDURE [tab].[xl_actions_export_data]
AS
BEGIN

SET NOCOUNT ON;

SELECT
    s.command
FROM
    (
SELECT
    v.part
    , v.sort_order
    , v.command
FROM
    (VALUES
        ((1), (0), 'SET IDENTITY_INSERT tab.tables ON;')
        , ((1), (10000), 'SET IDENTITY_INSERT tab.tables OFF;')
        , ((1), (10001), 'GO')
        , ((1), (10002), NULL)
        , ((2), (0), 'SET IDENTITY_INSERT tab.columns ON;')
        , ((2), (10000), 'SET IDENTITY_INSERT tab.columns OFF;')
        , ((2), (10001), 'GO')
        , ((2), (10002), NULL)
        , ((3), (0), 'SET IDENTITY_INSERT tab.rows ON;')
        , ((3), (10000), 'SET IDENTITY_INSERT tab.rows OFF;')
        , ((3), (10001), 'GO')
        , ((3), (10002), NULL)
        , ((4), (10001), 'GO')
        , ((4), (10002), NULL)
        , ((5), (10001), 'GO')
        , ((5), (10002), NULL)
        , ((6), (10001), 'GO')
        , ((6), (10002), NULL)
        , ((7), (10001), 'GO')
        , ((7), (10002), NULL)
        , ((8), (10001), 'GO')
        , ((8), (10002), NULL)
    ) v(part, sort_order, command)
UNION ALL
SELECT
    1 AS part
    , ROW_NUMBER() OVER(ORDER BY t.id) AS sort_order
    , 'INSERT INTO tab.tables (id, table_schema, table_name, store_formulas, protect_rows, do_not_save) VALUES ('
        + CAST(t.id AS nvarchar)
        + ', ' + CASE WHEN t.table_schema IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(t.table_schema, '''', '''''') + '''' END
        + ', ' + CASE WHEN t.table_name IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(t.table_name, '''', '''''') + '''' END
        + ', ' + CASE WHEN t.store_formulas IS NULL THEN 'NULL' ELSE CAST(t.store_formulas AS nvarchar) END
        + ', ' + CASE WHEN t.protect_rows IS NULL THEN 'NULL' ELSE CAST(t.protect_rows AS nvarchar) END
        + ', ' + CASE WHEN t.do_not_save IS NULL THEN 'NULL' ELSE CAST(t.do_not_save AS nvarchar) END
        + ');' AS command
FROM
    tab.tables t
UNION ALL
SELECT
    2 AS part
    , ROW_NUMBER() OVER(ORDER BY c.id) AS sort_order
    , 'INSERT INTO tab.columns (id, table_id, name, column_id, type_id, max_length, value_table_id, value_column_id, parameter_name, translation_supported, do_not_change) VALUES ('
        + CAST(c.id AS nvarchar)
        + ', ' + CAST(c.table_id AS nvarchar)
        + ', ' + CASE WHEN c.name IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(c.name, '''', '''''') + '''' END
        + ', ' + CASE WHEN c.column_id IS NULL THEN 'NULL' ELSE CAST(c.column_id AS nvarchar) END
        + ', ' + CASE WHEN c.type_id IS NULL THEN 'NULL' ELSE CAST(c.type_id AS nvarchar) END
        + ', ' + CASE WHEN c.max_length IS NULL THEN 'NULL' ELSE CAST(c.max_length AS nvarchar) END
        + ', ' + CASE WHEN c.value_table_id IS NULL THEN 'NULL' ELSE CAST(c.value_table_id AS nvarchar) END
        + ', ' + CASE WHEN c.value_column_id IS NULL THEN 'NULL' ELSE CAST(c.value_column_id AS nvarchar) END
        + ', ' + CASE WHEN c.parameter_name IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(c.parameter_name, '''', '''''') + '''' END
        + ', ' + CASE WHEN c.translation_supported IS NULL THEN 'NULL' ELSE CAST(c.translation_supported AS nvarchar) END
        + ', ' + CASE WHEN c.do_not_change IS NULL THEN 'NULL' ELSE CAST(c.do_not_change AS nvarchar) END
        + ');' AS command
FROM
    tab.columns c
    INNER JOIN tab.tables t ON t.id = c.table_id
UNION ALL
SELECT
    3 AS part
    , ROW_NUMBER() OVER(ORDER BY r.id) AS sort_order
    , 'INSERT INTO tab.rows (id, table_id, cell_formulas, cell_comments) VALUES ('
        + CAST(r.id AS nvarchar)
        + ', ' + CAST(r.table_id AS nvarchar)
        + ', ' + CASE WHEN r.cell_formulas IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(r.cell_formulas, '''', '''''') + '''' END
        + ', ' + CASE WHEN r.cell_comments IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(r.cell_comments, '''', '''''') + '''' END
        + ');' AS command
FROM
    tab.rows r
    INNER JOIN tab.tables t ON t.id = r.table_id
UNION ALL
SELECT
    4 AS part
    , ROW_NUMBER() OVER(ORDER BY m.table_id, c.column_id, c.value, c.row_id) AS sort_order
    , 'INSERT INTO tab.cells (row_id, column_id, value) VALUES ('
        + CAST(c.row_id AS nvarchar)
        + ', ' + CAST(c.column_id AS nvarchar)
        + ', ' + CASE WHEN c.value IS NULL THEN 'NULL' ELSE
            CASE
                WHEN t.name IN ('varchar', 'nvarchar') THEN 'N''' + REPLACE(CAST(c.value AS nvarchar), '''', '''''') + ''''
                WHEN t.name IN ('char', 'nchar') THEN 'N''' + REPLACE(CAST(c.value AS nvarchar), '''', '''''') + ''''
                WHEN t.name IN ('date') THEN 'CAST(''' + CONVERT(nvarchar, c.value, 120) + ''' AS ' + t.name + ')'
                WHEN t.name IN ('time') THEN 'CAST(''' + CONVERT(nvarchar, c.value, 114) + ''' AS ' + t.name + ')'
                WHEN t.name IN ('datetime', 'datetime2', 'smalldatetime') THEN 'CAST(''' + CONVERT(nvarchar, c.value, 120) + ''' AS ' + t.name + ')'
                WHEN t.name IN ('date') THEN 'CAST(''' + CONVERT(nvarchar, c.value, 120) + ''' AS ' + t.name + ')'
                WHEN t.name IN ('datetimeoffset') THEN 'CAST(''' + CONVERT(nvarchar, c.value, 127) + ''' AS ' + t.name + ')'
                WHEN t.name IN ('uniqueidentifier') THEN 'CAST(''' + CAST(c.value AS nvarchar) + ''' AS ' + t.name + ')'
                ELSE 'CAST(' + CAST(c.value AS nvarchar) + ' AS ' + t.name + ')'
            END
            END
        + ');' AS command
FROM
    tab.cells c
    INNER JOIN tab.columns m ON m.id = c.column_id
    INNER JOIN tab.types t ON t.id = m.type_id
UNION ALL
SELECT
    5 AS part
    , ROW_NUMBER() OVER(ORDER BY t.language) AS ID
    , 'INSERT INTO tab.languages (language, sort_order) VALUES ('
        + 'N''' + REPLACE(t.language, '''', '''''') + ''''
        + ', ' + CASE WHEN t.sort_order IS NULL THEN 'NULL' ELSE CAST(t.sort_order AS nvarchar) END
        + ');' AS command
FROM
    tab.languages t
UNION ALL
SELECT
    6 AS part
    , ROW_NUMBER() OVER(ORDER BY language, type_id, table_id, column_id, row_id, name) AS ID
    , 'INSERT INTO tab.translations (type_id, table_id, column_id, row_id, language, name) VALUES ('
        + CAST(type_id AS nvarchar)
        + ', ' + CASE WHEN table_id IS NULL THEN 'NULL' ELSE CAST(table_id AS nvarchar) END
        + ', ' + CASE WHEN column_id IS NULL THEN 'NULL' ELSE CAST(column_id AS nvarchar) END
        + ', ' + CASE WHEN row_id IS NULL THEN 'NULL' ELSE CAST(row_id AS nvarchar) END
        + ', ' + CASE WHEN language IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(language, '''', '''''') + '''' END
        + ', ' + CASE WHEN name IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(CAST(name AS nvarchar(max)), '''', '''''') + '''' END
        + ');' AS command
FROM
    tab.translations t
UNION ALL
SELECT
    7 AS part
    , ROW_NUMBER() OVER(ORDER BY NAME, TEMPLATE) AS sort_order
    , 'INSERT INTO tab.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES ('
        + CASE WHEN NAME IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(NAME, '''', '''''') + '''' END
        + ', ' + CASE WHEN TEMPLATE IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TEMPLATE, '''', '''''') + '''' END
        + ', ' + CASE WHEN DEFINITION IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(DEFINITION, '''', '''''') + '''' END
        + ', ' + CASE WHEN TABLE_SCHEMA IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TABLE_SCHEMA, '''', '''''') + '''' END
        + ');' AS command
FROM
    tab.workbooks
WHERE
    NOT TABLE_SCHEMA IN ('tab')
UNION ALL
SELECT
    8 AS part
    , ROW_NUMBER() OVER(ORDER BY TABLE_SCHEMA, TABLE_NAME) AS sort_order
    , 'INSERT INTO tab.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES ('
        + CASE WHEN TABLE_SCHEMA IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TABLE_SCHEMA, '''', '''''') + '''' END
        + ', ' + CASE WHEN TABLE_NAME IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(TABLE_NAME, '''', '''''') + '''' END
        + ', ' + CASE WHEN TABLE_EXCEL_FORMAT_XML IS NULL THEN 'NULL' ELSE 'N''' + REPLACE(CAST(TABLE_EXCEL_FORMAT_XML AS nvarchar(max)), '''', '''''') + '''' END
        + ');' AS command
FROM
    tab.formats f
WHERE
    NOT TABLE_SCHEMA IN ('tab')
    ) s
ORDER BY
    s.part
    , s.sort_order
    , s.command

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects values for a validation list
-- =============================================

CREATE PROCEDURE [tab].[xl_list_by_column_id]
    @column_id int = NULL
    , @data_language varchar(10) = NULL
AS
BEGIN

SET NOCOUNT ON;

IF @data_language IS NULL
    SELECT c.row_id AS id, c.value AS name FROM tab.cells c WHERE c.column_id = @column_id ORDER BY name, id
ELSE
    SELECT
        c.row_id AS id
        , COALESCE(t.name, c.value) AS name
    FROM
        tab.cells c
        LEFT OUTER JOIN tab.translations t ON t.type_id = 3 AND t.table_id IS NULL AND t.column_id = c.column_id AND t.row_id = c.row_id AND t.language = @data_language
    WHERE
        c.column_id = @column_id
    ORDER BY
        name, id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects dynamic tables
-- =============================================

CREATE PROCEDURE [tab].[xl_list_table_id]
    @data_language varchar(10) = NULL
AS
BEGIN

SET NOCOUNT ON;

IF @data_language IS NULL
    SELECT c.id, c.table_name AS name FROM tab.tables c ORDER BY name, id
ELSE
    SELECT
        c.id
        , COALESCE(t.name, c.table_name) AS name
    FROM
        tab.tables c
        LEFT OUTER JOIN tab.translations t ON t.type_id = 1 AND t.table_id = c.id AND t.column_id IS NULL AND t.row_id IS NULL AND t.language = @data_language
    ORDER BY
        name, id

END


GO

INSERT INTO tab.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'tab', N'columns', N'<table name="tab.columns"><columnFormats><column name="" property="ListObjectName" value="columns" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="id" property="Address" value="$C$4" type="String"/><column name="id" property="NumberFormat" value="General" type="String"/><column name="id" property="Validation.Type" value="1" type="Double"/><column name="id" property="Validation.Operator" value="1" type="Double"/><column name="id" property="Validation.Formula1" value="-2147483648" type="String"/><column name="id" property="Validation.Formula2" value="2147483647" type="String"/><column name="id" property="Validation.AlertStyle" value="2" type="Double"/><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="id" property="Validation.ShowInput" value="True" type="Boolean"/><column name="id" property="Validation.ShowError" value="True" type="Boolean"/><column name="table_id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="table_id" property="Address" value="$D$4" type="String"/><column name="table_id" property="ColumnWidth" value="17.14" type="Double"/><column name="table_id" property="NumberFormat" value="General" type="String"/><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="name" property="Address" value="$E$4" type="String"/><column name="name" property="ColumnWidth" value="20.71" type="Double"/><column name="name" property="NumberFormat" value="General" type="String"/><column name="name" property="Validation.Type" value="6" type="Double"/><column name="name" property="Validation.Operator" value="8" type="Double"/><column name="name" property="Validation.Formula1" value="50" type="String"/><column name="name" property="Validation.AlertStyle" value="2" type="Double"/><column name="name" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="name" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="name" property="Validation.ShowInput" value="True" type="Boolean"/><column name="name" property="Validation.ShowError" value="True" type="Boolean"/><column name="column_id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="column_id" property="Address" value="$F$4" type="String"/><column name="column_id" property="ColumnWidth" value="11.86" type="Double"/><column name="column_id" property="NumberFormat" value="General" type="String"/><column name="column_id" property="Validation.Type" value="1" type="Double"/><column name="column_id" property="Validation.Operator" value="1" type="Double"/><column name="column_id" property="Validation.Formula1" value="-2147483648" type="String"/><column name="column_id" property="Validation.Formula2" value="2147483647" type="String"/><column name="column_id" property="Validation.AlertStyle" value="2" type="Double"/><column name="column_id" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="column_id" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="column_id" property="Validation.ShowInput" value="True" type="Boolean"/><column name="column_id" property="Validation.ShowError" value="True" type="Boolean"/><column name="type_id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="type_id" property="Address" value="$G$4" type="String"/><column name="type_id" property="ColumnWidth" value="14" type="Double"/><column name="type_id" property="NumberFormat" value="General" type="String"/><column name="max_length" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="max_length" property="Address" value="$H$4" type="String"/><column name="max_length" property="ColumnWidth" value="13" type="Double"/><column name="max_length" property="NumberFormat" value="General" type="String"/><column name="max_length" property="Validation.Type" value="1" type="Double"/><column name="max_length" property="Validation.Operator" value="1" type="Double"/><column name="max_length" property="Validation.Formula1" value="-2147483648" type="String"/><column name="max_length" property="Validation.Formula2" value="2147483647" type="String"/><column name="max_length" property="Validation.AlertStyle" value="2" type="Double"/><column name="max_length" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="max_length" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="max_length" property="Validation.ShowInput" value="True" type="Boolean"/><column name="max_length" property="Validation.ShowError" value="True" type="Boolean"/><column name="value_table_id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="value_table_id" property="Address" value="$I$4" type="String"/><column name="value_table_id" property="ColumnWidth" value="20.71" type="Double"/><column name="value_table_id" property="NumberFormat" value="General" type="String"/><column name="value_column_id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="value_column_id" property="Address" value="$J$4" type="String"/><column name="value_column_id" property="ColumnWidth" value="20.71" type="Double"/><column name="value_column_id" property="NumberFormat" value="General" type="String"/><column name="parameter_name" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="parameter_name" property="Address" value="$K$4" type="String"/><column name="parameter_name" property="ColumnWidth" value="18" type="Double"/><column name="parameter_name" property="NumberFormat" value="General" type="String"/><column name="parameter_name" property="Validation.Type" value="3" type="Double"/><column name="parameter_name" property="Validation.Operator" value="1" type="Double"/><column name="parameter_name" property="Validation.Formula1" value="; p1; p2; p3; p4; p5; p6" type="String"/><column name="parameter_name" property="Validation.AlertStyle" value="1" type="Double"/><column name="parameter_name" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="parameter_name" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="parameter_name" property="Validation.ShowInput" value="True" type="Boolean"/><column name="parameter_name" property="Validation.ShowError" value="True" type="Boolean"/><column name="translation_supported" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="translation_supported" property="Address" value="$L$4" type="String"/><column name="translation_supported" property="ColumnWidth" value="22.57" type="Double"/><column name="translation_supported" property="NumberFormat" value="General" type="String"/><column name="translation_supported" property="HorizontalAlignment" value="-4108" type="Double"/><column name="translation_supported" property="Font.Size" value="9" type="Double"/><column name="do_not_change" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="do_not_change" property="Address" value="$M$4" type="String"/><column name="do_not_change" property="ColumnWidth" value="16.29" type="Double"/><column name="do_not_change" property="NumberFormat" value="General" type="String"/><column name="do_not_change" property="HorizontalAlignment" value="-4108" type="Double"/><column name="do_not_change" property="Font.Size" value="9" type="Double"/><column name="translation_supported" property="FormatConditions(1).AppliesTo.Address" value="$L$4:$L$12" type="String"/><column name="translation_supported" property="FormatConditions(1).Type" value="6" type="Double"/><column name="translation_supported" property="FormatConditions(1).Priority" value="2" type="Double"/><column name="translation_supported" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean"/><column name="translation_supported" property="FormatConditions(1).IconSet.ID" value="8" type="Double"/><column name="translation_supported" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double"/><column name="translation_supported" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double"/><column name="translation_supported" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double"/><column name="translation_supported" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double"/><column name="translation_supported" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double"/><column name="translation_supported" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double"/><column name="translation_supported" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double"/><column name="translation_supported" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double"/><column name="do_not_change" property="FormatConditions(1).AppliesTo.Address" value="$M$4:$M$12" type="String"/><column name="do_not_change" property="FormatConditions(1).Type" value="6" type="Double"/><column name="do_not_change" property="FormatConditions(1).Priority" value="1" type="Double"/><column name="do_not_change" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean"/><column name="do_not_change" property="FormatConditions(1).IconSet.ID" value="8" type="Double"/><column name="do_not_change" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double"/><column name="do_not_change" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double"/><column name="do_not_change" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double"/><column name="do_not_change" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double"/><column name="do_not_change" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double"/><column name="do_not_change" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double"/><column name="do_not_change" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double"/><column name="do_not_change" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double"/><column name="SortFields(1)" property="KeyfieldName" value="table_id" type="String"/><column name="SortFields(1)" property="SortOn" value="0" type="Double"/><column name="SortFields(1)" property="Order" value="1" type="Double"/><column name="SortFields(1)" property="DataOption" value="2" type="Double"/><column name="SortFields(2)" property="KeyfieldName" value="column_id" type="String"/><column name="SortFields(2)" property="SortOn" value="0" type="Double"/><column name="SortFields(2)" property="Order" value="1" type="Double"/><column name="SortFields(2)" property="DataOption" value="2" type="Double"/><column name="SortFields(3)" property="KeyfieldName" value="name" type="String"/><column name="SortFields(3)" property="SortOn" value="0" type="Double"/><column name="SortFields(3)" property="Order" value="1" type="Double"/><column name="SortFields(3)" property="DataOption" value="2" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
INSERT INTO tab.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'tab', N'languages', N'<table name="tab.languages"><columnFormats><column name="" property="ListObjectName" value="languages" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="language" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="language" property="Address" value="$C$4" type="String"/><column name="language" property="ColumnWidth" value="10.57" type="Double"/><column name="language" property="NumberFormat" value="General" type="String"/><column name="language" property="Validation.Type" value="6" type="Double"/><column name="language" property="Validation.Operator" value="8" type="Double"/><column name="language" property="Validation.Formula1" value="10" type="String"/><column name="language" property="Validation.AlertStyle" value="2" type="Double"/><column name="language" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="language" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="language" property="Validation.ShowInput" value="True" type="Boolean"/><column name="language" property="Validation.ShowError" value="True" type="Boolean"/><column name="sort_order" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="sort_order" property="Address" value="$D$4" type="String"/><column name="sort_order" property="ColumnWidth" value="11.86" type="Double"/><column name="sort_order" property="NumberFormat" value="General" type="String"/><column name="sort_order" property="Validation.Type" value="1" type="Double"/><column name="sort_order" property="Validation.Operator" value="1" type="Double"/><column name="sort_order" property="Validation.Formula1" value="0" type="String"/><column name="sort_order" property="Validation.Formula2" value="255" type="String"/><column name="sort_order" property="Validation.AlertStyle" value="2" type="Double"/><column name="sort_order" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="sort_order" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="sort_order" property="Validation.ShowInput" value="True" type="Boolean"/><column name="sort_order" property="Validation.ShowError" value="True" type="Boolean"/><column name="language" property="FormatConditions(1).AppliesTo.Address" value="$C$4:$C$14" type="String"/><column name="language" property="FormatConditions(1).Type" value="2" type="Double"/><column name="language" property="FormatConditions(1).Priority" value="1" type="Double"/><column name="language" property="FormatConditions(1).Formula1" value="=ISBLANK(C4)" type="String"/><column name="language" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="SortFields(1)" property="KeyfieldName" value="sort_order" type="String"/><column name="SortFields(1)" property="SortOn" value="0" type="Double"/><column name="SortFields(1)" property="Order" value="1" type="Double"/><column name="SortFields(1)" property="DataOption" value="0" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
INSERT INTO tab.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'tab', N'tables', N'<table name="tab.tables"><columnFormats><column name="" property="ListObjectName" value="tables" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="id" property="Address" value="$C$4" type="String"/><column name="id" property="NumberFormat" value="General" type="String"/><column name="id" property="Validation.Type" value="1" type="Double"/><column name="id" property="Validation.Operator" value="1" type="Double"/><column name="id" property="Validation.Formula1" value="-2147483648" type="String"/><column name="id" property="Validation.Formula2" value="2147483647" type="String"/><column name="id" property="Validation.AlertStyle" value="2" type="Double"/><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="id" property="Validation.ShowInput" value="True" type="Boolean"/><column name="id" property="Validation.ShowError" value="True" type="Boolean"/><column name="table_schema" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="table_schema" property="Address" value="$D$4" type="String"/><column name="table_schema" property="ColumnWidth" value="15" type="Double"/><column name="table_schema" property="NumberFormat" value="General" type="String"/><column name="table_schema" property="Validation.Type" value="6" type="Double"/><column name="table_schema" property="Validation.Operator" value="8" type="Double"/><column name="table_schema" property="Validation.Formula1" value="20" type="String"/><column name="table_schema" property="Validation.AlertStyle" value="2" type="Double"/><column name="table_schema" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="table_schema" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="table_schema" property="Validation.ShowInput" value="True" type="Boolean"/><column name="table_schema" property="Validation.ShowError" value="True" type="Boolean"/><column name="table_name" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="table_name" property="Address" value="$E$4" type="String"/><column name="table_name" property="ColumnWidth" value="13.14" type="Double"/><column name="table_name" property="NumberFormat" value="General" type="String"/><column name="table_name" property="Validation.Type" value="6" type="Double"/><column name="table_name" property="Validation.Operator" value="8" type="Double"/><column name="table_name" property="Validation.Formula1" value="128" type="String"/><column name="table_name" property="Validation.AlertStyle" value="2" type="Double"/><column name="table_name" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="table_name" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="table_name" property="Validation.ShowInput" value="True" type="Boolean"/><column name="table_name" property="Validation.ShowError" value="True" type="Boolean"/><column name="store_formulas" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="store_formulas" property="Address" value="$F$4" type="String"/><column name="store_formulas" property="ColumnWidth" value="16.14" type="Double"/><column name="store_formulas" property="NumberFormat" value="General" type="String"/><column name="store_formulas" property="HorizontalAlignment" value="-4108" type="Double"/><column name="store_formulas" property="Font.Size" value="9" type="Double"/><column name="protect_rows" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="protect_rows" property="Address" value="$G$4" type="String"/><column name="protect_rows" property="ColumnWidth" value="14.29" type="Double"/><column name="protect_rows" property="NumberFormat" value="General" type="String"/><column name="protect_rows" property="HorizontalAlignment" value="-4108" type="Double"/><column name="protect_rows" property="Font.Size" value="9" type="Double"/><column name="do_not_save" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="do_not_save" property="Address" value="$H$4" type="String"/><column name="do_not_save" property="ColumnWidth" value="13.86" type="Double"/><column name="do_not_save" property="NumberFormat" value="General" type="String"/><column name="do_not_save" property="HorizontalAlignment" value="-4108" type="Double"/><column name="do_not_save" property="Font.Size" value="9" type="Double"/><column name="store_formulas" property="FormatConditions(1).AppliesTo.Address" value="$F$4:$F$7" type="String"/><column name="store_formulas" property="FormatConditions(1).Type" value="6" type="Double"/><column name="store_formulas" property="FormatConditions(1).Priority" value="3" type="Double"/><column name="store_formulas" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean"/><column name="store_formulas" property="FormatConditions(1).IconSet.ID" value="8" type="Double"/><column name="store_formulas" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double"/><column name="store_formulas" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double"/><column name="store_formulas" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double"/><column name="store_formulas" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double"/><column name="store_formulas" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double"/><column name="store_formulas" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double"/><column name="store_formulas" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double"/><column name="store_formulas" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double"/><column name="protect_rows" property="FormatConditions(1).AppliesTo.Address" value="$G$4:$G$7" type="String"/><column name="protect_rows" property="FormatConditions(1).Type" value="6" type="Double"/><column name="protect_rows" property="FormatConditions(1).Priority" value="2" type="Double"/><column name="protect_rows" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean"/><column name="protect_rows" property="FormatConditions(1).IconSet.ID" value="8" type="Double"/><column name="protect_rows" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double"/><column name="protect_rows" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double"/><column name="protect_rows" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double"/><column name="protect_rows" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double"/><column name="protect_rows" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double"/><column name="protect_rows" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double"/><column name="protect_rows" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double"/><column name="protect_rows" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double"/><column name="do_not_save" property="FormatConditions(1).AppliesTo.Address" value="$H$4:$H$7" type="String"/><column name="do_not_save" property="FormatConditions(1).Type" value="6" type="Double"/><column name="do_not_save" property="FormatConditions(1).Priority" value="1" type="Double"/><column name="do_not_save" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean"/><column name="do_not_save" property="FormatConditions(1).IconSet.ID" value="8" type="Double"/><column name="do_not_save" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double"/><column name="do_not_save" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double"/><column name="do_not_save" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double"/><column name="do_not_save" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double"/><column name="do_not_save" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double"/><column name="do_not_save" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double"/><column name="do_not_save" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double"/><column name="do_not_save" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double"/><column name="SortFields(1)" property="KeyfieldName" value="table_name" type="String"/><column name="SortFields(1)" property="SortOn" value="0" type="Double"/><column name="SortFields(1)" property="Order" value="1" type="Double"/><column name="SortFields(1)" property="DataOption" value="2" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
INSERT INTO tab.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'tab', N'users', N'<table name="tab.users"><columnFormats><column name="" property="ListObjectName" value="users" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="user" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="user" property="Address" value="$C$4" type="String"/><column name="user" property="ColumnWidth" value="20.71" type="Double"/><column name="user" property="NumberFormat" value="General" type="String"/><column name="role" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="role" property="Address" value="$D$4" type="String"/><column name="role" property="ColumnWidth" value="20.71" type="Double"/><column name="role" property="NumberFormat" value="General" type="String"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
INSERT INTO tab.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'tab', N'usp_select_translations', N'<table name="tab.usp_select_translations"><columnFormats><column name="" property="ListObjectName" value="translations" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="type_id" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="type_id" property="Address" value="$C$4" type="String"/><column name="type_id" property="NumberFormat" value="General" type="String"/><column name="table_id" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="table_id" property="Address" value="$D$4" type="String"/><column name="table_id" property="NumberFormat" value="General" type="String"/><column name="column_id" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="column_id" property="Address" value="$E$4" type="String"/><column name="column_id" property="NumberFormat" value="General" type="String"/><column name="row_id" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="row_id" property="Address" value="$F$4" type="String"/><column name="row_id" property="NumberFormat" value="General" type="String"/><column name="table_schema" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="table_schema" property="Address" value="$G$4" type="String"/><column name="table_schema" property="ColumnWidth" value="14.71" type="Double"/><column name="table_schema" property="NumberFormat" value="General" type="String"/><column name="table_name" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="table_name" property="Address" value="$H$4" type="String"/><column name="table_name" property="ColumnWidth" value="13" type="Double"/><column name="table_name" property="NumberFormat" value="General" type="String"/><column name="column_name" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="column_name" property="Address" value="$I$4" type="String"/><column name="column_name" property="ColumnWidth" value="15" type="Double"/><column name="column_name" property="NumberFormat" value="General" type="String"/><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="name" property="Address" value="$J$4" type="String"/><column name="name" property="ColumnWidth" value="19.86" type="Double"/><column name="name" property="NumberFormat" value="General" type="String"/><column name="en" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="en" property="Address" value="$K$4" type="String"/><column name="en" property="ColumnWidth" value="19.86" type="Double"/><column name="en" property="NumberFormat" value="General" type="String"/><column name="fr" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="fr" property="Address" value="$L$4" type="String"/><column name="fr" property="ColumnWidth" value="19.71" type="Double"/><column name="fr" property="NumberFormat" value="General" type="String"/><column name="it" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="it" property="Address" value="$M$4" type="String"/><column name="it" property="ColumnWidth" value="29.86" type="Double"/><column name="it" property="NumberFormat" value="General" type="String"/><column name="es" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="es" property="Address" value="$N$4" type="String"/><column name="es" property="ColumnWidth" value="25.14" type="Double"/><column name="es" property="NumberFormat" value="General" type="String"/><column name="pt" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="pt" property="Address" value="$O$4" type="String"/><column name="pt" property="ColumnWidth" value="25.71" type="Double"/><column name="pt" property="NumberFormat" value="General" type="String"/><column name="de" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="de" property="Address" value="$P$4" type="String"/><column name="de" property="ColumnWidth" value="26.86" type="Double"/><column name="de" property="NumberFormat" value="General" type="String"/><column name="ru" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="ru" property="Address" value="$Q$4" type="String"/><column name="ru" property="ColumnWidth" value="17.29" type="Double"/><column name="ru" property="NumberFormat" value="General" type="String"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
INSERT INTO tab.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'tab', N'workbooks', N'<table name="tab.workbooks"><columnFormats><column name="" property="ListObjectName" value="workbooks" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="_RowNum" property="VerticalAlignment" value="-4160" type="Double"/><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="ID" property="Address" value="$C$4" type="String"/><column name="ID" property="ColumnWidth" value="4.43" type="Double"/><column name="ID" property="NumberFormat" value="General" type="String"/><column name="ID" property="VerticalAlignment" value="-4160" type="Double"/><column name="ID" property="Validation.Type" value="1" type="Double"/><column name="ID" property="Validation.Operator" value="1" type="Double"/><column name="ID" property="Validation.Formula1" value="-2147483648" type="String"/><column name="ID" property="Validation.Formula2" value="2147483647" type="String"/><column name="ID" property="Validation.AlertStyle" value="2" type="Double"/><column name="ID" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="ID" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="ID" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="ID" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String"/><column name="ID" property="Validation.ShowInput" value="True" type="Boolean"/><column name="ID" property="Validation.ShowError" value="True" type="Boolean"/><column name="NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="NAME" property="Address" value="$D$4" type="String"/><column name="NAME" property="ColumnWidth" value="30.29" type="Double"/><column name="NAME" property="NumberFormat" value="General" type="String"/><column name="NAME" property="VerticalAlignment" value="-4160" type="Double"/><column name="NAME" property="Validation.Type" value="6" type="Double"/><column name="NAME" property="Validation.Operator" value="8" type="Double"/><column name="NAME" property="Validation.Formula1" value="128" type="String"/><column name="NAME" property="Validation.AlertStyle" value="2" type="Double"/><column name="NAME" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="NAME" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="NAME" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="NAME" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(128) datatype." type="String"/><column name="NAME" property="Validation.ShowInput" value="True" type="Boolean"/><column name="NAME" property="Validation.ShowError" value="True" type="Boolean"/><column name="TEMPLATE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TEMPLATE" property="Address" value="$E$4" type="String"/><column name="TEMPLATE" property="ColumnWidth" value="11.71" type="Double"/><column name="TEMPLATE" property="NumberFormat" value="General" type="String"/><column name="TEMPLATE" property="VerticalAlignment" value="-4160" type="Double"/><column name="TEMPLATE" property="Validation.Type" value="6" type="Double"/><column name="TEMPLATE" property="Validation.Operator" value="8" type="Double"/><column name="TEMPLATE" property="Validation.Formula1" value="255" type="String"/><column name="TEMPLATE" property="Validation.AlertStyle" value="2" type="Double"/><column name="TEMPLATE" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="TEMPLATE" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="TEMPLATE" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="TEMPLATE" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(255) datatype." type="String"/><column name="TEMPLATE" property="Validation.ShowInput" value="True" type="Boolean"/><column name="TEMPLATE" property="Validation.ShowError" value="True" type="Boolean"/><column name="DEFINITION" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="DEFINITION" property="Address" value="$F$4" type="String"/><column name="DEFINITION" property="ColumnWidth" value="117.29" type="Double"/><column name="DEFINITION" property="NumberFormat" value="General" type="String"/><column name="DEFINITION" property="VerticalAlignment" value="-4160" type="Double"/><column name="TABLE_SCHEMA" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_SCHEMA" property="Address" value="$G$4" type="String"/><column name="TABLE_SCHEMA" property="ColumnWidth" value="16.57" type="Double"/><column name="TABLE_SCHEMA" property="NumberFormat" value="General" type="String"/><column name="TABLE_SCHEMA" property="VerticalAlignment" value="-4160" type="Double"/><column name="TABLE_SCHEMA" property="Validation.Type" value="6" type="Double"/><column name="TABLE_SCHEMA" property="Validation.Operator" value="8" type="Double"/><column name="TABLE_SCHEMA" property="Validation.Formula1" value="128" type="String"/><column name="TABLE_SCHEMA" property="Validation.AlertStyle" value="2" type="Double"/><column name="TABLE_SCHEMA" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="TABLE_SCHEMA" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="TABLE_SCHEMA" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="TABLE_SCHEMA" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(128) datatype." type="String"/><column name="TABLE_SCHEMA" property="Validation.ShowInput" value="True" type="Boolean"/><column name="TABLE_SCHEMA" property="Validation.ShowError" value="True" type="Boolean"/><column name="NAME" property="FormatConditions(1).AppliesTo.Address" value="$D$4:$D$12,$F$7:$F$12" type="String"/><column name="NAME" property="FormatConditions(1).Type" value="2" type="Double"/><column name="NAME" property="FormatConditions(1).Priority" value="1" type="Double"/><column name="NAME" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String"/><column name="NAME" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="DEFINITION" property="FormatConditions(1).AppliesTo.Address" value="$F$4:$F$12" type="String"/><column name="DEFINITION" property="FormatConditions(1).Type" value="2" type="Double"/><column name="DEFINITION" property="FormatConditions(1).Priority" value="2" type="Double"/><column name="DEFINITION" property="FormatConditions(1).Formula1" value="=ISBLANK(F4)" type="String"/><column name="DEFINITION" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
GO

INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (36, N'uniqueidentifier', N'DataTypeGuid', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (40, N'date', N'DataTypeDate', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (41, N'time', N'DataTypeTime', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (42, N'datetime2', N'DataTypeDateTime', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (43, N'datetimeoffset', N'DataTypeDateTimeOffset', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (48, N'tinyint', N'DataTypeInt', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (52, N'smallint', N'DataTypeInt', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (56, N'int', N'DataTypeInt', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (58, N'smalldatetime', N'DataTypeDateTime', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (60, N'money', N'DataTypeDouble', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (61, N'datetime', N'DataTypeDateTime', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (62, N'float', N'DataTypeDouble', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (98, N'sql_variant', NULL, 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (104, N'bit', N'DataTypeBit', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (106, N'decimal', N'DataTypeDouble', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (108, N'numeric', N'DataTypeDouble', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (122, N'smallmoney', N'DataTypeDouble', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (127, N'bigint', N'DataTypeInt', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (167, N'varchar', N'DataTypeString', 1);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (175, N'char', N'DataTypeString', 0);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (231, N'nvarchar', N'DataTypeString', 1);
INSERT INTO tab.types (id, name, datatype, translation_supported) VALUES (239, N'nchar', N'DataTypeString', 0);
GO

INSERT INTO tab.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'application-designer.xlsx', NULL, N'tables=tab.tables,tab,False,$B$3,,{"Parameters":{"table_schema":null},"ListObjectName":"tables"}
columns=tab.columns,tab,False,$B$3,,{"Parameters":{"table_id":null},"ListObjectName":"columns"}
languages=tab.languages,tab,False,$B$3,,{"Parameters":{},"ListObjectName":"languages"}
translations=tab.usp_select_translations,tab,False,$B$3,,{"Parameters":{"type_id":null,"table_id":null,"language":null},"ListObjectName":"translations"}
users=tab.users,tab,False,$B$3,,{"Parameters":{},"ListObjectName":"users"}
workbooks=tab.workbooks,tab,False,$B$3,,{"Parameters":{"TABLE_SCHEMA":null},"ListObjectName":"workbooks"}', N'tab');
GO

CREATE ROLE tab_developers;
GO
CREATE ROLE tab_users;
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON tab.formats     TO tab_users;

GRANT SELECT ON tab.workbooks                           TO tab_users;
GRANT SELECT ON tab.xl_app_handlers                     TO tab_users;
GRANT SELECT ON tab.xl_app_tables                       TO tab_users;
GRANT SELECT ON tab.xl_app_objects                      TO tab_users;
GRANT SELECT ON tab.xl_app_translations                 TO tab_users;

GRANT EXECUTE ON tab.usp_select_table                   TO tab_users;
GRANT EXECUTE ON tab.usp_select_table_update            TO tab_users;
GRANT EXECUTE ON tab.xl_list_by_column_id               TO tab_users;
GRANT EXECUTE ON tab.xl_list_table_id                   TO tab_users;

GRANT SELECT, INSERT, UPDATE, DELETE ON tab.columns     TO tab_developers;
GRANT SELECT, INSERT, UPDATE, DELETE ON tab.formats     TO tab_developers;
GRANT SELECT, INSERT, UPDATE, DELETE ON tab.languages   TO tab_developers;
GRANT SELECT, INSERT, UPDATE, DELETE ON tab.tables      TO tab_developers;
GRANT SELECT, INSERT, UPDATE, DELETE ON tab.workbooks   TO tab_developers;

GRANT SELECT ON tab.users                               TO tab_developers;
GRANT SELECT ON tab.types                               TO tab_developers;

GRANT SELECT ON tab.xl_app_handlers                     TO tab_developers;
GRANT SELECT ON tab.xl_app_tables                       TO tab_developers;
GRANT SELECT ON tab.xl_app_translations                 TO tab_developers;

GRANT EXECUTE ON tab.usp_select_table                   TO tab_developers;
GRANT EXECUTE ON tab.usp_select_table_update            TO tab_developers;
GRANT EXECUTE ON tab.xl_list_by_column_id               TO tab_developers;
GRANT EXECUTE ON tab.xl_list_table_id                   TO tab_developers;
GRANT EXECUTE ON tab.usp_select_translations            TO tab_developers;
GRANT EXECUTE ON tab.usp_select_translations_change     TO tab_developers;

GRANT VIEW DEFINITION ON ROLE::tab_users                TO tab_developers;
GO

print 'Tab Framework installed';
