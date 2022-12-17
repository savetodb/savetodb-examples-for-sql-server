-- =============================================
-- SaveToDB Framework Extension for Microsoft SQL Server
-- Version 10.6, December 13, 2022
--
-- Copyright 2022 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON
GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view select configured columns
-- =============================================

CREATE VIEW [xls].[view_columns]
AS
SELECT
    t.ID
    , t.TABLE_SCHEMA
    , t.TABLE_NAME
    , t.COLUMN_NAME
    , t.ORDINAL_POSITION
    , t.IS_PRIMARY_KEY
    , t.IS_NULLABLE
    , t.IS_IDENTITY
    , t.IS_COMPUTED
    , t.COLUMN_DEFAULT
    , t.DATA_TYPE
    , t.CHARACTER_MAXIMUM_LENGTH
    , t.PRECISION
    , t.SCALE
FROM
    xls.columns t
WHERE
    t.TABLE_SCHEMA IN (SELECT DISTINCT s.name FROM sys.objects o INNER JOIN sys.schemas s ON s.schema_id = o.schema_id)


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view select object formats
-- =============================================

CREATE VIEW [xls].[view_formats]
AS
SELECT
    t.ID
    , t.TABLE_SCHEMA
    , t.TABLE_NAME
    , t.TABLE_EXCEL_FORMAT_XML
    , t.APP
FROM
    xls.formats t
WHERE
    t.TABLE_SCHEMA IN (SELECT DISTINCT s.name FROM sys.objects o INNER JOIN sys.schemas s ON s.schema_id = o.schema_id)
    AND NOT t.TABLE_SCHEMA = 'xls'


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view select handlers
-- =============================================

CREATE VIEW [xls].[view_handlers]
AS
SELECT
    t.ID
    , t.TABLE_SCHEMA
    , t.TABLE_NAME
    , t.COLUMN_NAME
    , t.EVENT_NAME
    , t.HANDLER_SCHEMA
    , t.HANDLER_NAME
    , t.HANDLER_TYPE
    , t.HANDLER_CODE
    , t.TARGET_WORKSHEET
    , t.MENU_ORDER
    , t.EDIT_PARAMETERS
FROM
    xls.handlers t
WHERE
    t.TABLE_SCHEMA IN (SELECT DISTINCT s.name FROM sys.objects o INNER JOIN sys.schemas s ON s.schema_id = o.schema_id)
    AND NOT t.TABLE_SCHEMA = 'xls'


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view select configured objects
-- =============================================

CREATE VIEW [xls].[view_objects]
AS
SELECT
    t.ID
    , t.TABLE_SCHEMA
    , t.TABLE_NAME
    , t.TABLE_TYPE
    , t.TABLE_CODE
    , t.INSERT_OBJECT
    , t.UPDATE_OBJECT
    , t.DELETE_OBJECT
FROM
    xls.objects t
WHERE
    t.TABLE_SCHEMA IN (SELECT DISTINCT s.name FROM sys.objects o INNER JOIN sys.schemas s ON s.schema_id = o.schema_id)


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view select Query List objects
-- =============================================

CREATE VIEW [xls].[view_queries]
AS
SELECT
    t.TABLE_SCHEMA
    , t.TABLE_NAME
    , t.TABLE_TYPE
    , t.TABLE_CODE
    , t.INSERT_PROCEDURE
    , t.UPDATE_PROCEDURE
    , t.DELETE_PROCEDURE
    , t.PROCEDURE_TYPE
FROM
    xls.queries t
WHERE
    t.TABLE_SCHEMA IN (SELECT DISTINCT s.name FROM sys.objects o INNER JOIN sys.schemas s ON s.schema_id = o.schema_id)


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view select translations
-- =============================================

CREATE VIEW [xls].[view_translations]
AS
SELECT
    t.ID
    , t.TABLE_SCHEMA
    , t.TABLE_NAME
    , t.COLUMN_NAME
    , t.LANGUAGE_NAME
    , t.TRANSLATED_NAME
    , t.TRANSLATED_DESC
    , t.TRANSLATED_COMMENT
FROM
    xls.translations t
WHERE
    t.TABLE_SCHEMA IN (SELECT DISTINCT s.name FROM sys.objects o INNER JOIN sys.schemas s ON s.schema_id = o.schema_id)


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view select definitions of application workbooks
-- =============================================

CREATE VIEW [xls].[view_workbooks]
AS
SELECT
    t.ID
    , t.NAME
    , t.TEMPLATE
    , t.DEFINITION
    , t.TABLE_SCHEMA
FROM
    xls.workbooks t
WHERE
    t.TABLE_SCHEMA IN (SELECT DISTINCT s.name FROM sys.objects o INNER JOIN sys.schemas s ON s.schema_id = o.schema_id)


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.4, 2022-10-13
-- Description: Activates using SaveToDB Framework Extension views instead of SaveToDB Framework tables
-- =============================================

CREATE PROCEDURE [xls].[xl_actions_set_extended_role_permissions]
    @confirm bit = 0
AS
BEGIN

SET NOCOUNT ON;

IF COALESCE(@confirm, 0) = 0 RETURN;

GRANT SELECT ON xls.view_columns        TO xls_users;
GRANT SELECT ON xls.view_formats        TO xls_users;
GRANT SELECT ON xls.view_handlers       TO xls_users;
GRANT SELECT ON xls.view_objects        TO xls_users;
GRANT SELECT ON xls.view_translations   TO xls_users;
GRANT SELECT ON xls.view_workbooks      TO xls_users;
GRANT SELECT ON xls.view_queries        TO xls_users;

REVOKE SELECT, VIEW DEFINITION ON xls.columns       FROM xls_users;
REVOKE SELECT, VIEW DEFINITION ON xls.formats       FROM xls_users;
REVOKE SELECT, VIEW DEFINITION ON xls.handlers      FROM xls_users;
REVOKE SELECT, VIEW DEFINITION ON xls.objects       FROM xls_users;
REVOKE SELECT, VIEW DEFINITION ON xls.translations  FROM xls_users;
REVOKE SELECT, VIEW DEFINITION ON xls.workbooks     FROM xls_users;
REVOKE SELECT, VIEW DEFINITION ON xls.queries       FROM xls_users;

GRANT EXECUTE ON xls.xl_update_table_format TO xls_formats;

REVOKE SELECT, INSERT, UPDATE, DELETE, VIEW DEFINITION ON xls.formats FROM xls_formats;

DENY SELECT, INSERT, UPDATE, DELETE, VIEW DEFINITION ON xls.view_columns        TO xls_developers;
DENY SELECT, INSERT, UPDATE, DELETE, VIEW DEFINITION ON xls.view_formats        TO xls_developers;
DENY SELECT, INSERT, UPDATE, DELETE, VIEW DEFINITION ON xls.view_handlers       TO xls_developers;
DENY SELECT, INSERT, UPDATE, DELETE, VIEW DEFINITION ON xls.view_objects        TO xls_developers;
DENY SELECT, INSERT, UPDATE, DELETE, VIEW DEFINITION ON xls.view_translations   TO xls_developers;
DENY SELECT, INSERT, UPDATE, DELETE, VIEW DEFINITION ON xls.view_workbooks      TO xls_developers;
DENY SELECT, INSERT, UPDATE, DELETE, VIEW DEFINITION ON xls.view_queries        TO xls_developers;

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.4, 2022-10-13
-- Description: Activates using SaveToDB Framework tables instead of SaveToDB Framework Extension views
-- =============================================

CREATE PROCEDURE [xls].[xl_actions_revoke_extended_role_permissions]
    @confirm bit = 0
AS
BEGIN

SET NOCOUNT ON;

IF COALESCE(@confirm, 0) = 0 RETURN;

REVOKE SELECT ON xls.view_columns        FROM xls_users;
REVOKE SELECT ON xls.view_formats        FROM xls_users;
REVOKE SELECT ON xls.view_handlers       FROM xls_users;
REVOKE SELECT ON xls.view_objects        FROM xls_users;
REVOKE SELECT ON xls.view_translations   FROM xls_users;
REVOKE SELECT ON xls.view_workbooks      FROM xls_users;
REVOKE SELECT ON xls.view_queries        FROM xls_users;

GRANT SELECT, VIEW DEFINITION ON xls.columns        TO xls_users;
GRANT SELECT, VIEW DEFINITION ON xls.formats        TO xls_users;
GRANT SELECT, VIEW DEFINITION ON xls.handlers       TO xls_users;
GRANT SELECT, VIEW DEFINITION ON xls.objects        TO xls_users;
GRANT SELECT, VIEW DEFINITION ON xls.translations   TO xls_users;
GRANT SELECT, VIEW DEFINITION ON xls.workbooks      TO xls_users;
GRANT SELECT, VIEW DEFINITION ON xls.queries        TO xls_users;

REVOKE EXECUTE ON xls.xl_update_table_format FROM xls_formats;

GRANT SELECT, INSERT, UPDATE, DELETE, VIEW DEFINITION ON xls.formats TO xls_formats;

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure updates Excel table formats
-- =============================================

CREATE PROCEDURE [xls].[xl_update_table_format]
    @schema nvarchar(128) = NULL
    , @name nvarchar(128) = NULL
    , @excelFormatXML xml = NULL
    , @app nvarchar(50) = NULL
AS
BEGIN

IF @schema IS NOT NULL AND @name IS NOT NULL
    IF @excelFormatXML IS NULL
        BEGIN

        DELETE FROM xls.formats
        WHERE
            TABLE_SCHEMA = @schema AND TABLE_NAME = @name

        END
    ELSE
        BEGIN

        UPDATE xls.formats
        SET
            TABLE_EXCEL_FORMAT_XML = @excelFormatXML
        WHERE
            TABLE_SCHEMA = @schema AND TABLE_NAME = @name AND COALESCE(APP, '') = COALESCE(@app, '')

        IF @@ROWCOUNT = 0
            INSERT xls.formats
                (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML, APP)
            VALUES
                (@schema, @name, @excelFormatXML, @app)

        END

END


GO

INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'xls', N'view_columns', N'<table name="xls.view_columns"><columnFormats><column name="" property="ListObjectName" value="columns" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="ID" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="ID" property="Address" value="$C$4" type="String"/><column name="ID" property="ColumnWidth" value="4.43" type="Double"/><column name="ID" property="NumberFormat" value="General" type="String"/><column name="ID" property="Validation.Type" value="1" type="Double"/><column name="ID" property="Validation.Operator" value="1" type="Double"/><column name="ID" property="Validation.Formula1" value="-2147483648" type="String"/><column name="ID" property="Validation.Formula2" value="2147483647" type="String"/><column name="ID" property="Validation.AlertStyle" value="2" type="Double"/><column name="ID" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="ID" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="ID" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="ID" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String"/><column name="ID" property="Validation.ShowInput" value="True" type="Boolean"/><column name="ID" property="Validation.ShowError" value="True" type="Boolean"/><column name="TABLE_SCHEMA" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_SCHEMA" property="Address" value="$D$4" type="String"/><column name="TABLE_SCHEMA" property="ColumnWidth" value="16.57" type="Double"/><column name="TABLE_SCHEMA" property="NumberFormat" value="General" type="String"/><column name="TABLE_SCHEMA" property="Validation.Type" value="6" type="Double"/><column name="TABLE_SCHEMA" property="Validation.Operator" value="8" type="Double"/><column name="TABLE_SCHEMA" property="Validation.Formula1" value="128" type="String"/><column name="TABLE_SCHEMA" property="Validation.AlertStyle" value="2" type="Double"/><column name="TABLE_SCHEMA" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="TABLE_SCHEMA" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="TABLE_SCHEMA" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="TABLE_SCHEMA" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(128) datatype." type="String"/><column name="TABLE_SCHEMA" property="Validation.ShowInput" value="True" type="Boolean"/><column name="TABLE_SCHEMA" property="Validation.ShowError" value="True" type="Boolean"/><column name="TABLE_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_NAME" property="Address" value="$E$4" type="String"/><column name="TABLE_NAME" property="ColumnWidth" value="15.43" type="Double"/><column name="TABLE_NAME" property="NumberFormat" value="General" type="String"/><column name="TABLE_NAME" property="Validation.Type" value="6" type="Double"/><column name="TABLE_NAME" property="Validation.Operator" value="8" type="Double"/><column name="TABLE_NAME" property="Validation.Formula1" value="128" type="String"/><column name="TABLE_NAME" property="Validation.AlertStyle" value="2" type="Double"/><column name="TABLE_NAME" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="TABLE_NAME" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="TABLE_NAME" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="TABLE_NAME" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(128) datatype." type="String"/><column name="TABLE_NAME" property="Validation.ShowInput" value="True" type="Boolean"/><column name="TABLE_NAME" property="Validation.ShowError" value="True" type="Boolean"/><column name="COLUMN_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="COLUMN_NAME" property="Address" value="$F$4" type="String"/><column name="COLUMN_NAME" property="ColumnWidth" value="27.86" type="Double"/><column name="COLUMN_NAME" property="NumberFormat" value="General" type="String"/><column name="COLUMN_NAME" property="Validation.Type" value="6" type="Double"/><column name="COLUMN_NAME" property="Validation.Operator" value="8" type="Double"/><column name="COLUMN_NAME" property="Validation.Formula1" value="128" type="String"/><column name="COLUMN_NAME" property="Validation.AlertStyle" value="2" type="Double"/><column name="COLUMN_NAME" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="COLUMN_NAME" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="COLUMN_NAME" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="COLUMN_NAME" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(128) datatype." type="String"/><column name="COLUMN_NAME" property="Validation.ShowInput" value="True" type="Boolean"/><column name="COLUMN_NAME" property="Validation.ShowError" value="True" type="Boolean"/><column name="ORDINAL_POSITION" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="ORDINAL_POSITION" property="Address" value="$G$4" type="String"/><column name="ORDINAL_POSITION" property="ColumnWidth" value="20.43" type="Double"/><column name="ORDINAL_POSITION" property="NumberFormat" value="General" type="String"/><column name="ORDINAL_POSITION" property="Validation.Type" value="1" type="Double"/><column name="ORDINAL_POSITION" property="Validation.Operator" value="1" type="Double"/><column name="ORDINAL_POSITION" property="Validation.Formula1" value="-2147483648" type="String"/><column name="ORDINAL_POSITION" property="Validation.Formula2" value="2147483647" type="String"/><column name="ORDINAL_POSITION" property="Validation.AlertStyle" value="2" type="Double"/><column name="ORDINAL_POSITION" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="ORDINAL_POSITION" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="ORDINAL_POSITION" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="ORDINAL_POSITION" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String"/><column name="ORDINAL_POSITION" property="Validation.ShowInput" value="True" type="Boolean"/><column name="ORDINAL_POSITION" property="Validation.ShowError" value="True" type="Boolean"/><column name="IS_PRIMARY_KEY" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="IS_PRIMARY_KEY" property="Address" value="$H$4" type="String"/><column name="IS_PRIMARY_KEY" property="ColumnWidth" value="17.86" type="Double"/><column name="IS_PRIMARY_KEY" property="NumberFormat" value="General" type="String"/><column name="IS_PRIMARY_KEY" property="HorizontalAlignment" value="-4108" type="Double"/><column name="IS_PRIMARY_KEY" property="Font.Size" value="10" type="Double"/><column name="IS_NULLABLE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="IS_NULLABLE" property="Address" value="$I$4" type="String"/><column name="IS_NULLABLE" property="ColumnWidth" value="14" type="Double"/><column name="IS_NULLABLE" property="NumberFormat" value="General" type="String"/><column name="IS_NULLABLE" property="HorizontalAlignment" value="-4108" type="Double"/><column name="IS_NULLABLE" property="Font.Size" value="10" type="Double"/><column name="IS_IDENTITY" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="IS_IDENTITY" property="Address" value="$J$4" type="String"/><column name="IS_IDENTITY" property="ColumnWidth" value="13.14" type="Double"/><column name="IS_IDENTITY" property="NumberFormat" value="General" type="String"/><column name="IS_IDENTITY" property="HorizontalAlignment" value="-4108" type="Double"/><column name="IS_IDENTITY" property="Font.Size" value="10" type="Double"/><column name="IS_COMPUTED" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="IS_COMPUTED" property="Address" value="$K$4" type="String"/><column name="IS_COMPUTED" property="ColumnWidth" value="15.57" type="Double"/><column name="IS_COMPUTED" property="NumberFormat" value="General" type="String"/><column name="IS_COMPUTED" property="HorizontalAlignment" value="-4108" type="Double"/><column name="IS_COMPUTED" property="Font.Size" value="10" type="Double"/><column name="COLUMN_DEFAULT" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="COLUMN_DEFAULT" property="Address" value="$L$4" type="String"/><column name="COLUMN_DEFAULT" property="ColumnWidth" value="19.86" type="Double"/><column name="COLUMN_DEFAULT" property="NumberFormat" value="General" type="String"/><column name="COLUMN_DEFAULT" property="Validation.Type" value="6" type="Double"/><column name="COLUMN_DEFAULT" property="Validation.Operator" value="8" type="Double"/><column name="COLUMN_DEFAULT" property="Validation.Formula1" value="256" type="String"/><column name="COLUMN_DEFAULT" property="Validation.AlertStyle" value="2" type="Double"/><column name="COLUMN_DEFAULT" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="COLUMN_DEFAULT" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="COLUMN_DEFAULT" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="COLUMN_DEFAULT" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(256) datatype." type="String"/><column name="COLUMN_DEFAULT" property="Validation.ShowInput" value="True" type="Boolean"/><column name="COLUMN_DEFAULT" property="Validation.ShowError" value="True" type="Boolean"/><column name="DATA_TYPE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="DATA_TYPE" property="Address" value="$M$4" type="String"/><column name="DATA_TYPE" property="ColumnWidth" value="12.71" type="Double"/><column name="DATA_TYPE" property="NumberFormat" value="General" type="String"/><column name="DATA_TYPE" property="Validation.Type" value="6" type="Double"/><column name="DATA_TYPE" property="Validation.Operator" value="8" type="Double"/><column name="DATA_TYPE" property="Validation.Formula1" value="128" type="String"/><column name="DATA_TYPE" property="Validation.AlertStyle" value="2" type="Double"/><column name="DATA_TYPE" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="DATA_TYPE" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="DATA_TYPE" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="DATA_TYPE" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(128) datatype." type="String"/><column name="DATA_TYPE" property="Validation.ShowInput" value="True" type="Boolean"/><column name="DATA_TYPE" property="Validation.ShowError" value="True" type="Boolean"/><column name="CHARACTER_MAXIMUM_LENGTH" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="CHARACTER_MAXIMUM_LENGTH" property="Address" value="$N$4" type="String"/><column name="CHARACTER_MAXIMUM_LENGTH" property="ColumnWidth" value="32.71" type="Double"/><column name="CHARACTER_MAXIMUM_LENGTH" property="NumberFormat" value="General" type="String"/><column name="CHARACTER_MAXIMUM_LENGTH" property="Validation.Type" value="1" type="Double"/><column name="CHARACTER_MAXIMUM_LENGTH" property="Validation.Operator" value="1" type="Double"/><column name="CHARACTER_MAXIMUM_LENGTH" property="Validation.Formula1" value="-2147483648" type="String"/><column name="CHARACTER_MAXIMUM_LENGTH" property="Validation.Formula2" value="2147483647" type="String"/><column name="CHARACTER_MAXIMUM_LENGTH" property="Validation.AlertStyle" value="2" type="Double"/><column name="CHARACTER_MAXIMUM_LENGTH" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="CHARACTER_MAXIMUM_LENGTH" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="CHARACTER_MAXIMUM_LENGTH" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="CHARACTER_MAXIMUM_LENGTH" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String"/><column name="CHARACTER_MAXIMUM_LENGTH" property="Validation.ShowInput" value="True" type="Boolean"/><column name="CHARACTER_MAXIMUM_LENGTH" property="Validation.ShowError" value="True" type="Boolean"/><column name="PRECISION" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="PRECISION" property="Address" value="$O$4" type="String"/><column name="PRECISION" property="ColumnWidth" value="12" type="Double"/><column name="PRECISION" property="NumberFormat" value="General" type="String"/><column name="PRECISION" property="Validation.Type" value="1" type="Double"/><column name="PRECISION" property="Validation.Operator" value="1" type="Double"/><column name="PRECISION" property="Validation.Formula1" value="0" type="String"/><column name="PRECISION" property="Validation.Formula2" value="255" type="String"/><column name="PRECISION" property="Validation.AlertStyle" value="2" type="Double"/><column name="PRECISION" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="PRECISION" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="PRECISION" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="PRECISION" property="Validation.ErrorMessage" value="The column requires values of the tinyint datatype." type="String"/><column name="PRECISION" property="Validation.ShowInput" value="True" type="Boolean"/><column name="PRECISION" property="Validation.ShowError" value="True" type="Boolean"/><column name="SCALE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="SCALE" property="Address" value="$P$4" type="String"/><column name="SCALE" property="ColumnWidth" value="7.86" type="Double"/><column name="SCALE" property="NumberFormat" value="General" type="String"/><column name="SCALE" property="Validation.Type" value="1" type="Double"/><column name="SCALE" property="Validation.Operator" value="1" type="Double"/><column name="SCALE" property="Validation.Formula1" value="0" type="String"/><column name="SCALE" property="Validation.Formula2" value="255" type="String"/><column name="SCALE" property="Validation.AlertStyle" value="2" type="Double"/><column name="SCALE" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="SCALE" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="SCALE" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="SCALE" property="Validation.ErrorMessage" value="The column requires values of the tinyint datatype." type="String"/><column name="SCALE" property="Validation.ShowInput" value="True" type="Boolean"/><column name="SCALE" property="Validation.ShowError" value="True" type="Boolean"/><column name="TABLE_SCHEMA" property="FormatConditions(1).AppliesTo.Address" value="$D$4:$D$423" type="String"/><column name="TABLE_SCHEMA" property="FormatConditions(1).Type" value="2" type="Double"/><column name="TABLE_SCHEMA" property="FormatConditions(1).Priority" value="5" type="Double"/><column name="TABLE_SCHEMA" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String"/><column name="TABLE_SCHEMA" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="TABLE_NAME" property="FormatConditions(1).AppliesTo.Address" value="$E$4:$E$423" type="String"/><column name="TABLE_NAME" property="FormatConditions(1).Type" value="2" type="Double"/><column name="TABLE_NAME" property="FormatConditions(1).Priority" value="6" type="Double"/><column name="TABLE_NAME" property="FormatConditions(1).Formula1" value="=ISBLANK(E4)" type="String"/><column name="TABLE_NAME" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="COLUMN_NAME" property="FormatConditions(1).AppliesTo.Address" value="$F$4:$F$423" type="String"/><column name="COLUMN_NAME" property="FormatConditions(1).Type" value="2" type="Double"/><column name="COLUMN_NAME" property="FormatConditions(1).Priority" value="7" type="Double"/><column name="COLUMN_NAME" property="FormatConditions(1).Formula1" value="=ISBLANK(F4)" type="String"/><column name="COLUMN_NAME" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="ORDINAL_POSITION" property="FormatConditions(1).AppliesTo.Address" value="$G$4:$G$423" type="String"/><column name="ORDINAL_POSITION" property="FormatConditions(1).Type" value="2" type="Double"/><column name="ORDINAL_POSITION" property="FormatConditions(1).Priority" value="8" type="Double"/><column name="ORDINAL_POSITION" property="FormatConditions(1).Formula1" value="=ISBLANK(G4)" type="String"/><column name="ORDINAL_POSITION" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="IS_PRIMARY_KEY" property="FormatConditions(1).AppliesTo.Address" value="$H$4:$H$423" type="String"/><column name="IS_PRIMARY_KEY" property="FormatConditions(1).Type" value="6" type="Double"/><column name="IS_PRIMARY_KEY" property="FormatConditions(1).Priority" value="4" type="Double"/><column name="IS_PRIMARY_KEY" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean"/><column name="IS_PRIMARY_KEY" property="FormatConditions(1).IconSet.ID" value="8" type="Double"/><column name="IS_PRIMARY_KEY" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double"/><column name="IS_PRIMARY_KEY" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double"/><column name="IS_PRIMARY_KEY" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double"/><column name="IS_PRIMARY_KEY" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double"/><column name="IS_PRIMARY_KEY" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double"/><column name="IS_PRIMARY_KEY" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double"/><column name="IS_PRIMARY_KEY" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double"/><column name="IS_PRIMARY_KEY" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double"/><column name="IS_NULLABLE" property="FormatConditions(1).AppliesTo.Address" value="$I$4:$I$423" type="String"/><column name="IS_NULLABLE" property="FormatConditions(1).Type" value="6" type="Double"/><column name="IS_NULLABLE" property="FormatConditions(1).Priority" value="3" type="Double"/><column name="IS_NULLABLE" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean"/><column name="IS_NULLABLE" property="FormatConditions(1).IconSet.ID" value="8" type="Double"/><column name="IS_NULLABLE" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double"/><column name="IS_NULLABLE" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double"/><column name="IS_NULLABLE" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double"/><column name="IS_NULLABLE" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double"/><column name="IS_NULLABLE" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double"/><column name="IS_NULLABLE" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double"/><column name="IS_NULLABLE" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double"/><column name="IS_NULLABLE" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double"/><column name="IS_IDENTITY" property="FormatConditions(1).AppliesTo.Address" value="$J$4:$J$423" type="String"/><column name="IS_IDENTITY" property="FormatConditions(1).Type" value="6" type="Double"/><column name="IS_IDENTITY" property="FormatConditions(1).Priority" value="2" type="Double"/><column name="IS_IDENTITY" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean"/><column name="IS_IDENTITY" property="FormatConditions(1).IconSet.ID" value="8" type="Double"/><column name="IS_IDENTITY" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double"/><column name="IS_IDENTITY" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double"/><column name="IS_IDENTITY" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double"/><column name="IS_IDENTITY" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double"/><column name="IS_IDENTITY" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double"/><column name="IS_IDENTITY" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double"/><column name="IS_IDENTITY" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double"/><column name="IS_IDENTITY" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double"/><column name="IS_COMPUTED" property="FormatConditions(1).AppliesTo.Address" value="$K$4:$K$423" type="String"/><column name="IS_COMPUTED" property="FormatConditions(1).Type" value="6" type="Double"/><column name="IS_COMPUTED" property="FormatConditions(1).Priority" value="1" type="Double"/><column name="IS_COMPUTED" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean"/><column name="IS_COMPUTED" property="FormatConditions(1).IconSet.ID" value="8" type="Double"/><column name="IS_COMPUTED" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double"/><column name="IS_COMPUTED" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double"/><column name="IS_COMPUTED" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double"/><column name="IS_COMPUTED" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double"/><column name="IS_COMPUTED" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double"/><column name="IS_COMPUTED" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double"/><column name="IS_COMPUTED" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double"/><column name="IS_COMPUTED" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double"/><column name="SortFields(1)" property="KeyfieldName" value="TABLE_SCHEMA" type="String"/><column name="SortFields(1)" property="SortOn" value="0" type="Double"/><column name="SortFields(1)" property="Order" value="1" type="Double"/><column name="SortFields(1)" property="DataOption" value="2" type="Double"/><column name="SortFields(2)" property="KeyfieldName" value="TABLE_NAME" type="String"/><column name="SortFields(2)" property="SortOn" value="0" type="Double"/><column name="SortFields(2)" property="Order" value="1" type="Double"/><column name="SortFields(2)" property="DataOption" value="2" type="Double"/><column name="SortFields(3)" property="KeyfieldName" value="ORDINAL_POSITION" type="String"/><column name="SortFields(3)" property="SortOn" value="0" type="Double"/><column name="SortFields(3)" property="Order" value="1" type="Double"/><column name="SortFields(3)" property="DataOption" value="2" type="Double"/><column name="SortFields(4)" property="KeyfieldName" value="COLUMN_NAME" type="String"/><column name="SortFields(4)" property="SortOn" value="0" type="Double"/><column name="SortFields(4)" property="Order" value="1" type="Double"/><column name="SortFields(4)" property="DataOption" value="2" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'xls', N'view_formats', N'<table name="xls.view_formats"><columnFormats><column name="" property="ListObjectName" value="formats" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="_RowNum" property="VerticalAlignment" value="-4160" type="Double"/><column name="ID" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="ID" property="Address" value="$C$4" type="String"/><column name="ID" property="NumberFormat" value="General" type="String"/><column name="ID" property="VerticalAlignment" value="-4160" type="Double"/><column name="TABLE_SCHEMA" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_SCHEMA" property="Address" value="$D$4" type="String"/><column name="TABLE_SCHEMA" property="ColumnWidth" value="16.57" type="Double"/><column name="TABLE_SCHEMA" property="NumberFormat" value="General" type="String"/><column name="TABLE_SCHEMA" property="VerticalAlignment" value="-4160" type="Double"/><column name="TABLE_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_NAME" property="Address" value="$E$4" type="String"/><column name="TABLE_NAME" property="ColumnWidth" value="30" type="Double"/><column name="TABLE_NAME" property="NumberFormat" value="General" type="String"/><column name="TABLE_NAME" property="VerticalAlignment" value="-4160" type="Double"/><column name="TABLE_EXCEL_FORMAT_XML" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_EXCEL_FORMAT_XML" property="Address" value="$F$4" type="String"/><column name="TABLE_EXCEL_FORMAT_XML" property="ColumnWidth" value="42.29" type="Double"/><column name="TABLE_EXCEL_FORMAT_XML" property="NumberFormat" value="General" type="String"/><column name="SortFields(1)" property="KeyfieldName" value="TABLE_SCHEMA" type="String"/><column name="SortFields(1)" property="SortOn" value="0" type="Double"/><column name="SortFields(1)" property="Order" value="1" type="Double"/><column name="SortFields(1)" property="DataOption" value="0" type="Double"/><column name="SortFields(2)" property="KeyfieldName" value="TABLE_NAME" type="String"/><column name="SortFields(2)" property="SortOn" value="0" type="Double"/><column name="SortFields(2)" property="Order" value="1" type="Double"/><column name="SortFields(2)" property="DataOption" value="0" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'xls', N'view_handlers', N'<table name="xls.view_handlers"><columnFormats><column name="" property="ListObjectName" value="handlers" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="_RowNum" property="VerticalAlignment" value="-4160" type="Double"/><column name="ID" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="ID" property="Address" value="$C$4" type="String"/><column name="ID" property="NumberFormat" value="General" type="String"/><column name="ID" property="VerticalAlignment" value="-4160" type="Double"/><column name="TABLE_SCHEMA" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_SCHEMA" property="Address" value="$D$4" type="String"/><column name="TABLE_SCHEMA" property="ColumnWidth" value="16.57" type="Double"/><column name="TABLE_SCHEMA" property="NumberFormat" value="General" type="String"/><column name="TABLE_SCHEMA" property="VerticalAlignment" value="-4160" type="Double"/><column name="TABLE_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_NAME" property="Address" value="$E$4" type="String"/><column name="TABLE_NAME" property="ColumnWidth" value="30" type="Double"/><column name="TABLE_NAME" property="NumberFormat" value="General" type="String"/><column name="TABLE_NAME" property="VerticalAlignment" value="-4160" type="Double"/><column name="COLUMN_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="COLUMN_NAME" property="Address" value="$F$4" type="String"/><column name="COLUMN_NAME" property="ColumnWidth" value="17.43" type="Double"/><column name="COLUMN_NAME" property="NumberFormat" value="General" type="String"/><column name="COLUMN_NAME" property="VerticalAlignment" value="-4160" type="Double"/><column name="EVENT_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="EVENT_NAME" property="Address" value="$G$4" type="String"/><column name="EVENT_NAME" property="ColumnWidth" value="21.57" type="Double"/><column name="EVENT_NAME" property="NumberFormat" value="General" type="String"/><column name="EVENT_NAME" property="VerticalAlignment" value="-4160" type="Double"/><column name="HANDLER_SCHEMA" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="HANDLER_SCHEMA" property="Address" value="$H$4" type="String"/><column name="HANDLER_SCHEMA" property="ColumnWidth" value="19.71" type="Double"/><column name="HANDLER_SCHEMA" property="NumberFormat" value="General" type="String"/><column name="HANDLER_SCHEMA" property="VerticalAlignment" value="-4160" type="Double"/><column name="HANDLER_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="HANDLER_NAME" property="Address" value="$I$4" type="String"/><column name="HANDLER_NAME" property="ColumnWidth" value="31.14" type="Double"/><column name="HANDLER_NAME" property="NumberFormat" value="General" type="String"/><column name="HANDLER_NAME" property="VerticalAlignment" value="-4160" type="Double"/><column name="HANDLER_TYPE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="HANDLER_TYPE" property="Address" value="$J$4" type="String"/><column name="HANDLER_TYPE" property="ColumnWidth" value="16.29" type="Double"/><column name="HANDLER_TYPE" property="NumberFormat" value="General" type="String"/><column name="HANDLER_TYPE" property="VerticalAlignment" value="-4160" type="Double"/><column name="HANDLER_CODE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="HANDLER_CODE" property="Address" value="$K$4" type="String"/><column name="HANDLER_CODE" property="ColumnWidth" value="70.71" type="Double"/><column name="HANDLER_CODE" property="NumberFormat" value="General" type="String"/><column name="HANDLER_CODE" property="VerticalAlignment" value="-4160" type="Double"/><column name="TARGET_WORKSHEET" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TARGET_WORKSHEET" property="Address" value="$L$4" type="String"/><column name="TARGET_WORKSHEET" property="ColumnWidth" value="21.71" type="Double"/><column name="TARGET_WORKSHEET" property="NumberFormat" value="General" type="String"/><column name="TARGET_WORKSHEET" property="VerticalAlignment" value="-4160" type="Double"/><column name="MENU_ORDER" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="MENU_ORDER" property="Address" value="$M$4" type="String"/><column name="MENU_ORDER" property="ColumnWidth" value="15.43" type="Double"/><column name="MENU_ORDER" property="NumberFormat" value="General" type="String"/><column name="MENU_ORDER" property="VerticalAlignment" value="-4160" type="Double"/><column name="EDIT_PARAMETERS" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="EDIT_PARAMETERS" property="Address" value="$N$4" type="String"/><column name="EDIT_PARAMETERS" property="ColumnWidth" value="19.57" type="Double"/><column name="EDIT_PARAMETERS" property="NumberFormat" value="General" type="String"/><column name="EDIT_PARAMETERS" property="HorizontalAlignment" value="-4108" type="Double"/><column name="EDIT_PARAMETERS" property="VerticalAlignment" value="-4160" type="Double"/><column name="EDIT_PARAMETERS" property="Font.Size" value="10" type="Double"/><column name="SortFields(1)" property="KeyfieldName" value="EVENT_NAME" type="String"/><column name="SortFields(1)" property="SortOn" value="0" type="Double"/><column name="SortFields(1)" property="Order" value="1" type="Double"/><column name="SortFields(1)" property="DataOption" value="0" type="Double"/><column name="SortFields(2)" property="KeyfieldName" value="TABLE_SCHEMA" type="String"/><column name="SortFields(2)" property="SortOn" value="0" type="Double"/><column name="SortFields(2)" property="Order" value="1" type="Double"/><column name="SortFields(2)" property="DataOption" value="0" type="Double"/><column name="SortFields(3)" property="KeyfieldName" value="TABLE_NAME" type="String"/><column name="SortFields(3)" property="SortOn" value="0" type="Double"/><column name="SortFields(3)" property="Order" value="1" type="Double"/><column name="SortFields(3)" property="DataOption" value="0" type="Double"/><column name="SortFields(4)" property="KeyfieldName" value="COLUMN_NAME" type="String"/><column name="SortFields(4)" property="SortOn" value="0" type="Double"/><column name="SortFields(4)" property="Order" value="1" type="Double"/><column name="SortFields(4)" property="DataOption" value="0" type="Double"/><column name="SortFields(5)" property="KeyfieldName" value="MENU_ORDER" type="String"/><column name="SortFields(5)" property="SortOn" value="0" type="Double"/><column name="SortFields(5)" property="Order" value="1" type="Double"/><column name="SortFields(5)" property="DataOption" value="0" type="Double"/><column name="SortFields(6)" property="KeyfieldName" value="HANDLER_SCHEMA" type="String"/><column name="SortFields(6)" property="SortOn" value="0" type="Double"/><column name="SortFields(6)" property="Order" value="1" type="Double"/><column name="SortFields(6)" property="DataOption" value="0" type="Double"/><column name="SortFields(7)" property="KeyfieldName" value="HANDLER_NAME" type="String"/><column name="SortFields(7)" property="SortOn" value="0" type="Double"/><column name="SortFields(7)" property="Order" value="1" type="Double"/><column name="SortFields(7)" property="DataOption" value="0" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'xls', N'view_objects', N'<table name="xls.view_objects"><columnFormats><column name="" property="ListObjectName" value="objects" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="_RowNum" property="VerticalAlignment" value="-4160" type="Double"/><column name="ID" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="ID" property="Address" value="$C$4" type="String"/><column name="ID" property="NumberFormat" value="General" type="String"/><column name="ID" property="VerticalAlignment" value="-4160" type="Double"/><column name="TABLE_SCHEMA" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_SCHEMA" property="Address" value="$D$4" type="String"/><column name="TABLE_SCHEMA" property="ColumnWidth" value="16.57" type="Double"/><column name="TABLE_SCHEMA" property="NumberFormat" value="General" type="String"/><column name="TABLE_SCHEMA" property="VerticalAlignment" value="-4160" type="Double"/><column name="TABLE_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_NAME" property="Address" value="$E$4" type="String"/><column name="TABLE_NAME" property="ColumnWidth" value="30" type="Double"/><column name="TABLE_NAME" property="NumberFormat" value="General" type="String"/><column name="TABLE_NAME" property="VerticalAlignment" value="-4160" type="Double"/><column name="TABLE_TYPE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_TYPE" property="Address" value="$F$4" type="String"/><column name="TABLE_TYPE" property="ColumnWidth" value="13.14" type="Double"/><column name="TABLE_TYPE" property="NumberFormat" value="General" type="String"/><column name="TABLE_TYPE" property="VerticalAlignment" value="-4160" type="Double"/><column name="TABLE_TYPE" property="Validation.Type" value="3" type="Double"/><column name="TABLE_TYPE" property="Validation.Operator" value="1" type="Double"/><column name="TABLE_TYPE" property="Validation.Formula1" value="TABLE; VIEW; PROCEDURE; CODE; HTTP; TEXT; HIDDEN" type="String"/><column name="TABLE_TYPE" property="Validation.AlertStyle" value="1" type="Double"/><column name="TABLE_TYPE" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="TABLE_TYPE" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="TABLE_TYPE" property="Validation.ShowInput" value="True" type="Boolean"/><column name="TABLE_TYPE" property="Validation.ShowError" value="True" type="Boolean"/><column name="TABLE_CODE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_CODE" property="Address" value="$G$4" type="String"/><column name="TABLE_CODE" property="ColumnWidth" value="13.57" type="Double"/><column name="TABLE_CODE" property="NumberFormat" value="General" type="String"/><column name="TABLE_CODE" property="VerticalAlignment" value="-4160" type="Double"/><column name="INSERT_OBJECT" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="INSERT_OBJECT" property="Address" value="$H$4" type="String"/><column name="INSERT_OBJECT" property="ColumnWidth" value="27.86" type="Double"/><column name="INSERT_OBJECT" property="NumberFormat" value="General" type="String"/><column name="INSERT_OBJECT" property="VerticalAlignment" value="-4160" type="Double"/><column name="UPDATE_OBJECT" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="UPDATE_OBJECT" property="Address" value="$I$4" type="String"/><column name="UPDATE_OBJECT" property="ColumnWidth" value="27.86" type="Double"/><column name="UPDATE_OBJECT" property="NumberFormat" value="General" type="String"/><column name="UPDATE_OBJECT" property="VerticalAlignment" value="-4160" type="Double"/><column name="DELETE_OBJECT" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="DELETE_OBJECT" property="Address" value="$J$4" type="String"/><column name="DELETE_OBJECT" property="ColumnWidth" value="27.86" type="Double"/><column name="DELETE_OBJECT" property="NumberFormat" value="General" type="String"/><column name="DELETE_OBJECT" property="VerticalAlignment" value="-4160" type="Double"/><column name="SortFields(1)" property="KeyfieldName" value="TABLE_SCHEMA" type="String"/><column name="SortFields(1)" property="SortOn" value="0" type="Double"/><column name="SortFields(1)" property="Order" value="1" type="Double"/><column name="SortFields(1)" property="DataOption" value="2" type="Double"/><column name="SortFields(2)" property="KeyfieldName" value="TABLE_NAME" type="String"/><column name="SortFields(2)" property="SortOn" value="0" type="Double"/><column name="SortFields(2)" property="Order" value="1" type="Double"/><column name="SortFields(2)" property="DataOption" value="2" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'xls', N'view_translations', N'<table name="xls.view_translations"><columnFormats><column name="" property="ListObjectName" value="translations" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="_RowNum" property="VerticalAlignment" value="-4160" type="Double"/><column name="ID" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="ID" property="Address" value="$C$4" type="String"/><column name="ID" property="NumberFormat" value="General" type="String"/><column name="ID" property="VerticalAlignment" value="-4160" type="Double"/><column name="TABLE_SCHEMA" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_SCHEMA" property="Address" value="$D$4" type="String"/><column name="TABLE_SCHEMA" property="ColumnWidth" value="16.57" type="Double"/><column name="TABLE_SCHEMA" property="NumberFormat" value="General" type="String"/><column name="TABLE_SCHEMA" property="VerticalAlignment" value="-4160" type="Double"/><column name="TABLE_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_NAME" property="Address" value="$E$4" type="String"/><column name="TABLE_NAME" property="ColumnWidth" value="32.14" type="Double"/><column name="TABLE_NAME" property="NumberFormat" value="General" type="String"/><column name="TABLE_NAME" property="VerticalAlignment" value="-4160" type="Double"/><column name="COLUMN_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="COLUMN_NAME" property="Address" value="$F$4" type="String"/><column name="COLUMN_NAME" property="ColumnWidth" value="20.71" type="Double"/><column name="COLUMN_NAME" property="NumberFormat" value="General" type="String"/><column name="COLUMN_NAME" property="VerticalAlignment" value="-4160" type="Double"/><column name="LANGUAGE_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="LANGUAGE_NAME" property="Address" value="$G$4" type="String"/><column name="LANGUAGE_NAME" property="ColumnWidth" value="19.57" type="Double"/><column name="LANGUAGE_NAME" property="NumberFormat" value="General" type="String"/><column name="LANGUAGE_NAME" property="VerticalAlignment" value="-4160" type="Double"/><column name="TRANSLATED_NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TRANSLATED_NAME" property="Address" value="$H$4" type="String"/><column name="TRANSLATED_NAME" property="ColumnWidth" value="30" type="Double"/><column name="TRANSLATED_NAME" property="NumberFormat" value="General" type="String"/><column name="TRANSLATED_NAME" property="VerticalAlignment" value="-4160" type="Double"/><column name="TRANSLATED_DESC" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TRANSLATED_DESC" property="Address" value="$I$4" type="String"/><column name="TRANSLATED_DESC" property="ColumnWidth" value="19.57" type="Double"/><column name="TRANSLATED_DESC" property="NumberFormat" value="General" type="String"/><column name="TRANSLATED_DESC" property="VerticalAlignment" value="-4160" type="Double"/><column name="TRANSLATED_COMMENT" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TRANSLATED_COMMENT" property="Address" value="$J$4" type="String"/><column name="TRANSLATED_COMMENT" property="ColumnWidth" value="25" type="Double"/><column name="TRANSLATED_COMMENT" property="NumberFormat" value="General" type="String"/><column name="TRANSLATED_COMMENT" property="VerticalAlignment" value="-4160" type="Double"/><column name="SortFields(1)" property="KeyfieldName" value="LANGUAGE_NAME" type="String"/><column name="SortFields(1)" property="SortOn" value="0" type="Double"/><column name="SortFields(1)" property="Order" value="1" type="Double"/><column name="SortFields(1)" property="DataOption" value="2" type="Double"/><column name="SortFields(2)" property="KeyfieldName" value="TABLE_SCHEMA" type="String"/><column name="SortFields(2)" property="SortOn" value="0" type="Double"/><column name="SortFields(2)" property="Order" value="1" type="Double"/><column name="SortFields(2)" property="DataOption" value="2" type="Double"/><column name="SortFields(3)" property="KeyfieldName" value="TABLE_NAME" type="String"/><column name="SortFields(3)" property="SortOn" value="0" type="Double"/><column name="SortFields(3)" property="Order" value="1" type="Double"/><column name="SortFields(3)" property="DataOption" value="2" type="Double"/><column name="SortFields(4)" property="KeyfieldName" value="COLUMN_NAME" type="String"/><column name="SortFields(4)" property="SortOn" value="0" type="Double"/><column name="SortFields(4)" property="Order" value="1" type="Double"/><column name="SortFields(4)" property="DataOption" value="2" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N'xls', N'view_workbooks', N'<table name="xls.view_workbooks"><columnFormats><column name="" property="ListObjectName" value="workbooks" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="_RowNum" property="VerticalAlignment" value="-4160" type="Double"/><column name="ID" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="ID" property="Address" value="$C$4" type="String"/><column name="ID" property="NumberFormat" value="General" type="String"/><column name="ID" property="VerticalAlignment" value="-4160" type="Double"/><column name="NAME" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="NAME" property="Address" value="$D$4" type="String"/><column name="NAME" property="ColumnWidth" value="42.14" type="Double"/><column name="NAME" property="NumberFormat" value="General" type="String"/><column name="NAME" property="VerticalAlignment" value="-4160" type="Double"/><column name="TEMPLATE" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TEMPLATE" property="Address" value="$E$4" type="String"/><column name="TEMPLATE" property="ColumnWidth" value="30" type="Double"/><column name="TEMPLATE" property="NumberFormat" value="General" type="String"/><column name="TEMPLATE" property="VerticalAlignment" value="-4160" type="Double"/><column name="DEFINITION" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="DEFINITION" property="Address" value="$F$4" type="String"/><column name="DEFINITION" property="ColumnWidth" value="70.71" type="Double"/><column name="DEFINITION" property="NumberFormat" value="General" type="String"/><column name="DEFINITION" property="VerticalAlignment" value="-4160" type="Double"/><column name="TABLE_SCHEMA" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="TABLE_SCHEMA" property="Address" value="$G$4" type="String"/><column name="TABLE_SCHEMA" property="ColumnWidth" value="16.57" type="Double"/><column name="TABLE_SCHEMA" property="NumberFormat" value="General" type="String"/><column name="TABLE_SCHEMA" property="VerticalAlignment" value="-4160" type="Double"/><column name="SortFields(1)" property="KeyfieldName" value="TABLE_SCHEMA" type="String"/><column name="SortFields(1)" property="SortOn" value="0" type="Double"/><column name="SortFields(1)" property="Order" value="1" type="Double"/><column name="SortFields(1)" property="DataOption" value="0" type="Double"/><column name="SortFields(2)" property="KeyfieldName" value="NAME" type="String"/><column name="SortFields(2)" property="SortOn" value="0" type="Double"/><column name="SortFields(2)" property="Order" value="1" type="Double"/><column name="SortFields(2)" property="DataOption" value="0" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
GO

INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'savetodb_framework_extension', N'version', N'Information', NULL, NULL, N'ATTRIBUTE', N'10.4', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'users', NULL, N'Actions', N'xls', N'xl_actions_set_extended_role_permissions', N'PROCEDURE', NULL, N'_MsgBox', 22, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'users', NULL, N'Actions', N'xls', N'xl_actions_revoke_extended_role_permissions', N'PROCEDURE', NULL, N'_MsgBox', 23, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_columns', NULL, N'Actions', N'xls', N'Developer Guide', N'HTTP', N'https://www.savetodb.com/dev-guide/xls-columns.htm', NULL, 13, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_formats', NULL, N'Actions', N'xls', N'Developer Guide', N'HTTP', N'https://www.savetodb.com/dev-guide/xls-formats.htm', NULL, 13, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_handlers', NULL, N'Actions', N'xls', N'Developer Guide', N'HTTP', N'https://www.savetodb.com/dev-guide/xls-handlers.htm', NULL, 13, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_objects', NULL, N'Actions', N'xls', N'Developer Guide', N'HTTP', N'https://www.savetodb.com/dev-guide/xls-objects.htm', NULL, 13, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_queries', NULL, N'Actions', N'xls', N'Developer Guide', N'HTTP', N'https://www.savetodb.com/dev-guide/xls-queries.htm', NULL, 13, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_translations', NULL, N'Actions', N'xls', N'Developer Guide', N'HTTP', N'https://www.savetodb.com/dev-guide/xls-translations.htm', NULL, 13, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N'xls', N'view_workbooks', NULL, N'Actions', N'xls', N'Developer Guide', N'HTTP', N'https://www.savetodb.com/dev-guide/xls-workbooks.htm', NULL, 13, NULL);
GO

INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'savetodb_user_configuration.xlsx', NULL, N'objects=xls.view_objects,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":null,"TABLE_TYPE":null},"ListObjectName":"objects"}
handlers=xls.view_handlers,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":null,"EVENT_NAME":null,"HANDLER_TYPE":null},"ListObjectName":"handlers"}
columns=xls.view_columns,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":null,"TABLE_NAME":null},"ListObjectName":"columns"}
translations=xls.view_translations,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":null,"LANGUAGE_NAME":null},"ListObjectName":"translations"}
workbooks=xls.view_workbooks,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":null},"ListObjectName":"workbooks"}', N'xls');
GO

print 'SaveToDB Framework Extension installed';
