<cfcomponent displayname="Authentication Service" output="false">

    <cffunction name="init" access="public" returntype="any" output="false">
        <cfargument name="dataService" required="true">
        <cfset variables.dataService = arguments.dataService>
        <cfset variables.saltRounds = 10>
        <cfset variables.sessionTimeout = 1800><!--- 30 minutes in seconds --->
        <cfreturn this>
    </cffunction>
    
    <cffunction name="register" returntype="struct" access="public" output="false">
        <cfargument name="userData" type="struct" required="true">
        
        <cftry>
            <!--- Validate required fields --->
            <cfif NOT structKeyExists(arguments.userData, "username") OR 
                  NOT structKeyExists(arguments.userData, "email") OR 
                  NOT structKeyExists(arguments.userData, "password")>
                <cfreturn {
                    "success": false,
                    "error": "Username, email, and password are required"
                }>
            </cfif>
            
            <!--- Check if user already exists --->
            <cfset var existingUser = variables.dataService.executeQuery(
                collection = "users",
                operation = "findOne",
                query = {
                    "$or": [
                        {"email": arguments.userData.email},
                        {"username": arguments.userData.username}
                    ]
                }
            )>
            
            <cfif existingUser.success AND structCount(existingUser.data) GT 0>
                <cfreturn {
                    "success": false,
                    "error": "User with this email or username already exists"
                }>
            </cfif>
            
            <!--- Hash password --->
            <cfset var hashedPassword = hashPassword(arguments.userData.password)>
            
            <!--- Create user document --->
            <cfset var newUser = {
                "username": arguments.userData.username,
                "email": lcase(arguments.userData.email),
                "password": hashedPassword,
                "role": "user",
                "createdAt": dateTimeFormat(now(), "iso8601"),
                "updatedAt": dateTimeFormat(now(), "iso8601"),
                "preferences": {
                    "favoriteCategories": []
                }
            }>
            
            <cfif structKeyExists(arguments.userData, "role")>
                <cfset newUser.role = arguments.userData.role>
            </cfif>
            
            <!--- Insert user --->
            <cfset var insertResult = variables.dataService.executeQuery(
                collection = "users",
                operation = "insert",
                data = newUser
            )>
            
            <cfif insertResult.success>
                <!--- Remove password from response --->
                <cfset structDelete(insertResult.data, "password")>
                
                <cfreturn {
                    "success": true,
                    "message": "User registered successfully",
                    "user": insertResult.data
                }>
            <cfelse>
                <cfreturn {
                    "success": false,
                    "error": "Failed to create user account"
                }>
            </cfif>
            
            <cfcatch type="any">
                <cflog file="auth" text="Registration error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "error": "Registration failed"
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="login" returntype="struct" access="public" output="false">
        <cfargument name="credentials" type="struct" required="true">
        
        <cftry>
            
            <!--- Validate required fields --->
            <cfif NOT structKeyExists(arguments.credentials, "email") OR 
                  NOT structKeyExists(arguments.credentials, "password")>
                <cfreturn {
                    "success": false,
                    "error": "Email and password are required"
                }>
            </cfif>
            
            <!--- Find user by email --->
            <cfset var userResult = variables.dataService.executeQuery(
                collection = "users",
                operation = "findOne",
                query = {"email": lcase(arguments.credentials.email)}
            )>
            
            <cfif NOT userResult.success OR structCount(userResult.data) EQ 0>
                <cfreturn {
                    "success": false,
                    "error": "Invalid email or password"
                }>
            </cfif>
            
            <cfset var user = userResult.data>
            
            <!--- Verify password --->
            <cfif NOT verifyPassword(arguments.credentials.password, user.password)>
                <cfreturn {
                    "success": false,
                    "error": "Invalid email or password"
                }>
            </cfif>
            
            <!--- Create session --->
            <cfset var sessionResult = createSession(user._id)>
            
            <cfif sessionResult.success>
                <!--- Remove password from user data --->
                <cfset structDelete(user, "password")>
                
                <cfreturn {
                    "success": true,
                    "message": "Login successful",
                    "user": user,
                    "session": {
                        "sessionId": sessionResult.sessionId,
                        "expiresAt": sessionResult.expiresAt
                    }
                }>
            <cfelse>
                <cfreturn {
                    "success": false,
                    "error": "Failed to create session"
                }>
            </cfif>
            
            <cfcatch type="any">
                <cflog file="auth" text="Login error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "error": "Login failed"
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="logout" returntype="struct" access="public" output="false">
        <cfargument name="sessionId" type="string" required="true">
        
        <cftry>
            <!--- Delete session from data storage --->
            <cfset var deleteResult = variables.dataService.executeQuery(
                collection = "sessions",
                operation = "delete",
                query = {"sessionId": arguments.sessionId}
            )>
            
            <!--- Clear session variables --->
            <cfset structClear(session)>
            
            <cfreturn {
                "success": true,
                "message": "Logout successful"
            }>
            
            <cfcatch type="any">
                <cflog file="auth" text="Logout error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "error": "Logout failed"
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="validateSession" returntype="struct" access="public" output="false">
        <cfargument name="sessionId" type="string" required="true">
        
        <cftry>
            <cfif len(arguments.sessionId) EQ 0>
                <cfreturn {
                    "success": false,
                    "error": "No session ID provided"
                }>
            </cfif>
            
            <!--- Find session in data storage --->
            <cfset var sessionResult = variables.dataService.executeQuery(
                collection = "sessions",
                operation = "findOne",
                query = {"sessionId": arguments.sessionId}
            )>
            
            <cfif NOT sessionResult.success OR structCount(sessionResult.data) EQ 0>
                <cfreturn {
                    "success": false,
                    "error": "Invalid session"
                }>
            </cfif>
            
            <cfset var sessionData = sessionResult.data>
            
            <!--- Check if session has expired --->
            <cftry>
                <cfif parseDateTime(sessionData.expiresAt) LT now()>
                <!--- Delete expired session --->
                <cfset variables.dataService.executeQuery(
                    collection = "sessions",
                    operation = "delete",
                    query = {"sessionId": arguments.sessionId}
                )>
                
                <cfreturn {
                    "success": false,
                    "error": "Session expired"
                }>
                </cfif>
                
                <cfcatch type="any">
                    <!--- If date parsing fails, consider session expired --->
                    <cfset variables.dataService.executeQuery(
                        collection = "sessions",
                        operation = "delete",
                        query = {"sessionId": arguments.sessionId}
                    )>
                    
                    <cfreturn {
                        "success": false,
                        "error": "Session expired"
                    }>
                </cfcatch>
            </cftry>
            
            <!--- Get user data --->
            <cfset var userResult = variables.dataService.executeQuery(
                collection = "users",
                operation = "findOne",
                query = {"_id": sessionData.userId}
            )>
            
            <cfif userResult.success AND structCount(userResult.data) GT 0>
                <cfset structDelete(userResult.data, "password")>
                
                <cfreturn {
                    "success": true,
                    "user": userResult.data,
                    "session": sessionData
                }>
            <cfelse>
                <cfreturn {
                    "success": false,
                    "error": "User not found"
                }>
            </cfif>
            
            <cfcatch type="any">
                <cflog file="auth" text="Session validation error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "error": "Session validation failed"
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="createSession" access="public" returntype="struct">
        <cfargument name="userId" type="string" required="true">

        <cfset var sessionId = createUUID()>
        <cfset var expiresAt = dateAdd("n", 30, now())> <!--- 30 min expiry --->

        <cfset var sessionData = {
            "sessionId": sessionId,
            "userId": arguments.userId,
            "expiresAt": dateTimeFormat(expiresAt, "yyyy-mm-dd HH:nn:ss"),
            "ipAddress": cgi.remote_addr,
            "userAgent": cgi.http_user_agent
        }>

        <cfset var result = variables.dataService.executeQuery(
            collection = "sessions",
            operation = "insert", 
            data = sessionData
        )>

        <cfif result.success>
            <cfreturn { "success": true, "sessionId": sessionId, "expiresAt": expiresAt }>
        <cfelse>
            <cfreturn { "success": false, "error": "Failed to create session" }>
        </cfif>
    </cffunction>
    
    <cffunction name="hashPassword" returntype="string" access="private" output="false">
        <cfargument name="password" type="string" required="true">
        
        <!--- Generate a random salt --->
        <cfset var salt = generateSecretKey("AES")>
        <!--- Use PBKDF2-like approach with multiple iterations --->
        <cfset var hashedPassword = arguments.password>
        <cfloop from="1" to="10000" index="i">
            <cfset hashedPassword = hash(hashedPassword & salt, "SHA-256")>
        </cfloop>
        <!--- Return salt:hash format for verification --->
        <cfreturn "#toBase64(salt)#:#hashedPassword#">
    </cffunction>
    
    <cffunction name="verifyPassword" returntype="boolean" access="private" output="false">
        <cfargument name="plainPassword" type="string" required="true">
        <cfargument name="hashedPassword" type="string" required="true">
        
        <cftry>
            <!--- Handle legacy/demo passwords first --->
            <cfif arguments.hashedPassword EQ "password123" OR arguments.hashedPassword EQ "admin123">
                <cfreturn arguments.plainPassword EQ arguments.hashedPassword>
            </cfif>
            
            <!--- For new hash format (salt:hash) --->
            <cfif find(":", arguments.hashedPassword) GT 0>
                <cfset var saltAndHash = listToArray(arguments.hashedPassword, ":")>
                <cfif arrayLen(saltAndHash) EQ 2>
                    <cfset var salt = toBinary(saltAndHash[1])>
                    <cfset var storedHash = saltAndHash[2]>
                    
                    <!--- Recreate hash with same salt --->
                    <cfset var testPassword = arguments.plainPassword>
                    <cfloop from="1" to="10000" index="i">
                        <cfset testPassword = hash(testPassword & salt, "SHA-256")>
                    </cfloop>
                    
                    <cfreturn testPassword EQ storedHash>
                </cfif>
            </cfif>
            
            <!--- Fallback for older hash formats --->
            <cfreturn false>
            
            <cfcatch type="any">
                <cflog file="auth" text="Password verification error: #cfcatch.message#" type="error">
                <cfreturn false>
            </cfcatch>
        </cftry>
    </cffunction>

</cfcomponent>