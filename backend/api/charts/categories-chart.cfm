<cfsilent>
    <cfheader name="Access-Control-Allow-Origin" value="http://localhost:3000">
    <cfheader name="Access-Control-Allow-Methods" value="GET,OPTIONS">
    <cfheader name="Access-Control-Allow-Headers" value="Content-Type,Authorization,X-Requested-With">
    <cfheader name="Access-Control-Max-Age" value="3600">

    <!--- Handle OPTIONS request for CORS ----->
    <cfif cgi.request_method EQ "OPTIONS">
        <cfabort>
    </cfif>

    <!--- Only allow GET requests ----->
    <cfif cgi.request_method NEQ "GET">
        <cfheader statuscode="405" statustext="Method Not Allowed">
        <cfheader name="Content-Type" value="application/json">
        <cfoutput>{"error": "Method not allowed. Only GET requests are supported."}</cfoutput>
        <cfabort>
    </cfif>
</cfsilent>

<cftry>
    <!--- Get real category data from MySQL database --->
    <cfquery name="categoryStats" datasource="nutriapp">
        SELECT category, COUNT(*) as count 
        FROM products 
        WHERE category IS NOT NULL 
        GROUP BY category 
        ORDER BY count DESC
    </cfquery>
    
    <!--- Convert query to array for chart processing --->
    <cfset categoryData = []>
    <cfloop query="categoryStats">
        <!--- Convert underscores to spaces and capitalize for display --->
        <cfset displayName = replace(categoryStats.category, "_", " ", "ALL")>
        <cfset displayName = uCase(left(displayName, 1)) & lCase(right(displayName, len(displayName)-1))>
        <cfset arrayAppend(categoryData, {
            category: displayName,
            count: categoryStats.count
        })>
    </cfloop>
    
    <!--- Generate chart and capture binary data --->
    <cfchart format="png" chartwidth="900" chartheight="600" title="Product Category Distribution"
             backgroundcolor="##ffffff" databackgroundcolor="##f8f9fa" showlegend="yes"
             name="chartData">
        <cfchartseries type="pie" seriescolor="##28a745">
            <cfloop array="#categoryData#" index="category">
                <cfchartdata item="#category.category# (#category.count# products)" value="#category.count#">
            </cfloop>
        </cfchartseries>
    </cfchart>
    
    <!--- Set content type and output binary data --->
    <cfheader name="Content-Type" value="image/png">
    <cfcontent type="image/png" variable="#chartData#">

<cfcatch type="any">
    <!--- If chart generation fails, create a simple error image --->
    <cfheader name="Content-Type" value="text/plain">
    <cfheader statuscode="500" statustext="Internal Server Error">
    <cfoutput>Chart generation failed: #cfcatch.message#</cfoutput>
</cfcatch>
</cftry>
