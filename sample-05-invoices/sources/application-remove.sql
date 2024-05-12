-- =============================================
-- Application: Sample 05 - Invoices
-- Version 10.13, April 29, 2024
--
-- Copyright 2018-2024 Gartle LLC
--
-- License: MIT
-- =============================================

SET NOCOUNT ON;
GO

DECLARE @sql nvarchar(max) = ''

SELECT
    @sql = @sql + 'ALTER ROLE ' + QUOTENAME(r.name) + ' DROP MEMBER ' + QUOTENAME(m.name) + ';' + CHAR(13) + CHAR(10)
FROM
    sys.database_role_members rm
    INNER JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
    INNER JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE
    r.name IN ('xls_admins', 'xls_developers', 'xls_formats', 'xls_users')
    AND m.name LIKE 'sample05_user%'

IF LEN(@sql) > 1
    BEGIN
    EXEC (@sql);
    PRINT @sql
    END
GO

DELETE FROM [xls].[formats]                        WHERE TABLE_SCHEMA IN (N's05');
DELETE FROM [xls].[handlers]                       WHERE TABLE_SCHEMA IN (N's05');
DELETE FROM [xls].[objects]                        WHERE TABLE_SCHEMA IN (N's05');
DELETE FROM [xls].[translations]                   WHERE TABLE_SCHEMA IN (N's05');
DELETE FROM [xls].[workbooks]                      WHERE TABLE_SCHEMA IN (N's05');
GO

DECLARE @id int

SET @id = COALESCE((SELECT MAX(ID) FROM xls.formats), 0);

DBCC CHECKIDENT ('xls.formats', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM xls.handlers), 0);

DBCC CHECKIDENT ('xls.handlers', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM xls.objects), 0);

DBCC CHECKIDENT ('xls.objects', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM xls.translations), 0);

DBCC CHECKIDENT ('xls.translations', RESEED, @id) WITH NO_INFOMSGS;

SET @id = COALESCE((SELECT MAX(ID) FROM xls.workbooks), 0);

DBCC CHECKIDENT ('xls.workbooks', RESEED, @id) WITH NO_INFOMSGS;
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s05].[FK_customers_pricing_categories]') AND parent_object_id = OBJECT_ID(N'[s05].[customers]'))
    ALTER TABLE [s05].[customers] DROP CONSTRAINT [FK_customers_pricing_categories];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s05].[FK_order_details_orders]') AND parent_object_id = OBJECT_ID(N'[s05].[order_details]'))
    ALTER TABLE [s05].[order_details] DROP CONSTRAINT [FK_order_details_orders];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s05].[FK_order_details_products]') AND parent_object_id = OBJECT_ID(N'[s05].[order_details]'))
    ALTER TABLE [s05].[order_details] DROP CONSTRAINT [FK_order_details_products];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s05].[FK_orders_customers]') AND parent_object_id = OBJECT_ID(N'[s05].[orders]'))
    ALTER TABLE [s05].[orders] DROP CONSTRAINT [FK_orders_customers];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s05].[FK_orders_sellers]') AND parent_object_id = OBJECT_ID(N'[s05].[orders]'))
    ALTER TABLE [s05].[orders] DROP CONSTRAINT [FK_orders_sellers];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s05].[FK_product_categories_product_categories]') AND parent_object_id = OBJECT_ID(N'[s05].[product_categories]'))
    ALTER TABLE [s05].[product_categories] DROP CONSTRAINT [FK_product_categories_product_categories];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s05].[FK_prices_items]') AND parent_object_id = OBJECT_ID(N'[s05].[product_prices]'))
    ALTER TABLE [s05].[product_prices] DROP CONSTRAINT [FK_prices_items];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s05].[FK_product_prices_pricing_categories]') AND parent_object_id = OBJECT_ID(N'[s05].[product_prices]'))
    ALTER TABLE [s05].[product_prices] DROP CONSTRAINT [FK_product_prices_pricing_categories];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s05].[FK_products_brands]') AND parent_object_id = OBJECT_ID(N'[s05].[products]'))
    ALTER TABLE [s05].[products] DROP CONSTRAINT [FK_products_brands];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s05].[FK_products_product_categories]') AND parent_object_id = OBJECT_ID(N'[s05].[products]'))
    ALTER TABLE [s05].[products] DROP CONSTRAINT [FK_products_product_categories];
GO

IF OBJECT_ID('[s05].[usp_invoice_print_details]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[usp_invoice_print_details];
GO
IF OBJECT_ID('[s05].[usp_order_details]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[usp_order_details];
GO
IF OBJECT_ID('[s05].[usp_order_header]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[usp_order_header];
GO
IF OBJECT_ID('[s05].[usp_order_print_details]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[usp_order_print_details];
GO
IF OBJECT_ID('[s05].[usp_products]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[usp_products];
GO
IF OBJECT_ID('[s05].[usp_quote_print_details]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[usp_quote_print_details];
GO
IF OBJECT_ID('[s05].[xl_actions_order_clear]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[xl_actions_order_clear];
GO
IF OBJECT_ID('[s05].[xl_actions_order_copy]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[xl_actions_order_copy];
GO
IF OBJECT_ID('[s05].[xl_actions_order_create]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[xl_actions_order_create];
GO
IF OBJECT_ID('[s05].[xl_actions_order_print]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[xl_actions_order_print];
GO
IF OBJECT_ID('[s05].[xl_actions_product_delete]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[xl_actions_product_delete];
GO
IF OBJECT_ID('[s05].[xl_actions_product_insert]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[xl_actions_product_insert];
GO
IF OBJECT_ID('[s05].[xl_actions_update_product_categories]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[xl_actions_update_product_categories];
GO
IF OBJECT_ID('[s05].[xl_change_order_details]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[xl_change_order_details];
GO
IF OBJECT_ID('[s05].[xl_change_order_header]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[xl_change_order_header];
GO
IF OBJECT_ID('[s05].[xl_change_products]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[xl_change_products];
GO
IF OBJECT_ID('[s05].[xl_select_brand_id]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[xl_select_brand_id];
GO
IF OBJECT_ID('[s05].[xl_select_category_id]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[xl_select_category_id];
GO
IF OBJECT_ID('[s05].[xl_select_customer_orders]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[xl_select_customer_orders];
GO
IF OBJECT_ID('[s05].[xl_select_order_details]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[xl_select_order_details];
GO
IF OBJECT_ID('[s05].[xl_select_order_id]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[xl_select_order_id];
GO
IF OBJECT_ID('[s05].[xl_select_subcategory_id]', 'P') IS NOT NULL
DROP PROCEDURE [s05].[xl_select_subcategory_id];
GO

IF OBJECT_ID('[s05].[view_order_details]', 'V') IS NOT NULL
DROP VIEW [s05].[view_order_details];
GO
IF OBJECT_ID('[s05].[view_orders]', 'V') IS NOT NULL
DROP VIEW [s05].[view_orders];
GO

IF OBJECT_ID('[s05].[get_new_order_number]', 'FN') IS NOT NULL
DROP FUNCTION [s05].[get_new_order_number];
GO

IF OBJECT_ID('[s05].[brands]', 'U') IS NOT NULL
DROP TABLE [s05].[brands];
GO
IF OBJECT_ID('[s05].[customers]', 'U') IS NOT NULL
DROP TABLE [s05].[customers];
GO
IF OBJECT_ID('[s05].[forms]', 'U') IS NOT NULL
DROP TABLE [s05].[forms];
GO
IF OBJECT_ID('[s05].[order_details]', 'U') IS NOT NULL
DROP TABLE [s05].[order_details];
GO
IF OBJECT_ID('[s05].[orders]', 'U') IS NOT NULL
DROP TABLE [s05].[orders];
GO
IF OBJECT_ID('[s05].[pricing_categories]', 'U') IS NOT NULL
DROP TABLE [s05].[pricing_categories];
GO
IF OBJECT_ID('[s05].[product_categories]', 'U') IS NOT NULL
DROP TABLE [s05].[product_categories];
GO
IF OBJECT_ID('[s05].[product_prices]', 'U') IS NOT NULL
DROP TABLE [s05].[product_prices];
GO
IF OBJECT_ID('[s05].[products]', 'U') IS NOT NULL
DROP TABLE [s05].[products];
GO
IF OBJECT_ID('[s05].[sellers]', 'U') IS NOT NULL
DROP TABLE [s05].[sellers];
GO

IF SCHEMA_ID('s05') IS NOT NULL
DROP SCHEMA [s05];
GO


IF DATABASE_PRINCIPAL_ID('sample05_user1') IS NOT NULL
DROP USER [sample05_user1];
GO

print 'Application removed';
