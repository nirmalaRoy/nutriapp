<!--- 
    Email Configuration for NutriApp
    Add your SMTP settings here 
--->

<cfif not structKeyExists(application, "mailConfigured")>
    <!--- Configure mail settings for Gmail --->
    <!--- IMPORTANT: Replace "Adobe@az123" with Gmail App Password --->
    <!--- Go to Google Account → Security → 2-Step Verification → App passwords --->
    <cfset application.mailServer = {
        server = "smtp.gmail.com",
        port = 587,
        username = "testnaina02@gmail.com",
        password = "ablm duhc lfpa hpfo",  <!--- Gmail App Password --->
        useSSL = false,
        useTLS = true
    }>
    
    <!--- Backup localhost config if needed --->
    <!--- 
    <cfset application.mailServer = {
        server = "localhost",
        port = 25,
        username = "",
        password = "",
        useSSL = false,
        useTLS = false
    }>
    --->
    
    <!--- For Office 365 --->
    <!--- 
    <cfset application.mailServer = {
        server = "smtp-mail.outlook.com",
        port = 587,
        username = "your-email@outlook.com",
        password = "your-password",
        useSSL = false,
        useTLS = true
    }>
    --->
    
    <cfset application.mailConfigured = true>
</cfif>
