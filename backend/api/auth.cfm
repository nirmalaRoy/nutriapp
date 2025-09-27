<!--- Authentication API Endpoint --->
<!--- Handles login, register, logout, and session validation --->

<!--- CORS Configuration --->
<cfcontent reset="true">
<cfheader name="Content-Type" value="application/json">
<cfheader name="Access-Control-Allow-Origin" value="http://localhost:3000">
<cfheader name="Access-Control-Allow-Methods" value="GET,POST,PUT,DELETE,OPTIONS">
<cfheader name="Access-Control-Allow-Headers" value="Content-Type,Authorization,X-Requested-With">
<cfheader name="Access-Control-Allow-Credentials" value="true">
<cfheader name="Access-Control-Max-Age" value="3600">

<!--- Handle preflight OPTIONS request --->
<cfif cgi.request_method EQ "OPTIONS">
    <cfheader statuscode="200" statustext="OK">
    <cfabort>
</cfif>

<!--- Get HTTP method and request data --->
<cfset httpMethod = cgi.request_method>
<cfset requestData = {}>

<!--- Parse request body for POST requests --->
<cfif httpMethod EQ "POST">
    <cftry>
        <cfset httpData = getHTTPRequestData()>
        <cfif len(httpData.content)>
            <cfset requestData = deserializeJSON(httpData.content)>
        </cfif>
        
        <cfcatch type="any">
            <cfheader statuscode="400" statustext="Bad Request">
            <cfset response = {
                "success": false,
                "error": "Invalid JSON in request body"
            }>
            <cfoutput>#serializeJSON(response)#</cfoutput>
            <cfabort>
        </cfcatch>
    </cftry>
</cfif>

<!--- Get URL parameters --->
<cfset urlParams = url>

<!--- Initialize response --->
<cfset response = {
    "success": false,
    "error": "Invalid request"
}>
<cfset statusCode = 400>

<!--- Route requests based on URL path --->
<cfset pathInfo = cgi.path_info>
<cfset requestURI = cgi.request_uri>
<cfset fullPath = cgi.script_name & cgi.path_info>

<cfif (findNoCase("/login", pathInfo) OR 
       findNoCase("/login", requestURI) OR 
       findNoCase("/auth.cfm/login", fullPath) OR
       findNoCase("/login", fullPath)) AND httpMethod EQ "POST">
    <!--- User Login --->
    <cfif structKeyExists(requestData, "email") AND structKeyExists(requestData, "password")>
        <cfset loginResult = application.authService.login({
            "email": requestData.email,
            "password": requestData.password
        })>
        
        <!--- Fix response structure for frontend compatibility --->
        <cfif loginResult.success AND structKeyExists(loginResult, "session")>
            <cfset response = {
                "success": loginResult.success,
                "message": loginResult.message,
                "user": loginResult.user,
                "session": {
                    "sessionId": loginResult.session.sessionId,
                    "expiresAt": loginResult.session.expiresAt
                }
            }>
        <cfelse>
            <cfset response = loginResult>
        </cfif>
        <cfset statusCode = loginResult.success ? 200 : 401>
    <cfelse>
        <cfset response = {
            "success": false,
            "error": "Email and password are required"
        }>
        <cfset statusCode = 400>
    </cfif>
    
<cfelseif (findNoCase("/register", pathInfo) OR 
           findNoCase("/register", requestURI) OR 
           findNoCase("/auth.cfm/register", fullPath) OR
           findNoCase("/register", fullPath)) AND httpMethod EQ "POST">
    <!--- User Registration --->
    <cfif structKeyExists(requestData, "username") AND 
          structKeyExists(requestData, "email") AND 
          structKeyExists(requestData, "password")>
        
        <cfset registerData = {
            "username": requestData.username,
            "email": requestData.email,
            "password": requestData.password,
            "role": "user"
        }>
        
        <cfif structKeyExists(requestData, "role")>
            <cfset registerData.role = requestData.role>
        </cfif>
        
        <cfset registerResult = application.authService.register(registerData)>
        
        <cfset response = registerResult>
        <cfset statusCode = registerResult.success ? 201 : 400>
    <cfelse>
        <cfset response = {
            "success": false,
            "error": "Username, email, and password are required"
        }>
        <cfset statusCode = 400>
    </cfif>
    
<cfelseif (findNoCase("/logout", pathInfo) OR 
           findNoCase("/logout", requestURI) OR 
           findNoCase("/auth.cfm/logout", fullPath) OR
           findNoCase("/logout", fullPath)) AND httpMethod EQ "POST">
    <!--- User Logout --->
    <cfset sessionId = "">
    
    <!--- Get session ID from request body or session --->
    <cfif structKeyExists(requestData, "sessionId")>
        <cfset sessionId = requestData.sessionId>
    <cfelseif structKeyExists(session, "sessionId")>
        <cfset sessionId = session.sessionId>
    </cfif>
    
    <cfif len(sessionId)>
        <cfset logoutResult = application.authService.logout(sessionId)>
        <cfset response = logoutResult>
        <cfset statusCode = 200>
    <cfelse>
        <cfset response = {
            "success": false,
            "error": "No active session found"
        }>
        <cfset statusCode = 400>
    </cfif>
    
<cfelseif (findNoCase("/validate", pathInfo) OR 
           findNoCase("/validate", requestURI) OR 
           findNoCase("/auth.cfm/validate", fullPath) OR
           findNoCase("/validate", fullPath)) AND httpMethod EQ "GET">
    <!--- Session Validation --->
    <cfset sessionId = "">
    
    <!--- Get session ID from headers or session --->
    <cfset httpData = getHTTPRequestData()>
    <cfif structKeyExists(httpData.headers, "Authorization")>
        <cfset authHeader = httpData.headers.Authorization>
        <cfif left(authHeader, 7) EQ "Bearer ">
            <cfset sessionId = right(authHeader, len(authHeader) - 7)>
        </cfif>
    <cfelseif structKeyExists(session, "sessionId")>
        <cfset sessionId = session.sessionId>
    </cfif>
    
    <cfif len(sessionId)>
        <!--- Direct database query for session validation to bypass component cache issues --->
        <cftry>
            <cfquery name="sessionQuery" datasource="nutriapp">
                SELECT s.*, u.id as user_id, u.username, u.email, u.role, u.created_at as user_created_at,
                       u.updated_at as user_updated_at, u.preferences
                FROM sessions s
                INNER JOIN users u ON s.user_id = u.id
                WHERE s.session_id = <cfqueryparam value="#sessionId#" cfsqltype="CF_SQL_VARCHAR">
                  AND s.expires_at > NOW()
                  AND s.is_active = 1
            </cfquery>
            
            <cfif sessionQuery.recordCount GT 0>
                <cfset response = {
                    "success": true,
                    "user": {
                        "_id": sessionQuery.user_id,
                        "username": sessionQuery.username,
                        "email": sessionQuery.email,
                        "role": sessionQuery.role,
                        "createdAt": dateTimeFormat(sessionQuery.user_created_at, "mmmm, dd yyyy HH:nn:ss"),
                        "updatedAt": dateTimeFormat(sessionQuery.user_updated_at, "mmmm, dd yyyy HH:nn:ss"),
                        "preferences": isJSON(sessionQuery.preferences) ? deserializeJSON(sessionQuery.preferences) : {}
                    },
                    "session": {
                        "sessionId": sessionId,
                        "expiresAt": dateTimeFormat(sessionQuery.expires_at, "mmmm, dd yyyy HH:nn:ss")
                    }
                }>
                <cfset statusCode = 200>
            <cfelse>
                <cfset response = {
                    "success": false,
                    "error": "Invalid session"
                }>
                <cfset statusCode = 401>
            </cfif>
            
            <cfcatch type="any">
                <cfset response = {
                    "success": false,
                    "error": "Session validation failed"
                }>
                <cfset statusCode = 401>
            </cfcatch>
        </cftry>
    <cfelse>
        <cfset response = {
            "success": false,
            "error": "No session ID provided"
        }>
        <cfset statusCode = 401>
    </cfif>
    
<cfelseif (findNoCase("/me", pathInfo) OR 
           findNoCase("/me", requestURI) OR 
           findNoCase("/auth.cfm/me", fullPath) OR
           findNoCase("/me", fullPath)) AND httpMethod EQ "GET">
    <!--- Get current user info --->
    <cfset sessionId = "">
    
    <!--- Get session ID from headers or session --->
    <cfset httpData = getHTTPRequestData()>
    <cfif structKeyExists(httpData.headers, "Authorization")>
        <cfset authHeader = httpData.headers.Authorization>
        <cfif left(authHeader, 7) EQ "Bearer ">
            <cfset sessionId = right(authHeader, len(authHeader) - 7)>
        </cfif>
    <cfelseif structKeyExists(session, "sessionId")>
        <cfset sessionId = session.sessionId>
    </cfif>
    
    <cfif len(sessionId)>
        <cfset validateResult = application.authService.validateSession(sessionId)>
        <cfif validateResult.success>
            <cfset response = {
                "success": true,
                "user": validateResult.user
            }>
            <cfset statusCode = 200>
        <cfelse>
            <cfset response = validateResult>
            <cfset statusCode = 401>
        </cfif>
    <cfelse>
        <cfset response = {
            "success": false,
            "error": "Authentication required"
        }>
        <cfset statusCode = 401>
    </cfif>
    
<cfelseif (findNoCase("/forgot-password", pathInfo) OR 
           findNoCase("/forgot-password", requestURI) OR 
           findNoCase("/auth.cfm/forgot-password", fullPath) OR
           findNoCase("/forgot-password", fullPath)) AND httpMethod EQ "POST">
    <!--- Forgot Password --->
    <cfif structKeyExists(requestData, "email")>
        <cfset forgotResult = application.authService.forgotPassword(requestData.email)>
        <cfset response = forgotResult>
        <cfset statusCode = forgotResult.success ? 200 : 400>
    <cfelse>
        <cfset response = {
            "success": false,
            "error": "Email address is required"
        }>
        <cfset statusCode = 400>
    </cfif>
    
<cfelseif (findNoCase("/reset-password", pathInfo) OR 
           findNoCase("/reset-password", requestURI) OR 
           findNoCase("/auth.cfm/reset-password", fullPath) OR
           findNoCase("/reset-password", fullPath)) AND httpMethod EQ "POST">
    <!--- Reset Password --->
    <cfif structKeyExists(requestData, "token") AND structKeyExists(requestData, "password")>
        <cfset resetResult = application.authService.resetPassword(requestData.token, requestData.password)>
        <cfset response = resetResult>
        <cfset statusCode = resetResult.success ? 200 : 400>
    <cfelse>
        <cfset response = {
            "success": false,
            "error": "Reset token and new password are required"
        }>
        <cfset statusCode = 400>
    </cfif>
    
<cfelse>
    <!--- Invalid endpoint or method --->
    <cfset response = {
        "success": false,
        "error": "Endpoint not found or method not allowed",
        "availableEndpoints": [
            "POST /api/auth/login",
            "POST /api/auth/register", 
            "POST /api/auth/logout",
            "GET /api/auth/validate",
            "GET /api/auth/me",
            "POST /api/auth/forgot-password",
            "POST /api/auth/reset-password"
        ]
    }>
    <cfset statusCode = 404>
</cfif>

<!--- Send response --->
<cfheader statuscode="#statusCode#">
<cfoutput>#serializeJSON(response)#</cfoutput>