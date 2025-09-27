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
    
    <!--- Get real price data from MySQL database and categorize into ranges --->
    <cfquery name="priceStats" datasource="nutriapp">
        SELECT price_range, COUNT(*) as count
        FROM (
            SELECT 
                CASE 
                    WHEN price < 100 THEN 'Under ₹100'
                    WHEN price < 200 THEN '₹100-200'
                    WHEN price < 300 THEN '₹200-300'
                    WHEN price < 500 THEN '₹300-500'
                    ELSE '₹500+'
                END as price_range
            FROM products 
            WHERE price IS NOT NULL 
        ) as price_categories
        GROUP BY price_range
        ORDER BY 
            CASE price_range
                WHEN 'Under ₹100' THEN 1
                WHEN '₹100-200' THEN 2
                WHEN '₹200-300' THEN 3
                WHEN '₹300-500' THEN 4
                WHEN '₹500+' THEN 5
            END
    </cfquery>
    
    <!--- Convert query to array for chart processing --->
    <cfset priceData = []>
    <cfloop query="priceStats">
        <cfset arrayAppend(priceData, {
            range: priceStats.price_range,
            count: priceStats.count
        })>
    </cfloop>
    
    <!--- Generate chart and capture binary data --->
    <cfchart format="png" chartwidth="800" chartheight="600" title="Product Price Range Distribution"
             backgroundcolor="##ffffff" databackgroundcolor="##f8f9fa" showlegend="no"
             name="chartData">
        <cfchartseries type="bar" seriescolor="##ffc107">
            <cfloop array="#priceData#" index="price">
                <cfchartdata item="#price.range# (#price.count# products)" value="#price.count#">
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
