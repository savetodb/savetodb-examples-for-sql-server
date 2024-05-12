-- =============================================
-- Application: Sample 14 - Dynamic Columns
-- Version 10.13, April 29, 2024
--
-- Copyright 2019-2024 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON
GO

CREATE SCHEMA s14;
GO

CREATE TABLE s14.clients (
    id int IDENTITY(1,1) NOT NULL
    , name nvarchar(50) NOT NULL
    , CONSTRAINT PK_clients PRIMARY KEY (id)
    , CONSTRAINT IX_clients UNIQUE (name)
);
GO

CREATE TABLE s14.dimensions (
    id int NOT NULL
    , name nvarchar(50) NOT NULL
    , CONSTRAINT PK_dimensions PRIMARY KEY (id)
    , CONSTRAINT IX_dimensions UNIQUE (name)
);
GO

CREATE TABLE s14.aliases (
    id int IDENTITY(1,1) NOT NULL
    , client_id int NULL
    , table_name nvarchar(128) NULL
    , column_name nvarchar(128) NULL
    , alias nvarchar(128) NULL
    , is_active bit NULL
    , is_selected bit NULL
    , sort_order int NULL
    , CONSTRAINT PK_aliases PRIMARY KEY (id)
    , CONSTRAINT IX_aliases UNIQUE (client_id, table_name, column_name)
);
GO

ALTER TABLE s14.aliases ADD CONSTRAINT FK_aliases_clients FOREIGN KEY (client_id) REFERENCES s14.clients (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

CREATE TABLE s14.members (
    id int IDENTITY(1,1) NOT NULL
    , client_id int NOT NULL
    , dimension_id int NOT NULL
    , name nvarchar(50) NOT NULL
    , string1 nvarchar(50) NULL
    , string2 nvarchar(50) NULL
    , int1 int NULL
    , int2 int NULL
    , float1 float NULL
    , float2 float NULL
    , CONSTRAINT PK_members PRIMARY KEY (id)
);
GO

ALTER TABLE s14.members ADD CONSTRAINT FK_members_clients FOREIGN KEY (client_id) REFERENCES s14.clients (id) ON UPDATE CASCADE;
GO

ALTER TABLE s14.members ADD CONSTRAINT FK_members_dimensions FOREIGN KEY (dimension_id) REFERENCES s14.dimensions (id) ON UPDATE CASCADE;
GO

CREATE TABLE s14.user_clients (
    user_name nvarchar(128) NOT NULL
    , client_id int NOT NULL
    , CONSTRAINT PK_user_clients PRIMARY KEY (user_name, client_id)
);
GO

ALTER TABLE s14.user_clients ADD CONSTRAINT FK_user_clients_clients FOREIGN KEY (client_id) REFERENCES s14.clients (id);
GO

CREATE TABLE s14.data (
    id int IDENTITY(1,1) NOT NULL
    , client_id int NULL
    , id1 int NULL
    , id2 int NULL
    , id3 int NULL
    , string1 nvarchar(50) NULL
    , string2 nvarchar(50) NULL
    , int1 int NULL
    , int2 int NULL
    , float1 float NULL
    , float2 float NULL
    , CONSTRAINT PK_data PRIMARY KEY (id)
);
GO

ALTER TABLE s14.data ADD CONSTRAINT FK_data_clients FOREIGN KEY (client_id) REFERENCES s14.clients (id) ON UPDATE CASCADE;
GO

ALTER TABLE s14.data ADD CONSTRAINT FK_data_members_id1 FOREIGN KEY (id1) REFERENCES s14.members (id);
GO

ALTER TABLE s14.data ADD CONSTRAINT FK_data_members_id2 FOREIGN KEY (id2) REFERENCES s14.members (id);
GO

ALTER TABLE s14.data ADD CONSTRAINT FK_data_members_id3 FOREIGN KEY (id3) REFERENCES s14.members (id);
GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Aliases
-- =============================================

CREATE VIEW [s14].[view_aliases]
AS

SELECT
    a.client_id
    , a.table_name
    , a.column_name
    , a.alias
    , a.is_active
    , a.is_selected
    , a.sort_order
FROM
    s14.aliases a
    INNER JOIN s14.user_clients uc ON uc.client_id = a.client_id AND uc.user_name = USER_NAME()


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Data
-- =============================================

CREATE VIEW [s14].[view_data]
AS

SELECT
    d.id
    , d.client_id
    , d.id1
    , d.id2
    , d.id3
    , d.string1
    , d.string2
    , d.int1
    , d.int2
    , d.float1
    , d.float2
FROM
    s14.data d
    INNER JOIN s14.user_clients uc ON uc.client_id = d.client_id AND uc.user_name = USER_NAME()


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Members
-- =============================================

CREATE VIEW [s14].[view_members]
AS

SELECT
    d.id
    , d.client_id
    , d.dimension_id
    , d.name
    , d.string1
    , d.string2
    , d.int1
    , d.int2
    , d.float1
    , d.float2
FROM
    s14.members d
    INNER JOIN s14.user_clients uc ON uc.client_id = d.client_id AND uc.user_name = USER_NAME()


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Clients
-- =============================================

CREATE VIEW [s14].[xl_list_client_id]
AS

SELECT
    c.id
    , c.name
FROM
    s14.clients c
WHERE
    c.id IN (SELECT client_id FROM s14.user_clients WHERE user_name = USER_NAME())


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure deleted data from s14.data
-- =============================================

CREATE PROCEDURE [s14].[view_data_delete]
    @id int
AS
BEGIN

DELETE FROM s14.data
WHERE
    id = @id
    AND client_id IN (SELECT client_id FROM s14.user_clients WHERE user_name = USER_NAME())

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure inserts data into s14.data
-- =============================================

CREATE PROCEDURE [s14].[view_data_insert]
    @client_id int = NULL
    , @id1 int = NULL
    , @id2 int = NULL
    , @id3 int = NULL
    , @string1 nvarchar(50) = NULL
    , @string2 nvarchar(50) = NULL
    , @int1 int = NULL
    , @int2 int = NULL
    , @float1 float = NULL
    , @float2 float = NULL
AS
BEGIN

SET NOCOUNT ON

IF (SELECT client_id FROM s14.user_clients WHERE client_id = @client_id AND user_name = USER_NAME()) IS NULL
    RETURN

SET NOCOUNT OFF

INSERT INTO s14.data
    ( client_id
    , id1
    , id2
    , id3
    , string1
    , string2
    , int1
    , int2
    , float1
    , float2
    )
VALUES
    ( @client_id
    , @id1
    , @id2
    , @id3
    , @string1
    , @string2
    , @int1
    , @int2
    , @float1
    , @float2
    )

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure updates data of s14.data
-- =============================================

CREATE PROCEDURE [s14].[view_data_update]
    @id int
    , @client_id int = NULL
    , @id1 int = NULL
    , @id2 int = NULL
    , @id3 int = NULL
    , @string1 nvarchar(50) = NULL
    , @string2 nvarchar(50) = NULL
    , @int1 int = NULL
    , @int2 int = NULL
    , @float1 float = NULL
    , @float2 float = NULL
AS
BEGIN

UPDATE s14.data
SET
    id1 = @id1
    , id2 = @id2
    , id3 = @id3
    , string1 = @string1
    , string2 = @string2
    , int1 = @int1
    , int2 = @int2
    , float1 = @float1
    , float2 = @float2
WHERE
    id = @id
    AND client_id = @client_id
    AND client_id IN (SELECT client_id FROM s14.user_clients WHERE user_name = USER_NAME())

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure deleted data from s14.view_members
-- =============================================

CREATE PROCEDURE [s14].[view_members_delete]
    @id int
AS
BEGIN

DELETE FROM [s14].[members]
WHERE
    id = @id
    AND client_id IN (SELECT client_id FROM s14.user_clients WHERE user_name = USER_NAME())

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure inserts data into s14.view_members
-- =============================================

CREATE PROCEDURE [s14].[view_members_insert]
    @client_id int
    , @dimension_id int
    , @name nvarchar(50) = NULL
    , @string1 nvarchar(50) = NULL
    , @string2 nvarchar(50) = NULL
    , @int1 int = NULL
    , @int2 int = NULL
    , @float1 float = NULL
    , @float2 float = NULL
AS
BEGIN

SET NOCOUNT ON

IF (SELECT client_id FROM s14.user_clients WHERE client_id = @client_id AND user_name = USER_NAME()) IS NULL
    RETURN

SET NOCOUNT OFF

INSERT INTO [s14].[members]
    ( client_id
    , dimension_id
    , name
    , string1
    , string2
    , int1
    , int2
    , float1
    , float2
    )
VALUES
    ( @client_id
    , @dimension_id
    , @name
    , @string1
    , @string2
    , @int1
    , @int2
    , @float1
    , @float2
    )

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: The procedure updates data of s14.view_members
-- =============================================

CREATE PROCEDURE [s14].[view_members_update]
    @id int
    , @client_id int
    , @dimension_id int
    , @name nvarchar(50) = NULL
    , @string1 nvarchar(50) = NULL
    , @string2 nvarchar(50) = NULL
    , @int1 int = NULL
    , @int2 int = NULL
    , @float1 float = NULL
    , @float2 float = NULL
AS
BEGIN

UPDATE [s14].[members]
SET
    dimension_id = @dimension_id
    , name = @name
    , string1 = @string1
    , string2 = @string2
    , int1 = @int1
    , int2 = @int2
    , float1 = @float1
    , float2 = @float2
WHERE
    id = @id
    AND client_id = @client_id
    AND client_id IN (SELECT client_id FROM s14.user_clients WHERE user_name = USER_NAME())

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Validation list of member_id
-- =============================================

CREATE PROCEDURE [s14].[xl_list_member_id]
    @dimension_id int = NULL
    , @client_id int = NULL
AS
BEGIN

SET NOCOUNT ON

SELECT
    m.id
    , m.name
    , m.client_id
FROM
    s14.members m
    INNER JOIN s14.user_clients uc ON uc.client_id = m.client_id AND uc.user_name = USER_NAME()
WHERE
    m.dimension_id = @dimension_id
    AND m.client_id = COALESCE(@client_id, m.client_id)
ORDER BY
    m.name

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Validation list of member_id
-- =============================================

CREATE PROCEDURE [s14].[xl_list_member_id1]
    @client_id int = NULL
AS
BEGIN

EXEC s14.xl_list_member_id 1, @client_id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Validation list of member_id
-- =============================================

CREATE PROCEDURE [s14].[xl_list_member_id2]
    @client_id int = NULL
AS
BEGIN

EXEC s14.xl_list_member_id 2, @client_id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Validation list of member_id
-- =============================================

CREATE PROCEDURE [s14].[xl_list_member_id3]
    @client_id int = NULL
AS
BEGIN

EXEC s14.xl_list_member_id 3, @client_id

END


GO

SET IDENTITY_INSERT s14.clients ON;
INSERT INTO s14.clients (id, name) VALUES (1, N'Client 1');
INSERT INTO s14.clients (id, name) VALUES (2, N'Client 2');
SET IDENTITY_INSERT s14.clients OFF;
GO

INSERT INTO s14.dimensions (id, name) VALUES (1, N'Dim1');
INSERT INTO s14.dimensions (id, name) VALUES (2, N'Dim2');
INSERT INTO s14.dimensions (id, name) VALUES (3, N'Dim3');
GO

SET IDENTITY_INSERT s14.aliases ON;
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (1, 1, N's14.data', N'string1', N'product', 1, 1, 4);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (2, 1, N's14.data', N'id1', N'state', 1, 1, 3);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (3, 1, N's14.data', N'float1', N'sales', 1, 1, 5);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (4, 2, N's14.data', N'string1', N'region', 1, 1, 3);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (5, 2, N's14.data', N'string2', N'manager', 1, 1, 4);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (6, 2, N's14.data', N'float1', N'sales', 1, 1, 5);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (9, 1, N's14.members', N'string1', N'country', NULL, NULL, NULL);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (10, 1, N's14.members', N'string2', N'state', NULL, NULL, NULL);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (11, 1, N's14.data', N'string2', NULL, 0, 0, NULL);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (12, 1, N's14.data', N'id2', NULL, 0, 0, NULL);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (13, 1, N's14.data', N'id3', NULL, 0, 0, NULL);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (14, 1, N's14.data', N'int1', NULL, 0, 0, NULL);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (15, 1, N's14.data', N'int2', NULL, 0, 0, NULL);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (16, 1, N's14.data', N'float2', NULL, 0, 0, NULL);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (17, 2, N's14.data', N'float2', NULL, 0, 0, NULL);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (18, 2, N's14.data', N'id1', NULL, 0, 0, NULL);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (19, 2, N's14.data', N'id2', NULL, 0, 0, NULL);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (20, 2, N's14.data', N'id3', NULL, 0, 0, NULL);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (21, 2, N's14.data', N'int1', NULL, 0, 0, NULL);
INSERT INTO s14.aliases (id, client_id, table_name, column_name, alias, is_active, is_selected, sort_order) VALUES (22, 2, N's14.data', N'int2', NULL, 0, 0, NULL);
SET IDENTITY_INSERT s14.aliases OFF;
GO

SET IDENTITY_INSERT s14.members ON;
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (1, 1, 1, N'AK', N'USA', N'Alaska', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (2, 1, 1, N'AL', N'USA', N'Alabama', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (3, 1, 1, N'AR', N'USA', N'Arkansas', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (4, 1, 1, N'AZ', N'USA', N'Arizona', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (5, 1, 1, N'CA', N'USA', N'California', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (6, 1, 1, N'CO', N'USA', N'Colorado', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (7, 1, 1, N'CT', N'USA', N'Connecticut', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (8, 1, 1, N'DE', N'USA', N'Delaware', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (9, 1, 1, N'FL', N'USA', N'Florida', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (10, 1, 1, N'GA', N'USA', N'Georgia', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (11, 1, 1, N'HI', N'USA', N'Hawaii', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (12, 1, 1, N'IA', N'USA', N'Iowa', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (13, 1, 1, N'ID', N'USA', N'Idaho', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (14, 1, 1, N'IL', N'USA', N'Illinois', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (15, 1, 1, N'IN', N'USA', N'Indiana', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (16, 1, 1, N'KS', N'USA', N'Kansas', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (17, 1, 1, N'KY', N'USA', N'Kentucky', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (18, 1, 1, N'LA', N'USA', N'Louisiana', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (19, 1, 1, N'MA', N'USA', N'Massachusetts', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (20, 1, 1, N'MD', N'USA', N'Maryland', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (21, 1, 1, N'ME', N'USA', N'Maine', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (22, 1, 1, N'MI', N'USA', N'Michigan', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (23, 1, 1, N'MN', N'USA', N'Minnesota', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (24, 1, 1, N'MO', N'USA', N'Missouri', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (25, 1, 1, N'MS', N'USA', N'Mississippi', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (26, 1, 1, N'MT', N'USA', N'Montana', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (27, 1, 1, N'NC', N'USA', N'North Carolina', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (28, 1, 1, N'ND', N'USA', N'North Dakota', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (29, 1, 1, N'NE', N'USA', N'Nebraska', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (30, 1, 1, N'NH', N'USA', N'New Hampshire', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (31, 1, 1, N'NJ', N'USA', N'New Jersey', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (32, 1, 1, N'NM', N'USA', N'New Mexico', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (33, 1, 1, N'NV', N'USA', N'Nevada', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (34, 1, 1, N'NY', N'USA', N'New York', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (35, 1, 1, N'OH', N'USA', N'Ohio', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (36, 1, 1, N'OK', N'USA', N'Oklahoma', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (37, 1, 1, N'OR', N'USA', N'Oregon', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (38, 1, 1, N'PA', N'USA', N'Pennsylvania', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (39, 1, 1, N'RI', N'USA', N'Rhode Island', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (40, 1, 1, N'SC', N'USA', N'South Carolina', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (41, 1, 1, N'SD', N'USA', N'South Dakota', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (42, 1, 1, N'TN', N'USA', N'Tennessee', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (43, 1, 1, N'TX', N'USA', N'Texas', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (44, 1, 1, N'UT', N'USA', N'Utah', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (45, 1, 1, N'VA', N'USA', N'Virginia', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (46, 1, 1, N'VT', N'USA', N'Vermont', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (47, 1, 1, N'WA', N'USA', N'Washington', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (48, 1, 1, N'WI', N'USA', N'Wisconsin', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (49, 1, 1, N'WV', N'USA', N'West Virginia', NULL, NULL, NULL, NULL);
INSERT INTO s14.members (id, client_id, dimension_id, name, string1, string2, int1, int2, float1, float2) VALUES (50, 1, 1, N'WY', N'USA', N'Wyoming', NULL, NULL, NULL, NULL);
SET IDENTITY_INSERT s14.members OFF;
GO

INSERT INTO s14.user_clients (user_name, client_id) VALUES (N'dbo', 1);
INSERT INTO s14.user_clients (user_name, client_id) VALUES (N'dbo', 2);
INSERT INTO s14.user_clients (user_name, client_id) VALUES (N'sample14_user1', 1);
INSERT INTO s14.user_clients (user_name, client_id) VALUES (N'sample14_user1', 2);
INSERT INTO s14.user_clients (user_name, client_id) VALUES (N'sample14_user2', 1);
INSERT INTO s14.user_clients (user_name, client_id) VALUES (N'sample14_user3', 2);
GO

SET IDENTITY_INSERT s14.data ON;
INSERT INTO s14.data (id, client_id, id1, id2, id3, string1, string2, int1, int2, float1, float2) VALUES (1, 1, 2, NULL, NULL, N'Product 1', NULL, NULL, NULL, 1000, NULL);
INSERT INTO s14.data (id, client_id, id1, id2, id3, string1, string2, int1, int2, float1, float2) VALUES (2, 1, 2, NULL, NULL, N'Product 2', NULL, NULL, NULL, 2000, NULL);
INSERT INTO s14.data (id, client_id, id1, id2, id3, string1, string2, int1, int2, float1, float2) VALUES (3, 2, NULL, NULL, NULL, N'USA', N'Smith', NULL, NULL, 2000, NULL);
INSERT INTO s14.data (id, client_id, id1, id2, id3, string1, string2, int1, int2, float1, float2) VALUES (4, 2, NULL, NULL, NULL, N'Canada', N'Smith', NULL, NULL, 1000, NULL);
SET IDENTITY_INSERT s14.data OFF;
GO

INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's14', N'view_aliases', N'<table name="s14.view_aliases"><columnFormats><column name="" property="ListObjectName" value="aliases" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="client_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="client_id" property="Address" value="$C$4" type="String" /><column name="client_id" property="ColumnWidth" value="10.29" type="Double" /><column name="client_id" property="NumberFormat" value="General" type="String" /><column name="table_name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="table_name" property="Address" value="$D$4" type="String" /><column name="table_name" property="ColumnWidth" value="13.57" type="Double" /><column name="table_name" property="NumberFormat" value="General" type="String" /><column name="column_name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="column_name" property="Address" value="$E$4" type="String" /><column name="column_name" property="ColumnWidth" value="15.29" type="Double" /><column name="column_name" property="NumberFormat" value="General" type="String" /><column name="alias" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="alias" property="Address" value="$F$4" type="String" /><column name="alias" property="ColumnWidth" value="12.14" type="Double" /><column name="alias" property="NumberFormat" value="General" type="String" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="2" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's14', N'view_data', N'<table name="s14.view_data"><columnFormats><column name="" property="ListObjectName" value="view_data" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="id" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="client_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="client_id" property="Address" value="$D$4" type="String" /><column name="client_id" property="ColumnWidth" value="12.14" type="Double" /><column name="client_id" property="NumberFormat" value="General" type="String" /><column name="client_id" property="Validation.Type" value="3" type="Double" /><column name="client_id" property="Validation.Operator" value="1" type="Double" /><column name="client_id" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s14_xl_list_client_id[name]&quot;)" type="String" /><column name="client_id" property="Validation.AlertStyle" value="1" type="Double" /><column name="client_id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="client_id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="client_id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="client_id" property="Validation.ShowError" value="True" type="Boolean" /><column name="id1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id1" property="Address" value="$E$4" type="String" /><column name="id1" property="ColumnWidth" value="12.14" type="Double" /><column name="id1" property="NumberFormat" value="General" type="String" /><column name="id1" property="Validation.Type" value="3" type="Double" /><column name="id1" property="Validation.Operator" value="1" type="Double" /><column name="id1" property="Validation.Formula1" value="=vl_d1_view_data" type="String" /><column name="id1" property="Validation.AlertStyle" value="1" type="Double" /><column name="id1" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id1" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id1" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id1" property="Validation.ShowError" value="True" type="Boolean" /><column name="id2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id2" property="Address" value="$F$4" type="String" /><column name="id2" property="NumberFormat" value="General" type="String" /><column name="id3" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id3" property="Address" value="$G$4" type="String" /><column name="id3" property="NumberFormat" value="General" type="String" /><column name="string1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="string1" property="Address" value="$H$4" type="String" /><column name="string1" property="ColumnWidth" value="12.14" type="Double" /><column name="string1" property="NumberFormat" value="General" type="String" /><column name="string1" property="Validation.Type" value="6" type="Double" /><column name="string1" property="Validation.Operator" value="8" type="Double" /><column name="string1" property="Validation.Formula1" value="50" type="String" /><column name="string1" property="Validation.AlertStyle" value="1" type="Double" /><column name="string1" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="string1" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="string1" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="string1" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(50) datatype." type="String" /><column name="string1" property="Validation.ShowInput" value="True" type="Boolean" /><column name="string1" property="Validation.ShowError" value="True" type="Boolean" /><column name="string2" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="string2" property="Address" value="$I$4" type="String" /><column name="string2" property="ColumnWidth" value="12.14" type="Double" /><column name="string2" property="NumberFormat" value="General" type="String" /><column name="string2" property="Validation.Type" value="6" type="Double" /><column name="string2" property="Validation.Operator" value="8" type="Double" /><column name="string2" property="Validation.Formula1" value="50" type="String" /><column name="string2" property="Validation.AlertStyle" value="1" type="Double" /><column name="string2" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="string2" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="string2" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="string2" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(50) datatype." type="String" /><column name="string2" property="Validation.ShowInput" value="True" type="Boolean" /><column name="string2" property="Validation.ShowError" value="True" type="Boolean" /><column name="int1" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="int1" property="Address" value="$J$4" type="String" /><column name="int1" property="NumberFormat" value="#,##0" type="String" /><column name="int1" property="Validation.Type" value="1" type="Double" /><column name="int1" property="Validation.Operator" value="1" type="Double" /><column name="int1" property="Validation.Formula1" value="-2147483648" type="String" /><column name="int1" property="Validation.Formula2" value="2147483647" type="String" /><column name="int1" property="Validation.AlertStyle" value="1" type="Double" /><column name="int1" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="int1" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="int1" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="int1" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String" /><column name="int1" property="Validation.ShowInput" value="True" type="Boolean" /><column name="int1" property="Validation.ShowError" value="True" type="Boolean" /><column name="int2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="int2" property="Address" value="$K$4" type="String" /><column name="int2" property="NumberFormat" value="#,##0" type="String" /><column name="int2" property="Validation.Type" value="1" type="Double" /><column name="int2" property="Validation.Operator" value="1" type="Double" /><column name="int2" property="Validation.Formula1" value="-2147483648" type="String" /><column name="int2" property="Validation.Formula2" value="2147483647" type="String" /><column name="int2" property="Validation.AlertStyle" value="1" type="Double" /><column name="int2" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="int2" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="int2" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="int2" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String" /><column name="int2" property="Validation.ShowInput" value="True" type="Boolean" /><column name="int2" property="Validation.ShowError" value="True" type="Boolean" /><column name="float1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="float1" property="Address" value="$L$4" type="String" /><column name="float1" property="ColumnWidth" value="12.14" type="Double" /><column name="float1" property="NumberFormat" value="#,##0" type="String" /><column name="float1" property="Validation.Type" value="2" type="Double" /><column name="float1" property="Validation.Operator" value="4" type="Double" /><column name="float1" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="float1" property="Validation.AlertStyle" value="1" type="Double" /><column name="float1" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="float1" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="float1" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="float1" property="Validation.ErrorMessage" value="The column requires values of the float datatype." type="String" /><column name="float1" property="Validation.ShowInput" value="True" type="Boolean" /><column name="float1" property="Validation.ShowError" value="True" type="Boolean" /><column name="float2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="float2" property="Address" value="$M$4" type="String" /><column name="float2" property="NumberFormat" value="#,##0" type="String" /><column name="float2" property="Validation.Type" value="2" type="Double" /><column name="float2" property="Validation.Operator" value="4" type="Double" /><column name="float2" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="float2" property="Validation.AlertStyle" value="1" type="Double" /><column name="float2" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="float2" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="float2" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="float2" property="Validation.ErrorMessage" value="The column requires values of the float datatype." type="String" /><column name="float2" property="Validation.ShowInput" value="True" type="Boolean" /><column name="float2" property="Validation.ShowError" value="True" type="Boolean" /><column name="id" property="FormatConditions(1).AppliesTo.Address" value="$C$4:$C$5" type="String" /><column name="id" property="FormatConditions(1).Type" value="2" type="Double" /><column name="id" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="id" property="FormatConditions(1).Formula1" value="=ISBLANK(C4)" type="String" /><column name="id" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="id" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="2" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats><views><view name="All columns"><column name="" property="ListObjectName" value="view_data" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="client_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id2" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id3" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="string1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="string2" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="int1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="int2" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="float1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="float2" property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Common columns"><column name="" property="ListObjectName" value="view_data" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="client_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id3" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="string1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="string2" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="int1" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="int2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="float1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="float2" property="EntireColumn.Hidden" value="True" type="Boolean" /></view><view name="Client 1"><column name="" property="ListObjectName" value="view_data" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="client_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id3" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="string1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="string2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="int1" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="int2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="float1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="float2" property="EntireColumn.Hidden" value="True" type="Boolean" /></view><view name="Client 2"><column name="" property="ListObjectName" value="view_data" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="client_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id1" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id3" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="string1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="string2" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="int1" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="int2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="float1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="float2" property="EntireColumn.Hidden" value="True" type="Boolean" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's14', N'view_members', N'<table name="s14.view_members"><columnFormats><column name="" property="ListObjectName" value="members" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="name" property="Address" value="$D$4" type="String" /><column name="name" property="ColumnWidth" value="12.14" type="Double" /><column name="name" property="NumberFormat" value="General" type="String" /><column name="string1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="string1" property="Address" value="$E$4" type="String" /><column name="string1" property="ColumnWidth" value="14.86" type="Double" /><column name="string1" property="NumberFormat" value="General" type="String" /><column name="string1" property="Validation.Type" value="6" type="Double" /><column name="string1" property="Validation.Operator" value="8" type="Double" /><column name="string1" property="Validation.Formula1" value="50" type="String" /><column name="string1" property="Validation.AlertStyle" value="1" type="Double" /><column name="string1" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="string1" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="string1" property="Validation.ShowInput" value="True" type="Boolean" /><column name="string1" property="Validation.ShowError" value="True" type="Boolean" /><column name="string2" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="string2" property="Address" value="$F$4" type="String" /><column name="string2" property="ColumnWidth" value="14.57" type="Double" /><column name="string2" property="NumberFormat" value="General" type="String" /><column name="string2" property="Validation.Type" value="6" type="Double" /><column name="string2" property="Validation.Operator" value="8" type="Double" /><column name="string2" property="Validation.Formula1" value="50" type="String" /><column name="string2" property="Validation.AlertStyle" value="1" type="Double" /><column name="string2" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="string2" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="string2" property="Validation.ShowInput" value="True" type="Boolean" /><column name="string2" property="Validation.ShowError" value="True" type="Boolean" /><column name="int1" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="int1" property="Address" value="$G$4" type="String" /><column name="int1" property="NumberFormat" value="General" type="String" /><column name="int1" property="Validation.Type" value="1" type="Double" /><column name="int1" property="Validation.Operator" value="1" type="Double" /><column name="int1" property="Validation.Formula1" value="-2147483648" type="String" /><column name="int1" property="Validation.Formula2" value="2147483647" type="String" /><column name="int1" property="Validation.AlertStyle" value="1" type="Double" /><column name="int1" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="int1" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="int1" property="Validation.ShowInput" value="True" type="Boolean" /><column name="int1" property="Validation.ShowError" value="True" type="Boolean" /><column name="int2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="int2" property="Address" value="$H$4" type="String" /><column name="int2" property="NumberFormat" value="General" type="String" /><column name="int2" property="Validation.Type" value="1" type="Double" /><column name="int2" property="Validation.Operator" value="1" type="Double" /><column name="int2" property="Validation.Formula1" value="-2147483648" type="String" /><column name="int2" property="Validation.Formula2" value="2147483647" type="String" /><column name="int2" property="Validation.AlertStyle" value="1" type="Double" /><column name="int2" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="int2" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="int2" property="Validation.ShowInput" value="True" type="Boolean" /><column name="int2" property="Validation.ShowError" value="True" type="Boolean" /><column name="float1" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="float1" property="Address" value="$I$4" type="String" /><column name="float1" property="NumberFormat" value="General" type="String" /><column name="float1" property="Validation.Type" value="2" type="Double" /><column name="float1" property="Validation.Operator" value="4" type="Double" /><column name="float1" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="float1" property="Validation.AlertStyle" value="1" type="Double" /><column name="float1" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="float1" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="float1" property="Validation.ShowInput" value="True" type="Boolean" /><column name="float1" property="Validation.ShowError" value="True" type="Boolean" /><column name="float2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="float2" property="Address" value="$J$4" type="String" /><column name="float2" property="NumberFormat" value="General" type="String" /><column name="float2" property="Validation.Type" value="2" type="Double" /><column name="float2" property="Validation.Operator" value="4" type="Double" /><column name="float2" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="float2" property="Validation.AlertStyle" value="1" type="Double" /><column name="float2" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="float2" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="float2" property="Validation.ShowInput" value="True" type="Boolean" /><column name="float2" property="Validation.ShowError" value="True" type="Boolean" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="2" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /></columnFormats></table>');
GO

INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's14', N'view_data', NULL, N'DynamicColumns', N's14', N'dynamic_columns', N'CODE', N'SELECT column_name, alias, is_active, is_selected, sort_order FROM s14.view_aliases WHERE client_id = @client_id AND table_name = ''s14.data''', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's14', N'view_members', NULL, N'DynamicColumns', N's14', N'dynamic_columns', N'CODE', N'SELECT column_name, alias, is_active, is_selected, sort_order FROM s14.view_aliases WHERE client_id = @client_id AND table_name = ''s14.members''', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's14', N'view_data', N'client_id', N'ValidationList', N's14', N'xl_list_client_id', N'VIEW', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's14', N'view_data', N'id1', N'ValidationList', N's14', N'xl_list_member_id1', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's14', N'view_data', N'id2', N'ValidationList', N's14', N'xl_list_member_id2', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's14', N'view_data', N'id3', N'ValidationList', N's14', N'xl_list_member_id3', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's14', N'view_members', N'client_id', N'ValidationList', N's14', N'xl_list_client_id', N'VIEW', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's14', N'view_members', N'dimension_id', N'ValidationList', N's14', N'dimensions', N'TABLE', N'id, name', NULL, NULL, NULL);
GO

print 'Application installed';
