<cfcomponent displayname="Data Service" output="false">

    <cffunction name="init" returntype="DataService" access="public" output="false">
        <!--- Initialize in-memory data storage --->
        <cfif NOT structKeyExists(application, "dataStorage")>
            <cfset application.dataStorage = {
                "users": [],
                "products": [],
                "sessions": []
            }>
            
            <!--- No mock data initialization needed - using MySQL --->
            <cflog file="data" text="In-memory DataService initialized (fallback mode)" type="warning">
        </cfif>
        
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
                <cflog file="data" text="Data operation error: #cfcatch.message#" type="error">
                <cfset result = {
                    "success": false,
                    "error": cfcatch.message
                }>
                <cfreturn result>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <!--- Data Operations --->
    <cffunction name="findDocuments" returntype="struct" access="private" output="false">
        <cfargument name="collection" type="string" required="true">
        <cfargument name="query" type="struct" required="true">
        <cfargument name="options" type="struct" required="false" default="#{}#">
        
        <cftry>
            <cfset var data = getCollectionData(arguments.collection)>
            <cfset var filteredData = []>
            <cfset var limit = 0>
            <cfset var skip = 0>
            
            <cfif structKeyExists(arguments.options, "limit")>
                <cfset limit = arguments.options.limit>
            </cfif>
            <cfif structKeyExists(arguments.options, "skip")>
                <cfset skip = arguments.options.skip>
            </cfif>
            
            <!--- Filter data based on query --->
            <cfloop array="#data#" index="doc">
                <cfif matchesQuery(doc, arguments.query)>
                    <cfset arrayAppend(filteredData, doc)>
                </cfif>
            </cfloop>
            
            <!--- Apply skip and limit --->
            <cfif skip GT 0 AND arrayLen(filteredData) GT skip>
                <cfset filteredData = arraySlice(filteredData, skip + 1, arrayLen(filteredData))>
            </cfif>
            
            <cfif limit GT 0 AND arrayLen(filteredData) GT limit>
                <cfset filteredData = arraySlice(filteredData, 1, limit)>
            </cfif>
            
            <cfreturn {
                "success": true,
                "data": filteredData,
                "count": arrayLen(filteredData)
            }>
            
            <cfcatch type="any">
                <cflog file="data" text="Find documents error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "error": cfcatch.message
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="findOneDocument" returntype="struct" access="private" output="false">
        <cfargument name="collection" type="string" required="true">
        <cfargument name="query" type="struct" required="true">
        
        <cftry>
            <cfset var result = findDocuments(arguments.collection, arguments.query, {"limit": 1})>
            
            <cfif result.success AND arrayLen(result.data) GT 0>
                <cfreturn {
                    "success": true,
                    "data": result.data[1]
                }>
            <cfelse>
                <cfreturn {
                    "success": false,
                    "data": {}
                }>
            </cfif>
            
            <cfcatch type="any">
                <cflog file="data" text="Find one document error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "data": {}
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="insertDocument" returntype="struct" access="private" output="false">
        <cfargument name="collection" type="string" required="true">
        <cfargument name="data" type="struct" required="true">
        
        <cftry>
            <cfset var data = getCollectionData(arguments.collection)>
            <cfset var newDoc = duplicate(arguments.data)>
            
            <!--- Generate ID if not present --->
            <cfif NOT structKeyExists(newDoc, "_id")>
                <cfset newDoc._id = createUUID()>
            </cfif>
            
            <!--- Add timestamps --->
            <cfif NOT structKeyExists(newDoc, "createdAt")>
                <cfset newDoc.createdAt = dateTimeFormat(now(), "iso8601")>
            </cfif>
            <cfset newDoc.updatedAt = dateTimeFormat(now(), "iso8601")>
            
            <!--- Add to collection --->
            <cfset arrayAppend(data, newDoc)>
            
            <cfreturn {
                "success": true,
                "data": newDoc,
                "insertedId": newDoc._id
            }>
            
            <cfcatch type="any">
                <cflog file="data" text="Insert document error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "error": cfcatch.message
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="updateDocument" returntype="struct" access="private" output="false">
        <cfargument name="collection" type="string" required="true">
        <cfargument name="query" type="struct" required="true">
        <cfargument name="data" type="struct" required="true">
        <cfargument name="options" type="struct" required="false" default="#{}#">
        
        <cftry>
            <cfset var data = getCollectionData(arguments.collection)>
            <cfset var modifiedCount = 0>
            
            <!--- Find and update matching documents --->
            <cfloop array="#data#" index="doc">
                <cfif matchesQuery(doc, arguments.query)>
                    <!--- Update fields --->
                    <cfloop collection="#arguments.data#" item="key">
                        <cfset doc[key] = arguments.data[key]>
                    </cfloop>
                    <cfset doc.updatedAt = dateTimeFormat(now(), "iso8601")>
                    <cfset modifiedCount = modifiedCount + 1>
                </cfif>
            </cfloop>
            
            <cfreturn {
                "success": modifiedCount GT 0,
                "modifiedCount": modifiedCount,
                "matchedCount": modifiedCount
            }>
            
            <cfcatch type="any">
                <cflog file="data" text="Update document error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "error": cfcatch.message
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="deleteDocument" returntype="struct" access="private" output="false">
        <cfargument name="collection" type="string" required="true">
        <cfargument name="query" type="struct" required="true">
        
        <cftry>
            <cfset var data = getCollectionData(arguments.collection)>
            <cfset var deletedCount = 0>
            <cfset var indicesToDelete = []>
            
            <!--- Find matching documents to delete --->
            <cfloop from="1" to="#arrayLen(data)#" index="i">
                <cfif matchesQuery(data[i], arguments.query)>
                    <cfset arrayAppend(indicesToDelete, i)>
                </cfif>
            </cfloop>
            
            <!--- Delete documents (in reverse order to maintain indices) --->
            <cfloop from="#arrayLen(indicesToDelete)#" to="1" step="-1" index="j">
                <cfset arrayDeleteAt(data, indicesToDelete[j])>
                <cfset deletedCount = deletedCount + 1>
            </cfloop>
            
            <cfreturn {
                "success": deletedCount GT 0,
                "deletedCount": deletedCount
            }>
            
            <cfcatch type="any">
                <cflog file="data" text="Delete document error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "error": cfcatch.message
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <!--- Helper Functions --->
    <cffunction name="getCollectionData" returntype="array" access="private" output="false">
        <cfargument name="collection" type="string" required="true">
        
        <cfif NOT structKeyExists(application.dataStorage, arguments.collection)>
            <cfset application.dataStorage[arguments.collection] = []>
        </cfif>
        
        <cfreturn application.dataStorage[arguments.collection]>
    </cffunction>
    
    <cffunction name="matchesQuery" returntype="boolean" access="private" output="false">
        <cfargument name="doc" type="struct" required="true">
        <cfargument name="query" type="struct" required="true">
        
        <cfset var matches = true>
        
        <!--- Handle empty query (match all) --->
        <cfif structCount(arguments.query) EQ 0>
            <cfreturn true>
        </cfif>
        
        <!--- Handle special query operators --->
        <cfif structKeyExists(arguments.query, "$or")>
            <cfset matches = false>
            <cfloop array="#arguments.query.$or#" index="orCondition">
                <cfif matchesQuery(arguments.doc, orCondition)>
                    <cfset matches = true>
                    <cfbreak>
                </cfif>
            </cfloop>
            <cfreturn matches>
        </cfif>
        
        <!--- Handle regular field matching --->
        <cfloop collection="#arguments.query#" item="key">
            <cfif key EQ "searchTerm">
                <!--- Special handling for text search --->
                <cfset var searchTerm = lcase(arguments.query[key])>
                <cfset var found = false>
                
                <!--- Search in name, brand, description, category --->
                <cfif structKeyExists(arguments.doc, "name") AND findNoCase(searchTerm, arguments.doc.name) GT 0>
                    <cfset found = true>
                <cfelseif structKeyExists(arguments.doc, "brand") AND findNoCase(searchTerm, arguments.doc.brand) GT 0>
                    <cfset found = true>
                <cfelseif structKeyExists(arguments.doc, "description") AND findNoCase(searchTerm, arguments.doc.description) GT 0>
                    <cfset found = true>
                <cfelseif structKeyExists(arguments.doc, "category") AND findNoCase(searchTerm, arguments.doc.category) GT 0>
                    <cfset found = true>
                </cfif>
                
                <cfif NOT found>
                    <cfset matches = false>
                    <cfbreak>
                </cfif>
            <cfelse>
                <!--- Regular field matching --->
                <cfif NOT structKeyExists(arguments.doc, key) OR arguments.doc[key] NEQ arguments.query[key]>
                    <cfset matches = false>
                    <cfbreak>
                </cfif>
            </cfif>
        </cfloop>
        
        <cfreturn matches>
    </cffunction>
    
    <!--- Mock data initialization function removed - using MySQL database instead --->

</cfcomponent>
