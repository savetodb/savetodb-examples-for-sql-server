# SaveToDB Examples for SQL Server

SaveToDB examples show various features of the applications built with SQL Server and the following client apps:

- [SaveToDB add-in for Microsoft Excel](https://www.savetodb.com/savetodb.htm)
- [DBEdit for Windows](https://www.savetodb.com/dbedit.htm)
- [DBGate for Windows and Linux](https://www.savetodb.com/dbgate.htm)
- [ODataDB for Windows and Linux](https://www.savetodb.com/odatadb.htm)

You may try the samples online with [ODataDB](https://odatadb.savetodb.com/) or [DBGate](https://dbgate.savetodb.com/).

To try examples with Excel, download the [SaveToDB SDK](https://www.savetodb.com/download.htm) which includes the source codes and workbooks.

Some samples have no configuration and show the features from the box.

Other samples have the configured features. Refer to the [Developer Guide](https://www.savetodb.com/dev-guide/getting-started.htm) for details.

Such samples use one or more frameworks:

- [SaveToDB Framework for SQL Server](https://github.com/savetodb/savetodb-framework-for-sql-server)
- [SaveToDB Framework Extension for SQL Server](https://github.com/savetodb/savetodb-framework-extension-for-sql-server)
- [SaveToDB Developer Framework for SQL Server](https://github.com/savetodb/savetodb-developer-framework-for-sql-server)
- [SaveToDB Administrator Framework for SQL Server](https://github.com/savetodb/savetodb-administrator-framework-for-sql-server)
- [Tab Framework for SQL Server](https://github.com/savetodb/tab-tramework-for-sql-server)

Examples may contain preconfigured users defined in master-install.sql and application-grants.sql files.

[passwords.txt](passwords.txt) contains logins and passwords for users of all examples.


## Manual installation, update, and uninstallation

### Installation

To install the example, execute the following files from the example folder in the following order:

1. master-install.sql
2. savetodb-framework-install.sql
3. savetodb-framework-extension-install.sql
4. savetodb-developer-framework-install.sql
5. savetodb-administrator-framework-install.sql
6. application-install.sql
7. application-grants.sql

Omit SaveToDB framework files if you already installed them with another example.

SaveToDB Framework files, except for savetodb-framework-install.sql, are optional anyway.

Some examples have a reduced file list like:

1. master-install.sql
2. savetodb-framework-install.sql
3. application-install.sql
4. application-grants.sql

or even without the SaveToDB Framework:

1. master-install.sql
2. application-install.sql
3. application-grants.sql

You may check the actual files in the install.lst file.

### Update

SaveToDB samples do not support updating. However, you may update SaveToDB frameworks separately.

### Uninstallation

To remove the example, execute the following files from the example folder in the following order:

1. application-remove.sql
2. master-remove.sql
3. savetodb-administrator-framework-remove.sql
4. savetodb-developer-framework-remove.sql
5. savetodb-framework-extension-remove.sql
6. savetodb-framework-remove.sql

Some examples have fewer files. You may check the actual files in the remove.lst file.

Remove SaveToDB frameworks with the latest uninstalled example only.


## Installation and uninstallation with DBSetup

DBSetup is a free command-line tool to automate install and uninstall operations.

It is shipped with [SaveToDB SDKs](https://www.savetodb.com/download.htm), [SaveToDB add-in](https://www.savetodb.com/savetodb.htm), and [DBEdit](https://www.savetodb.com/dbedit.htm)..

We recommend installing it with gsqlcmd, another free useful tool for database developers.

To install or uninstall the example, edit the setup connection string in the gsqlcmd.exe.config file and run `dbsetup` in Windows or `dotnet dbsetup` in Linux. Then follow command-line instructions.


## License

The SaveToDB examples are licensed under the MIT license.
