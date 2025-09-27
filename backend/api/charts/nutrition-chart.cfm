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

    <!--- Get product ID from URL parameter ----->
    <cfparam name="url.productId" default="">
    
    <!--- Validate product ID ----->
    <cfif NOT len(url.productId) OR NOT isNumeric(url.productId)>
        <!--- Use default product ID of 1 instead of returning error ----->
        <cfset url.productId = 1>
    </cfif>
</cfsilent>

<cftry>
    <!--- Set content type for PNG image --->
    <cfheader name="Content-Type" value="image/png">
    
    <!--- Use productId parameter or default to "biscuit2" --->
    <cfset productId = len(url.productId) ? url.productId : "biscuit2">
    
    <!--- Get sample product with nutrition data from MySQL database --->
    <cfquery name="productInfo" datasource="nutriapp">
        SELECT name, brand, nutrition_facts 
        FROM products 
        WHERE nutrition_facts IS NOT NULL 
        LIMIT 1
    </cfquery>
    
    <cfif productInfo.recordCount EQ 0>
        <cfheader statuscode="404" statustext="Not Found">
        <cfheader name="Content-Type" value="text/plain">
        <cfoutput>No products with nutrition data found</cfoutput>
        <cfabort>
    </cfif>
    
    <!--- Get product name and brand --->
    <cfset productName = productInfo.name>
    <cfset brandName = len(productInfo.brand) ? " (" & productInfo.brand & ")" : "">
    
    <!--- Parse nutrition facts JSON or create default data --->
    <cfset nutritionData = []>
    <cftry>
        <cfif len(productInfo.nutrition_facts)>
            <cfset nutritionJson = deserializeJSON(productInfo.nutrition_facts)>
            
            <!--- Convert JSON to array format for chart --->
            <cfif structKeyExists(nutritionJson, "calories") AND isNumeric(nutritionJson.calories)>
                <cfset arrayAppend(nutritionData, {item: "Calories", value: nutritionJson.calories})>
            </cfif>
            <cfif structKeyExists(nutritionJson, "protein") AND isNumeric(nutritionJson.protein)>
                <cfset arrayAppend(nutritionData, {item: "Protein (g)", value: nutritionJson.protein})>
            </cfif>
            <cfif structKeyExists(nutritionJson, "carbs") AND isNumeric(nutritionJson.carbs)>
                <cfset arrayAppend(nutritionData, {item: "Carbs (g)", value: nutritionJson.carbs})>
            </cfif>
            <cfif structKeyExists(nutritionJson, "fat") AND isNumeric(nutritionJson.fat)>
                <cfset arrayAppend(nutritionData, {item: "Fat (g)", value: nutritionJson.fat})>
            </cfif>
            <cfif structKeyExists(nutritionJson, "fiber") AND isNumeric(nutritionJson.fiber)>
                <cfset arrayAppend(nutritionData, {item: "Fiber (g)", value: nutritionJson.fiber})>
            </cfif>
            <cfif structKeyExists(nutritionJson, "sugar") AND isNumeric(nutritionJson.sugar)>
                <cfset arrayAppend(nutritionData, {item: "Sugar (g)", value: nutritionJson.sugar})>
            </cfif>
        </cfif>
        
        <!--- If no nutrition data found, create a basic chart with product info --->
        <cfif arrayLen(nutritionData) EQ 0>
            <cfset arrayAppend(nutritionData, {item: "No Nutrition Data", value: 0})>
        </cfif>
        
        <cfcatch type="any">
            <!--- Fallback data if JSON parsing fails --->
            <cfset arrayAppend(nutritionData, {item: "Data Parse Error", value: 0})>
        </cfcatch>
    </cftry>
    
    <!--- Generate chart and capture binary data --->
    <cfchart format="png" chartwidth="900" chartheight="700" 
             title="Nutrition Facts - #productName##brandName#"
             backgroundcolor="##ffffff" databackgroundcolor="##f8f9fa" showlegend="no"
             name="chartData">
        <cfchartseries type="bar" seriescolor="##17a2b8">
            <cfloop array="#nutritionData#" index="nutrient">
                <cfchartdata item="#nutrient.item#" value="#nutrient.value#">
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