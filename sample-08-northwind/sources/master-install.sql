USE master;
GO

CREATE LOGIN sample08_user1 WITH PASSWORD=N'Usr_2011#_Xls4168';
GO


CREATE USER sample08_user1 FOR LOGIN sample08_user1 WITH DEFAULT_SCHEMA=dbo;
GO

