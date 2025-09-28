<cfcomponent displayname="Product Service" output="false">

    <cffunction name="init" returntype="ProductService" access="public" output="false">
        <!--- Use the application-scoped dataService --->
        <cfset variables.dataService = application.dataService>
        <cfset variables.ratingOrder = ["E", "D", "C", "B", "A"]><!--- Worst to Best --->
        
        <cfreturn this>
    </cffunction>
    
    <cffunction name="searchProducts" returntype="struct" access="public" output="false">
        <cfargument name="searchParams" type="struct" required="true">
        
        <cftry>
            <cfset var query = {}>
            <cfset var options = {
                "limit": 20,
                "skip": 0
            }>
            
            <cfif structKeyExists(arguments.searchParams, "limit")>
                <cfset options.limit = arguments.searchParams.limit>
            </cfif>
            <cfif structKeyExists(arguments.searchParams, "skip")>
                <cfset options.skip = arguments.searchParams.skip>
            </cfif>
            
            <!--- Build search query --->
            <cfif structKeyExists(arguments.searchParams, "keyword") AND len(arguments.searchParams.keyword) GT 0>
                <!--- Text search simulation --->
                <cfset query.searchTerm = arguments.searchParams.keyword>
            </cfif>
            
            <cfif structKeyExists(arguments.searchParams, "category") AND len(arguments.searchParams.category) GT 0>
                <cfset query.category = arguments.searchParams.category>
            </cfif>
            
            <cfif structKeyExists(arguments.searchParams, "rating") AND len(arguments.searchParams.rating) GT 0>
                <cfset query.rating = arguments.searchParams.rating>
            </cfif>
            
            <!--- Get products from data store --->
            <cfset var productsResult = variables.dataService.executeQuery(
                collection = "products",
                operation = "find",
                query = query,
                options = options
            )>
            
            <cfif productsResult.success>
                <cfset var products = productsResult.data>
                
                <!--- Filter by keyword if provided (simple text matching) --->
                <cfif structKeyExists(arguments.searchParams, "keyword") AND len(arguments.searchParams.keyword) GT 0>
                    <cfset products = filterByKeyword(products, arguments.searchParams.keyword)>
                </cfif>
                
                <!--- Generate suggestions for each product --->
                <cfloop from="1" to="#arrayLen(products)#" index="i">
                    <cfset products[i].suggestions = getSuggestions(products[i])>
                </cfloop>
                
                <cfreturn {
                    "success": true,
                    "products": products,
                    "total": arrayLen(products)
                }>
            <cfelse>
                <cfreturn {
                    "success": false,
                    "error": "Failed to search products"
                }>
            </cfif>
            
            <cfcatch type="any">
                <cflog file="products" text="Search error: #cfcatch.message# - #cfcatch.detail#" type="error">
                <cfreturn {
                    "success": false,
                    "error": "Search failed: #cfcatch.message#",
                    "detail": cfcatch.detail,
                    "type": cfcatch.type
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="getProduct" returntype="struct" access="public" output="false">
        <cfargument name="productId" type="string" required="true">
        
        <cftry>
            <cfset var productResult = variables.dataService.executeQuery(
                collection = "products",
                operation = "findOne",
                query = {"_id": arguments.productId}
            )>
            
            <cfif productResult.success AND structCount(productResult.data) GT 0>
                <cfset var product = productResult.data>
                <cfset product.suggestions = getSuggestions(product)>
                
                <cfreturn {
                    "success": true,
                    "product": product
                }>
            <cfelse>
                <cfreturn {
                    "success": false,
                    "error": "Product not found"
                }>
            </cfif>
            
            <cfcatch type="any">
                <cflog file="products" text="Get product error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "error": "Failed to retrieve product"
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="getSuggestions" returntype="struct" access="public" output="false">
        <cfargument name="product" type="struct" required="true">
        
        <cftry>
            <cfset var suggestions = {
                "better": [],
                "best": []
            }>
            
            <cfset var currentRating = arguments.product.rating>
            <cfset var category = arguments.product.category>
            
            <!--- Find current rating position --->
            <cfset var currentIndex = arrayFind(variables.ratingOrder, currentRating)>
            
            <cfif currentIndex GT 0>
                <!--- Get better products (next rating up) --->
                <cfif currentIndex LT arrayLen(variables.ratingOrder)>
                    <cfset var betterRating = variables.ratingOrder[currentIndex + 1]>
                    <cfset suggestions.better = findProductsByRating(category, betterRating, arguments.product._id)>
                </cfif>
                
                <!--- Get best products (A rating) --->
                <cfif currentRating NEQ "A">
                    <cfset suggestions.best = findProductsByRating(category, "A", arguments.product._id)>
                </cfif>
            </cfif>
            
            <cfreturn suggestions>
            
            <cfcatch type="any">
                <cflog file="products" text="Get suggestions error: #cfcatch.message#" type="error">
                <cfreturn {
                    "better": [],
                    "best": []
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="findProductsByRating" returntype="array" access="private" output="false">
        <cfargument name="category" type="string" required="true">
        <cfargument name="rating" type="string" required="true">
        <cfargument name="excludeId" type="string" required="false" default="">
        
        <cftry>
            <cfset var query = {
                "category": arguments.category,
                "rating": arguments.rating
            }>
            
            <cfset var productsResult = variables.dataService.executeQuery(
                collection = "products",
                operation = "find",
                query = query,
                options = {"limit": 5}
            )>
            
            <cfif productsResult.success>
                <cfset var products = productsResult.data>
                <cfset var filteredProducts = []>
                
                <!--- Exclude the current product --->
                <cfloop array="#products#" index="product">
                    <cfif product._id NEQ arguments.excludeId>
                        <cfset arrayAppend(filteredProducts, product)>
                    </cfif>
                </cfloop>
                
                <cfreturn filteredProducts>
            <cfelse>
                <cfreturn []>
            </cfif>
            
            <cfcatch type="any">
                <cflog file="products" text="Find by rating error: #cfcatch.message#" type="error">
                <cfreturn []>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="filterByKeyword" returntype="array" access="private" output="false">
        <cfargument name="products" type="array" required="true">
        <cfargument name="keyword" type="string" required="true">
        
        <cfset var filteredProducts = []>
        <cfset var searchTerm = lcase(arguments.keyword)>
        
        <cfloop array="#arguments.products#" index="product">
            <cfset var matches = false>
            
            <!--- Check product name --->
            <cfif findNoCase(searchTerm, product.name) GT 0>
                <cfset matches = true>
            </cfif>
            
            <!--- Check brand --->
            <cfif NOT matches AND structKeyExists(product, "brand") AND findNoCase(searchTerm, product.brand) GT 0>
                <cfset matches = true>
            </cfif>
            
            <!--- Check description --->
            <cfif NOT matches AND structKeyExists(product, "description") AND findNoCase(searchTerm, product.description) GT 0>
                <cfset matches = true>
            </cfif>
            
            <!--- Check category --->
            <cfif NOT matches AND findNoCase(searchTerm, product.category) GT 0>
                <cfset matches = true>
            </cfif>
            
            <cfif matches>
                <cfset arrayAppend(filteredProducts, product)>
            </cfif>
        </cfloop>
        
        <cfreturn filteredProducts>
    </cffunction>
    
    <cffunction name="addProduct" returntype="struct" access="public" output="false">
        <cfargument name="productData" type="struct" required="true">
        <cfargument name="userId" type="string" required="true">
        
        <cftry>
            <!--- Validate required fields --->
            <cfset var requiredFields = ["name", "brand", "category", "rating"]>
            
            <cfloop array="#requiredFields#" index="field">
                <cfif NOT structKeyExists(arguments.productData, field) OR len(arguments.productData[field]) EQ 0>
                    <cfreturn {
                        "success": false,
                        "error": "Missing required field: #field#"
                    }>
                </cfif>
            </cfloop>
            
            <!--- Validate rating --->
            <cfif NOT arrayFind(variables.ratingOrder, arguments.productData.rating)>
                <cfreturn {
                    "success": false,
                    "error": "Invalid rating. Must be A, B, C, D, or E"
                }>
            </cfif>
            
            <!--- Create product document --->
            <cfset var newProduct = duplicate(arguments.productData)>
            <cfset newProduct.createdAt = dateTimeFormat(now(), "iso8601")>
            <cfset newProduct.updatedAt = dateTimeFormat(now(), "iso8601")>
            <cfset newProduct.createdBy = arguments.userId>
            
            <!--- Set default values --->
            <cfif NOT structKeyExists(newProduct, "description")>
                <cfset newProduct.description = "">
            </cfif>
            
            <cfif NOT structKeyExists(newProduct, "price")>
                <cfset newProduct.price = 0>
            </cfif>
            
            <!--- Insert product --->
            <cfset var insertResult = variables.dataService.executeQuery(
                collection = "products",
                operation = "insert",
                data = newProduct
            )>
            
            <cfif insertResult.success>
                <cfreturn {
                    "success": true,
                    "message": "Product added successfully",
                    "product": insertResult.data
                }>
            <cfelse>
                <cfreturn {
                    "success": false,
                    "error": "Failed to add product"
                }>
            </cfif>
            
            <cfcatch type="any">
                <cflog file="products" text="Add product error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "error": "Failed to add product"
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="getCategories" returntype="struct" access="public" output="false">
        <cftry>
            <cfset var categoriesResult = variables.dataService.executeQuery(
                collection = "categories",
                operation = "find",
                query = {}
            )>
            
            <cfif categoriesResult.success>
                <cfreturn {
                    "success": true,
                    "categories": categoriesResult.data
                }>
            <cfelse>
                <!--- Return default categories if data service call fails --->
                <cfreturn {
                    "success": true,
                    "categories": [
                        {"name": "protein_powder", "displayName": "Protein Powder"},
                        {"name": "chips", "displayName": "Chips"},
                        {"name": "chocolates", "displayName": "Chocolates"},
                        {"name": "popcorn", "displayName": "Popcorn"},
                        {"name": "biscuits", "displayName": "Biscuits"}
                    ]
                }>
            </cfif>
            
            <cfcatch type="any">
                <cflog file="products" text="Get categories error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "error": "Failed to get categories"
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="getRatings" returntype="struct" access="public" output="false">
        <cftry>
            <cfreturn {
                "success": true,
                "ratings": [
                    {"code": "A", "name": "Best", "color": "##4CAF50"},
                    {"code": "B", "name": "Better", "color": "##8BC34A"},
                    {"code": "C", "name": "Good", "color": "##FFC107"},
                    {"code": "D", "name": "Bad", "color": "##FF9800"},
                    {"code": "E", "name": "Worst", "color": "##F44336"}
                ]
            }>
            
            <cfcatch type="any">
                <cflog file="products" text="Get ratings error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "error": "Failed to get ratings"
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="updateProduct" returntype="struct" access="public" output="false">
        <cfargument name="productId" type="string" required="true">
        <cfargument name="productData" type="struct" required="true">
        <cfargument name="userId" type="string" required="true">
        
        <cftry>
            <!--- First check if product exists --->
            <cfset var existingProduct = getProduct(arguments.productId)>
            <cfif NOT existingProduct.success>
                <cfreturn {
                    "success": false,
                    "error": "Product not found"
                }>
            </cfif>
            
            <!--- Validate rating if provided --->
            <cfif structKeyExists(arguments.productData, "rating") AND NOT arrayFind(variables.ratingOrder, arguments.productData.rating)>
                <cfreturn {
                    "success": false,
                    "error": "Invalid rating. Must be A, B, C, D, or E"
                }>
            </cfif>
            
            <!--- Create update document --->
            <cfset var updateData = duplicate(arguments.productData)>
            <cfset updateData.updatedAt = dateTimeFormat(now(), "iso8601")>
            <cfset updateData.updatedBy = arguments.userId>
            
            <!--- Update product --->
            <cfset var updateResult = variables.dataService.executeQuery(
                collection = "products",
                operation = "update",
                query = {"_id": arguments.productId},
                data = updateData
            )>
            
            <cfif updateResult.success>
                <!--- Get updated product --->
                <cfset var updatedProduct = getProduct(arguments.productId)>
                <cfreturn {
                    "success": true,
                    "message": "Product updated successfully",
                    "product": updatedProduct.success ? updatedProduct.product : {}
                }>
            <cfelse>
                <cfreturn {
                    "success": false,
                    "error": "Failed to update product"
                }>
            </cfif>
            
            <cfcatch type="any">
                <cflog file="products" text="Update product error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "error": "Failed to update product"
                }>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="deleteProduct" returntype="struct" access="public" output="false">
        <cfargument name="productId" type="string" required="true">
        <cfargument name="userId" type="string" required="true">
        
        <cftry>
            <!--- First check if product exists --->
            <cfset var existingProduct = getProduct(arguments.productId)>
            <cfif NOT existingProduct.success>
                <cfreturn {
                    "success": false,
                    "error": "Product not found"
                }>
            </cfif>
            
            <!--- Delete product --->
            <cfset var deleteResult = variables.dataService.executeQuery(
                collection = "products",
                operation = "delete",
                query = {"_id": arguments.productId}
            )>
            
            <cfif deleteResult.success>
                <cfreturn {
                    "success": true,
                    "message": "Product deleted successfully"
                }>
            <cfelse>
                <cfreturn {
                    "success": false,
                    "error": "Failed to delete product"
                }>
            </cfif>
            
            <cfcatch type="any">
                <cflog file="products" text="Delete product error: #cfcatch.message#" type="error">
                <cfreturn {
                    "success": false,
                    "error": "Failed to delete product"
                }>
            </cfcatch>
        </cftry>
    </cffunction>

    <!--- Chart Statistics Methods --->
    <cffunction name="getRatingStatistics" returntype="query" access="public" output="false">
        <cftry>
            <!--- Get all products --->
            <cfset var result = variables.dataService.executeQuery(
                collection = "products",
                operation = "find",
                query = {}
            )>
            
            <cfif NOT result.success>
                <cfthrow type="ProductService.Statistics" message="Failed to retrieve products" detail="#result.error#">
            </cfif>
            
            <!--- Process data to calculate rating statistics --->
            <cfset var ratingCounts = {}>
            <cfloop array="#result.data#" index="product">
                <cfif structKeyExists(product, "rating") AND len(product.rating)>
                    <cfif NOT structKeyExists(ratingCounts, product.rating)>
                        <cfset ratingCounts[product.rating] = 0>
                    </cfif>
                    <cfset ratingCounts[product.rating] = ratingCounts[product.rating] + 1>
                </cfif>
            </cfloop>
            
            <!--- Convert to query for chart compatibility --->
            <cfset var statsQuery = queryNew("rating,count", "varchar,integer")>
            <cfloop collection="#ratingCounts#" item="rating">
                <cfset queryAddRow(statsQuery)>
                <cfset querySetCell(statsQuery, "rating", rating)>
                <cfset querySetCell(statsQuery, "count", ratingCounts[rating])>
            </cfloop>
            
            <cfreturn statsQuery>
        <cfcatch type="any">
            <cfthrow type="ProductService.Statistics" message="Failed to get rating statistics" detail="#cfcatch.message#">
        </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="getCategoryStatistics" returntype="query" access="public" output="false">
        <cftry>
            <!--- Get all products --->
            <cfset var result = variables.dataService.executeQuery(
                collection = "products",
                operation = "find",
                query = {}
            )>
            
            <cfif NOT result.success>
                <cfthrow type="ProductService.Statistics" message="Failed to retrieve products" detail="#result.error#">
            </cfif>
            
            <!--- Process data to calculate category statistics --->
            <cfset var categoryCounts = {}>
            <cfloop array="#result.data#" index="product">
                <cfif structKeyExists(product, "category") AND len(product.category)>
                    <cfif NOT structKeyExists(categoryCounts, product.category)>
                        <cfset categoryCounts[product.category] = 0>
                    </cfif>
                    <cfset categoryCounts[product.category] = categoryCounts[product.category] + 1>
                </cfif>
            </cfloop>
            
            <!--- Convert to query and sort by count DESC --->
            <cfset var statsQuery = queryNew("category,count", "varchar,integer")>
            <cfloop collection="#categoryCounts#" item="category">
                <cfset queryAddRow(statsQuery)>
                <cfset querySetCell(statsQuery, "category", category)>
                <cfset querySetCell(statsQuery, "count", categoryCounts[category])>
            </cfloop>
            
            <cfreturn statsQuery>
        <cfcatch type="any">
            <cfthrow type="ProductService.Statistics" message="Failed to get category statistics" detail="#cfcatch.message#">
        </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="getPriceRangeStatistics" returntype="query" access="public" output="false">
        <cftry>
            <!--- Get all products --->
            <cfset var result = variables.dataService.executeQuery(
                collection = "products",
                operation = "find",
                query = {}
            )>
            
            <cfif NOT result.success>
                <cfthrow type="ProductService.Statistics" message="Failed to retrieve products" detail="#result.error#">
            </cfif>
            
            <!--- Process data to calculate price range statistics --->
            <cfset var priceRangeCounts = {
                "$0-5": 0,
                "$5-10": 0,
                "$10-15": 0,
                "$15-20": 0,
                "$20+": 0
            }>
            
            <cfloop array="#result.data#" index="product">
                <cfif structKeyExists(product, "price") AND isNumeric(product.price)>
                    <cfset var price = product.price>
                    <cfif price LT 5>
                        <cfset priceRangeCounts["$0-5"] = priceRangeCounts["$0-5"] + 1>
                    <cfelseif price LT 10>
                        <cfset priceRangeCounts["$5-10"] = priceRangeCounts["$5-10"] + 1>
                    <cfelseif price LT 15>
                        <cfset priceRangeCounts["$10-15"] = priceRangeCounts["$10-15"] + 1>
                    <cfelseif price LT 20>
                        <cfset priceRangeCounts["$15-20"] = priceRangeCounts["$15-20"] + 1>
                    <cfelse>
                        <cfset priceRangeCounts["$20+"] = priceRangeCounts["$20+"] + 1>
                    </cfif>
                </cfif>
            </cfloop>
            
            <!--- Convert to query in proper order --->
            <cfset var statsQuery = queryNew("price_range,count", "varchar,integer")>
            <cfset var ranges = ["$0-5", "$5-10", "$10-15", "$15-20", "$20+"]>
            <cfloop array="#ranges#" index="range">
                <cfset queryAddRow(statsQuery)>
                <cfset querySetCell(statsQuery, "price_range", range)>
                <cfset querySetCell(statsQuery, "count", priceRangeCounts[range])>
            </cfloop>
            
            <cfreturn statsQuery>
        <cfcatch type="any">
            <cfthrow type="ProductService.Statistics" message="Failed to get price range statistics" detail="#cfcatch.message#">
        </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="getTopRatedProducts" returntype="query" access="public" output="false">
        <cftry>
            <!--- Get all products --->
            <cfset var result = variables.dataService.executeQuery(
                collection = "products",
                operation = "find",
                query = {}
            )>
            
            <cfif NOT result.success>
                <cfthrow type="ProductService.Statistics" message="Failed to retrieve products" detail="#result.error#">
            </cfif>
            
            <!--- Filter and sort top rated products --->
            <cfset var topRatedProducts = []>
            <cfloop array="#result.data#" index="product">
                <cfif structKeyExists(product, "rating") AND listFindNoCase("A,B", product.rating)>
                    <cfset arrayAppend(topRatedProducts, product)>
                </cfif>
            </cfloop>
            
            <!--- Sort by rating (A first, then B), then by name, limit to 10 --->
            <cfset var statsQuery = queryNew("name,brand,rating", "varchar,varchar,varchar")>
            <cfset var count = 0>
            
            <!--- Add A-rated products first --->
            <cfloop array="#topRatedProducts#" index="product">
                <cfif product.rating EQ "A" AND count LT 10>
                    <cfset queryAddRow(statsQuery)>
                    <cfset querySetCell(statsQuery, "name", product.name)>
                    <cfset querySetCell(statsQuery, "brand", product.brand)>
                    <cfset querySetCell(statsQuery, "rating", product.rating)>
                    <cfset count = count + 1>
                </cfif>
            </cfloop>
            
            <!--- Add B-rated products if space remains --->
            <cfloop array="#topRatedProducts#" index="product">
                <cfif product.rating EQ "B" AND count LT 10>
                    <cfset queryAddRow(statsQuery)>
                    <cfset querySetCell(statsQuery, "name", product.name)>
                    <cfset querySetCell(statsQuery, "brand", product.brand)>
                    <cfset querySetCell(statsQuery, "rating", product.rating)>
                    <cfset count = count + 1>
                </cfif>
            </cfloop>
            
            <cfreturn statsQuery>
        <cfcatch type="any">
            <cfthrow type="ProductService.Statistics" message="Failed to get top rated products" detail="#cfcatch.message#">
        </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="getCategoryRatingStatistics" returntype="query" access="public" output="false">
        <cfargument name="category" type="string" required="true">
        <cftry>
            <!--- Get products in the specified category --->
            <cfset var result = variables.dataService.executeQuery(
                collection = "products",
                operation = "find",
                query = {"category": arguments.category}
            )>
            
            <cfif NOT result.success>
                <cfthrow type="ProductService.Statistics" message="Failed to retrieve products for category" detail="#result.error#">
            </cfif>
            
            <!--- Process data to calculate rating statistics for this category --->
            <cfset var ratingCounts = {}>
            <cfloop array="#result.data#" index="product">
                <cfif structKeyExists(product, "rating") AND len(product.rating)>
                    <cfif NOT structKeyExists(ratingCounts, product.rating)>
                        <cfset ratingCounts[product.rating] = 0>
                    </cfif>
                    <cfset ratingCounts[product.rating] = ratingCounts[product.rating] + 1>
                </cfif>
            </cfloop>
            
            <!--- Convert to query for chart compatibility --->
            <cfset var statsQuery = queryNew("rating,count", "varchar,integer")>
            <cfloop collection="#ratingCounts#" item="rating">
                <cfset queryAddRow(statsQuery)>
                <cfset querySetCell(statsQuery, "rating", rating)>
                <cfset querySetCell(statsQuery, "count", ratingCounts[rating])>
            </cfloop>
            
            <cfreturn statsQuery>
        <cfcatch type="any">
            <cfthrow type="ProductService.Statistics" message="Failed to get category rating statistics" detail="#cfcatch.message#">
        </cfcatch>
        </cftry>
    </cffunction>

</cfcomponent>