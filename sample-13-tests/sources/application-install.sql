-- =============================================
-- Application: Sample 13 - Tests
-- Version 10.8, January 9, 2023
--
-- Copyright 2019-2023 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON
GO

CREATE SCHEMA [s13];
GO

CREATE TABLE [s13].[datatypes] (
      [id] int IDENTITY(1,1) NOT NULL
    , [bigint] bigint NULL
    , [binary] binary(8) NULL
    , [binary16] binary(16) NULL
    , [bit] bit NULL
    , [char] char(10) NULL
    , [char36] char(36) NULL
    , [date] date NULL
    , [datetime] datetime NULL
    , [datetime20] datetime2(0) NULL
    , [datetime23] datetime2(3) NULL
    , [datetime27] datetime2(7) NULL
    , [datetimeoffset0] datetimeoffset(0) NULL
    , [datetimeoffset3] datetimeoffset(3) NULL
    , [datetimeoffset7] datetimeoffset(7) NULL
    , [decimal] decimal(18,0) NULL
    , [decimal92] decimal(9,2) NULL
    , [decimal150] decimal(15,0) NULL
    , [decimal152] decimal(15,2) NULL
    , [decimal192] decimal(19,2) NULL
    , [decimal282] decimal(28,2) NULL
    , [decimal382] decimal(38,2) NULL
    , [float] float NULL
    , [geography] geography NULL
    , [geometry] geometry NULL
    , [hierarchyid] hierarchyid NULL
    , [image] image NULL
    , [int] int NULL
    , [money] money NULL
    , [nchar] nchar(10) NULL
    , [ntext] ntext NULL
    , [numeric] numeric(18,0) NULL
    , [numeric92] numeric(9,2) NULL
    , [numeric150] numeric(15,0) NULL
    , [numeric152] numeric(15,2) NULL
    , [numeric192] numeric(19,2) NULL
    , [numeric282] numeric(28,2) NULL
    , [numeric382] numeric(38,2) NULL
    , [nvarchar] nvarchar(255) NULL
    , [nvarcharmax] nvarchar(max) NULL
    , [real] real NULL
    , [smalldatetime] smalldatetime NULL
    , [smallint] smallint NULL
    , [smallmoney] smallmoney NULL
    , [sql_variant] sql_variant NULL
    , [sysname] sysname NULL
    , [text] text NULL
    , [time0] time(0) NULL
    , [time3] time(3) NULL
    , [time7] time(7) NULL
    , [timestamp] timestamp NULL
    , [tinyint] tinyint NULL
    , [uniqueidentifier] uniqueidentifier NULL
    , [varbinary] varbinary(1024) NULL
    , [varchar] varchar(255) NULL
    , [varcharmax] varchar(max) NULL
    , [xml] xml NULL
    , CONSTRAINT [PK_datatypes] PRIMARY KEY ([id])
);
GO

CREATE TABLE [s13].[quotes] (
      ['] nvarchar(50) NOT NULL
    , [''] nvarchar(50) NOT NULL
    , [,] nvarchar(50) NOT NULL
    , [-] nvarchar(50) NOT NULL
    , [@] nvarchar(50) NOT NULL
    , [@@] nvarchar(50) NOT NULL
    , [`] nvarchar(50) NULL
    , [``] nvarchar(50) NULL
    , ["] nvarchar(50) NULL
    , [""] nvarchar(50) NULL
    , []]] nvarchar(50) NULL
    , [[] nvarchar(50) NULL
    , [[]]] nvarchar(50) NULL
    , [+] nvarchar(50) NULL
    , [*] nvarchar(50) NULL
    , [%] nvarchar(50) NULL
    , [%%] nvarchar(50) NULL
    , [=] nvarchar(50) NULL
    , [;] nvarchar(50) NULL
    , [:] nvarchar(50) NULL
    , [<>] nvarchar(50) NULL
    , [&] nvarchar(50) NULL
    , [.] nvarchar(50) NULL
    , [..] nvarchar(50) NULL
    , CONSTRAINT [PK_quotes] PRIMARY KEY (['], [''], [,], [-], [@], [@@])
);
GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects columns of s13.datatypes
-- =============================================

CREATE VIEW [s13].[view_datatype_columns]
AS

SELECT
    c.TABLE_SCHEMA
    , c.TABLE_NAME
    , c.COLUMN_NAME
    , c.ORDINAL_POSITION
    , NULL AS IS_PRIMARY_KEY
    , c.IS_NULLABLE
    , sc.is_identity AS IS_IDENTITY
    , sc.is_computed AS IS_COMPUTED
    , c.COLUMN_DEFAULT
    , c.DATA_TYPE
    , c.CHARACTER_MAXIMUM_LENGTH AS MAX_LENGTH
    , COALESCE(c.NUMERIC_PRECISION, c.DATETIME_PRECISION) AS [PRECISION]
    , c.NUMERIC_SCALE AS SCALE
FROM
    INFORMATION_SCHEMA.COLUMNS c
    INNER JOIN sys.columns sc
        ON sc.[object_id] = OBJECT_ID(QUOTENAME(c.TABLE_SCHEMA) + '.' + QUOTENAME(c.TABLE_NAME)) AND UPPER(sc.name) = UPPER(c.COLUMN_NAME)
WHERE
    NOT c.TABLE_SCHEMA IN ('sys')
    AND NOT c.TABLE_NAME LIKE 'sys%'
    AND c.TABLE_SCHEMA = 's13' AND c.TABLE_NAME = 'datatypes'


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects parameters of s13.usp_datatype procedures
-- =============================================

CREATE VIEW [s13].[view_datatype_parameters]
AS

SELECT
    p.SPECIFIC_SCHEMA
    , p.SPECIFIC_NAME
    , p.ORDINAL_POSITION
    , p.PARAMETER_MODE
    , p.PARAMETER_NAME
    , p.DATA_TYPE
    , p.CHARACTER_MAXIMUM_LENGTH AS MAX_LENGTH
    , COALESCE(p.NUMERIC_PRECISION, p.DATETIME_PRECISION) AS [PRECISION]
    , p.NUMERIC_SCALE AS SCALE
FROM
    INFORMATION_SCHEMA.PARAMETERS p
WHERE
    NOT (LEFT(p.SPECIFIC_NAME, 3) = 'sp_' AND p.SPECIFIC_SCHEMA = 'dbo')
    AND NOT (LEFT(p.SPECIFIC_NAME, 3) = 'fn_' AND p.SPECIFIC_SCHEMA = 'dbo')
    AND NOT (LEFT(p.SPECIFIC_NAME, 3) = 'sys' AND p.SPECIFIC_SCHEMA = 'dbo')
    AND NOT p.SPECIFIC_SCHEMA IN ('sys')
    AND p.SPECIFIC_SCHEMA = 's13' AND p.SPECIFIC_NAME LIKE 'usp_datatypes%'


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure selects data from s13.datatypes
-- =============================================

CREATE PROCEDURE [s13].[usp_datatypes]
AS
BEGIN

SET NOCOUNT ON

SELECT
    t.id
    , t.[bigint]
    , t.[binary]
    , t.[binary16]
    , t.[bit]
    , t.[char]
    , t.[char36]
    , t.[date]
    , t.[datetime]
    , t.[datetime20]
    , t.[datetime23]
    , t.[datetime27]
    , t.[datetimeoffset0]
    , t.[datetimeoffset3]
    , t.[datetimeoffset7]
    , t.[decimal]
    , t.[decimal92]
    , t.[decimal150]
    , t.[decimal152]
    , t.[decimal192]
    , t.[decimal282]
    , t.[decimal382]
    , t.[float]
    , t.[geography]
    , t.[geometry]
    , t.[hierarchyid]
    , t.[image]
    , t.[int]
    , t.[money]
    , t.[nchar]
    , t.[ntext]
    , t.[numeric]
    , t.[numeric92]
    , t.[numeric150]
    , t.[numeric152]
    , t.[numeric192]
    , t.[numeric282]
    , t.[numeric382]
    , t.[nvarchar]
    , t.[nvarcharmax]
    , t.[real]
    , t.[smalldatetime]
    , t.[smallint]
    , t.[smallmoney]
    , t.[sql_variant]
    , t.[sysname]
    , t.[text]
    , t.[time0]
    , t.[time3]
    , t.[time7]
    , t.[timestamp]
    , t.[tinyint]
    , t.[uniqueidentifier]
    , t.[varbinary]
    , t.[varchar]
    , t.[varcharmax]
    , t.[xml]
FROM
    s13.datatypes t

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure deleted data from s13.datatypes
-- =============================================

CREATE PROCEDURE [s13].[usp_datatypes_delete]
    @id int
AS
BEGIN

DELETE FROM s13.datatypes
WHERE
    id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure inserts data into s13.datatypes
-- =============================================

CREATE PROCEDURE [s13].[usp_datatypes_insert]
    @bigint bigint = NULL
    , @binary binary(8) = NULL
    , @binary16 binary(16) = NULL
    , @bit bit = NULL
    , @char char(10) = NULL
    , @char36 char(36) = NULL
    , @date date = NULL
    , @datetime datetime = NULL
    , @datetime20 datetime2(0) = NULL
    , @datetime23 datetime2(3) = NULL
    , @datetime27 datetime2(7) = NULL
    , @datetimeoffset0 datetimeoffset(0) = NULL
    , @datetimeoffset3 datetimeoffset(3) = NULL
    , @datetimeoffset7 datetimeoffset(7) = NULL
    , @decimal decimal(18,0) = NULL
    , @decimal92 decimal(9,2) = NULL
    , @decimal150 decimal(15,0) = NULL
    , @decimal152 decimal(15,2) = NULL
    , @decimal192 decimal(19,2) = NULL
    , @decimal282 decimal(28,2) = NULL
    , @decimal382 decimal(38,2) = NULL
    , @float float = NULL
    , @geography geography = NULL
    , @geometry geometry = NULL
    , @hierarchyid hierarchyid = NULL
    , @image image = NULL
    , @int int = NULL
    , @money money = NULL
    , @nchar nchar(10) = NULL
    , @ntext ntext = NULL
    , @numeric numeric(18,0) = NULL
    , @numeric92 numeric(9,2) = NULL
    , @numeric150 numeric(15,0) = NULL
    , @numeric152 numeric(15,2) = NULL
    , @numeric192 numeric(19,2) = NULL
    , @numeric282 numeric(28,2) = NULL
    , @numeric382 numeric(38,2) = NULL
    , @nvarchar nvarchar(255) = NULL
    , @nvarcharmax nvarchar(max) = NULL
    , @real real = NULL
    , @smalldatetime smalldatetime = NULL
    , @smallint smallint = NULL
    , @smallmoney smallmoney = NULL
    , @sql_variant sql_variant = NULL
    , @sysname sysname = NULL
    , @text text = NULL
    , @time0 time(0) = NULL
    , @time3 time(3) = NULL
    , @time7 time(7) = NULL
    , @timestamp timestamp = NULL
    , @tinyint tinyint = NULL
    , @uniqueidentifier uniqueidentifier = NULL
    , @varbinary varbinary(1024) = NULL
    , @varchar varchar(255) = NULL
    , @varcharmax varchar(max) = NULL
    , @xml xml = NULL
AS
BEGIN

INSERT INTO s13.datatypes
    ( [bigint]
    , [binary]
    , [binary16]
    , [bit]
    , [char]
    , [char36]
    , [date]
    , [datetime]
    , [datetime20]
    , [datetime23]
    , [datetime27]
    , [datetimeoffset0]
    , [datetimeoffset3]
    , [datetimeoffset7]
    , [decimal]
    , [decimal92]
    , [decimal150]
    , [decimal152]
    , [decimal192]
    , [decimal282]
    , [decimal382]
    , [float]
    , [geography]
    , [geometry]
    , [hierarchyid]
    , [image]
    , [int]
    , [money]
    , [nchar]
    , [ntext]
    , [numeric]
    , [numeric92]
    , [numeric150]
    , [numeric152]
    , [numeric192]
    , [numeric282]
    , [numeric382]
    , [nvarchar]
    , [nvarcharmax]
    , [real]
    , [smalldatetime]
    , [smallint]
    , [smallmoney]
    , [sql_variant]
    , [sysname]
    , [text]
    , [time0]
    , [time3]
    , [time7]
    --, [timestamp]
    , [tinyint]
    , [uniqueidentifier]
    , [varbinary]
    , [varchar]
    , [varcharmax]
    , [xml]
    )
VALUES
    ( @bigint
    , @binary
    , @binary16
    , @bit
    , @char
    , @char36
    , @date
    , @datetime
    , @datetime20
    , @datetime23
    , @datetime27
    , @datetimeoffset0
    , @datetimeoffset3
    , @datetimeoffset7
    , @decimal
    , @decimal92
    , @decimal150
    , @decimal152
    , @decimal192
    , @decimal282
    , @decimal382
    , @float
    , @geography
    , @geometry
    , @hierarchyid
    , @image
    , @int
    , @money
    , @nchar
    , @ntext
    , @numeric
    , @numeric92
    , @numeric150
    , @numeric152
    , @numeric192
    , @numeric282
    , @numeric382
    , @nvarchar
    , @nvarcharmax
    , @real
    , @smalldatetime
    , @smallint
    , @smallmoney
    , @sql_variant
    , @sysname
    , @text
    , @time0
    , @time3
    , @time7
    --, @timestamp
    , @tinyint
    , @uniqueidentifier
    , @varbinary
    , @varchar
    , @varcharmax
    , @xml
    )

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure updates data of s13.datatypes
-- =============================================

CREATE PROCEDURE [s13].[usp_datatypes_update]
    @id int
    , @bigint bigint = NULL
    , @binary binary(8) = NULL
    , @binary16 binary(16) = NULL
    , @bit bit = NULL
    , @char char(10) = NULL
    , @char36 char(36) = NULL
    , @date date = NULL
    , @datetime datetime = NULL
    , @datetime20 datetime2(0) = NULL
    , @datetime23 datetime2(3) = NULL
    , @datetime27 datetime2(7) = NULL
    , @datetimeoffset0 datetimeoffset(0) = NULL
    , @datetimeoffset3 datetimeoffset(3) = NULL
    , @datetimeoffset7 datetimeoffset(7) = NULL
    , @decimal decimal(18,0) = NULL
    , @decimal92 decimal(9,2) = NULL
    , @decimal150 decimal(15,0) = NULL
    , @decimal152 decimal(15,2) = NULL
    , @decimal192 decimal(19,2) = NULL
    , @decimal282 decimal(28,2) = NULL
    , @decimal382 decimal(38,2) = NULL
    , @float float = NULL
    , @geography geography = NULL
    , @geometry geometry = NULL
    , @hierarchyid hierarchyid = NULL
    , @image image = NULL
    , @int int = NULL
    , @money money = NULL
    , @nchar nchar(10) = NULL
    , @ntext ntext = NULL
    , @numeric numeric(18,0) = NULL
    , @numeric92 numeric(9,2) = NULL
    , @numeric150 numeric(15,0) = NULL
    , @numeric152 numeric(15,2) = NULL
    , @numeric192 numeric(19,2) = NULL
    , @numeric282 numeric(28,2) = NULL
    , @numeric382 numeric(38,2) = NULL
    , @nvarchar nvarchar(255) = NULL
    , @nvarcharmax nvarchar(max) = NULL
    , @real real = NULL
    , @smalldatetime smalldatetime = NULL
    , @smallint smallint = NULL
    , @smallmoney smallmoney = NULL
    , @sql_variant sql_variant = NULL
    , @sysname sysname = NULL
    , @text text = NULL
    , @time0 time(0) = NULL
    , @time3 time(3) = NULL
    , @time7 time(7) = NULL
    , @timestamp timestamp = NULL
    , @tinyint tinyint = NULL
    , @uniqueidentifier uniqueidentifier = NULL
    , @varbinary varbinary(1024) = NULL
    , @varchar varchar(255) = NULL
    , @varcharmax varchar(max) = NULL
    , @xml xml = NULL
AS
BEGIN

UPDATE s13.datatypes
SET
    [bigint] = @bigint
    , [binary] = @binary
    , [binary16] = @binary16
    , [bit] = @bit
    , [char] = @char
    , [char36] = @char36
    , [date] = @date
    , [datetime] = @datetime
    , [datetime20] = @datetime20
    , [datetime23] = @datetime23
    , [datetime27] = @datetime27
    , [datetimeoffset0] = @datetimeoffset0
    , [datetimeoffset3] = @datetimeoffset3
    , [datetimeoffset7] = @datetimeoffset7
    , [decimal] = @decimal
    , [decimal92] = @decimal92
    , [decimal150] = @decimal150
    , [decimal152] = @decimal152
    , [decimal192] = @decimal192
    , [decimal282] = @decimal282
    , [decimal382] = @decimal382
    , [float] = @float
    , [geography] = @geography
    , [geometry] = @geometry
    , [hierarchyid] = @hierarchyid
    , [image] = @image
    , [int] = @int
    , [money] = @money
    , [nchar] = @nchar
    , [ntext] = @ntext
    , [numeric] = @numeric
    , [numeric92] = @numeric92
    , [numeric150] = @numeric150
    , [numeric152] = @numeric152
    , [numeric192] = @numeric192
    , [numeric282] = @numeric282
    , [numeric382] = @numeric382
    , [nvarchar] = @nvarchar
    , [nvarcharmax] = @nvarcharmax
    , [real] = @real
    , [smalldatetime] = @smalldatetime
    , [smallint] = @smallint
    , [smallmoney] = @smallmoney
    , [sql_variant] = @sql_variant
    , [sysname] = @sysname
    , [text] = @text
    , [time0] = @time0
    , [time3] = @time3
    , [time7] = @time7
    --, [timestamp] = @timestamp
    , [tinyint] = @tinyint
    , [uniqueidentifier] = @uniqueidentifier
    , [varbinary] = @varbinary
    , [varchar] = @varchar
    , [varcharmax] = @varcharmax
    , [xml] = @xml
WHERE
    id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure selects data from s13.datatypes
-- =============================================

CREATE PROCEDURE [s13].[usp_odbc_datatypes]
AS
BEGIN

SET NOCOUNT ON

SELECT
    t.id
    , t.[bigint]
    , CAST(CONVERT(varchar(max), t.[binary], 1) AS text) AS [binary]
    , CAST(CONVERT(varchar(max), t.[binary16], 1) AS text) AS [binary16]
    , CAST(t.[bit] AS tinyint) AS [bit]
    , t.[char]
    , t.[char36]
    , CAST(t.[date] AS datetime) AS [date]
    , CONVERT(varchar(50), t.datetime, 121) AS datetime
    , CAST(t.datetime20 AS datetime) AS datetime20
    , CONVERT(varchar(50), t.datetime23, 121) AS datetime23
    , CONVERT(varchar(50), t.datetime27, 121) AS datetime27
    , CONVERT(varchar(50), t.datetimeoffset0, 121) AS datetimeoffset0
    , CONVERT(varchar(50), t.datetimeoffset3, 121) AS datetimeoffset3
    , CONVERT(varchar(50), t.datetimeoffset7, 121) AS datetimeoffset7
    , CAST(t.[decimal] AS varchar) AS [decimal]
    , t.[decimal92]
    , t.[decimal150]
    , t.[decimal152]
    , CAST(t.[decimal192] AS varchar(50)) [decimal192]
    , CAST(t.[decimal282] AS varchar(50)) [decimal282]
    , CAST(t.[decimal382] AS varchar(50)) [decimal382]
    , t.[float]
    , CAST(t.[geography].STAsText() AS text) AS [geography]
    , CAST(t.[geometry].STAsText() AS text) AS [geometry]
    , CAST(t.[hierarchyid] AS varchar(892)) AS [hierarchyid]
    , CAST(CONVERT(varchar(max), CAST(t.[image] AS varbinary), 1) AS text) AS [image]
    , t.[int]
    , t.[money]
    , t.[nchar]
    , t.[ntext]
    , CAST(t.[numeric] AS varchar(50)) [numeric]
    , t.[numeric92]
    , t.[numeric150]
    , t.[numeric152]
    , CAST(t.[numeric192] AS varchar(50)) AS [numeric192]
    , CAST(t.[numeric282] AS varchar(50)) AS [numeric282]
    , CAST(t.[numeric382] AS varchar(50)) AS [numeric382]
    , t.[nvarchar]
    , CAST(t.[nvarcharmax] AS ntext) AS [nvarcharmax]
    , t.[real]
    , t.[smalldatetime]
    , t.[smallint]
    , t.[smallmoney]
    , t.[sql_variant]
    , t.[sysname]
    , t.[text]
    , CONVERT(varchar(50), t.time0, 121) AS time0
    , CONVERT(varchar(50), t.time3, 121) AS time3
    , CONVERT(varchar(50), t.time7, 121) AS time7
    , CONVERT(char(18), CONVERT(binary(8), t.[timestamp], 1), 1) AS [timestamp]
    , t.[tinyint]
    , CAST(t.[uniqueidentifier] AS char(36)) AS [uniqueidentifier]
    , CAST(CONVERT(varchar(max), t.[varbinary],1) AS text) AS [varbinary]
    , t.[varchar]
    , CAST(t.[varcharmax] AS text) AS [varcharmax]
    , CAST(CAST(t.[xml] AS nvarchar(max)) AS ntext) AS [xml]
FROM
    s13.datatypes t

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure deleted data from s13.datatypes
-- =============================================

CREATE PROCEDURE [s13].[usp_odbc_datatypes_delete]
    @id int
AS
BEGIN

DELETE FROM s13.datatypes
WHERE
    id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure inserts data into s13.datatypes
-- =============================================

CREATE PROCEDURE [s13].[usp_odbc_datatypes_insert]
    @bigint bigint = NULL
    , @binary binary(8) = NULL
    , @binary16 binary(16) = NULL
    , @bit bit = NULL
    , @char char(10) = NULL
    , @char36 char(36) = NULL
    , @date date = NULL
    , @datetime datetime = NULL
    , @datetime20 datetime2(0) = NULL
    , @datetime23 datetime2(3) = NULL
    , @datetime27 datetime2(7) = NULL
    , @datetimeoffset0 datetimeoffset(0) = NULL
    , @datetimeoffset3 datetimeoffset(3) = NULL
    , @datetimeoffset7 datetimeoffset(7) = NULL
    , @decimal decimal(18,0) = NULL
    , @decimal92 decimal(9,2) = NULL
    , @decimal150 decimal(15,0) = NULL
    , @decimal152 decimal(15,2) = NULL
    , @decimal192 decimal(19,2) = NULL
    , @decimal282 decimal(28,2) = NULL
    , @decimal382 decimal(38,2) = NULL
    , @float float = NULL
    , @geography geography = NULL
    , @geometry geometry = NULL
    , @hierarchyid hierarchyid = NULL
    , @image image = NULL
    , @int int = NULL
    , @money money = NULL
    , @nchar nchar(10) = NULL
    , @ntext ntext = NULL
    , @numeric numeric(18,0) = NULL
    , @numeric92 numeric(9,2) = NULL
    , @numeric150 numeric(15,0) = NULL
    , @numeric152 numeric(15,2) = NULL
    , @numeric192 numeric(19,2) = NULL
    , @numeric282 numeric(28,2) = NULL
    , @numeric382 numeric(38,2) = NULL
    , @nvarchar nvarchar(255) = NULL
    , @nvarcharmax nvarchar(max) = NULL
    , @real real = NULL
    , @smalldatetime smalldatetime = NULL
    , @smallint smallint = NULL
    , @smallmoney smallmoney = NULL
    , @sql_variant sql_variant = NULL
    , @sysname sysname = NULL
    , @text text = NULL
    , @time0 time(0) = NULL
    , @time3 time(3) = NULL
    , @time7 time(7) = NULL
    , @timestamp timestamp = NULL
    , @tinyint tinyint = NULL
    , @uniqueidentifier uniqueidentifier = NULL
    , @varbinary varbinary(1024) = NULL
    , @varchar varchar(255) = NULL
    , @varcharmax varchar(max) = NULL
    , @xml xml = NULL
AS
BEGIN

INSERT INTO s13.datatypes
    ( [bigint]
    , [binary]
    , [binary16]
    , [bit]
    , [char]
    , [char36]
    , [date]
    , [datetime]
    , [datetime20]
    , [datetime23]
    , [datetime27]
    , [datetimeoffset0]
    , [datetimeoffset3]
    , [datetimeoffset7]
    , [decimal]
    , [decimal92]
    , [decimal150]
    , [decimal152]
    , [decimal192]
    , [decimal282]
    , [decimal382]
    , [float]
    , [geography]
    , [geometry]
    , [hierarchyid]
    , [image]
    , [int]
    , [money]
    , [nchar]
    , [ntext]
    , [numeric]
    , [numeric92]
    , [numeric150]
    , [numeric152]
    , [numeric192]
    , [numeric282]
    , [numeric382]
    , [nvarchar]
    , [nvarcharmax]
    , [real]
    , [smalldatetime]
    , [smallint]
    , [smallmoney]
    , [sql_variant]
    , [sysname]
    , [text]
    , [time0]
    , [time3]
    , [time7]
    --, [timestamp]
    , [tinyint]
    , [uniqueidentifier]
    , [varbinary]
    , [varchar]
    , [varcharmax]
    , [xml]
    )
VALUES
    ( @bigint
    , @binary
    , @binary16
    , @bit
    , @char
    , @char36
    , @date
    , @datetime
    , @datetime20
    , @datetime23
    , @datetime27
    , @datetimeoffset0
    , @datetimeoffset3
    , @datetimeoffset7
    , @decimal
    , @decimal92
    , @decimal150
    , @decimal152
    , @decimal192
    , @decimal282
    , @decimal382
    , @float
    , @geography
    , @geometry
    , @hierarchyid
    , @image
    , @int
    , @money
    , @nchar
    , @ntext
    , @numeric
    , @numeric92
    , @numeric150
    , @numeric152
    , @numeric192
    , @numeric282
    , @numeric382
    , @nvarchar
    , @nvarcharmax
    , @real
    , @smalldatetime
    , @smallint
    , @smallmoney
    , @sql_variant
    , @sysname
    , @text
    , @time0
    , @time3
    , @time7
    --, @timestamp
    , @tinyint
    , @uniqueidentifier
    , @varbinary
    , @varchar
    , @varcharmax
    , @xml
    )

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure updates data of s13.datatypes
-- =============================================

CREATE PROCEDURE [s13].[usp_odbc_datatypes_update]
    @id int
    , @bigint bigint = NULL
    , @binary binary(8) = NULL
    , @binary16 binary(16) = NULL
    , @bit bit = NULL
    , @char char(10) = NULL
    , @char36 char(36) = NULL
    , @date date = NULL
    , @datetime datetime = NULL
    , @datetime20 datetime2(0) = NULL
    , @datetime23 datetime2(3) = NULL
    , @datetime27 datetime2(7) = NULL
    , @datetimeoffset0 datetimeoffset(0) = NULL
    , @datetimeoffset3 datetimeoffset(3) = NULL
    , @datetimeoffset7 datetimeoffset(7) = NULL
    , @decimal decimal(18,0) = NULL
    , @decimal92 decimal(9,2) = NULL
    , @decimal150 decimal(15,0) = NULL
    , @decimal152 decimal(15,2) = NULL
    , @decimal192 decimal(19,2) = NULL
    , @decimal282 decimal(28,2) = NULL
    , @decimal382 decimal(38,2) = NULL
    , @float float = NULL
    , @geography geography = NULL
    , @geometry geometry = NULL
    , @hierarchyid hierarchyid = NULL
    , @image image = NULL
    , @int int = NULL
    , @money money = NULL
    , @nchar nchar(10) = NULL
    , @ntext ntext = NULL
    , @numeric numeric(18,0) = NULL
    , @numeric92 numeric(9,2) = NULL
    , @numeric150 numeric(15,0) = NULL
    , @numeric152 numeric(15,2) = NULL
    , @numeric192 numeric(19,2) = NULL
    , @numeric282 numeric(28,2) = NULL
    , @numeric382 numeric(38,2) = NULL
    , @nvarchar nvarchar(255) = NULL
    , @nvarcharmax nvarchar(max) = NULL
    , @real real = NULL
    , @smalldatetime smalldatetime = NULL
    , @smallint smallint = NULL
    , @smallmoney smallmoney = NULL
    , @sql_variant sql_variant = NULL
    , @sysname sysname = NULL
    , @text text = NULL
    , @time0 time(0) = NULL
    , @time3 time(3) = NULL
    , @time7 time(7) = NULL
    , @timestamp timestamp = NULL
    , @tinyint tinyint = NULL
    , @uniqueidentifier uniqueidentifier = NULL
    , @varbinary varbinary(1024) = NULL
    , @varchar varchar(255) = NULL
    , @varcharmax varchar(max) = NULL
    , @xml xml = NULL
AS
BEGIN

UPDATE s13.datatypes
SET
    [bigint] = @bigint
    , [binary] = @binary
    , [binary16] = @binary16
    , [bit] = @bit
    , [char] = @char
    , [char36] = @char36
    , [date] = @date
    , [datetime] = @datetime
    , [datetime20] = @datetime20
    , [datetime23] = @datetime23
    , [datetime27] = @datetime27
    , [datetimeoffset0] = @datetimeoffset0
    , [datetimeoffset3] = @datetimeoffset3
    , [datetimeoffset7] = @datetimeoffset7
    , [decimal] = @decimal
    , [decimal92] = @decimal92
    , [decimal150] = @decimal150
    , [decimal152] = @decimal152
    , [decimal192] = @decimal192
    , [decimal282] = @decimal282
    , [decimal382] = @decimal382
    , [float] = @float
    , [geography] = @geography
    , [geometry] = @geometry
    , [hierarchyid] = @hierarchyid
    , [image] = @image
    , [int] = @int
    , [money] = @money
    , [nchar] = @nchar
    , [ntext] = @ntext
    , [numeric] = @numeric
    , [numeric92] = @numeric92
    , [numeric150] = @numeric150
    , [numeric152] = @numeric152
    , [numeric192] = @numeric192
    , [numeric282] = @numeric282
    , [numeric382] = @numeric382
    , [nvarchar] = @nvarchar
    , [nvarcharmax] = @nvarcharmax
    , [real] = @real
    , [smalldatetime] = @smalldatetime
    , [smallint] = @smallint
    , [smallmoney] = @smallmoney
    , [sql_variant] = @sql_variant
    , [sysname] = @sysname
    , [text] = @text
    , [time0] = @time0
    , [time3] = @time3
    , [time7] = @time7
    --, [timestamp] = @timestamp
    , [tinyint] = @tinyint
    , [uniqueidentifier] = @uniqueidentifier
    , [varbinary] = @varbinary
    , [varchar] = @varchar
    , [varcharmax] = @varcharmax
    , [xml] = @xml
WHERE
    id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure selects data for parameter tests
-- =============================================

CREATE PROCEDURE [s13].[usp_parameters_test]
    @bigint bigint = NULL
    , @binary binary(8) = NULL
    , @binary16 binary(16) = NULL
    , @bit bit = NULL
    , @char char(10) = NULL
    , @char36 char(36) = NULL
    , @date date = NULL
    , @datetime datetime = NULL
    , @datetime20 datetime2(0) = NULL
    , @datetime23 datetime2(3) = NULL
    , @datetime27 datetime2(7) = NULL
    , @datetimeoffset0 datetimeoffset(0) = NULL
    , @datetimeoffset3 datetimeoffset(3) = NULL
    , @datetimeoffset7 datetimeoffset(7) = NULL
    , @decimal decimal(18,0) = NULL
    , @decimal92 decimal(9,2) = NULL
    , @decimal150 decimal(15,0) = NULL
    , @decimal152 decimal(15,2) = NULL
    , @decimal192 decimal(19,2) = NULL
    , @decimal282 decimal(28,2) = NULL
    , @decimal382 decimal(38,2) = NULL
    , @float float = NULL
    , @geography geography = NULL
    , @geometry geometry = NULL
    , @hierarchyid hierarchyid = NULL
    , @image image = NULL
    , @int int = NULL
    , @money money = NULL
    , @nchar nchar(10) = NULL
    , @ntext ntext = NULL
    , @numeric numeric(18,0) = NULL
    , @numeric92 numeric(9,2) = NULL
    , @numeric150 numeric(15,0) = NULL
    , @numeric152 numeric(15,2) = NULL
    , @numeric192 numeric(19,2) = NULL
    , @numeric282 numeric(28,2) = NULL
    , @numeric382 numeric(38,2) = NULL
    , @nvarchar nvarchar(255) = NULL
    , @nvarcharmax nvarchar(max) = NULL
    , @real real = NULL
    , @smalldatetime smalldatetime = NULL
    , @smallint smallint = NULL
    , @smallmoney smallmoney = NULL
    , @sql_variant sql_variant = NULL
    , @sysname sysname = NULL
    , @text text = NULL
    , @time0 time(0) = NULL
    , @time3 time(3) = NULL
    , @time7 time(7) = NULL
    , @timestamp timestamp = NULL
    , @tinyint tinyint = NULL
    , @uniqueidentifier uniqueidentifier = NULL
    , @varbinary varbinary(1024) = NULL
    , @varchar varchar(255) = NULL
    , @varcharmax varchar(max) = NULL
    , @xml xml = NULL
AS
BEGIN

SET NOCOUNT ON

SELECT
    t.id
    , t.[bigint]
    , CAST(CONVERT(varchar(max), t.[binary], 1) AS text) AS [binary]
    , CAST(CONVERT(varchar(max), t.[binary16], 1) AS text) AS [binary16]
    , CAST(t.[bit] AS tinyint) AS [bit]
    , t.[char]
    , t.[char36]
    , CAST(t.[date] AS datetime) AS [date]
    , CONVERT(varchar(50), t.datetime, 121) AS datetime
    , CAST(t.datetime20 AS datetime) AS datetime20
    , CONVERT(varchar(50), t.datetime23, 121) AS datetime23
    , CONVERT(varchar(50), t.datetime27, 121) AS datetime27
    , CONVERT(varchar(50), t.datetimeoffset0, 121) AS datetimeoffset0
    , CONVERT(varchar(50), t.datetimeoffset3, 121) AS datetimeoffset3
    , CONVERT(varchar(50), t.datetimeoffset7, 121) AS datetimeoffset7
    , CAST(t.[decimal] AS varchar) AS [decimal]
    , t.[decimal92]
    , t.[decimal150]
    , t.[decimal152]
    , CAST(t.[decimal192] AS varchar(50)) [decimal192]
    , CAST(t.[decimal282] AS varchar(50)) [decimal282]
    , CAST(t.[decimal382] AS varchar(50)) [decimal382]
    , t.[float]
    , CAST(t.[geography].STAsText() AS text) AS [geography]
    , CAST(t.[geometry].STAsText() AS text) AS [geometry]
    , CAST(t.[hierarchyid] AS varchar(892)) AS [hierarchyid]
    , CAST(CONVERT(varchar(max), CAST(t.[image] AS varbinary), 1) AS text) AS [image]
    , t.[int]
    , t.[money]
    , t.[nchar]
    , t.[ntext]
    , CAST(t.[numeric] AS varchar(50)) [numeric]
    , t.[numeric92]
    , t.[numeric150]
    , t.[numeric152]
    , CAST(t.[numeric192] AS varchar(50)) AS [numeric192]
    , CAST(t.[numeric282] AS varchar(50)) AS [numeric282]
    , CAST(t.[numeric382] AS varchar(50)) AS [numeric382]
    , t.[nvarchar]
    , CAST(t.[nvarcharmax] AS ntext) AS [nvarcharmax]
    , t.[real]
    , t.[smalldatetime]
    , t.[smallint]
    , t.[smallmoney]
    , t.[sql_variant]
    , t.[sysname]
    , t.[text]
    , CONVERT(varchar(50), t.time0, 121) AS time0
    , CONVERT(varchar(50), t.time3, 121) AS time3
    , CONVERT(varchar(50), t.time7, 121) AS time7
    , CONVERT(char(18), CONVERT(binary(8), t.[timestamp], 1), 1) AS [timestamp]
    , t.[tinyint]
    , CAST(t.[uniqueidentifier] AS char(36)) AS [uniqueidentifier]
    , CAST(CONVERT(varchar(max), t.[varbinary],1) AS text) AS [varbinary]
    , t.[varchar]
    , CAST(t.[varcharmax] AS text) AS [varcharmax]
    , CAST(CAST(t.[xml] AS nvarchar(max)) AS ntext) AS [xml]
FROM
    s13.datatypes t
WHERE
    (@bigint IS NULL OR t.bigint = @bigint)
    AND (@binary IS NULL OR t.binary = @binary)
    AND (@binary16 IS NULL OR t.binary16 = @binary16)
    AND (@bit IS NULL OR t.bit = @bit)
    AND (@char IS NULL OR t.char = @char)
    AND (@char36 IS NULL OR t.char36 = @char36)
    AND (@date IS NULL OR t.date = @date)
    AND (@datetime IS NULL OR t.datetime = @datetime)
    AND (@datetime20 IS NULL OR t.datetime20 = @datetime20)
    AND (@datetime23 IS NULL OR t.datetime23 = @datetime23)
    AND (@datetime27 IS NULL OR t.datetime27 = @datetime27)
    AND (@datetimeoffset0 IS NULL OR t.datetimeoffset0 = @datetimeoffset0)
    AND (@datetimeoffset3 IS NULL OR t.datetimeoffset3 = @datetimeoffset3)
    AND (@datetimeoffset7 IS NULL OR t.datetimeoffset7 = @datetimeoffset7)
    AND (@decimal IS NULL OR t.decimal = @decimal)
    AND (@decimal92 IS NULL OR t.decimal92 = @decimal92)
    AND (@decimal150 IS NULL OR t.decimal150 = @decimal150)
    AND (@decimal152 IS NULL OR t.decimal152 = @decimal152)
    AND (@decimal192 IS NULL OR t.decimal192 = @decimal192)
    AND (@decimal282 IS NULL OR t.decimal282 = @decimal282)
    AND (@decimal382 IS NULL OR t.decimal382 = @decimal382)
    AND (@float IS NULL OR t.float = @float)
    AND (@geography IS NULL OR t.[geography].STAsText() = @geography.STAsText())
    AND (@geometry IS NULL OR t.[geometry].STAsText() = @geometry.STAsText())
    AND (@hierarchyid IS NULL OR t.hierarchyid = @hierarchyid)
    AND (@image IS NULL OR CAST(t.image AS varbinary(max)) = CAST(@image AS varbinary(max)))
    AND (@int IS NULL OR t.int = @int)
    AND (@money IS NULL OR t.money = @money)
    AND (@nchar IS NULL OR t.nchar = @nchar)
    AND (@ntext IS NULL OR CAST(t.ntext AS nvarchar(max)) = CAST(@ntext AS nvarchar(max)))
    AND (@numeric IS NULL OR t.numeric = @numeric)
    AND (@numeric92 IS NULL OR t.numeric92 = @numeric92)
    AND (@numeric150 IS NULL OR t.numeric150 = @numeric150)
    AND (@numeric152 IS NULL OR t.numeric152 = @numeric152)
    AND (@numeric192 IS NULL OR t.numeric192 = @numeric192)
    AND (@numeric282 IS NULL OR t.numeric282 = @numeric282)
    AND (@numeric382 IS NULL OR t.numeric382 = @numeric382)
    AND (@nvarchar IS NULL OR t.nvarchar = @nvarchar)
    AND (@nvarcharmax IS NULL OR t.nvarcharmax = @nvarcharmax)
    AND (@real IS NULL OR t.real = @real)
    AND (@smalldatetime IS NULL OR t.smalldatetime = @smalldatetime)
    AND (@smallint IS NULL OR t.smallint = @smallint)
    AND (@smallmoney IS NULL OR t.smallmoney = @smallmoney)
    AND (@sql_variant IS NULL OR t.sql_variant = @sql_variant)
    AND (@sysname IS NULL OR t.sysname = @sysname)
    AND (@text IS NULL OR CAST(t.text AS varchar(max)) = CAST(@text AS varchar(max)))
    AND (@time0 IS NULL OR t.time0 = @time0)
    AND (@time3 IS NULL OR t.time3 = @time3)
    AND (@time7 IS NULL OR t.time7 = @time7)
    AND (@timestamp IS NULL OR t.timestamp = @timestamp)
    AND (@tinyint IS NULL OR t.tinyint = @tinyint)
    AND (@uniqueidentifier IS NULL OR t.uniqueidentifier = @uniqueidentifier)
    AND (@varbinary IS NULL OR t.varbinary = @varbinary)
    AND (@varchar IS NULL OR t.varchar = @varchar)
    AND (@varcharmax IS NULL OR t.varcharmax = @varcharmax)
    AND (@xml IS NULL OR CAST(t.xml AS nvarchar(max)) = CAST(@xml AS nvarchar(max)))

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure selects data from s13.quotes
-- =============================================

CREATE PROCEDURE [s13].[usp_quotes]
AS
BEGIN

SET NOCOUNT ON

SELECT
      t.[']
    , t.['']
    , t.[,]
    , t.[-]
    , t.[@]
    , t.[@@]
    , t.[`]
    , t.[``]
    , t.["]
    , t.[""]
    , t.[]]]
    , t.[[]
    , t.[[]]]
    , t.[+]
    , t.[*]
    , t.[%]
    , t.[%%]
    , t.[=]
    , t.[;]
    , t.[:]
    , t.[<>]
    , t.[&]
    , t.[.]
    , t.[..]
FROM
    [s13].[quotes] t

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure deleted data from s13.quotes
-- =============================================

CREATE PROCEDURE [s13].[usp_quotes_delete]
    @_x0027_ nvarchar(50)
    , @_x0027__x0027_ nvarchar(50)
    , @_x002C_ nvarchar(50)
    , @_x002D_ nvarchar(50)
    , @_x0040_ nvarchar(50)
    , @_x0040__x0040_ nvarchar(50)
AS
BEGIN

DELETE FROM [s13].[quotes]
WHERE
    ['] = @_x0027_
    AND [''] = @_x0027__x0027_
    AND [,] = @_x002C_
    AND [-] = @_x002D_
    AND [@] = @_x0040_
    AND [@@] = @_x0040__x0040_

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure inserts data into s13.quotes
-- =============================================

CREATE PROCEDURE [s13].[usp_quotes_insert]
    @_x0027_ nvarchar(50)
    , @_x0027__x0027_ nvarchar(50)
    , @_x002C_ nvarchar(50)
    , @_x002D_ nvarchar(50)
    , @_x0040_ nvarchar(50)
    , @_x0040__x0040_ nvarchar(50)
    , @_x0060_ nvarchar(50) = NULL
    , @_x0060__x0060_ nvarchar(50) = NULL
    , @_x0022_ nvarchar(50) = NULL
    , @_x0022__x0022_ nvarchar(50) = NULL
    , @_x005D_ nvarchar(50) = NULL
    , @_x005B_ nvarchar(50) = NULL
    , @_x005B__x005D_ nvarchar(50) = NULL
    , @_x002B_ nvarchar(50) = NULL
    , @_x002A_ nvarchar(50) = NULL
    , @_x0025_ nvarchar(50) = NULL
    , @_x0025__x0025_ nvarchar(50) = NULL
    , @_x003D_ nvarchar(50) = NULL
    , @_x003B_ nvarchar(50) = NULL
    , @_x003A_ nvarchar(50) = NULL
    , @_x003C__x003E_ nvarchar(50) = NULL
    , @_x0026_ nvarchar(50) = NULL
    , @_x002E_ nvarchar(50) = NULL
    , @_x002E__x002E_ nvarchar(50) = NULL
AS
BEGIN

INSERT INTO [s13].[quotes]
    ( [']
    , ['']
    , [,]
    , [-]
    , [@]
    , [@@]
    , [`]
    , [``]
    , ["]
    , [""]
    , []]]
    , [[]
    , [[]]]
    , [+]
    , [*]
    , [%]
    , [%%]
    , [=]
    , [;]
    , [:]
    , [<>]
    , [&]
    , [.]
    , [..]
    )
VALUES
    ( @_x0027_
    , @_x0027__x0027_
    , @_x002C_
    , @_x002D_
    , @_x0040_
    , @_x0040__x0040_
    , @_x0060_
    , @_x0060__x0060_
    , @_x0022_
    , @_x0022__x0022_
    , @_x005D_
    , @_x005B_
    , @_x005B__x005D_
    , @_x002B_
    , @_x002A_
    , @_x0025_
    , @_x0025__x0025_
    , @_x003D_
    , @_x003B_
    , @_x003A_
    , @_x003C__x003E_
    , @_x0026_
    , @_x002E_
    , @_x002E__x002E_
    )

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure updates data of s13.quotes
-- =============================================

CREATE PROCEDURE [s13].[usp_quotes_update]
    @_x0027_ nvarchar(50)
    , @_x0027__x0027_ nvarchar(50)
    , @_x002C_ nvarchar(50)
    , @_x002D_ nvarchar(50)
    , @_x0040_ nvarchar(50)
    , @_x0040__x0040_ nvarchar(50)
    , @_x0060_ nvarchar(50) = NULL
    , @_x0060__x0060_ nvarchar(50) = NULL
    , @_x0022_ nvarchar(50) = NULL
    , @_x0022__x0022_ nvarchar(50) = NULL
    , @_x005D_ nvarchar(50) = NULL
    , @_x005B_ nvarchar(50) = NULL
    , @_x005B__x005D_ nvarchar(50) = NULL
    , @_x002B_ nvarchar(50) = NULL
    , @_x002A_ nvarchar(50) = NULL
    , @_x0025_ nvarchar(50) = NULL
    , @_x0025__x0025_ nvarchar(50) = NULL
    , @_x003D_ nvarchar(50) = NULL
    , @_x003B_ nvarchar(50) = NULL
    , @_x003A_ nvarchar(50) = NULL
    , @_x003C__x003E_ nvarchar(50) = NULL
    , @_x0026_ nvarchar(50) = NULL
    , @_x002E_ nvarchar(50) = NULL
    , @_x002E__x002E_ nvarchar(50) = NULL
AS
BEGIN

UPDATE [s13].[quotes]
SET
    [`] = @_x0060_
    , [``] = @_x0060__x0060_
    , ["] = @_x0022_
    , [""] = @_x0022__x0022_
    , []]] = @_x005D_
    , [[] = @_x005B_
    , [[]]] = @_x005B__x005D_
    , [+] = @_x002B_
    , [*] = @_x002A_
    , [%] = @_x0025_
    , [%%] = @_x0025__x0025_
    , [=] = @_x003D_
    , [;] = @_x003B_
    , [:] = @_x003A_
    , [<>] = @_x003C__x003E_
    , [&] = @_x0026_
    , [.] = @_x002E_
    , [..] = @_x002E__x002E_
WHERE
    ['] = @_x0027_
    AND [''] = @_x0027__x0027_
    AND [,] = @_x002C_
    AND [-] = @_x002D_
    AND [@] = @_x0040_
    AND [@@] = @_x0040__x0040_

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure selects test data
-- =============================================

CREATE PROCEDURE [s13].[usp_select_test_editable_rows]
    @limit int = NULL
AS
BEGIN

SET NOCOUNT ON

IF @limit IS NULL SET @limit = 10

;WITH e1(n) AS
(
    SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL
    SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
),                                              -- 10
e2(n) AS (SELECT 1 FROM e1 CROSS JOIN e1 AS b), -- 10*10
e3(n) AS (SELECT 1 FROM e1 CROSS JOIN e2 AS c), -- 10*100
e4(n) AS (SELECT 1 FROM e1 CROSS JOIN e3 AS d), -- 10*1000
e5(n) AS (SELECT 1 FROM e1 CROSS JOIN e4 AS e)  -- 10*10000

SELECT
    n.row_index
    , r.*
FROM
    INFORMATION_SCHEMA.ROUTINES r
    CROSS JOIN
    (SELECT row_index = ROW_NUMBER() OVER (ORDER BY n) FROM e5) n
WHERE
    r.SPECIFIC_SCHEMA = 's13' AND r.SPECIFIC_NAME = 'usp_select_test_editable_rows'
    AND n.row_index BETWEEN 1 AND @limit
ORDER BY
    n.row_index

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure emulates a delete procedure for test data
-- =============================================

CREATE PROCEDURE [s13].[usp_select_test_editable_rows_delete]
    @row_index int
AS
BEGIN

SET NOCOUNT ON

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure emulates an insert procedure for test data
-- =============================================

CREATE PROCEDURE [s13].[usp_select_test_editable_rows_insert]
    @SPECIFIC_CATALOG nvarchar(128) = NULL
    , @SPECIFIC_SCHEMA nvarchar(128) = NULL
    , @SPECIFIC_NAME nvarchar(255) = NULL
    , @ROUTINE_CATALOG nvarchar(128) = NULL
    , @ROUTINE_SCHEMA nvarchar(128) = NULL
    , @ROUTINE_NAME nvarchar(255) = NULL
    , @ROUTINE_TYPE nvarchar(20) = NULL
    , @MODULE_CATALOG nvarchar(255) = NULL
    , @MODULE_SCHEMA nvarchar(255) = NULL
    , @MODULE_NAME nvarchar(255) = NULL
    , @UDT_CATALOG nvarchar(255) = NULL
    , @UDT_SCHEMA nvarchar(255) = NULL
    , @UDT_NAME nvarchar(255) = NULL
    , @DATA_TYPE nvarchar(255) = NULL
    , @CHARACTER_MAXIMUM_LENGTH int = NULL
    , @CHARACTER_OCTET_LENGTH int = NULL
    , @COLLATION_CATALOG nvarchar(255) = NULL
    , @COLLATION_SCHEMA nvarchar(255) = NULL
    , @COLLATION_NAME nvarchar(20) = NULL
    , @CHARACTER_SET_CATALOG nvarchar(255) = NULL
    , @CHARACTER_SET_SCHEMA nvarchar(255) = NULL
    , @CHARACTER_SET_NAME nvarchar(255) = NULL
    , @NUMERIC_PRECISION tinyint = NULL
    , @NUMERIC_PRECISION_RADIX smallint = NULL
    , @NUMERIC_SCALE int = NULL
    , @DATETIME_PRECISION smallint = NULL
    , @INTERVAL_TYPE nvarchar(30) = NULL
    , @INTERVAL_PRECISION smallint = NULL
    , @TYPE_UDT_CATALOG nvarchar(255) = NULL
    , @TYPE_UDT_SCHEMA nvarchar(255) = NULL
    , @TYPE_UDT_NAME nvarchar(255) = NULL
    , @SCOPE_CATALOG nvarchar(255) = NULL
    , @SCOPE_SCHEMA nvarchar(255) = NULL
    , @SCOPE_NAME nvarchar(255) = NULL
    , @MAXIMUM_CARDINALITY bigint = NULL
    , @DTD_IDENTIFIER nvarchar(255) = NULL
    , @ROUTINE_BODY nvarchar(30) = NULL
    , @ROUTINE_DEFINITION nvarchar(4000) = NULL
    , @EXTERNAL_NAME nvarchar(255) = NULL
    , @EXTERNAL_LANGUAGE nvarchar(30) = NULL
    , @PARAMETER_STYLE nvarchar(30) = NULL
    , @IS_DETERMINISTIC nvarchar(10) = NULL
    , @SQL_DATA_ACCESS nvarchar(30) = NULL
    , @IS_NULL_CALL nvarchar(10) = NULL
    , @SQL_PATH nvarchar(255) = NULL
    , @SCHEMA_LEVEL_ROUTINE nvarchar(10) = NULL
    , @MAX_DYNAMIC_RESULT_SETS smallint = NULL
    , @IS_USER_DEFINED_CAST nvarchar(10) = NULL
    , @IS_IMPLICITLY_INVOCABLE nvarchar(10) = NULL
    , @CREATED datetime = NULL
    , @LAST_ALTERED datetime = NULL
AS
BEGIN

SET NOCOUNT ON

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure emulates an update procedure for test data
-- =============================================

CREATE PROCEDURE [s13].[usp_select_test_editable_rows_update]
    @row_index int
    , @SPECIFIC_CATALOG nvarchar(128) = NULL
    , @SPECIFIC_SCHEMA nvarchar(128) = NULL
    , @SPECIFIC_NAME nvarchar(255) = NULL
    , @ROUTINE_CATALOG nvarchar(128) = NULL
    , @ROUTINE_SCHEMA nvarchar(128) = NULL
    , @ROUTINE_NAME nvarchar(255) = NULL
    , @ROUTINE_TYPE nvarchar(20) = NULL
    , @MODULE_CATALOG nvarchar(255) = NULL
    , @MODULE_SCHEMA nvarchar(255) = NULL
    , @MODULE_NAME nvarchar(255) = NULL
    , @UDT_CATALOG nvarchar(255) = NULL
    , @UDT_SCHEMA nvarchar(255) = NULL
    , @UDT_NAME nvarchar(255) = NULL
    , @DATA_TYPE nvarchar(255) = NULL
    , @CHARACTER_MAXIMUM_LENGTH int = NULL
    , @CHARACTER_OCTET_LENGTH int = NULL
    , @COLLATION_CATALOG nvarchar(255) = NULL
    , @COLLATION_SCHEMA nvarchar(255) = NULL
    , @COLLATION_NAME nvarchar(20) = NULL
    , @CHARACTER_SET_CATALOG nvarchar(255) = NULL
    , @CHARACTER_SET_SCHEMA nvarchar(255) = NULL
    , @CHARACTER_SET_NAME nvarchar(255) = NULL
    , @NUMERIC_PRECISION tinyint = NULL
    , @NUMERIC_PRECISION_RADIX smallint = NULL
    , @NUMERIC_SCALE int = NULL
    , @DATETIME_PRECISION smallint = NULL
    , @INTERVAL_TYPE nvarchar(30) = NULL
    , @INTERVAL_PRECISION smallint = NULL
    , @TYPE_UDT_CATALOG nvarchar(255) = NULL
    , @TYPE_UDT_SCHEMA nvarchar(255) = NULL
    , @TYPE_UDT_NAME nvarchar(255) = NULL
    , @SCOPE_CATALOG nvarchar(255) = NULL
    , @SCOPE_SCHEMA nvarchar(255) = NULL
    , @SCOPE_NAME nvarchar(255) = NULL
    , @MAXIMUM_CARDINALITY bigint = NULL
    , @DTD_IDENTIFIER nvarchar(255) = NULL
    , @ROUTINE_BODY nvarchar(30) = NULL
    , @ROUTINE_DEFINITION nvarchar(4000) = NULL
    , @EXTERNAL_NAME nvarchar(255) = NULL
    , @EXTERNAL_LANGUAGE nvarchar(30) = NULL
    , @PARAMETER_STYLE nvarchar(30) = NULL
    , @IS_DETERMINISTIC nvarchar(10) = NULL
    , @SQL_DATA_ACCESS nvarchar(30) = NULL
    , @IS_NULL_CALL nvarchar(10) = NULL
    , @SQL_PATH nvarchar(255) = NULL
    , @SCHEMA_LEVEL_ROUTINE nvarchar(10) = NULL
    , @MAX_DYNAMIC_RESULT_SETS smallint = NULL
    , @IS_USER_DEFINED_CAST nvarchar(10) = NULL
    , @IS_IMPLICITLY_INVOCABLE nvarchar(10) = NULL
    , @CREATED datetime = NULL
    , @LAST_ALTERED datetime = NULL
AS
BEGIN

SET NOCOUNT ON

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure selects test data
-- =============================================

CREATE PROCEDURE [s13].[usp_select_test_rows]
    @limit int = NULL
AS
BEGIN

SET NOCOUNT ON

IF @limit IS NULL SET @limit = 10

;WITH e1(n) AS
(
    SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL
    SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
),                                              -- 10
e2(n) AS (SELECT 1 FROM e1 CROSS JOIN e1 AS b), -- 10*10
e3(n) AS (SELECT 1 FROM e1 CROSS JOIN e2 AS c), -- 10*100
e4(n) AS (SELECT 1 FROM e1 CROSS JOIN e3 AS d), -- 10*1000
e5(n) AS (SELECT 1 FROM e1 CROSS JOIN e4 AS e)  -- 10*10000

SELECT
    n.row_index
    , r.*
FROM
    INFORMATION_SCHEMA.ROUTINES r
    CROSS JOIN
    (SELECT row_index = ROW_NUMBER() OVER (ORDER BY n) FROM e5) n
WHERE
    r.SPECIFIC_SCHEMA = 's13' AND r.SPECIFIC_NAME = 'usp_select_test_rows'
    AND n.row_index BETWEEN 1 AND @limit
ORDER BY
    n.row_index

END


GO

SET IDENTITY_INSERT [s13].[datatypes] ON;
INSERT INTO [s13].[datatypes] ([id], [bigint], [binary], [binary16], [bit], [char], [char36], [date], [datetime], [datetime20], [datetime23], [datetime27], [datetimeoffset0], [datetimeoffset3], [datetimeoffset7], [decimal], [decimal92], [decimal150], [decimal152], [decimal192], [decimal282], [decimal382], [float], [geography], [geometry], [hierarchyid], [image], [int], [money], [nchar], [ntext], [numeric], [numeric92], [numeric150], [numeric152], [numeric192], [numeric282], [numeric382], [nvarchar], [nvarcharmax], [real], [smalldatetime], [smallint], [smallmoney], [sql_variant], [sysname], [text], [time0], [time3], [time7], [tinyint], [uniqueidentifier], [varbinary], [varchar], [varcharmax], [xml]) VALUES (1, 123456789012345, 0x0A0B0C0000000000, 0x030201000504070608090A0B0C0D0E0F, 1, N'char', N'00010203-0405-0607-0809-0a0b0c0d0e0f', '20211210', '20211210 15:20:10.123', '20211210 15:20:10', '20211210 15:20:10.123', '20211210 15:20:10.1234567', '20211210 15:20:10 +00:00', '20211210 15:20:10.123 +00:00', '20211210 15:20:10.1234567 +00:00', 123456789012345678, 1234567.12, 123456789012345, 123456789012.12, 12345678901234567.12, 12345678901234567890123456.12, 12345678901234567890123456.12, 1234567890123.45, 'LINESTRING (-122.36 47.656, -122.343 47.656)', 'LINESTRING (100 100, 20 180, 180 180)', '/', 0x0A0B0C, 1234567890, 123456789012.12, N'nchar', N'ntext', 123456789012345678, 1234567.12, 123456789012345, 123456789012.12, 12345678901234567.12, 12345678901234567.12, 12345678901234567890123456.12, N'nvarchar', N'nvarcharmax', 1234567, '20211210 15:20:00', 32767, 214748.36, N'sql_variant', N'sysname', N'text', '15:20:10', '15:20:10.123', '15:20:10.1234567', 255, '00010203-0405-0607-0809-0a0b0c0d0e0f', 0x0A0B0C, N'varchar', N'varchar(max)', N'<root/>');
INSERT INTO [s13].[datatypes] ([id], [bigint], [binary], [binary16], [bit], [char], [char36], [date], [datetime], [datetime20], [datetime23], [datetime27], [datetimeoffset0], [datetimeoffset3], [datetimeoffset7], [decimal], [decimal92], [decimal150], [decimal152], [decimal192], [decimal282], [decimal382], [float], [geography], [geometry], [hierarchyid], [image], [int], [money], [nchar], [ntext], [numeric], [numeric92], [numeric150], [numeric152], [numeric192], [numeric282], [numeric382], [nvarchar], [nvarcharmax], [real], [smalldatetime], [smallint], [smallmoney], [sql_variant], [sysname], [text], [time0], [time3], [time7], [tinyint], [uniqueidentifier], [varbinary], [varchar], [varcharmax], [xml]) VALUES (2, 123456789012345, 0x0A0B0C0000000000, 0x030201000504070608090A0B0C0D0E0F, 1, N'char', N'00010203-0405-0607-0809-0a0b0c0d0e0f', '20211210', '20211210 15:20:10.123', '20211210 15:20:10', '20211210 15:20:10.123', '20211210 15:20:10.1234567', '20211210 15:20:10 +00:00', '20211210 15:20:10.123 +00:00', '20211210 15:20:10.1234567 +00:00', 123456789012345678, 1234567.12, 123456789012345, 123456789012.12, 12345678901234567.12, 12345678901234567890123456.12, 12345678901234567890123456.12, 1234567890123.45, 'LINESTRING (-122.36 47.656, -122.343 47.656)', 'LINESTRING (100 100, 20 180, 180 180)', '/', 0x0A0B0C, 1234567890, 123456789012.12, N'nchar', N'ntext', 123456789012345678, 1234567.12, 123456789012345, 123456789012.12, 12345678901234567.12, 12345678901234567.12, 12345678901234567890123456.12, N'nvarchar', N'nvarcharmax', 1234567, '20211210 15:20:00', 32767, 214748.36, N'sql_variant', N'sysname', N'text', '15:20:10', '15:20:10.123', '15:20:10.1234567', 255, '00010203-0405-0607-0809-0a0b0c0d0e0f', 0x0A0B0C, N'varchar', N'varchar(max)', N'<root/>');
INSERT INTO [s13].[datatypes] ([id], [bigint], [binary], [binary16], [bit], [char], [char36], [date], [datetime], [datetime20], [datetime23], [datetime27], [datetimeoffset0], [datetimeoffset3], [datetimeoffset7], [decimal], [decimal92], [decimal150], [decimal152], [decimal192], [decimal282], [decimal382], [float], [geography], [geometry], [hierarchyid], [image], [int], [money], [nchar], [ntext], [numeric], [numeric92], [numeric150], [numeric152], [numeric192], [numeric282], [numeric382], [nvarchar], [nvarcharmax], [real], [smalldatetime], [smallint], [smallmoney], [sql_variant], [sysname], [text], [time0], [time3], [time7], [tinyint], [uniqueidentifier], [varbinary], [varchar], [varcharmax], [xml]) VALUES (3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
SET IDENTITY_INSERT [s13].[datatypes] OFF;
GO

INSERT INTO [s13].[quotes] (['], [''], [,], [-], [@], [@@], [`], [``], [""], []]], [[], [[]]], [+], [*], [%], [%%], [=], [;], [:], [<>], [&], [.], [..]) VALUES (N'''', N'''''', N',', N'-', N'@', N'@@', N'`', N'``', N'""', N']', N'[', N'[]', N'+', N'*', N'%', N'%%', N'=', N';', N':', N'<>', N'&', N'.', N'..');
INSERT INTO [s13].[quotes] (['], [''], [,], [-], [@], [@@], [`], [``], [""], []]], [[], [[]]], [+], [*], [%], [%%], [=], [;], [:], [<>], [&], [.], [..]) VALUES (N'1', N'2', N'3', N'4', N'5', N'6', N'`', N'``', N'""', N']', N'[', N'[]', N'+', N'*', N'%', N'%%', N'=', N';', N':', N'<>', N'&', N'.', N'..');
GO

print 'Application installed';
