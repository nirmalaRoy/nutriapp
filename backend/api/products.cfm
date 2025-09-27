<!--- Direct MySQL Products API - Simplified --->
<!--- FINAL CORS Configuration - Single Headers Only --->
<cfcontent reset="true">
<cfheader name="Content-Type" value="application/json">
<cfheader name="Access-Control-Allow-Origin" value="http://localhost:3000">
<cfheader name="Access-Control-Allow-Methods" value="GET,POST,PUT,DELETE,OPTIONS">
<cfheader name="Access-Control-Allow-Headers" value="Content-Type,Authorization,X-Requested-With">
<cfheader name="Access-Control-Max-Age" value="3600">

<!--- Handle preflight OPTIONS request --->
<cfif cgi.request_method EQ "OPTIONS">
    <cfheader statuscode="200" statustext="OK">
    <cfabort>
</cfif>

<cfset response = {}>

<cftry>
    <!--- Direct MySQL query approach --->
    <cfif cgi.request_method EQ "GET">
        
        <!--- Check for pathInfo to handle different endpoints --->
        <cfset pathInfo = structKeyExists(url, "pathInfo") ? url.pathInfo : "">
        
        <!--- Handle categories endpoint --->
        <cfif pathInfo EQ "/categories">
            <cfquery name="categories" datasource="nutriapp">
                SELECT name, display_name, description, is_active 
                FROM categories 
                WHERE is_active = 1
                ORDER BY display_name
            </cfquery>
            
            <cfset categoryArray = []>
            <cfloop query="categories">
                <cfset category = {
                    "name": categories.name,
                    "displayName": categories.display_name,
                    "description": categories.description
                }>
                <cfset arrayAppend(categoryArray, category)>
            </cfloop>
            
            <cfset response = {
                "success": true,
                "categories": categoryArray
            }>
            
        <!--- Handle ratings endpoint --->
        <cfelseif pathInfo EQ "/ratings">
            <cfset ratingsArray = [
                {"code": "A", "name": "Excellent", "description": "Highly nutritious with minimal processing", "color": "##28a745"},
                {"code": "B", "name": "Good", "description": "Good nutritional value with some processing", "color": "##17a2b8"},
                {"code": "C", "name": "Fair", "description": "Moderate nutritional value", "color": "##ffc107"},
                {"code": "D", "name": "Poor", "description": "Limited nutritional value with high processing", "color": "##fd7e14"},
                {"code": "E", "name": "Very Poor", "description": "Highly processed with poor nutritional value", "color": "##dc3545"}
            ]>
            
            <cfset response = {
                "success": true,
                "ratings": ratingsArray
            }>
            
        <!--- Handle suggestions request --->
        <cfelseif pathInfo CONTAINS "/suggestions/" AND len(pathInfo) GT 13>
            <cfset productId = right(pathInfo, len(pathInfo) - 13)> <!--- Remove "/suggestions/" prefix --->
            
            <!--- First get the current product to determine its rating and category --->
            <cfquery name="currentProduct" datasource="nutriapp">
                SELECT id, name, brand, category, rating, description, ingredients, nutrition_facts, price, created_at 
                FROM products 
                WHERE id = <cfqueryparam value="#productId#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif currentProduct.recordCount EQ 1>
                <cfset currentRating = currentProduct.rating>
                <cfset currentCategory = currentProduct.category>
                
                <!--- Define rating hierarchy --->
                <cfset ratingHierarchy = ["E", "D", "C", "B", "A"]>
                <cfset currentRatingIndex = arrayFind(ratingHierarchy, currentRating)>
                
                <!--- Get better alternatives (higher rated products in same category) --->
                <cfset betterRatings = []>
                <cfloop from="#currentRatingIndex + 1#" to="#arrayLen(ratingHierarchy)#" index="i">
                    <cfset arrayAppend(betterRatings, ratingHierarchy[i])>
                </cfloop>
                
                <cfset betterProducts = []>
                <cfset bestProducts = []>
                
                <!--- Get better rated products if any exist --->
                <cfif arrayLen(betterRatings) GT 0>
                    <cfset ratingList = "'" & arrayToList(betterRatings, "','") & "'">
                    
                    <cfquery name="betterAlternatives" datasource="nutriapp">
                        SELECT id, name, brand, category, rating, description, ingredients, nutrition_facts, price, created_at 
                        FROM products 
                        WHERE category = <cfqueryparam value="#currentCategory#" cfsqltype="cf_sql_varchar">
                        AND rating IN (#preserveSingleQuotes(ratingList)#)
                        AND id != <cfqueryparam value="#productId#" cfsqltype="cf_sql_varchar">
                        ORDER BY 
                            FIELD(rating, 'A', 'B', 'C', 'D', 'E'),
                            name ASC
                        LIMIT 10
                    </cfquery>
                    
                    <cfloop query="betterAlternatives">
                        <cftry>
                            <cfset product = {
                                "_id": betterAlternatives.id,
                                "name": betterAlternatives.name,
                                "brand": betterAlternatives.brand,
                                "category": betterAlternatives.category,
                                "rating": betterAlternatives.rating,
                                "description": betterAlternatives.description,
                                "ingredients": isJSON(betterAlternatives.ingredients) ? deserializeJSON(betterAlternatives.ingredients) : [],
                                "nutritionFacts": isJSON(betterAlternatives.nutrition_facts) ? deserializeJSON(betterAlternatives.nutrition_facts) : {},
                                "price": betterAlternatives.price,
                                "createdAt": dateTimeFormat(betterAlternatives.created_at, "yyyy-mm-dd'T'HH:nn:ss.SSS'Z'")
                            }>
                            <cfset arrayAppend(betterProducts, product)>
                            <cfcatch type="any">
                                <!--- Continue if there's an error with one product --->
                            </cfcatch>
                        </cftry>
                    </cfloop>
                </cfif>
                
                <!--- Get all A-rated products in same category (for when current product is A-rated) --->
                <cfquery name="bestAlternatives" datasource="nutriapp">
                    SELECT id, name, brand, category, rating, description, ingredients, nutrition_facts, price, created_at 
                    FROM products 
                    WHERE category = <cfqueryparam value="#currentCategory#" cfsqltype="cf_sql_varchar">
                    AND rating = 'A'
                    ORDER BY name ASC
                    LIMIT 10
                </cfquery>
                
                <cfloop query="bestAlternatives">
                    <cftry>
                        <cfset product = {
                            "_id": bestAlternatives.id,
                            "name": bestAlternatives.name,
                            "brand": bestAlternatives.brand,
                            "category": bestAlternatives.category,
                            "rating": bestAlternatives.rating,
                            "description": bestAlternatives.description,
                            "ingredients": isJSON(bestAlternatives.ingredients) ? deserializeJSON(bestAlternatives.ingredients) : [],
                            "nutritionFacts": isJSON(bestAlternatives.nutrition_facts) ? deserializeJSON(bestAlternatives.nutrition_facts) : {},
                            "price": bestAlternatives.price,
                            "createdAt": dateTimeFormat(bestAlternatives.created_at, "yyyy-mm-dd'T'HH:nn:ss.SSS'Z'")
                        }>
                        <cfset arrayAppend(bestProducts, product)>
                        <cfcatch type="any">
                            <!--- Continue if there's an error with one product --->
                        </cfcatch>
                    </cftry>
                </cfloop>
                
                <cfset response = {
                    "success": true,
                    "suggestions": {
                        "better": betterProducts,
                        "best": bestProducts,
                        "currentRating": currentRating,
                        "currentCategory": currentCategory
                    }
                }>
            <cfelse>
                <cfset response = {
                    "success": false,
                    "error": "Product not found for suggestions"
                }>
                <cfheader statuscode="404">
            </cfif>
            
        <!--- Handle individual product request --->
        <cfelseif len(pathInfo) GT 1 AND left(pathInfo, 1) EQ "/" AND NOT pathInfo CONTAINS "/suggestions/">
            <cfset productId = right(pathInfo, len(pathInfo) - 1)>
            
            <cfquery name="singleProduct" datasource="nutriapp">
                SELECT id, name, brand, category, rating, description, ingredients, nutrition_facts, price, created_at 
                FROM products 
                WHERE id = <cfqueryparam value="#productId#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif singleProduct.recordCount EQ 1>
                <cfset product = {
                    "_id": singleProduct.id,
                    "name": singleProduct.name,
                    "brand": singleProduct.brand,
                    "category": singleProduct.category,
                    "rating": singleProduct.rating,
                    "description": singleProduct.description,
                    "ingredients": isJSON(singleProduct.ingredients) ? deserializeJSON(singleProduct.ingredients) : [],
                    "nutritionFacts": isJSON(singleProduct.nutrition_facts) ? deserializeJSON(singleProduct.nutrition_facts) : {},
                    "price": singleProduct.price,
                    "createdAt": dateTimeFormat(singleProduct.created_at, "yyyy-mm-dd'T'HH:nn:ss.SSS'Z'")
                }>
                
                <cfset response = {
                    "success": true,
                    "product": product
                }>
            <cfelse>
                <cfset response = {
                    "success": false,
                    "error": "Product not found"
                }>
                <cfheader statuscode="404">
            </cfif>
            
        <!--- Handle default product listing --->
        <cfelse>
        
        <!--- Get search parameters with defaults --->
        <cfset limit = structKeyExists(url, "limit") AND val(url.limit) GT 0 ? val(url.limit) : 50>
        <cfset skip = structKeyExists(url, "skip") AND val(url.skip) GT 0 ? val(url.skip) : 0>
        <cfset keyword = structKeyExists(url, "keyword") ? url.keyword : "">
        <cfset category = structKeyExists(url, "category") ? url.category : "">
        <cfset rating = structKeyExists(url, "rating") ? url.rating : "">
        
        <!--- Build SQL query using traditional approach --->
        <cfquery name="products" datasource="nutriapp">
            SELECT id, name, brand, category, rating, description, ingredients, nutrition_facts, price, created_at 
            FROM products 
            WHERE 1=1
            
            <cfif len(keyword)>
                AND (name LIKE <cfqueryparam value="%#keyword#%" cfsqltype="cf_sql_varchar">
                  OR brand LIKE <cfqueryparam value="%#keyword#%" cfsqltype="cf_sql_varchar">
                  OR description LIKE <cfqueryparam value="%#keyword#%" cfsqltype="cf_sql_varchar">)
            </cfif>
            
            <cfif len(category)>
                AND category = <cfqueryparam value="#category#" cfsqltype="cf_sql_varchar">
            </cfif>
            
            <cfif len(rating)>
                AND rating = <cfqueryparam value="#rating#" cfsqltype="cf_sql_varchar">
            </cfif>
            
            ORDER BY created_at DESC 
            LIMIT #limit# OFFSET #skip#
        </cfquery>
        
        <!--- Convert to array --->
        <cfset productArray = []>
        <cfloop query="products">
            <cftry>
                <cfset product = {
                    "_id": products.id,
                    "name": products.name,
                    "brand": products.brand,
                    "category": products.category,
                    "rating": products.rating,
                    "description": products.description,
                    "ingredients": isJSON(products.ingredients) ? deserializeJSON(products.ingredients) : [],
                    "nutritionFacts": isJSON(products.nutrition_facts) ? deserializeJSON(products.nutrition_facts) : {},
                    "price": products.price,
                    "createdAt": dateTimeFormat(products.created_at, "yyyy-mm-dd'T'HH:nn:ss.SSS'Z'")
                }>
                <cfset arrayAppend(productArray, product)>
                <cfcatch type="any">
                    <!--- Log error but continue with next product --->
                    <cflog file="products_api" text="Error processing product #products.id#: #cfcatch.message#" type="error">
                </cfcatch>
            </cftry>
        </cfloop>
        
        <!--- Get total count with same parameters as main query --->
        <cfquery name="totalCount" datasource="nutriapp">
            SELECT COUNT(*) as total 
            FROM products 
            WHERE 1=1
            
            <cfif len(keyword)>
                AND (name LIKE <cfqueryparam value="%#keyword#%" cfsqltype="cf_sql_varchar">
                  OR brand LIKE <cfqueryparam value="%#keyword#%" cfsqltype="cf_sql_varchar">
                  OR description LIKE <cfqueryparam value="%#keyword#%" cfsqltype="cf_sql_varchar">)
            </cfif>
            
            <cfif len(category)>
                AND category = <cfqueryparam value="#category#" cfsqltype="cf_sql_varchar">
            </cfif>
            
            <cfif len(rating)>
                AND rating = <cfqueryparam value="#rating#" cfsqltype="cf_sql_varchar">
            </cfif>
        </cfquery>
        
        <cfset response = {
            "success": true,
            "products": productArray,
            "total": totalCount.total,
            "limit": limit,
            "skip": skip,
            "source": "MySQL"
        }>
        
        </cfif> <!--- End of pathInfo conditional --->
        
    <!--- Handle POST request (Add Product) --->
    <cfelseif cgi.request_method EQ "POST">
        <cfset requestBody = getHttpRequestData().content>
        <cfset productData = deserializeJSON(requestBody)>
        
        <!--- Generate unique ID --->
        <cfset productId = replace(createUUID(), "-", "", "all")>
        
        <!--- Insert new product --->
        <cfquery name="insertProduct" datasource="nutriapp">
            INSERT INTO products (
                id, name, brand, category, rating, description, 
                ingredients, nutrition_facts, price, created_at, updated_at
            ) VALUES (
                <cfqueryparam value="#productId#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#productData.name#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#productData.brand#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#productData.category#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#productData.rating#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#structKeyExists(productData, 'description') ? productData.description : ''#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#structKeyExists(productData, 'ingredients') ? serializeJSON(productData.ingredients) : '[]'#" cfsqltype="cf_sql_longvarchar">,
                <cfqueryparam value="#structKeyExists(productData, 'nutritionFacts') ? serializeJSON(productData.nutritionFacts) : '{}'#" cfsqltype="cf_sql_longvarchar">,
                <cfqueryparam value="#structKeyExists(productData, 'price') ? productData.price : 0#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
            )
        </cfquery>
        
        <cfset response = {
            "success": true,
            "message": "Product added successfully",
            "product": {
                "_id": productId,
                "name": productData.name,
                "brand": productData.brand,
                "category": productData.category,
                "rating": productData.rating,
                "description": structKeyExists(productData, 'description') ? productData.description : "",
                "ingredients": structKeyExists(productData, 'ingredients') ? productData.ingredients : [],
                "nutritionFacts": structKeyExists(productData, 'nutritionFacts') ? productData.nutritionFacts : {},
                "price": structKeyExists(productData, 'price') ? productData.price : 0,
                "createdAt": dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss.SSS'Z'")
            }
        }>
        
    <!--- Handle PUT request (Update Product) --->
    <cfelseif cgi.request_method EQ "PUT">
        <cfset pathInfo = structKeyExists(url, "pathInfo") ? url.pathInfo : "">
        
        <!--- Extract product ID from path --->
        <cfif len(pathInfo) GT 1 AND left(pathInfo, 1) EQ "/">
            <cfset productId = right(pathInfo, len(pathInfo) - 1)>
            <cfset requestBody = getHttpRequestData().content>
            <cfset productData = deserializeJSON(requestBody)>
            
            <!--- First check if product exists --->
            <cfquery name="checkProductExists" datasource="nutriapp">
                SELECT id FROM products 
                WHERE id = <cfqueryparam value="#productId#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif checkProductExists.recordCount EQ 0>
                <cfset response = {
                    "success": false,
                    "error": "Product not found"
                }>
                <cfheader statuscode="404">
            <cfelse>
                <!--- Update product --->
                <cfquery name="updateProduct" datasource="nutriapp">
                    UPDATE products SET
                        name = <cfqueryparam value="#productData.name#" cfsqltype="cf_sql_varchar">,
                        brand = <cfqueryparam value="#productData.brand#" cfsqltype="cf_sql_varchar">,
                        category = <cfqueryparam value="#productData.category#" cfsqltype="cf_sql_varchar">,
                        rating = <cfqueryparam value="#productData.rating#" cfsqltype="cf_sql_varchar">,
                        description = <cfqueryparam value="#structKeyExists(productData, 'description') ? productData.description : ''#" cfsqltype="cf_sql_varchar">,
                        ingredients = <cfqueryparam value="#structKeyExists(productData, 'ingredients') ? serializeJSON(productData.ingredients) : '[]'#" cfsqltype="cf_sql_longvarchar">,
                        nutrition_facts = <cfqueryparam value="#structKeyExists(productData, 'nutritionFacts') ? serializeJSON(productData.nutritionFacts) : '{}'#" cfsqltype="cf_sql_longvarchar">,
                        price = <cfqueryparam value="#structKeyExists(productData, 'price') ? productData.price : 0#" cfsqltype="cf_sql_decimal">,
                        updated_at = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
                    WHERE id = <cfqueryparam value="#productId#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
                <cfset response = {
                    "success": true,
                    "message": "Product updated successfully",
                    "product": {
                        "_id": productId,
                        "name": productData.name,
                        "brand": productData.brand,
                        "category": productData.category,
                        "rating": productData.rating,
                        "description": structKeyExists(productData, 'description') ? productData.description : "",
                        "ingredients": structKeyExists(productData, 'ingredients') ? productData.ingredients : [],
                        "nutritionFacts": structKeyExists(productData, 'nutritionFacts') ? productData.nutritionFacts : {},
                        "price": structKeyExists(productData, 'price') ? productData.price : 0,
                        "updatedAt": dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss.SSS'Z'")
                    }
                }>
            </cfif>
        <cfelse>
            <cfset response = {
                "success": false,
                "error": "Product ID is required"
            }>
            <cfheader statuscode="400">
        </cfif>
        
    <!--- Handle DELETE request (Delete Product) --->
    <cfelseif cgi.request_method EQ "DELETE">
        <cfset pathInfo = structKeyExists(url, "pathInfo") ? url.pathInfo : "">
        
        <!--- Extract product ID from path --->
        <cfif len(pathInfo) GT 1 AND left(pathInfo, 1) EQ "/">
            <cfset productId = right(pathInfo, len(pathInfo) - 1)>
            
            <!--- Check if product exists before deleting --->
            <cfquery name="checkProduct" datasource="nutriapp">
                SELECT id, name FROM products 
                WHERE id = <cfqueryparam value="#productId#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif checkProduct.recordCount EQ 0>
                <cfset response = {
                    "success": false,
                    "error": "Product not found"
                }>
                <cfheader statuscode="404">
            <cfelse>
                <!--- Delete the product --->
                <cfquery name="deleteProduct" datasource="nutriapp">
                    DELETE FROM products 
                    WHERE id = <cfqueryparam value="#productId#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
                <cfset response = {
                    "success": true,
                    "message": "Product '#checkProduct.name#' deleted successfully"
                }>
            </cfif>
        <cfelse>
            <cfset response = {
                "success": false,
                "error": "Product ID is required"
            }>
            <cfheader statuscode="400">
        </cfif>
        
    <cfelse>
        <cfset response = {
            "success": false,
            "error": "Method not supported"
        }>
        <cfheader statuscode="405">
    </cfif>
    
    <cfcatch type="any">
        <cfset response = {
            "success": false,
            "error": "Database error: #cfcatch.message#",
            "detail": cfcatch.detail
        }>
        <cfheader statuscode="500">
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>