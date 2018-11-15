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
