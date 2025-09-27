<!--- NutriApp Backend API - Main Index --->

<cfset response = {
    "success": true,
    "message": "NutriApp Backend API is running",
    "version": "1.0.0",
    "timestamp": dateTimeFormat(now(), "iso8601"),
    "endpoints": {
        "authentication": "/api/auth",
        "products": "/api/products"
    },
    "availableRoutes": [
        {
            "method": "POST",
            "path": "/api/auth/login",
            "description": "User login"
        },
        {
            "method": "POST", 
            "path": "/api/auth/register",
            "description": "User registration"
        },
        {
            "method": "POST",
            "path": "/api/auth/logout", 
            "description": "User logout"
        },
        {
            "method": "GET",
            "path": "/api/auth/validate",
            "description": "Validate session"
        },
        {
            "method": "GET",
            "path": "/api/auth/me",
            "description": "Get current user info"
        },
        {
            "method": "GET",
            "path": "/api/products",
            "description": "Get all products"
        },
        {
            "method": "GET",
            "path": "/api/products/search",
            "description": "Search products"
        },
        {
            "method": "GET",
            "path": "/api/products/{id}",
            "description": "Get product by ID"
        },
        {
            "method": "GET",
            "path": "/api/products/suggestions/{id}",
            "description": "Get product suggestions"
        },
        {
            "method": "GET",
            "path": "/api/products/categories",
            "description": "Get product categories"
        },
        {
            "method": "GET",
            "path": "/api/products/ratings",
            "description": "Get rating system"
        },
        {
            "method": "POST",
            "path": "/api/products",
            "description": "Add new product (admin only)"
        }
    ]
}>

<cfheader statuscode="200">
<cfoutput>#serializeJSON(response)#</cfoutput>