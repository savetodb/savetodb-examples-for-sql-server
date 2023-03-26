-- =============================================
-- Application: Sample 05 - Invoices
-- Version 10.8, January 9, 2023
--
-- Copyright 2018-2023 Gartle LLC
--
-- License: MIT
--
-- Prerequisites: SaveToDB Framework 8.19 or higher
-- =============================================

SET NOCOUNT ON
GO

CREATE SCHEMA s05;
GO

CREATE TABLE s05.brands (
    id int IDENTITY(1,1) NOT NULL
    , brand nvarchar(255) NOT NULL
    , CONSTRAINT PK_brands PRIMARY KEY (id)
    , CONSTRAINT IX_brands_brand UNIQUE (brand)
);
GO

CREATE TABLE s05.forms (
    id int IDENTITY(1,1) NOT NULL
    , form nvarchar(255) NOT NULL
    , template nvarchar(max) NULL
    , CONSTRAINT PK_forms PRIMARY KEY (id)
    , CONSTRAINT IX_forms_form UNIQUE (form)
);
GO

CREATE TABLE s05.pricing_categories (
    id int NOT NULL
    , pricing_category nvarchar(255) NOT NULL
    , CONSTRAINT PK_pricing_categories PRIMARY KEY (id)
    , CONSTRAINT IX_pricing_categories_pricing_category UNIQUE (pricing_category)
);
GO

CREATE TABLE s05.product_categories (
    id int IDENTITY(1,1) NOT NULL
    , category nvarchar(255) NOT NULL
    , parent_id int NULL
    , level tinyint NULL
    , sort_order int NULL
    , CONSTRAINT PK_product_categories PRIMARY KEY (id)
    , CONSTRAINT IX_product_categories_product_category UNIQUE (category)
);
GO

ALTER TABLE s05.product_categories ADD CONSTRAINT FK_product_categories_product_categories FOREIGN KEY (parent_id) REFERENCES s05.product_categories (id);
GO

CREATE TABLE s05.sellers (
    id int IDENTITY(1,1) NOT NULL
    , code nvarchar(20) NOT NULL
    , company nvarchar(100) NOT NULL
    , salesperson nvarchar(100) NULL
    , prepared_by nvarchar(100) NULL
    , phone nvarchar(100) NULL
    , email nvarchar(100) NULL
    , address nvarchar(255) NULL
    , slogan nvarchar(255) NULL
    , bank nvarchar(100) NULL
    , bank_address nvarchar(100) NULL
    , bank_swift nvarchar(50) NULL
    , account_holder nvarchar(100) NULL
    , account_number nvarchar(100) NULL
    , account_string1 nvarchar(100) NULL
    , account_string2 nvarchar(100) NULL
    , CONSTRAINT PK_sellers PRIMARY KEY (id)
    , CONSTRAINT IX_sellers_code UNIQUE (code)
);
GO

CREATE TABLE s05.customers (
    id int IDENTITY(1,1) NOT NULL
    , customer nvarchar(50) NOT NULL
    , company nvarchar(255) NOT NULL
    , contact nvarchar(255) NULL
    , phone nvarchar(255) NULL
    , email nvarchar(255) NULL
    , address nvarchar(255) NULL
    , sales_tax float NULL
    , pricing_category_id int NULL
    , CONSTRAINT PK_customers PRIMARY KEY (id)
    , CONSTRAINT IX_customers_customer UNIQUE (customer)
    , CONSTRAINT IX_customers_name UNIQUE (company)
);
GO

ALTER TABLE s05.customers ADD CONSTRAINT FK_customers_pricing_categories FOREIGN KEY (pricing_category_id) REFERENCES s05.pricing_categories (id) ON UPDATE CASCADE;
GO

CREATE TABLE s05.products (
    id int IDENTITY(1,1) NOT NULL
    , category_id int NULL
    , brand_id int NULL
    , sku nvarchar(50) NULL
    , product_name nvarchar(255) NOT NULL
    , CONSTRAINT PK_products PRIMARY KEY (id)
);
GO

ALTER TABLE s05.products ADD CONSTRAINT FK_products_brands FOREIGN KEY (brand_id) REFERENCES s05.brands (id);
GO

ALTER TABLE s05.products ADD CONSTRAINT FK_products_product_categories FOREIGN KEY (category_id) REFERENCES s05.product_categories (id) ON UPDATE CASCADE;
GO

CREATE TABLE s05.orders (
    id int IDENTITY(1,1) NOT NULL
    , order_date date NOT NULL
    , order_number nvarchar(50) NULL
    , seller_id int NULL
    , customer_id int NULL
    , expiration_date date NULL
    , delivery_date date NULL
    , due_date date NULL
    , CONSTRAINT PK_orders PRIMARY KEY (id)
);
GO

ALTER TABLE s05.orders ADD CONSTRAINT FK_orders_customers FOREIGN KEY (customer_id) REFERENCES s05.customers (id) ON UPDATE CASCADE;
GO

ALTER TABLE s05.orders ADD CONSTRAINT FK_orders_sellers FOREIGN KEY (seller_id) REFERENCES s05.sellers (id) ON UPDATE CASCADE;
GO

CREATE TABLE s05.product_prices (
    product_id int NOT NULL
    , pricing_category_id int NOT NULL
    , unit_price float NOT NULL
    , CONSTRAINT PK_product_prices_1 PRIMARY KEY (product_id, pricing_category_id)
);
GO

ALTER TABLE s05.product_prices ADD CONSTRAINT FK_prices_items FOREIGN KEY (product_id) REFERENCES s05.products (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

ALTER TABLE s05.product_prices ADD CONSTRAINT FK_product_prices_pricing_categories FOREIGN KEY (pricing_category_id) REFERENCES s05.pricing_categories (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

CREATE TABLE s05.order_details (
    id int IDENTITY(1,1) NOT NULL
    , order_id int NOT NULL
    , product_id int NOT NULL
    , amount float NULL
    , unit_price float NULL
    , subtotal float NULL
    , sales_tax float NULL
    , total float NULL
    , discount float NULL
    , CONSTRAINT PK_positions PRIMARY KEY (id)
);
GO

ALTER TABLE s05.order_details ADD CONSTRAINT FK_order_details_orders FOREIGN KEY (order_id) REFERENCES s05.orders (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

ALTER TABLE s05.order_details ADD CONSTRAINT FK_order_details_products FOREIGN KEY (product_id) REFERENCES s05.products (id) ON DELETE CASCADE ON UPDATE CASCADE;
GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Returns a new order number
-- =============================================

CREATE FUNCTION [s05].[get_new_order_number]
(
)
RETURNS nvarchar(25)
AS
BEGIN

DECLARE @result nvarchar(25)

SELECT
    @result = SUBSTRING(REPLACE(CONVERT(nvarchar(10), GETDATE(), 120), '-', ''), 3, 6)
                + RIGHT('000' + CAST(COUNT(*) + 1 AS nvarchar), 2)
FROM
    s05.orders o
WHERE
    o.order_date = CAST(GETDATE() AS date)

RETURN @result

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Order details
-- =============================================

CREATE VIEW [s05].[view_order_details]
AS

SELECT
    d.id
    , d.order_id
    , DATEADD(DAY, 1 - DATEPART(DAY, o.order_date), o.order_date) AS order_month
    , CAST(o.order_date AS datetime) AS order_date
    , o.order_number
    , CAST(o.expiration_date AS datetime) AS expiration_date
    , CAST(o.delivery_date AS datetime) AS delivery_date
    , CAST(o.due_date AS datetime) AS due_date
    , c.customer AS customer
    , s.code AS seller
    , pc.category
    , b.brand
    , p.sku
    , p.product_name
    , CASE WHEN d.amount = 0 THEN NULL ELSE d.unit_price + ROUND(COALESCE(d.discount, 0) / d.amount, 2) END AS base_unit_price
    , d.discount
    , d.amount
    , d.unit_price
    , d.subtotal
    , d.sales_tax
    , d.total
FROM
    s05.order_details d
    INNER JOIN s05.orders o ON o.id = d.order_id
    INNER JOIN s05.products p ON p.id = d.product_id
    LEFT OUTER JOIN s05.customers c ON c.id = o.customer_id
    LEFT OUTER JOIN s05.sellers s ON s.id = o.seller_id
    LEFT OUTER JOIN s05.product_categories pc ON pc.id = p.category_id
    LEFT OUTER JOIN s05.brands b ON b.id = p.brand_id


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Orders
-- =============================================

CREATE VIEW [s05].[view_orders]
AS

SELECT
    o.id
    , DATEADD(DAY, 1 - DATEPART(DAY, o.order_date), o.order_date) AS order_month
    , CAST(o.order_date AS datetime) AS order_date
    , o.order_number
    , CAST(o.expiration_date AS datetime) AS expiration_date
    , CAST(o.delivery_date AS datetime) AS delivery_date
    , CAST(o.due_date AS datetime) AS due_date
    , o.customer_id
    , o.seller_id
    , d.discount
    , d.items
    , d.amount
    , d.subtotal
    , d.sales_tax
    , d.total
FROM
    s05.orders o
    LEFT OUTER JOIN (
        SELECT
            d.order_id
            , COUNT(*) AS items
            , SUM(d.amount) AS amount
            , SUM(d.discount) AS discount
            , SUM(d.subtotal) AS subtotal
            , SUM(d.sales_tax) AS sales_tax
            , SUM(d.total) AS total
        FROM
            s05.order_details d
        WHERE
            d.amount IS NOT NULL
        GROUP BY
            d.order_id
    ) d ON d.order_id = o.id
    LEFT OUTER JOIN s05.customers c ON c.id = o.customer_id


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Order details
-- =============================================

CREATE PROCEDURE [s05].[usp_order_details]
    @category_id int = NULL
    , @subcategory_id int = NULL
    , @brand_id int = NULL
    , @order_id int = NULL
    , @show_all bit = NULL
AS
BEGIN

IF @show_all IS NULL
    SET @show_all = 1

SELECT
    t.id
    , t.[level]
    , t.sku
    , t.product_name
    , COALESCE(d.unit_price, p.unit_price) AS unit_price
    , d.amount
    , '=[@[unit_price]]*[@amount]' AS subtotal
    , CASE WHEN c.sales_tax IS NULL THEN NULL ELSE '=ROUND([@subtotal]*' + CAST(c.sales_tax AS nvarchar) + ',2)' END AS sales_tax
    , '=[@subtotal]+[@[sales_tax]]' AS total
FROM
    (
    SELECT
        NULL AS [id]
        , c.[level]
        , c.id AS category_id
        , NULL AS subcategory_id
        , NULL AS brand_id
        , NULL AS sku
        , c.category AS product_name
        , c.category AS category
        , NULL AS subcategory
        , NULL AS brand
        , c.sort_order AS category_sort_order
        , NULL AS subcategory_sort_order
    FROM
        s05.product_categories c
    WHERE
        c.[level] = 1
        AND c.id = COALESCE(@category_id, c.id)
        AND (@subcategory_id IS NULL OR c.id IN (
            SELECT parent_id FROM s05.product_categories WHERE id = @subcategory_id
            ))
        AND (@brand_id IS NULL OR c.id IN (
            SELECT s.parent_id FROM s05.products p INNER JOIN s05.product_categories s ON s.id = p.category_id WHERE p.brand_id = @brand_id
            ))
        AND (@show_all IS NULL OR @show_all = 1 OR c.id IN (
            SELECT s.parent_id FROM s05.order_details d INNER JOIN s05.products p ON p.id = d.product_id INNER JOIN s05.product_categories s ON s.id = p.category_id WHERE d.order_id = @order_id
            ))
    UNION ALL
    SELECT
        NULL AS [id]
        , s.[level]
        , c.id category_id
        , s.id AS subcategory_id
        , NULL AS brand_id
        , NULL AS sku
        , s.category AS product_name
        , c.category AS category
        , s.category AS subcategory
        , NULL AS brand
        , c.sort_order AS category_sort_order
        , s.sort_order AS subcategory_sort_order
    FROM
        s05.product_categories s
        INNER JOIN s05.product_categories c ON c.id = s.parent_id
    WHERE
        s.[level] = 2
        AND c.id = COALESCE(@category_id, c.id)
        AND COALESCE(s.id, 0) = COALESCE(@subcategory_id, COALESCE(s.id, 0))
        AND (@brand_id IS NULL OR s.id IN (
            SELECT category_id FROM s05.products WHERE brand_id = @brand_id
            ))
        AND (@show_all IS NULL OR @show_all = 1 OR s.id IN (
            SELECT p.category_id FROM s05.order_details d INNER JOIN s05.products p ON p.id = d.product_id WHERE d.order_id = @order_id
            ))
    UNION ALL
    SELECT
        t.[id]
        , s.[level] + 1 AS [level]
        , c.id AS category_id
        , s.id AS subcategory_id
        , b.id AS brand_id
        , t.sku
        , t.product_name
        , c.category AS category
        , s.category AS subcategory
        , b.brand
        , c.sort_order AS category_sort_order
        , s.sort_order AS subcategory_sort_order
    FROM
        s05.products t
        LEFT OUTER JOIN s05.product_categories s ON s.id = t.category_id
        LEFT OUTER JOIN s05.product_categories c ON c.id = s.parent_id
        LEFT OUTER JOIN s05.brands b ON b.id = t.brand_id
    WHERE
        c.id = COALESCE(@category_id, c.id)
        AND COALESCE(s.id, 0) = COALESCE(@subcategory_id, COALESCE(s.id, 0))
        AND COALESCE(t.brand_id, 0) = COALESCE(@brand_id, COALESCE(t.brand_id, 0))
        AND (@show_all IS NULL OR @show_all = 1 OR t.id IN (
            SELECT product_id FROM s05.order_details d WHERE d.order_id = @order_id
            ))
    ) t
    LEFT OUTER JOIN s05.orders o ON o.id = @order_id
    LEFT OUTER JOIN s05.order_details d ON d.product_id = t.id AND d.order_id = o.id
    LEFT OUTER JOIN s05.customers c ON c.id = o.customer_id
    LEFT OUTER JOIN s05.product_prices p ON p.product_id = t.id AND p.pricing_category_id = c.pricing_category_id
ORDER BY
    t.category_sort_order
    , t.category
    , t.subcategory_sort_order
    , t.subcategory
    , t.brand
    , t.product_name

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Order header
-- =============================================

CREATE PROCEDURE [s05].[usp_order_header]
    @order_id int = NULL
AS
BEGIN

SELECT
    TOP 1
    o.id
    , c.sales_tax
    , o.seller_id
    , o.customer_id
    , CAST(o.order_date AS datetime) AS order_date
    , o.order_number
    , CAST(o.expiration_date AS datetime) AS expiration_date
    , CAST(o.delivery_date AS datetime) AS delivery_date
    , CAST(o.due_date AS datetime) AS due_date
FROM
    s05.orders o
    LEFT OUTER JOIN s05.customers c ON c.id = o.customer_id
WHERE
    o.id = @order_id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Order print details
-- =============================================

CREATE PROCEDURE [s05].[usp_order_print_details]
    @order_id int = NULL
AS
BEGIN

SELECT
    t.id
    , COALESCE(o.order_number, o.id)        AS order_number
    , CAST(o.order_date AS datetime)        AS order_date
    , CAST(o.expiration_date AS datetime)   AS expiration_date
    , CAST(o.delivery_date AS datetime)     AS delivery_date
    , CAST(o.due_date AS datetime)          AS due_date
    , s.code            AS seller
    , s.company         AS seller_company
    , s.slogan          AS seller_slogan
    , s.salesperson     AS seller_salesperson
    , s.prepared_by     AS seller_prepared_by
    , s.phone           AS seller_phone
    , s.email           AS seller_email
    , s.[address]       AS seller_address
    , s.bank            AS seller_bank
    , s.bank_address    AS seller_bank_address
    , s.bank_swift      AS seller_bank_swift
    , s.account_holder  AS seller_account_holder
    , s.account_number  AS seller_account_number
    , s.account_string1 AS seller_account_string1
    , s.account_string2 AS seller_account_string2
    , c.customer        AS customer_customer
    , c.company         AS customer_company
    , c.contact         AS customer_contact
    , c.phone           AS customer_phone
    , c.email           AS customer_email
    , c.[address]       AS customer_address
    , c.sales_tax       AS customer_sales_tax
    , ROW_NUMBER() OVER(ORDER BY pc.sort_order, pc.category, ps.sort_order, ps.category, b.brand, t.product_name) AS item
    , t.sku
    , t.product_name
    , CASE WHEN d.amount = 0 THEN NULL ELSE d.unit_price + ROUND(COALESCE(d.discount, 0) / d.amount, 2) END AS base_unit_price
    , d.discount
    , d.amount
    , d.unit_price
    , d.subtotal
    , d.sales_tax
    , d.total
FROM
    s05.order_details d
    INNER JOIN s05.orders o ON o.id = d.order_id
    INNER JOIN s05.products t ON t.id = d.product_id
    LEFT OUTER JOIN s05.customers c ON c.id = o.customer_id
    LEFT OUTER JOIN s05.sellers s ON s.id = o.seller_id
    LEFT OUTER JOIN s05.product_prices p ON p.product_id = t.id AND p.pricing_category_id = c.pricing_category_id
    LEFT OUTER JOIN s05.product_categories ps ON ps.id = t.category_id
    LEFT OUTER JOIN s05.product_categories pc ON pc.id = ps.parent_id
    LEFT OUTER JOIN s05.brands b ON b.id = t.brand_id
WHERE
    d.order_id = @order_id
    AND d.amount > 0
ORDER BY
    item

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Invoice print details
-- =============================================

CREATE PROCEDURE [s05].[usp_invoice_print_details]
    @order_id int = NULL
AS
BEGIN

EXEC [s05].[usp_order_print_details] @order_id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Products
-- =============================================

CREATE PROCEDURE [s05].[usp_products]
    @category_id int = NULL
    , @subcategory_id int = NULL
    , @brand_id int = NULL
    , @pricing_category_id int = NULL
AS
BEGIN

IF @pricing_category_id IS NULL
    SET @pricing_category_id = 1

SELECT
    t.id
    , t.[level]
    , t.category_id
    , t.subcategory_id
    , t.brand_id
    , t.sku
    , t.product_name
    , t.unit_price
    --, t.category
    --, t.subcategory
    --, t.brand
    --, t.category_sort_order
    --, t.subcategory_sort_order
FROM
    (
    SELECT
        NULL AS [id]
        , c.[level]
        , c.id AS category_id
        , NULL AS subcategory_id
        , NULL AS brand_id
        , NULL AS sku
        , c.category AS product_name
        , NULL AS unit_price
        , c.category AS category
        , NULL AS subcategory
        , NULL AS brand
        , c.sort_order AS category_sort_order
        , NULL AS subcategory_sort_order
    FROM
        s05.product_categories c
    WHERE
        c.[level] = 1
        AND c.id = COALESCE(@category_id, c.id)
        AND (@subcategory_id IS NULL OR c.id IN (
            SELECT parent_id FROM s05.product_categories WHERE id = @subcategory_id
            ))
        AND (@brand_id IS NULL OR c.id IN (
            SELECT s.parent_id FROM s05.products p INNER JOIN s05.product_categories s ON s.id = p.category_id WHERE p.brand_id = @brand_id
            ))
    UNION ALL
    SELECT
        NULL AS [id]
        , s.[level]
        , c.id category_id
        , s.id AS subcategory_id
        , NULL AS brand_id
        , NULL AS sku
        , s.category AS product_name
        , NULL AS unit_price
        , c.category AS category
        , s.category AS subcategory
        , NULL AS brand
        , c.sort_order AS category_sort_order
        , s.sort_order AS subcategory_sort_order
    FROM
        s05.product_categories s
        INNER JOIN s05.product_categories c ON c.id = s.parent_id
    WHERE
        s.[level] = 2
        AND c.id = COALESCE(@category_id, c.id)
        AND COALESCE(s.id, 0) = COALESCE(@subcategory_id, COALESCE(s.id, 0))
        AND (@brand_id IS NULL OR s.id IN (
            SELECT category_id FROM s05.products WHERE brand_id = @brand_id
            ))
    UNION ALL
    SELECT
        t.[id]
        , s.[level] + 1 AS [level]
        , c.id AS category_id
        , s.id AS subcategory_id
        , b.id AS brand_id
        , t.sku AS sku
        , t.product_name
        , p.unit_price
        , c.category AS category
        , s.category AS subcategory
        , b.brand
        , c.sort_order AS category_sort_order
        , s.sort_order AS subcategory_sort_order
    FROM
        s05.products t
        LEFT OUTER JOIN s05.product_categories s ON s.id = t.category_id
        LEFT OUTER JOIN s05.product_categories c ON c.id = s.parent_id
        LEFT OUTER JOIN s05.brands b ON b.id = t.brand_id
        LEFT OUTER JOIN s05.product_prices p ON p.product_id = t.id AND p.pricing_category_id = @pricing_category_id
    WHERE
        c.id = COALESCE(@category_id, c.id)
        AND COALESCE(s.id, 0) = COALESCE(@subcategory_id, COALESCE(s.id, 0))
        AND COALESCE(t.brand_id, 0) = COALESCE(@brand_id, COALESCE(t.brand_id, 0))
    ) t
ORDER BY
    t.category_sort_order
    , t.category
    , t.subcategory_sort_order
    , t.subcategory
    , t.brand
    , t.product_name

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Quote print details
-- =============================================

CREATE PROCEDURE [s05].[usp_quote_print_details]
    @order_id int = NULL
AS
BEGIN

EXEC [s05].[usp_order_print_details] @order_id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Clears order positions
-- =============================================

CREATE PROCEDURE [s05].[xl_actions_order_clear]
    @order_id int = NULL
AS
BEGIN

-- UPDATE s05.order_details SET amount = NULL WHERE order_id = @order_id
DELETE FROM s05.order_details WHERE order_id = @order_id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Creates a new order copy
-- =============================================

CREATE PROCEDURE [s05].[xl_actions_order_copy]
    @order_id int = NULL
AS
BEGIN

IF @order_id IS NULL
    BEGIN
    INSERT INTO s05.orders (order_date, order_number, seller_id)
    SELECT
        GETDATE()
        , s05.get_new_order_number()
        , (SELECT seller_id FROM s05.orders o WHERE o.id = (SELECT MAX(id) FROM s05.orders))
    END
ELSE
    BEGIN
    INSERT INTO s05.orders (order_date, order_number, seller_id)
    SELECT
        GETDATE()
        , s05.get_new_order_number()
        , (SELECT seller_id FROM s05.orders o WHERE o.id = @order_id)
    END

DECLARE @new_order_id int = SCOPE_IDENTITY()

INSERT INTO s05.order_details (order_id, product_id, amount, unit_price, subtotal, sales_tax, total, discount)
SELECT
    @new_order_id, d.product_id, d.amount, d.unit_price, d.subtotal, d.sales_tax, d.total, d.discount
FROM
    s05.order_details d
WHERE
    d.order_id = @order_id

SELECT
    @new_order_id AS order_id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Creates a new order
-- =============================================

CREATE PROCEDURE [s05].[xl_actions_order_create]
    @order_id int = NULL
AS
BEGIN

IF @order_id IS NULL
    BEGIN
    INSERT INTO s05.orders (order_date, order_number, seller_id)
    SELECT
        GETDATE()
        , s05.get_new_order_number()
        , (SELECT seller_id FROM s05.orders o WHERE o.id = (SELECT MAX(id) FROM s05.orders))
    END
ELSE
    BEGIN
    INSERT INTO s05.orders (order_date, order_number, seller_id)
    SELECT
        GETDATE()
        , s05.get_new_order_number()
        , (SELECT seller_id FROM s05.orders o WHERE o.id = @order_id)
    END

DECLARE @new_order_id int = SCOPE_IDENTITY()

SELECT
    @new_order_id AS order_id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Prints an order
-- =============================================

CREATE PROCEDURE [s05].[xl_actions_order_print]
    @order_id int = NULL
    , @form_id int = NULL
AS
BEGIN

IF @form_id IS NULL
    SET @form_id = 1

SET NOCOUNT ON

DECLARE @order_number nvarchar(50)
DECLARE @order_date date
DECLARE @order_total money
DECLARE @customer_company nvarchar(255)
DECLARE @customer_contact nvarchar(255)
DECLARE @customer_phone nvarchar(255)
DECLARE @customer_email nvarchar(255)
DECLARE @customer_address nvarchar(255)
DECLARE @seller_company nvarchar(255)
DECLARE @seller_salesperson nvarchar(255)
DECLARE @seller_prepared_by nvarchar(255)
DECLARE @seller_phone nvarchar(255)
DECLARE @seller_email nvarchar(255)
DECLARE @seller_address nvarchar(255)

SELECT
    @order_number = COALESCE(o.order_number, CAST(o.id AS nvarchar))
    , @order_date = o.order_date

    , @customer_company     = COALESCE(c.company, '')
    , @customer_contact     = COALESCE(c.contact, '')
    , @customer_phone       = COALESCE(c.phone, '')
    , @customer_email       = COALESCE(c.email, '')
    , @customer_address     = COALESCE(c.[address], '')

    , @seller_company       = COALESCE(s.company, '')
    , @seller_salesperson   = COALESCE(s.salesperson, '')
    , @seller_prepared_by   = COALESCE(s.prepared_by, '')
    , @seller_address       = COALESCE(s.[address], '')
    , @seller_phone         = COALESCE(s.phone, '')
    , @seller_email         = COALESCE(s.email, '')
    , @seller_address       = COALESCE(s.[address], '')
FROM
    s05.orders o
    LEFT OUTER JOIN s05.customers c ON c.id = o.customer_id
    LEFT OUTER JOIN s05.sellers s ON s.id = o.seller_id

SET @order_total = ISNULL((SELECT SUM(COALESCE(t.unit_price * t.amount, 0)) FROM s05.order_details t WHERE t.order_id = @order_id AND t.amount IS NOT NULL), 0)

DECLARE @table nvarchar(MAX)

SET @table = ISNULL((
    SELECT
        ROW_NUMBER() OVER(ORDER BY pc.sort_order, pc.category, ps.sort_order, ps.category, b.brand, t.product_name) AS item
        , t.product_name
        , CAST(d.unit_price AS decimal(18,2)) AS unit_price
        , CAST(d.amount AS nvarchar) AS amount
        , CAST(d.total AS decimal(18,2)) AS total
    FROM
        s05.order_details d
        INNER JOIN s05.products t ON t.id = d.product_id
        LEFT OUTER JOIN s05.product_categories ps ON ps.id = t.category_id
        LEFT OUTER JOIN s05.product_categories pc ON pc.id = ps.parent_id
        LEFT OUTER JOIN s05.brands b ON b.id = t.brand_id
    WHERE
        d.order_id = @order_id
        AND d.amount IS NOT NULL
    ORDER BY
        item
    FOR XML PATH('tr')
    ), '')

SET @table = REPLACE(@table, '<item>', '<td class="item" >')
SET @table = REPLACE(@table, '<product_name>', '<td class="name" >')
SET @table = REPLACE(@table, '<unit_price>', '<td class="price" >')
SET @table = REPLACE(@table, '<amount>', '<td class="amount" >')
SET @table = REPLACE(@table, '<total>', '<td class="total" >')

SET @table = REPLACE(@table, '</item>', '</td>')
SET @table = REPLACE(@table, '</product_name>', '</td>')
SET @table = REPLACE(@table, '</unit_price>', '</td>')
SET @table = REPLACE(@table, '</amount>', '</td>')
SET @table = REPLACE(@table, '</total>', '</td>')
SET @table = REPLACE(@table, '</tr>', '</tr>' + CHAR(13) + CHAR(10))

DECLARE @html nvarchar(MAX)

SELECT @html = template FROM s05.forms WHERE id = @form_id

print @html

SET @html = REPLACE(@html, '{table}', @table)

SET @html = REPLACE(@html, '{order_number}',    @order_number)
SET @html = REPLACE(@html, '{order_date}',      CONVERT(nvarchar(10), @order_date, 120))
SET @html = REPLACE(@html, '{order_total}',     CAST(@order_total AS varchar(255)))

SET @html = REPLACE(@html, '{customer_company}',    @customer_company)
SET @html = REPLACE(@html, '{customer_contact}',    @customer_contact)
SET @html = REPLACE(@html, '{customer_phone}',      @customer_phone)
SET @html = REPLACE(@html, '{customer_email}',      @customer_email)
SET @html = REPLACE(@html, '{customer_address}',    @customer_address)

SET @html = REPLACE(@html, '{seller_company}',      @seller_company)
SET @html = REPLACE(@html, '{seller_salesperson}',  @seller_salesperson)
SET @html = REPLACE(@html, '{seller_prepared_by}',  @seller_prepared_by)
SET @html = REPLACE(@html, '{seller_phone}',        @seller_phone)
SET @html = REPLACE(@html, '{seller_email}',        @seller_email)
SET @html = REPLACE(@html, '{seller_address}',      @seller_address)

SELECT @html AS [html]

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Deletes a product
-- =============================================

CREATE PROCEDURE [s05].[xl_actions_product_delete]
    @id int
    , @name nvarchar(255)
AS
BEGIN

DELETE s05.products
WHERE
    id = @id
    AND product_name = @name

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Inserts a product
-- =============================================

CREATE PROCEDURE [s05].[xl_actions_product_insert]
    @category_id int = NULL
    , @subcategory_id int = NULL
    , @brand_id int = NULL
    , @product_name nvarchar(255) = NULL
AS
BEGIN

INSERT s05.products
    (category_id, brand_id, product_name)
VALUES
    (@subcategory_id, @brand_id, @product_name)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Updates levels of product categories
-- =============================================

CREATE PROCEDURE [s05].[xl_actions_update_product_categories]
AS
BEGIN

UPDATE s05.product_categories SET [level] = 1 WHERE parent_id IN (SELECT id FROM s05.product_categories WHERE [level] = 0) AND ([level] IS NULL OR NOT [level] = 1)
UPDATE s05.product_categories SET [level] = 2 WHERE parent_id IN (SELECT id FROM s05.product_categories WHERE [level] = 1) AND ([level] IS NULL OR NOT [level] = 2)
UPDATE s05.product_categories SET [level] = 3 WHERE parent_id IN (SELECT id FROM s05.product_categories WHERE [level] = 2) AND ([level] IS NULL OR NOT [level] = 3)

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Change event handler for order details
-- =============================================

CREATE PROCEDURE [s05].[xl_change_order_details]
    @id int = NULL
    , @column_name nvarchar(255) = NULL
    , @cell_value nvarchar(255) = NULL
    , @cell_number_value float = NULL
    , @order_id int = NULL
    , @amount float = NULL
    , @unit_price float = NULL
AS
BEGIN

IF @order_id IS NULL
    RETURN

SET NOCOUNT ON

DECLARE @sales_tax float, @discount float, @subtotal float, @tax float, @total float
DECLARE @pricing_category_id int
DECLARE @default_unit_price float

DECLARE @message nvarchar(max)

IF @column_name IN ('amount', 'unit_price')
    BEGIN

    IF @id IS NULL
        RETURN

    IF @amount IS NULL
        BEGIN
        DELETE FROM s05.order_details WHERE order_id = @order_id AND product_id = @id
        RETURN
        END

    SELECT TOP 1 @sales_tax = c.sales_tax, @pricing_category_id = c.pricing_category_id
        FROM s05.orders o INNER JOIN s05.customers c ON c.id = o.customer_id WHERE o.id = @order_id

    SELECT @default_unit_price = unit_price FROM s05.product_prices WHERE product_id = @id AND pricing_category_id = @pricing_category_id

    SET @unit_price = COALESCE(@unit_price, @default_unit_price)
    SET @subtotal = ROUND(@amount * @unit_price, 2)
    SET @tax = ROUND(@subtotal * @sales_tax, 2)
    SET @total = @subtotal + @tax
    SET @discount = ROUND(@amount * COALESCE(@default_unit_price, @unit_price), 2) - @subtotal

    UPDATE s05.order_details
    SET
        amount = @amount
        , unit_price = @unit_price
        , subtotal = @subtotal
        , sales_tax = @tax
        , total = @total
        , discount = @discount
    WHERE
        product_id = @id
        AND order_id = @order_id

    IF (@@ROWCOUNT = 0) AND (@amount IS NOT NULL)
        BEGIN
        INSERT s05.order_details
            (product_id, order_id, amount, unit_price, subtotal, sales_tax, total, discount)
        VALUES
            (@id, @order_id, @amount, @unit_price, @subtotal, @tax, @total, @discount)
        END

    RETURN
    END

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Change event handler for order headers
-- =============================================

CREATE PROCEDURE [s05].[xl_change_order_header]
    @id int = NULL
    , @column_name nvarchar(255) = NULL
    , @cell_value nvarchar(255) = NULL
    , @cell_number_value float = NULL
    , @cell_datetime_value datetime = NULL
AS
BEGIN

IF @column_name = 'customer_id'
    BEGIN
    UPDATE s05.orders SET customer_id = @cell_number_value WHERE id = @id
    END
ELSE IF @column_name = 'seller_id'
    BEGIN
    UPDATE s05.orders SET seller_id = @cell_number_value WHERE id = @id
    END
ELSE IF @column_name = 'order_date'
    BEGIN
    UPDATE s05.orders SET order_date = @cell_datetime_value, expiration_date = DATEADD(DAY, 30, @cell_datetime_value) WHERE id = @id
    END
ELSE IF @column_name = 'order_number'
    BEGIN
    UPDATE s05.orders SET order_number = @cell_value WHERE id = @id
    END
ELSE IF @column_name = 'expiration_date'
    BEGIN
    UPDATE s05.orders SET expiration_date = @cell_datetime_value WHERE id = @id
    END
ELSE IF @column_name = 'delivary_date'
    BEGIN
    UPDATE s05.orders SET delivery_date = @cell_datetime_value WHERE id = @id
    END
ELSE IF @column_name = 'due_date'
    BEGIN
    UPDATE s05.orders SET due_date = @cell_datetime_value WHERE id = @id
    END
ELSE
    BEGIN
    RETURN
    END

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Change event handler for products
-- =============================================

CREATE PROCEDURE [s05].[xl_change_products]
    @id int = NULL
    , @column_name nvarchar(255) = NULL
    , @cell_value nvarchar(255) = NULL
    , @cell_number_value float = NULL
    , @pricing_category_id int = NULL
AS
BEGIN

SET NOCOUNT ON

IF @pricing_category_id IS NULL
    SET @pricing_category_id = 1

DECLARE @level int

DECLARE @message nvarchar(max)

IF @column_name = 'unit_price'
    BEGIN

    IF @id IS NULL
        RETURN

    UPDATE s05.product_prices
    SET
        unit_price = @cell_number_value
    WHERE
        product_id = @id
        AND pricing_category_id = @pricing_category_id

    IF (@@ROWCOUNT = 0) AND (@cell_number_value IS NOT NULL)
        BEGIN

        INSERT s05.product_prices
            (product_id, pricing_category_id, unit_price)
        VALUES
            (@id, @pricing_category_id, @cell_number_value)
        END

    RETURN
    END
ELSE IF @column_name = 'product_name'
    BEGIN
    UPDATE s05.products SET product_name = @cell_value WHERE id = @id
    RETURN
    END
ELSE IF @column_name = 'sku'
    BEGIN
    UPDATE s05.products SET sku = @cell_value WHERE id = @id
    RETURN
    END

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects brand_id parameter values
-- =============================================

CREATE PROCEDURE [s05].[xl_select_brand_id]
    @category_id int = NULL
    , @subcategory_id int = NULL
AS
BEGIN

IF @category_id IS NULL
    BEGIN
    SELECT
        id
        , brand
    FROM
        s05.brands
    ORDER BY
        brand
    END
ELSE
    BEGIN

    SELECT
        DISTINCT
        b.id
        , b.brand
    FROM
        s05.products t
        INNER JOIN s05.brands b ON b.id = t.brand_id
        INNER JOIN s05.product_categories c ON c.id = t.category_id
    WHERE
        c.parent_id = @category_id
    ORDER BY
        b.brand

    END

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects category_id parameter values
-- =============================================

CREATE PROCEDURE [s05].[xl_select_category_id]
AS
BEGIN

SELECT NULL AS id, NULL AS name UNION
SELECT
    t.id
    , t.category AS name
FROM
    s05.product_categories t
WHERE
    t.[level] = 1
ORDER BY
    name

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Customer orders for task panes
-- =============================================

CREATE PROCEDURE [s05].[xl_select_customer_orders]
    @id int = NULL
AS
BEGIN

SELECT
    o.id
    , CAST(o.order_date AS datetime) AS order_date
    , o.order_number
    , CAST(o.expiration_date AS datetime) AS expiration_date
    , CAST(o.delivery_date AS datetime) AS delivery_date
    , CAST(o.due_date AS datetime) AS due_date
    , s.code AS seller
    , d.discount
    , d.items
    , d.amount
    , d.subtotal
    , d.sales_tax
    , ROUND(d.total, 2) AS total
FROM
    s05.orders o
    LEFT OUTER JOIN s05.sellers s ON s.id = o.seller_id
    LEFT OUTER JOIN (
        SELECT
            d.order_id
            , COUNT(*) AS items
            , SUM(d.amount) AS amount
            , SUM(d.discount) AS discount
            , SUM(d.subtotal) AS subtotal
            , SUM(d.sales_tax) AS sales_tax
            , SUM(d.total) AS total
        FROM
            s05.order_details d
        WHERE
            d.amount IS NOT NULL
        GROUP BY
            d.order_id
    ) d ON d.order_id = o.id
WHERE
    o.customer_id = @id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Order details for task panes
-- =============================================

CREATE PROCEDURE [s05].[xl_select_order_details]
    @id int = NULL
AS
BEGIN

SELECT
    t.id
    , t.sku
    , t.product_name
    , t.amount
    , t.unit_price
    , t.subtotal
FROM
    (
    SELECT
        t.[id]
        , t.sku
        , t.product_name
        , c.category AS category
        , s.category AS subcategory
        , b.brand
        , c.sort_order AS category_sort_order
        , s.sort_order AS subcategory_sort_order
        , d.amount
        , d.unit_price
        , d.subtotal
    FROM
        s05.order_details d
        LEFT OUTER JOIN s05.products t ON t.id = d.product_id
        LEFT OUTER JOIN s05.product_categories s ON s.id = t.category_id
        LEFT OUTER JOIN s05.product_categories c ON c.id = s.parent_id
        LEFT OUTER JOIN s05.brands b ON b.id = t.brand_id
    WHERE
        d.order_id = @id
    ) t
ORDER BY
    t.category_sort_order
    , t.category
    , t.subcategory_sort_order
    , t.subcategory
    , t.brand
    , t.product_name

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects order_id parameter values
-- =============================================

CREATE PROCEDURE [s05].[xl_select_order_id]
AS
BEGIN

SELECT
    o.id
    , COALESCE(o.order_number, CAST(o.id AS nvarchar)) + COALESCE(' - ' + c.customer, '') AS name
FROM
    s05.orders o
    LEFT OUTER JOIN s05.customers c ON c.id = o.customer_id

END


GO

-- =============================================
-- Author:      Gartle LLC
-- Release:     10.0, 2022-07-05
-- Description: Selects subcategory_id parameter values
-- =============================================

CREATE PROCEDURE [s05].[xl_select_subcategory_id]
    @category_id int = NULL
AS
BEGIN

IF @category_id IS NULL
    BEGIN
    SELECT CAST(NULL AS int) AS id, CAST(NULL AS nvarchar(255)) AS name
    RETURN
    END

SELECT
    t.id
    , t.category AS name
FROM
    s05.product_categories t
WHERE
    t.parent_id = @category_id
ORDER BY
    name

END


GO

SET IDENTITY_INSERT s05.brands ON;
INSERT INTO s05.brands (id, brand) VALUES (1, N'Acer');
INSERT INTO s05.brands (id, brand) VALUES (2, N'ASUS');
INSERT INTO s05.brands (id, brand) VALUES (3, N'Dell');
INSERT INTO s05.brands (id, brand) VALUES (4, N'Samsung');
INSERT INTO s05.brands (id, brand) VALUES (5, N'Sony');
SET IDENTITY_INSERT s05.brands OFF;
GO

SET IDENTITY_INSERT s05.forms ON;
INSERT INTO s05.forms (id, form, template) VALUES (1, N'Simple order', N'<html>
<head>
<title>Order #{order_number}</title>
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
<h1>Order #{order_number}</h1>
<table>
<tr><th>item #</th><th>name</th><th>price</th><th>amount</th><th>total</th></tr>
{table}
<tr class="total_row"><td></td><td>Total</td><td></td><td></td><td class="sum" >{order_total}</td></tr>
</table>
<p>This is an example. You may edit the template in the s05.forms table.</p>
</body>
</html>');
SET IDENTITY_INSERT s05.forms OFF;
GO

INSERT INTO s05.pricing_categories (id, pricing_category) VALUES (1, N'Default');
GO

SET IDENTITY_INSERT s05.product_categories ON;
INSERT INTO s05.product_categories (id, category, parent_id, level, sort_order) VALUES (1, N'Catalog', NULL, 0, NULL);
INSERT INTO s05.product_categories (id, category, parent_id, level, sort_order) VALUES (2, N'Laptops', 1, 1, NULL);
INSERT INTO s05.product_categories (id, category, parent_id, level, sort_order) VALUES (3, N'Netbooks', 1, 1, NULL);
INSERT INTO s05.product_categories (id, category, parent_id, level, sort_order) VALUES (4, N'Acer Laptops', 2, 2, NULL);
INSERT INTO s05.product_categories (id, category, parent_id, level, sort_order) VALUES (5, N'ASUS Laptops', 2, 2, NULL);
INSERT INTO s05.product_categories (id, category, parent_id, level, sort_order) VALUES (6, N'Dell Laptops', 2, 2, NULL);
INSERT INTO s05.product_categories (id, category, parent_id, level, sort_order) VALUES (7, N'Sony Laptops', 2, 2, NULL);
INSERT INTO s05.product_categories (id, category, parent_id, level, sort_order) VALUES (8, N'Acer Netbooks', 3, 2, NULL);
INSERT INTO s05.product_categories (id, category, parent_id, level, sort_order) VALUES (9, N'ASUS Netbooks', 3, 2, NULL);
INSERT INTO s05.product_categories (id, category, parent_id, level, sort_order) VALUES (10, N'Samsung Netbooks', 3, 2, NULL);
SET IDENTITY_INSERT s05.product_categories OFF;
GO

SET IDENTITY_INSERT s05.sellers ON;
INSERT INTO s05.sellers (id, code, company, salesperson, prepared_by, phone, email, address, slogan, bank, bank_address, bank_swift, account_holder, account_number, account_string1, account_string2) VALUES (1, N'SELLER1', N'<company>', N'<salesperson>', N'<prepared by>', N'<phone>', N'<email>', N'<address>', N'<slogan>', N'<bank>', N'<bank address>', N'<swift>', N'<account holder>', N'<account number>', N'<account string 1>', N'<account string 2>');
SET IDENTITY_INSERT s05.sellers OFF;
GO

SET IDENTITY_INSERT s05.customers ON;
INSERT INTO s05.customers (id, customer, company, contact, phone, email, address, sales_tax, pricing_category_id) VALUES (1, N'ABC', N'ABC Inc.', N'<ABC contact>', N'<ABC phone>', N'<ABC email>', N'<ABC address>', 0, 1);
INSERT INTO s05.customers (id, customer, company, contact, phone, email, address, sales_tax, pricing_category_id) VALUES (2, N'XYZ', N'XYZ Corp.', N'<XYZ contact>', N'<XYZ phone>', N'<XYZ email>', N'<XYZ address>', 0.01, 1);
SET IDENTITY_INSERT s05.customers OFF;
GO

SET IDENTITY_INSERT s05.products ON;
INSERT INTO s05.products (id, category_id, brand_id, sku, product_name) VALUES (11, 4, 1, N'10-01', N'Acer Aspire TimelineX AS1830T-6651 11.6-Inch Laptop (Black)');
INSERT INTO s05.products (id, category_id, brand_id, sku, product_name) VALUES (12, 4, 1, N'10-02', N'Acer Aspire TimelineX AS4830T-6642 14-Inch Laptop (Cobalt Blue Aluminum)');
INSERT INTO s05.products (id, category_id, brand_id, sku, product_name) VALUES (13, 5, 2, N'11-02', N'ASUS A53U-XE1 15.6-Inch Versatile Entertainment Laptop (Mocha)');
INSERT INTO s05.products (id, category_id, brand_id, sku, product_name) VALUES (14, 5, 2, N'11-01', N'ASUS A53SV-XE1 15.6-Inch Versatile Entertainment Laptop (Black)');
INSERT INTO s05.products (id, category_id, brand_id, sku, product_name) VALUES (15, 6, 3, N'12-01', N'Dell Inspiron 14R i14RN4110-8073DBK 14-Inch Laptop (Diamond Black)');
INSERT INTO s05.products (id, category_id, brand_id, sku, product_name) VALUES (16, 6, 3, N'12-02', N'Dell XPS 15 X15L-1024ELS Laptop (Elemental Silver)');
INSERT INTO s05.products (id, category_id, brand_id, sku, product_name) VALUES (17, 7, 5, N'13-01', N'Sony VAIO VPC-EH11FX/L Laptop (Blue)');
INSERT INTO s05.products (id, category_id, brand_id, sku, product_name) VALUES (18, 7, 5, N'13-02', N'Sony VAIO VPC-EL17FX/B Laptop (Black)');
INSERT INTO s05.products (id, category_id, brand_id, sku, product_name) VALUES (19, 8, 1, N'21-01', N'Acer Aspire One AO722-BZ454 11.6-Inch HD Netbook (Espresso Black)');
INSERT INTO s05.products (id, category_id, brand_id, sku, product_name) VALUES (20, 8, 1, N'21-02', N'Acer Aspire One AOD257-13685 10.1-Inch Netbook (Espresso Black)');
INSERT INTO s05.products (id, category_id, brand_id, sku, product_name) VALUES (21, 9, 2, N'22-01', N'ASUS Eee PC 1015PEM-PU17-BK 10.1-Inch Netbook (Black)');
INSERT INTO s05.products (id, category_id, brand_id, sku, product_name) VALUES (22, 9, 2, N'22-02', N'ASUS Eee PC 1015PEM-PU17-BU 10.1-Inch Netbook (Blue)');
INSERT INTO s05.products (id, category_id, brand_id, sku, product_name) VALUES (23, 10, 4, N'23-01', N'Samsung NF310-A01 10.1-Inch Netbook (Titan Silver)');
INSERT INTO s05.products (id, category_id, brand_id, sku, product_name) VALUES (24, 10, 4, N'23-01', N'Samsung NB30-JP02 10.1-Inch Netbook (Texturized Matte Black)');
SET IDENTITY_INSERT s05.products OFF;
GO

SET IDENTITY_INSERT s05.orders ON;
INSERT INTO s05.orders (id, order_date, order_number, seller_id, customer_id, expiration_date, delivery_date, due_date) VALUES (1, '20230221', N'23022101', 1, 2, '20230323', NULL, NULL);
INSERT INTO s05.orders (id, order_date, order_number, seller_id, customer_id, expiration_date, delivery_date, due_date) VALUES (2, '20230221', N'23022102', 1, 2, '20230323', NULL, NULL);
INSERT INTO s05.orders (id, order_date, order_number, seller_id, customer_id, expiration_date, delivery_date, due_date) VALUES (3, '20230221', N'23022103', 1, 1, '20230323', NULL, NULL);
SET IDENTITY_INSERT s05.orders OFF;
GO

INSERT INTO s05.product_prices (product_id, pricing_category_id, unit_price) VALUES (11, 1, 479.99);
INSERT INTO s05.product_prices (product_id, pricing_category_id, unit_price) VALUES (12, 1, 699.99);
INSERT INTO s05.product_prices (product_id, pricing_category_id, unit_price) VALUES (13, 1, 339.98);
INSERT INTO s05.product_prices (product_id, pricing_category_id, unit_price) VALUES (14, 1, 799.99);
INSERT INTO s05.product_prices (product_id, pricing_category_id, unit_price) VALUES (15, 1, 549.99);
INSERT INTO s05.product_prices (product_id, pricing_category_id, unit_price) VALUES (16, 1, 899.99);
INSERT INTO s05.product_prices (product_id, pricing_category_id, unit_price) VALUES (17, 1, 540.86);
INSERT INTO s05.product_prices (product_id, pricing_category_id, unit_price) VALUES (18, 1, 499);
INSERT INTO s05.product_prices (product_id, pricing_category_id, unit_price) VALUES (19, 1, 292.88);
INSERT INTO s05.product_prices (product_id, pricing_category_id, unit_price) VALUES (20, 1, 269.99);
INSERT INTO s05.product_prices (product_id, pricing_category_id, unit_price) VALUES (21, 1, 299.99);
INSERT INTO s05.product_prices (product_id, pricing_category_id, unit_price) VALUES (22, 1, 289.98);
INSERT INTO s05.product_prices (product_id, pricing_category_id, unit_price) VALUES (23, 1, 379.34);
INSERT INTO s05.product_prices (product_id, pricing_category_id, unit_price) VALUES (24, 1, 359);
GO

SET IDENTITY_INSERT s05.order_details ON;
INSERT INTO s05.order_details (id, order_id, product_id, amount, unit_price, subtotal, sales_tax, total, discount) VALUES (1, 1, 13, 1, 339.98, 339.98, 3.4, 343.38, 0);
INSERT INTO s05.order_details (id, order_id, product_id, amount, unit_price, subtotal, sales_tax, total, discount) VALUES (2, 1, 15, 1, 549.99, 549.99, 5.5, 555.49, 0);
INSERT INTO s05.order_details (id, order_id, product_id, amount, unit_price, subtotal, sales_tax, total, discount) VALUES (3, 2, 15, 1, 549.99, 549.99, 5.5, 555.49, 0);
INSERT INTO s05.order_details (id, order_id, product_id, amount, unit_price, subtotal, sales_tax, total, discount) VALUES (4, 1, 14, 1, 799.99, 799.99, 8, 807.99, 0);
INSERT INTO s05.order_details (id, order_id, product_id, amount, unit_price, subtotal, sales_tax, total, discount) VALUES (6, 3, 19, 1, 282.88, 282.88, 0, 282.88, 10);
INSERT INTO s05.order_details (id, order_id, product_id, amount, unit_price, subtotal, sales_tax, total, discount) VALUES (7, 3, 20, 1, 269.99, 269.99, 0, 269.99, 0);
SET IDENTITY_INSERT s05.order_details OFF;
GO

INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's05', N'brands', N'<table name="s05.brands"><columnFormats><column name="" property="ListObjectName" value="brands" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="id" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="brand" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="brand" property="Address" value="$D$4" type="String" /><column name="brand" property="ColumnWidth" value="13.57" type="Double" /><column name="brand" property="NumberFormat" value="General" type="String" /><column name="brand" property="Validation.Type" value="6" type="Double" /><column name="brand" property="Validation.Operator" value="8" type="Double" /><column name="brand" property="Validation.Formula1" value="255" type="String" /><column name="brand" property="Validation.AlertStyle" value="1" type="Double" /><column name="brand" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="brand" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="brand" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="brand" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(255) datatype." type="String" /><column name="brand" property="Validation.ShowInput" value="True" type="Boolean" /><column name="brand" property="Validation.ShowError" value="True" type="Boolean" /><column name="brand" property="FormatConditions(1).AppliesTo.Address" value="$D$4:$D$8" type="String" /><column name="brand" property="FormatConditions(1).Type" value="2" type="Double" /><column name="brand" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="brand" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String" /><column name="brand" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="brand" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's05', N'customers', N'<table name="s05.customers"><columnFormats><column name="" property="ListObjectName" value="customers" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="customer" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer" property="Address" value="$D$4" type="String" /><column name="customer" property="ColumnWidth" value="11.14" type="Double" /><column name="customer" property="NumberFormat" value="General" type="String" /><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company" property="Address" value="$E$4" type="String" /><column name="company" property="ColumnWidth" value="13.71" type="Double" /><column name="company" property="NumberFormat" value="General" type="String" /><column name="company" property="Validation.Type" value="6" type="Double" /><column name="company" property="Validation.Operator" value="8" type="Double" /><column name="company" property="Validation.Formula1" value="255" type="String" /><column name="company" property="Validation.AlertStyle" value="1" type="Double" /><column name="company" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="company" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="company" property="Validation.ShowInput" value="True" type="Boolean" /><column name="company" property="Validation.ShowError" value="True" type="Boolean" /><column name="contact" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="contact" property="Address" value="$F$4" type="String" /><column name="contact" property="ColumnWidth" value="15.43" type="Double" /><column name="contact" property="NumberFormat" value="General" type="String" /><column name="contact" property="Validation.Type" value="6" type="Double" /><column name="contact" property="Validation.Operator" value="8" type="Double" /><column name="contact" property="Validation.Formula1" value="255" type="String" /><column name="contact" property="Validation.AlertStyle" value="1" type="Double" /><column name="contact" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="contact" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="contact" property="Validation.ShowInput" value="True" type="Boolean" /><column name="contact" property="Validation.ShowError" value="True" type="Boolean" /><column name="phone" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="phone" property="Address" value="$G$4" type="String" /><column name="phone" property="ColumnWidth" value="16.71" type="Double" /><column name="phone" property="NumberFormat" value="General" type="String" /><column name="phone" property="Validation.Type" value="6" type="Double" /><column name="phone" property="Validation.Operator" value="8" type="Double" /><column name="phone" property="Validation.Formula1" value="255" type="String" /><column name="phone" property="Validation.AlertStyle" value="1" type="Double" /><column name="phone" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="phone" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="phone" property="Validation.ShowInput" value="True" type="Boolean" /><column name="phone" property="Validation.ShowError" value="True" type="Boolean" /><column name="email" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="email" property="Address" value="$H$4" type="String" /><column name="email" property="ColumnWidth" value="21.71" type="Double" /><column name="email" property="NumberFormat" value="General" type="String" /><column name="email" property="Validation.Type" value="6" type="Double" /><column name="email" property="Validation.Operator" value="8" type="Double" /><column name="email" property="Validation.Formula1" value="255" type="String" /><column name="email" property="Validation.AlertStyle" value="1" type="Double" /><column name="email" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="email" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="email" property="Validation.ShowInput" value="True" type="Boolean" /><column name="email" property="Validation.ShowError" value="True" type="Boolean" /><column name="address" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="address" property="Address" value="$I$4" type="String" /><column name="address" property="ColumnWidth" value="51" type="Double" /><column name="address" property="NumberFormat" value="General" type="String" /><column name="address" property="Validation.Type" value="6" type="Double" /><column name="address" property="Validation.Operator" value="8" type="Double" /><column name="address" property="Validation.Formula1" value="255" type="String" /><column name="address" property="Validation.AlertStyle" value="1" type="Double" /><column name="address" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="address" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="address" property="Validation.ShowInput" value="True" type="Boolean" /><column name="address" property="Validation.ShowError" value="True" type="Boolean" /><column name="sales_tax" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sales_tax" property="Address" value="$J$4" type="String" /><column name="sales_tax" property="ColumnWidth" value="10.57" type="Double" /><column name="sales_tax" property="NumberFormat" value="0.00%" type="String" /><column name="pricing_category_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="pricing_category_id" property="Address" value="$K$4" type="String" /><column name="pricing_category_id" property="ColumnWidth" value="20.14" type="Double" /><column name="pricing_category_id" property="NumberFormat" value="General" type="String" /><column name="pricing_category_id" property="Validation.Type" value="3" type="Double" /><column name="pricing_category_id" property="Validation.Operator" value="1" type="Double" /><column name="pricing_category_id" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s05_pricing_categories_id_pricing_category[pricing_category]&quot;)" type="String" /><column name="pricing_category_id" property="Validation.AlertStyle" value="1" type="Double" /><column name="pricing_category_id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="pricing_category_id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="pricing_category_id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="pricing_category_id" property="Validation.ShowError" value="True" type="Boolean" /><column name="company" property="FormatConditions(1).AppliesTo.Address" value="$E$4:$E$5" type="String" /><column name="company" property="FormatConditions(1).Type" value="2" type="Double" /><column name="company" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="company" property="FormatConditions(1).Formula1" value="=ISBLANK(E4)" type="String" /><column name="company" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="company" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's05', N'pricing_categories', N'<table name="s05.pricing_categories"><columnFormats><column name="" property="ListObjectName" value="pricing_categories" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="id" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="pricing_category" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="pricing_category" property="Address" value="$D$4" type="String" /><column name="pricing_category" property="ColumnWidth" value="23.29" type="Double" /><column name="pricing_category" property="NumberFormat" value="General" type="String" /><column name="pricing_category" property="Validation.Type" value="6" type="Double" /><column name="pricing_category" property="Validation.Operator" value="8" type="Double" /><column name="pricing_category" property="Validation.Formula1" value="255" type="String" /><column name="pricing_category" property="Validation.AlertStyle" value="1" type="Double" /><column name="pricing_category" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="pricing_category" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="pricing_category" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="pricing_category" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(255) datatype." type="String" /><column name="pricing_category" property="Validation.ShowInput" value="True" type="Boolean" /><column name="pricing_category" property="Validation.ShowError" value="True" type="Boolean" /><column name="id" property="FormatConditions(1).AppliesTo.Address" value="$C$4" type="String" /><column name="id" property="FormatConditions(1).Type" value="2" type="Double" /><column name="id" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="id" property="FormatConditions(1).Formula1" value="=ISBLANK(C4)" type="String" /><column name="id" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="id" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="pricing_category" property="FormatConditions(1).AppliesTo.Address" value="$D$4" type="String" /><column name="pricing_category" property="FormatConditions(1).Type" value="2" type="Double" /><column name="pricing_category" property="FormatConditions(1).Priority" value="2" type="Double" /><column name="pricing_category" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String" /><column name="pricing_category" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="pricing_category" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's05', N'product_categories', N'<table name="s05.product_categories"><columnFormats><column name="" property="ListObjectName" value="product_categories" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="id" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="category" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="category" property="Address" value="$D$4" type="String" /><column name="category" property="ColumnWidth" value="25" type="Double" /><column name="category" property="NumberFormat" value="General" type="String" /><column name="category" property="Validation.Type" value="6" type="Double" /><column name="category" property="Validation.Operator" value="8" type="Double" /><column name="category" property="Validation.Formula1" value="255" type="String" /><column name="category" property="Validation.AlertStyle" value="1" type="Double" /><column name="category" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="category" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="category" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="category" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(255) datatype." type="String" /><column name="category" property="Validation.ShowInput" value="True" type="Boolean" /><column name="category" property="Validation.ShowError" value="True" type="Boolean" /><column name="parent_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="parent_id" property="Address" value="$E$4" type="String" /><column name="parent_id" property="ColumnWidth" value="20.43" type="Double" /><column name="parent_id" property="NumberFormat" value="General" type="String" /><column name="parent_id" property="Validation.Type" value="3" type="Double" /><column name="parent_id" property="Validation.Operator" value="1" type="Double" /><column name="parent_id" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s05_product_categories_id_category[category]&quot;)" type="String" /><column name="parent_id" property="Validation.AlertStyle" value="1" type="Double" /><column name="parent_id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="parent_id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="parent_id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="parent_id" property="Validation.ShowError" value="True" type="Boolean" /><column name="level" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="level" property="Address" value="$F$4" type="String" /><column name="level" property="ColumnWidth" value="8.57" type="Double" /><column name="level" property="NumberFormat" value="General" type="String" /><column name="level" property="Validation.Type" value="1" type="Double" /><column name="level" property="Validation.Operator" value="1" type="Double" /><column name="level" property="Validation.Formula1" value="0" type="String" /><column name="level" property="Validation.Formula2" value="255" type="String" /><column name="level" property="Validation.AlertStyle" value="1" type="Double" /><column name="level" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="level" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="level" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="level" property="Validation.ErrorMessage" value="The column requires values of the tinyint datatype." type="String" /><column name="level" property="Validation.ShowInput" value="True" type="Boolean" /><column name="level" property="Validation.ShowError" value="True" type="Boolean" /><column name="sort_order" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sort_order" property="Address" value="$G$4" type="String" /><column name="sort_order" property="ColumnWidth" value="12.71" type="Double" /><column name="sort_order" property="NumberFormat" value="General" type="String" /><column name="sort_order" property="Validation.Type" value="1" type="Double" /><column name="sort_order" property="Validation.Operator" value="1" type="Double" /><column name="sort_order" property="Validation.Formula1" value="-2147483648" type="String" /><column name="sort_order" property="Validation.Formula2" value="2147483647" type="String" /><column name="sort_order" property="Validation.AlertStyle" value="1" type="Double" /><column name="sort_order" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="sort_order" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="sort_order" property="Validation.ErrorTitle" value="Datatype Control" type="String" /><column name="sort_order" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String" /><column name="sort_order" property="Validation.ShowInput" value="True" type="Boolean" /><column name="sort_order" property="Validation.ShowError" value="True" type="Boolean" /><column name="category" property="FormatConditions(1).AppliesTo.Address" value="$D$4:$D$13" type="String" /><column name="category" property="FormatConditions(1).Type" value="2" type="Double" /><column name="category" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="category" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String" /><column name="category" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="category" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's05', N'sellers', N'<table name="s05.sellers"><columnFormats><column name="" property="ListObjectName" value="sellers" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="code" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="code" property="Address" value="$D$4" type="String" /><column name="code" property="ColumnWidth" value="7.43" type="Double" /><column name="code" property="NumberFormat" value="General" type="String" /><column name="company" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="company" property="Address" value="$E$4" type="String" /><column name="company" property="ColumnWidth" value="27.86" type="Double" /><column name="company" property="NumberFormat" value="General" type="String" /><column name="company" property="Validation.Type" value="6" type="Double" /><column name="company" property="Validation.Operator" value="8" type="Double" /><column name="company" property="Validation.Formula1" value="255" type="String" /><column name="company" property="Validation.AlertStyle" value="1" type="Double" /><column name="company" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="company" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="company" property="Validation.ShowInput" value="True" type="Boolean" /><column name="company" property="Validation.ShowError" value="True" type="Boolean" /><column name="salesperson" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="salesperson" property="Address" value="$F$4" type="String" /><column name="salesperson" property="ColumnWidth" value="13.14" type="Double" /><column name="salesperson" property="NumberFormat" value="General" type="String" /><column name="prepared_by" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="prepared_by" property="Address" value="$G$4" type="String" /><column name="prepared_by" property="ColumnWidth" value="13.86" type="Double" /><column name="prepared_by" property="NumberFormat" value="General" type="String" /><column name="phone" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="phone" property="Address" value="$H$4" type="String" /><column name="phone" property="ColumnWidth" value="13.57" type="Double" /><column name="phone" property="NumberFormat" value="General" type="String" /><column name="phone" property="Validation.Type" value="6" type="Double" /><column name="phone" property="Validation.Operator" value="8" type="Double" /><column name="phone" property="Validation.Formula1" value="255" type="String" /><column name="phone" property="Validation.AlertStyle" value="1" type="Double" /><column name="phone" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="phone" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="phone" property="Validation.ShowInput" value="True" type="Boolean" /><column name="phone" property="Validation.ShowError" value="True" type="Boolean" /><column name="email" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="email" property="Address" value="$I$4" type="String" /><column name="email" property="ColumnWidth" value="19.29" type="Double" /><column name="email" property="NumberFormat" value="General" type="String" /><column name="email" property="Validation.Type" value="6" type="Double" /><column name="email" property="Validation.Operator" value="8" type="Double" /><column name="email" property="Validation.Formula1" value="255" type="String" /><column name="email" property="Validation.AlertStyle" value="1" type="Double" /><column name="email" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="email" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="email" property="Validation.ShowInput" value="True" type="Boolean" /><column name="email" property="Validation.ShowError" value="True" type="Boolean" /><column name="address" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="address" property="Address" value="$J$4" type="String" /><column name="address" property="ColumnWidth" value="51" type="Double" /><column name="address" property="NumberFormat" value="General" type="String" /><column name="address" property="Validation.Type" value="6" type="Double" /><column name="address" property="Validation.Operator" value="8" type="Double" /><column name="address" property="Validation.Formula1" value="255" type="String" /><column name="address" property="Validation.AlertStyle" value="1" type="Double" /><column name="address" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="address" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="address" property="Validation.ShowInput" value="True" type="Boolean" /><column name="address" property="Validation.ShowError" value="True" type="Boolean" /><column name="slogan" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="slogan" property="Address" value="$K$4" type="String" /><column name="slogan" property="ColumnWidth" value="19.43" type="Double" /><column name="slogan" property="NumberFormat" value="General" type="String" /><column name="bank" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="bank" property="Address" value="$L$4" type="String" /><column name="bank" property="ColumnWidth" value="21.57" type="Double" /><column name="bank" property="NumberFormat" value="General" type="String" /><column name="bank_address" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="bank_address" property="Address" value="$M$4" type="String" /><column name="bank_address" property="ColumnWidth" value="15" type="Double" /><column name="bank_address" property="NumberFormat" value="General" type="String" /><column name="bank_swift" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="bank_swift" property="Address" value="$N$4" type="String" /><column name="bank_swift" property="ColumnWidth" value="12.29" type="Double" /><column name="bank_swift" property="NumberFormat" value="General" type="String" /><column name="account_holder" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_holder" property="Address" value="$O$4" type="String" /><column name="account_holder" property="ColumnWidth" value="16.43" type="Double" /><column name="account_holder" property="NumberFormat" value="General" type="String" /><column name="account_number" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_number" property="Address" value="$P$4" type="String" /><column name="account_number" property="ColumnWidth" value="17.57" type="Double" /><column name="account_number" property="NumberFormat" value="General" type="String" /><column name="account_string1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_string1" property="Address" value="$Q$4" type="String" /><column name="account_string1" property="ColumnWidth" value="16.57" type="Double" /><column name="account_string1" property="NumberFormat" value="General" type="String" /><column name="account_string2" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="account_string2" property="Address" value="$R$4" type="String" /><column name="account_string2" property="ColumnWidth" value="16.57" type="Double" /><column name="account_string2" property="NumberFormat" value="General" type="String" /><column name="company" property="FormatConditions(1).AppliesTo.Address" value="$E$4" type="String" /><column name="company" property="FormatConditions(1).Type" value="2" type="Double" /><column name="company" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="company" property="FormatConditions(1).Formula1" value="=ISBLANK(E4)" type="String" /><column name="company" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="company" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's05', N'usp_invoice_print_details', N'<table name="s05.usp_invoice_print_details"><columnFormats><column name="" property="ListObjectName" value="invoice_details" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="Table Style 1" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$29" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="_RowNum" property="VerticalAlignment" value="-4160" type="Double" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="Address" value="$C$29" type="String" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="VerticalAlignment" value="-4160" type="Double" /><column name="order_number" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="order_number" property="Address" value="$D$29" type="String" /><column name="order_number" property="NumberFormat" value="General" type="String" /><column name="order_number" property="VerticalAlignment" value="-4160" type="Double" /><column name="order_date" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="order_date" property="Address" value="$E$29" type="String" /><column name="order_date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="order_date" property="VerticalAlignment" value="-4160" type="Double" /><column name="expiration_date" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="expiration_date" property="Address" value="$F$29" type="String" /><column name="expiration_date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="expiration_date" property="VerticalAlignment" value="-4160" type="Double" /><column name="delivery_date" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="delivery_date" property="Address" value="$G$29" type="String" /><column name="delivery_date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="delivery_date" property="VerticalAlignment" value="-4160" type="Double" /><column name="due_date" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="due_date" property="Address" value="$H$29" type="String" /><column name="due_date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="due_date" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller" property="Address" value="$I$29" type="String" /><column name="seller" property="NumberFormat" value="General" type="String" /><column name="seller" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_company" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_company" property="Address" value="$J$29" type="String" /><column name="seller_company" property="NumberFormat" value="General" type="String" /><column name="seller_company" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_slogan" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_slogan" property="Address" value="$K$29" type="String" /><column name="seller_slogan" property="NumberFormat" value="General" type="String" /><column name="seller_slogan" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_salesperson" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_salesperson" property="Address" value="$L$29" type="String" /><column name="seller_salesperson" property="NumberFormat" value="General" type="String" /><column name="seller_salesperson" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_prepared_by" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_prepared_by" property="Address" value="$M$29" type="String" /><column name="seller_prepared_by" property="NumberFormat" value="General" type="String" /><column name="seller_prepared_by" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_phone" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_phone" property="Address" value="$N$29" type="String" /><column name="seller_phone" property="NumberFormat" value="General" type="String" /><column name="seller_phone" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_email" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_email" property="Address" value="$O$29" type="String" /><column name="seller_email" property="NumberFormat" value="General" type="String" /><column name="seller_email" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_address" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_address" property="Address" value="$P$29" type="String" /><column name="seller_address" property="NumberFormat" value="General" type="String" /><column name="seller_address" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_bank" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_bank" property="Address" value="$Q$29" type="String" /><column name="seller_bank" property="NumberFormat" value="General" type="String" /><column name="seller_bank" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_bank_address" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_bank_address" property="Address" value="$R$29" type="String" /><column name="seller_bank_address" property="NumberFormat" value="General" type="String" /><column name="seller_bank_address" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_bank_swift" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_bank_swift" property="Address" value="$S$29" type="String" /><column name="seller_bank_swift" property="NumberFormat" value="General" type="String" /><column name="seller_bank_swift" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_account_holder" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_account_holder" property="Address" value="$T$29" type="String" /><column name="seller_account_holder" property="NumberFormat" value="General" type="String" /><column name="seller_account_holder" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_account_number" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_account_number" property="Address" value="$U$29" type="String" /><column name="seller_account_number" property="NumberFormat" value="General" type="String" /><column name="seller_account_number" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_account_string1" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_account_string1" property="Address" value="$V$29" type="String" /><column name="seller_account_string1" property="NumberFormat" value="General" type="String" /><column name="seller_account_string1" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_account_string2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_account_string2" property="Address" value="$W$29" type="String" /><column name="seller_account_string2" property="NumberFormat" value="General" type="String" /><column name="seller_account_string2" property="VerticalAlignment" value="-4160" type="Double" /><column name="customer_customer" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_customer" property="Address" value="$X$29" type="String" /><column name="customer_customer" property="NumberFormat" value="General" type="String" /><column name="customer_customer" property="VerticalAlignment" value="-4160" type="Double" /><column name="customer_company" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_company" property="Address" value="$Y$29" type="String" /><column name="customer_company" property="NumberFormat" value="General" type="String" /><column name="customer_company" property="VerticalAlignment" value="-4160" type="Double" /><column name="customer_contact" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_contact" property="Address" value="$Z$29" type="String" /><column name="customer_contact" property="NumberFormat" value="General" type="String" /><column name="customer_contact" property="VerticalAlignment" value="-4160" type="Double" /><column name="customer_phone" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_phone" property="Address" value="$AA$29" type="String" /><column name="customer_phone" property="NumberFormat" value="General" type="String" /><column name="customer_phone" property="VerticalAlignment" value="-4160" type="Double" /><column name="customer_email" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_email" property="Address" value="$AB$29" type="String" /><column name="customer_email" property="NumberFormat" value="General" type="String" /><column name="customer_email" property="VerticalAlignment" value="-4160" type="Double" /><column name="customer_address" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_address" property="Address" value="$AC$29" type="String" /><column name="customer_address" property="NumberFormat" value="General" type="String" /><column name="customer_address" property="VerticalAlignment" value="-4160" type="Double" /><column name="customer_sales_tax" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_sales_tax" property="Address" value="$AD$29" type="String" /><column name="customer_sales_tax" property="NumberFormat" value="General" type="String" /><column name="customer_sales_tax" property="VerticalAlignment" value="-4160" type="Double" /><column name="item" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="item" property="Address" value="$AE$29" type="String" /><column name="item" property="NumberFormat" value="General" type="String" /><column name="item" property="VerticalAlignment" value="-4160" type="Double" /><column name="sku" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="sku" property="Address" value="$AF$29" type="String" /><column name="sku" property="NumberFormat" value="General" type="String" /><column name="sku" property="VerticalAlignment" value="-4160" type="Double" /><column name="product_name" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="product_name" property="Address" value="$AG$29" type="String" /><column name="product_name" property="NumberFormat" value="General" type="String" /><column name="product_name" property="VerticalAlignment" value="-4160" type="Double" /><column name="base_unit_price" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="base_unit_price" property="Address" value="$AH$29" type="String" /><column name="base_unit_price" property="NumberFormat" value="General" type="String" /><column name="base_unit_price" property="VerticalAlignment" value="-4160" type="Double" /><column name="discount" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="discount" property="Address" value="$AI$29" type="String" /><column name="discount" property="NumberFormat" value="General" type="String" /><column name="discount" property="VerticalAlignment" value="-4160" type="Double" /><column name="amount" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="amount" property="Address" value="$AJ$29" type="String" /><column name="amount" property="NumberFormat" value="General" type="String" /><column name="amount" property="VerticalAlignment" value="-4160" type="Double" /><column name="unit_price" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="unit_price" property="Address" value="$AK$29" type="String" /><column name="unit_price" property="NumberFormat" value="General" type="String" /><column name="unit_price" property="VerticalAlignment" value="-4160" type="Double" /><column name="subtotal" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="subtotal" property="Address" value="$AL$29" type="String" /><column name="subtotal" property="NumberFormat" value="General" type="String" /><column name="subtotal" property="VerticalAlignment" value="-4160" type="Double" /><column name="sales_tax" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="sales_tax" property="Address" value="$AM$29" type="String" /><column name="sales_tax" property="NumberFormat" value="General" type="String" /><column name="sales_tax" property="VerticalAlignment" value="-4160" type="Double" /><column name="total" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="total" property="Address" value="$AN$29" type="String" /><column name="total" property="NumberFormat" value="General" type="String" /><column name="total" property="VerticalAlignment" value="-4160" type="Double" /><column name="Item " property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Item " property="Address" value="$AO$29" type="String" /><column name="Item " property="FormulaR1C1" value="=[@item]" type="String" /><column name="Item " property="ColumnWidth" value="6.43" type="Double" /><column name="Item " property="NumberFormat" value="General" type="String" /><column name="Item " property="HorizontalAlignment" value="-4108" type="Double" /><column name="Item " property="VerticalAlignment" value="-4160" type="Double" /><column name="Qty " property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Qty " property="Address" value="$AP$29" type="String" /><column name="Qty " property="FormulaR1C1" value="=[@amount]" type="String" /><column name="Qty " property="ColumnWidth" value="6.43" type="Double" /><column name="Qty " property="NumberFormat" value="General" type="String" /><column name="Qty " property="HorizontalAlignment" value="-4108" type="Double" /><column name="Qty " property="VerticalAlignment" value="-4160" type="Double" /><column name="Part #" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Part #" property="Address" value="$AQ$29" type="String" /><column name="Part #" property="FormulaR1C1" value="=[@sku]" type="String" /><column name="Part #" property="ColumnWidth" value="7.86" type="Double" /><column name="Part #" property="NumberFormat" value="General" type="String" /><column name="Part #" property="HorizontalAlignment" value="-4108" type="Double" /><column name="Part #" property="VerticalAlignment" value="-4160" type="Double" /><column name="Description" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Description" property="Address" value="$AR$29" type="String" /><column name="Description" property="FormulaR1C1" value="=[@[product_name]]" type="String" /><column name="Description" property="ColumnWidth" value="42.14" type="Double" /><column name="Description" property="NumberFormat" value="General" type="String" /><column name="Description" property="VerticalAlignment" value="-4160" type="Double" /><column name="Description" property="WrapText" value="True" type="Boolean" /><column name="Unit Price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Unit Price" property="Address" value="$AS$29" type="String" /><column name="Unit Price" property="FormulaR1C1" value="=[@[unit_price]]" type="String" /><column name="Unit Price" property="ColumnWidth" value="10" type="Double" /><column name="Unit Price" property="NumberFormat" value="_(&quot;$&quot;* #,##0.00_);_(&quot;$&quot;* (#,##0.00);;_(@_)" type="String" /><column name="Unit Price" property="VerticalAlignment" value="-4160" type="Double" /><column name=" Total " property="EntireColumn.Hidden" value="False" type="Boolean" /><column name=" Total " property="Address" value="$AT$29" type="String" /><column name=" Total " property="FormulaR1C1" value="=[@subtotal]" type="String" /><column name=" Total " property="ColumnWidth" value="10" type="Double" /><column name=" Total " property="NumberFormat" value="_(&quot;$&quot;* #,##0.00_);_(&quot;$&quot;* (#,##0.00);;_(@_)" type="String" /><column name=" Total " property="VerticalAlignment" value="-4160" type="Double" /><column name="" property="AutoFilter.Off" value="True" type="Boolean" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="False" type="Boolean" /><column name="" property="ActiveWindow.Split" value="False" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="-28" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /><column name="" property="PageSetup.LeftMargin" value="59.5275590551181" type="Double" /><column name="" property="PageSetup.RightMargin" value="31.1811023622047" type="Double" /><column name="" property="PageSetup.TopMargin" value="53.8582677165354" type="Double" /><column name="" property="PageSetup.BottomMargin" value="53.8582677165354" type="Double" /><column name="" property="PageSetup.HeaderMargin" value="22.6771653543307" type="Double" /><column name="" property="PageSetup.FooterMargin" value="22.6771653543307" type="Double" /></columnFormats><views><view name="Show data"><column name="" property="ListObjectName" value="invoice_details" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="order_number" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="order_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="expiration_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="delivery_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="due_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_company" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_slogan" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_salesperson" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_prepared_by" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_phone" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_email" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_address" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_bank" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_bank_address" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_bank_swift" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_account_holder" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_account_number" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_account_string1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_account_string2" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer_customer" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer_company" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer_contact" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer_phone" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer_email" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer_address" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer_sales_tax" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sku" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="product_name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="base_unit_price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="discount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="unit_price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="subtotal" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sales_tax" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="total" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="dummy1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="dummy2" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Item " property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Qty " property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Part #" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Description" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Unit Price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name=" Total " property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Hide data"><column name="" property="ListObjectName" value="invoice_details" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="order_number" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="order_date" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="expiration_date" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="delivery_date" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="due_date" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_company" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_slogan" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_salesperson" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_prepared_by" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_phone" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_email" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_address" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_bank" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_bank_address" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_bank_swift" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_account_holder" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_account_number" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_account_string1" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_account_string2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_customer" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_company" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_contact" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_phone" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_email" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_address" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_sales_tax" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="item" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="sku" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="product_name" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="base_unit_price" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="discount" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="amount" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="unit_price" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="subtotal" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="sales_tax" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="total" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="dummy1" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="dummy2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="Item " property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Qty " property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Part #" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Description" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Unit Price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name=" Total " property="EntireColumn.Hidden" value="False" type="Boolean" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's05', N'usp_order_details', N'<table name="s05.usp_order_details"><columnFormats><column name="" property="ListObjectName" value="order_details" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$8" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="Address" value="$C$8" type="String" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="level" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="level" property="Address" value="$D$8" type="String" /><column name="level" property="NumberFormat" value="General" type="String" /><column name="sku" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sku" property="Address" value="$E$8" type="String" /><column name="sku" property="ColumnWidth" value="7.71" type="Double" /><column name="sku" property="NumberFormat" value="General" type="String" /><column name="product_name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="product_name" property="Address" value="$F$8" type="String" /><column name="product_name" property="ColumnWidth" value="69.29" type="Double" /><column name="product_name" property="NumberFormat" value="General" type="String" /><column name="unit_price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="unit_price" property="Address" value="$G$8" type="String" /><column name="unit_price" property="ColumnWidth" value="11.29" type="Double" /><column name="unit_price" property="NumberFormat" value="#,##0.00;[Red]-#,##0.00;" type="String" /><column name="amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="amount" property="Address" value="$H$8" type="String" /><column name="amount" property="ColumnWidth" value="9.43" type="Double" /><column name="amount" property="NumberFormat" value="General" type="String" /><column name="subtotal" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="subtotal" property="Address" value="$I$8" type="String" /><column name="subtotal" property="FormulaR1C1" value="=[@[unit_price]]*[@Amount]" type="String" /><column name="subtotal" property="ColumnWidth" value="9.29" type="Double" /><column name="subtotal" property="NumberFormat" value="#,##0.00;[Red]-#,##0.00;" type="String" /><column name="sales_tax" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sales_tax" property="Address" value="$J$8" type="String" /><column name="sales_tax" property="FormulaR1C1" value="=ROUND([@Subtotal]*0.01,2)" type="String" /><column name="sales_tax" property="ColumnWidth" value="12.43" type="Double" /><column name="sales_tax" property="NumberFormat" value="#,##0.00;[Red]-#,##0.00;" type="String" /><column name="total" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="total" property="Address" value="$K$8" type="String" /><column name="total" property="FormulaR1C1" value="=[@Subtotal]+[@[sales_tax]]" type="String" /><column name="total" property="ColumnWidth" value="10" type="Double" /><column name="total" property="NumberFormat" value="#,##0.00;[Red]-#,##0.00;" type="String" /><column name="_RowNum" property="FormatConditions(1).AppliesToTable" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(1).AppliesTo.Address" value="$B$8:$K$30" type="String" /><column name="_RowNum" property="FormatConditions(1).Type" value="2" type="Double" /><column name="_RowNum" property="FormatConditions(1).Priority" value="3" type="Double" /><column name="_RowNum" property="FormatConditions(1).Formula1" value="=$D8=2" type="String" /><column name="_RowNum" property="FormatConditions(1).Font.Bold" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(1).Interior.Color" value="14136213" type="Double" /><column name="_RowNum" property="FormatConditions(1).Interior.ThemeColor" value="5" type="Double" /><column name="_RowNum" property="FormatConditions(1).Interior.TintAndShade" value="0.399914548173467" type="Double" /><column name="_RowNum" property="FormatConditions(2).AppliesToTable" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(2).AppliesTo.Address" value="$B$8:$K$30" type="String" /><column name="_RowNum" property="FormatConditions(2).Type" value="2" type="Double" /><column name="_RowNum" property="FormatConditions(2).Priority" value="4" type="Double" /><column name="_RowNum" property="FormatConditions(2).Formula1" value="=$D8=1" type="String" /><column name="_RowNum" property="FormatConditions(2).Font.Bold" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(2).Font.Color" value="16777215" type="Double" /><column name="_RowNum" property="FormatConditions(2).Font.ThemeColor" value="1" type="Double" /><column name="_RowNum" property="FormatConditions(2).Font.TintAndShade" value="0" type="Double" /><column name="_RowNum" property="FormatConditions(2).Interior.Color" value="6299648" type="Double" /><column name="_RowNum" property="FormatConditions(2).Interior.Color" value="6299648" type="Double" /><column name="" property="AutoFilter.Off" value="True" type="Boolean" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats><views><view name="Form"><column name="" property="ListObjectName" value="order_details" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="level" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="sku" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="product_name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="unit_price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="subtotal" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sales_tax" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="total" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="" property="AutoFilter.Off" value="True" type="Boolean" /></view><view name="Short Form"><column name="" property="ListObjectName" value="order_details" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="level" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="sku" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="product_name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="unit_price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="subtotal" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sales_tax" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="total" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="" property="AutoFilter.Off" value="True" type="Boolean" /></view><view name="All columns"><column name="" property="ListObjectName" value="order_details" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="level" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sku" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="product_name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="unit_price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="subtotal" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sales_tax" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="total" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="" property="AutoFilter.Off" value="True" type="Boolean" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's05', N'usp_order_header', N'<table name="s05.usp_order_header"><columnFormats><column name="" property="ListObjectName" value="order_header" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleLight12" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="sales_tax" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="sales_tax" property="Address" value="$D$4" type="String" /><column name="sales_tax" property="NumberFormat" value="General" type="String" /><column name="seller_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_id" property="Address" value="$E$4" type="String" /><column name="seller_id" property="ColumnWidth" value="7.71" type="Double" /><column name="seller_id" property="NumberFormat" value="General" type="String" /><column name="seller_id" property="Validation.Type" value="3" type="Double" /><column name="seller_id" property="Validation.Operator" value="1" type="Double" /><column name="seller_id" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s05_sellers_id_code[code]&quot;)" type="String" /><column name="seller_id" property="Validation.AlertStyle" value="1" type="Double" /><column name="seller_id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="seller_id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="seller_id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="seller_id" property="Validation.ShowError" value="True" type="Boolean" /><column name="customer_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer_id" property="Address" value="$F$4" type="String" /><column name="customer_id" property="ColumnWidth" value="69.29" type="Double" /><column name="customer_id" property="NumberFormat" value="General" type="String" /><column name="customer_id" property="Font.Bold" value="True" type="Boolean" /><column name="customer_id" property="Font.Size" value="12" type="Double" /><column name="customer_id" property="Validation.Type" value="3" type="Double" /><column name="customer_id" property="Validation.Operator" value="1" type="Double" /><column name="customer_id" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s05_customers_id_customer[customer]&quot;)" type="String" /><column name="customer_id" property="Validation.AlertStyle" value="1" type="Double" /><column name="customer_id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="customer_id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="customer_id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="customer_id" property="Validation.ShowError" value="True" type="Boolean" /><column name="order_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="order_date" property="Address" value="$G$4" type="String" /><column name="order_date" property="ColumnWidth" value="11.29" type="Double" /><column name="order_date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="order_date" property="HorizontalAlignment" value="-4108" type="Double" /><column name="order_date" property="Validation.Type" value="4" type="Double" /><column name="order_date" property="Validation.Operator" value="5" type="Double" /><column name="order_date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="order_date" property="Validation.AlertStyle" value="1" type="Double" /><column name="order_date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="order_date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="order_date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="order_date" property="Validation.ShowError" value="True" type="Boolean" /><column name="order_number" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="order_number" property="Address" value="$H$4" type="String" /><column name="order_number" property="ColumnWidth" value="9.43" type="Double" /><column name="order_number" property="NumberFormat" value="General" type="String" /><column name="order_number" property="HorizontalAlignment" value="-4108" type="Double" /><column name="order_number" property="Font.Bold" value="True" type="Boolean" /><column name="order_number" property="Font.Size" value="12" type="Double" /><column name="order_number" property="Validation.Type" value="6" type="Double" /><column name="order_number" property="Validation.Operator" value="8" type="Double" /><column name="order_number" property="Validation.Formula1" value="50" type="String" /><column name="order_number" property="Validation.AlertStyle" value="1" type="Double" /><column name="order_number" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="order_number" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="order_number" property="Validation.ShowInput" value="True" type="Boolean" /><column name="order_number" property="Validation.ShowError" value="True" type="Boolean" /><column name="expiration_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="expiration_date" property="Address" value="$I$4" type="String" /><column name="expiration_date" property="ColumnWidth" value="9.29" type="Double" /><column name="expiration_date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="delivery_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="delivery_date" property="Address" value="$J$4" type="String" /><column name="delivery_date" property="ColumnWidth" value="12.43" type="Double" /><column name="delivery_date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="due_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="due_date" property="Address" value="$K$4" type="String" /><column name="due_date" property="ColumnWidth" value="10" type="Double" /><column name="due_date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="" property="AutoFilter.Off" value="True" type="Boolean" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="Tab.Color" value="5287936" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="4" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's05', N'usp_products', N'<table name="s05.usp_products"><columnFormats><column name="" property="ListObjectName" value="products" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="level" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="level" property="Address" value="$D$4" type="String" /><column name="level" property="NumberFormat" value="General" type="String" /><column name="category_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="category_id" property="Address" value="$E$4" type="String" /><column name="category_id" property="NumberFormat" value="General" type="String" /><column name="subcategory_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="subcategory_id" property="Address" value="$F$4" type="String" /><column name="subcategory_id" property="NumberFormat" value="General" type="String" /><column name="brand_id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="brand_id" property="Address" value="$G$4" type="String" /><column name="brand_id" property="NumberFormat" value="General" type="String" /><column name="sku" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sku" property="Address" value="$H$4" type="String" /><column name="sku" property="ColumnWidth" value="8.43" type="Double" /><column name="sku" property="NumberFormat" value="@" type="String" /><column name="product_name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="product_name" property="Address" value="$I$4" type="String" /><column name="product_name" property="ColumnWidth" value="69.29" type="Double" /><column name="product_name" property="NumberFormat" value="General" type="String" /><column name="unit_price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="unit_price" property="Address" value="$J$4" type="String" /><column name="unit_price" property="ColumnWidth" value="11.29" type="Double" /><column name="unit_price" property="NumberFormat" value="#,##0.00" type="String" /><column name="_RowNum" property="FormatConditions(1).AppliesToTable" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(1).AppliesTo.Address" value="$B$4:$J$26" type="String" /><column name="_RowNum" property="FormatConditions(1).Type" value="2" type="Double" /><column name="_RowNum" property="FormatConditions(1).Priority" value="3" type="Double" /><column name="_RowNum" property="FormatConditions(1).Formula1" value="=$D4=2" type="String" /><column name="_RowNum" property="FormatConditions(1).Font.Bold" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(1).Interior.Color" value="14136213" type="Double" /><column name="_RowNum" property="FormatConditions(1).Interior.ThemeColor" value="5" type="Double" /><column name="_RowNum" property="FormatConditions(1).Interior.TintAndShade" value="0.399914548173467" type="Double" /><column name="_RowNum" property="FormatConditions(2).AppliesToTable" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(2).AppliesTo.Address" value="$B$4:$J$26" type="String" /><column name="_RowNum" property="FormatConditions(2).Type" value="2" type="Double" /><column name="_RowNum" property="FormatConditions(2).Priority" value="4" type="Double" /><column name="_RowNum" property="FormatConditions(2).Formula1" value="=$D4=1" type="String" /><column name="_RowNum" property="FormatConditions(2).Font.Bold" value="True" type="Boolean" /><column name="_RowNum" property="FormatConditions(2).Font.Color" value="16777215" type="Double" /><column name="_RowNum" property="FormatConditions(2).Font.ThemeColor" value="1" type="Double" /><column name="_RowNum" property="FormatConditions(2).Font.TintAndShade" value="0" type="Double" /><column name="_RowNum" property="FormatConditions(2).Interior.Color" value="6299648" type="Double" /><column name="_RowNum" property="FormatConditions(2).Interior.Color" value="6299648" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="Tab.Color" value="6299648" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's05', N'usp_quote_print_details', N'<table name="s05.usp_quote_print_details"><columnFormats><column name="" property="ListObjectName" value="quote_details" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="Table Style 1" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="True" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$19" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="_RowNum" property="VerticalAlignment" value="-4160" type="Double" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="Address" value="$C$19" type="String" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="VerticalAlignment" value="-4160" type="Double" /><column name="order_number" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="order_number" property="Address" value="$D$19" type="String" /><column name="order_number" property="NumberFormat" value="General" type="String" /><column name="order_number" property="VerticalAlignment" value="-4160" type="Double" /><column name="order_date" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="order_date" property="Address" value="$E$19" type="String" /><column name="order_date" property="NumberFormat" value="yyyy/mm/dd;@" type="String" /><column name="order_date" property="VerticalAlignment" value="-4160" type="Double" /><column name="expiration_date" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="expiration_date" property="Address" value="$F$19" type="String" /><column name="expiration_date" property="NumberFormat" value="General" type="String" /><column name="expiration_date" property="VerticalAlignment" value="-4160" type="Double" /><column name="delivery_date" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="delivery_date" property="Address" value="$G$19" type="String" /><column name="delivery_date" property="NumberFormat" value="General" type="String" /><column name="delivery_date" property="VerticalAlignment" value="-4160" type="Double" /><column name="due_date" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="due_date" property="Address" value="$H$19" type="String" /><column name="due_date" property="NumberFormat" value="General" type="String" /><column name="due_date" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller" property="Address" value="$I$19" type="String" /><column name="seller" property="NumberFormat" value="General" type="String" /><column name="seller" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_company" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_company" property="Address" value="$J$19" type="String" /><column name="seller_company" property="NumberFormat" value="General" type="String" /><column name="seller_company" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_slogan" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_slogan" property="Address" value="$K$19" type="String" /><column name="seller_slogan" property="NumberFormat" value="General" type="String" /><column name="seller_slogan" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_salesperson" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_salesperson" property="Address" value="$L$19" type="String" /><column name="seller_salesperson" property="NumberFormat" value="General" type="String" /><column name="seller_salesperson" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_prepared_by" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_prepared_by" property="Address" value="$M$19" type="String" /><column name="seller_prepared_by" property="NumberFormat" value="General" type="String" /><column name="seller_prepared_by" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_phone" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_phone" property="Address" value="$N$19" type="String" /><column name="seller_phone" property="NumberFormat" value="General" type="String" /><column name="seller_phone" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_email" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_email" property="Address" value="$O$19" type="String" /><column name="seller_email" property="NumberFormat" value="General" type="String" /><column name="seller_email" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_address" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_address" property="Address" value="$P$19" type="String" /><column name="seller_address" property="NumberFormat" value="General" type="String" /><column name="seller_address" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_bank" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_bank" property="Address" value="$Q$19" type="String" /><column name="seller_bank" property="NumberFormat" value="General" type="String" /><column name="seller_bank" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_bank_address" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_bank_address" property="Address" value="$R$19" type="String" /><column name="seller_bank_address" property="NumberFormat" value="General" type="String" /><column name="seller_bank_address" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_bank_swift" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_bank_swift" property="Address" value="$S$19" type="String" /><column name="seller_bank_swift" property="NumberFormat" value="General" type="String" /><column name="seller_bank_swift" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_account_holder" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_account_holder" property="Address" value="$T$19" type="String" /><column name="seller_account_holder" property="NumberFormat" value="General" type="String" /><column name="seller_account_holder" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_account_number" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_account_number" property="Address" value="$U$19" type="String" /><column name="seller_account_number" property="NumberFormat" value="General" type="String" /><column name="seller_account_number" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_account_string1" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_account_string1" property="Address" value="$V$19" type="String" /><column name="seller_account_string1" property="NumberFormat" value="General" type="String" /><column name="seller_account_string1" property="VerticalAlignment" value="-4160" type="Double" /><column name="seller_account_string2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_account_string2" property="Address" value="$W$19" type="String" /><column name="seller_account_string2" property="NumberFormat" value="General" type="String" /><column name="seller_account_string2" property="VerticalAlignment" value="-4160" type="Double" /><column name="customer_customer" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_customer" property="Address" value="$X$19" type="String" /><column name="customer_customer" property="NumberFormat" value="General" type="String" /><column name="customer_customer" property="VerticalAlignment" value="-4160" type="Double" /><column name="customer_company" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_company" property="Address" value="$Y$19" type="String" /><column name="customer_company" property="NumberFormat" value="General" type="String" /><column name="customer_company" property="VerticalAlignment" value="-4160" type="Double" /><column name="customer_contact" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_contact" property="Address" value="$Z$19" type="String" /><column name="customer_contact" property="NumberFormat" value="General" type="String" /><column name="customer_contact" property="VerticalAlignment" value="-4160" type="Double" /><column name="customer_phone" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_phone" property="Address" value="$AA$19" type="String" /><column name="customer_phone" property="NumberFormat" value="General" type="String" /><column name="customer_phone" property="VerticalAlignment" value="-4160" type="Double" /><column name="customer_email" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_email" property="Address" value="$AB$19" type="String" /><column name="customer_email" property="NumberFormat" value="General" type="String" /><column name="customer_email" property="VerticalAlignment" value="-4160" type="Double" /><column name="customer_address" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_address" property="Address" value="$AC$19" type="String" /><column name="customer_address" property="NumberFormat" value="General" type="String" /><column name="customer_address" property="VerticalAlignment" value="-4160" type="Double" /><column name="customer_sales_tax" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_sales_tax" property="Address" value="$AD$19" type="String" /><column name="customer_sales_tax" property="NumberFormat" value="General" type="String" /><column name="customer_sales_tax" property="VerticalAlignment" value="-4160" type="Double" /><column name="item" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="item" property="Address" value="$AE$19" type="String" /><column name="item" property="NumberFormat" value="General" type="String" /><column name="item" property="VerticalAlignment" value="-4160" type="Double" /><column name="sku" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="sku" property="Address" value="$AF$19" type="String" /><column name="sku" property="NumberFormat" value="General" type="String" /><column name="sku" property="VerticalAlignment" value="-4160" type="Double" /><column name="product_name" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="product_name" property="Address" value="$AG$19" type="String" /><column name="product_name" property="NumberFormat" value="General" type="String" /><column name="product_name" property="VerticalAlignment" value="-4160" type="Double" /><column name="base_unit_price" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="base_unit_price" property="Address" value="$AH$19" type="String" /><column name="base_unit_price" property="NumberFormat" value="General" type="String" /><column name="base_unit_price" property="VerticalAlignment" value="-4160" type="Double" /><column name="discount" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="discount" property="Address" value="$AI$19" type="String" /><column name="discount" property="NumberFormat" value="General" type="String" /><column name="discount" property="VerticalAlignment" value="-4160" type="Double" /><column name="amount" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="amount" property="Address" value="$AJ$19" type="String" /><column name="amount" property="NumberFormat" value="General" type="String" /><column name="amount" property="VerticalAlignment" value="-4160" type="Double" /><column name="unit_price" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="unit_price" property="Address" value="$AK$19" type="String" /><column name="unit_price" property="NumberFormat" value="General" type="String" /><column name="unit_price" property="VerticalAlignment" value="-4160" type="Double" /><column name="subtotal" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="subtotal" property="Address" value="$AL$19" type="String" /><column name="subtotal" property="NumberFormat" value="General" type="String" /><column name="subtotal" property="VerticalAlignment" value="-4160" type="Double" /><column name="sales_tax" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="sales_tax" property="Address" value="$AM$19" type="String" /><column name="sales_tax" property="NumberFormat" value="General" type="String" /><column name="sales_tax" property="VerticalAlignment" value="-4160" type="Double" /><column name="total" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="total" property="Address" value="$AN$19" type="String" /><column name="total" property="NumberFormat" value="General" type="String" /><column name="total" property="VerticalAlignment" value="-4160" type="Double" /><column name="Item " property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Item " property="Address" value="$AO$19" type="String" /><column name="Item " property="FormulaR1C1" value="=[@item]" type="String" /><column name="Item " property="ColumnWidth" value="6.43" type="Double" /><column name="Item " property="NumberFormat" value="General" type="String" /><column name="Item " property="HorizontalAlignment" value="-4108" type="Double" /><column name="Item " property="VerticalAlignment" value="-4160" type="Double" /><column name="Qty" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Qty" property="Address" value="$AP$19" type="String" /><column name="Qty" property="FormulaR1C1" value="=[@amount]" type="String" /><column name="Qty" property="ColumnWidth" value="6.43" type="Double" /><column name="Qty" property="NumberFormat" value="General" type="String" /><column name="Qty" property="HorizontalAlignment" value="-4108" type="Double" /><column name="Qty" property="VerticalAlignment" value="-4160" type="Double" /><column name="Part #" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Part #" property="Address" value="$AQ$19" type="String" /><column name="Part #" property="FormulaR1C1" value="=[@sku]" type="String" /><column name="Part #" property="ColumnWidth" value="7.86" type="Double" /><column name="Part #" property="NumberFormat" value="General" type="String" /><column name="Part #" property="HorizontalAlignment" value="-4108" type="Double" /><column name="Part #" property="VerticalAlignment" value="-4160" type="Double" /><column name="Description" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Description" property="Address" value="$AR$19" type="String" /><column name="Description" property="FormulaR1C1" value="=[@[product_name]]" type="String" /><column name="Description" property="ColumnWidth" value="42.14" type="Double" /><column name="Description" property="NumberFormat" value="General" type="String" /><column name="Description" property="VerticalAlignment" value="-4160" type="Double" /><column name="Description" property="WrapText" value="True" type="Boolean" /><column name="Unit Price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Unit Price" property="Address" value="$AS$19" type="String" /><column name="Unit Price" property="FormulaR1C1" value="=[@[base_unit_price]]" type="String" /><column name="Unit Price" property="ColumnWidth" value="10" type="Double" /><column name="Unit Price" property="NumberFormat" value="_(&quot;$&quot;* #,##0.00_);_(&quot;$&quot;* (#,##0.00);;_(@_)" type="String" /><column name="Unit Price" property="VerticalAlignment" value="-4160" type="Double" /><column name=" Discount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name=" Discount" property="Address" value="$AT$19" type="String" /><column name=" Discount" property="FormulaR1C1" value="=[@discount]" type="String" /><column name=" Discount" property="ColumnWidth" value="10" type="Double" /><column name=" Discount" property="NumberFormat" value="_(&quot;$&quot;* #,##0.00_);_(&quot;$&quot;* (#,##0.00);;_(@_)" type="String" /><column name=" Discount" property="VerticalAlignment" value="-4160" type="Double" /><column name=" Total " property="EntireColumn.Hidden" value="False" type="Boolean" /><column name=" Total " property="Address" value="$AU$19" type="String" /><column name=" Total " property="FormulaR1C1" value="=[@subtotal]" type="String" /><column name=" Total " property="ColumnWidth" value="10" type="Double" /><column name=" Total " property="NumberFormat" value="_(&quot;$&quot;* #,##0.00_);_(&quot;$&quot;* (#,##0.00);;_(@_)" type="String" /><column name=" Total " property="VerticalAlignment" value="-4160" type="Double" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="False" type="Boolean" /><column name="" property="ActiveWindow.Split" value="False" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="-18" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /><column name="" property="PageSetup.LeftMargin" value="31.1811023622047" type="Double" /><column name="" property="PageSetup.RightMargin" value="31.1811023622047" type="Double" /><column name="" property="PageSetup.TopMargin" value="53.8582677165354" type="Double" /><column name="" property="PageSetup.BottomMargin" value="53.8582677165354" type="Double" /><column name="" property="PageSetup.HeaderMargin" value="22.6771653543307" type="Double" /><column name="" property="PageSetup.FooterMargin" value="22.6771653543307" type="Double" /></columnFormats><views><view name="Show data"><column name="" property="ListObjectName" value="quote_details" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="order_number" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="order_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="expiration_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="delivery_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="due_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_company" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_slogan" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_salesperson" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_prepared_by" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_phone" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_email" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_address" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_bank" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_bank_address" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_bank_swift" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_account_holder" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_account_number" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_account_string1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_account_string2" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer_customer" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer_company" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer_contact" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer_phone" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer_email" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer_address" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer_sales_tax" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="item" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sku" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="product_name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="base_unit_price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="discount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="unit_price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="subtotal" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sales_tax" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="total" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="dummy1" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="dummy2" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Item " property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Qty" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Part #" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Description" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Unit Price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name=" Discount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name=" Total " property="EntireColumn.Hidden" value="False" type="Boolean" /></view><view name="Hide data"><column name="" property="ListObjectName" value="quote_details" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="order_number" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="order_date" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="expiration_date" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="delivery_date" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="due_date" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_company" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_slogan" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_salesperson" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_prepared_by" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_phone" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_email" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_address" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_bank" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_bank_address" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_bank_swift" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_account_holder" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_account_number" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_account_string1" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="seller_account_string2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_customer" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_company" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_contact" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_phone" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_email" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_address" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="customer_sales_tax" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="item" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="sku" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="product_name" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="base_unit_price" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="discount" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="amount" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="unit_price" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="subtotal" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="sales_tax" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="total" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="dummy1" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="dummy2" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="Item " property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Qty" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Part #" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Description" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="Unit Price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name=" Discount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name=" Total " property="EntireColumn.Hidden" value="False" type="Boolean" /></view></views></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's05', N'view_order_details', N'<table name="s05.view_order_details"><columnFormats><column name="" property="ListObjectName" value="view_order_details" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="order_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="order_id" property="Address" value="$D$4" type="String" /><column name="order_id" property="ColumnWidth" value="10.14" type="Double" /><column name="order_id" property="NumberFormat" value="General" type="String" /><column name="order_id" property="Validation.Type" value="3" type="Double" /><column name="order_id" property="Validation.Operator" value="1" type="Double" /><column name="order_id" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s05_orders_id[id]&quot;)" type="String" /><column name="order_id" property="Validation.AlertStyle" value="1" type="Double" /><column name="order_id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="order_id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="order_id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="order_id" property="Validation.ShowError" value="True" type="Boolean" /><column name="order_month" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="order_month" property="Address" value="$E$4" type="String" /><column name="order_month" property="ColumnWidth" value="14.29" type="Double" /><column name="order_month" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="order_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="order_date" property="Address" value="$F$4" type="String" /><column name="order_date" property="ColumnWidth" value="12.43" type="Double" /><column name="order_date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="order_date" property="Validation.Type" value="4" type="Double" /><column name="order_date" property="Validation.Operator" value="5" type="Double" /><column name="order_date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="order_date" property="Validation.AlertStyle" value="1" type="Double" /><column name="order_date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="order_date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="order_date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="order_date" property="Validation.ShowError" value="True" type="Boolean" /><column name="order_number" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="order_number" property="Address" value="$G$4" type="String" /><column name="order_number" property="ColumnWidth" value="15.57" type="Double" /><column name="order_number" property="NumberFormat" value="General" type="String" /><column name="order_number" property="Validation.Type" value="6" type="Double" /><column name="order_number" property="Validation.Operator" value="8" type="Double" /><column name="order_number" property="Validation.Formula1" value="50" type="String" /><column name="order_number" property="Validation.AlertStyle" value="1" type="Double" /><column name="order_number" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="order_number" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="order_number" property="Validation.ShowInput" value="True" type="Boolean" /><column name="order_number" property="Validation.ShowError" value="True" type="Boolean" /><column name="expiration_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="expiration_date" property="Address" value="$H$4" type="String" /><column name="expiration_date" property="ColumnWidth" value="16.86" type="Double" /><column name="expiration_date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="expiration_date" property="Validation.Type" value="4" type="Double" /><column name="expiration_date" property="Validation.Operator" value="5" type="Double" /><column name="expiration_date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="expiration_date" property="Validation.AlertStyle" value="1" type="Double" /><column name="expiration_date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="expiration_date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="expiration_date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="expiration_date" property="Validation.ShowError" value="True" type="Boolean" /><column name="delivery_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="delivery_date" property="Address" value="$I$4" type="String" /><column name="delivery_date" property="ColumnWidth" value="15" type="Double" /><column name="delivery_date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="delivery_date" property="Validation.Type" value="4" type="Double" /><column name="delivery_date" property="Validation.Operator" value="5" type="Double" /><column name="delivery_date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="delivery_date" property="Validation.AlertStyle" value="1" type="Double" /><column name="delivery_date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="delivery_date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="delivery_date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="delivery_date" property="Validation.ShowError" value="True" type="Boolean" /><column name="due_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="due_date" property="Address" value="$J$4" type="String" /><column name="due_date" property="ColumnWidth" value="11" type="Double" /><column name="due_date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="due_date" property="Validation.Type" value="4" type="Double" /><column name="due_date" property="Validation.Operator" value="5" type="Double" /><column name="due_date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="due_date" property="Validation.AlertStyle" value="1" type="Double" /><column name="due_date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="due_date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="due_date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="due_date" property="Validation.ShowError" value="True" type="Boolean" /><column name="customer" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer" property="Address" value="$K$4" type="String" /><column name="customer" property="ColumnWidth" value="11.14" type="Double" /><column name="customer" property="NumberFormat" value="General" type="String" /><column name="customer" property="Validation.Type" value="6" type="Double" /><column name="customer" property="Validation.Operator" value="8" type="Double" /><column name="customer" property="Validation.Formula1" value="50" type="String" /><column name="customer" property="Validation.AlertStyle" value="1" type="Double" /><column name="customer" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="customer" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="customer" property="Validation.ShowInput" value="True" type="Boolean" /><column name="customer" property="Validation.ShowError" value="True" type="Boolean" /><column name="seller" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller" property="Address" value="$L$4" type="String" /><column name="seller" property="ColumnWidth" value="8" type="Double" /><column name="seller" property="NumberFormat" value="General" type="String" /><column name="seller" property="Validation.Type" value="6" type="Double" /><column name="seller" property="Validation.Operator" value="8" type="Double" /><column name="seller" property="Validation.Formula1" value="20" type="String" /><column name="seller" property="Validation.AlertStyle" value="1" type="Double" /><column name="seller" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="seller" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="seller" property="Validation.ShowInput" value="True" type="Boolean" /><column name="seller" property="Validation.ShowError" value="True" type="Boolean" /><column name="category" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="category" property="Address" value="$M$4" type="String" /><column name="category" property="ColumnWidth" value="13.43" type="Double" /><column name="category" property="NumberFormat" value="General" type="String" /><column name="category" property="Validation.Type" value="6" type="Double" /><column name="category" property="Validation.Operator" value="8" type="Double" /><column name="category" property="Validation.Formula1" value="255" type="String" /><column name="category" property="Validation.AlertStyle" value="1" type="Double" /><column name="category" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="category" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="category" property="Validation.ShowInput" value="True" type="Boolean" /><column name="category" property="Validation.ShowError" value="True" type="Boolean" /><column name="brand" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="brand" property="Address" value="$N$4" type="String" /><column name="brand" property="ColumnWidth" value="13" type="Double" /><column name="brand" property="NumberFormat" value="General" type="String" /><column name="brand" property="Validation.Type" value="6" type="Double" /><column name="brand" property="Validation.Operator" value="8" type="Double" /><column name="brand" property="Validation.Formula1" value="255" type="String" /><column name="brand" property="Validation.AlertStyle" value="1" type="Double" /><column name="brand" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="brand" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="brand" property="Validation.ShowInput" value="True" type="Boolean" /><column name="brand" property="Validation.ShowError" value="True" type="Boolean" /><column name="sku" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sku" property="Address" value="$O$4" type="String" /><column name="sku" property="ColumnWidth" value="6.29" type="Double" /><column name="sku" property="NumberFormat" value="General" type="String" /><column name="sku" property="Validation.Type" value="6" type="Double" /><column name="sku" property="Validation.Operator" value="8" type="Double" /><column name="sku" property="Validation.Formula1" value="50" type="String" /><column name="sku" property="Validation.AlertStyle" value="1" type="Double" /><column name="sku" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="sku" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="sku" property="Validation.ShowInput" value="True" type="Boolean" /><column name="sku" property="Validation.ShowError" value="True" type="Boolean" /><column name="product_name" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="product_name" property="Address" value="$P$4" type="String" /><column name="product_name" property="ColumnWidth" value="63" type="Double" /><column name="product_name" property="NumberFormat" value="General" type="String" /><column name="product_name" property="Validation.Type" value="6" type="Double" /><column name="product_name" property="Validation.Operator" value="8" type="Double" /><column name="product_name" property="Validation.Formula1" value="255" type="String" /><column name="product_name" property="Validation.AlertStyle" value="1" type="Double" /><column name="product_name" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="product_name" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="product_name" property="Validation.ShowInput" value="True" type="Boolean" /><column name="product_name" property="Validation.ShowError" value="True" type="Boolean" /><column name="base_unit_price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="base_unit_price" property="Address" value="$Q$4" type="String" /><column name="base_unit_price" property="ColumnWidth" value="16.86" type="Double" /><column name="base_unit_price" property="NumberFormat" value="General" type="String" /><column name="discount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="discount" property="Address" value="$R$4" type="String" /><column name="discount" property="ColumnWidth" value="10.29" type="Double" /><column name="discount" property="NumberFormat" value="General" type="String" /><column name="discount" property="Validation.Type" value="2" type="Double" /><column name="discount" property="Validation.Operator" value="4" type="Double" /><column name="discount" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="discount" property="Validation.AlertStyle" value="1" type="Double" /><column name="discount" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="discount" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="discount" property="Validation.ShowInput" value="True" type="Boolean" /><column name="discount" property="Validation.ShowError" value="True" type="Boolean" /><column name="amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="amount" property="Address" value="$S$4" type="String" /><column name="amount" property="ColumnWidth" value="9.71" type="Double" /><column name="amount" property="NumberFormat" value="General" type="String" /><column name="amount" property="Validation.Type" value="2" type="Double" /><column name="amount" property="Validation.Operator" value="4" type="Double" /><column name="amount" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="amount" property="Validation.AlertStyle" value="1" type="Double" /><column name="amount" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="amount" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="amount" property="Validation.ShowInput" value="True" type="Boolean" /><column name="amount" property="Validation.ShowError" value="True" type="Boolean" /><column name="unit_price" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="unit_price" property="Address" value="$T$4" type="String" /><column name="unit_price" property="ColumnWidth" value="11.29" type="Double" /><column name="unit_price" property="NumberFormat" value="General" type="String" /><column name="unit_price" property="Validation.Type" value="2" type="Double" /><column name="unit_price" property="Validation.Operator" value="4" type="Double" /><column name="unit_price" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="unit_price" property="Validation.AlertStyle" value="1" type="Double" /><column name="unit_price" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="unit_price" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="unit_price" property="Validation.ShowInput" value="True" type="Boolean" /><column name="unit_price" property="Validation.ShowError" value="True" type="Boolean" /><column name="subtotal" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="subtotal" property="Address" value="$U$4" type="String" /><column name="subtotal" property="ColumnWidth" value="9.86" type="Double" /><column name="subtotal" property="NumberFormat" value="General" type="String" /><column name="sales_tax" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sales_tax" property="Address" value="$V$4" type="String" /><column name="sales_tax" property="ColumnWidth" value="10.71" type="Double" /><column name="sales_tax" property="NumberFormat" value="General" type="String" /><column name="total" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="total" property="Address" value="$W$4" type="String" /><column name="total" property="ColumnWidth" value="6.71" type="Double" /><column name="total" property="NumberFormat" value="General" type="String" /><column name="total" property="Validation.Type" value="2" type="Double" /><column name="total" property="Validation.Operator" value="4" type="Double" /><column name="total" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="total" property="Validation.AlertStyle" value="1" type="Double" /><column name="total" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="total" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="total" property="Validation.ShowInput" value="True" type="Boolean" /><column name="total" property="Validation.ShowError" value="True" type="Boolean" /><column name="order_id" property="FormatConditions(1).ColumnsCount" value="2" type="Double" /><column name="order_id" property="FormatConditions(1).AppliesTo.Address" value="$D$4:$E$9" type="String" /><column name="order_id" property="FormatConditions(1).Type" value="2" type="Double" /><column name="order_id" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="order_id" property="FormatConditions(1).Formula1" value="=ISBLANK(D4)" type="String" /><column name="order_id" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="order_id" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
INSERT INTO xls.formats (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES (N's05', N'view_orders', N'<table name="s05.view_orders"><columnFormats><column name="" property="ListObjectName" value="view_orders" type="String" /><column name="" property="ShowTotals" value="False" type="Boolean" /><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String" /><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean" /><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean" /><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean" /><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean" /><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean" /><column name="_RowNum" property="Address" value="$B$4" type="String" /><column name="_RowNum" property="NumberFormat" value="General" type="String" /><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="id" property="Address" value="$C$4" type="String" /><column name="id" property="ColumnWidth" value="4.29" type="Double" /><column name="id" property="NumberFormat" value="General" type="String" /><column name="id" property="Validation.Type" value="1" type="Double" /><column name="id" property="Validation.Operator" value="1" type="Double" /><column name="id" property="Validation.Formula1" value="-2147483648" type="String" /><column name="id" property="Validation.Formula2" value="2147483647" type="String" /><column name="id" property="Validation.AlertStyle" value="1" type="Double" /><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="id" property="Validation.ShowError" value="True" type="Boolean" /><column name="order_month" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="order_month" property="Address" value="$D$4" type="String" /><column name="order_month" property="ColumnWidth" value="14.29" type="Double" /><column name="order_month" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="order_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="order_date" property="Address" value="$E$4" type="String" /><column name="order_date" property="ColumnWidth" value="12.43" type="Double" /><column name="order_date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="order_date" property="Validation.Type" value="4" type="Double" /><column name="order_date" property="Validation.Operator" value="5" type="Double" /><column name="order_date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="order_date" property="Validation.AlertStyle" value="1" type="Double" /><column name="order_date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="order_date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="order_date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="order_date" property="Validation.ShowError" value="True" type="Boolean" /><column name="order_number" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="order_number" property="Address" value="$F$4" type="String" /><column name="order_number" property="ColumnWidth" value="15.57" type="Double" /><column name="order_number" property="NumberFormat" value="@" type="String" /><column name="order_number" property="Validation.Type" value="6" type="Double" /><column name="order_number" property="Validation.Operator" value="8" type="Double" /><column name="order_number" property="Validation.Formula1" value="50" type="String" /><column name="order_number" property="Validation.AlertStyle" value="1" type="Double" /><column name="order_number" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="order_number" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="order_number" property="Validation.ShowInput" value="True" type="Boolean" /><column name="order_number" property="Validation.ShowError" value="True" type="Boolean" /><column name="expiration_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="expiration_date" property="Address" value="$G$4" type="String" /><column name="expiration_date" property="ColumnWidth" value="16.86" type="Double" /><column name="expiration_date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="expiration_date" property="Validation.Type" value="4" type="Double" /><column name="expiration_date" property="Validation.Operator" value="5" type="Double" /><column name="expiration_date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="expiration_date" property="Validation.AlertStyle" value="1" type="Double" /><column name="expiration_date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="expiration_date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="expiration_date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="expiration_date" property="Validation.ShowError" value="True" type="Boolean" /><column name="delivery_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="delivery_date" property="Address" value="$H$4" type="String" /><column name="delivery_date" property="ColumnWidth" value="15" type="Double" /><column name="delivery_date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="delivery_date" property="Validation.Type" value="4" type="Double" /><column name="delivery_date" property="Validation.Operator" value="5" type="Double" /><column name="delivery_date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="delivery_date" property="Validation.AlertStyle" value="1" type="Double" /><column name="delivery_date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="delivery_date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="delivery_date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="delivery_date" property="Validation.ShowError" value="True" type="Boolean" /><column name="due_date" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="due_date" property="Address" value="$I$4" type="String" /><column name="due_date" property="ColumnWidth" value="11" type="Double" /><column name="due_date" property="NumberFormat" value="m/d/yyyy" type="String" /><column name="due_date" property="Validation.Type" value="4" type="Double" /><column name="due_date" property="Validation.Operator" value="5" type="Double" /><column name="due_date" property="Validation.Formula1" value="12/31/1899" type="String" /><column name="due_date" property="Validation.AlertStyle" value="1" type="Double" /><column name="due_date" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="due_date" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="due_date" property="Validation.ShowInput" value="True" type="Boolean" /><column name="due_date" property="Validation.ShowError" value="True" type="Boolean" /><column name="customer_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="customer_id" property="Address" value="$J$4" type="String" /><column name="customer_id" property="ColumnWidth" value="13.57" type="Double" /><column name="customer_id" property="NumberFormat" value="General" type="String" /><column name="customer_id" property="Validation.Type" value="3" type="Double" /><column name="customer_id" property="Validation.Operator" value="1" type="Double" /><column name="customer_id" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s05_customers_id_customer[customer]&quot;)" type="String" /><column name="customer_id" property="Validation.AlertStyle" value="1" type="Double" /><column name="customer_id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="customer_id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="customer_id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="customer_id" property="Validation.ShowError" value="True" type="Boolean" /><column name="seller_id" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="seller_id" property="Address" value="$K$4" type="String" /><column name="seller_id" property="ColumnWidth" value="11.57" type="Double" /><column name="seller_id" property="NumberFormat" value="General" type="String" /><column name="seller_id" property="Validation.Type" value="3" type="Double" /><column name="seller_id" property="Validation.Operator" value="1" type="Double" /><column name="seller_id" property="Validation.Formula1" value="=INDIRECT(&quot;vl_s05_sellers_id_code[code]&quot;)" type="String" /><column name="seller_id" property="Validation.AlertStyle" value="1" type="Double" /><column name="seller_id" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="seller_id" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="seller_id" property="Validation.ShowInput" value="True" type="Boolean" /><column name="seller_id" property="Validation.ShowError" value="True" type="Boolean" /><column name="discount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="discount" property="Address" value="$L$4" type="String" /><column name="discount" property="ColumnWidth" value="10.29" type="Double" /><column name="discount" property="NumberFormat" value="#,##0.00;[Red]-#,##0.00;" type="String" /><column name="items" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="items" property="Address" value="$M$4" type="String" /><column name="items" property="ColumnWidth" value="8.14" type="Double" /><column name="items" property="NumberFormat" value="General" type="String" /><column name="items" property="Validation.Type" value="1" type="Double" /><column name="items" property="Validation.Operator" value="1" type="Double" /><column name="items" property="Validation.Formula1" value="-2147483648" type="String" /><column name="items" property="Validation.Formula2" value="2147483647" type="String" /><column name="items" property="Validation.AlertStyle" value="1" type="Double" /><column name="items" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="items" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="items" property="Validation.ShowInput" value="True" type="Boolean" /><column name="items" property="Validation.ShowError" value="True" type="Boolean" /><column name="amount" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="amount" property="Address" value="$N$4" type="String" /><column name="amount" property="ColumnWidth" value="9.71" type="Double" /><column name="amount" property="NumberFormat" value="General" type="String" /><column name="subtotal" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="subtotal" property="Address" value="$O$4" type="String" /><column name="subtotal" property="ColumnWidth" value="10" type="Double" /><column name="subtotal" property="NumberFormat" value="#,##0.00;[Red]-#,##0.00;" type="String" /><column name="subtotal" property="Validation.Type" value="2" type="Double" /><column name="subtotal" property="Validation.Operator" value="4" type="Double" /><column name="subtotal" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="subtotal" property="Validation.AlertStyle" value="1" type="Double" /><column name="subtotal" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="subtotal" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="subtotal" property="Validation.ShowInput" value="True" type="Boolean" /><column name="subtotal" property="Validation.ShowError" value="True" type="Boolean" /><column name="sales_tax" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="sales_tax" property="Address" value="$P$4" type="String" /><column name="sales_tax" property="ColumnWidth" value="10.57" type="Double" /><column name="sales_tax" property="NumberFormat" value="#,##0.00;[Red]-#,##0.00;" type="String" /><column name="total" property="EntireColumn.Hidden" value="False" type="Boolean" /><column name="total" property="Address" value="$Q$4" type="String" /><column name="total" property="ColumnWidth" value="10" type="Double" /><column name="total" property="NumberFormat" value="#,##0.00;[Red]-#,##0.00;" type="String" /><column name="total" property="Validation.Type" value="2" type="Double" /><column name="total" property="Validation.Operator" value="4" type="Double" /><column name="total" property="Validation.Formula1" value="-1.11222333444555E+29" type="String" /><column name="total" property="Validation.AlertStyle" value="1" type="Double" /><column name="total" property="Validation.IgnoreBlank" value="True" type="Boolean" /><column name="total" property="Validation.InCellDropdown" value="True" type="Boolean" /><column name="total" property="Validation.ShowInput" value="True" type="Boolean" /><column name="total" property="Validation.ShowError" value="True" type="Boolean" /><column name="order_date" property="FormatConditions(1).AppliesTo.Address" value="$E$4:$E$6" type="String" /><column name="order_date" property="FormatConditions(1).Type" value="2" type="Double" /><column name="order_date" property="FormatConditions(1).Priority" value="1" type="Double" /><column name="order_date" property="FormatConditions(1).Formula1" value="=ISBLANK(E4)" type="String" /><column name="order_date" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="order_date" property="FormatConditions(1).Interior.Color" value="65535" type="Double" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="Tab.Color" value="10498160" type="Double" /><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean" /><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean" /><column name="" property="ActiveWindow.Split" value="True" type="Boolean" /><column name="" property="ActiveWindow.SplitRow" value="0" type="Double" /><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double" /><column name="" property="PageSetup.Orientation" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double" /><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double" /><column name="" property="PageSetup.PaperSize" value="1" type="Double" /></columnFormats></table>');
GO

INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'product_categories', NULL, N'Actions', N's05', N'xl_actions_update_product_categories', N'PROCEDURE', NULL, N'_reload', 11, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_invoice_print_details', NULL, N'Actions', N's05', N'Create Invoice PDF', N'PDF', NULL, NULL, 22, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_invoice_print_details', NULL, N'Actions', N's05', N'Create Invoice XLSX', N'REPORT', NULL, NULL, 23, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_invoice_print_details', NULL, N'Actions', N's05', N'MenuSeparator30', N'MENUSEPARATOR', NULL, NULL, 30, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_invoice_print_details', NULL, N'Actions', N's05', N'Create Quote & Invoice PDF', N'PDF', NULL, N'quote,invoice', 32, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_invoice_print_details', NULL, N'Actions', N's05', N'Create Quote & Invoice XSLX', N'REPORT', NULL, N'quote,invoice', 33, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', NULL, N'Actions', N's05', N'xl_actions_order_create', N'PROCEDURE', NULL, N'_reload', 11, 0);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', NULL, N'Actions', N's05', N'xl_actions_order_copy', N'PROCEDURE', NULL, N'_reload', 12, 0);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', NULL, N'Actions', N's05', N'MenuSeparator30', N'MENUSEPARATOR', NULL, NULL, 30, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', NULL, N'Actions', N's05', N'xl_actions_order_print', N'PROCEDURE', NULL, NULL, 31, 0);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', NULL, N'Actions', N's05', N'Create Quote & Invoice PDF', N'PDF', NULL, N'quote,invoice', 32, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', NULL, N'Actions', N's05', N'Create Quote & Invoice XSLX', N'REPORT', NULL, N'quote,invoice', 33, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_header', NULL, N'Actions', N's05', N'xl_actions_order_create', N'PROCEDURE', NULL, N'_reload', 11, 0);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_header', NULL, N'Actions', N's05', N'xl_actions_order_copy', N'PROCEDURE', NULL, N'_reload', 12, 0);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_header', NULL, N'Actions', N's05', N'MenuSeparator30', N'MENUSEPARATOR', NULL, NULL, 30, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_header', NULL, N'Actions', N's05', N'xl_actions_order_print', N'PROCEDURE', NULL, NULL, 31, 0);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_header', NULL, N'Actions', N's05', N'Create Quote & Invoice PDF', N'PDF', NULL, N'quote,invoice', 32, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_header', NULL, N'Actions', N's05', N'Create Quote & Invoice XSLX', N'REPORT', NULL, N'quote,invoice', 33, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_print_details', NULL, N'Actions', N's05', N'Create Quote & Invoice PDF', N'PDF', NULL, N'quote,invoice', 32, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_print_details', NULL, N'Actions', N's05', N'Create Quote & Invoice XSLX', N'REPORT', NULL, N'quote,invoice', 33, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_quote_print_details', NULL, N'Actions', N's05', N'Create Quote PDF', N'PDF', NULL, NULL, 22, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_quote_print_details', NULL, N'Actions', N's05', N'Create Quote XLSX', N'REPORT', NULL, NULL, 23, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_quote_print_details', NULL, N'Actions', N's05', N'MenuSeparator30', N'MENUSEPARATOR', NULL, NULL, 30, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_quote_print_details', NULL, N'Actions', N's05', N'Create Quote & Invoice PDF', N'PDF', NULL, N'quote,invoice', 32, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_quote_print_details', NULL, N'Actions', N's05', N'Create Quote & Invoice XSLX', N'REPORT', NULL, N'quote,invoice', 33, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', NULL, N'Change', N's05', N'xl_change_order_details', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_header', NULL, N'Change', N's05', N'xl_change_order_header', N'PROCEDURE', NULL, N'_reload', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_products', NULL, N'Change', N's05', N'xl_change_products', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'customers', NULL, N'ContextMenu', N's05', N'Search in Google', N'HTTP', N'https://www.google.com/search?as_q={company}', NULL, 21, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'products', NULL, N'ContextMenu', N's05', N'Search in Google', N'HTTP', N'https://www.google.com/search?as_q={product_name}', NULL, 21, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_products', NULL, N'ContextMenu', N's05', N'xl_actions_product_insert', N'PROCEDURE', NULL, N'_reload', 11, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_products', NULL, N'ContextMenu', N's05', N'xl_actions_product_delete', N'PROCEDURE', NULL, N'_reload', 12, 1);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_products', NULL, N'ContextMenu', N's05', N'MenuSeparator20', N'MENUSEPARATOR', NULL, NULL, 20, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_products', NULL, N'ContextMenu', N's05', N'Search in Google', N'HTTP', N'https://www.google.com/search?as_q={product_name}', NULL, 21, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', NULL, N'DefaultListObject', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', N'id', N'DoNotChange', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', N'level', N'DoNotChange', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', N'product_name', N'DoNotChange', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', N'sales_tax', N'DoNotChange', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', N'sku', N'DoNotChange', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', N'subtotal', N'DoNotChange', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', N'total', N'DoNotChange', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_header', NULL, N'DoNotSave', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_invoice_print_details', N'order_id', N'ParameterValues', N's05', N'xl_select_order_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', N'brand_id', N'ParameterValues', N's05', N'xl_select_brand_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', N'category_id', N'ParameterValues', N's05', N'xl_select_category_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', N'order_id', N'ParameterValues', N's05', N'xl_select_order_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', N'subcategory_id', N'ParameterValues', N's05', N'xl_select_subcategory_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_header', N'order_id', N'ParameterValues', N's05', N'xl_select_order_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_print_details', N'order_id', N'ParameterValues', N's05', N'xl_select_order_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_products', N'brand_id', N'ParameterValues', N's05', N'xl_select_brand_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_products', N'category_id', N'ParameterValues', N's05', N'xl_select_category_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_products', N'pricing_category_id', N'ParameterValues', N's05', N'pricing_categories', N'TABLE', N'id, pricing_category', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_products', N'subcategory_id', N'ParameterValues', N's05', N'xl_select_subcategory_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_quote_print_details', N'order_id', N'ParameterValues', N's05', N'xl_select_order_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'xl_actions_product_insert', N'brand_id', N'ParameterValues', N's05', N'xl_select_brand_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'xl_actions_product_insert', N'category_id', N'ParameterValues', N's05', N'xl_select_category_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'xl_actions_product_insert', N'subcategory_id', N'ParameterValues', N's05', N'xl_select_subcategory_id', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_invoice_print_details', NULL, N'ProtectRows', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', NULL, N'ProtectRows', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_header', NULL, N'ProtectRows', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_print_details', NULL, N'ProtectRows', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_products', NULL, N'ProtectRows', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_quote_print_details', NULL, N'ProtectRows', NULL, NULL, N'ATTRIBUTE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'customers', NULL, N'SelectionChange', N's05', N'xl_select_customer_orders', N'PROCEDURE', NULL, N'_taskpane', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'view_orders', NULL, N'SelectionChange', N's05', N'xl_select_order_details', N'PROCEDURE', NULL, N'_taskpane', NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_details', N'order_id', N'SyncParameter', N's05', N'usp_order_header', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'usp_order_header', N'order_id', N'SyncParameter', N's05', N'usp_order_details', N'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'product_categories', N'parent_id', N'ValidationList', N's05', N'product_categories', N'TABLE', N'id, category', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'view_orders', N'customer_id', N'ValidationList', N's05', N'customers', N'TABLE', N'id, customer', NULL, NULL, NULL);
INSERT INTO xls.handlers (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES (N's05', N'view_orders', N'seller_id', N'ValidationList', N's05', N'sellers', N'TABLE', N'id, code', NULL, NULL, NULL);
GO

INSERT INTO xls.objects (TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE, TABLE_CODE, INSERT_OBJECT, UPDATE_OBJECT, DELETE_OBJECT) VALUES (N's05', N'view_orders', N'VIEW', NULL, N's05.orders', N's05.orders', N's05.orders');
GO

INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'brands', N'brand', N'en', N'Brand', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'brands', N'id', N'en', N'ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'Create Invoice PDF', NULL, N'en', N'Create Invoice PDF', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'Create Invoice XLSX', NULL, N'en', N'Create Invoice XLSX', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'Create Quote & Invoice PDF', NULL, N'en', N'Create Quote & Invoice PDF', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'Create Quote & Invoice XSLX', NULL, N'en', N'Create Quote & Invoice XSLX', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'Create Quote PDF', NULL, N'en', N'Create Quote PDF', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'Create Quote XLSX', NULL, N'en', N'Create Quote XLSX', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'customers', N'address', N'en', N'Address', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'customers', N'company', N'en', N'Company', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'customers', N'contact', N'en', N'Contact', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'customers', N'customer', N'en', N'Customer', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'customers', N'email', N'en', N'Email', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'customers', N'id', N'en', N'ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'customers', N'phone', N'en', N'Phone', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'customers', N'pricing_category_id', N'en', N'Pricing Category', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'customers', N'sales_tax', N'en', N'Sales Tax', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'pricing_categories', N'id', N'en', N'ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'pricing_categories', N'pricing_category', N'en', N'Pricing Category', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'product_categories', N'category', N'en', N'Category', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'product_categories', N'id', N'en', N'ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'product_categories', N'level', N'en', N'Level', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'product_categories', N'parent_id', N'en', N'Parent Category', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'product_categories', N'sort_order', N'en', N'Sort Order', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'Search in Google', NULL, N'en', N'Search in Google', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'sellers', N'account_holder', N'en', N'Account Holder', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'sellers', N'account_number', N'en', N'Account Number', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'sellers', N'account_string1', N'en', N'Account String1', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'sellers', N'account_string2', N'en', N'Account String2', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'sellers', N'address', N'en', N'Address', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'sellers', N'bank', N'en', N'Bank', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'sellers', N'bank_address', N'en', N'Bank Address', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'sellers', N'bank_swift', N'en', N'SWIFT', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'sellers', N'code', N'en', N'Code', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'sellers', N'company', N'en', N'Company', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'sellers', N'email', N'en', N'Email', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'sellers', N'id', N'en', N'ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'sellers', N'phone', N'en', N'Phone', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'sellers', N'prepared_by', N'en', N'Prepared By', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'sellers', N'salesperson', N'en', N'Salesperson', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'sellers', N'slogan', N'en', N'Slogan', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_invoice_print_details', N'order_id', N'en', N'Order', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_details', N'amount', N'en', N'Amount', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_details', N'brand_id', N'en', N'Brand', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_details', N'category_id', N'en', N'Category', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_details', N'order_id', N'en', N'Order', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_details', N'product_name', N'en', N'Product', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_details', N'sales_tax', N'en', N'Sales Tax', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_details', N'show_all', N'en', N'Show All', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_details', N'sku', N'en', N'SKU', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_details', N'subcategory_id', N'en', N'Subcategory', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_details', N'subtotal', N'en', N'Subtotal', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_details', N'total', N'en', N'Total', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_details', N'unit_price', N'en', N'Unit Price', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_header', N'customer_id', N'en', N'Customer', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_header', N'delivery_date', N'en', N'Delivery Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_header', N'due_date', N'en', N'Due Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_header', N'expiration_date', N'en', N'Expires', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_header', N'id', N'en', N'ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_header', N'order_date', N'en', N'Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_header', N'order_id', N'en', N'Order', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_header', N'order_number', N'en', N'Number', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_header', N'sales_tax', N'en', N'Sales Tax', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_header', N'seller_id', N'en', N'Seller', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_order_print_details', N'order_id', N'en', N'Order', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_products', N'brand_id', N'en', N'Brand', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_products', N'category_id', N'en', N'Category', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_products', N'id', N'en', N'ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_products', N'level', N'en', N'Level', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_products', N'pricing_category_id', N'en', N'Pricing Category', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_products', N'product_name', N'en', N'Product Name', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_products', N'sku', N'en', N'SKU', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_products', N'subcategory_id', N'en', N'Subcategory', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_products', N'unit_price', N'en', N'Unit Price', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'usp_quote_print_details', N'order_id', N'en', N'Order', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'amount', N'en', N'Amount', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'brand', N'en', N'Brand', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'category', N'en', N'Category', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'customer', N'en', N'Customer', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'delivery_date', N'en', N'Delivery Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'discount', N'en', N'Discount', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'due_date', N'en', N'Due Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'expiration_date', N'en', N'Expiration Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'id', N'en', N'ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'order_date', N'en', N'Order Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'order_id', N'en', N'Order ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'order_month', N'en', N'Order Month', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'order_number', N'en', N'Order Number', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'product_name', N'en', N'Product Name', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'seller', N'en', N'Seller', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'sku', N'en', N'SKU', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'total', N'en', N'Total', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_order_details', N'unit_price', N'en', N'Unit Price', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_orders', N'amount', N'en', N'Amount', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_orders', N'customer_id', N'en', N'Customer', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_orders', N'delivery_date', N'en', N'Delivery Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_orders', N'discount', N'en', N'Discount', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_orders', N'due_date', N'en', N'Due Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_orders', N'expiration_date', N'en', N'Expiration Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_orders', N'id', N'en', N'ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_orders', N'items', N'en', N'Items', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_orders', N'order_date', N'en', N'Order Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_orders', N'order_month', N'en', N'Order Month', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_orders', N'order_number', N'en', N'Order Number', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_orders', N'sales_tax', N'en', N'Sales Tax', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_orders', N'seller_id', N'en', N'Seller', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_orders', N'subtotal', N'en', N'Subtotal', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'view_orders', N'total', N'en', N'Total', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_actions_order_copy', NULL, N'en', N'Copy Order', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_actions_order_create', NULL, N'en', N'Create Order', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_actions_order_print', NULL, N'en', N'Print Order', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_actions_product_delete', NULL, N'en', N'Delete Product', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_actions_product_insert', NULL, N'en', N'Create Product', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_actions_update_product_categories', NULL, N'en', N'Update Product Categories', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_customer_orders', NULL, N'en', N'Customer Orders', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_customer_orders', N'amount', N'en', N'Amount', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_customer_orders', N'delivery_date', N'en', N'Delivery Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_customer_orders', N'discount', N'en', N'Discount', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_customer_orders', N'due_date', N'en', N'Due Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_customer_orders', N'expiration_date', N'en', N'Expiration Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_customer_orders', N'id', N'en', N'ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_customer_orders', N'items', N'en', N'Items', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_customer_orders', N'order_date', N'en', N'Order Date', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_customer_orders', N'order_number', N'en', N'Order Number', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_customer_orders', N'sales_tax', N'en', N'Sales Tax', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_customer_orders', N'seller', N'en', N'Seller', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_customer_orders', N'subtotal', N'en', N'Subtotal', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_customer_orders', N'total', N'en', N'Total', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_order_details', NULL, N'en', N'Order Details', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_order_details', N'amount', N'en', N'Amount', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_order_details', N'id', N'en', N'ID', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_order_details', N'product_name', N'en', N'Product Name', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_order_details', N'sku', N'en', N'SKU', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_order_details', N'subtotal', N'en', N'Subtotal', NULL, NULL);
INSERT INTO xls.translations (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, LANGUAGE_NAME, TRANSLATED_NAME, TRANSLATED_DESC, TRANSLATED_COMMENT) VALUES (N's05', N'xl_select_order_details', N'unit_price', N'en', N'Unit Price', NULL, NULL);
GO

INSERT INTO xls.workbooks (NAME, TEMPLATE, DEFINITION, TABLE_SCHEMA) VALUES (N'Sample 05 - Invoices.xlsx', N'Sample 05 - Invoices.xlsx', N'order=s05.usp_order_header,(Default),False,$B$3,,{"Parameters":{"order_id":1},"ListObjectName":"order_header","WorkbookLanguage":"en"}
order=s05.usp_order_details,(Default),False,$B$7,,{"Parameters":{"category_id":null,"subcategory_id":null,"brand_id":null,"order_id":1,"show_all":1},"ListObjectName":"order_details","WorkbookLanguage":"en"}
quote=s05.usp_quote_print_details,(Default),False,$B$18,,{"Parameters":{"order_id":1},"ListObjectName":"quote_details","WorkbookLanguage":"en"}
invoice=s05.usp_invoice_print_details,(Default),False,$B$28,,{"Parameters":{"order_id":1},"ListObjectName":"invoice_details","WorkbookLanguage":"en"}
customers=s05.customers,(Default),False,$B$3,,{"Parameters":{},"ListObjectName":"customers","WorkbookLanguage":"en"}
products=s05.usp_products,(Default),False,$B$3,,{"Parameters":{"category_id":null,"subcategory_id":null,"brand_id":null,"pricing_category_id":1},"ListObjectName":"products","WorkbookLanguage":"en"}
orders=s05.view_orders,(Default),False,$B$3,,{"Parameters":{},"ListObjectName":"view_orders","WorkbookLanguage":"en"}
order_details=s05.view_order_details,(Default),False,$B$3,,{"Parameters":{},"ListObjectName":"view_order_details","WorkbookLanguage":"en"}
sellers=s05.sellers,(Default),False,$B$3,,{"Parameters":{},"ListObjectName":"sellers","WorkbookLanguage":"en"}
product_categories=s05.product_categories,(Default),False,$B$3,,{"Parameters":{},"ListObjectName":"product_categories","WorkbookLanguage":"en"}
brands=s05.brands,(Default),False,$B$3,,{"Parameters":{},"ListObjectName":"brands","WorkbookLanguage":"en"}
pricing_categories=s05.pricing_categories,(Default),False,$B$3,,{"Parameters":{},"ListObjectName":"pricing_categories","WorkbookLanguage":"en"}
objects=xls.objects,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s05"},"ListObjectName":"objects","WorkbookLanguage":"en"}
handlers=xls.handlers,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s05","EVENT_NAME":null},"ListObjectName":"handlers","WorkbookLanguage":"en"}
translations=xls.translations,(Default),False,$B$3,,{"Parameters":{"TABLE_SCHEMA":"s05","TABLE_NAME":null},"ListObjectName":"translations","WorkbookLanguage":"en"}', N's05');
GO

print 'Application installed';
