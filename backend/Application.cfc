<cfcomponent displayname="NutriApp Application">

    <cfset this.name = "NutriApp">
    <cfset this.applicationTimeout = createTimeSpan(0, 2, 0, 0)>
    <cfset this.sessionManagement = true>
    <cfset this.sessionTimeout = createTimeSpan(0, 0, 30, 0)>
    <cfset this.setClientCookies = true>
    <cfset this.scriptProtect = "all">
    
    <!--- CORS Settings for React Frontend --->
    <cfset this.allowedOrigins = ["http://localhost:3000", "http://127.0.0.1:3000"]>
    
    <!--- MySQL Datasource Configuration --->
    <cfset this.datasources = {
        "nutriapp": {
            "class": "com.mysql.cj.jdbc.Driver",
            "connectionString": "jdbc:mysql://localhost:3306/nutriapp?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&allowPublicKeyRetrieval=true",
            "username": "nutriapp_user",
            "password": "nutriapp_password",
            "validate": false,
            "storage": true
        }
    }>
    
    <cfset this.defaultdatasource = "nutriapp">
    
    <cffunction name="onApplicationStart" returntype="boolean" output="false">
        <cftry>
            <!--- Load mail configuration --->
            <cfinclude template="mail-config.cfm">
            
            <!--- Initialize services --->
            <cfset application.dataService = createObject("component", "components.MySQLDataService").init()>
            <cfset application.productService = createObject("component", "components.ProductService")>
            <cfset application.authService = createObject("component", "components.AuthService").init(application.dataService)>
            
            <cflog file="application" text="NutriApp started successfully" type="information">
            <cfreturn true>
            
            <cfcatch type="any">
                <cflog file="application" text="Application initialization failed: #cfcatch.message#" type="error">
                <cfreturn false>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="onRequestStart" returntype="boolean" output="false">
        <cfargument name="targetPage" type="string" required="true">
        
        <!--- CORS now handled in individual API endpoints --->
        <!--- <cfif cgi.request_method EQ "OPTIONS">
            <cfinvoke method="setCORSHeaders">
            <cfheader statuscode="200" statustext="OK">
            <cfabort>
        </cfif>
        
        <!--- Set CORS headers for all requests --->
        <cfinvoke method="setCORSHeaders"> --->
        
        <cfreturn true>
    </cffunction>
    
    <cffunction name="setCORSHeaders" returntype="void" output="false">
        <cfset var origin = "">
        <cfset var httpData = getHttpRequestData()>
        
        <cfif structKeyExists(httpData.headers, "Origin")>
            <cfset origin = httpData.headers.Origin>
        </cfif>
        
        <!--- Check if origin is allowed --->
        <cfif arrayContains(this.allowedOrigins, origin)>
            <cfheader name="Access-Control-Allow-Origin" value="#origin#">
        </cfif>
        
        <cfheader name="Access-Control-Allow-Methods" value="GET,POST,PUT,DELETE,OPTIONS">
        <cfheader name="Access-Control-Allow-Headers" value="Content-Type,Authorization,X-Requested-With">
        <cfheader name="Access-Control-Allow-Credentials" value="true">
        <cfheader name="Access-Control-Max-Age" value="3600">
    </cffunction>

</cfcomponent>