USE master;
GO

CREATE LOGIN sample02_user1 WITH PASSWORD=N'Usr_2011#_Xls4168';
GO

CREATE LOGIN sample02_user2 WITH PASSWORD=N'Usr_2011#_Xls4168';
GO

CREATE LOGIN sample02_user3 WITH PASSWORD=N'Usr_2011#_Xls4168';
GO

CREATE LOGIN sample02_user5 WITH PASSWORD=N'Usr_2011#_Xls4168';
GO

CREATE LOGIN sample02_user6 WITH PASSWORD=N'Usr_2011#_Xls4168';
GO


CREATE USER sample02_user1 FOR LOGIN sample02_user1 WITH DEFAULT_SCHEMA=dbo;
GO

CREATE USER sample02_user2 FOR LOGIN sample02_user2 WITH DEFAULT_SCHEMA=dbo;
GO

CREATE USER sample02_user3 FOR LOGIN sample02_user3 WITH DEFAULT_SCHEMA=dbo;
GO

CREATE USER sample02_user5 FOR LOGIN sample02_user5 WITH DEFAULT_SCHEMA=dbo;
GO

CREATE USER sample02_user6 FOR LOGIN sample02_user6 WITH DEFAULT_SCHEMA=dbo;
GO

