-- =============================================
-- Application: Sample 04 - Orders
-- Version 10.13, April 29, 2024
--
-- Copyright 2014-2024 Gartle LLC
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
    AND m.name LIKE 'sample04_user%'

IF LEN(@sql) > 1
    BEGIN
    EXEC (@sql);
    PRINT @sql
    END
GO

DELETE FROM [xls].[formats]                        WHERE TABLE_SCHEMA IN (N's04');
DELETE FROM [xls].[handlers]                       WHERE TABLE_SCHEMA IN (N's04');
DELETE FROM [xls].[objects]                        WHERE TABLE_SCHEMA IN (N's04');
DELETE FROM [xls].[translations]                   WHERE TABLE_SCHEMA IN (N's04');
DELETE FROM [xls].[workbooks]                      WHERE TABLE_SCHEMA IN (N's04');
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

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s04].[FK_items_brands]') AND parent_object_id = OBJECT_ID(N'[s04].[items]'))
    ALTER TABLE [s04].[items] DROP CONSTRAINT [FK_items_brands];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s04].[FK_order_details_items]') AND parent_object_id = OBJECT_ID(N'[s04].[order_details]'))
    ALTER TABLE [s04].[order_details] DROP CONSTRAINT [FK_order_details_items];
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[s04].[FK_prices_items]') AND parent_object_id = OBJECT_ID(N'[s04].[prices]'))
    ALTER TABLE [s04].[prices] DROP CONSTRAINT [FK_prices_items];
GO

IF OBJECT_ID('[s04].[usp_order_form]', 'P') IS NOT NULL
DROP PROCEDURE [s04].[usp_order_form];
GO
IF OBJECT_ID('[s04].[usp_order_form_change]', 'P') IS NOT NULL
DROP PROCEDURE [s04].[usp_order_form_change];
GO
IF OBJECT_ID('[s04].[xl_actions_items_clear]', 'P') IS NOT NULL
DROP PROCEDURE [s04].[xl_actions_items_clear];
GO
IF OBJECT_ID('[s04].[xl_actions_items_clear_brands]', 'P') IS NOT NULL
DROP PROCEDURE [s04].[xl_actions_items_clear_brands];
GO
IF OBJECT_ID('[s04].[xl_actions_items_delete_item]', 'P') IS NOT NULL
DROP PROCEDURE [s04].[xl_actions_items_delete_item];
GO
IF OBJECT_ID('[s04].[xl_actions_items_insert_item]', 'P') IS NOT NULL
DROP PROCEDURE [s04].[xl_actions_items_insert_item];
GO
IF OBJECT_ID('[s04].[xl_actions_items_print_as_html]', 'P') IS NOT NULL
DROP PROCEDURE [s04].[xl_actions_items_print_as_html];
GO
IF OBJECT_ID('[s04].[xl_actions_items_rename_item]', 'P') IS NOT NULL
DROP PROCEDURE [s04].[xl_actions_items_rename_item];
GO
IF OBJECT_ID('[s04].[xl_actions_items_set_brand_acer]', 'P') IS NOT NULL
DROP PROCEDURE [s04].[xl_actions_items_set_brand_acer];
GO
IF OBJECT_ID('[s04].[xl_actions_items_set_brand_asus]', 'P') IS NOT NULL
DROP PROCEDURE [s04].[xl_actions_items_set_brand_asus];
GO
IF OBJECT_ID('[s04].[xl_list_brand_id]', 'P') IS NOT NULL
DROP PROCEDURE [s04].[xl_list_brand_id];
GO
IF OBJECT_ID('[s04].[xl_list_category_id]', 'P') IS NOT NULL
DROP PROCEDURE [s04].[xl_list_category_id];
GO
IF OBJECT_ID('[s04].[xl_list_subcategory_id]', 'P') IS NOT NULL
DROP PROCEDURE [s04].[xl_list_subcategory_id];
GO

IF OBJECT_ID('[s04].[view_items]', 'V') IS NOT NULL
DROP VIEW [s04].[view_items];
GO

IF OBJECT_ID('[s04].[brands]', 'U') IS NOT NULL
DROP TABLE [s04].[brands];
GO
IF OBJECT_ID('[s04].[items]', 'U') IS NOT NULL
DROP TABLE [s04].[items];
GO
IF OBJECT_ID('[s04].[order_details]', 'U') IS NOT NULL
DROP TABLE [s04].[order_details];
GO
IF OBJECT_ID('[s04].[prices]', 'U') IS NOT NULL
DROP TABLE [s04].[prices];
GO

IF SCHEMA_ID('s04') IS NOT NULL
DROP SCHEMA [s04];
GO


IF DATABASE_PRINCIPAL_ID('sample04_user1') IS NOT NULL
DROP USER [sample04_user1];
GO
print 'Application removed';
