USE master;
GO

CREATE LOGIN sample21_user1 WITH PASSWORD=N'Usr_2011#_Xls4168';
GO

CREATE LOGIN sample21_user2 WITH PASSWORD=N'Usr_2011#_Xls4168';
GO


CREATE USER sample21_user1 FOR LOGIN sample21_user1 WITH DEFAULT_SCHEMA=dbo;
GO

CREATE USER sample21_user2 FOR LOGIN sample21_user2 WITH DEFAULT_SCHEMA=dbo;
GO
