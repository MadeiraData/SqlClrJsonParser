/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
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
