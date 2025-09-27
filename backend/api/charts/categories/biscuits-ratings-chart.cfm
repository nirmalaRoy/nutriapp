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
    <!--- Set content type for PNG image --->
    <cfheader name="Content-Type" value="image/png">
    
    <!--- Set category to biscuits --->
    <cfset category = "biscuits">
    
    <!--- Get real category rating data from MySQL database --->
    <cfquery name="categoryRatingStats" datasource="nutriapp">
        SELECT rating, COUNT(*) as count 
        FROM products 
        WHERE category = <cfqueryparam value="#category#" cfsqltype="cf_sql_varchar">
          AND rating IS NOT NULL 
        GROUP BY rating 
        ORDER BY rating
    </cfquery>
    
    <cfif categoryRatingStats.recordCount EQ 0>
        <cfheader statuscode="404" statustext="Not Found">
        <cfheader name="Content-Type" value="text/plain">
        <cfoutput>No products found for biscuits category</cfoutput>
        <cfabort>
    </cfif>
    
    <!--- Convert query to array for chart processing --->
    <cfset categoryRatings = []>
    <cfloop query="categoryRatingStats">
        <cfset arrayAppend(categoryRatings, {
            rating: categoryRatingStats.rating,
            count: categoryRatingStats.count
        })>
    </cfloop>
    
    <!--- Generate chart and capture binary data --->
    <cfchart format="png" chartwidth="800" chartheight="600" 
             title="Rating Distribution for Biscuits"
             backgroundcolor="##ffffff" databackgroundcolor="##f8f9fa" showlegend="no"
             name="chartData">
        <cfchartseries type="bar" seriescolor="##007bff">
            <cfloop array="#categoryRatings#" index="rating">
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
