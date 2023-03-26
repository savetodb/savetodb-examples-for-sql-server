-- =============================================
-- Application: Sample 20 - Cube App
-- Version 10.8, January 9, 2023
--
-- Copyright 2020-2023 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON
GO

CREATE SCHEMA s20;
GO

CREATE TABLE s20.accounts (
    id int IDENTITY(1,1) NOT NULL
    , code nvarchar(50) NOT NULL
    , name nvarchar(255) NOT NULL
    , CONSTRAINT PK_accounts PRIMARY KEY (id)
    , CONSTRAINT IX_accounts_code UNIQUE (code)
    , CONSTRAINT IX_accounts_name UNIQUE (name)
);
GO

CREATE TABLE s20.categories (
    id int IDENTITY(1,1) NOT NULL
    , code nvarchar(50) NOT NULL
    , name nvarchar(255) NOT NULL
    , CONSTRAINT PK_categories PRIMARY KEY (id)
    , CONSTRAINT IX_categories_code UNIQUE (code)
    , CONSTRAINT IX_categories_name UNIQUE (name)
);
GO

CREATE TABLE s20.entities (
    id int IDENTITY(1,1) NOT NULL
    , code nvarchar(50) NOT NULL
    , name nvarchar(255) NOT NULL
    , CONSTRAINT PK_entities PRIMARY KEY (id)
    , CONSTRAINT IX_entities_code UNIQUE (code)
    , CONSTRAINT IX_entities_name UNIQUE (name)
);
GO

CREATE TABLE s20.permissions (
    id tinyint NOT NULL
    , code nvarchar(50) NOT NULL
    , name nvarchar(255) NOT NULL
    , CONSTRAINT PK_permissions PRIMARY KEY (id)
    , CONSTRAINT IX_permissions_code UNIQUE (code)
    , CONSTRAINT IX_permissions_name UNIQUE (name)
);
GO

CREATE TABLE s20.times (
    id int IDENTITY(1,1) NOT NULL
    , code nvarchar(50) NOT NULL
    , name nvarchar(255) NOT NULL
    , year int NOT NULL
    , column_name nvarchar(50) NOT NULL
    , CONSTRAINT PK_times PRIMARY KEY (id)
    , CONSTRAINT IX_times_code UNIQUE (code)
    , CONSTRAINT IX_times_name UNIQUE (name)
    , CONSTRAINT IX_times_year_column_name UNIQUE (year, column_name)
);
GO

CREATE TABLE s20.users (
    id int IDENTITY(1,1) NOT NULL
    , username nvarchar(255) NOT NULL
    , CONSTRAINT PK_users PRIMARY KEY (id)
    , CONSTRAINT IX_users_username UNIQUE (username)
);
GO

CREATE TABLE s20.category_times (
    category_id int NOT NULL
    , time_id int NOT NULL
    , permission tinyint NOT NULL CONSTRAINT DF_category_times_permission DEFAULT((0))
    , CONSTRAINT PK_category_times PRIMARY KEY (category_id, time_id)
);
GO

ALTER TABLE s20.category_times ADD CONSTRAINT FK_category_times_categories FOREIGN KEY (category_id) REFERENCES s20.categories (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

ALTER TABLE s20.category_times ADD CONSTRAINT FK_category_times_permissions FOREIGN KEY (permission) REFERENCES s20.permissions (id) ON UPDATE CASCADE;
GO

ALTER TABLE s20.category_times ADD CONSTRAINT FK_category_times_times FOREIGN KEY (time_id) REFERENCES s20.times (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

CREATE TABLE s20.category_users (
    category_id int NOT NULL
    , user_id int NOT NULL
    , permission tinyint NOT NULL CONSTRAINT DF_category_permission DEFAULT((0))
    , CONSTRAINT PK_category_users PRIMARY KEY (category_id, user_id)
);
GO

ALTER TABLE s20.category_users ADD CONSTRAINT FK_category_users_categories FOREIGN KEY (category_id) REFERENCES s20.categories (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

ALTER TABLE s20.category_users ADD CONSTRAINT FK_category_users_permissions FOREIGN KEY (permission) REFERENCES s20.permissions (id) ON UPDATE CASCADE;
GO

ALTER TABLE s20.category_users ADD CONSTRAINT FK_category_users_users FOREIGN KEY (user_id) REFERENCES s20.users (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

CREATE TABLE s20.entity_users (
    entity_id int NOT NULL
    , user_id int NOT NULL
    , permission tinyint NOT NULL CONSTRAINT DF_entity_users_permission DEFAULT((0))
    , CONSTRAINT PK_entity_users PRIMARY KEY (entity_id, user_id)
);
GO

ALTER TABLE s20.entity_users ADD CONSTRAINT FK_entity_users_entities FOREIGN KEY (entity_id) REFERENCES s20.entities (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

ALTER TABLE s20.entity_users ADD CONSTRAINT FK_entity_users_permissions FOREIGN KEY (permission) REFERENCES s20.permissions (id) ON UPDATE CASCADE;
GO

ALTER TABLE s20.entity_users ADD CONSTRAINT FK_entity_users_users FOREIGN KEY (user_id) REFERENCES s20.users (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

CREATE TABLE s20.facts (
    id int IDENTITY(1,1) NOT NULL
    , account_id int NOT NULL
    , entity_id int NOT NULL
    , category_id int NOT NULL
    , time_id int NOT NULL
    , value money NULL
    , CONSTRAINT PK_facts PRIMARY KEY (id)
    , CONSTRAINT IX_facts UNIQUE (account_id, category_id, entity_id, time_id)
);
GO

ALTER TABLE s20.facts ADD CONSTRAINT FK_facts_accounts FOREIGN KEY (account_id) REFERENCES s20.accounts (id) ON UPDATE CASCADE;
GO

ALTER TABLE s20.facts ADD CONSTRAINT FK_facts_categories FOREIGN KEY (category_id) REFERENCES s20.categories (id) ON UPDATE CASCADE;
GO

ALTER TABLE s20.facts ADD CONSTRAINT FK_facts_entities FOREIGN KEY (entity_id) REFERENCES s20.entities (id) ON UPDATE CASCADE;
GO

ALTER TABLE s20.facts ADD CONSTRAINT FK_facts_times FOREIGN KEY (time_id) REFERENCES s20.times (id) ON UPDATE CASCADE;
GO

CREATE TABLE s20.comments (
    id int NOT NULL
    , fact_id int NOT NULL
    , user_id int NOT NULL
    , time datetime2(0) NOT NULL
    , comment nvarchar(255) NULL
    , CONSTRAINT PK_comments PRIMARY KEY (id)
);
GO

ALTER TABLE s20.comments ADD CONSTRAINT FK_comments_facts FOREIGN KEY (fact_id) REFERENCES s20.facts (id) ON UPDATE CASCADE;
GO

ALTER TABLE s20.comments ADD CONSTRAINT FK_comments_users FOREIGN KEY (user_id) REFERENCES s20.users (id) ON UPDATE CASCADE;
GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view generates application handlers
-- =============================================

CREATE VIEW [s20].[xl_app_handlers]
AS

SELECT
    's20' AS TABLE_SCHEMA
    , 'usp_web_category_times' TABLE_NAME
    , c.name AS COLUMN_NAME
    , 'ValidationList' AS EVENT_NAME
    , 's20' AS HANDLER_SCHEMA
    , 'permissions' AS HANDLER_NAME
    , 'TABLE' AS HANDLER_TYPE
    , 'id, code' HANDLER_CODE
    , CAST(NULL AS nvarchar) AS TARGET_WORKSHEET
    , CAST(NULL AS int) AS MENU_ORDER
    , CAST(NULL AS bit) AS EDIT_PARAMETERS
FROM
    s20.categories c
UNION ALL
SELECT
    's20' AS TABLE_SCHEMA
    , 'usp_web_category_users' TABLE_NAME
    , c.name AS COLUMN_NAME
    , 'ValidationList' AS EVENT_NAME
    , 's20' AS HANDLER_SCHEMA
    , 'permissions' AS HANDLER_NAME
    , 'TABLE' AS HANDLER_TYPE
    , 'id, code' HANDLER_CODE
    , CAST(NULL AS nvarchar) AS TARGET_WORKSHEET
    , CAST(NULL AS int) AS MENU_ORDER
    , CAST(NULL AS bit) AS EDIT_PARAMETERS
FROM
    s20.categories c
UNION ALL
SELECT
    's20' AS TABLE_SCHEMA
    , 'usp_web_entity_users' TABLE_NAME
    , c.name AS COLUMN_NAME
    , 'ValidationList' AS EVENT_NAME
    , 's20' AS HANDLER_SCHEMA
    , 'permissions' AS HANDLER_NAME
    , 'TABLE' AS HANDLER_TYPE
    , 'id, code' HANDLER_CODE
    , CAST(NULL AS nvarchar) AS TARGET_WORKSHEET
    , CAST(NULL AS int) AS MENU_ORDER
    , CAST(NULL AS bit) AS EDIT_PARAMETERS
FROM
    s20.entities c


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view selects value for the @category_id parameter
-- =============================================

CREATE VIEW [s20].[xl_list_category_id]
AS

SELECT
    c.id
    , c.name
FROM
    s20.categories c
    INNER JOIN s20.category_users cp ON cp.category_id = c.id
    INNER JOIN s20.users u ON u.id = cp.user_id AND u.username = USER_NAME()
WHERE
    cp.permission IN (1, 2)


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The view selects value for the @entity_id parameter
-- =============================================

CREATE VIEW [s20].[xl_list_entity_id]
AS

SELECT
    e.id
    , e.name
FROM
    s20.entities e
    INNER JOIN s20.entity_users ep ON ep.entity_id = e.id
    INNER JOIN s20.users u ON u.id = ep.user_id AND u.username = USER_NAME()


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Data entry form
-- =============================================

CREATE PROCEDURE [s20].[usp_form_01]
    @entity_id int = NULL
    , @category_id int = NULL
    , @year int = NULL
AS
BEGIN

SET NOCOUNT ON;

DECLARE @user_id int = (SELECT id FROM s20.users WHERE username = USER_NAME())

IF @year IS NULL SET @year = YEAR(GETDATE())

SELECT
    a.id
    , a.code
    , a.name
    , [01], [02], [03], [04], [05], [06], [07], [08], [09], [10], [11], [12]
FROM
    s20.accounts a
    LEFT OUTER JOIN (
        SELECT
            f.account_id
            , SUBSTRING(t.code, 6, 2) AS code
            , f.value
        FROM
            s20.facts f
            INNER JOIN s20.times t ON t.id = f.time_id AND t.[year] = @year
            INNER JOIN s20.category_times ct ON ct.time_id = f.time_id AND ct.category_id = @category_id
            INNER JOIN s20.category_users cp ON cp.category_id = f.category_id AND cp.user_id = @user_id
            INNER JOIN s20.entity_users ep ON ep.entity_id = f.entity_id AND ep.user_id = @user_id
        WHERE
            f.category_id = @category_id
            AND f.entity_id = @entity_id
            AND ct.permission IN (1, 2)
            AND cp.permission IN (1, 2)
            AND ep.permission IN (1, 2)
    ) s PIVOT (
        MAX(value) FOR code IN ([01], [02], [03], [04], [05], [06], [07], [08], [09], [10], [11], [12])
    ) p ON p.account_id = a.id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure processes changes of usp_form_01
-- =============================================

CREATE PROCEDURE [s20].[usp_form_01_change]
    @id int = NULL
    , @entity_id int = NULL
    , @category_id int = NULL
    , @column_name nvarchar(128) = NULL
    , @cell_number_value money = NULL
    , @year int = NULL
AS
BEGIN

SET NOCOUNT ON;

DECLARE @user_id int = (SELECT id FROM s20.users WHERE username = USER_NAME())

DECLARE @time_id int = (SELECT id FROM s20.times WHERE [year] = @year and column_name = @column_name)

IF @time_id IS NULL
    RETURN

IF @user_id IS NULL
    BEGIN
    RAISERROR('No permission', 16, 1)
    RETURN
    END

IF NOT EXISTS(SELECT permission FROM s20.entity_users WHERE entity_id = @entity_id AND user_id = @user_id AND permission = 2)
    BEGIN
    RAISERROR('No permission', 16, 1)
    RETURN
    END

IF NOT EXISTS(SELECT permission FROM s20.category_users WHERE category_id = @category_id AND user_id = @user_id AND permission = 2)
    BEGIN
    RAISERROR('No permission', 16, 1)
    RETURN
    END

IF NOT EXISTS(SELECT permission FROM s20.category_times WHERE category_id = @category_id AND time_id = @time_id AND permission = 2)
    BEGIN
    DECLARE @category nvarchar(255) = (SELECT name FROM s20.categories WHERE id = @category_id)
    DECLARE @time nvarchar(255) = (SELECT name FROM s20.times WHERE id = @time_id)

    RAISERROR('%s %s closed for changes', 16, 1, @category, @time)
    RETURN
    END

SET NOCOUNT OFF;

MERGE s20.facts t
USING (SELECT @id, @entity_id, @category_id, @time_id, @cell_number_value) s (account_id, entity_id, category_id, time_id, value)
ON (t.account_id = s.account_id AND t.entity_id = s.entity_id AND t.category_id = s.category_id AND t.time_id = s.time_id)
WHEN MATCHED THEN
    UPDATE SET value = s.value
WHEN NOT MATCHED THEN
    INSERT (account_id, entity_id, category_id, time_id, value)
    VALUES (s.account_id, s.entity_id, s.category_id, s.time_id, s.value);

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Webform to edit category-time permissions
-- =============================================

CREATE PROCEDURE [s20].[usp_web_category_times]
AS
BEGIN

SET NOCOUNT ON;

SELECT '{"parameters":[],"rows":' + (

    SELECT t.id AS time_id, t.name FROM s20.times t ORDER BY t.code FOR JSON AUTO

) + ',"columns":' + COALESCE((

    SELECT c.id AS category_id, c.name FROM s20.categories c ORDER BY c.id FOR JSON AUTO

), 'null') + ',"cells":' + COALESCE((

    SELECT ct.category_id, ct.time_id, ct.permission AS value FROM s20.category_times ct FOR JSON AUTO

),'[{"category_id":null,"time_id":null,"value":null}]') + '}' AS data

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure processes changes of usp_web_category_times
-- =============================================

CREATE PROCEDURE [s20].[usp_web_category_times_change]
    @category_id int = NULL
    , @time_id int = NULL
    , @cell_number_value tinyint = NULL
AS
BEGIN

MERGE s20.category_times t
USING (SELECT @category_id, @time_id, @cell_number_value) s (category_id, time_id, permission)
ON (t.category_id = s.category_id AND t.time_id = s.time_id)
WHEN MATCHED AND s.permission IS NULL THEN
    DELETE
WHEN MATCHED AND s.permission IS NOT NULL THEN
    UPDATE SET permission = s.permission
WHEN NOT MATCHED THEN
    INSERT (category_id, time_id, permission)
    VALUES (s.category_id, s.time_id, s.permission);

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Webform to edit category-users permissions
-- =============================================

CREATE PROCEDURE [s20].[usp_web_category_users]
AS
BEGIN

SET NOCOUNT ON;

SELECT '{"parameters":[],"rows":' + (

    SELECT t.id AS user_id, t.username FROM s20.users t ORDER BY t.username FOR JSON AUTO

) + ',"columns":' + COALESCE((

    SELECT c.id AS category_id, c.name FROM s20.categories c ORDER BY c.id FOR JSON AUTO

), 'null') + ',"cells":' + COALESCE((

    SELECT cp.category_id, cp.user_id, cp.permission AS value FROM s20.category_users cp FOR JSON AUTO

),'[{"category_id":null,"user_id":null,"value":null}]') + '}' AS data

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure processes changes of usp_web_category_users
-- =============================================

CREATE PROCEDURE [s20].[usp_web_category_users_change]
    @category_id int = NULL
    , @user_id int = NULL
    , @cell_number_value tinyint = NULL
AS
BEGIN

MERGE s20.category_users t
USING (SELECT @category_id, @user_id, @cell_number_value) s (category_id, user_id, permission)
ON (t.category_id = s.category_id AND t.user_id = s.user_id)
WHEN MATCHED AND s.permission IS NULL THEN
    DELETE
WHEN MATCHED AND s.permission IS NOT NULL THEN
    UPDATE SET permission = s.permission
WHEN NOT MATCHED THEN
    INSERT (category_id, user_id, permission)
    VALUES (s.category_id, s.user_id, s.permission);

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Webform to edit entity-users permissions
-- =============================================

CREATE PROCEDURE [s20].[usp_web_entity_users]
AS
BEGIN

SET NOCOUNT ON;

SELECT '{"parameters":[],"rows":' + (

    SELECT t.id AS user_id, t.username FROM s20.users t ORDER BY t.username FOR JSON AUTO

) + ',"columns":' + COALESCE((

    SELECT c.id AS entity_id, c.name FROM s20.entities c ORDER BY c.id FOR JSON AUTO

), 'null') + ',"cells":' + COALESCE((

    SELECT cp.entity_id, cp.user_id, cp.permission AS value FROM s20.entity_users cp FOR JSON AUTO

),'[{"entity_id":null,"user_id":null,"value":null}]') + '}' AS data

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure processes changes of usp_web_entity_users
-- =============================================

CREATE PROCEDURE [s20].[usp_web_entity_users_change]
    @entity_id int = NULL
    , @user_id int = NULL
    , @cell_number_value tinyint = NULL
AS
BEGIN

MERGE s20.entity_users t
USING (SELECT @entity_id, @user_id, @cell_number_value) s (entity_id, user_id, permission)
ON (t.entity_id = s.entity_id AND t.user_id = s.user_id)
WHEN MATCHED AND s.permission IS NULL THEN
    DELETE
WHEN MATCHED AND s.permission IS NOT NULL THEN
    UPDATE SET permission = s.permission
WHEN NOT MATCHED THEN
    INSERT (entity_id, user_id, permission)
    VALUES (s.entity_id, s.user_id, s.permission);

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Data entry form
-- =============================================

CREATE PROCEDURE [s20].[usp_web_form_01]
    @entity_id int = NULL
    , @category_id int = NULL
    , @year int = NULL
AS
BEGIN

SET NOCOUNT ON;

DECLARE @user_id int = (SELECT id FROM s20.users WHERE username = USER_NAME())

IF @entity_id IS NULL
    SELECT TOP 1 @entity_id = entity_id FROM s20.entity_users p WHERE p.user_id = @user_id

IF @category_id IS NULL
    SELECT TOP 1 @category_id = category_id FROM s20.category_users p WHERE p.user_id = @user_id

IF @year IS NULL
    SET @year = YEAR(GETDATE())

SELECT '{"parameters":[{"name":"entity_id","is_nullable":false' + COALESCE(',"value":' + CAST(@entity_id AS nvarchar(10)), '') + ',"items":' + COALESCE((

    SELECT e.id, e.name
    FROM s20.entities e INNER JOIN s20.entity_users p ON p.entity_id = e.id INNER JOIN s20.users u ON u.id = p.user_id AND u.username = USER_NAME()
    WHERE p.permission IN (1,2)
    ORDER BY e.name
    FOR JSON AUTO

), 'null') + '},{"name":"category_id","is_nullable":false' + COALESCE(',"value":' + CAST(@category_id AS nvarchar(10)), '') + ',"items":' + COALESCE((

    SELECT c.id, c.name FROM s20.categories c INNER JOIN s20.category_users p ON p.category_id = c.id INNER JOIN s20.users u ON u.id = p.user_id AND u.username = USER_NAME()
    WHERE p.permission IN (1,2)
    ORDER BY c.id
    FOR JSON AUTO

), 'null') + '},{"name":"year","is_nullable":false' + COALESCE(',"value":' + CAST(@year AS nvarchar(10)), '') + ',"items":' + COALESCE((

    SELECT DISTINCT t.year FROM s20.times t INNER JOIN s20.category_times p ON p.time_id = t.id AND p.category_id = @category_id ORDER BY t.year
    FOR JSON AUTO

), 'null') + '}],"rows":' + (

    SELECT a.id AS account_id, a.name FROM s20.accounts a ORDER BY a.code
    FOR JSON AUTO

) + ',"columns":' + COALESCE((

    SELECT t.id AS time_id, t.column_name, 1 AS column_group FROM s20.times t WHERE t.year = @year ORDER BY t.code
    FOR JSON AUTO

), 'null') + ',"cells":' + COALESCE((

    SELECT
        f.account_id
        , f.time_id
        , f.value
    FROM
        s20.facts f
        INNER JOIN s20.times t ON t.id = f.time_id
        INNER JOIN s20.entity_users ep ON ep.entity_id = f.entity_id AND ep.user_id = @user_id
        INNER JOIN s20.category_users cp ON cp.category_id = f.category_id AND cp.user_id = @user_id
        LEFT OUTER JOIN s20.category_times ct ON ct.category_id = f.category_id AND ct.time_id = f.time_id
    WHERE
        f.entity_id = @entity_id
        AND f.category_id = @category_id
        AND t.year = @year
        AND ep.permission IN (1,2)
        AND cp.permission IN (1,2)
        AND COALESCE(ct.permission, 1) IN (1,2)
    FOR JSON AUTO

),'[{"account_id":null,"time_id":null,"value":null}]') + '}' AS data

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure processes changes of usp_web_form_01
-- =============================================

CREATE PROCEDURE [s20].[usp_web_form_01_change]
    @account_id int = NULL
    , @entity_id int = NULL
    , @category_id int = NULL
    , @time_id int = NULL
    , @cell_number_value money = NULL
    , @year int = NULL
AS
BEGIN

SET NOCOUNT ON;

DECLARE @user_id int = (SELECT id FROM s20.users WHERE username = USER_NAME())

IF @user_id IS NULL
    BEGIN
    RAISERROR('No permission', 16, 1)
    RETURN
    END

IF NOT EXISTS(SELECT permission FROM s20.entity_users WHERE entity_id = @entity_id AND user_id = @user_id AND permission = 2)
    BEGIN
    RAISERROR('No permission', 16, 1)
    RETURN
    END

IF NOT EXISTS(SELECT permission FROM s20.category_users WHERE category_id = @category_id AND user_id = @user_id AND permission = 2)
    BEGIN
    RAISERROR('No permission', 16, 1)
    RETURN
    END

IF NOT EXISTS(SELECT permission FROM s20.category_times WHERE category_id = @category_id AND time_id = @time_id AND permission = 2)
    BEGIN
    RAISERROR('Period closed', 16, 1)
    RETURN
    END

SET NOCOUNT OFF;

MERGE s20.facts t
USING (SELECT @account_id, @entity_id, @category_id, @time_id, @cell_number_value) s (account_id, entity_id, category_id, time_id, value)
ON (t.account_id = s.account_id AND t.entity_id = s.entity_id AND t.category_id = s.category_id AND t.time_id = s.time_id)
WHEN MATCHED THEN
    UPDATE SET value = s.value
WHEN NOT MATCHED THEN
    INSERT (account_id, entity_id, category_id, time_id, value)
    VALUES (s.account_id, s.entity_id, s.category_id, s.time_id, s.value);

END


GO

SET IDENTITY_INSERT s20.accounts ON;
INSERT INTO s20.accounts (id, code, name) VALUES (1, N'100', N'Sales');
INSERT INTO s20.accounts (id, code, name) VALUES (2, N'200', N'Cost of sales');
INSERT INTO s20.accounts (id, code, name) VALUES (3, N'300', N'Operating expences');
INSERT INTO s20.accounts (id, code, name) VALUES (4, N'900', N'Net Income');
SET IDENTITY_INSERT s20.accounts OFF;
GO

SET IDENTITY_INSERT s20.categories ON;
INSERT INTO s20.categories (id, code, name) VALUES (1, N'Budget', N'Budget');
INSERT INTO s20.categories (id, code, name) VALUES (2, N'Actual', N'Actual');
INSERT INTO s20.categories (id, code, name) VALUES (3, N'Forecast', N'Forecast');
SET IDENTITY_INSERT s20.categories OFF;
GO

SET IDENTITY_INSERT s20.entities ON;
INSERT INTO s20.entities (id, code, name) VALUES (1, N'Plant01', N'Plant 01');
INSERT INTO s20.entities (id, code, name) VALUES (2, N'Plant02', N'Plant 02');
SET IDENTITY_INSERT s20.entities OFF;
GO

INSERT INTO s20.permissions (id, code, name) VALUES (0, N'D', N'Deny');
INSERT INTO s20.permissions (id, code, name) VALUES (1, N'R', N'Read');
INSERT INTO s20.permissions (id, code, name) VALUES (2, N'W', N'Write');
GO

SET IDENTITY_INSERT s20.times ON;
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (1, N'2022-01', N'2022-01', 2022, N'01');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (2, N'2022-02', N'2022-02', 2022, N'02');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (3, N'2022-03', N'2022-03', 2022, N'03');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (4, N'2022-04', N'2022-04', 2022, N'04');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (5, N'2022-05', N'2022-05', 2022, N'05');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (6, N'2022-06', N'2022-06', 2022, N'06');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (7, N'2022-07', N'2022-07', 2022, N'07');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (8, N'2022-08', N'2022-08', 2022, N'08');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (9, N'2022-09', N'2022-09', 2022, N'09');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (10, N'2022-10', N'2022-10', 2022, N'10');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (11, N'2022-11', N'2022-11', 2022, N'11');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (12, N'2022-12', N'2022-12', 2022, N'12');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (13, N'2023-01', N'2023-01', 2023, N'01');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (14, N'2023-02', N'2023-02', 2023, N'02');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (15, N'2023-03', N'2023-03', 2023, N'03');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (16, N'2023-04', N'2023-04', 2023, N'04');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (17, N'2023-05', N'2023-05', 2023, N'05');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (18, N'2023-06', N'2023-06', 2023, N'06');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (19, N'2023-07', N'2023-07', 2023, N'07');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (20, N'2023-08', N'2023-08', 2023, N'08');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (21, N'2023-09', N'2023-09', 2023, N'09');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (22, N'2023-10', N'2023-10', 2023, N'10');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (23, N'2023-11', N'2023-11', 2023, N'11');
INSERT INTO s20.times (id, code, name, year, column_name) VALUES (24, N'2023-12', N'2023-12', 2023, N'12');
SET IDENTITY_INSERT s20.times OFF;
GO

SET IDENTITY_INSERT s20.users ON;
INSERT INTO s20.users (id, username) VALUES (1, N'dbo');
INSERT INTO s20.users (id, username) VALUES (2, N'sample20_user1');
INSERT INTO s20.users (id, username) VALUES (3, N'sample20_user2');
SET IDENTITY_INSERT s20.users OFF;
GO

INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 1, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 2, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 3, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 4, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 5, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 6, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 7, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 8, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 9, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 10, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 11, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 12, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 13, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 14, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 15, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 16, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 17, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 18, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 19, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 20, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 21, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 22, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 23, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (1, 24, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 1, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 2, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 3, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 4, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 5, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 6, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 7, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 8, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 9, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 10, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 11, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 12, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 13, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 14, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 15, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 16, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 17, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 18, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 19, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 20, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 21, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 22, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 23, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (2, 24, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 1, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 2, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 3, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 4, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 5, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 6, 1);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 7, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 8, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 9, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 10, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 11, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 12, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 13, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 14, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 15, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 16, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 17, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 18, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 19, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 20, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 21, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 22, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 23, 2);
INSERT INTO s20.category_times (category_id, time_id, permission) VALUES (3, 24, 2);
GO

INSERT INTO s20.category_users (category_id, user_id, permission) VALUES (1, 1, 2);
INSERT INTO s20.category_users (category_id, user_id, permission) VALUES (1, 2, 2);
INSERT INTO s20.category_users (category_id, user_id, permission) VALUES (1, 3, 2);
INSERT INTO s20.category_users (category_id, user_id, permission) VALUES (2, 1, 2);
INSERT INTO s20.category_users (category_id, user_id, permission) VALUES (2, 2, 2);
INSERT INTO s20.category_users (category_id, user_id, permission) VALUES (2, 3, 2);
INSERT INTO s20.category_users (category_id, user_id, permission) VALUES (3, 1, 2);
INSERT INTO s20.category_users (category_id, user_id, permission) VALUES (3, 2, 2);
INSERT INTO s20.category_users (category_id, user_id, permission) VALUES (3, 3, 0);
GO

INSERT INTO s20.entity_users (entity_id, user_id, permission) VALUES (1, 1, 2);
INSERT INTO s20.entity_users (entity_id, user_id, permission) VALUES (1, 2, 2);
INSERT INTO s20.entity_users (entity_id, user_id, permission) VALUES (2, 1, 2);
INSERT INTO s20.entity_users (entity_id, user_id, permission) VALUES (2, 2, 2);
INSERT INTO s20.entity_users (entity_id, user_id, permission) VALUES (2, 3, 2);
GO

SET IDENTITY_INSERT s20.facts ON;
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (1, 1, 1, 1, 1, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (2, 1, 1, 1, 2, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (3, 1, 1, 1, 3, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (4, 1, 1, 1, 4, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (5, 1, 1, 1, 5, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (6, 1, 1, 1, 6, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (7, 1, 1, 1, 7, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (8, 1, 1, 1, 8, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (9, 1, 1, 1, 9, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (10, 1, 1, 1, 10, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (11, 1, 1, 1, 11, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (12, 1, 1, 1, 12, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (13, 2, 1, 1, 1, 10000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (14, 2, 1, 1, 2, 10000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (15, 2, 1, 1, 3, 10000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (16, 2, 1, 1, 4, 10000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (17, 2, 1, 1, 5, 10000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (18, 2, 1, 1, 6, 10000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (19, 2, 1, 1, 7, 10000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (20, 2, 1, 1, 8, 10000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (21, 2, 1, 1, 9, 10000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (22, 2, 1, 1, 10, 10000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (23, 2, 1, 1, 11, 10000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (24, 2, 1, 1, 12, 10000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (25, 3, 1, 1, 1, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (26, 3, 1, 1, 2, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (27, 3, 1, 1, 3, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (28, 3, 1, 1, 4, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (29, 3, 1, 1, 5, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (30, 3, 1, 1, 6, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (31, 3, 1, 1, 7, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (32, 3, 1, 1, 8, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (33, 3, 1, 1, 9, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (34, 3, 1, 1, 10, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (35, 3, 1, 1, 11, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (36, 3, 1, 1, 12, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (37, 4, 1, 1, 1, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (38, 4, 1, 1, 2, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (39, 4, 1, 1, 3, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (40, 4, 1, 1, 4, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (41, 4, 1, 1, 5, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (42, 4, 1, 1, 6, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (43, 4, 1, 1, 7, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (44, 4, 1, 1, 8, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (45, 4, 1, 1, 9, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (46, 4, 1, 1, 10, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (47, 4, 1, 1, 11, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (48, 4, 1, 1, 12, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (50, 1, 2, 1, 1, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (51, 1, 2, 1, 2, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (52, 1, 2, 1, 3, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (53, 1, 2, 1, 4, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (54, 1, 2, 1, 5, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (55, 1, 2, 1, 6, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (56, 1, 2, 1, 7, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (57, 1, 2, 1, 8, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (58, 1, 2, 1, 9, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (59, 1, 2, 1, 10, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (60, 1, 2, 1, 11, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (61, 1, 2, 1, 12, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (62, 2, 2, 1, 1, 9000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (63, 2, 2, 1, 2, 9000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (64, 2, 2, 1, 3, 9000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (65, 2, 2, 1, 4, 9000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (66, 2, 2, 1, 5, 9000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (67, 2, 2, 1, 6, 9000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (68, 2, 2, 1, 7, 9000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (69, 2, 2, 1, 8, 9000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (70, 2, 2, 1, 9, 9000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (71, 2, 2, 1, 10, 9000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (72, 2, 2, 1, 11, 9000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (73, 2, 2, 1, 12, 9000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (74, 3, 2, 1, 1, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (75, 3, 2, 1, 2, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (76, 3, 2, 1, 3, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (77, 3, 2, 1, 4, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (78, 3, 2, 1, 5, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (79, 3, 2, 1, 6, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (80, 3, 2, 1, 7, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (81, 3, 2, 1, 8, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (82, 3, 2, 1, 9, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (83, 3, 2, 1, 10, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (84, 3, 2, 1, 11, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (85, 3, 2, 1, 12, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (86, 4, 2, 1, 1, 2000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (87, 4, 2, 1, 2, 2000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (88, 4, 2, 1, 3, 2000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (89, 4, 2, 1, 4, 2000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (90, 4, 2, 1, 5, 2000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (91, 4, 2, 1, 6, 2000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (92, 4, 2, 1, 7, 2000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (93, 4, 2, 1, 8, 2000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (94, 4, 2, 1, 9, 2000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (95, 4, 2, 1, 10, 2000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (96, 4, 2, 1, 11, 2000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (97, 4, 2, 1, 12, 2000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (98, 1, 1, 1, 13, 30000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (99, 1, 1, 1, 14, 30000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (100, 1, 1, 1, 15, 30000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (101, 1, 1, 1, 16, 30000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (102, 1, 1, 1, 17, 30000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (103, 1, 1, 1, 18, 30000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (104, 1, 1, 1, 19, 30000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (105, 1, 1, 1, 20, 30000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (106, 1, 1, 1, 21, 30000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (107, 1, 1, 1, 22, 30000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (108, 1, 1, 1, 23, 30000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (109, 1, 1, 1, 24, 30000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (110, 2, 1, 1, 13, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (111, 2, 1, 1, 14, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (112, 2, 1, 1, 15, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (113, 2, 1, 1, 16, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (114, 2, 1, 1, 17, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (115, 2, 1, 1, 18, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (116, 2, 1, 1, 19, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (117, 2, 1, 1, 20, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (118, 2, 1, 1, 21, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (119, 2, 1, 1, 22, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (120, 2, 1, 1, 23, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (121, 2, 1, 1, 24, 15000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (122, 3, 1, 1, 13, 8000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (123, 3, 1, 1, 14, 8000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (124, 3, 1, 1, 15, 8000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (125, 3, 1, 1, 16, 8000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (126, 3, 1, 1, 17, 8000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (127, 3, 1, 1, 18, 8000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (128, 3, 1, 1, 19, 8000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (129, 3, 1, 1, 20, 8000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (130, 3, 1, 1, 21, 8000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (131, 3, 1, 1, 22, 8000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (132, 3, 1, 1, 23, 8000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (133, 3, 1, 1, 24, 8000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (134, 4, 1, 1, 13, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (135, 4, 1, 1, 14, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (136, 4, 1, 1, 15, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (137, 4, 1, 1, 16, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (138, 4, 1, 1, 17, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (139, 4, 1, 1, 18, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (140, 4, 1, 1, 19, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (141, 4, 1, 1, 20, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (142, 4, 1, 1, 21, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (143, 4, 1, 1, 22, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (144, 4, 1, 1, 23, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (145, 4, 1, 1, 24, 5000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (146, 1, 2, 1, 13, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (147, 1, 2, 1, 14, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (148, 1, 2, 1, 15, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (149, 1, 2, 1, 16, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (150, 1, 2, 1, 17, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (151, 1, 2, 1, 18, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (152, 1, 2, 1, 19, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (153, 1, 2, 1, 20, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (154, 1, 2, 1, 21, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (155, 1, 2, 1, 22, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (156, 1, 2, 1, 23, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (157, 1, 2, 1, 24, 20000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (158, 2, 2, 1, 13, 12000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (159, 2, 2, 1, 14, 12000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (160, 2, 2, 1, 15, 12000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (161, 2, 2, 1, 16, 12000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (162, 2, 2, 1, 17, 12000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (163, 2, 2, 1, 18, 12000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (164, 2, 2, 1, 19, 12000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (165, 2, 2, 1, 20, 12000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (166, 2, 2, 1, 21, 12000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (167, 2, 2, 1, 22, 12000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (168, 2, 2, 1, 23, 12000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (169, 2, 2, 1, 24, 12000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (170, 3, 2, 1, 13, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (171, 3, 2, 1, 14, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (172, 3, 2, 1, 15, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (173, 3, 2, 1, 16, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (174, 3, 2, 1, 17, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (175, 3, 2, 1, 18, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (176, 3, 2, 1, 19, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (177, 3, 2, 1, 20, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (178, 3, 2, 1, 21, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (179, 3, 2, 1, 22, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (180, 3, 2, 1, 23, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (181, 3, 2, 1, 24, 4000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (182, 4, 2, 1, 13, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (183, 4, 2, 1, 14, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (184, 4, 2, 1, 15, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (185, 4, 2, 1, 16, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (186, 4, 2, 1, 17, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (187, 4, 2, 1, 18, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (188, 4, 2, 1, 19, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (189, 4, 2, 1, 20, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (190, 4, 2, 1, 21, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (191, 4, 2, 1, 22, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (192, 4, 2, 1, 23, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (193, 4, 2, 1, 24, 3000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (194, 1, 1, 2, 1, 22000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (195, 2, 1, 2, 1, 11000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (196, 3, 1, 2, 1, 5500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (197, 4, 1, 2, 1, 4400000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (198, 1, 1, 2, 2, 22000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (199, 1, 1, 2, 3, 22000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (200, 1, 1, 2, 4, 22000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (201, 1, 1, 2, 5, 22000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (202, 1, 1, 2, 6, 22000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (203, 1, 1, 2, 7, 22000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (204, 1, 1, 2, 8, 22000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (205, 1, 1, 2, 9, 22000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (206, 1, 1, 2, 10, 22000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (207, 1, 1, 2, 11, 22000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (208, 1, 1, 2, 12, 22000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (209, 2, 1, 2, 2, 11000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (210, 2, 1, 2, 3, 11000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (211, 2, 1, 2, 4, 11000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (212, 2, 1, 2, 5, 11000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (213, 2, 1, 2, 6, 11000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (214, 2, 1, 2, 7, 11000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (215, 2, 1, 2, 8, 11000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (216, 2, 1, 2, 9, 11000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (217, 2, 1, 2, 10, 11000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (218, 2, 1, 2, 11, 11000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (219, 2, 1, 2, 12, 11000000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (220, 3, 1, 2, 2, 5500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (221, 3, 1, 2, 3, 5500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (222, 3, 1, 2, 4, 5500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (223, 3, 1, 2, 5, 5500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (224, 3, 1, 2, 6, 5500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (225, 3, 1, 2, 7, 5500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (226, 3, 1, 2, 8, 5500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (227, 3, 1, 2, 9, 5500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (228, 3, 1, 2, 10, 5500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (229, 3, 1, 2, 11, 5500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (230, 3, 1, 2, 12, 5500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (231, 4, 1, 2, 2, 4400000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (232, 4, 1, 2, 3, 4400000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (233, 4, 1, 2, 4, 4400000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (234, 4, 1, 2, 5, 4400000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (235, 4, 1, 2, 6, 4400000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (236, 4, 1, 2, 7, 4400000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (237, 4, 1, 2, 8, 4400000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (238, 4, 1, 2, 9, 4400000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (239, 4, 1, 2, 10, 4400000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (240, 4, 1, 2, 11, 4400000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (241, 4, 1, 2, 12, 4400000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (242, 1, 2, 2, 1, 16500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (243, 2, 2, 2, 1, 9900000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (244, 3, 2, 2, 1, 3300000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (245, 4, 2, 2, 1, 2200000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (246, 1, 2, 2, 2, 16500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (247, 1, 2, 2, 3, 16500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (248, 1, 2, 2, 4, 16500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (249, 1, 2, 2, 5, 16500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (250, 1, 2, 2, 6, 16500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (251, 1, 2, 2, 7, 16500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (252, 1, 2, 2, 8, 16500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (253, 1, 2, 2, 9, 16500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (254, 1, 2, 2, 10, 16500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (255, 1, 2, 2, 11, 16500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (256, 1, 2, 2, 12, 16500000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (257, 2, 2, 2, 2, 9900000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (258, 2, 2, 2, 3, 9900000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (259, 2, 2, 2, 4, 9900000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (260, 2, 2, 2, 5, 9900000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (261, 2, 2, 2, 6, 9900000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (262, 2, 2, 2, 7, 9900000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (263, 2, 2, 2, 8, 9900000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (264, 2, 2, 2, 9, 9900000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (265, 2, 2, 2, 10, 9900000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (266, 2, 2, 2, 11, 9900000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (267, 2, 2, 2, 12, 9900000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (268, 3, 2, 2, 2, 3300000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (269, 3, 2, 2, 3, 3300000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (270, 3, 2, 2, 4, 3300000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (271, 3, 2, 2, 5, 3300000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (272, 3, 2, 2, 6, 3300000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (273, 3, 2, 2, 7, 3300000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (274, 3, 2, 2, 8, 3300000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (275, 3, 2, 2, 9, 3300000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (276, 3, 2, 2, 10, 3300000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (277, 3, 2, 2, 11, 3300000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (278, 3, 2, 2, 12, 3300000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (279, 4, 2, 2, 2, 2200000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (280, 4, 2, 2, 3, 2200000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (281, 4, 2, 2, 4, 2200000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (282, 4, 2, 2, 5, 2200000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (283, 4, 2, 2, 6, 2200000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (284, 4, 2, 2, 7, 2200000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (285, 4, 2, 2, 8, 2200000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (286, 4, 2, 2, 9, 2200000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (287, 4, 2, 2, 10, 2200000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (288, 4, 2, 2, 11, 2200000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (289, 4, 2, 2, 12, 2200000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (290, 1, 2, 3, 1, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (291, 2, 2, 3, 1, 9100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (292, 3, 2, 3, 1, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (293, 4, 2, 3, 1, 2100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (294, 1, 2, 3, 2, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (295, 1, 2, 3, 3, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (296, 1, 2, 3, 4, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (297, 1, 2, 3, 5, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (298, 1, 2, 3, 6, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (299, 1, 2, 3, 7, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (300, 1, 2, 3, 8, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (301, 1, 2, 3, 9, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (302, 1, 2, 3, 10, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (303, 1, 2, 3, 11, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (304, 1, 2, 3, 12, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (305, 2, 2, 3, 2, 9100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (306, 2, 2, 3, 3, 9100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (307, 2, 2, 3, 4, 9100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (308, 2, 2, 3, 5, 9100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (309, 2, 2, 3, 6, 9100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (310, 2, 2, 3, 7, 9100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (311, 2, 2, 3, 8, 9100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (312, 2, 2, 3, 9, 9100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (313, 2, 2, 3, 10, 9100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (314, 2, 2, 3, 11, 9100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (315, 2, 2, 3, 12, 9100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (316, 3, 2, 3, 2, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (317, 3, 2, 3, 3, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (318, 3, 2, 3, 4, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (319, 3, 2, 3, 5, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (320, 3, 2, 3, 6, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (321, 3, 2, 3, 7, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (322, 3, 2, 3, 8, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (323, 3, 2, 3, 9, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (324, 3, 2, 3, 10, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (325, 3, 2, 3, 11, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (326, 3, 2, 3, 12, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (327, 4, 2, 3, 2, 2100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (328, 4, 2, 3, 3, 2100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (329, 4, 2, 3, 4, 2100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (330, 4, 2, 3, 5, 2100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (331, 4, 2, 3, 6, 2100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (332, 4, 2, 3, 7, 2100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (333, 4, 2, 3, 8, 2100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (334, 4, 2, 3, 9, 2100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (335, 4, 2, 3, 10, 2100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (336, 4, 2, 3, 11, 2100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (337, 4, 2, 3, 12, 2100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (338, 1, 2, 3, 13, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (339, 2, 2, 3, 13, 12100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (340, 3, 2, 3, 13, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (341, 4, 2, 3, 13, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (342, 1, 2, 3, 14, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (343, 1, 2, 3, 15, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (344, 1, 2, 3, 16, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (345, 1, 2, 3, 17, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (346, 1, 2, 3, 18, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (347, 1, 2, 3, 19, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (348, 1, 2, 3, 20, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (349, 1, 2, 3, 21, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (350, 1, 2, 3, 22, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (351, 1, 2, 3, 23, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (352, 1, 2, 3, 24, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (353, 2, 2, 3, 14, 12100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (354, 2, 2, 3, 15, 12100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (355, 2, 2, 3, 16, 12100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (356, 2, 2, 3, 17, 12100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (357, 2, 2, 3, 18, 12100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (358, 2, 2, 3, 19, 12100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (359, 2, 2, 3, 20, 12100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (360, 2, 2, 3, 21, 12100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (361, 2, 2, 3, 22, 12100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (362, 2, 2, 3, 23, 12100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (363, 2, 2, 3, 24, 12100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (364, 3, 2, 3, 14, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (365, 3, 2, 3, 15, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (366, 3, 2, 3, 16, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (367, 3, 2, 3, 17, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (368, 3, 2, 3, 18, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (369, 3, 2, 3, 19, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (370, 3, 2, 3, 20, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (371, 3, 2, 3, 21, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (372, 3, 2, 3, 22, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (373, 3, 2, 3, 23, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (374, 3, 2, 3, 24, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (375, 4, 2, 3, 14, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (376, 4, 2, 3, 15, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (377, 4, 2, 3, 16, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (378, 4, 2, 3, 17, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (379, 4, 2, 3, 18, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (380, 4, 2, 3, 19, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (381, 4, 2, 3, 20, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (382, 4, 2, 3, 21, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (383, 4, 2, 3, 22, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (384, 4, 2, 3, 23, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (385, 4, 2, 3, 24, 3100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (386, 1, 1, 3, 13, 30100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (387, 2, 1, 3, 13, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (388, 3, 1, 3, 13, 8100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (389, 4, 1, 3, 13, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (390, 1, 1, 3, 14, 30100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (391, 1, 1, 3, 15, 30100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (392, 1, 1, 3, 16, 30100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (393, 1, 1, 3, 17, 30100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (394, 1, 1, 3, 18, 30100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (395, 1, 1, 3, 19, 30100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (396, 1, 1, 3, 20, 30100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (397, 1, 1, 3, 21, 30100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (398, 1, 1, 3, 22, 30100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (399, 1, 1, 3, 23, 30100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (400, 1, 1, 3, 24, 30100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (401, 2, 1, 3, 14, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (402, 2, 1, 3, 15, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (403, 2, 1, 3, 16, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (404, 2, 1, 3, 17, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (405, 2, 1, 3, 18, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (406, 2, 1, 3, 19, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (407, 2, 1, 3, 20, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (408, 2, 1, 3, 21, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (409, 2, 1, 3, 22, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (410, 2, 1, 3, 23, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (411, 2, 1, 3, 24, 15100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (412, 3, 1, 3, 14, 8100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (413, 3, 1, 3, 15, 8100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (414, 3, 1, 3, 16, 8100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (415, 3, 1, 3, 17, 8100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (416, 3, 1, 3, 18, 8100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (417, 3, 1, 3, 19, 8100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (418, 3, 1, 3, 20, 8100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (419, 3, 1, 3, 21, 8100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (420, 3, 1, 3, 22, 8100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (421, 3, 1, 3, 23, 8100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (422, 3, 1, 3, 24, 8100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (423, 4, 1, 3, 14, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (424, 4, 1, 3, 15, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (425, 4, 1, 3, 16, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (426, 4, 1, 3, 17, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (427, 4, 1, 3, 18, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (428, 4, 1, 3, 19, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (429, 4, 1, 3, 20, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (430, 4, 1, 3, 21, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (431, 4, 1, 3, 22, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (432, 4, 1, 3, 23, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (433, 4, 1, 3, 24, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (434, 1, 1, 3, 1, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (435, 2, 1, 3, 1, 10100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (436, 3, 1, 3, 1, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (437, 4, 1, 3, 1, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (438, 1, 1, 3, 2, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (439, 1, 1, 3, 3, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (440, 1, 1, 3, 4, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (441, 1, 1, 3, 5, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (442, 1, 1, 3, 6, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (443, 1, 1, 3, 7, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (444, 1, 1, 3, 8, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (445, 1, 1, 3, 9, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (446, 1, 1, 3, 10, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (447, 1, 1, 3, 11, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (448, 1, 1, 3, 12, 20100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (449, 2, 1, 3, 2, 10100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (450, 2, 1, 3, 3, 10100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (451, 2, 1, 3, 4, 10100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (452, 2, 1, 3, 5, 10100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (453, 2, 1, 3, 6, 10100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (454, 2, 1, 3, 7, 10100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (455, 2, 1, 3, 8, 10100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (456, 2, 1, 3, 9, 10100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (457, 2, 1, 3, 10, 10100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (458, 2, 1, 3, 11, 10100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (459, 2, 1, 3, 12, 10100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (460, 3, 1, 3, 2, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (461, 3, 1, 3, 3, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (462, 3, 1, 3, 4, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (463, 3, 1, 3, 5, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (464, 3, 1, 3, 6, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (465, 3, 1, 3, 7, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (466, 3, 1, 3, 8, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (467, 3, 1, 3, 9, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (468, 3, 1, 3, 10, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (469, 3, 1, 3, 11, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (470, 3, 1, 3, 12, 5100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (471, 4, 1, 3, 2, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (472, 4, 1, 3, 3, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (473, 4, 1, 3, 4, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (474, 4, 1, 3, 5, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (475, 4, 1, 3, 6, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (476, 4, 1, 3, 7, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (477, 4, 1, 3, 8, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (478, 4, 1, 3, 9, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (479, 4, 1, 3, 10, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (480, 4, 1, 3, 11, 4100000);
INSERT INTO s20.facts (id, account_id, entity_id, category_id, time_id, value) VALUES (481, 4, 1, 3, 12, 4100000);
SET IDENTITY_INSERT s20.facts OFF;
GO

INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's20', N'accounts', N'<table name="s20.accounts"><columnFormats><column name="" property="ListObjectName" value="tables" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="2" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="code" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="code" property="Address" value="$D$4" type="String" /><column name="code" property="ColumnWidth" value="6.86" type="Double" /><column name="code" property="NumberFormat" value="General" type="String" /><column name="code" property="Validation.Type" value="6" type="Double" /><column name="code" property="Validation.Operator" value="8" type="Double" /><column name="code" property="Validation.Formula1" value="50" type="String" /><column name="code" property="Validation.AlertStyle" value="2" type="Double" /><column name="code" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="code" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="code" property="Validation.ShowInput" value="True" type="Boolean" /><column name="code" property="Validation.ShowError" value="True" type="Boolean" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="name" property="Address" value="$E$4" type="String" /><column name="name" property="ColumnWidth" value="18.29" type="Double" /><column name="name" property="NumberFormat" value="General" type="String" /><column name="name" property="Validation.Type" value="6" type="Double" /><column name="name" property="Validation.Operator" value="8" type="Double" /><column name="name" property="Validation.Formula1" value="255" type="String" /><column name="name" property="Validation.AlertStyle" value="2" type="Double" /><column name="name" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="name" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="name" property="Validation.ShowInput" value="True" type="Boolean" /><column name="name" property="Validation.ShowError" value="True" type="Boolean" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's20', N'categories', N'<table name="s20.categories"><columnFormats><column name="" property="ListObjectName" value="tables" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="2" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="id" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="code" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="code" property="Address" value="$D$4" type="String" /><column name="code" property="ColumnWidth" value="7.71" type="Double" /><column name="code" property="NumberFormat" value="General" type="String" /><column name="code" property="Validation.Type" value="6" type="Double" /><column name="code" property="Validation.Operator" value="8" type="Double" /><column name="code" property="Validation.Formula1" value="50" type="String" /><column name="code" property="Validation.AlertStyle" value="2" type="Double" /><column name="code" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="code" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="code" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="code" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(50) datatype." type="String" /><column name="code" property="Validation.ShowInput" value="True" type="Boolean" /><column name="code" property="Validation.ShowError" value="True" type="Boolean" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="name" property="Address" value="$E$4" type="String" /><column name="name" property="ColumnWidth" value="7.71" type="Double" /><column name="name" property="NumberFormat" value="General" type="String" /><column name="name" property="Validation.Type" value="6" type="Double" /><column name="name" property="Validation.Operator" value="8" type="Double" /><column name="name" property="Validation.Formula1" value="255" type="String" /><column name="name" property="Validation.AlertStyle" value="2" type="Double" /><column name="name" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="name" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="name" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="name" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(255) datatype." type="String" /><column name="name" property="Validation.ShowInput" value="True" type="Boolean" /><column name="name" property="Validation.ShowError" value="True" type="Boolean" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's20', N'category_times', N'<table name="s20.category_times"><columnFormats><column name="" property="ListObjectName" value="tables" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="category_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="category_id" property="Address" value="$C$4" type="String" /><column name="category_id" property="ColumnWidth" value="12.86" type="Double" /><column name="category_id" property="NumberFormat" value="General" type="String" /><column name="time_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="time_id" property="Address" value="$D$4" type="String" /><column name="time_id" property="ColumnWidth" value="9.43" type="Double" /><column name="time_id" property="NumberFormat" value="General" type="String" /><column name="permission" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="permission" property="Address" value="$E$4" type="String" /><column name="permission" property="ColumnWidth" value="12.43" type="Double" /><column name="permission" property="NumberFormat" value="General" type="String" /><column name="_State_" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_State_" property="Address" value="$F$4" type="String" /><column name="_State_" property="ColumnWidth" value="9.14" type="Double" /><column name="_State_" property="NumberFormat" value="General" type="String" /><column name="_State_" property="HorizontalAlignment" value="-4108" type="Double" /><column name="_State_" property="Font.Size" value="10" type="Double" /><column name="category_id" property="FormatConditions(1).ColumnsCount" value="2" type="Double" /><column name="category_id" property="FormatConditions(1).AppliesTo.Address" value="$C$4:$D$75" type="String" /><column name="category_id" property="FormatConditions(1).Type" value="2" type="Double" /><column name="category_id" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="category_id" property="FormatConditions(1).Formula1" value="=ISBLANK(C4)" type="String" /><column name="category_id" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="_State_" property="FormatConditions(1).AppliesTo.Address" value="$F$4:$F$75" type="String" /><column name="_State_" property="FormatConditions(1).Type" value="6" type="Double" /><column name="_State_" property="FormatConditions(1).Priority" value="2" type="Double" /><column name="_State_" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean" /><column name="_State_" property="FormatConditions(1).IconSet.ID" value="8" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's20', N'category_users', N'<table name="s20.category_users"><columnFormats><column name="" property="ListObjectName" value="tables" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="category_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="category_id" property="Address" value="$C$4" type="String" /><column name="category_id" property="ColumnWidth" value="12.86" type="Double" /><column name="category_id" property="NumberFormat" value="General" type="String" /><column name="user_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="user_id" property="Address" value="$D$4" type="String" /><column name="user_id" property="ColumnWidth" value="14.71" type="Double" /><column name="user_id" property="NumberFormat" value="General" type="String" /><column name="permission" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="permission" property="Address" value="$E$4" type="String" /><column name="permission" property="ColumnWidth" value="12.43" type="Double" /><column name="permission" property="NumberFormat" value="General" type="String" /><column name="_State_" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_State_" property="Address" value="$F$4" type="String" /><column name="_State_" property="ColumnWidth" value="9.14" type="Double" /><column name="_State_" property="NumberFormat" value="General" type="String" /><column name="_State_" property="HorizontalAlignment" value="-4108" type="Double" /><column name="_State_" property="Font.Size" value="10" type="Double" /><column name="_State_" property="FormatConditions(1).AppliesTo.Address" value="$F$4:$F$12" type="String" /><column name="_State_" property="FormatConditions(1).Type" value="6" type="Double" /><column name="_State_" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="_State_" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean" /><column name="_State_" property="FormatConditions(1).IconSet.ID" value="8" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's20', N'comments', N'<table name="s20.comments"><columnFormats><column name="" property="ListObjectName" value="Sheet1_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="2" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="fact_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="fact_id" property="Address" value="$D$4" type="String" /><column name="fact_id" property="ColumnWidth" value="9.29" type="Double" /><column name="fact_id" property="NumberFormat" value="General" type="String" /><column name="user_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="user_id" property="Address" value="$E$4" type="String" /><column name="user_id" property="ColumnWidth" value="19.29" type="Double" /><column name="user_id" property="NumberFormat" value="General" type="String" /><column name="time" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="time" property="Address" value="$F$4" type="String" /><column name="time" property="ColumnWidth" value="9.29" type="Double" /><column name="time" property="NumberFormat" value="m/d/yyyy h:mm" type="String" /><column name="comment" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="comment" property="Address" value="$G$4" type="String" /><column name="comment" property="ColumnWidth" value="11" type="Double" /><column name="comment" property="NumberFormat" value="General" type="String" /><column name="comment" property="Validation.Type" value="6" type="Double" /><column name="comment" property="Validation.Operator" value="8" type="Double" /><column name="comment" property="Validation.Formula1" value="255" type="String" /><column name="comment" property="Validation.AlertStyle" value="2" type="Double" /><column name="comment" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="comment" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="comment" property="Validation.ShowInput" value="True" type="Boolean" /><column name="comment" property="Validation.ShowError" value="True" type="Boolean" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's20', N'entities', N'<table name="s20.entities"><columnFormats><column name="" property="ListObjectName" value="Sheet1_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="2" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="code" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="code" property="Address" value="$D$4" type="String" /><column name="code" property="ColumnWidth" value="13.57" type="Double" /><column name="code" property="NumberFormat" value="General" type="String" /><column name="code" property="Validation.Type" value="6" type="Double" /><column name="code" property="Validation.Operator" value="8" type="Double" /><column name="code" property="Validation.Formula1" value="50" type="String" /><column name="code" property="Validation.AlertStyle" value="2" type="Double" /><column name="code" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="code" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="code" property="Validation.ShowInput" value="True" type="Boolean" /><column name="code" property="Validation.ShowError" value="True" type="Boolean" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="name" property="Address" value="$E$4" type="String" /><column name="name" property="ColumnWidth" value="27.86" type="Double" /><column name="name" property="NumberFormat" value="General" type="String" /><column name="name" property="Validation.Type" value="6" type="Double" /><column name="name" property="Validation.Operator" value="8" type="Double" /><column name="name" property="Validation.Formula1" value="255" type="String" /><column name="name" property="Validation.AlertStyle" value="2" type="Double" /><column name="name" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="name" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="name" property="Validation.ShowInput" value="True" type="Boolean" /><column name="name" property="Validation.ShowError" value="True" type="Boolean" /><column name="code" property="FormatConditions(1).AppliesTo.Address" value="$D$4:$D$5" type="String" /><column name="code" property="FormatConditions(1).Type" value="2" type="Double" /><column name="code" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="code" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String" /><column name="code" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="name" property="FormatConditions(1).AppliesTo.Address" value="$E$4:$E$5" type="String" /><column name="name" property="FormatConditions(1).Type" value="2" type="Double" /><column name="name" property="FormatConditions(1).Priority" value="2" type="Double" /><column name="name" property="FormatConditions(1).Formula1" value="=ISBLANK(E4)" type="String" /><column name="name" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's20', N'entity_users', N'<table name="s20.entity_users"><columnFormats><column name="" property="ListObjectName" value="Sheet1_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="entity_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="entity_id" property="Address" value="$C$4" type="String" /><column name="entity_id" property="ColumnWidth" value="10.57" type="Double" /><column name="entity_id" property="NumberFormat" value="General" type="String" /><column name="user_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="user_id" property="Address" value="$D$4" type="String" /><column name="user_id" property="ColumnWidth" value="19.29" type="Double" /><column name="user_id" property="NumberFormat" value="General" type="String" /><column name="permission" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="permission" property="Address" value="$E$4" type="String" /><column name="permission" property="ColumnWidth" value="12.43" type="Double" /><column name="permission" property="NumberFormat" value="General" type="String" /><column name="_State_" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_State_" property="Address" value="$F$4" type="String" /><column name="_State_" property="ColumnWidth" value="9.14" type="Double" /><column name="_State_" property="NumberFormat" value="General" type="String" /><column name="_State_" property="HorizontalAlignment" value="-4108" type="Double" /><column name="_State_" property="Font.Size" value="10" type="Double" /><column name="entity_id" property="FormatConditions(1).AppliesTo.Address" value="$C$4:$C$8" type="String" /><column name="entity_id" property="FormatConditions(1).Type" value="2" type="Double" /><column name="entity_id" property="FormatConditions(1).Priority" value="2" type="Double" /><column name="entity_id" property="FormatConditions(1).Formula1" value="=ISBLANK(C4)" type="String" /><column name="entity_id" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="user_id" property="FormatConditions(1).AppliesTo.Address" value="$D$4:$D$8" type="String" /><column name="user_id" property="FormatConditions(1).Type" value="2" type="Double" /><column name="user_id" property="FormatConditions(1).Priority" value="3" type="Double" /><column name="user_id" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String" /><column name="user_id" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="_State_" property="FormatConditions(1).AppliesTo.Address" value="$F$4:$F$8" type="String" /><column name="_State_" property="FormatConditions(1).Type" value="6" type="Double" /><column name="_State_" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="_State_" property="FormatConditions(1).ShowIconOnly" value="True" type="Boolean" /><column name="_State_" property="FormatConditions(1).IconSet.ID" value="8" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(1).Type" value="3" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(1).Operator" value="7" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(2).Type" value="0" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(2).Value" value="0.5" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(2).Operator" value="7" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(3).Type" value="0" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(3).Value" value="1" type="Double" /><column name="_State_" property="FormatConditions(1).IconCriteria(3).Operator" value="7" type="Double" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's20', N'facts', N'<table name="s20.facts"><columnFormats><column name="" property="ListObjectName" value="tables" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="2" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="Address" value="$D$4" type="String" /><column name="account_id" property="ColumnWidth" value="12.14" type="Double" /><column name="account_id" property="NumberFormat" value="General" type="String" /><column name="entity_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="entity_id" property="Address" value="$E$4" type="String" /><column name="entity_id" property="ColumnWidth" value="10.57" type="Double" /><column name="entity_id" property="NumberFormat" value="General" type="String" /><column name="category_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="category_id" property="Address" value="$F$4" type="String" /><column name="category_id" property="ColumnWidth" value="12.86" type="Double" /><column name="category_id" property="NumberFormat" value="General" type="String" /><column name="time_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="time_id" property="Address" value="$G$4" type="String" /><column name="time_id" property="ColumnWidth" value="9.43" type="Double" /><column name="time_id" property="NumberFormat" value="General" type="String" /><column name="value" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="value" property="Address" value="$H$4" type="String" /><column name="value" property="ColumnWidth" value="11.43" type="Double" /><column name="value" property="NumberFormat" value="#,##0" type="String" /><column name="value" property="Validation.Type" value="2" type="Double" /><column name="value" property="Validation.Operator" value="4" type="Double" /><column name="value" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="value" property="Validation.AlertStyle" value="2" type="Double" /><column name="value" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="value" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="value" property="Validation.ShowInput" value="True" type="Boolean" /><column name="value" property="Validation.ShowError" value="True" type="Boolean" /><column name="account_id" property="FormatConditions(1).AppliesTo.Address" value="$D$4:$D$483" type="String" /><column name="account_id" property="FormatConditions(1).Type" value="2" type="Double" /><column name="account_id" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="account_id" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String" /><column name="account_id" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="entity_id" property="FormatConditions(1).AppliesTo.Address" value="$E$4:$E$483" type="String" /><column name="entity_id" property="FormatConditions(1).Type" value="2" type="Double" /><column name="entity_id" property="FormatConditions(1).Priority" value="2" type="Double" /><column name="entity_id" property="FormatConditions(1).Formula1" value="=ISBLANK(E4)" type="String" /><column name="entity_id" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="category_id" property="FormatConditions(1).AppliesTo.Address" value="$F$4:$F$483" type="String" /><column name="category_id" property="FormatConditions(1).Type" value="2" type="Double" /><column name="category_id" property="FormatConditions(1).Priority" value="3" type="Double" /><column name="category_id" property="FormatConditions(1).Formula1" value="=ISBLANK(F4)" type="String" /><column name="category_id" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="time_id" property="FormatConditions(1).AppliesTo.Address" value="$G$4:$G$483" type="String" /><column name="time_id" property="FormatConditions(1).Type" value="2" type="Double" /><column name="time_id" property="FormatConditions(1).Priority" value="4" type="Double" /><column name="time_id" property="FormatConditions(1).Formula1" value="=ISBLANK(G4)" type="String" /><column name="time_id" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's20', N'permissions', N'<table name="s20.permissions"><columnFormats><column name="" property="ListObjectName" value="Sheet1_Table15" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="0" type="String" /><column name="id" property="Validation.Formula2" value="255" type="String" /><column name="id" property="Validation.AlertStyle" value="2" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="id" property="Validation.ErrorMessage" value="The column requires values of the tinyint datatype." type="String" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="code" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="code" property="Address" value="$D$4" type="String" /><column name="code" property="ColumnWidth" value="6.86" type="Double" /><column name="code" property="NumberFormat" value="General" type="String" /><column name="code" property="Validation.Type" value="6" type="Double" /><column name="code" property="Validation.Operator" value="8" type="Double" /><column name="code" property="Validation.Formula1" value="50" type="String" /><column name="code" property="Validation.AlertStyle" value="2" type="Double" /><column name="code" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="code" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="code" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="code" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(50) datatype." type="String" /><column name="code" property="Validation.ShowInput" value="True" type="Boolean" /><column name="code" property="Validation.ShowError" value="True" type="Boolean" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="name" property="Address" value="$E$4" type="String" /><column name="name" property="ColumnWidth" value="11.43" type="Double" /><column name="name" property="NumberFormat" value="General" type="String" /><column name="name" property="Validation.Type" value="6" type="Double" /><column name="name" property="Validation.Operator" value="8" type="Double" /><column name="name" property="Validation.Formula1" value="255" type="String" /><column name="name" property="Validation.AlertStyle" value="2" type="Double" /><column name="name" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="name" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="name" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="name" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(255) datatype." type="String" /><column name="name" property="Validation.ShowInput" value="True" type="Boolean" /><column name="name" property="Validation.ShowError" value="True" type="Boolean" /><column name="id" property="FormatConditions(1).AppliesTo.Address" value="$C$4:$C$6" type="String" /><column name="id" property="FormatConditions(1).Type" value="2" type="Double" /><column name="id" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="id" property="FormatConditions(1).Formula1" value="=ISBLANK(C4)" type="String" /><column name="id" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="code" property="FormatConditions(1).AppliesTo.Address" value="$D$4:$D$6" type="String" /><column name="code" property="FormatConditions(1).Type" value="2" type="Double" /><column name="code" property="FormatConditions(1).Priority" value="2" type="Double" /><column name="code" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String" /><column name="code" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="name" property="FormatConditions(1).AppliesTo.Address" value="$E$4:$E$6" type="String" /><column name="name" property="FormatConditions(1).Type" value="2" type="Double" /><column name="name" property="FormatConditions(1).Priority" value="3" type="Double" /><column name="name" property="FormatConditions(1).Formula1" value="=ISBLANK(E4)" type="String" /><column name="name" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's20', N'times', N'<table name="s20.times"><columnFormats><column name="" property="ListObjectName" value="tables" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="2" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="code" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="code" property="Address" value="$D$4" type="String" /><column name="code" property="ColumnWidth" value="13.57" type="Double" /><column name="code" property="NumberFormat" value="General" type="String" /><column name="code" property="Validation.Type" value="6" type="Double" /><column name="code" property="Validation.Operator" value="8" type="Double" /><column name="code" property="Validation.Formula1" value="50" type="String" /><column name="code" property="Validation.AlertStyle" value="2" type="Double" /><column name="code" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="code" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="code" property="Validation.ShowInput" value="True" type="Boolean" /><column name="code" property="Validation.ShowError" value="True" type="Boolean" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="name" property="Address" value="$E$4" type="String" /><column name="name" property="ColumnWidth" value="27.86" type="Double" /><column name="name" property="NumberFormat" value="General" type="String" /><column name="name" property="Validation.Type" value="6" type="Double" /><column name="name" property="Validation.Operator" value="8" type="Double" /><column name="name" property="Validation.Formula1" value="255" type="String" /><column name="name" property="Validation.AlertStyle" value="2" type="Double" /><column name="name" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="name" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="name" property="Validation.ShowInput" value="True" type="Boolean" /><column name="name" property="Validation.ShowError" value="True" type="Boolean" /><column name="year" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="year" property="Address" value="$F$4" type="String" /><column name="year" property="ColumnWidth" value="6.43" type="Double" /><column name="year" property="NumberFormat" value="General" type="String" /><column name="year" property="Validation.Type" value="1" type="Double" /><column name="year" property="Validation.Operator" value="1" type="Double" /><column name="year" property="Validation.Formula1" value="-2147483648" type="String" /><column name="year" property="Validation.Formula2" value="2147483647" type="String" /><column name="year" property="Validation.AlertStyle" value="2" type="Double" /><column name="year" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="year" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="year" property="Validation.ShowInput" value="True" type="Boolean" /><column name="year" property="Validation.ShowError" value="True" type="Boolean" /><column name="column_name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="column_name" property="Address" value="$G$4" type="String" /><column name="column_name" property="ColumnWidth" value="15.29" type="Double" /><column name="column_name" property="NumberFormat" value="@" type="String" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's20', N'users', N'<table name="s20.users"><columnFormats><column name="" property="ListObjectName" value="Sheet1_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="2" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="username" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="username" property="Address" value="$D$4" type="String" /><column name="username" property="ColumnWidth" value="27.86" type="Double" /><column name="username" property="NumberFormat" value="General" type="String" /><column name="username" property="Validation.Type" value="6" type="Double" /><column name="username" property="Validation.Operator" value="8" type="Double" /><column name="username" property="Validation.Formula1" value="255" type="String" /><column name="username" property="Validation.AlertStyle" value="2" type="Double" /><column name="username" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="username" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="username" property="Validation.ShowInput" value="True" type="Boolean" /><column name="username" property="Validation.ShowError" value="True" type="Boolean" /><column name="username" property="FormatConditions(1).AppliesTo.Address" value="$D$4:$D$6" type="String" /><column name="username" property="FormatConditions(1).Type" value="2" type="Double" /><column name="username" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="username" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String" /><column name="username" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's20', N'usp_form_01', N'<table name="s20.usp_form_01"><columnFormats><column name="" property="ListObjectName" value="tables" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="2" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="code" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="code" property="Address" value="$D$4" type="String" /><column name="code" property="ColumnWidth" value="6.86" type="Double" /><column name="code" property="NumberFormat" value="General" type="String" /><column name="code" property="Validation.Type" value="6" type="Double" /><column name="code" property="Validation.Operator" value="8" type="Double" /><column name="code" property="Validation.Formula1" value="50" type="String" /><column name="code" property="Validation.AlertStyle" value="2" type="Double" /><column name="code" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="code" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="code" property="Validation.ShowInput" value="True" type="Boolean" /><column name="code" property="Validation.ShowError" value="True" type="Boolean" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="name" property="Address" value="$E$4" type="String" /><column name="name" property="ColumnWidth" value="18.29" type="Double" /><column name="name" property="NumberFormat" value="General" type="String" /><column name="name" property="Validation.Type" value="6" type="Double" /><column name="name" property="Validation.Operator" value="8" type="Double" /><column name="name" property="Validation.Formula1" value="255" type="String" /><column name="name" property="Validation.AlertStyle" value="2" type="Double" /><column name="name" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="name" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="name" property="Validation.ShowInput" value="True" type="Boolean" /><column name="name" property="Validation.ShowError" value="True" type="Boolean" /><column name="01" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="01" property="Address" value="$F$4" type="String" /><column name="01" property="ColumnWidth" value="12.86" type="Double" /><column name="01" property="NumberFormat" value="#,##0" type="String" /><column name="02" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="02" property="Address" value="$G$4" type="String" /><column name="02" property="ColumnWidth" value="12.86" type="Double" /><column name="02" property="NumberFormat" value="#,##0" type="String" /><column name="03" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="03" property="Address" value="$H$4" type="String" /><column name="03" property="ColumnWidth" value="12.86" type="Double" /><column name="03" property="NumberFormat" value="#,##0" type="String" /><column name="04" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="04" property="Address" value="$I$4" type="String" /><column name="04" property="ColumnWidth" value="12.86" type="Double" /><column name="04" property="NumberFormat" value="#,##0" type="String" /><column name="05" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="05" property="Address" value="$J$4" type="String" /><column name="05" property="ColumnWidth" value="12.86" type="Double" /><column name="05" property="NumberFormat" value="#,##0" type="String" /><column name="06" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="06" property="Address" value="$K$4" type="String" /><column name="06" property="ColumnWidth" value="12.86" type="Double" /><column name="06" property="NumberFormat" value="#,##0" type="String" /><column name="07" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="07" property="Address" value="$L$4" type="String" /><column name="07" property="ColumnWidth" value="12.86" type="Double" /><column name="07" property="NumberFormat" value="#,##0" type="String" /><column name="08" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="08" property="Address" value="$M$4" type="String" /><column name="08" property="ColumnWidth" value="12.86" type="Double" /><column name="08" property="NumberFormat" value="#,##0" type="String" /><column name="09" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="09" property="Address" value="$N$4" type="String" /><column name="09" property="ColumnWidth" value="12.86" type="Double" /><column name="09" property="NumberFormat" value="#,##0" type="String" /><column name="10" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="10" property="Address" value="$O$4" type="String" /><column name="10" property="ColumnWidth" value="12.86" type="Double" /><column name="10" property="NumberFormat" value="#,##0" type="String" /><column name="11" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="11" property="Address" value="$P$4" type="String" /><column name="11" property="ColumnWidth" value="12.86" type="Double" /><column name="11" property="NumberFormat" value="#,##0" type="String" /><column name="12" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="12" property="Address" value="$Q$4" type="String" /><column name="12" property="ColumnWidth" value="12.86" type="Double" /><column name="12" property="NumberFormat" value="#,##0" type="String" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's20', N'usp_web_category_times', N'<table name="s20.usp_web_category_times"><columnFormats><column name="" property="ListObjectName" value="tables" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="time_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="time_id" property="Address" value="$C$4" type="String" /><column name="time_id" property="ColumnWidth" value="9.29" type="Double" /><column name="time_id" property="NumberFormat" value="General" type="String" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="name" property="Address" value="$D$4" type="String" /><column name="name" property="ColumnWidth" value="13.57" type="Double" /><column name="name" property="NumberFormat" value="General" type="String" /><column name="Budget" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Budget" property="Address" value="$E$4" type="String" /><column name="Budget" property="ColumnWidth" value="11.43" type="Double" /><column name="Budget" property="NumberFormat" value="General" type="String" /><column name="Budget" property="HorizontalAlignment" value="-4108" type="Double" /><column name="Actual" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Actual" property="Address" value="$F$4" type="String" /><column name="Actual" property="ColumnWidth" value="11.43" type="Double" /><column name="Actual" property="NumberFormat" value="General" type="String" /><column name="Actual" property="HorizontalAlignment" value="-4108" type="Double" /><column name="Forecast" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Forecast" property="Address" value="$G$4" type="String" /><column name="Forecast" property="ColumnWidth" value="11.43" type="Double" /><column name="Forecast" property="NumberFormat" value="General" type="String" /><column name="Forecast" property="HorizontalAlignment" value="-4108" type="Double" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's20', N'usp_web_category_users', N'<table name="s20.usp_web_category_users"><columnFormats><column name="" property="ListObjectName" value="tables" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="user_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="user_id" property="Address" value="$C$4" type="String" /><column name="user_id" property="ColumnWidth" value="9.29" type="Double" /><column name="user_id" property="NumberFormat" value="General" type="String" /><column name="username" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="username" property="Address" value="$D$4" type="String" /><column name="username" property="ColumnWidth" value="20.71" type="Double" /><column name="username" property="NumberFormat" value="General" type="String" /><column name="Budget" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Budget" property="Address" value="$E$4" type="String" /><column name="Budget" property="ColumnWidth" value="11.43" type="Double" /><column name="Budget" property="NumberFormat" value="General" type="String" /><column name="Budget" property="HorizontalAlignment" value="-4108" type="Double" /><column name="Actual" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Actual" property="Address" value="$F$4" type="String" /><column name="Actual" property="ColumnWidth" value="11.43" type="Double" /><column name="Actual" property="NumberFormat" value="General" type="String" /><column name="Actual" property="HorizontalAlignment" value="-4108" type="Double" /><column name="Forecast" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Forecast" property="Address" value="$G$4" type="String" /><column name="Forecast" property="ColumnWidth" value="11.43" type="Double" /><column name="Forecast" property="NumberFormat" value="General" type="String" /><column name="Forecast" property="HorizontalAlignment" value="-4108" type="Double" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's20', N'usp_web_entity_users', N'<table name="s20.usp_web_entity_users"><columnFormats><column name="" property="ListObjectName" value="Sheet1_Table1" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="user_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="user_id" property="Address" value="$C$4" type="String" /><column name="user_id" property="ColumnWidth" value="9.29" type="Double" /><column name="user_id" property="NumberFormat" value="General" type="String" /><column name="username" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="username" property="Address" value="$D$4" type="String" /><column name="username" property="ColumnWidth" value="20.71" type="Double" /><column name="username" property="NumberFormat" value="General" type="String" /><column name="Plant 01" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Plant 01" property="Address" value="$E$4" type="String" /><column name="Plant 01" property="ColumnWidth" value="11.43" type="Double" /><column name="Plant 01" property="NumberFormat" value="General" type="String" /><column name="Plant 01" property="HorizontalAlignment" value="-4108" type="Double" /><column name="Plant 02" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Plant 02" property="Address" value="$F$4" type="String" /><column name="Plant 02" property="ColumnWidth" value="11.43" type="Double" /><column name="Plant 02" property="NumberFormat" value="General" type="String" /><column name="Plant 02" property="HorizontalAlignment" value="-4108" type="Double" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's20', N'usp_web_form_01', N'<table name="s20.usp_web_form_01"><columnFormats><column name="" property="ListObjectName" value="tables" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium2" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="ColumnWidth" value="0.08" type="Double" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="account_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_id" property="Address" value="$C$4" type="String" /><column name="account_id" property="ColumnWidth" value="12" type="Double" /><column name="account_id" property="NumberFormat" value="General" type="String" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="name" property="Address" value="$D$4" type="String" /><column name="name" property="ColumnWidth" value="20.71" type="Double" /><column name="name" property="NumberFormat" value="General" type="String" /><column name="01" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="01" property="Address" value="$E$4" type="String" /><column name="01" property="ColumnWidth" value="10.71" type="Double" /><column name="01" property="NumberFormat" value="#,##0" type="String" /><column name="02" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="02" property="Address" value="$F$4" type="String" /><column name="02" property="ColumnWidth" value="10.71" type="Double" /><column name="02" property="NumberFormat" value="#,##0" type="String" /><column name="03" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="03" property="Address" value="$G$4" type="String" /><column name="03" property="ColumnWidth" value="10.71" type="Double" /><column name="03" property="NumberFormat" value="#,##0" type="String" /><column name="04" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="04" property="Address" value="$H$4" type="String" /><column name="04" property="ColumnWidth" value="10.71" type="Double" /><column name="04" property="NumberFormat" value="#,##0" type="String" /><column name="05" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="05" property="Address" value="$I$4" type="String" /><column name="05" property="ColumnWidth" value="10.71" type="Double" /><column name="05" property="NumberFormat" value="#,##0" type="String" /><column name="06" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="06" property="Address" value="$J$4" type="String" /><column name="06" property="ColumnWidth" value="10.71" type="Double" /><column name="06" property="NumberFormat" value="#,##0" type="String" /><column name="07" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="07" property="Address" value="$K$4" type="String" /><column name="07" property="ColumnWidth" value="10.71" type="Double" /><column name="07" property="NumberFormat" value="#,##0" type="String" /><column name="08" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="08" property="Address" value="$L$4" type="String" /><column name="08" property="ColumnWidth" value="10.71" type="Double" /><column name="08" property="NumberFormat" value="#,##0" type="String" /><column name="09" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="09" property="Address" value="$M$4" type="String" /><column name="09" property="ColumnWidth" value="10.71" type="Double" /><column name="09" property="NumberFormat" value="#,##0" type="String" /><column name="10" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="10" property="Address" value="$N$4" type="String" /><column name="10" property="ColumnWidth" value="10.71" type="Double" /><column name="10" property="NumberFormat" value="#,##0" type="String" /><column name="11" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="11" property="Address" value="$O$4" type="String" /><column name="11" property="ColumnWidth" value="10.71" type="Double" /><column name="11" property="NumberFormat" value="#,##0" type="String" /><column name="12" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="12" property="Address" value="$P$4" type="String" /><column name="12" property="ColumnWidth" value="10.71" type="Double" /><column name="12" property="NumberFormat" value="#,##0" type="String" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
GO

INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's20', N'comments', NULL, N'DoNotAddValidation', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's20', N'facts', NULL, N'DoNotAddValidation', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's20', N'usp_form_01', NULL, N'DoNotSave', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's20', N'usp_form_01', NULL, N'DoNotSort', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's20', N'usp_web_form_01', NULL, N'DoNotSort', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's20', N'usp_web_category_times', NULL, N'JsonForm', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's20', N'usp_web_category_users', NULL, N'JsonForm', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's20', N'usp_web_entity_users', NULL, N'JsonForm', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's20', N'usp_web_form_01', NULL, N'JsonForm', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's20', N'usp_form_01', N'category_id', N'ParameterValues', N's20', N'xl_list_category_id', N'VIEW', NULL, N'_NotNull', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's20', N'usp_form_01', N'entity_id', N'ParameterValues', N's20', N'xl_list_entity_id', N'VIEW', NULL, N'_NotNull', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's20', N'usp_form_01', N'year', N'ParameterValues', NULL, NULL, N'VALUES', N'2022,2023', N'_NotNull', NULL, NULL);
GO

print 'Application installed';
