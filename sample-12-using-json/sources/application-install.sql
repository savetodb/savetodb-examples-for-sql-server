-- =============================================
-- Application: Sample 12 - Using JSON
-- Version 10.8, January 9, 2023
--
-- Copyright 2018-2023 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON
GO

CREATE SCHEMA [s12];
GO

CREATE TABLE [s12].[json_test] (
      [id] int IDENTITY(1,1) NOT NULL
    , [nvarchar] nvarchar(50) NULL
    , [nvarchar(max)] nvarchar(max) NULL
    , [int] int NULL
    , [float] float NULL
    , [datetime] datetime NULL
    , [datetime2(0)] datetime2(0) NULL
    , [datetime2(7)] datetime2(7) NULL
    , [date] date NULL
    , [time(0)] time(0) NULL
    , [time(7)] time(7) NULL
    , [datetimeoffset(0)] datetimeoffset(0) NULL
    , [datetimeoffset(7)] datetimeoffset(7) NULL
    , [bit] bit NULL
    , [uniqueidentifier] uniqueidentifier NULL
    , CONSTRAINT [PK_json_test] PRIMARY KEY ([id])
);
GO

CREATE TABLE [s12].[objects] (
      [ID] int IDENTITY(1,1) NOT NULL
    , [TABLE_SCHEMA] nvarchar(128) NOT NULL
    , [TABLE_NAME] nvarchar(128) NOT NULL
    , [TABLE_TYPE] nvarchar(128) NOT NULL
    , [TABLE_CODE] nvarchar(max) NULL
    , [INSERT_OBJECT] nvarchar(max) NULL
    , [UPDATE_OBJECT] nvarchar(max) NULL
    , [DELETE_OBJECT] nvarchar(max) NULL
    , CONSTRAINT [PK_objects] PRIMARY KEY ([ID])
    , CONSTRAINT [IX_objects] UNIQUE ([TABLE_NAME], [TABLE_SCHEMA])
);
GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Test view 0
--
-- This view has no configured edit procedures.
-- The SaveToDB add-in save changes directly into the json_test table.
-- A user must have SELECT and VIEW DEFINITION permissions on the view
-- and INSERT, UPDATE, DELETE, and VIEW DEFINITION permissions on the table.
-- Otherwise, the add-in cannot detect the underlying table and save changes.
-- =============================================

CREATE VIEW [s12].[view_json_test_0]
AS

SELECT
    t.[id]
    , t.[nvarchar]
    , t.[nvarchar(max)]
    , t.[int]
    , t.[float]
    , t.[datetime]
    , t.[datetime2(0)]
    , t.[datetime2(7)]
    , t.[date]
    , t.[time(0)]
    , t.[time(7)]
    , t.[datetimeoffset(0)]
    , t.[datetimeoffset(7)]
    , t.[bit]
    , CAST(t.[uniqueidentifier] AS char(36)) AS [uniqueidentifier]
FROM
    s12.json_test t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Test view 1
--
-- This view has edit procedures:
-- view_json_test_1_insert, view_json_test_1_update, view_json_test_1_delete
--
-- The SaveToDB add-in links these procedures automatically as the procedures
-- have the underlying object name and suffixes _insert, _update, and _delete.
-- You can use this technique to use edit procedure with no configuration.
-- Otherwise, you can specify the procedures in the xls.objects table.
--
-- The procedures show a standard way to save changes.
-- They have parameters with the view column names and use parameter values
-- with INSERT, UPDATE, and DELETE statements.
-- =============================================

CREATE VIEW [s12].[view_json_test_1]
AS

SELECT
    t.[id]
    , t.[nvarchar]
    , t.[nvarchar(max)]
    , t.[int]
    , t.[float]
    , t.[datetime]
    , t.[datetime2(0)]
    , t.[datetime2(7)]
    , t.[date]
    , t.[time(0)]
    , t.[time(7)]
    , t.[datetimeoffset(0)]
    , t.[datetimeoffset(7)]
    , t.[bit]
    , t.[uniqueidentifier]
FROM
    s12.json_test t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Test view 2
--
-- This view has edit procedures:
-- view_json_test_2_insert, view_json_test_2_update, view_json_test_2_delete
--
-- The SaveToDB add-in links these procedures automatically as the procedures
-- have the underlying object name and suffixes _insert, _update, and _delete.
-- You can use this technique to use edit procedure with no configuration.
-- Otherwise, you can specify the procedures in the xls.objects table.
--
-- The procedures show how to use the @json_values parameter to save changes.
-- =============================================

CREATE VIEW [s12].[view_json_test_2]
AS

SELECT
    t.[id]
    , t.[nvarchar]
    , t.[nvarchar(max)]
    , t.[int]
    , t.[float]
    , t.[datetime]
    , t.[datetime2(0)]
    , t.[datetime2(7)]
    , t.[date]
    , t.[time(0)]
    , t.[time(7)]
    , t.[datetimeoffset(0)]
    , t.[datetimeoffset(7)]
    , t.[bit]
    , t.[uniqueidentifier]
FROM
    s12.json_test t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Test view 3
--
-- This view has edit procedures:
-- view_json_test_3_insert, view_json_test_3_update, view_json_test_3_delete
--
-- The SaveToDB add-in links these procedures automatically as the procedures
-- have the underlying object name and suffixes _insert, _update, and _delete.
-- You can use this technique to use edit procedure with no configuration.
-- Otherwise, you can specify the procedures in the xls.objects table.
--
-- The procedures show how to use the @json_values_f2 parameter to save changes.
-- @json_values_f2 is introduced in SaveToDB 8.16.
-- Unlike @json_values, it contains an object, no an array.
-- =============================================

CREATE VIEW [s12].[view_json_test_3]
AS

SELECT
    t.[id]
    , t.[nvarchar]
    , t.[nvarchar(max)]
    , t.[int]
    , t.[float]
    , t.[datetime]
    , t.[datetime2(0)]
    , t.[datetime2(7)]
    , t.[date]
    , t.[time(0)]
    , t.[time(7)]
    , t.[datetimeoffset(0)]
    , t.[datetimeoffset(7)]
    , t.[bit]
    , t.[uniqueidentifier]
FROM
    s12.json_test t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Test view 4
--
-- This view has edit procedures:
-- view_json_test_4_insert, view_json_test_4_update, view_json_test_4_delete
--
-- The SaveToDB add-in links these procedures automatically as the procedures
-- have the underlying object name and suffixes _insert, _update, and _delete.
-- You can use this technique to use edit procedure with no configuration.
-- Otherwise, you can specify the procedures in the xls.objects table.
--
-- The procedures show how to use @json_columns and @json_values parameters to save changes.
-- These procedures are universal. They can update any table using the input parameters.
-- =============================================

CREATE VIEW [s12].[view_json_test_4]
AS

SELECT
    t.[id]
    , t.[nvarchar]
    , t.[nvarchar(max)]
    , t.[int]
    , t.[float]
    , t.[datetime]
    , t.[datetime2(0)]
    , t.[datetime2(7)]
    , t.[date]
    , t.[time(0)]
    , t.[time(7)]
    , t.[datetimeoffset(0)]
    , t.[datetimeoffset(7)]
    , t.[bit]
    , t.[uniqueidentifier]
FROM
    s12.json_test t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Test view 5
--
-- This view has a single edit procedure: view_json_test_5_update
--
-- This is a new feature introduced in SaveToDB 8.16.
-- A single procedure is used to execute INSERT, UPDATE, and DELETE operations.
-- This is a better approach for procedures with parameters like @json_columns and @json_values,
-- as the procedures are universal and can work with dynamic tables and parameters.
--
-- The SaveToDB add-in links such procedures automatically by the _update suffix.
-- You can use this technique to use edit procedure with no configuration.
-- Otherwise, you can specify the procedures in the UPDATE_OBJECT field of the xls.objects table.
--
-- The procedure shows how to use @json_columns and @json_values parameters to save changes.
-- =============================================

CREATE VIEW [s12].[view_json_test_5]
AS

SELECT
    t.[id]
    , t.[nvarchar]
    , t.[nvarchar(max)]
    , t.[int]
    , t.[float]
    , t.[datetime]
    , t.[datetime2(0)]
    , t.[datetime2(7)]
    , t.[date]
    , t.[time(0)]
    , t.[time(7)]
    , t.[datetimeoffset(0)]
    , t.[datetimeoffset(7)]
    , t.[bit]
    , t.[uniqueidentifier]
FROM
    s12.json_test t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Test view 6
--
-- This view has a single edit procedure: view_json_test_6_update
--
-- This is a new feature introduced in SaveToDB 8.16.
-- A single procedure is used to execute INSERT, UPDATE, and DELETE operations.
-- This is a better approach for procedures with parameters like @json_columns and @json_values,
-- as the procedures are universal and can work with dynamic tables and parameters.
--
-- The SaveToDB add-in links such procedures automatically by the _update suffix.
-- You can use this technique to use edit procedure with no configuration.
-- Otherwise, you can specify the procedures in the UPDATE_OBJECT field of the xls.objects table.
--
-- The procedure shows how to use @json_values_f2 parameter values to save changes.
--
-- @json_values_f2 is a new feature introduced in SaveToDB 8.16.
-- It allows using a single parameter instead of @json_columns and @json_values.
-- =============================================

CREATE VIEW [s12].[view_json_test_6]
AS

SELECT
    t.[id]
    , t.[nvarchar]
    , t.[nvarchar(max)]
    , t.[int]
    , t.[float]
    , t.[datetime]
    , t.[datetime2(0)]
    , t.[datetime2(7)]
    , t.[date]
    , t.[time(0)]
    , t.[time(7)]
    , t.[datetimeoffset(0)]
    , t.[datetimeoffset(7)]
    , t.[bit]
    , t.[uniqueidentifier]
FROM
    s12.json_test t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Test view 7
--
-- This view has a single edit procedure: view_json_test_7_update
--
-- The edit procedure shows how to save all changes using a single procedure call.
--
-- The procedure has the @json_changes_f1 parameter and gets all the table changes in JSON.
-- This new feature is introduced in SaveToDB 8.16.
-- =============================================

CREATE VIEW [s12].[view_json_test_7]
AS

SELECT
    t.[id]
    , t.[nvarchar]
    , t.[nvarchar(max)]
    , t.[int]
    , t.[float]
    , t.[datetime]
    , t.[datetime2(0)]
    , t.[datetime2(7)]
    , t.[date]
    , t.[time(0)]
    , t.[time(7)]
    , t.[datetimeoffset(0)]
    , t.[datetimeoffset(7)]
    , t.[bit]
    , t.[uniqueidentifier]
FROM
    s12.json_test t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Test view 8
--
-- This view has a single edit procedure: view_json_test_8_update
--
-- The edit procedure shows how to save all changes using a single procedure call.
--
-- The procedure has the @json_changes_f2 parameter and gets all the table changes in JSON.
-- This new feature is introduced in SaveToDB 8.16.
-- =============================================

CREATE VIEW [s12].[view_json_test_8]
AS

SELECT
    t.[id]
    , t.[nvarchar]
    , t.[nvarchar(max)]
    , t.[int]
    , t.[float]
    , t.[datetime]
    , t.[datetime2(0)]
    , t.[datetime2(7)]
    , t.[date]
    , t.[time(0)]
    , t.[time(7)]
    , t.[datetimeoffset(0)]
    , t.[datetimeoffset(7)]
    , t.[bit]
    , t.[uniqueidentifier]
FROM
    s12.json_test t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Test view 9
--
-- This view has a single edit procedure: view_json_test_9_update
--
-- The edit procedure shows how to save all changes using a single procedure call.
--
-- The procedure has the @json_changes_f1 parameter and gets all the table changes in JSON.
-- This new feature is introduced in SaveToDB 8.16.
-- =============================================

CREATE VIEW [s12].[view_json_test_9]
AS

SELECT
    t.[id]
    , t.[nvarchar]
    , t.[nvarchar(max)]
    , t.[int]
    , t.[float]
    , t.[datetime]
    , t.[datetime2(0)]
    , t.[datetime2(7)]
    , t.[date]
    , t.[time(0)]
    , t.[time(7)]
    , t.[datetimeoffset(0)]
    , t.[datetimeoffset(7)]
    , t.[bit]
    , t.[uniqueidentifier]
FROM
    s12.json_test t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Test view a
--
-- This view has a single edit procedure: view_json_test_a_update
--
-- The edit procedure shows how to save all changes using a single procedure call.
--
-- The procedure has the @json_changes_f2 parameter and gets all the table changes in JSON.
-- This new feature is introduced in SaveToDB 8.16.
-- =============================================

CREATE VIEW [s12].[view_json_test_a]
AS

SELECT
    t.[id]
    , t.[nvarchar]
    , t.[nvarchar(max)]
    , t.[int]
    , t.[float]
    , t.[datetime]
    , t.[datetime2(0)]
    , t.[datetime2(7)]
    , t.[date]
    , t.[time(0)]
    , t.[time(7)]
    , t.[datetimeoffset(0)]
    , t.[datetimeoffset(7)]
    , t.[bit]
    , t.[uniqueidentifier]
FROM
    s12.json_test t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Test view b
--
-- This view has a single merge procedure: view_json_test_b_merge
--
-- The edit procedure shows how to merge all records using a single procedure call.
--
-- The procedure has the @json_changes_f1 parameter and gets all the data in JSON.
-- This new feature is introduced in SaveToDB 8.16.
-- =============================================

CREATE VIEW [s12].[view_json_test_b]
AS

SELECT
    t.[id]
    , t.[nvarchar]
    , t.[nvarchar(max)]
    , t.[int]
    , t.[float]
    , t.[datetime]
    , t.[datetime2(0)]
    , t.[datetime2(7)]
    , t.[date]
    , t.[time(0)]
    , t.[time(7)]
    , t.[datetimeoffset(0)]
    , t.[datetimeoffset(7)]
    , t.[bit]
    , t.[uniqueidentifier]
FROM
    s12.json_test t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Test view c
--
-- This view has a single merge procedure: view_json_test_c_merge
--
-- The edit procedure shows how to merge all records using a single procedure call.
--
-- The procedure has the @json_changes_f2 parameter and gets all the data in JSON.
-- This new feature is introduced in SaveToDB 8.16.
-- =============================================

CREATE VIEW [s12].[view_json_test_c]
AS

SELECT
    t.[id]
    , t.[nvarchar]
    , t.[nvarchar(max)]
    , t.[int]
    , t.[float]
    , t.[datetime]
    , t.[datetime2(0)]
    , t.[datetime2(7)]
    , t.[date]
    , t.[time(0)]
    , t.[time(7)]
    , t.[datetimeoffset(0)]
    , t.[datetimeoffset(7)]
    , t.[bit]
    , t.[uniqueidentifier]
FROM
    s12.json_test t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Test view d
--
-- This view has a single edit procedure: view_json_test_d_update
--
-- The edit procedure shows how to save all changes using a single procedure call.
--
-- The procedure has the @json_changes_f3 parameter and gets all the table changes in JSON.
-- This new feature is introduced in SaveToDB 9.12.
-- =============================================

CREATE VIEW [s12].[view_json_test_d]
AS

SELECT
    t.[id]
    , t.[nvarchar]
    , t.[nvarchar(max)]
    , t.[int]
    , t.[float]
    , t.[datetime]
    , t.[datetime2(0)]
    , t.[datetime2(7)]
    , t.[date]
    , t.[time(0)]
    , t.[time(7)]
    , t.[datetimeoffset(0)]
    , t.[datetimeoffset(7)]
    , t.[bit]
    , t.[uniqueidentifier]
FROM
    s12.json_test t


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: DELETE procedure for s12.view_json_test_1
--
-- This procedure shows a traditional way to save changes from Excel to a database with the SaveToDB add-in.
-- This is one of the three required procedures for INSERT, UPDATE, and DELETE operations.
--
-- The SaveToDB add-in links such procedures automatically using the _insert, _update, and _delete suffixes.
-- Also, you can specify the procedures in the xls.objects table.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_1_delete]
    @id int = NULL
AS
BEGIN

DELETE FROM s12.json_test WHERE id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: INSERT procedure for s12.view_json_test_1
--
-- This procedure shows a traditional way to save changes from Excel to a database with the SaveToDB add-in.
-- This is one of the three required procedures for INSERT, UPDATE, and DELETE operations.
--
-- The SaveToDB add-in links such procedures automatically using the _insert, _update, and _delete suffixes.
-- Also, you can specify the procedures in the xls.objects table.
--
-- The underlying s12.view_json_test_1 and s12.json_test objects have column names
-- with the characters that are not allowed in the parameter names.
-- The SaveToDB add-in allows using escaped characters instead.
-- For example, the @nvarchar_x0028_max_x0029_ parameter gets the value of the nvarchar(max) column.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_1_insert]
    @nvarchar nvarchar(50) = NULL
    , @nvarchar_x0028_max_x0029_ nvarchar(max) = NULL
    , @int int = NULL
    , @float float = NULL
    , @datetime datetime NULL
    , @datetime2_x0028_0_x0029_ datetime2(0) = NULL
    , @datetime2_x0028_7_x0029_ datetime2(7) = NULL
    , @date date = NULL
    , @time_x0028_0_x0029_ time(0) = NULL
    , @time_x0028_7_x0029_ time(7) = NULL
    , @datetimeoffset_x0028_0_x0029_ datetimeoffset(0) = NULL
    , @datetimeoffset_x0028_7_x0029_ datetimeoffset(7) = NULL
    , @bit bit = NULL
    , @uniqueidentifier uniqueidentifier = NULL
AS
BEGIN

INSERT INTO s12.json_test
    ( [nvarchar]
    , [nvarchar(max)]
    , [int]
    , [float]
    , [datetime]
    , [datetime2(0)]
    , [datetime2(7)]
    , [date]
    , [time(0)]
    , [time(7)]
    , [datetimeoffset(0)]
    , [datetimeoffset(7)]
    , [bit]
    , [uniqueidentifier]
    )
VALUES
    ( @nvarchar
    , @nvarchar_x0028_max_x0029_
    , @int
    , @float
    , @datetime
    , @datetime2_x0028_0_x0029_
    , @datetime2_x0028_7_x0029_
    , @date
    , @time_x0028_0_x0029_
    , @time_x0028_7_x0029_
    , @datetimeoffset_x0028_0_x0029_
    , @datetimeoffset_x0028_7_x0029_
    , @bit
    , @uniqueidentifier
    )

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: INSERT procedure for s12.view_json_test_1
--
-- This procedure shows a traditional way to save changes from Excel to a database with the SaveToDB add-in.
-- This is one of the three required procedures for INSERT, UPDATE, and DELETE operations.
--
-- The SaveToDB add-in links such procedures automatically using the _insert, _update, and _delete suffixes.
-- Also, you can specify the procedures in the xls.objects table.
--
-- The underlying s12.view_json_test_1 and s12.json_test objects have column names
-- with the characters that are not allowed in the parameter names.
-- The SaveToDB add-in allows using escaped characters instead.
-- For example, the @nvarchar_x0028_max_x0029_ parameter gets the value of the nvarchar(max) column.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_1_update]
    @id int = NULL
    , @nvarchar nvarchar(50) = NULL
    , @nvarchar_x0028_max_x0029_ nvarchar(max) = NULL
    , @int int = NULL
    , @float float = NULL
    , @datetime datetime NULL
    , @datetime2_x0028_0_x0029_ datetime2(0) = NULL
    , @datetime2_x0028_7_x0029_ datetime2(7) = NULL
    , @date date = NULL
    , @time_x0028_0_x0029_ time(0) = NULL
    , @time_x0028_7_x0029_ time(7) = NULL
    , @datetimeoffset_x0028_0_x0029_ datetimeoffset(0) = NULL
    , @datetimeoffset_x0028_7_x0029_ datetimeoffset(7) = NULL
    , @bit bit = NULL
    , @uniqueidentifier uniqueidentifier = NULL
AS
BEGIN

UPDATE s12.json_test
SET
    [nvarchar] = @nvarchar
    , [nvarchar(max)] = @nvarchar_x0028_max_x0029_
    , [int] = @int
    , [float] = @float
    , [datetime] = @datetime
    , [datetime2(0)] = @datetime2_x0028_0_x0029_
    , [datetime2(7)] = @datetime2_x0028_7_x0029_
    , [date] = @date
    , [time(0)] = @time_x0028_0_x0029_
    , [time(7)] = @time_x0028_7_x0029_
    , [datetimeoffset(0)] = @datetimeoffset_x0028_0_x0029_
    , [datetimeoffset(7)] = @datetimeoffset_x0028_7_x0029_
    , [bit] = @bit
    , [uniqueidentifier] = @uniqueidentifier
WHERE
    id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: DELETE procedure for s12.view_json_test_2
--
-- This procedure shows a traditional way to save changes from Excel to a database with the SaveToDB add-in.
-- This is one of the three required procedures for INSERT, UPDATE, and DELETE operations.
--
-- The SaveToDB add-in links such procedures automatically using the _insert, _update, and _delete suffixes.
-- Also, you can specify the procedures in the xls.objects table.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_2_delete]
    @id int = NULL
AS
BEGIN

DELETE FROM s12.json_test WHERE id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: INSERT procedure for s12.view_json_test_2
--
-- This procedure shows how to use the @json_columns parameter.
-- @json_columns contains an array of row values.
-- So, to use it, the Excel table must have columns in the same order as the edit procedure.
-- You can use the @json_columns_f2 parameter instead that returns an object.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_2_insert]
    @json_values nvarchar(max)
AS
BEGIN

SET @json_values = '[' + @json_values + ']'    -- Fix for OPENJSON top-level array

INSERT INTO s12.json_test
    ( [nvarchar]
    , [nvarchar(max)]
    , [int]
    , [float]
    , [datetime]
    , [datetime2(0)]
    , [datetime2(7)]
    , [date]
    , [time(0)]
    , [time(7)]
    , [datetimeoffset(0)]
    , [datetimeoffset(7)]
    , [bit]
    , [uniqueidentifier]
    )
SELECT
    t2.[nvarchar] AS [nvarchar]
    , t2.[nvarchar(max)] AS [nvarchar(max)]
    , t2.[int] AS [int]
    , t2.[float] AS [float]
    , t2.[datetime] AS [datetime]
    , t2.[datetime2(0)] AS [datetime2(0)]
    , t2.[datetime2(7)] AS [datetime2(7)]
    , t2.[date] AS [date]
    , t2.[time(0)] AS [time(0)]
    , t2.[time(7)] AS [time(7)]
    , t2.[datetimeoffset(0)] AS [datetimeoffset(0)]
    , t2.[datetimeoffset(7)] AS [datetimeoffset(7)]
    , t2.[bit] AS [bit]
    , t2.[uniqueidentifier] AS [uniqueidentifier]
FROM
    OPENJSON(@json_values) WITH (
        [id] int '$[0]'
        , [nvarchar] nvarchar(50) '$[1]'
        , [nvarchar(max)] nvarchar(max) '$[2]'
        , [int] int '$[3]'
        , [float] float '$[4]'
        , [datetime] datetime '$[5]'
        , [datetime2(0)] datetime2(0) '$[6]'
        , [datetime2(7)] datetime2(7) '$[7]'
        , [date] date '$[8]'
        , [time(0)] time(0) '$[9]'
        , [time(7)] time(7) '$[10]'
        , [datetimeoffset(0)] datetimeoffset(0) '$[11]'
        , [datetimeoffset(7)] datetimeoffset(7) '$[12]'
        , [bit] bit '$[13]'
        , [uniqueidentifier] uniqueidentifier '$[14]'
    ) t2;

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: UPDATE procedure for s12.view_json_test_2
--
-- This procedure shows how to use the @json_columns parameter.
-- @json_columns contains an array of row values.
-- So, to use it, the Excel table must have columns in the same order as the edit procedure.
-- You can use the @json_columns_f2 parameter instead that returns an object.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_2_update]
    @json_values nvarchar(max)
AS
BEGIN

SET @json_values = '[' + @json_values + ']'    -- Fix for OPENJSON top-level array

UPDATE s12.json_test
SET
    [nvarchar] = t2.[nvarchar]
    , [nvarchar(max)] = t2.[nvarchar(max)]
    , [int] = t2.[int]
    , [float] = t2.[float]
    , [datetime] = t2.[datetime]
    , [datetime2(0)] = t2.[datetime2(0)]
    , [datetime2(7)] = t2.[datetime2(7)]
    , [date] = t2.[date]
    , [time(0)] = t2.[time(0)]
    , [time(7)] = t2.[time(7)]
    , [datetimeoffset(0)] = t2.[datetimeoffset(0)]
    , [datetimeoffset(7)] = t2.[datetimeoffset(7)]
    , [bit] = t2.[bit]
    , [uniqueidentifier] = t2.[uniqueidentifier]
FROM
    s12.json_test t
    INNER JOIN OPENJSON(@json_values) WITH (
        [id] int '$[0]'
        , [nvarchar] nvarchar(50) '$[1]'
        , [nvarchar(max)] nvarchar(max) '$[2]'
        , [int] int '$[3]'
        , [float] float '$[4]'
        , [datetime] datetime '$[5]'
        , [datetime2(0)] datetime2(0) '$[6]'
        , [datetime2(7)] datetime2(7) '$[7]'
        , [date] date '$[8]'
        , [time(0)] time(0) '$[9]'
        , [time(7)] time(7) '$[10]'
        , [datetimeoffset(0)] datetimeoffset(0) '$[11]'
        , [datetimeoffset(7)] datetimeoffset(7) '$[12]'
        , [bit] bit '$[13]'
        , [uniqueidentifier] uniqueidentifier '$[14]'
    ) t2 ON t2.id = t.id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: DELETE procedure for s12.view_json_test_3
--
-- This procedure shows a traditional way to save changes from Excel to a database with the SaveToDB add-in.
-- This is one of the three required procedures for INSERT, UPDATE, and DELETE operations.
--
-- The SaveToDB add-in links such procedures automatically using the _insert, _update, and _delete suffixes.
-- Also, you can specify the procedures in the xls.objects table.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_3_delete]
    @id int = NULL
AS
BEGIN

DELETE FROM s12.json_test WHERE id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: INSERT procedure for s12.view_json_test_3
--
-- This procedure shows how to use the @json_columns_f2 parameter
-- that contains an object of row values.
-- The feature is introduced in SaveToDB 8.16.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_3_insert]
    @json_values_f2 nvarchar(max)
AS
BEGIN

INSERT INTO s12.json_test
    ( [nvarchar]
    , [nvarchar(max)]
    , [int]
    , [float]
    , [datetime]
    , [datetime2(0)]
    , [datetime2(7)]
    , [date]
    , [time(0)]
    , [time(7)]
    , [datetimeoffset(0)]
    , [datetimeoffset(7)]
    , [bit]
    , [uniqueidentifier]
    )
SELECT
    t2.[nvarchar] AS [nvarchar]
    , t2.[nvarchar(max)] AS [nvarchar(max)]
    , t2.[int] AS [int]
    , t2.[float] AS [float]
    , t2.[datetime] AS [datetime]
    , t2.[datetime2(0)] AS [datetime2(0)]
    , t2.[datetime2(7)] AS [datetime2(7)]
    , t2.[date] AS [date]
    , t2.[time(0)] AS [time(0)]
    , t2.[time(7)] AS [time(7)]
    , t2.[datetimeoffset(0)] AS [datetimeoffset(0)]
    , t2.[datetimeoffset(7)] AS [datetimeoffset(7)]
    , t2.[bit] AS [bit]
    , t2.[uniqueidentifier] AS [uniqueidentifier]
FROM
    OPENJSON(@json_values_f2) WITH (
        [id] int '$."id"'
        , [nvarchar] nvarchar(50) '$."nvarchar"'
        , [nvarchar(max)] nvarchar(max) '$."nvarchar(max)"'
        , [int] int '$."int"'
        , [float] float '$."float"'
        , [datetime] datetime '$."datetime"'
        , [datetime2(0)] datetime2(0) '$."datetime2(0)"'
        , [datetime2(7)] datetime2(7) '$."datetime2(7)"'
        , [date] date '$."date"'
        , [time(0)] time(0) '$."time(0)"'
        , [time(7)] time(7) '$."time(7)"'
        , [datetimeoffset(0)] datetimeoffset(0) '$."datetimeoffset(0)"'
        , [datetimeoffset(7)] datetimeoffset(7) '$."datetimeoffset(7)"'
        , [bit] bit '$."bit"'
        , [uniqueidentifier] uniqueidentifier '$."uniqueidentifier"'
    ) t2

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: UPDATE procedure for s12.view_json_test_3
--
-- This procedure shows how to use the @json_columns_f2 parameter
-- that contains an object of row values.
-- The feature is introduced in SaveToDB 8.16.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_3_update]
    @json_values_f2 nvarchar(max)
AS
BEGIN

UPDATE s12.json_test
SET
    [nvarchar] = t2.[nvarchar]
    , [nvarchar(max)] = t2.[nvarchar(max)]
    , [int] = t2.[int]
    , [float] = t2.[float]
    , [datetime] = t2.[datetime]
    , [datetime2(0)] = t2.[datetime2(0)]
    , [datetime2(7)] = t2.[datetime2(7)]
    , [date] = t2.[date]
    , [time(0)] = t2.[time(0)]
    , [time(7)] = t2.[time(7)]
    , [datetimeoffset(0)] = t2.[datetimeoffset(0)]
    , [datetimeoffset(7)] = t2.[datetimeoffset(7)]
    , [bit] = t2.[bit]
    , [uniqueidentifier] = t2.[uniqueidentifier]
FROM
    s12.json_test t
    INNER JOIN OPENJSON(@json_values_f2) WITH (
        [id] int '$."id"'
        , [nvarchar] nvarchar(50) '$."nvarchar"'
        , [nvarchar(max)] nvarchar(max) '$."nvarchar(max)"'
        , [int] int '$."int"'
        , [float] float '$."float"'
        , [datetime] datetime '$."datetime"'
        , [datetime2(0)] datetime2(0) '$."datetime2(0)"'
        , [datetime2(7)] datetime2(7) '$."datetime2(7)"'
        , [date] date '$."date"'
        , [time(0)] time(0) '$."time(0)"'
        , [time(7)] time(7) '$."time(7)"'
        , [datetimeoffset(0)] datetimeoffset(0) '$."datetimeoffset(0)"'
        , [datetimeoffset(7)] datetimeoffset(7) '$."datetimeoffset(7)"'
        , [bit] bit '$."bit"'
        , [uniqueidentifier] uniqueidentifier '$."uniqueidentifier"'
    ) t2 ON t2.id = t.id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: DELETE procedure for s12.view_json_test_4
--
-- This procedure shows how to implement a generic DELETE procedure
-- using the @table_name parameter.
--
-- Unlike INSERT and UPDATE procedures, the DELETE procedure must specify
-- the columns used in the WHERE clause of the DELETE statement.
--
-- The reason is simple. Users delete rows in Excel.
-- So, the SaveToDB add-in can use only data saved before on a separate hidden worksheet.
--
-- The add-in detects such required columns using the parameters of the DELETE procedure
-- and saves them whenever a user reloads data.
--
-- So, you can ALTER a quite generic delete procedure if you have generic names and types
-- of primary key columns like @id int.
--
-- Note that the @table_name parameter gets the name of the database object
-- used to select data in Excel.
-- In this case, this is the s12.view_json_test_4 view.
-- So, you have to find the real underlying table using the object name.
--
-- The procedure contains optional @changed_row_count and @changed_row_index parameters
-- introduced in SaveToDB 8.15.
-- You can consume these parameters to execute actions before the first operation and after the last one.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_4_delete]
    @id int
    , @table_name nvarchar(255)
    , @changed_row_count int = NULL
    , @changed_row_index int = NULL
AS
BEGIN
SET NOCOUNT ON

-- PRINT @table_name

SET @table_name = '[s12].[json_test]'

DECLARE @sql nvarchar(max)

SELECT @sql = 'DELETE FROM ' + @table_name + ' WHERE id = ' + CAST(@id AS nvarchar(15))

-- PRINT @sql

SET NOCOUNT OFF

EXEC (@sql)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: INSERT procedure for s12.view_json_test_4
--
-- This procedure shows how to implement a generic INSERT procedure
-- using the @table_name, @json_columns, and @json_values parameters.
--
-- Note that the @table_name parameter gets the name of the database object
-- used to select data in Excel.
-- In this case, this is the s12.view_json_test_4 view.
-- So, you have to find the real underlying table using the object name.
--
-- The procedure contains optional @changed_row_count and @changed_row_index parameters
-- introduced in SaveToDB 8.15.
-- You can consume these parameters to execute actions before the first operation and after the last one.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_4_insert]
    @table_name nvarchar(255)
    , @json_columns nvarchar(max)
    , @json_values nvarchar(max)
    , @changed_row_count int = NULL
    , @changed_row_index int = NULL
AS
BEGIN
SET NOCOUNT ON

-- PRINT @table_name
-- PRINT @json_columns
-- PRINT @json_values

SET @table_name = '[s12].[json_test]'

DECLARE @sql nvarchar(max)

;WITH c (column_id, name, value, index_column_id, skip_value) AS (
    SELECT
        t.column_id
        , '[' + REPLACE(c.value, '''', '''''') + ']' AS name
        , CASE WHEN v.value IS NULL THEN 'NULL' WHEN v.[type] = 1 THEN '''' + REPLACE(v.value, '''', '''''') + '''' ELSE v.value END AS value
        , ic.index_column_id
        , CASE WHEN t.is_identity = 1 OR t.is_computed = 1 OR t.system_type_id = 189
            OR (t.system_type_id = 36 AND NOT t.default_object_id = 0) THEN 1 ELSE 0 END AS skip_value

    FROM
        OPENJSON(@json_columns) c
        INNER JOIN OPENJSON(@json_values) v ON v.[key] = c.[key]
        INNER JOIN sys.columns t ON t.[object_id] = OBJECT_ID(@table_name) AND t.name = c.value
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

-- PRINT @sql

SET NOCOUNT OFF

EXEC (@sql)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: UPDATE procedure for s12.view_json_test_4
--
-- This procedure shows how to implement a generic UPDATE procedure
-- using the @table_name, @json_columns, and @json_values parameters.
--
-- Note that the @table_name parameter gets the name of the database object
-- used to select data in Excel.
-- In this case, this is the dbo.view_json_test_4 view.
-- So, you have to find the real underlying table using the object name.
--
-- The procedure contains optional @changed_row_count and @changed_row_index parameters
-- introduced in SaveToDB 8.15.
-- You can consume these parameters to execute actions before the first operation and after the last one.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_4_update]
    @table_name nvarchar(255)
    , @json_columns nvarchar(max)
    , @json_values nvarchar(max)
    , @changed_row_count int = NULL
    , @changed_row_index int = NULL
AS
BEGIN
SET NOCOUNT ON

-- PRINT @table_name
-- PRINT @json_columns
-- PRINT @json_values

SET @table_name = '[s12].[json_test]'

DECLARE @sql nvarchar(max)

;WITH c (column_id, name, value, index_column_id, skip_value) AS (
    SELECT
        t.column_id
        , '[' + REPLACE(c.value, '''', '''''') + ']' AS name
        , CASE WHEN v.value IS NULL THEN 'NULL' WHEN v.[type] = 1 THEN '''' + REPLACE(v.value, '''', '''''') + '''' ELSE v.value END AS value
        , ic.index_column_id
        , CASE WHEN t.is_identity = 1 OR t.is_computed = 1 OR t.system_type_id = 189
            OR (t.system_type_id = 36 AND NOT t.default_object_id = 0) THEN 1 ELSE 0 END AS skip_value

    FROM
        OPENJSON(@json_columns) c
        INNER JOIN OPENJSON(@json_values) v ON v.[key] = c.[key]
        INNER JOIN sys.columns t ON t.[object_id] = OBJECT_ID(@table_name) AND t.name = c.value
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

-- PRINT @sql

SET NOCOUNT OFF

EXEC (@sql)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: UPDATE procedure for s12.view_json_test_5
--
-- This procedure shows how to implement a single generic INSERT, UPDATE, and DELETE procedure
-- using the @table_name, @edit_action, @json_columns, and @json_values parameters.
--
-- This example improves the previous one. This single procedure replaces
-- view_json_test_4_insert, view_json_test_4_update, and view_json_test_4_delete.
--
-- The procedure executes the required action using the @edit_action value: INSERT, UPDATE, or DELETE
--
-- SaveToDB 8.16 improves the configuration features.
-- You can use a single UPDATE procedure instead of the required INSERT, UPDATE, and DELETE procedures.
--
-- The add-in links such procedures to underlying objects using the _update suffix.
-- You can specify the required procedure in the UPDATE_OBJECT field in the xls.objects table.
--
-- Note that the @table_name parameter gets the name of the database object
-- used to select data in Excel.
-- In this case, this is the s12.view_json_test_5 view.
-- So, you have to find the real underlying table using the object name.
--
-- Such procedures must contain parameters used in the WHERE clause of the DELETE operation like @id.
-- See comments in the description of the s12.view_json_test_4_delete procedure.
--
-- The procedure contains optional @changed_row_count and @changed_row_index parameters
-- introduced in SaveToDB 8.15.
-- You can consume these parameters to execute actions before the first operation and after the last one.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_5_update]
    @id int
    , @table_name nvarchar(255)
    , @edit_action nvarchar(6) = NULL
    , @json_columns nvarchar(max)
    , @json_values nvarchar(max)
AS
BEGIN
SET NOCOUNT ON

-- PRINT @table_name
-- PRINT @json_action
-- PRINT @json_columns
-- PRINT @json_values

SET @table_name = '[s12].[json_test]'

DECLARE @sql nvarchar(max)

IF @edit_action = 'INSERT'
    BEGIN
    WITH c (column_id, name, value, index_column_id, skip_value) AS (
        SELECT
            t.column_id
            , '[' + REPLACE(c.value, '''', '''''') + ']' AS name
            , CASE WHEN v.value IS NULL THEN 'NULL' WHEN v.[type] = 1 THEN '''' + REPLACE(v.value, '''', '''''') + '''' ELSE v.value END AS value
            , ic.index_column_id
            , CASE WHEN t.is_identity = 1 OR t.is_computed = 1 OR t.system_type_id = 189
                OR (t.system_type_id = 36 AND NOT t.default_object_id = 0) THEN 1 ELSE 0 END AS skip_value

        FROM
            OPENJSON(@json_columns) c
            INNER JOIN OPENJSON(@json_values) v ON v.[key] = c.[key]
            INNER JOIN sys.columns t ON t.[object_id] = OBJECT_ID(@table_name) AND t.name = c.value
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
            , '[' + REPLACE(c.value, '''', '''''') + ']' AS name
            , CASE WHEN v.value IS NULL THEN 'NULL' WHEN v.[type] = 1 THEN '''' + REPLACE(v.value, '''', '''''') + '''' ELSE v.value END AS value
            , ic.index_column_id
            , CASE WHEN t.is_identity = 1 OR t.is_computed = 1 OR t.system_type_id = 189
                OR (t.system_type_id = 36 AND NOT t.default_object_id = 0) THEN 1 ELSE 0 END AS skip_value

        FROM
            OPENJSON(@json_columns) c
            INNER JOIN OPENJSON(@json_values) v ON v.[key] = c.[key]
            INNER JOIN sys.columns t ON t.[object_id] = OBJECT_ID(@table_name) AND t.name = c.value
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
-- Description: UPDATE procedure for s12.view_json_test_6
--
-- This procedure shows how to implement a single generic INSERT, UPDATE, and DELETE procedure.
--
-- It extends the s12.view_json_test_5_update example replacing @json_columns and @json_values parameters
-- with a single @json_values_f2 parameter introduced in SaveToDB 8.16.
--
-- See comments in the description of the s12.view_json_test_5_update procedure.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_6_update]
    @id int
    , @table_name nvarchar(255)
    , @edit_action nvarchar(6) = NULL
    , @json_values_f2 nvarchar(max)
AS
BEGIN
SET NOCOUNT ON

-- PRINT @table_name
-- PRINT @json_action
-- PRINT @json_columns
-- PRINT @json_values

SET @table_name = '[s12].[json_test]'

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
-- Description: Edit procedure for view_json_test_7
--
-- This is a single procedure used to apply data changes using a single procedure call.
-- This new feature is introduced in SaveToDB 8.16.
--
-- The procedure has the @json_changes_f1 parameter that gets all changes in JSON.
--
-- The procedure also has the @id parameter that defines columns that must be passed for DELETE operations.
-- The add-in saves values of such parameters on the hidden worksheet and passes values
-- when the source Excel rows are already deleted.
--
-- Please note that single call procedures must be specified as a single UPDATE object,
-- using the _update suffix or using the UPDATE_OBJECT field in the xls.objects table.
--
-- This feature is introduced in SaveToDB 8.16.
-- Traditionally, the add-in requires procedures for INSERT, UPDATE, and DELETE operations
-- and it calls the procedures for every new, updated, or deleted row.
--
-- So, this new technique allows updating data using a single procedure call for any number of rows
-- that can dramatically improve the perfomance.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_7_update]
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
INSERT INTO [s12].[json_test]
    ( [nvarchar]
    , [nvarchar(max)]
    , [int]
    , [float]
    , [datetime]
    , [datetime2(0)]
    , [datetime2(7)]
    , [date]
    , [time(0)]
    , [time(7)]
    , [datetimeoffset(0)]
    , [datetimeoffset(7)]
    , [bit]
    , [uniqueidentifier]
    )
SELECT
    t2.[nvarchar] AS [nvarchar]
    , t2.[nvarchar(max)] AS [nvarchar(max)]
    , t2.[int] AS [int]
    , t2.[float] AS [float]
    , t2.[datetime] AS [datetime]
    , t2.[datetime2(0)] AS [datetime2(0)]
    , t2.[datetime2(7)] AS [datetime2(7)]
    , t2.[date] AS [date]
    , t2.[time(0)] AS [time(0)]
    , t2.[time(7)] AS [time(7)]
    , t2.[datetimeoffset(0)] AS [datetimeoffset(0)]
    , t2.[datetimeoffset(7)] AS [datetimeoffset(7)]
    , t2.[bit] AS [bit]
    , t2.[uniqueidentifier] AS [uniqueidentifier]
FROM
    OPENJSON(@insert) WITH (
        [rows] nvarchar(max) '$.rows' AS json
    ) t1
    CROSS APPLY OPENJSON(t1.[rows]) WITH (
        [id] int '$[0]'
        , [nvarchar] nvarchar(50) '$[1]'
        , [nvarchar(max)] nvarchar(max) '$[2]'
        , [int] int '$[3]'
        , [float] float '$[4]'
        , [datetime] datetime '$[5]'
        , [datetime2(0)] datetime2(0) '$[6]'
        , [datetime2(7)] datetime2(7) '$[7]'
        , [date] date '$[8]'
        , [time(0)] time(0) '$[9]'
        , [time(7)] time(7) '$[10]'
        , [datetimeoffset(0)] datetimeoffset(0) '$[11]'
        , [datetimeoffset(7)] datetimeoffset(7) '$[12]'
        , [bit] bit '$[13]'
        , [uniqueidentifier] uniqueidentifier '$[14]'
    ) t2

IF @update IS NOT NULL
UPDATE s12.json_test
SET
    [nvarchar] = t2.[nvarchar]
    , [nvarchar(max)] = t2.[nvarchar(max)]
    , [int] = t2.[int]
    , [float] = t2.[float]
    , [datetime] = t2.[datetime]
    , [datetime2(0)] = t2.[datetime2(0)]
    , [datetime2(7)] = t2.[datetime2(7)]
    , [date] = t2.[date]
    , [time(0)] = t2.[time(0)]
    , [time(7)] = t2.[time(7)]
    , [datetimeoffset(0)] = t2.[datetimeoffset(0)]
    , [datetimeoffset(7)] = t2.[datetimeoffset(7)]
    , [bit] = t2.[bit]
    , [uniqueidentifier] = t2.[uniqueidentifier]
FROM
    s12.json_test t
    INNER JOIN (
        SELECT
            t2.[id] AS [id]
            , t2.[nvarchar] AS [nvarchar]
            , t2.[nvarchar(max)] AS [nvarchar(max)]
            , t2.[int] AS [int]
            , t2.[float] AS [float]
            , t2.[datetime] AS [datetime]
            , t2.[datetime2(0)] AS [datetime2(0)]
            , t2.[datetime2(7)] AS [datetime2(7)]
            , t2.[date] AS [date]
            , t2.[time(0)] AS [time(0)]
            , t2.[time(7)] AS [time(7)]
            , t2.[datetimeoffset(0)] AS [datetimeoffset(0)]
            , t2.[datetimeoffset(7)] AS [datetimeoffset(7)]
            , t2.[bit] AS [bit]
            , t2.[uniqueidentifier] AS [uniqueidentifier]
        FROM
            OPENJSON(@update) WITH (
                [rows] nvarchar(max) '$.rows' AS json
            ) t1
            CROSS APPLY OPENJSON(t1.[rows]) WITH (
                [id] int '$[0]'
                , [nvarchar] nvarchar(50) '$[1]'
                , [nvarchar(max)] nvarchar(max) '$[2]'
                , [int] int '$[3]'
                , [float] float '$[4]'
                , [datetime] datetime '$[5]'
                , [datetime2(0)] datetime2(0) '$[6]'
                , [datetime2(7)] datetime2(7) '$[7]'
                , [date] date '$[8]'
                , [time(0)] time(0) '$[9]'
                , [time(7)] time(7) '$[10]'
                , [datetimeoffset(0)] datetimeoffset(0) '$[11]'
                , [datetimeoffset(7)] datetimeoffset(7) '$[12]'
                , [bit] bit '$[13]'
                , [uniqueidentifier] uniqueidentifier '$[14]'
            ) t2
    ) t2 ON t2.id = t.id

IF @delete IS NOT NULL
DELETE FROM s12.json_test
FROM
    s12.json_test t
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
-- Description: Edit procedure for view_json_test_8
--
-- This is a single procedure used to apply data changes using a single procedure call.
-- This new feature is introduced in SaveToDB 8.16.
--
-- This procedure extends the previous example and shows use of the @json_changes_f2 parameter.
--
-- See the description of the view_json_test_7_update procedure.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_8_update]
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
INSERT INTO [s12].[json_test]
    ( [nvarchar]
    , [nvarchar(max)]
    , [int]
    , [float]
    , [datetime]
    , [datetime2(0)]
    , [datetime2(7)]
    , [date]
    , [time(0)]
    , [time(7)]
    , [datetimeoffset(0)]
    , [datetimeoffset(7)]
    , [bit]
    , [uniqueidentifier]
    )
SELECT
    t2.[nvarchar] AS [nvarchar]
    , t2.[nvarchar(max)] AS [nvarchar(max)]
    , t2.[int] AS [int]
    , t2.[float] AS [float]
    , t2.[datetime] AS [datetime]
    , t2.[datetime2(0)] AS [datetime2(0)]
    , t2.[datetime2(7)] AS [datetime2(7)]
    , t2.[date] AS [date]
    , t2.[time(0)] AS [time(0)]
    , t2.[time(7)] AS [time(7)]
    , t2.[datetimeoffset(0)] AS [datetimeoffset(0)]
    , t2.[datetimeoffset(7)] AS [datetimeoffset(7)]
    , t2.[bit] AS [bit]
    , t2.[uniqueidentifier] AS [uniqueidentifier]
FROM
    OPENJSON(@insert) WITH (
        [rows] nvarchar(max) '$.rows' AS json
    ) t1
    CROSS APPLY OPENJSON(t1.[rows]) WITH (
        [id] int '$."id"'
        , [nvarchar] nvarchar(50) '$."nvarchar"'
        , [nvarchar(max)] nvarchar(max) '$."nvarchar(max)"'
        , [int] int '$."int"'
        , [float] float '$."float"'
        , [datetime] datetime '$."datetime"'
        , [datetime2(0)] datetime2(0) '$."datetime2(0)"'
        , [datetime2(7)] datetime2(7) '$."datetime2(7)"'
        , [date] date '$."date"'
        , [time(0)] time(0) '$."time(0)"'
        , [time(7)] time(7) '$."time(7)"'
        , [datetimeoffset(0)] datetime2(0) '$."datetimeoffset(0)"'
        , [datetimeoffset(7)] datetime2(7) '$."datetimeoffset(7)"'
        , [bit] bit '$."bit"'
        , [uniqueidentifier] uniqueidentifier '$."uniqueidentifier"'
    ) t2;

IF @update IS NOT NULL
UPDATE s12.json_test
SET
    [nvarchar] = t2.[nvarchar]
    , [nvarchar(max)] = t2.[nvarchar(max)]
    , [int] = t2.[int]
    , [float] = t2.[float]
    , [datetime] = t2.[datetime]
    , [datetime2(0)] = t2.[datetime2(0)]
    , [datetime2(7)] = t2.[datetime2(7)]
    , [date] = t2.[date]
    , [time(0)] = t2.[time(0)]
    , [time(7)] = t2.[time(7)]
    , [datetimeoffset(0)] = t2.[datetimeoffset(0)]
    , [datetimeoffset(7)] = t2.[datetimeoffset(7)]
    , [bit] = t2.[bit]
    , [uniqueidentifier] = t2.[uniqueidentifier]
FROM
    s12.json_test t
    INNER JOIN (
        SELECT
            t2.[id] AS [id]
            , t2.[nvarchar] AS [nvarchar]
            , t2.[nvarchar(max)] AS [nvarchar(max)]
            , t2.[int] AS [int]
            , t2.[float] AS [float]
            , t2.[datetime] AS [datetime]
            , t2.[datetime2(0)] AS [datetime2(0)]
            , t2.[datetime2(7)] AS [datetime2(7)]
            , t2.[date] AS [date]
            , t2.[time(0)] AS [time(0)]
            , t2.[time(7)] AS [time(7)]
            , t2.[datetimeoffset(0)] AS [datetimeoffset(0)]
            , t2.[datetimeoffset(7)] AS [datetimeoffset(7)]
            , t2.[bit] AS [bit]
            , t2.[uniqueidentifier] AS [uniqueidentifier]
        FROM
            OPENJSON(@update) WITH (
                [rows] nvarchar(max) '$.rows' AS json
            ) t1
            CROSS APPLY OPENJSON(t1.[rows]) WITH (
                [id] int '$."id"'
                , [nvarchar] nvarchar(50) '$."nvarchar"'
                , [nvarchar(max)] nvarchar(max) '$."nvarchar(max)"'
                , [int] int '$."int"'
                , [float] float '$."float"'
                , [datetime] datetime '$."datetime"'
                , [datetime2(0)] datetime2(0) '$."datetime2(0)"'
                , [datetime2(7)] datetime2(7) '$."datetime2(7)"'
                , [date] date '$."date"'
                , [time(0)] time(0) '$."time(0)"'
                , [time(7)] time(7) '$."time(7)"'
                , [datetimeoffset(0)] datetimeoffset(0) '$."datetimeoffset(0)"'
                , [datetimeoffset(7)] datetimeoffset(7) '$."datetimeoffset(7)"'
                , [bit] bit '$."bit"'
                , [uniqueidentifier] uniqueidentifier '$."uniqueidentifier"'
            ) t2
    ) t2 ON t2.id = t.id;

IF @delete IS NOT NULL
DELETE FROM s12.json_test
FROM
    s12.json_test t
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
-- Description: Edit procedure for view_json_test_9
--
-- This is a single procedure used to apply data changes using a single procedure call.
-- This is a new feature introduced in SaveToDB 8.16.
--
-- This procedure is generic and can update any table specified with @table_name.
--
-- Note that @json_changes_f1 contains the table_name value.
-- However, this is the name of the database object used to select data in Excel.
-- In this example, it is the s12.view_json_test_9 view.
-- You have to find the real underlying table using the object name.
--
-- The procedure has the @id parameter that defines columns that must be passed for DELETE operations.
-- The add-in saves values of such parameters on the hidden worksheet and passes values
-- when the source Excel rows are already deleted.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_9_update]
    @id int = NULL
    , @json_changes_f1 nvarchar(max) = NULL
AS
BEGIN
SET NOCOUNT ON

DECLARE @table_name nvarchar(255)
DECLARE @insert nvarchar(max),  @update nvarchar(max), @delete nvarchar(max)

SELECT
    @table_name = t1.table_name
    , @insert = t2.[insert]
    , @update = t2.[update]
    , @delete = t2.[delete]
FROM
    OPENJSON(@json_changes_f1) WITH (
        table_name nvarchar(255) '$.table_name'
        , actions nvarchar(max) AS json
    ) t1
    CROSS APPLY OPENJSON(t1.actions) WITH (
        [insert] nvarchar(max) '$.insert' AS json
        , [update] nvarchar(max) '$.update' AS json
        , [delete] nvarchar(max) '$.delete' AS json
    ) t2

SET @table_name = '[s12].[json_test]'

DECLARE @insert_sql nvarchar(max), @update_sql nvarchar(max), @delete_sql nvarchar(max)

IF @insert IS NOT NULL
WITH c (column_id, column_name, datatype, index_column_id, skip_value, column_index) AS (
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
        , t2.[key] AS column_index
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
        SELECT '        , ' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' ' + c.datatype + ' ''$[' + CAST(c.column_index AS nvarchar(10)) + ']''' + CHAR(13) + CHAR(10)
            FROM c ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 10, '        ')
    + '    ) t2'

IF @update IS NOT NULL
WITH c (column_id, column_name, datatype, index_column_id, skip_value, column_index) AS (
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
        , t2.[key] AS column_index
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
        SELECT '                , ' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' ' + c.datatype + ' ''$[' + CAST(c.column_index AS nvarchar(10)) + ']''' + CHAR(13) + CHAR(10)
            FROM c ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 18, '                ')
    + '            ) t2' + CHAR(13) + CHAR(10)
    + '    ) t2 ON '
    + STUFF((
        SELECT '    AND t.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' = t2.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c WHERE c.index_column_id IS NOT NULL ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 8, '')

IF @delete IS NOT NULL
WITH c (column_id, column_name, datatype, index_column_id, skip_value, column_index) AS (
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
        , t2.[key] AS column_index
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
        SELECT '                , ' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' ' + c.datatype + ' ''$[' + CAST(c.column_index AS nvarchar(10)) + ']''' + CHAR(13) + CHAR(10)
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
-- Description: Edit procedure for view_json_test_a
--
-- This is a single procedure used to apply data changes using a single procedure call.
-- This is a new feature introduced in SaveToDB 8.16.
--
-- This procedure is generic and can update any table specified with @table_name.
--
-- Note that @json_changes_f2 contains the table_name value.
-- However, this is the name of the database object used to select data in Excel.
-- In this example, it is the s12.view_json_test_a view.
-- You have to find the real underlying table using the object name.
--
-- The procedure has the @id parameter that defines columns that must be passed for DELETE operations.
-- The add-in saves values of such parameters on the hidden worksheet and passes values
-- when the source Excel rows are already deleted.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_a_update]
    @id int = NULL
    , @json_changes_f2 nvarchar(max) = NULL
AS
BEGIN
SET NOCOUNT ON

DECLARE @table_name nvarchar(255)
DECLARE @insert nvarchar(max),  @update nvarchar(max), @delete nvarchar(max)

SELECT
    @table_name = t1.table_name
    , @insert = t2.[insert]
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

SET @table_name = '[s12].[json_test]'

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
-- Description: Merge procedure for view_json_test_b
--
-- This procedure shows how to merge all data using a single procedure call.
-- This is a new feature introduced in SaveToDB 8.16.
--
-- This procedure is generic and can update any table specified with @table_name.
--
-- Note that @json_changes_f1 contains the table_name value.
-- However, this is the name of the database object used to select data in Excel.
-- In this example, it is the s12.view_json_test_b view.
-- You have to find the real underlying table using the object name.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_b_merge]
    @json_changes_f1 nvarchar(max) = NULL
AS
BEGIN
SET NOCOUNT ON

DECLARE @table_name nvarchar(255)
DECLARE @merge nvarchar(max)

SELECT
    @table_name = t1.table_name
    , @merge = t2.[insert]
FROM
    OPENJSON(@json_changes_f1) WITH (
        table_name nvarchar(255) '$.table_name'
        , actions nvarchar(max) AS json
    ) t1
    CROSS APPLY OPENJSON(t1.actions) WITH (
        [insert] nvarchar(max) '$.merge' AS json
    ) t2

SET @table_name = '[s12].[json_test]'

DECLARE @merge_sql nvarchar(max)

IF @merge IS NOT NULL
WITH c (column_id, column_name, datatype, index_column_id, skip_value, column_index) AS (
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
        , t2.[key] AS column_index
    FROM
        OPENJSON(@merge) WITH ([columns] nvarchar(max) '$.columns' AS json) t1
        CROSS APPLY OPENJSON(t1.[columns]) t2
        INNER JOIN sys.columns c ON c.[object_id] = OBJECT_ID(@table_name) AND c.[name] = t2.[value]
        INNER JOIN sys.types t ON t.user_type_id = c.user_type_id
        LEFT OUTER JOIN sys.indexes i ON i.[object_id] = c.[object_id] AND i.is_primary_key = 1
        LEFT OUTER JOIN sys.index_columns ic ON ic.[object_id] = i.[object_id] AND ic.index_id = i.index_id AND ic.column_id = c.column_id
)
SELECT
    @merge_sql = ''
    + 'MERGE ' + @table_name + ' AS t' + CHAR(13) + CHAR(10)
    + 'USING (' + CHAR(13) + CHAR(10)
    + '    SELECT' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '        , t2.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' AS ' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 10, '        ')
    + '    FROM
        OPENJSON(@merge) WITH (
            [rows] nvarchar(max) ''$.rows'' AS json
        ) t1
        CROSS APPLY OPENJSON(t1.[rows]) WITH (' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '            , ' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' ' + c.datatype + ' ''$[' + CAST(c.column_index AS nvarchar(10)) + ']''' + CHAR(13) + CHAR(10)
            FROM c ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 14, '            ')
    + '        ) t2' + CHAR(13) + CHAR(10)
    + '    ) s ON '
    + STUFF((
        SELECT '    AND s.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' = t.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c WHERE c.index_column_id IS NOT NULL ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 8, '')
    + 'WHEN MATCHED THEN
    UPDATE SET' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '        , ' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' = s.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c WHERE c.skip_value = 0 ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 10, '          ')
    + 'WHEN NOT MATCHED THEN
    INSERT' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '        , ' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c WHERE c.skip_value = 0 ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 10, '        ( ')
    + '        )
    VALUES' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '        , s.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c WHERE c.skip_value = 0 ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 10, '        ( ')
    + '        );' + CHAR(13) + CHAR(10)

-- PRINT @merge_sql

IF @merge_sql IS NOT NULL
EXEC sp_executesql @merge_sql, N'@merge nvarchar(max)', @merge = @merge

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Merge procedure for view_json_test_b
--
-- This procedure shows how to merge all data using a single procedure call.
-- This is a new feature introduced in SaveToDB 8.16.
--
-- This procedure is generic and can update any table specified with @table_name.
--
-- Note that @json_changes_f2 contains the table_name value.
-- However, this is the name of the database object used to select data in Excel.
-- In this example, it is the s12.view_json_test_b view.
-- You have to find the real underlying table using the object name.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_c_merge]
    @json_changes_f2 nvarchar(max) = NULL
AS
BEGIN
SET NOCOUNT ON

DECLARE @table_name nvarchar(255)
DECLARE @merge nvarchar(max)

SELECT
    @table_name = t1.table_name
    , @merge = t2.[insert]
FROM
    OPENJSON(@json_changes_f2) WITH (
        table_name nvarchar(255) '$.table_name'
        , actions nvarchar(max) AS json
    ) t1
    CROSS APPLY OPENJSON(t1.actions) WITH (
        [insert] nvarchar(max) '$.merge' AS json
    ) t2

SET @table_name = '[s12].[json_test]'

DECLARE @merge_sql nvarchar(max)

IF @merge IS NOT NULL
WITH c (column_id, column_name, datatype, index_column_id, skip_value, column_index) AS (
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
        , t2.[key] AS column_index
    FROM
        OPENJSON(@merge) WITH ([columns] nvarchar(max) '$.columns' AS json) t1
        CROSS APPLY OPENJSON(t1.[columns]) t2
        INNER JOIN sys.columns c ON c.[object_id] = OBJECT_ID(@table_name) AND c.[name] = t2.[value]
        INNER JOIN sys.types t ON t.user_type_id = c.user_type_id
        LEFT OUTER JOIN sys.indexes i ON i.[object_id] = c.[object_id] AND i.is_primary_key = 1
        LEFT OUTER JOIN sys.index_columns ic ON ic.[object_id] = i.[object_id] AND ic.index_id = i.index_id AND ic.column_id = c.column_id
)
SELECT
    @merge_sql = ''
    + 'MERGE ' + @table_name + ' AS t' + CHAR(13) + CHAR(10)
    + 'USING (' + CHAR(13) + CHAR(10)
    + '    SELECT' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '        , t2.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' AS ' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 10, '        ')
    + '    FROM
        OPENJSON(@merge) WITH (
            [rows] nvarchar(max) ''$.rows'' AS json
        ) t1
        CROSS APPLY OPENJSON(t1.[rows]) WITH (' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '            , ' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' ' + c.datatype + ' ''$."' + REPLACE(c.column_name, '''', '''''') + '"''' + CHAR(13) + CHAR(10)
            FROM c ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 14, '            ')
    + '        ) t2' + CHAR(13) + CHAR(10)
    + '    ) s ON '
    + STUFF((
        SELECT '    AND s.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' = t.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c WHERE c.index_column_id IS NOT NULL ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 8, '')
    + 'WHEN MATCHED THEN
    UPDATE SET' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '        , ' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + ' = s.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c WHERE c.skip_value = 0 ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 10, '          ')
    + 'WHEN NOT MATCHED THEN
    INSERT' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '        , ' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c WHERE c.skip_value = 0 ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 10, '        ( ')
    + '        )
    VALUES' + CHAR(13) + CHAR(10)
    + STUFF((
        SELECT '        , s.' + REPLACE(QUOTENAME(c.column_name), '''', '''''') + CHAR(13) + CHAR(10)
            FROM c WHERE c.skip_value = 0 ORDER BY c.column_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(MAX)'), 1, 10, '        ( ')
    + '        );' + CHAR(13) + CHAR(10)

-- PRINT @merge_sql

IF @merge_sql IS NOT NULL
EXEC sp_executesql @merge_sql, N'@merge nvarchar(max)', @merge = @merge

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Edit procedure for view_json_test_d
--
-- This procedure tests the @json_changes_f3 parameter introduced in SaveToDB 9.12.
-- Contrary to @json_changes_f3 it recieves all the columns including empty ones.
--
-- This procedure calls the s12.view_json_test_a_update procedure
-- that uses the @json_changes_f2 parameter that accepts a variable set of columns.
-- =============================================

CREATE PROCEDURE [s12].[view_json_test_d_update]
    @id int = NULL
    , @json_changes_f3 nvarchar(max) = NULL
AS
BEGIN
SET NOCOUNT ON

EXEC s12.view_json_test_a_update @id, @json_changes_f3

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure generates test records
-- =============================================

CREATE PROCEDURE [s12].[xl_actions_set_test_records]
    @count int = NULL
AS
BEGIN
SET NOCOUNT ON

DELETE FROM s12.json_test WHERE id > @count

SET IDENTITY_INSERT s12.json_test ON

;WITH e1(n) AS
(
    SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
    SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
)
, e2(n) AS (SELECT e2.n * 10    + e1.n FROM e1 e2 CROSS JOIN e1)
, e3(n) AS (SELECT e3.n * 100   + e2.n FROM e1 e3 CROSS JOIN e2)
, e4(n) AS (SELECT e4.n * 1000  + e3.n FROM e1 e4 CROSS JOIN e3)
, e5(n) AS (SELECT e5.n * 10000 + e4.n FROM e1 e5 CROSS JOIN e4)

INSERT INTO s12.json_test (
    [id]
    , [nvarchar]
    , [nvarchar(max)]
    , [int]
    , [float]
    , [datetime]
    , [datetime2(0)]
    , [datetime2(7)]
    , [date]
    , [time(0)]
    , [time(7)]
    , [datetimeoffset(0)]
    , [datetimeoffset(7)]
    , [bit]
    , [uniqueidentifier]
)
SELECT
    e.n
    , N'abc'
    , N'max'
    , 123
    , 123.12
    , '20181031 00:00:00.000'
    , '20181031 15:01:20'
    , '20181031 15:01:20.1234567'
    , '20181031'
    , '15:01:20'
    , '15:01:20.1234567'
    , '20181031 15:01:20 +03:00'
    , '20181031 15:01:20.1234567 +03:00'
    , 1
    , 'F184B08F-C81C-45F6-A57F-5ABD9991F28F'
FROM
    e5 e
    LEFT OUTER JOIN s12.json_test t ON t.id = e.n
WHERE
    e.n BETWEEN 1 AND @count
    AND t.id IS NULL

SET IDENTITY_INSERT s12.json_test OFF

DBCC CHECKIDENT ('s12.json_test', RESEED, @count) WITH NO_INFOMSGS;

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure generates test records
-- =============================================

CREATE PROCEDURE [s12].[xl_actions_set_test_records_100k]
AS
BEGIN

EXEC s12.xl_actions_set_test_records @count = 100000

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure generates test records
-- =============================================

CREATE PROCEDURE [s12].[xl_actions_set_test_records_10k]
AS
BEGIN

EXEC s12.xl_actions_set_test_records @count = 10000

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure generates test records
-- =============================================

CREATE PROCEDURE [s12].[xl_actions_set_test_records_5]
AS
BEGIN

EXEC s12.xl_actions_set_test_records @count = 5

END


GO

SET IDENTITY_INSERT [s12].[json_test] ON;
INSERT INTO [s12].[json_test] ([id], [nvarchar], [nvarchar(max)], [int], [float], [datetime], [datetime2(0)], [datetime2(7)], [date], [time(0)], [time(7)], [datetimeoffset(0)], [datetimeoffset(7)], [bit], [uniqueidentifier]) VALUES (1, N'abc', N'max', 123, 123.12, '20181031 00:00:00.000', '20181031 15:01:20', '20181031 15:01:20.1234567', '20181031', '15:01:20', '15:01:20.1234567', '20181031 15:01:20 -05:00', '20181031 15:01:20.1234567 -05:00', 1, 'f184b08f-c81c-45f6-a57f-5abd9991f28f');
INSERT INTO [s12].[json_test] ([id], [nvarchar], [nvarchar(max)], [int], [float], [datetime], [datetime2(0)], [datetime2(7)], [date], [time(0)], [time(7)], [datetimeoffset(0)], [datetimeoffset(7)], [bit], [uniqueidentifier]) VALUES (2, N'abc', N'max', 123, 123.12, '20181031 00:00:00.000', '20181031 15:01:20', '20181031 15:01:20.1234567', '20181031', '15:01:20', '15:01:20.1234567', '20181031 15:01:20 -05:00', '20181031 15:01:20.1234567 -05:00', 1, 'f184b08f-c81c-45f6-a57f-5abd9991f28f');
INSERT INTO [s12].[json_test] ([id], [nvarchar], [nvarchar(max)], [int], [float], [datetime], [datetime2(0)], [datetime2(7)], [date], [time(0)], [time(7)], [datetimeoffset(0)], [datetimeoffset(7)], [bit], [uniqueidentifier]) VALUES (3, N'abc', N'max', 123, 123.12, '20181031 00:00:00.000', '20181031 15:01:20', '20181031 15:01:20.1234567', '20181031', '15:01:20', '15:01:20.1234567', '20181031 15:01:20 -05:00', '20181031 15:01:20.1234567 -05:00', 1, 'f184b08f-c81c-45f6-a57f-5abd9991f28f');
INSERT INTO [s12].[json_test] ([id], [nvarchar], [nvarchar(max)], [int], [float], [datetime], [datetime2(0)], [datetime2(7)], [date], [time(0)], [time(7)], [datetimeoffset(0)], [datetimeoffset(7)], [bit], [uniqueidentifier]) VALUES (4, N'abc', N'max', 123, 123.12, '20181031 00:00:00.000', '20181031 15:01:20', '20181031 15:01:20.1234567', '20181031', '15:01:20', '15:01:20.1234567', '20181031 15:01:20 -05:00', '20181031 15:01:20.1234567 -05:00', 1, 'f184b08f-c81c-45f6-a57f-5abd9991f28f');
INSERT INTO [s12].[json_test] ([id], [nvarchar], [nvarchar(max)], [int], [float], [datetime], [datetime2(0)], [datetime2(7)], [date], [time(0)], [time(7)], [datetimeoffset(0)], [datetimeoffset(7)], [bit], [uniqueidentifier]) VALUES (5, N'abc', N'max', 123, 123.12, '20181031 00:00:00.000', '20181031 15:01:20', '20181031 15:01:20.1234567', '20181031', '15:01:20', '15:01:20.1234567', '20181031 15:01:20 -05:00', '20181031 15:01:20.1234567 -05:00', 1, 'f184b08f-c81c-45f6-a57f-5abd9991f28f');
SET IDENTITY_INSERT [s12].[json_test] OFF;
GO

SET IDENTITY_INSERT [s12].[objects] ON;
INSERT INTO [s12].[objects] ([ID], [TABLE_SCHEMA], [TABLE_NAME], [TABLE_TYPE], [TABLE_CODE], [INSERT_OBJECT], [UPDATE_OBJECT], [DELETE_OBJECT]) VALUES (1, N's12', N'code_json_test_0', N'CODE', N'SELECT * FROM s12.view_json_test_0', NULL, NULL, NULL);
INSERT INTO [s12].[objects] ([ID], [TABLE_SCHEMA], [TABLE_NAME], [TABLE_TYPE], [TABLE_CODE], [INSERT_OBJECT], [UPDATE_OBJECT], [DELETE_OBJECT]) VALUES (3, N's12', N'code_json_test_2', N'CODE', N'SELECT * FROM s12.view_json_test_0', N'EXEC s12.view_json_test_2_insert @json_values', N'EXEC s12.view_json_test_2_update @json_values', N'EXEC s12.view_json_test_2_delete @id');
INSERT INTO [s12].[objects] ([ID], [TABLE_SCHEMA], [TABLE_NAME], [TABLE_TYPE], [TABLE_CODE], [INSERT_OBJECT], [UPDATE_OBJECT], [DELETE_OBJECT]) VALUES (4, N's12', N'code_json_test_3', N'CODE', N'SELECT * FROM s12.view_json_test_0', N'EXEC s12.view_json_test_3_insert @json_values_f2', N'EXEC s12.view_json_test_3_update @json_values_f2', N'EXEC s12.view_json_test_3_delete @id');
INSERT INTO [s12].[objects] ([ID], [TABLE_SCHEMA], [TABLE_NAME], [TABLE_TYPE], [TABLE_CODE], [INSERT_OBJECT], [UPDATE_OBJECT], [DELETE_OBJECT]) VALUES (5, N's12', N'code_json_test_4', N'CODE', N'SELECT * FROM s12.view_json_test_0', N'EXEC s12.view_json_test_4_insert @table_name, @json_columns, @json_values, @changed_row_count, @changed_row_index', N'EXEC s12.view_json_test_4_update @table_name, @json_columns, @json_values, @changed_row_count, @changed_row_index', N'EXEC s12.view_json_test_2_delete @id, @table_name, @changed_row_count, @changed_row_index');
INSERT INTO [s12].[objects] ([ID], [TABLE_SCHEMA], [TABLE_NAME], [TABLE_TYPE], [TABLE_CODE], [INSERT_OBJECT], [UPDATE_OBJECT], [DELETE_OBJECT]) VALUES (6, N's12', N'code_json_test_5', N'CODE', N'SELECT * FROM s12.view_json_test_0', NULL, N'EXEC s12.view_json_test_5_update @id, @table_name, @edit_action, @json_columns, @json_values', NULL);
INSERT INTO [s12].[objects] ([ID], [TABLE_SCHEMA], [TABLE_NAME], [TABLE_TYPE], [TABLE_CODE], [INSERT_OBJECT], [UPDATE_OBJECT], [DELETE_OBJECT]) VALUES (7, N's12', N'code_json_test_6', N'CODE', N'SELECT * FROM s12.view_json_test_0', NULL, N'EXEC s12.view_json_test_6_update @id, @table_name, @edit_action, @json_values_f2', NULL);
INSERT INTO [s12].[objects] ([ID], [TABLE_SCHEMA], [TABLE_NAME], [TABLE_TYPE], [TABLE_CODE], [INSERT_OBJECT], [UPDATE_OBJECT], [DELETE_OBJECT]) VALUES (8, N's12', N'code_json_test_7', N'CODE', N'SELECT * FROM s12.view_json_test_0', NULL, N'EXEC s12.view_json_test_7_update @id, @json_changes_f1', NULL);
INSERT INTO [s12].[objects] ([ID], [TABLE_SCHEMA], [TABLE_NAME], [TABLE_TYPE], [TABLE_CODE], [INSERT_OBJECT], [UPDATE_OBJECT], [DELETE_OBJECT]) VALUES (9, N's12', N'code_json_test_8', N'CODE', N'SELECT * FROM s12.view_json_test_0', NULL, N'EXEC s12.view_json_test_8_update @id, @json_changes_f2', NULL);
INSERT INTO [s12].[objects] ([ID], [TABLE_SCHEMA], [TABLE_NAME], [TABLE_TYPE], [TABLE_CODE], [INSERT_OBJECT], [UPDATE_OBJECT], [DELETE_OBJECT]) VALUES (10, N's12', N'code_json_test_9', N'CODE', N'SELECT * FROM s12.view_json_test_0', NULL, N'EXEC s12.view_json_test_9_update @id, @json_changes_f1', NULL);
INSERT INTO [s12].[objects] ([ID], [TABLE_SCHEMA], [TABLE_NAME], [TABLE_TYPE], [TABLE_CODE], [INSERT_OBJECT], [UPDATE_OBJECT], [DELETE_OBJECT]) VALUES (11, N's12', N'code_json_test_a', N'CODE', N'SELECT * FROM s12.view_json_test_0', NULL, N'EXEC s12.view_json_test_a_update @id, @json_changes_f2', NULL);
SET IDENTITY_INSERT [s12].[objects] OFF;
GO

print 'Application installed';
