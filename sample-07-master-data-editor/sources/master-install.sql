USE master;
GO

CREATE LOGIN sample07_user1 WITH PASSWORD=N'Usr_2011#_Xls4168';
GO


CREATE USER sample07_user1 FOR LOGIN sample07_user1 WITH DEFAULT_SCHEMA=dbo;
GO

