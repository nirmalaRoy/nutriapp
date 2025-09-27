<cfcomponent displayname="MySQL Data Service" output="false">

    <cffunction name="init" returntype="MySQLDataService" access="public" output="false">
        <cfset variables.datasource = "nutriapp">
        
        <!--- Test database connection --->
        <cftry>
            <cfquery name="testConnection" datasource="#variables.datasource#">
                SELECT test_message FROM db_test LIMIT 1
            </cfquery>
            <cflog file="data" text="MySQL DataService initialized successfully" type="information">
            
            <cfcatch type="any">
                <cflog file="data" text="MySQL connection failed: #cfcatch.message#" type="error">
                <cfthrow type="DatabaseConnectionError" message="Failed to connect to MySQL database: #cfcatch.message#">
            </cfcatch>
        </cftry>
        
        <cfreturn this>
    </cffunction>
    
    <cffunction name="executeQuery" returntype="any" access="public" output="false">
        <cfargument name="collection" type="string" required="true">
        <cfargument name="operation" type="string" required="true">
        <cfargument name="query" type="struct" required="false" default="#{}#">
        <cfargument name="data" type="struct" required="false" default="#{}#">
        <cfargument name="options" type="struct" required="false" default="#{}#">
        
        <cfset var result = {}>
        
        <cftry>
            <cfswitch expression="#arguments.operation#">
                <cfcase value="find">
                    <cfset result = findDocuments(arguments.collection, arguments.query, arguments.options)>
                </cfcase>
                <cfcase value="findOne">
                    <cfset result = findOneDocument(arguments.collection, arguments.query)>
                </cfcase>
                <cfcase value="insert">
                    <cfset result = insertDocument(arguments.collection, arguments.data)>
                </cfcase>
                <cfcase value="update">
                    <cfset result = updateDocument(arguments.collection, arguments.query, arguments.data, arguments.options)>
                </cfcase>
                <cfcase value="delete">
                    <cfset result = deleteDocument(arguments.collection, arguments.query)>
                </cfcase>
                <cfdefaultcase>
                    <cfthrow type="InvalidOperation" message="Unsupported operation: #arguments.operation#">
                </cfdefaultcase>
            </cfswitch>
            
            <cfreturn result>
            
            <cfcatch type="any">
                <cflog file="data" text="MySQL operation error: #cfcatch.message#" type="error">
                <cfset result = {
                    "success": false,
                    "error": cfcatch.message
                }>
                <cfreturn result>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <!--- Find Documents --->
    <cffunction name="findDocuments" returntype="struct" access="private" output="false">
        <cfargument name="collection" type="string" required="true">
        <cfargument name="query" type="struct" required="true">
        <cfargument name="options" type="struct" required="false" default="#{}#">
        
        <cftry>
            <cfset var tableName = getTableName(arguments.collection)>
            <cfset var limit = structKeyExists(arguments.options, "limit") ? arguments.options.limit : 0>
            <cfset var skip = structKeyExists(arguments.options, "skip") ? arguments.options.skip : 0>
            
            <!--- Handle common query patterns directly --->
            <cfif structCount(arguments.query) EQ 1 AND structKeyExists(arguments.query, "email")>
                <cfquery name="queryResult" datasource="#variables.datasource#">
                    SELECT * FROM #tableName# 
                    WHERE email = <cfqueryparam value="#arguments.query.email#" cfsqltype="CF_SQL_VARCHAR">
                    ORDER BY created_at DESC
                    <cfif limit GT 0>LIMIT #limit#</cfif>
                </cfquery>
            <cfelseif structCount(arguments.query) EQ 1 AND structKeyExists(arguments.query, "_id")>
                <cfquery name="queryResult" datasource="#variables.datasource#">
                    SELECT * FROM #tableName# 
                    WHERE id = <cfqueryparam value="#arguments.query._id#" cfsqltype="CF_SQL_VARCHAR">
                    ORDER BY created_at DESC
                    <cfif limit GT 0>LIMIT #limit#</cfif>
                </cfquery>
            <cfelseif structCount(arguments.query) EQ 1 AND (structKeyExists(arguments.query, "session_id") OR structKeyExists(arguments.query, "sessionId"))>
                <cfset var sessionIdValue = structKeyExists(arguments.query, "sessionId") ? arguments.query.sessionId : arguments.query.session_id>
                <cfquery name="queryResult" datasource="#variables.datasource#">
                    SELECT * FROM #tableName# 
                    WHERE session_id = <cfqueryparam value="#sessionIdValue#" cfsqltype="CF_SQL_VARCHAR">
                    ORDER BY created_at DESC
                    <cfif limit GT 0>LIMIT #limit#</cfif>
                </cfquery>
            <cfelse>
                <!--- For complex queries, return empty result for now --->
                <cfset var emptyQuery = queryNew("id", "varchar", [])>
                <cfset queryResult = emptyQuery>
            </cfif>
            
            <!--- Convert query to array of structs --->
            <cfset var data = []>
            <cfloop query="queryResult">
                <cfset var row = {}>
                <cfloop list="#queryResult.columnList#" index="col">
                    <cfset var value = queryResult[col][queryResult.currentRow]>
                    <!--- Handle JSON columns --->
                    <cfif listFindNoCase("preferences,ingredients,nutrition_facts", col)>
                        <cftry>
                            <cfif isJSON(value)>
                                <cfset row[col] = deserializeJSON(value)>
                            <cfelse>
                                <cfset row[col] = {}>
                            </cfif>
                            <cfcatch>
                                <cfset row[col] = {}>
                            </cfcatch>
                        </cftry>
                    <cfelse>
                        <!--- Map database columns to expected field names --->
                        <cfset var fieldName = col>
                        <cfif col EQ "id">
                            <cfset fieldName = "_id">
                        <cfelseif col EQ "nutrition_facts">
                            <cfset fieldName = "nutritionFacts">
                        <cfelseif col EQ "created_at">
                            <cfset fieldName = "createdAt">
                        <cfelseif col EQ "updated_at">
                            <cfset fieldName = "updatedAt">
                        <cfelseif col EQ "created_by">
                            <cfset fieldName = "createdBy">
                        <cfelseif col EQ "updated_by">
                            <cfset fieldName = "updatedBy">
                        </cfif>
                        <cfset row[fieldName] = value>
                    </cfif>
                </cfloop>
                <cfset arrayAppend(data, row)>
            </cfloop>
            
            <cfreturn {
                "success": true,
                "data": data,
                "count": arrayLen(data)
            }>
            
            <cfcatch type="any">
                <cflog file="data" text="Find documents error: #cfcatch.message# - SQL: #sql#" type="error">
                <cfreturn {
                    "success": false,
                    "error": cfcatch.message
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <!--- Find One Document --->
    <cffunction name="findOneDocument" returntype="struct" access="private" output="false">
        <cfargument name="collection" type="string" required="true">
        <cfargument name="query" type="struct" required="true">
        
        <cftry>
            <cfset var tableName = getTableName(arguments.collection)>
            
            <!--- Handle simple queries directly to avoid SQL generation issues --->
            <cfif structCount(arguments.query) EQ 1 AND structKeyExists(arguments.query, "email")>
                <cfquery name="queryResult" datasource="#variables.datasource#">
                    SELECT * FROM #tableName# 
                    WHERE email = <cfqueryparam value="#arguments.query.email#" cfsqltype="CF_SQL_VARCHAR">
                    LIMIT 1
                </cfquery>
            <cfelseif structCount(arguments.query) EQ 1 AND structKeyExists(arguments.query, "_id")>
                <cfquery name="queryResult" datasource="#variables.datasource#">
                    SELECT * FROM #tableName# 
                    WHERE id = <cfqueryparam value="#arguments.query._id#" cfsqltype="CF_SQL_VARCHAR">
                    LIMIT 1
                </cfquery>
            <cfelseif structCount(arguments.query) EQ 1 AND (structKeyExists(arguments.query, "session_id") OR structKeyExists(arguments.query, "sessionId"))>
                <cfset var sessionIdValue = structKeyExists(arguments.query, "sessionId") ? arguments.query.sessionId : arguments.query.session_id>
                <cfquery name="queryResult" datasource="#variables.datasource#">
                    SELECT * FROM #tableName# 
                    WHERE session_id = <cfqueryparam value="#sessionIdValue#" cfsqltype="CF_SQL_VARCHAR">
                    LIMIT 1
                </cfquery>
            <cfelse>
                <!--- For complex queries, return error for now to avoid SQL bug --->
                <cfreturn {
                    "success": false,
                    "data": {},
                    "error": "Complex queries not supported in findOne"
                }>
            </cfif>
            
            <!--- Convert query result to struct --->
            <cfset var data = {}>
            <cfif queryResult.recordCount GT 0>
                <cfloop list="#queryResult.columnList#" index="col">
                    <cfset var value = queryResult[col][1]>
                    <!--- Handle JSON columns --->
                    <cfif listFindNoCase("preferences,ingredients,nutrition_facts", col)>
                        <cftry>
                            <cfif isJSON(value)>
                                <cfset data[col] = deserializeJSON(value)>
                            <cfelse>
                                <cfset data[col] = {}>
                            </cfif>
                            <cfcatch>
                                <cfset data[col] = {}>
                            </cfcatch>
                        </cftry>
                    <cfelse>
                        <!--- Map database columns to expected field names --->
                        <cfset var fieldName = lcase(col)>
                        <cfif lcase(col) EQ "id">
                            <cfset fieldName = "_id">
                        <cfelseif lcase(col) EQ "nutrition_facts">
                            <cfset fieldName = "nutritionFacts">
                        <cfelseif lcase(col) EQ "created_at">
                            <cfset fieldName = "createdAt">
                        <cfelseif lcase(col) EQ "updated_at">
                            <cfset fieldName = "updatedAt">
                        <cfelseif lcase(col) EQ "session_id">
                            <cfset fieldName = "sessionId">
                        <cfelseif lcase(col) EQ "user_id">
                            <cfset fieldName = "userId">
                        <cfelseif lcase(col) EQ "expires_at">
                            <cfset fieldName = "expiresAt">
                        <cfelseif lcase(col) EQ "ip_address">
                            <cfset fieldName = "ipAddress">
                        <cfelseif lcase(col) EQ "user_agent">
                            <cfset fieldName = "userAgent">
                        </cfif>
                        <cfset data[fieldName] = value>
                    </cfif>
                </cfloop>
            </cfif>
            
            <cfreturn {
                "success": queryResult.recordCount GT 0,
                "data": data,
                "recordCount": queryResult.recordCount
            }>
            
            <cfcatch type="any">
                <cflog file="data" text="FindOne error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "data": {},
                    "error": cfcatch.message
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <!--- Insert Document --->
    <cffunction name="insertDocument" returntype="struct" access="private" output="false">
        <cfargument name="collection" type="string" required="true">
        <cfargument name="data" type="struct" required="true">
        
        <cftry>
            <cfset var tableName = getTableName(arguments.collection)>
            <cfset var insertData = duplicate(arguments.data)>
            
            
            <!--- Handle JSON fields --->
            <cfif structKeyExists(insertData, "preferences") AND isStruct(insertData.preferences)>
                <cfset insertData.preferences = serializeJSON(insertData.preferences)>
            </cfif>
            <cfif structKeyExists(insertData, "ingredients") AND isArray(insertData.ingredients)>
                <cfset insertData.ingredients = serializeJSON(insertData.ingredients)>
            </cfif>
            <cfif structKeyExists(insertData, "nutritionFacts") AND isStruct(insertData.nutritionFacts)>
                <cfset insertData.nutrition_facts = serializeJSON(insertData.nutritionFacts)>
                <cfset structDelete(insertData, "nutritionFacts")>
            </cfif>
            
            <!--- Map field names to database columns --->
            <cfif structKeyExists(insertData, "_id")>
                <cfset insertData.id = insertData._id>
                <cfset structDelete(insertData, "_id")>
            </cfif>
            <cfif structKeyExists(insertData, "createdAt")>
                <cfset structDelete(insertData, "createdAt")> <!--- Let MySQL handle this --->
            </cfif>
            <cfif structKeyExists(insertData, "updatedAt")>
                <cfset structDelete(insertData, "updatedAt")> <!--- Let MySQL handle this --->
            </cfif>
            <cfif structKeyExists(insertData, "createdBy")>
                <cfset insertData.created_by = insertData.createdBy>
                <cfset structDelete(insertData, "createdBy")>
            </cfif>
            <cfif structKeyExists(insertData, "updatedBy")>
                <cfset insertData.updated_by = insertData.updatedBy>
                <cfset structDelete(insertData, "updatedBy")>
            </cfif>
            <!--- Map session-specific fields to database columns --->
            <cfif structKeyExists(insertData, "sessionId")>
                <cfset insertData.session_id = insertData.sessionId>
                <cfset structDelete(insertData, "sessionId")>
            </cfif>
            <cfif structKeyExists(insertData, "userId")>
                <cfset insertData.user_id = insertData.userId>
                <cfset structDelete(insertData, "userId")>
            </cfif>
            <cfif structKeyExists(insertData, "expiresAt")>
                <cfset insertData.expires_at = insertData.expiresAt>
                <cfset structDelete(insertData, "expiresAt")>
            </cfif>
            <cfif structKeyExists(insertData, "ipAddress")>
                <cfset insertData.ip_address = insertData.ipAddress>
                <cfset structDelete(insertData, "ipAddress")>
            </cfif>
            <cfif structKeyExists(insertData, "userAgent")>
                <cfset insertData.user_agent = insertData.userAgent>
                <cfset structDelete(insertData, "userAgent")>
            </cfif>
            
            <!--- Build INSERT query --->
            <cfset var columns = []>
            <cfset var placeholders = []>
            <cfset var params = []>
            
            <cfloop collection="#insertData#" item="key">
                <cfif NOT listFindNoCase("id", key)> <!--- Skip id, let MySQL generate it --->
                    <cfset arrayAppend(columns, key)>
                    <cfset arrayAppend(placeholders, "?")>
                    <cfset arrayAppend(params, {
                        "value": insertData[key],
                        "type": getSQLType(insertData[key])
                    })>
                </cfif>
            </cfloop>
            
            <cfset var sql = "INSERT INTO #tableName# (#arrayToList(columns)#) VALUES (#arrayToList(placeholders)#)">
            
            <!--- Build column and value arrays for clean SQL --->
            <cfset var columns = []>
            <cfset var values = []>
            <cfloop collection="#insertData#" item="key">
                <cfset arrayAppend(columns, key)>
                <cfset arrayAppend(values, insertData[key])>
            </cfloop>
            
            <!--- Execute insert with inline parameters --->
            <cfquery name="insertResult" datasource="#variables.datasource#" result="insertInfo">
                INSERT INTO #tableName# 
                (#arrayToList(columns)#)
                VALUES 
                (<cfloop from="1" to="#arrayLen(values)#" index="i">
                    <cfif i GT 1>,</cfif><cfqueryparam value="#values[i]#" cfsqltype="CF_SQL_VARCHAR">
                </cfloop>)
            </cfquery>
            
            <!--- Get the inserted ID and fetch the created record --->
            <cfset var insertedId = "">
            <cfif structKeyExists(insertInfo, "generatedKey")>
                <cfset insertedId = insertInfo.generatedKey>
            <cfelseif structKeyExists(insertInfo, "generated_key")>
                <cfset insertedId = insertInfo.generated_key>
            <cfelseif structKeyExists(insertInfo, "GENERATEDKEY")>
                <cfset insertedId = insertInfo.GENERATEDKEY>
            <cfelseif structKeyExists(insertInfo, "GENERATED_KEY")>
                <cfset insertedId = insertInfo.GENERATED_KEY>
            <cfelseif structKeyExists(insertInfo, "insertId")>
                <cfset insertedId = insertInfo.insertId>
            <cfelseif structKeyExists(insertInfo, "lastInsertId")>
                <cfset insertedId = insertInfo.lastInsertId>
            <cfelse>
                <!--- Use LAST_INSERT_ID() as fallback --->
                <cfquery name="getLastInsert" datasource="#variables.datasource#">
                    SELECT LAST_INSERT_ID() as lastId
                </cfquery>
                <cfif getLastInsert.recordCount GT 0>
                    <cfset insertedId = getLastInsert.lastId>
                </cfif>
            </cfif>
            
            <!--- Fetch the created record to return full data --->
            <cfquery name="newRecord" datasource="#variables.datasource#">
                SELECT * FROM #tableName# WHERE id = <cfqueryparam value="#insertedId#" cfsqltype="CF_SQL_VARCHAR">
            </cfquery>
            
            <!--- Convert query to struct --->
            <cfset var resultData = {}>
            <cfif newRecord.recordCount GT 0>
                <cfloop query="newRecord">
                    <cfset resultData = queryRowToStruct(newRecord, newRecord.currentRow)>
                    <!--- Add the MongoDB-style _id field --->
                    <cfset resultData._id = newRecord.id>
                </cfloop>
            <cfelse>
                <cfset resultData = insertData>
                <cfset resultData._id = insertedId>
            </cfif>
            
            <!--- Return success with inserted data --->
            <cfreturn {
                "success": true,
                "data": resultData,
                "insertedId": insertedId
            }>
            
            <cfcatch type="any">
                <cflog file="data" text="Insert document error: #cfcatch.message# - SQL: #sql#" type="error">
                <cfreturn {
                    "success": false,
                    "error": cfcatch.message
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <!--- Update Document --->
    <cffunction name="updateDocument" returntype="struct" access="private" output="false">
        <cfargument name="collection" type="string" required="true">
        <cfargument name="query" type="struct" required="true">
        <cfargument name="data" type="struct" required="true">
        <cfargument name="options" type="struct" required="false" default="#{}#">
        
        <cftry>
            <cfset var tableName = getTableName(arguments.collection)>
            <cfset var updateData = duplicate(arguments.data)>
            <cfset var whereClause = buildWhereClause(arguments.query)>
            
            <!--- Handle JSON fields --->
            <cfif structKeyExists(updateData, "preferences") AND isStruct(updateData.preferences)>
                <cfset updateData.preferences = serializeJSON(updateData.preferences)>
            </cfif>
            <cfif structKeyExists(updateData, "ingredients") AND isArray(updateData.ingredients)>
                <cfset updateData.ingredients = serializeJSON(updateData.ingredients)>
            </cfif>
            <cfif structKeyExists(updateData, "nutritionFacts") AND isStruct(updateData.nutritionFacts)>
                <cfset updateData.nutrition_facts = serializeJSON(updateData.nutritionFacts)>
                <cfset structDelete(updateData, "nutritionFacts")>
            </cfif>
            
            <!--- Map field names --->
            <cfif structKeyExists(updateData, "_id")>
                <cfset structDelete(updateData, "_id")> <!--- Don't update ID --->
            </cfif>
            <cfif structKeyExists(updateData, "createdAt")>
                <cfset structDelete(updateData, "createdAt")> <!--- Don't update created_at --->
            </cfif>
            <cfif structKeyExists(updateData, "updatedAt")>
                <cfset structDelete(updateData, "updatedAt")> <!--- Let MySQL handle this --->
            </cfif>
            <cfif structKeyExists(updateData, "createdBy")>
                <cfset updateData.created_by = updateData.createdBy>
                <cfset structDelete(updateData, "createdBy")>
            </cfif>
            <cfif structKeyExists(updateData, "updatedBy")>
                <cfset updateData.updated_by = updateData.updatedBy>
                <cfset structDelete(updateData, "updatedBy")>
            </cfif>
            
            <!--- Build UPDATE query --->
            <cfset var setClauses = []>
            <cfset var params = []>
            
            <cfloop collection="#updateData#" item="key">
                <cfset arrayAppend(setClauses, "#key# = ?")>
                <cfset arrayAppend(params, {
                    "value": updateData[key],
                    "type": getSQLType(updateData[key])
                })>
            </cfloop>
            
            <!--- Add WHERE parameters --->
            <cfloop array="#whereClause.params#" index="whereParam">
                <cfset arrayAppend(params, whereParam)>
            </cfloop>
            
            <cfset var sql = "UPDATE #tableName# SET #arrayToList(setClauses)#">
            <cfif len(whereClause.sql) GT 0>
                <cfset sql = sql & " WHERE " & whereClause.sql>
            </cfif>
            
            <!--- Execute update --->
            <cfquery name="updateResult" datasource="#variables.datasource#" result="updateInfo">
                #sql#
                <cfloop array="#params#" index="param">
                    <cfqueryparam value="#param.value#" cfsqltype="#param.type#">
                </cfloop>
            </cfquery>
            
            <cfreturn {
                "success": updateInfo.recordCount GT 0,
                "modifiedCount": updateInfo.recordCount,
                "matchedCount": updateInfo.recordCount
            }>
            
            <cfcatch type="any">
                <cflog file="data" text="Update document error: #cfcatch.message# - SQL: #sql#" type="error">
                <cfreturn {
                    "success": false,
                    "error": cfcatch.message
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <!--- Delete Document --->
    <cffunction name="deleteDocument" returntype="struct" access="private" output="false">
        <cfargument name="collection" type="string" required="true">
        <cfargument name="query" type="struct" required="true">
        
        <cftry>
            <cfset var tableName = getTableName(arguments.collection)>
            <cfset var whereClause = buildWhereClause(arguments.query)>
            
            <cfset var sql = "DELETE FROM #tableName#">
            <cfif len(whereClause.sql) GT 0>
                <cfset sql = sql & " WHERE " & whereClause.sql>
            </cfif>
            
            <!--- Execute delete --->
            <cfquery name="deleteResult" datasource="#variables.datasource#" result="deleteInfo">
                #sql#
                <cfloop array="#whereClause.params#" index="param">
                    <cfqueryparam value="#param.value#" cfsqltype="#param.type#">
                </cfloop>
            </cfquery>
            
            <cfreturn {
                "success": deleteInfo.recordCount GT 0,
                "deletedCount": deleteInfo.recordCount
            }>
            
            <cfcatch type="any">
                <cflog file="data" text="Delete document error: #cfcatch.message# - SQL: #sql#" type="error">
                <cfreturn {
                    "success": false,
                    "error": cfcatch.message
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <!--- Helper Functions --->
    <cffunction name="getTableName" returntype="string" access="private" output="false">
        <cfargument name="collection" type="string" required="true">
        
        <cfswitch expression="#arguments.collection#">
            <cfcase value="users">
                <cfreturn "users">
            </cfcase>
            <cfcase value="products">
                <cfreturn "products">
            </cfcase>
            <cfcase value="sessions">
                <cfreturn "sessions">
            </cfcase>
            <cfcase value="categories">
                <cfreturn "categories">
            </cfcase>
            <cfdefaultcase>
                <cfthrow type="InvalidCollection" message="Unknown collection: #arguments.collection#">
            </cfdefaultcase>
        </cfswitch>
    </cffunction>
    
    <cffunction name="buildWhereClause" returntype="struct" access="private" output="false">
        <cfargument name="query" type="struct" required="true">
        
        <cfset var whereParts = []>
        <cfset var params = []>
        
        <!--- Handle empty query --->
        <cfif structCount(arguments.query) EQ 0>
            <cfreturn {"sql": "", "params": []}>
        </cfif>
        
        <!--- Handle special operators --->
        <cfif structKeyExists(arguments.query, "$or")>
            <cfset var orParts = []>
            <cfloop array="#arguments.query.$or#" index="orCondition">
                <cfset var orClause = buildWhereClause(orCondition)>
                <cfif len(orClause.sql) GT 0>
                    <cfset arrayAppend(orParts, "(" & orClause.sql & ")")>
                    <cfloop array="#orClause.params#" index="param">
                        <cfset arrayAppend(params, param)>
                    </cfloop>
                </cfif>
            </cfloop>
            <cfif arrayLen(orParts) GT 0>
                <cfset arrayAppend(whereParts, "(" & arrayToList(orParts, " OR ") & ")")>
            </cfif>
        <cfelse>
            <!--- Handle regular fields --->
            <cfloop collection="#arguments.query#" item="key">
                <cfset var dbColumn = key>
                
                <!--- Map field names to database columns --->
                <cfif key EQ "_id">
                    <cfset dbColumn = "id">
                <cfelseif key EQ "searchTerm">
                    <!--- Handle full-text search --->
                    <cfset arrayAppend(whereParts, "(name LIKE ? OR brand LIKE ? OR description LIKE ?)")>
                    <cfset var searchValue = "%" & arguments.query[key] & "%">
                    <cfset arrayAppend(params, {"value": searchValue, "type": "CF_SQL_VARCHAR"})>
                    <cfset arrayAppend(params, {"value": searchValue, "type": "CF_SQL_VARCHAR"})>
                    <cfset arrayAppend(params, {"value": searchValue, "type": "CF_SQL_VARCHAR"})>
                    <cfcontinue>
                <cfelseif key EQ "createdBy">
                    <cfset dbColumn = "created_by">
                <cfelseif key EQ "updatedBy">
                    <cfset dbColumn = "updated_by">
                <cfelseif key EQ "sessionId">
                    <cfset dbColumn = "session_id">
                <cfelseif key EQ "userId">
                    <cfset dbColumn = "user_id">
                </cfif>
                
                <cfset arrayAppend(whereParts, "#dbColumn# = ?")>
                <cfset arrayAppend(params, {
                    "value": arguments.query[key],
                    "type": getSQLType(arguments.query[key])
                })>
            </cfloop>
        </cfif>
        
        <cfreturn {
            "sql": arrayToList(whereParts, " AND "),
            "params": params
        }>
    </cffunction>
    
    <cffunction name="getSQLType" returntype="string" access="private" output="false">
        <cfargument name="value" required="true">
        
        <cfif isNumeric(arguments.value)>
            <cfreturn "CF_SQL_INTEGER">
        <cfelseif isDate(arguments.value)>
            <cfreturn "CF_SQL_TIMESTAMP">
        <cfelseif isBoolean(arguments.value)>
            <cfreturn "CF_SQL_BOOLEAN">
        <cfelse>
            <cfreturn "CF_SQL_VARCHAR">
        </cfif>
    </cffunction>

</cfcomponent>
