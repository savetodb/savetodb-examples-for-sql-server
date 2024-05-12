-- =============================================
-- Application: Sample 04 - Orders
-- Version 10.13, April 29, 2024
--
-- Copyright 2014-2024 Gartle LLC
--
-- License: MIT
--
-- Prerequisites: SaveToDB Framework 8.19 or higher
-- =============================================

SET NOCOUNT ON
GO

CREATE SCHEMA s04;
GO

CREATE TABLE s04.brands (
    id int IDENTITY(1,1) NOT NULL
    , name nvarchar(255) NULL
    , CONSTRAINT PK_brands PRIMARY KEY (id)
    , CONSTRAINT IX_brands UNIQUE (name)
);
GO

CREATE TABLE s04.items (
    id int IDENTITY(1,1) NOT NULL
    , node hierarchyid NOT NULL
    , item_level AS ([node].[GetLevel]())
    , brand_id int NULL
    , name nvarchar(255) NULL
    , CONSTRAINT PK_items PRIMARY KEY (id)
    , CONSTRAINT IX_items_node UNIQUE (node)
);
GO

ALTER TABLE s04.items ADD CONSTRAINT FK_items_brands FOREIGN KEY (brand_id) REFERENCES s04.brands (id) ON UPDATE CASCADE;
GO

CREATE TABLE s04.order_details (
    id int IDENTITY(1,1) NOT NULL
    , item_id int NOT NULL
    , amount int NULL
    , CONSTRAINT PK_order_details PRIMARY KEY (id)
);
GO

ALTER TABLE s04.order_details ADD CONSTRAINT FK_order_details_items FOREIGN KEY (item_id) REFERENCES s04.items (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

CREATE TABLE s04.prices (
    item_id int NOT NULL
    , price decimal(18,2) NULL
    , CONSTRAINT PK_prices PRIMARY KEY (item_id)
);
GO

ALTER TABLE s04.prices ADD CONSTRAINT FK_prices_items FOREIGN KEY (item_id) REFERENCES s04.items (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Items
-- =============================================

CREATE VIEW [s04].[view_items]
AS

SELECT
    i.id
    , c.id AS category_id
    , s.id AS subcategory_id
    , v.id AS brand_id
    , i.item_level
    , i.node
    --, c.node AS category_node
    --, s.node AS subcategory_node
    , c.name AS category
    , s.name AS subcategory
    , v.name AS brand
    , i.name
    , p.price
    , b.amount
    , '=[@price]*[@amount]' AS total
FROM
    s04.items i
    LEFT OUTER JOIN s04.brands v ON v.id = i.brand_id
    LEFT OUTER JOIN s04.prices p ON p.item_id = i.id
    LEFT OUTER JOIN s04.order_details b ON b.item_id = i.id
    INNER JOIN s04.items c ON i.node.IsDescendantOf(c.node) >= 1 AND c.item_level = 1
    LEFT OUTER JOIN s04.items s ON i.node.IsDescendantOf(s.node) >= 1 AND s.item_level = 2


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects an order form
-- =============================================

CREATE PROCEDURE [s04].[usp_order_form]
    @category_id int = NULL
    , @subcategory_id int = NULL
    , @brand_id int = NULL
AS
BEGIN

SELECT
    t.id, t.category_id, t.subcategory_id, t.brand_id, t.item_level
    , CAST(t.node AS varchar(255)) AS node
    , t.category, t.subcategory, t.brand, t.name, t.price, t.amount, t.[total]
FROM
    s04.view_items t
WHERE
    t.category_id = COALESCE(@category_id, t.category_id)
    AND COALESCE(t.subcategory_id, 0) = COALESCE(@subcategory_id, t.subcategory_id, 0)
    AND COALESCE(t.brand_id, 0) = COALESCE(@brand_id, t.brand_id, 0)
ORDER BY
    t.node

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Basket change event handler
-- =============================================

CREATE PROCEDURE [s04].[usp_order_form_change]
    @id int = NULL
    , @column_name nvarchar(255) = NULL
    , @cell_value nvarchar(255) = NULL
    , @cell_number_value float = NULL
    , @changed_cell_action nvarchar(50) = NULL
    , @data_language varchar(10) = NULL
AS
BEGIN

SET NOCOUNT ON

DECLARE @level int

DECLARE @message nvarchar(max)

IF @data_language IS NULL SET @data_language = 'en'

IF @changed_cell_action = 'RowInsert' OR @changed_cell_action = 'RowDelete'
    BEGIN
        SELECT @message = TRANSLATED_DESC FROM xls.translations
            WHERE TABLE_SCHEMA = 's04' AND TABLE_NAME = 'strings' AND COLUMN_NAME = 'MessageDoNotAddOrDeleteRows' AND LANGUAGE_NAME = @data_language

        IF @message IS NULL SET @message = N'Please do not add or delete rows.'

        SET @message = REPLACE(REPLACE(@message, '\r\n', CHAR(13) + CHAR(10)), CHAR(10) + ' ', CHAR(10))

        -- Severity > 10 raises SqlException and SaveToDB makes Undo of user's change
        RAISERROR (@message, 11, 0)

        RETURN
    END

IF @column_name = 'amount'
    BEGIN

    SELECT @level = item_level FROM s04.items WHERE id = @id

    IF (@level IS NULL) OR (@level < 3)
        BEGIN

        SELECT @message = TRANSLATED_DESC FROM xls.translations
            WHERE TABLE_SCHEMA = 's04' AND TABLE_NAME = 'strings' AND COLUMN_NAME = 'MessageNonItemChanged' AND LANGUAGE_NAME = @data_language

        IF @message IS NULL SET @message = N'You have changed a category row.

The add-in will restore the previous value.

This example shows how to protect values and formulas using change event handlers.'

        SET @message = REPLACE(REPLACE(@message, '\r\n', CHAR(13) + CHAR(10)), CHAR(10) + ' ', CHAR(10))

        -- Severity > 10 raises SqlException and SaveToDB makes Undo of user's change
        RAISERROR (@message, 11, 0)

        RETURN
        END

    UPDATE s04.order_details
    SET
        amount = @cell_number_value
    WHERE
        item_id = @id

    IF (@@ROWCOUNT = 0) AND (@cell_value IS NOT NULL)
        BEGIN
        INSERT s04.order_details
            (item_id, amount)
        VALUES
            (@id, @cell_number_value)
        END

    END
ELSE IF @column_name = 'price'
    BEGIN

    SELECT @level = item_level FROM s04.items WHERE id = @id

    IF (@level IS NULL) OR (@level < 3)
        BEGIN

        SELECT @message = TRANSLATED_DESC FROM xls.translations
            WHERE TABLE_SCHEMA = 's04' AND TABLE_NAME = 'strings' AND COLUMN_NAME = 'MessageNonItemChanged' AND LANGUAGE_NAME = @data_language

        IF @message IS NULL SET @message = N'You have changed a category row.

The add-in will restore the previous value.

This example shows how to protect values and formulas using change event handlers.'

        SET @message = REPLACE(REPLACE(@message, '\r\n', CHAR(13) + CHAR(10)), CHAR(10) + ' ', CHAR(10))

        -- Severity > 10 raises SqlException and SaveToDB makes Undo of user's change
        RAISERROR (@message, 11, 0)

        RETURN
        END

    UPDATE s04.prices
    SET
        price = @cell_number_value
    WHERE
        item_id = @id

    IF (@@ROWCOUNT = 0) AND (@cell_value IS NOT NULL)
        BEGIN

        INSERT s04.prices
            (item_id, price)
        VALUES
            (@id, @cell_number_value)
        END

    SELECT @message = TRANSLATED_DESC FROM xls.translations
        WHERE TABLE_SCHEMA = 's04' AND TABLE_NAME = 'strings' AND COLUMN_NAME = 'MessagePriceChanged' AND LANGUAGE_NAME = @data_language

    IF @message IS NULL SET @message = N'You have changed the price value.

This example shows how to notify users from an event handler without the undo action.

You can undo the action yourself in Microsoft Excel (Ctrl-Z).'

    SET @message = REPLACE(REPLACE(@message, '\r\n', CHAR(13) + CHAR(10)), CHAR(10) + ' ', CHAR(10))

    -- Use PRINT to send a message to a user from the Change event handler
    PRINT @message

    END
ELSE
    BEGIN

    SELECT @message = TRANSLATED_DESC FROM xls.translations
        WHERE TABLE_SCHEMA = 's04' AND TABLE_NAME = 'strings' AND COLUMN_NAME = 'MessageNonAmountChanged' AND LANGUAGE_NAME = @data_language

    IF @message IS NULL SET @message = N'You have changed the protected ''%s'' column.

The add-in will restore the previous value.

You may change the Amount column only.

This example shows how to protect values and formulas using change event handlers.'

    SET @message = REPLACE(REPLACE(@message, '\r\n', CHAR(13) + CHAR(10)), CHAR(10) + ' ', CHAR(10))

    -- Severity > 10 raises SqlException and SaveToDB makes Undo of user's change
    RAISERROR (@message, 11, 0, @column_name)

    RETURN
    END

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Clears an order form
-- =============================================

CREATE PROCEDURE [s04].[xl_actions_items_clear]
AS
BEGIN

UPDATE s04.order_details
SET
    amount = NULL

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Clears the brand parameter
-- =============================================

CREATE PROCEDURE [s04].[xl_actions_items_clear_brands]
AS
BEGIN

SET NOCOUNT ON

SELECT
    NULL AS brand_id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Deletes an item
-- =============================================

CREATE PROCEDURE [s04].[xl_actions_items_delete_item]
    @id int
    , @name nvarchar(255)
AS
BEGIN

DELETE s04.items
WHERE
    id = @id
    AND name = name

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Inserts a new item
-- =============================================

CREATE PROCEDURE [s04].[xl_actions_items_insert_item]
    @category_id int = NULL
    , @subcategory_id int = NULL
    , @brand_id int = NULL
    , @name nvarchar(255) = NULL
AS
BEGIN

DECLARE @parent_id int

IF @subcategory_id IS NOT NULL SET @parent_id = @subcategory_id
ELSE IF @category_id IS NOT NULL SET @parent_id = @category_id
ELSE SELECT @parent_id = id FROM s04.items WHERE item_level = 0

DECLARE @parent_node hierarchyid
DECLARE @max_node hierarchyid
DECLARE @node hierarchyid

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

BEGIN TRANSACTION

    SELECT @parent_node = node FROM s04.items WHERE id = @parent_id

    SELECT @max_node = MAX(node) FROM s04.items WHERE node.GetAncestor(1) = @parent_node

    SET @node = @parent_node.GetDescendant(@max_node, NULL)

    INSERT s04.items
        (node, brand_id, name)
    VALUES
        (@node, @brand_id, @name)

COMMIT

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Prints to HTML
-- =============================================

CREATE PROCEDURE [s04].[xl_actions_items_print_as_html]
AS
BEGIN

SET NOCOUNT ON

DECLARE @total money = COALESCE((SELECT SUM(t.price * t.amount) FROM s04.view_items t WHERE amount IS NOT NULL), 0)

DECLARE @html nvarchar(MAX)

SET @html = COALESCE((
    SELECT
        ROW_NUMBER() OVER (ORDER BY t.[node]) AS item
        , t.name
        , t.price
        , t.amount
        , t.price * t.amount AS total
    FROM
        s04.view_items t
    WHERE
        t.amount IS NOT NULL
    ORDER BY
        t.node
    FOR XML PATH('tr')
    ), '')

SET @html = REPLACE(@html, '<item>', '<td class="item" >')
SET @html = REPLACE(@html, '<name>', '<td class="name" >')
SET @html = REPLACE(@html, '<price>', '<td class="price" >')
SET @html = REPLACE(@html, '<amount>', '<td class="amount" >')
SET @html = REPLACE(@html, '<total>', '<td class="total" >')

SET @html = REPLACE(@html, '</item>', '</td>')
SET @html = REPLACE(@html, '</name>', '</td>')
SET @html = REPLACE(@html, '</price>', '</td>')
SET @html = REPLACE(@html, '</amount>', '</td>')
SET @html = REPLACE(@html, '</total>', '</td>')
SET @html = REPLACE(@html, '</tr>', '</tr>' + CHAR(13) + CHAR(10))

SET @html = N'<html>
<head>
<title>HTML Form Example</title>
<style>
h1 { white-space: nowrap; }
table { border: 1px Black solid; border-collapse: collapse; }
td,th { border: 1px Black solid; padding: 1px 5px 1px 5px; }
td.item { text-align: center; }
td.name { }
td.price { text-align: right; }
td.amount { text-align: right; }
td.total { text-align: right; }
tr.total_row { font-weight: bold; }
</style>
</head>
<body>
<h1>HTML Form Example</h1>
<table>
<tr><th>item #</th><th>name</th><th>price</th><th>amount</th><th>total</th></tr>
' + @html + '<tr class="total_row"><td></td><td>Total</td><td></td><td></td><td class="sum" >' + CAST(@total AS varchar(255)) + '</td></tr>
</table>
</body>
</html>'

SELECT @html AS html

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Renames an item
-- =============================================

CREATE PROCEDURE [s04].[xl_actions_items_rename_item]
    @id int
    , @name nvarchar(255)
AS
BEGIN

UPDATE s04.items
SET
    name = @name
WHERE
    id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Set the brand parameter to Acer (example)
-- =============================================

CREATE PROCEDURE [s04].[xl_actions_items_set_brand_acer]
AS
BEGIN

SET NOCOUNT ON

SELECT id AS brand_id FROM s04.brands WHERE name = 'Acer'

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Set the brand parameter to ASUS (example)
-- =============================================

CREATE PROCEDURE [s04].[xl_actions_items_set_brand_asus]
AS
BEGIN

SET NOCOUNT ON

SELECT id AS brand_id FROM s04.brands WHERE name = 'ASUS'

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects brand_id parameter values
-- =============================================

CREATE PROCEDURE [s04].[xl_list_brand_id]
    @category_id int = NULL
    , @subcategory_id int = NULL
AS
BEGIN

IF @category_id IS NULL
    BEGIN
    SELECT
        id
        , name
    FROM
        s04.brands
    ORDER BY
        name
    END
ELSE
    BEGIN

    DECLARE @category_node hierarchyid

    IF @subcategory_id IS NULL
        SELECT @category_node = node FROM s04.items WHERE id = @category_id
    ELSE
        SELECT @category_node = node FROM s04.items WHERE id = @subcategory_id

    SELECT
        v.id
        , v.name
    FROM
        s04.items i
        INNER JOIN s04.brands v ON v.id = i.brand_id
    WHERE
        i.node.IsDescendantOf(@category_node) = 1
    GROUP BY
        v.id
        , v.name
    ORDER BY
        v.name

    END

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects category_id parameter values
-- =============================================

CREATE PROCEDURE [s04].[xl_list_category_id]
AS
BEGIN

SELECT NULL AS id, NULL AS name UNION
SELECT
    i.id
    , i.name
FROM
    s04.items i
WHERE
    i.item_level = 1
ORDER BY
    name

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects subcategory_id parameter values
-- =============================================

CREATE PROCEDURE [s04].[xl_list_subcategory_id]
    @category_id int = NULL
AS
BEGIN

IF @category_id IS NULL
    BEGIN
    SELECT CAST(NULL AS int) AS id, CAST(NULL AS nvarchar(255)) AS name
    RETURN
    END

DECLARE @category_node hierarchyid

SELECT @category_node = node FROM s04.items WHERE id = @category_id

SELECT
    i.id
    , i.name
FROM
    s04.items i
WHERE
    i.node.IsDescendantOf(@category_node) = 1
    AND i.item_level = 2
ORDER BY
    i.name

END


GO

SET IDENTITY_INSERT s04.brands ON;
INSERT INTO s04.brands (id, name) VALUES (1, N'Acer');
INSERT INTO s04.brands (id, name) VALUES (2, N'ASUS');
INSERT INTO s04.brands (id, name) VALUES (3, N'Dell');
INSERT INTO s04.brands (id, name) VALUES (4, N'Samsung');
INSERT INTO s04.brands (id, name) VALUES (5, N'Sony');
SET IDENTITY_INSERT s04.brands OFF;
GO

SET IDENTITY_INSERT s04.items ON;
INSERT INTO s04.items (id, node, brand_id, name) VALUES (1, '/', NULL, N'Catalog');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (2, '/1/', NULL, N'Laptops');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (3, '/2/', NULL, N'Netbooks');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (4, '/1/1/', 1, N'Acer Laptops');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (5, '/1/2/', 2, N'ASUS Laptops');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (6, '/1/3/', 3, N'Dell Laptops');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (7, '/1/4/', 5, N'Sony Laptops');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (8, '/2/1/', 1, N'Acer Netbooks');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (9, '/2/2/', 2, N'ASUS Netbooks');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (10, '/2/3/', 4, N'Samsung Netbooks');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (11, '/1/1/1/', 1, N'Acer Aspire TimelineX AS1830T-6651 11.6-Inch Laptop (Black)');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (12, '/1/1/2/', 1, N'Acer Aspire TimelineX AS4830T-6642 14-Inch Laptop (Cobalt Blue Aluminum)');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (13, '/1/2/1/', 2, N'ASUS A53U-XE1 15.6-Inch Versatile Entertainment Laptop (Mocha)');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (14, '/1/2/2/', 2, N'ASUS A53SV-XE1 15.6-Inch Versatile Entertainment Laptop (Black)');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (15, '/1/3/1/', 3, N'Dell Inspiron 14R i14RN4110-8073DBK 14-Inch Laptop (Diamond Black)');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (16, '/1/3/2/', 3, N'Dell XPS 15 X15L-1024ELS Laptop (Elemental Silver)');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (17, '/1/4/1/', 5, N'Sony VAIO VPC-EH11FX/L Laptop (Blue)');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (18, '/1/4/2/', 5, N'Sony VAIO VPC-EL17FX/B Laptop (Black)');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (19, '/2/1/1/', 1, N'Acer Aspire One AO722-BZ454 11.6-Inch HD Netbook (Espresso Black)');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (20, '/2/1/2/', 1, N'Acer Aspire One AOD257-13685 10.1-Inch Netbook (Espresso Black)');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (21, '/2/2/1/', 2, N'ASUS Eee PC 1015PEM-PU17-BK 10.1-Inch Netbook (Black)');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (22, '/2/2/2/', 2, N'ASUS Eee PC 1015PEM-PU17-BU 10.1-Inch Netbook (Blue)');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (23, '/2/3/1/', 4, N'Samsung NF310-A01 10.1-Inch Netbook (Titan Silver)');
INSERT INTO s04.items (id, node, brand_id, name) VALUES (24, '/2/3/2/', 4, N'Samsung NB30-JP02 10.1-Inch Netbook (Texturized Matte Black)');
SET IDENTITY_INSERT s04.items OFF;
GO

SET IDENTITY_INSERT s04.order_details ON;
INSERT INTO s04.order_details (id, item_id, amount) VALUES (1, 13, 1);
INSERT INTO s04.order_details (id, item_id, amount) VALUES (2, 15, 1);
SET IDENTITY_INSERT s04.order_details OFF;
GO

INSERT INTO s04.prices (item_id, price) VALUES (11, 479.99);
INSERT INTO s04.prices (item_id, price) VALUES (12, 699.99);
INSERT INTO s04.prices (item_id, price) VALUES (13, 339.98);
INSERT INTO s04.prices (item_id, price) VALUES (14, 799.99);
INSERT INTO s04.prices (item_id, price) VALUES (15, 549.99);
INSERT INTO s04.prices (item_id, price) VALUES (16, 899.99);
INSERT INTO s04.prices (item_id, price) VALUES (17, 540.86);
INSERT INTO s04.prices (item_id, price) VALUES (18, 499);
INSERT INTO s04.prices (item_id, price) VALUES (19, 292.88);
INSERT INTO s04.prices (item_id, price) VALUES (20, 269.99);
INSERT INTO s04.prices (item_id, price) VALUES (21, 299.99);
INSERT INTO s04.prices (item_id, price) VALUES (22, 289.98);
INSERT INTO s04.prices (item_id, price) VALUES (23, 379.34);
INSERT INTO s04.prices (item_id, price) VALUES (24, 359);
GO

INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's04', N'usp_order_form', N'<table name="s04.usp_order_form"><columnFormats><column name="" property="ListObjectName" value="usp_order_form" type="String" /><column name="" property="ShowTotals" value="True" type="Boolean" /><column name="total" property="TotalsCalculation" value="1" type="Double" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="category_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="category_id" property="Address" value="$D$4" type="String" /><column name="category_id" property="NumberFormat" value="General" type="String" /><column name="subcategory_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="subcategory_id" property="Address" value="$E$4" type="String" /><column name="subcategory_id" property="NumberFormat" value="General" type="String" /><column name="brand_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="brand_id" property="Address" value="$F$4" type="String" /><column name="brand_id" property="NumberFormat" value="General" type="String" /><column name="item_level" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="item_level" property="Address" value="$G$4" type="String" /><column name="item_level" property="NumberFormat" value="General" type="String" /><column name="node" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="node" property="Address" value="$H$4" type="String" /><column name="node" property="NumberFormat" value="General" type="String" /><column name="category" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="category" property="Address" value="$I$4" type="String" /><column name="category" property="NumberFormat" value="General" type="String" /><column name="subcategory" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="subcategory" property="Address" value="$J$4" type="String" /><column name="subcategory" property="NumberFormat" value="General" type="String" /><column name="brand" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="brand" property="Address" value="$K$4" type="String" /><column name="brand" property="NumberFormat" value="General" type="String" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="name" property="Address" value="$L$4" type="String" /><column name="name" property="ColumnWidth" value="69.29" type="Double" /><column name="name" property="NumberFormat" value="General" type="String" /><column name="price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="price" property="Address" value="$M$4" type="String" /><column name="price" property="ColumnWidth" value="8.57" type="Double" /><column name="price" property="NumberFormat" value="#,##0.00;[Red]-#,##0.00;" type="String" /><column name="amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="amount" property="Address" value="$N$4" type="String" /><column name="amount" property="ColumnWidth" value="10" type="Double" /><column name="amount" property="NumberFormat" value="General" type="String" /><column name="total" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="total" property="Address" value="$O$4" type="String" /><column name="total" property="FormulaR1C1" value="=[@price]*[@amount]" type="String" /><column name="total" property="ColumnWidth" value="8.57" type="Double" /><column name="total" property="NumberFormat" value="#,##0.00;[Red]-#,##0.00;" type="String" /><column name="_RowNum" property="FormatConditions(1).AppliesToTable" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(1).AppliesTo.Address" value="$B$4:$O$26" type="String" /><column name="_RowNum" property="FormatConditions(1).Type" value="2" type="Double" /><column name="_RowNum" property="FormatConditions(1).Priority" value="3" type="Double" /><column name="_RowNum" property="FormatConditions(1).Formula1" value="=$G4=2" type="String" /><column name="_RowNum" property="FormatConditions(1).Font.Bold" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(1).Interior.Color" value="15189684" type="Double" /><column name="_RowNum" property="FormatConditions(1).Interior.ThemeColor" value="5" type="Double" /><column name="_RowNum" property="FormatConditions(1).Interior.TintAndShade" value="0.599963377788629" type="Double" /><column name="_RowNum" property="FormatConditions(2).AppliesToTable" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(2).AppliesTo.Address" value="$B$4:$O$26" type="String" /><column name="_RowNum" property="FormatConditions(2).Type" value="2" type="Double" /><column name="_RowNum" property="FormatConditions(2).Priority" value="4" type="Double" /><column name="_RowNum" property="FormatConditions(2).Formula1" value="=$G4=1" type="String" /><column name="_RowNum" property="FormatConditions(2).Font.Bold" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(2).Font.Color" value="16777215" type="Double" /><column name="_RowNum" property="FormatConditions(2).Font.ThemeColor" value="1" type="Double" /><column name="_RowNum" property="FormatConditions(2).Font.TintAndShade" value="0" type="Double" /><column name="_RowNum" property="FormatConditions(2).Interior.Color" value="6299648" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /><column name="" property="PageSetup.LeftMargin" value="51.0236220472441" type="Double" /><column name="" property="PageSetup.RightMargin" value="22.6771653543307" type="Double" /><column name="" property="PageSetup.TopMargin" value="25.511811023622" type="Double" /><column name="" property="PageSetup.BottomMargin" value="34.0157480314961" type="Double" /><column name="" property="PageSetup.HeaderMargin" value="22.6771653543307" type="Double" /><column name="" property="PageSetup.FooterMargin" value="19.8425196850394" type="Double" /></columnFormats><views><view name="All rows"><column name="" property="ListObjectName" value="usp_order_form" type="String" /><column name="" property="ShowTotals" value="True" type="Boolean" /><column name="total" property="TotalsCalculation" value="1" type="Double" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="category_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="subcategory_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="brand_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="item_level" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="node" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="category" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="subcategory" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="brand" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="total" property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Filled rows"><column name="" property="ListObjectName" value="usp_order_form" type="String" /><column name="" property="ShowTotals" value="True" type="Boolean" /><column name="total" property="TotalsCalculation" value="1" type="Double" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="category_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="subcategory_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="brand_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="item_level" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="node" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="category" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="subcategory" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="brand" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="total" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="amount" property="AutoFilter.Criteria1" value="&lt;&gt;" type="String" /></view><view name="All columns"><column name="" property="ListObjectName" value="usp_order_form" type="String" /><column name="" property="ShowTotals" value="True" type="Boolean" /><column name="total" property="TotalsCalculation" value="1" type="Double" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="category_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="subcategory_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="brand_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item_level" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="node" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="category" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="subcategory" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="brand" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="total" property="EntireColumn.Hidden" value="False" type="Boolean" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's04', N'view_items', N'<table name="s04.view_items"><columnFormats><column name="" property="ListObjectName" value="UserObject_Table" type="String" /><column name="" property="ShowTotals" value="True" type="Boolean" /><column name="total" property="TotalsCalculation" value="1" type="Double" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="category_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="category_id" property="Address" value="$D$4" type="String" /><column name="category_id" property="NumberFormat" value="General" type="String" /><column name="subcategory_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="subcategory_id" property="Address" value="$E$4" type="String" /><column name="subcategory_id" property="NumberFormat" value="General" type="String" /><column name="brand_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="brand_id" property="Address" value="$F$4" type="String" /><column name="brand_id" property="NumberFormat" value="General" type="String" /><column name="item_level" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="item_level" property="Address" value="$G$4" type="String" /><column name="item_level" property="NumberFormat" value="General" type="String" /><column name="node" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="node" property="Address" value="$H$4" type="String" /><column name="node" property="NumberFormat" value="General" type="String" /><column name="category" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="category" property="Address" value="$I$4" type="String" /><column name="category" property="NumberFormat" value="General" type="String" /><column name="subcategory" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="subcategory" property="Address" value="$J$4" type="String" /><column name="subcategory" property="NumberFormat" value="General" type="String" /><column name="brand" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="brand" property="Address" value="$K$4" type="String" /><column name="brand" property="NumberFormat" value="General" type="String" /><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="name" property="Address" value="$L$4" type="String" /><column name="name" property="ColumnWidth" value="69.29" type="Double" /><column name="name" property="NumberFormat" value="General" type="String" /><column name="price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="price" property="Address" value="$M$4" type="String" /><column name="price" property="ColumnWidth" value="7" type="Double" /><column name="price" property="NumberFormat" value="#,##0.00;[Red]-#,##0.00;" type="String" /><column name="amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="amount" property="Address" value="$N$4" type="String" /><column name="amount" property="ColumnWidth" value="9.43" type="Double" /><column name="amount" property="NumberFormat" value="General" type="String" /><column name="total" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="total" property="Address" value="$O$4" type="String" /><column name="total" property="FormulaR1C1" value="=[@price]*[@amount]" type="String" /><column name="total" property="ColumnWidth" value="6.71" type="Double" /><column name="total" property="NumberFormat" value="#,##0.00;[Red]-#,##0.00;" type="String" /><column name="_RowNum" property="FormatConditions(1).AppliesToTable" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(1).AppliesTo.Address" value="$B$4:$O$26" type="String" /><column name="_RowNum" property="FormatConditions(1).Type" value="2" type="Double" /><column name="_RowNum" property="FormatConditions(1).Priority" value="3" type="Double" /><column name="_RowNum" property="FormatConditions(1).Formula1" value="=$G4=2" type="String" /><column name="_RowNum" property="FormatConditions(1).NumberFormat" value="General" type="String" /><column name="_RowNum" property="FormatConditions(1).Font.Bold" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(1).Interior.Color" value="14136213" type="Double" /><column name="_RowNum" property="FormatConditions(1).Interior.ThemeColor" value="5" type="Double" /><column name="_RowNum" property="FormatConditions(1).Interior.TintAndShade" value="0.399914548173467" type="Double" /><column name="_RowNum" property="FormatConditions(2).AppliesToTable" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(2).AppliesTo.Address" value="$B$4:$O$26" type="String" /><column name="_RowNum" property="FormatConditions(2).Type" value="2" type="Double" /><column name="_RowNum" property="FormatConditions(2).Priority" value="4" type="Double" /><column name="_RowNum" property="FormatConditions(2).Formula1" value="=$G4=1" type="String" /><column name="_RowNum" property="FormatConditions(2).NumberFormat" value="General" type="String" /><column name="_RowNum" property="FormatConditions(2).Font.Bold" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(2).Font.Color" value="16777215" type="Double" /><column name="_RowNum" property="FormatConditions(2).Font.ThemeColor" value="1" type="Double" /><column name="_RowNum" property="FormatConditions(2).Font.TintAndShade" value="0" type="Double" /><column name="_RowNum" property="FormatConditions(2).Interior.Color" value="6299648" type="Double" /><column name="_RowNum" property="FormatConditions(2).Interior.Color" value="6299648" type="Double" /><column name="SortFields(1)" property="KeyfieldName" value="node" type="String" /><column name="SortFields(1)" property="SortOn" value="0" type="Double" /><column name="SortFields(1)" property="Order" value="1" type="Double" /><column name="SortFields(1)" property="DataOption" value="2" type="Double" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /><column name="" property="PageSetup.LeftMargin" value="51.0236220472441" type="Double" /><column name="" property="PageSetup.RightMargin" value="22.6771653543307" type="Double" /><column name="" property="PageSetup.TopMargin" value="25.511811023622" type="Double" /><column name="" property="PageSetup.BottomMargin" value="34.0157480314961" type="Double" /><column name="" property="PageSetup.HeaderMargin" value="22.6771653543307" type="Double" /><column name="" property="PageSetup.FooterMargin" value="19.8425196850394" type="Double" /></columnFormats></table>');
GO

INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'Actions', N's04', N'xl_actions_items_print_as_html', N'PROCEDURE', NULL, NULL, 11, 0);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'Actions', N's04', N'MenuSeparator20', N'MENUSEPARATOR', NULL, NULL, 20, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'Actions', N's04', N'xl_actions_items_clear_brands', N'PROCEDURE', NULL, N'_Reload', 31, 0);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'Actions', N's04', N'xl_actions_items_set_brand_acer', N'PROCEDURE', NULL, N'_Reload', 32, 0);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'Actions', N's04', N'xl_actions_items_set_brand_asus', N'PROCEDURE', NULL, N'_Reload', 33, 0);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'Actions', N's04', N'MenuSeparator40', N'MENUSEPARATOR', NULL, NULL, 40, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'Actions', N's04', N'xl_actions_items_insert_item', N'PROCEDURE', NULL, N'_Reload', 41, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'Actions', N's04', N'xl_actions_items_delete_item', N'PROCEDURE', NULL, N'_Reload', 47, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'Actions', N's04', N'xl_actions_items_rename_item', N'PROCEDURE', NULL, N'_Reload', 49, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'Change', N's04', N'usp_order_form_change', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'ContextMenu', N's04', N'Search {name}', N'HTTP', N'https://www.google.com/search?as_q={name}', NULL, 11, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'ContextMenu', N's04', N'MenuSeparator40', N'MENUSEPARATOR', NULL, NULL, 40, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'ContextMenu', N's04', N'xl_actions_items_insert_item', N'PROCEDURE', NULL, N'_Reload', 41, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'ContextMenu', N's04', N'xl_actions_items_delete_item', N'PROCEDURE', NULL, N'_Reload', 47, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'ContextMenu', N's04', N'xl_actions_items_rename_item', N'PROCEDURE', NULL, N'_Reload', 49, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'DoNotSort', NULL, NULL, N'ATTRIBUTE', NULL, N'_Reload', 49, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'Format', NULL, NULL, N'ATTRIBUTE', N'[{"formula":"item_level=2","format":"background-color: rgb(180,198,231);font-weight: bold;"},{"formula":"item_level=1","format":"background-color: rgb(0,32,96);color: rgb(255,255,255);font-weight: bold;"}]', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', N'brand_id', N'ParameterValues', N's04', N'xl_list_brand_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', N'category_id', N'ParameterValues', N's04', N'xl_list_category_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', N'subcategory_id', N'ParameterValues', N's04', N'xl_list_subcategory_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'xl_actions_items_insert_item', N'brand_id', N'ParameterValues', N's04', N'xl_list_brand_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'xl_actions_items_insert_item', N'category_id', N'ParameterValues', N's04', N'xl_list_category_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'xl_actions_items_insert_item', N'subcategory_id', N'ParameterValues', N's04', N'xl_list_subcategory_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's04', N'usp_order_form', NULL, N'ProtectRows', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
GO

INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'amount', N'de', N'Betrag', N'Das Add-In aktualisiert einen geänderten Wert in einer Datenbank direkt nach der Änderung mithilfe eines Änderungsereignishandlers.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'brand_id', N'de', N'Marke', N'Das Add-In verwendet eine gespeicherte Prozedur, um Werte auszuwählen. \r\n \r\n Die Listenwerte hängen von den Parameterwerten category_id und subcategory_id ab. \r\n \r\n Die Liste enthält ID- und Namenspaare. \r\n \r\n Das Add-In verwendet Namenswerte zur Anzeige im Menüband und ID-Werte zur Übergabe als Parameterwerte.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'category_id', N'de', N'Kategorie', N'Das Add-In verwendet eine gespeicherte Prozedur, um Werte auszuwählen. \r\n \r\n Die Liste enthält ID- und Namenspaare. \r\n \r\n Das Add-In verwendet Namenswerte zur Anzeige im Menüband und ID-Werte zur Übergabe als Parameterwerte.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'name', N'de', N'Name', N'Das Add-In schützt Werte mithilfe eines Änderungsereignishandlers vor Änderungen.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'price', N'de', N'Preis', N'Das Add-In speichert einen geänderten Wert direkt nach der Änderung mithilfe eines Änderungsereignishandlers in einer Datenbank. \r\n \r\n Dieses Beispiel zeigt auch, wie eine Feedback-Nachricht von einem Handler angezeigt wird.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'subcategory_id', N'de', N'Unterkategorie', N'Das Add-In verwendet eine gespeicherte Prozedur, um Werte auszuwählen. \r\n \r\n Die Listenwerte hängen vom Parameterwert category_id ab. \r\n Das Add-In deaktiviert einen Parameter, wenn keine Werte für die Kategorie vorhanden sind. \r\n \r\n Das Add-In verwendet Namenswerte zur Anzeige im Menüband und ID-Werte zur Übergabe als Parameterwerte.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'total', N'de', N'Gesamt', N'Die Spalte enthält Werte, die mit einer regulären Excel-Formel berechnet werden. \r\n \r\n Das Add-In schützt die Formel mithilfe eines Änderungsereignishandlers vor Änderungen.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'Search {name}', NULL, N'de', N'Suche nach {Name}', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessageNonAmountChanged', N'de', NULL, N'Sie haben die geschützte Spalte ''%s'' geändert. \r\n \r\n Das Add-In stellt den vorherigen Wert wieder her. \r\n \r\n Sie können nur die Spalte Betrag ändern. \r\n \r\n Dieses Beispiel zeigt, wie man Werte und Formeln mit Change Event Handlern schützt.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessageNonItemChanged', N'de', NULL, N'Sie haben eine Kategoriezeile geändert. \r\n \r\n Das Add-In stellt den vorherigen Wert wieder her. \r\n \r\n Dieses Beispiel zeigt, wie man Werte und Formeln mit Change Event Handlern schützt.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessagePriceChanged', N'de', NULL, N'Sie haben den Preiswert geändert. \r\n \r\n Dieses Beispiel zeigt, wie Benutzer von einem Ereignishandler ohne die Aktion Rückgängig benachrichtigt werden. \r\n \r\n Sie können die Aktion in Microsoft Excel selbst rückgängig machen (Strg-Z).', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'usp_order_form', NULL, N'de', N'Bestellformular', N'Bestellformular', N'Diese gespeicherte Prozedur wählt ein Bestellformular aus. \r\n \r\n Es hat Parameter als ID- und Namenspaare, die im Menüband platziert werden. \r\n \r\n Außerdem hängen subcategory_id und brand_id von der category_id ab.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_clear', NULL, N'de', N'Löschen Sie einen Formular', NULL, N'Die Prozedur löscht Auftragspositionen und lädt die aktiven Tabellendaten neu.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_clear_brands', NULL, N'de', N'Löschen Sie einen Markenfilter', NULL, N'Die Prozedur setzt den Markenparameterwert auf NULL und lädt die aktiven Tabellendaten neu. \r\n \r\n Dieses Beispiel zeigt, wie aktive Abfrageparameter mit serverseitigen Ereignishandlern geändert werden.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_delete_item', NULL, N'de', N'Löschen Sie einen Artikel', NULL, N'Die Prozedur löscht ein Element. \r\n \r\n Dieses Beispiel zeigt, wie gespeicherte Prozeduren ausgeführt werden.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_insert_item', NULL, N'de', N'Einfügen Sie einen Artikel', NULL, N'Die Prozedur fügt ein neues Element ein. \r\n \r\n Die Prozedur verwendet auch gespeicherte Prozeduren, um Parameterwerte als ID- und Namenspaare auszuwählen.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_print_as_html', NULL, N'de', N'Als HTML drucken', NULL, N'Die Prozedur druckt die aktiven Tabellendaten in HTML.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_rename_item', NULL, N'de', N'Umbenennen eines Elements', NULL, N'Die Prozedur benennt ein Element um. \r\n \r\n Dieses Beispiel zeigt, wie gespeicherte Prozeduren ausgeführt werden.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_set_brand_acer', NULL, N'de', N'Filtern Sie die Artikel von Acer', NULL, N'Die Prozedur setzt den Markenparameterwert auf Acer und lädt die aktiven Tabellendaten neu. \r\n \r\n Dieses Beispiel zeigt, wie aktive Abfrageparameter mit serverseitigen Ereignishandlern geändert werden.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_set_brand_asus', NULL, N'de', N'Filtern Sie die Artikel von ASUS', NULL, N'Die Prozedur setzt den Markenparameterwert auf ASUS und lädt die aktiven Tabellendaten neu. \r\n \r\n Dieses Beispiel zeigt, wie aktive Abfrageparameter mit serverseitigen Ereignishandlern geändert werden.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'amount', N'en', N'Amount', N'The add-in updates a changed value in a database right after the change using a change event handler.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'brand_id', N'en', N'Brand', N'The add-in uses a stored procedure to select values. \r\n \r\n The list values depend on the category_id and subcategory_id parameter values. \r\n \r\n The list contains id and name pairs. \r\n \r\n The add-in uses name values to display on the ribbon and id values to pass as parameter values.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'category_id', N'en', N'Category', N'The add-in uses a stored procedure to select values. \r\n \r\n The list contains id and name pairs. \r\n \r\n The add-in uses name values to display on the ribbon and id values to pass as parameter values.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'name', N'en', N'Name', N'The add-in protects values from changes using a change event handler.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'price', N'en', N'Price', N'The add-in saves a changed value to a database right after the change using a change event handler. \r\n \r\n This example also shows how to show a feedback message from a handler.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'subcategory_id', N'en', N'Subcategory', N'The add-in uses a stored procedure to select a values. \r\n \r\n The list values depend on the category_id parameter value. \r\n The add-in disables a parameter if there are no values related to the category. \r\n \r\n The add-in uses name values to display on the ribbon and id values to pass as parameter values.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'total', N'en', N'Total', N'The column contains values calculated by a regular Excel formula. \r\n \r\n The add-in protects the formula from change using a change event handler.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'Search {name}', NULL, N'en', N'Search {name}', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessageNonAmountChanged', N'en', NULL, N'You have changed the protected ''%s'' column. \r\n \r\n The add-in will restore the previous value. \r\n \r\n You can change the Amount column only. \r\n \r\n This example shows how to protect values and formulas using change event handlers.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessageNonItemChanged', N'en', NULL, N'You have changed a category row. \r\n \r\n The add-in will restore the previous value. \r\n \r\n This example shows how to protect values and formulas using change event handlers.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessagePriceChanged', N'en', NULL, N'You have changed the price value. \r\n \r\n This example shows how to notify users from an event handler without the undo action. \r\n \r\n You can undo the action yourself in Microsoft Excel (Ctrl-Z).', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'usp_order_form', NULL, N'en', N'Order Form', N'Order Form', N'This stored procedure selects an order form. \r\n \r\n It has parameters as id and name pairs placed to the ribbon. \r\n \r\n Besides, subcategory_id and brand_id are dependent on category_id.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_clear', NULL, N'en', N'Clear Form', NULL, N'The procedure deletes order items and reloads the active table data.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_clear_brands', NULL, N'en', N'Clear Brand Filter', NULL, N'The procedure sets the brands parameter value to NULL and reloads the active table data. \r\n \r\n This example shows how to change active query parameters using server-side event handlers.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_delete_item', NULL, N'en', N'Delete Item', NULL, N'The procedure deletes an item. \r\n \r\n This example shows how to execute stored procedures.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_insert_item', NULL, N'en', N'Insert Item', NULL, N'The procedure inserts a new item. \r\n \r\n The procedure also uses stored procedures to select parameter values as id and name pairs.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_print_as_html', NULL, N'en', N'Print as HTML', NULL, N'The procedure prints the active table data to HTML.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_rename_item', NULL, N'en', N'Rename Item', NULL, N'The procedure renames an item. \r\n \r\n This example shows how to execute stored procedures.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_set_brand_acer', NULL, N'en', N'Filter Items of Acer', NULL, N'The procedure sets the brand parameter value to Acer and reloads the active table data. \r\n \r\n This example shows how to change active query parameters using server-side event handlers.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_set_brand_asus', NULL, N'en', N'Filter Items of ASUS', NULL, N'The procedure sets the brand parameter value to ASUS and reloads the active table data. \r\n \r\n This example shows how to change active query parameters using server-side event handlers.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'amount', N'es', N'Monto', N'El complemento actualiza un valor modificado en una base de datos inmediatamente después del cambio mediante un controlador de eventos de cambio.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'brand_id', N'es', N'Marca', N'El complemento utiliza un procedimiento almacenado para seleccionar valores. \r\n \r\n Los valores de la lista dependen de los valores de los parámetros category_id y subcategory_id. \r\n \r\n La lista contiene pares de identificación y nombre. \r\n \r\n El complemento usa valores de nombre para mostrar en la cinta y valores de identificación para pasar como valores de parámetro.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'category_id', N'es', N'Categoría', N'El complemento utiliza un procedimiento almacenado para seleccionar valores. \r\n \r\n La lista contiene pares de identificación y nombre. \r\n \r\n El complemento usa valores de nombre para mostrar en la cinta y valores de identificación para pasar como valores de parámetro.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'name', N'es', N'Nombre', N'El complemento protege los valores de los cambios mediante un controlador de eventos de cambio.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'price', N'es', N'Precio', N'El complemento guarda un valor modificado en una base de datos justo después del cambio mediante un controlador de eventos de cambio. \r\n \r\n Este ejemplo también muestra cómo mostrar un mensaje de retroalimentación de un controlador.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'subcategory_id', N'es', N'Subcategoría', N'El complemento utiliza un procedimiento almacenado para seleccionar valores. \r\n \r\n Los valores de la lista dependen del valor del parámetro category_id. \r\n El complemento deshabilita un parámetro si no hay valores relacionados con la categoría. \r\n \r\n El complemento usa valores de nombre para mostrar en la cinta y valores de identificación para pasar como valores de parámetro.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'total', N'es', N'Total', N'La columna contiene valores calculados por una fórmula regular de Excel. \r\n \r\n El complemento protege la fórmula de cambios mediante un controlador de eventos de cambio.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'Search {name}', NULL, N'es', N'Buscar {name}', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessageNonAmountChanged', N'es', NULL, N'Ha cambiado la columna protegida ''% s''. \r\n \r\n El complemento restaurará el valor anterior. \r\n \r\n Solo puede cambiar la columna Monto. \r\n \r\n Este ejemplo muestra cómo proteger valores y fórmulas utilizando controladores de eventos de cambio.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessageNonItemChanged', N'es', NULL, N'Ha cambiado una fila de categoría. \r\n \r\n El complemento restaurará el valor anterior. \r\n \r\n Este ejemplo muestra cómo proteger valores y fórmulas utilizando controladores de eventos de cambio.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessagePriceChanged', N'es', NULL, N'Ha cambiado el valor del precio. \r\n \r\n Este ejemplo muestra cómo notificar a los usuarios desde un controlador de eventos sin la acción de deshacer. \r\n \r\n Puede deshacer la acción usted mismo en Microsoft Excel (Ctrl-Z).', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'usp_order_form', NULL, N'es', N'Formulario de pedido', N'Formulario de pedido', N'Este procedimiento almacenado selecciona un formulario de pedido. \r\n \r\n Tiene parámetros como pares de identificación y nombre colocados en la cinta. \r\n \r\n Además, subcategory_id y brand_id dependen de category_id.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_clear', NULL, N'es', N'Borrar un formulario', NULL, N'Este procedimiento elimina los artículos del pedido y vuelve a cargar los datos de la tabla activa.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_clear_brands', NULL, N'es', N'Borrar un filtro de marca', NULL, N'Este procedimiento establece el valor del parámetro de marcas en NULL y vuelve a cargar los datos de la tabla activa. \r\n \r\n Este ejemplo muestra cómo cambiar los parámetros de consulta activos utilizando controladores de eventos del lado del servidor.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_delete_item', NULL, N'es', N'Eliminar un artículo', NULL, N'Este procedimiento elimina un elemento. \r\n \r\n Este ejemplo muestra cómo ejecutar procedimientos almacenados.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_insert_item', NULL, N'es', N'Insertar un artículo', NULL, N'Este procedimiento inserta un nuevo elemento. \r\n \r\n Este procedimiento también usa procedimientos almacenados para seleccionar valores de parámetros como pares de identificación y nombre.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_print_as_html', NULL, N'es', N'Imprimir como HTML', NULL, N'Este procedimiento imprime los datos de la tabla activa en HTML.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_rename_item', NULL, N'es', N'Cambiar el nombre de elemento', NULL, N'Este procedimiento cambia el nombre de un elemento. \r\n \r\n Este ejemplo muestra cómo ejecutar procedimientos almacenados.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_set_brand_acer', NULL, N'es', N'Filtrar los elementos de Acer', NULL, N'Este procedimiento establece el valor del parámetro de marca en Acer y vuelve a cargar los datos de la tabla activa. \r\n \r\n Este ejemplo muestra cómo cambiar los parámetros de consulta activos utilizando controladores de eventos del lado del servidor.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_set_brand_asus', NULL, N'es', N'Filtrar los elementos de ASUS', NULL, N'Este procedimiento establece el valor del parámetro de marca en ASUS y vuelve a cargar los datos de la tabla activa. \r\n \r\n Este ejemplo muestra cómo cambiar los parámetros de consulta activos utilizando controladores de eventos del lado del servidor.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'amount', N'fr', N'Quantité', N'Le complément met à jour une valeur modifiée dans une base de données juste après la modification à l''aide d''un gestionnaire d''événements de modification.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'brand_id', N'fr', N'Marque', N'Le complément utilise une procédure stockée pour sélectionner des valeurs. \r\n \r\n Les valeurs de la liste dépendent des valeurs des paramètres category_id et subcategory_id. \r\n \r\n La liste contient des paires d''identifiant et de nom. \r\n \r\n Le complément utilise des valeurs de nom à afficher sur le ruban et des valeurs d''identification à transmettre en tant que valeurs de paramètre.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'category_id', N'fr', N'Catégorie', N'Le complément utilise une procédure stockée pour sélectionner des valeurs. \r\n \r\n La liste contient des paires d''identifiant et de nom. \r\n \r\n Le complément utilise des valeurs de nom à afficher sur le ruban et des valeurs d''identification à transmettre en tant que valeurs de paramètre.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'name', N'fr', N'Nom', N'Le complément protège les valeurs des modifications à l''aide d''un gestionnaire d''événements de modification.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'price', N'fr', N'Prix', N'Le complément enregistre une valeur modifiée dans une base de données juste après la modification à l''aide d''un gestionnaire d''événements de modification. \r\n \r\n Cet exemple montre également comment afficher un message de retour d''un gestionnaire.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'subcategory_id', N'fr', N'Sous-catégorie', N'Le complément utilise une procédure stockée pour sélectionner des valeurs. \r\n \r\n Les valeurs de la liste dépendent de la valeur du paramètre category_id. \r\n Le complément désactive un paramètre s''il n''y a pas de valeurs liées à la catégorie. \r\n \r\n Le complément utilise des valeurs de nom à afficher sur le ruban et des valeurs d''identification à transmettre en tant que valeurs de paramètre.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'total', N'fr', N'Totale', N'La colonne contient des valeurs calculées par une formule Excel régulière. \r\n \r\n Le complément protège la formule des modifications à l''aide d''un gestionnaire d''événements de modification.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'Search {name}', NULL, N'fr', N'Rechercher {nom}', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessageNonAmountChanged', N'fr', NULL, N'Vous avez modifié la colonne protégée ''%s''. \r\n \r\n Le complément restaurera la valeur précédente. \r\n \r\n Vous ne pouvez modifier que la colonne Quantité. \r\n \r\n Cet exemple montre comment protéger les valeurs et les formules à l''aide des gestionnaires d''événements de modification.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessageNonItemChanged', N'fr', NULL, N'Vous avez modifié une ligne de catégorie. \r\n \r\n Le complément restaurera la valeur précédente. \r\n \r\n Cet exemple montre comment protéger les valeurs et les formules à l''aide des gestionnaires d''événements de modification.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessagePriceChanged', N'fr', NULL, N'Vous avez modifié la valeur du prix. \r\n \r\n Cet exemple montre comment notifier les utilisateurs à partir d''un gestionnaire d''événements sans l''action d''annulation. \r\n \r\n Vous pouvez annuler l''action vous-même dans Microsoft Excel (Ctrl-Z).', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'usp_order_form', NULL, N'fr', N'Bon de commande', N'Bon de commande', N'Cette procédure sélectionne un bon de commande. \r\n \r\n Il a des paramètres comme paires d''identifiant et de nom placés sur le ruban. \r\n \r\n En outre, subcategory_id et brand_id dépendent de category_id.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_clear', NULL, N'fr', N'Effacer un formulaire', NULL, N'Cette procédure supprime les postes de commande et recharge les données de la table active.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_clear_brands', NULL, N'fr', N'Effacer un filtre de marque', NULL, N'Cette procédure définit la valeur du paramètre marques sur NULL et recharge les données de la table active. \r\n \r\n Cet exemple montre comment modifier les paramètres de requête actifs à l''aide de gestionnaires d''événements côté serveur.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_delete_item', NULL, N'fr', N'Supprimer un élément', NULL, N'Cette procédure supprime un élément. \r\n \r\n Cet exemple montre comment exécuter des procédures stockées.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_insert_item', NULL, N'fr', N'Insérer un élément', NULL, N'Cette procédure insère un nouvel élément. \r\n \r\n Cette procédure utilise également des procédures stockées pour sélectionner les valeurs des paramètres en tant que paires d''identifiant et de nom.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_print_as_html', NULL, N'fr', N'Imprimer en HTML', NULL, N'Cette procédure imprime les données de la table active au format HTML.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_rename_item', NULL, N'fr', N'Renommer un élément', NULL, N'Cette procédure renomme un élément. \r\n \r\n Cet exemple montre comment exécuter des procédures stockées.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_set_brand_acer', NULL, N'fr', N'Filtrer les articles d''Acer', NULL, N'Cette procédure définit la valeur du paramètre de marque sur Acer et recharge les données de la table active. \r\n \r\n Cet exemple montre comment modifier les paramètres de requête actifs à l''aide de gestionnaires d''événements côté serveur.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_set_brand_asus', NULL, N'fr', N'Filtrer les articles d''ASUS', NULL, N'Cette procédure définit la valeur du paramètre de marque sur ASUS et recharge les données de la table active. \r\n \r\n Cet exemple montre comment modifier les paramètres de requête actifs à l''aide de gestionnaires d''événements côté serveur.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'amount', N'it', N'Quantità', N'Il componente aggiuntivo aggiorna un valore modificato in un database subito dopo la modifica utilizzando un gestore di eventi di modifica.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'brand_id', N'it', N'Marca', N'Il componente aggiuntivo utilizza una stored procedure per selezionare i valori. \r\n \r\n I valori dell''elenco dipendono dai valori dei parametri category_id e subcategory_id. \r\n \r\n L''elenco contiene coppie di nomi e ID. \r\n \r\n Il componente aggiuntivo utilizza valori di nome da visualizzare sulla barra multifunzione e valori di ID da passare come valori di parametro.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'category_id', N'it', N'Categoria', N'Il componente aggiuntivo utilizza una stored procedure per selezionare i valori. \r\n \r\n L''elenco contiene coppie di nomi e ID. \r\n \r\n Il componente aggiuntivo utilizza valori di nome da visualizzare sulla barra multifunzione e valori di ID da passare come valori di parametro.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'name', N'it', N'Nome', N'Il componente aggiuntivo protegge i valori dalle modifiche utilizzando un gestore di eventi di modifica.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'price', N'it', N'Prezzo', N'Il componente aggiuntivo salva un valore modificato in un database subito dopo la modifica utilizzando un gestore di eventi di modifica. \r\n \r\n Questo esempio mostra anche come mostrare un messaggio di feedback da un gestore.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'subcategory_id', N'it', N'Sottocategoria', N'Il componente aggiuntivo utilizza una stored procedure per selezionare un valore. \r\n \r\n I valori dell''elenco dipendono dal valore del parametro category_id. \r\n Il componente aggiuntivo disabilita un parametro se non sono presenti valori relativi alla categoria. \r\n \r\n Il componente aggiuntivo utilizza valori di nome da visualizzare sulla barra multifunzione e valori di ID da passare come valori di parametro.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'total', N'it', N'Totale', N'La colonna contiene valori calcolati da una normale formula di Excel. \r\n \r\n Il componente aggiuntivo protegge la formula dalle modifiche utilizzando un gestore di eventi di modifica.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'Search {name}', NULL, N'it', N'Cerca {nome}', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessageNonAmountChanged', N'it', NULL, N'Hai cambiato la colonna ''%s'' protetta. \r\n \r\n Il componente aggiuntivo ripristinerà il valore precedente. \r\n \r\n È possibile modificare solo la colonna Quantità. \r\n \r\n Questo esempio mostra come proteggere valori e formule utilizzando gestori di eventi di modifica.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessageNonItemChanged', N'it', NULL, N'Hai modificato una riga di categoria. \r\n \r\n Il componente aggiuntivo ripristinerà il valore precedente. \r\n \r\n Questo esempio mostra come proteggere valori e formule utilizzando gestori di eventi di modifica.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessagePriceChanged', N'it', NULL, N'Hai modificato il valore del prezzo. \r\n \r\n Questo esempio mostra come inviare una notifica agli utenti da un gestore di eventi senza l''azione di annullamento. \r\n \r\n Puoi annullare tu stesso l''azione in Microsoft Excel (Ctrl-Z).', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'usp_order_form', NULL, N'it', N'Modulo d''ordine', N'Modulo d''ordine', N'Questa procedura seleziona un modulo d''ordine. \r\n \r\n Ha parametri come id e coppie di nomi posizionati sulla barra multifunzione. \r\n \r\n Inoltre, subcategory_id e brand_id dipendono da category_id.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_clear', NULL, N'it', N'Cancella modulo', NULL, N'Questa procedura elimina gli articoli dell''ordine e ricarica i dati della tabella attiva.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_clear_brands', NULL, N'it', N'Cancella filtro di marca', NULL, N'Questa procedura imposta il valore del parametro marche su NULL e ricarica i dati della tabella attiva. \r\n \r\n Questo esempio mostra come modificare i parametri di query attivi utilizzando gestori di eventi lato server.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_delete_item', NULL, N'it', N'Elimina elemento', NULL, N'Questa procedura elimina un elemento. \r\n \r\n Questo esempio mostra come eseguire le stored procedure.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_insert_item', NULL, N'it', N'Inserisci elemento', NULL, N'Questa procedura inserisce un nuovo elemento. \r\n \r\n Questa procedura utilizza anche le stored procedure per selezionare i valori dei parametri come coppie ID e nomi.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_print_as_html', NULL, N'it', N'Stampa come HTML', NULL, N'Questa procedura stampa i dati della tabella attiva in HTML.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_rename_item', NULL, N'it', N'Rinominare elemento', NULL, N'Questa procedura rinomina un elemento. \r\n \r\n Questo esempio mostra come eseguire le stored procedure.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_set_brand_acer', NULL, N'it', N'Filtra gli elementi di Acer', NULL, N'Questa procedura imposta il valore del parametro del marchio su Acer e ricarica i dati della tabella attiva. \r\n \r\n Questo esempio mostra come modificare i parametri di query attivi utilizzando gestori di eventi lato server.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_set_brand_asus', NULL, N'it', N'Filtra gli elementi di ASUS', NULL, N'Questa procedura imposta il valore del parametro del marchio su ASUS e ricarica i dati della tabella attiva. \r\n \r\n Questo esempio mostra come modificare i parametri di query attivi utilizzando gestori di eventi lato server.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'amount', N'ru', N'Кол-во', N'Плагин обновляет измененное значение в базе данных сразу после изменения с помощью обработчика событий изменения.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'brand_id', N'ru', N'Марка', N'Плагин использует хранимую процедуру для выбора значений. \r\n \r\n Значения списка зависят от значений параметров category_id и subcategory_id. \r\n \r\n Список содержит пары идентификаторов и имен. \r\n \r\n Плагин использует значения имен для отображения на ленте и значения идентификаторов для передачи в качестве значений параметров.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'category_id', N'ru', N'Категория', N'Плагин использует хранимую процедуру для выбора значений. \r\n \r\n Список содержит пары идентификаторов и имен. \r\n \r\n Плагин использует значения имен для отображения на ленте и значения идентификаторов для передачи в качестве значений параметров.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'name', N'ru', N'Наименование', N'Плагин защищает значения от изменений с помощью обработчика событий изменения.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'price', N'ru', N'Цена', N'Плагин сохраняет измененное значение в базе данных сразу после изменения с помощью обработчика событий изменения. \r\n \r\n В этом примере также показано, как показать сообщение обратной связи от обработчика.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'subcategory_id', N'ru', N'Подкатегория', N'Плагин использует хранимую процедуру для выбора значений. \r\n \r\n Значения списка зависят от значения параметра category_id. \r\n Плагин отключает параметр, если для категории нет значений. \r\n \r\n Плагин использует значения имен для отображения на ленте и значения идентификаторов для передачи в качестве значений параметров.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', NULL, N'total', N'ru', N'Всего', N'Столбец содержит значения, рассчитанные обычной формулой Excel. \r\n \r\n Плагин защищает формулу от изменений с помощью обработчика событий изменения.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'Search {name}', NULL, N'ru', N'Поиск {name}', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessageNonAmountChanged', N'ru', NULL, N'Вы изменили защищенный столбец "%s". \r\n \r\n Плагин восстановит предыдущее значение. \r\n \r\n Вы можете изменить только столбец "Кол-во". \r\n \r\n В этом примере показано, как защитить значения и формулы с помощью обработчиков событий изменения.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessageNonItemChanged', N'ru', NULL, N'Вы изменили строку категории. \r\n \r\n Плагин восстановит предыдущее значение. \r\n \r\n В этом примере показано, как защитить значения и формулы с помощью обработчиков событий изменения.', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'strings', N'MessagePriceChanged', N'ru', NULL, N'Вы изменили значение цены. \r\n \r\n В этом примере показано, как уведомить пользователей из обработчика событий без действия отмены. \r\n \r\n Вы можете отменить действие самостоятельно в Microsoft Excel (Ctrl-Z).', NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'usp_order_form', NULL, N'ru', N'Форма заказа', N'Форма заказа', N'Эта хранимая процедура выбирает формы заказа. \r\n \r\n Она имеет параметры в виде пар идентификаторов и имен, размещенных на ленте. \r\n \r\n Кроме того, subcategory_id и brand_id зависят от category_id.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_clear', NULL, N'ru', N'Очистить форму', NULL, N'Процедура удаляет данные таблицы корзины и перезагружает данные активной таблицы.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_clear_brands', NULL, N'ru', N'Очистить выбор марки', NULL, N'Процедура устанавливает значение параметра торговой марки в NULL и перезагружает данные активной таблицы. \r\n \r\n В этом примере показано, как изменить параметры активного запроса с помощью серверных обработчиков событий.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_delete_item', NULL, N'ru', N'Удалить элемент', NULL, N'Процедура удаляет элемент. \r\n \r\n В этом примере показано, как выполнять хранимые процедуры.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_insert_item', NULL, N'ru', N'Вставить элемент', NULL, N'Процедура вставляет новый элемент. \r\n \r\n Процедура также использует хранимые процедуры для выбора значений параметров в виде пар идентификаторов и имен.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_print_as_html', NULL, N'ru', N'Печать в виде HTML', NULL, N'Процедура печатает данные активной таблицы в HTML.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_rename_item', NULL, N'ru', N'Переименовать элемент', NULL, N'Процедура переименовывает элемент. \r\n \r\n В этом примере показано, как выполнять хранимые процедуры.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_set_brand_acer', NULL, N'ru', N'Отфильтровать Acer', NULL, N'Процедура устанавливает значение параметра бренда для Acer и перезагружает данные активной таблицы. \r\n \r\n В этом примере показано, как изменить параметры активного запроса с помощью серверных обработчиков событий.');
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's04', N'xl_actions_items_set_brand_asus', NULL, N'ru', N'Отфильтровать ASUS', NULL, N'Процедура устанавливает значение параметра бренда на ASUS и перезагружает данные активной таблицы. \r\n \r\n В этом примере показано, как изменить параметры активного запроса с помощью серверных обработчиков событий.');
GO

INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 04 - Orders.xlsx', N'Sample 04 - Orders.xlsx', N'OrderForm=s04.usp_order_form,(Default),False,$B$3,,{"Parameters":{"category_id":null,"subcategory_id":null,"brand_id":null},"ListObjectName":"usp_order_form","WorkbookLanguage":"en"}', N's04');
GO

print 'Application installed';
