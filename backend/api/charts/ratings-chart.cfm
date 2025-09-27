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
    <!--- Get real rating data from MySQL database --->
    <cfquery name="ratingStats" datasource="nutriapp">
        SELECT rating, COUNT(*) as count 
        FROM products 
        WHERE rating IS NOT NULL 
        GROUP BY rating 
        ORDER BY rating
    </cfquery>
    
    <!--- Convert query to array for chart processing --->
    <cfset ratingData = []>
    <cfloop query="ratingStats">
        <cfset arrayAppend(ratingData, {
            rating: ratingStats.rating,
            count: ratingStats.count
        })>
    </cfloop>
    
    <!--- Generate chart and capture binary data --->
    <cfchart format="png" chartwidth="800" chartheight="600" title="Product Rating Distribution" 
             backgroundcolor="##ffffff" databackgroundcolor="##f8f9fa" gridlines="10" 
             name="chartData">
        <cfchartseries type="pie" seriescolor="##007bff">
            <cfloop array="#ratingData#" index="rating">
                <cfchartdata item="Rating #rating.rating# (#rating.count# products)" value="#rating.count#">
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
