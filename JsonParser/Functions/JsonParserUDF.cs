using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.IO;
using Microsoft.SqlServer.Server;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class UserDefinedFunctions
{
    static int count = 0;

    [Microsoft.SqlServer.Server.SqlFunction]
    public static SqlString JsonValue(SqlString json, SqlString path)
    {
        JObject ja = (JObject)JsonConvert.DeserializeObject(json.Value);
        JToken token = ja.SelectToken(path.Value);
        
        return token.ToString();
    }

    [Microsoft.SqlServer.Server.SqlFunction]
    public static SqlString JsonArrayValue(SqlString json, SqlInt32 rowindex, SqlString key)
    {
        JArray ja = (JArray)JsonConvert.DeserializeObject(json.Value);
        string re = ja[rowindex.Value][key.Value].ToString();
        return new SqlString(re);
    }

    public static void FillRowFromJson(Object token, out SqlString path, out SqlString value, out SqlString type, out SqlBoolean hasvalues, out SqlInt32 index)
    {
        JToken item = (JToken)token;
        path = item.Path;
        type = item.Type.ToString();
        hasvalues = item.HasValues;
        value = item.ToString();
        index = count;
        count++;
    }

    [SqlFunction(FillRowMethodName = "FillRowFromJson", TableDefinition = "[path] nvarchar(4000), [value] nvarchar(max), [type] nvarchar(4000), hasvalues bit, [index] int")]
    public static IEnumerable JsonTable(SqlString json, SqlString path)
    {
        ArrayList TokenCollection = new ArrayList();
        count = 0;

        JObject ja = (JObject)JsonConvert.DeserializeObject(json.Value);
        IEnumerable<JToken> tokens = ja.SelectTokens(path.Value);

        foreach (JToken token in tokens)
        {
            if (token.Type == JTokenType.Object || token.Type == JTokenType.Array)
            {
                foreach (JToken item in token.Children<JToken>())
                {
                    TokenCollection.Add(item);
                }
            } else
            {
                TokenCollection.Add(token);
            }
        }

        return TokenCollection;
    }

}
