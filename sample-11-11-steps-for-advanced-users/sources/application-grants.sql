-- =============================================
-- Application: Sample 11 - 11 Steps for Advanced Users
-- Version 10.6, December 13, 2022
--
-- Copyright 2019-2022 Sergey Vaselenko
--
-- License: MIT
-- =============================================

CREATE USER sample11_Alex FOR LOGIN sample11_Alex WITH DEFAULT_SCHEMA=s11;
GO

CREATE USER sample11_Lora FOR LOGIN sample11_Lora WITH DEFAULT_SCHEMA=s11;
GO

CREATE USER sample11_Nick FOR LOGIN sample11_Nick WITH DEFAULT_SCHEMA=s11;
GO


IF DATABASE_PRINCIPAL_ID('sample11_Alex_Team') IS NOT NULL
    EXEC sp_addrolemember N'sample11_Alex_Team', N'sample11_Lora';

IF DATABASE_PRINCIPAL_ID('sample11_Alex_Team') IS NOT NULL
    EXEC sp_addrolemember N'sample11_Alex_Team', N'sample11_Nick';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION ON SCHEMA::s11   TO sample11_Alex_Team;

GRANT CONTROL ON ROLE::sample11_Alex_Team     TO sample11_Alex;

GRANT CONTROL ON USER::sample11_Lora          TO sample11_Alex;

GRANT CONTROL ON USER::sample11_Nick          TO sample11_Alex;

GRANT CONTROL ON SCHEMA::s11   TO sample11_Alex;

