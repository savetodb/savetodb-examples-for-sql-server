USE master;
GO

CREATE LOGIN sample14_user1 WITH PASSWORD=N'Usr_2011#_Xls4168';
GO

CREATE LOGIN sample14_user2 WITH PASSWORD=N'Usr_2011#_Xls4168';
GO

CREATE LOGIN sample14_user3 WITH PASSWORD=N'Usr_2011#_Xls4168';
GO


CREATE USER sample14_user1 FOR LOGIN sample14_user1 WITH DEFAULT_SCHEMA=dbo;
GO

CREATE USER sample14_user2 FOR LOGIN sample14_user2 WITH DEFAULT_SCHEMA=dbo;
GO

CREATE USER sample14_user3 FOR LOGIN sample14_user3 WITH DEFAULT_SCHEMA=dbo;
GO
