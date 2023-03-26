-- =============================================
-- Application: Sample 13 - Tests
-- Version 10.8, January 9, 2023
--
-- Copyright 2019-2023 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER sample13_user1 FOR LOGIN sample13_user1 WITH DEFAULT_SCHEMA=s13;
GO


GRANT SELECT, INSERT, UPDATE, DELETE, VIEW DEFINITION ON s13.datatypes               TO sample13_user1;

GRANT SELECT, INSERT, UPDATE, DELETE, VIEW DEFINITION ON s13.quotes                  TO sample13_user1;

GRANT SELECT, VIEW DEFINITION ON s13.view_datatype_columns   TO sample13_user1;

GRANT SELECT, VIEW DEFINITION ON s13.view_datatype_parameters TO sample13_user1;

GRANT EXECUTE, VIEW DEFINITION ON s13.usp_datatypes           TO sample13_user1;

GRANT EXECUTE, VIEW DEFINITION ON s13.usp_datatypes_delete    TO sample13_user1;

GRANT EXECUTE, VIEW DEFINITION ON s13.usp_datatypes_insert    TO sample13_user1;

GRANT EXECUTE, VIEW DEFINITION ON s13.usp_datatypes_update    TO sample13_user1;

GRANT EXECUTE, VIEW DEFINITION ON s13.usp_odbc_datatypes      TO sample13_user1;

GRANT EXECUTE, VIEW DEFINITION ON s13.usp_odbc_datatypes_delete TO sample13_user1;

GRANT EXECUTE, VIEW DEFINITION ON s13.usp_odbc_datatypes_insert TO sample13_user1;

GRANT EXECUTE, VIEW DEFINITION ON s13.usp_odbc_datatypes_update TO sample13_user1;

GRANT EXECUTE ON s13.usp_parameters_test     TO sample13_user1;

GRANT EXECUTE, VIEW DEFINITION ON s13.usp_quotes              TO sample13_user1;

GRANT EXECUTE, VIEW DEFINITION ON s13.usp_quotes_delete       TO sample13_user1;

GRANT EXECUTE, VIEW DEFINITION ON s13.usp_quotes_insert       TO sample13_user1;

GRANT EXECUTE, VIEW DEFINITION ON s13.usp_quotes_update       TO sample13_user1;

GRANT EXECUTE ON s13.usp_select_test_editable_rows TO sample13_user1;

GRANT EXECUTE ON s13.usp_select_test_editable_rows_delete TO sample13_user1;

GRANT EXECUTE ON s13.usp_select_test_editable_rows_insert TO sample13_user1;

GRANT EXECUTE ON s13.usp_select_test_editable_rows_update TO sample13_user1;

GRANT EXECUTE ON s13.usp_select_test_rows    TO sample13_user1;

