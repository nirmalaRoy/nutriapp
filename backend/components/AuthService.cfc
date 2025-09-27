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
            "session_id": sessionId,
            "user_id": arguments.userId,
            "expires_at": dateTimeFormat(expiresAt, "yyyy-mm-dd HH:nn:ss"),
            "ip_address": cgi.remote_addr,
            "user_agent": cgi.http_user_agent
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

    <cffunction name="forgotPassword" returntype="struct" access="public" output="false">
        <cfargument name="email" type="string" required="true">
        
        <cftry>
            <!--- Check if user exists --->
            <cfquery name="userCheck" datasource="nutriapp">
                SELECT id, email, username 
                FROM users 
                WHERE email = <cfqueryparam value="#lcase(arguments.email)#" cfsqltype="CF_SQL_VARCHAR">
            </cfquery>
            
            <cfif userCheck.recordCount EQ 0>
                <!--- For security, return success even if email doesn't exist --->
                <cfreturn {
                    "success": true,
                    "message": "If the email exists in our system, a password reset link has been sent."
                }>
            </cfif>
            
            <!--- Generate reset token --->
            <cfset var resetToken = hash(createUUID() & now() & arguments.email, "SHA-256")>
            <cfset var expiresAt = dateAdd("n", 15, now())> <!--- 15 minute expiry --->
            
            <!--- Deactivate any existing tokens for this email --->
            <cfquery name="deactivateTokens" datasource="nutriapp">
                UPDATE password_reset_tokens 
                SET is_active = 0 
                WHERE email = <cfqueryparam value="#lcase(arguments.email)#" cfsqltype="CF_SQL_VARCHAR">
                  AND is_active = 1
            </cfquery>
            
            <!--- Insert new reset token --->
            <cfquery name="insertToken" datasource="nutriapp">
                INSERT INTO password_reset_tokens (email, token, expires_at)
                VALUES (
                    <cfqueryparam value="#lcase(arguments.email)#" cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#resetToken#" cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#dateTimeFormat(expiresAt, 'yyyy-mm-dd HH:nn:ss')#" cfsqltype="CF_SQL_TIMESTAMP">
                )
            </cfquery>
            
            <!--- Send password reset email --->
            <cftry>
                <cfset resetUrl = "http://localhost:3000/reset-password?token=" & resetToken>
                
                <cfmail 
                    to="#arguments.email#" 
                    from="testnaina02@gmail.com" 
                    subject="Password Reset Request - NutriApp"
                    type="html"
                    server="#application.mailServer.server#"
                    port="#application.mailServer.port#"
                    username="#application.mailServer.username#"
                    password="#application.mailServer.password#"
                    usessl="#application.mailServer.useSSL#"
                    usetls="#application.mailServer.useTLS#">
                    <h2>Password Reset Request</h2>
                    <p>Hello,</p>
                    <p>You have requested to reset your password for your NutriApp account.</p>
                    <p>Click the link below to reset your password (valid for 15 minutes):</p>
                    <p><a href="#resetUrl#" style="background-color: ##007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Reset Password</a></p>
                    <p>Or copy and paste this URL into your browser:</p>
                    <p style="word-break: break-all;">#resetUrl#</p>
                    <p>If you did not request this password reset, please ignore this email.</p>
                    <p>Best regards,<br>NutriApp Team</p>
                </cfmail>
                
                <cflog file="auth" text="Password reset email sent to #arguments.email#" type="information">
                
                <cfcatch type="any">
                    <!--- Log email error but don't reveal it to user for security --->
                    <cflog file="auth" text="Email sending failed for #arguments.email#: #cfcatch.message#" type="error">
                    <!--- Still return success for security reasons --->
                </cfcatch>
            </cftry>
            
            <cfreturn {
                "success": true,
                "message": "If the email exists in our system, a password reset link has been sent to your email address."
            }>
            
            <cfcatch type="any">
                <cflog file="auth" text="Forgot password error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "error": "Unable to process password reset request"
                }>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="resetPassword" returntype="struct" access="public" output="false">
        <cfargument name="token" type="string" required="true">
        <cfargument name="newPassword" type="string" required="true">
        
        <cftry>
            <!--- Validate reset token --->
            <cfquery name="tokenCheck" datasource="nutriapp">
                SELECT email, created_at, expires_at 
                FROM password_reset_tokens 
                WHERE token = <cfqueryparam value="#arguments.token#" cfsqltype="CF_SQL_VARCHAR">
                  AND is_active = 1
                  AND used_at IS NULL
                  AND expires_at > NOW()
            </cfquery>
            
            <cfif tokenCheck.recordCount EQ 0>
                <cfreturn {
                    "success": false,
                    "error": "Invalid or expired reset token"
                }>
            </cfif>
            
            <!--- Hash the new password --->
            <cfset var hashedPassword = hashPassword(arguments.newPassword)>
            
            <!--- Update user password --->
            <cfquery name="updatePassword" datasource="nutriapp">
                UPDATE users 
                SET password = <cfqueryparam value="#hashedPassword#" cfsqltype="CF_SQL_VARCHAR">,
                    updated_at = NOW()
                WHERE email = <cfqueryparam value="#tokenCheck.email#" cfsqltype="CF_SQL_VARCHAR">
            </cfquery>
            
            <!--- Mark token as used --->
            <cfquery name="markTokenUsed" datasource="nutriapp">
                UPDATE password_reset_tokens 
                SET used_at = NOW(), is_active = 0
                WHERE token = <cfqueryparam value="#arguments.token#" cfsqltype="CF_SQL_VARCHAR">
            </cfquery>
            
            <!--- Invalidate all existing sessions for this user --->
            <cfquery name="invalidateSessions" datasource="nutriapp">
                UPDATE sessions 
                SET is_active = 0
                WHERE user_id IN (
                    SELECT id FROM users WHERE email = <cfqueryparam value="#tokenCheck.email#" cfsqltype="CF_SQL_VARCHAR">
                )
            </cfquery>
            
            <cfreturn {
                "success": true,
                "message": "Password has been reset successfully"
            }>
            
            <cfcatch type="any">
                <cflog file="auth" text="Reset password error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "error": "Unable to reset password"
                }>
            </cfcatch>
        </cftry>
    </cffunction>

</cfcomponent>