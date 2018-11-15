# SqlClrJsonParser

A SQL Server CLR wrapper written in C#, for parsing Json documents within SQL Server versions pre-2016 (before the introduction of OPENJSON and JSON_VALUE functions and such).

# Pre-requisites

Most of the pre-requisites are automatically handled by the Pre-Deployment script:

```
exec sp_configure 'clr enabled', 1
reconfigure
GO
DECLARE @cmd NVARCHAR(MAX)
SELECT @cmd = N'ALTER AUTHORIZATION ON DATABASE::' + QUOTENAME(DB_NAME()) + N' TO ' + QUOTENAME(sp.name)
FROM sys.databases AS db
INNER JOIN sys.server_principals AS sp
ON db.owner_sid = sp.sid
WHERE db.database_id = 1
GO
IF NOT EXISTS (SELECT * FROM sys.assemblies WHERE name = 'System_Runtime_Serialization')
	CREATE ASSEMBLY System_Runtime_Serialization FROM 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.Serialization.dll'
	WITH PERMISSION_SET = UNSAFE
GO
IF NOT EXISTS (SELECT * FROM sys.assemblies WHERE name = 'Newtonsoft.Json')
	CREATE ASSEMBLY [Newtonsoft.Json]
	FROM '$(PathToNewtonsoftJsonDLL)'
	WITH PERMISSION_SET = UNSAFE
GO
```

These requirements are:

- 'clr enabled' instance option must be turned on
- Target Database must have the same owner as that of the "master" database (usually it's "sa").
- Target Database must have the TRUSTWORTHY ON setting (already configured in the project settings).
- The System.Runtime.Serialization assembly must be imported into the database.
- The Newtonsoft.Json DLL file must be imported into the database (it's already included with the project, you just need to specify the SQLCMD parameter that defines its file path location).

# Example Usage

Here is an example usage of this assembly within T-SQL:

```
DECLARE
	@Json NVARCHAR(MAX) = '{ "result": { "tickets": [ { "id": "123", "name": "hi there" }, { "id": "456", "name": "hello there" } ], "count": "2" } }'

SELECT *
, dbo.JsonValue([value], '$.id') AS [id]
, dbo.JsonValue([value], '$.name') AS [name]
FROM dbo.JsonTable(@Json, '$.result.tickets')

/* Equivalent of:
SELECT *
, JSON_VALUE([value], '$.id') AS [id]
, JSON_VALUE([value], '$.name') AS [name]
FROM OPENJSON (@Json, '$.result.tickets')
*/
```
