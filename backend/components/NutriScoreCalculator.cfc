<!--- 
    NutriScoreCalculator.cfc
    Implements simplified Nutri-Score calculation for automatic product grading
--->
<cfcomponent displayname="NutriScoreCalculator" hint="Calculates Nutri-Score based grades for products">
    
    <cffunction name="init" returntype="NutriScoreCalculator" access="public" output="false">
        <cfreturn this>
    </cffunction>
    
    <!--- 
        Calculate Nutri-Score grade based on nutritional data
        Formula:
        NegativePoints = CaloriesPoints + SugarPoints + FatPoints
        PositivePoints = FiberPoints + ProteinPoints
        NutritionalScore = NegativePoints - PositivePoints
        
        Grade mapping:
        A: NutritionalScore <= -1
        B: 0 <= NutritionalScore <= 2  
        C: 3 <= NutritionalScore <= 10
        D: 11 <= NutritionalScore <= 18
        E: NutritionalScore >= 19
    --->
    <cffunction name="calculateGrade" returntype="string" access="public" output="false">
        <cfargument name="nutritionFacts" type="struct" required="true">
        
        <cftry>
            <!--- Extract nutrition values with defaults --->
            <cfset var calories = structKeyExists(arguments.nutritionFacts, "calories") AND isNumeric(arguments.nutritionFacts.calories) ? arguments.nutritionFacts.calories : 0>
            <cfset var sugar = structKeyExists(arguments.nutritionFacts, "sugar") AND isNumeric(arguments.nutritionFacts.sugar) ? arguments.nutritionFacts.sugar : 0>
            <cfset var fat = structKeyExists(arguments.nutritionFacts, "fat") AND isNumeric(arguments.nutritionFacts.fat) ? arguments.nutritionFacts.fat : 0>
            <cfset var fiber = structKeyExists(arguments.nutritionFacts, "fiber") AND isNumeric(arguments.nutritionFacts.fiber) ? arguments.nutritionFacts.fiber : 0>
            <cfset var protein = structKeyExists(arguments.nutritionFacts, "protein") AND isNumeric(arguments.nutritionFacts.protein) ? arguments.nutritionFacts.protein : 0>
            
            <!--- Calculate negative points --->
            <cfset var caloriesPoints = getCaloriesPoints(calories)>
            <cfset var sugarPoints = getSugarPoints(sugar)>
            <cfset var fatPoints = getFatPoints(fat)>
            
            <!--- Calculate positive points --->
            <cfset var fiberPoints = getFiberPoints(fiber)>
            <cfset var proteinPoints = getProteinPoints(protein)>
            
            <!--- Calculate final score --->
            <cfset var negativePoints = caloriesPoints + sugarPoints + fatPoints>
            <cfset var positivePoints = fiberPoints + proteinPoints>
            <cfset var nutritionalScore = negativePoints - positivePoints>
            
            <!--- Determine grade --->
            <cfif nutritionalScore LTE -1>
                <cfreturn "A">
            <cfelseif nutritionalScore GTE 0 AND nutritionalScore LTE 2>
                <cfreturn "B">
            <cfelseif nutritionalScore GTE 3 AND nutritionalScore LTE 10>
                <cfreturn "C">
            <cfelseif nutritionalScore GTE 11 AND nutritionalScore LTE 18>
                <cfreturn "D">
            <cfelse>
                <cfreturn "E">
            </cfif>
            
        <cfcatch type="any">
            <!--- Default to E grade if calculation fails --->
            <cfreturn "E">
        </cfcatch>
        </cftry>
    </cffunction>
    
    <!--- Calculate calories points (per 100g) --->
    <cffunction name="getCaloriesPoints" returntype="numeric" access="private" output="false">
        <cfargument name="calories" type="numeric" required="true">
        
        <cfif arguments.calories LE 80>
            <cfreturn 0>
        <cfelseif arguments.calories LE 160>
            <cfreturn 1>
        <cfelseif arguments.calories LE 240>
            <cfreturn 2>
        <cfelseif arguments.calories LE 320>
            <cfreturn 3>
        <cfelseif arguments.calories LE 400>
            <cfreturn 4>
        <cfelseif arguments.calories LE 480>
            <cfreturn 5>
        <cfelseif arguments.calories LE 560>
            <cfreturn 6>
        <cfelseif arguments.calories LE 640>
            <cfreturn 7>
        <cfelseif arguments.calories LE 720>
            <cfreturn 8>
        <cfelseif arguments.calories LE 800>
            <cfreturn 9>
        <cfelse>
            <cfreturn 10>
        </cfif>
    </cffunction>
    
    <!--- Calculate sugar points (per 100g) --->
    <cffunction name="getSugarPoints" returntype="numeric" access="private" output="false">
        <cfargument name="sugar" type="numeric" required="true">
        
        <cfif arguments.sugar LE 4.5>
            <cfreturn 0>
        <cfelseif arguments.sugar LE 9>
            <cfreturn 1>
        <cfelseif arguments.sugar LE 13.5>
            <cfreturn 2>
        <cfelseif arguments.sugar LE 18>
            <cfreturn 3>
        <cfelseif arguments.sugar LE 22.5>
            <cfreturn 4>
        <cfelseif arguments.sugar LE 27>
            <cfreturn 5>
        <cfelseif arguments.sugar LE 31>
            <cfreturn 6>
        <cfelseif arguments.sugar LE 36>
            <cfreturn 7>
        <cfelseif arguments.sugar LE 40>
            <cfreturn 8>
        <cfelseif arguments.sugar LE 45>
            <cfreturn 9>
        <cfelse>
            <cfreturn 10>
        </cfif>
    </cffunction>
    
    <!--- Calculate fat points (per 100g) --->
    <cffunction name="getFatPoints" returntype="numeric" access="private" output="false">
        <cfargument name="fat" type="numeric" required="true">
        
        <cfif arguments.fat LE 1>
            <cfreturn 0>
        <cfelseif arguments.fat LE 2>
            <cfreturn 1>
        <cfelseif arguments.fat LE 3>
            <cfreturn 2>
        <cfelseif arguments.fat LE 4>
            <cfreturn 3>
        <cfelseif arguments.fat LE 5>
            <cfreturn 4>
        <cfelseif arguments.fat LE 6>
            <cfreturn 5>
        <cfelseif arguments.fat LE 7>
            <cfreturn 6>
        <cfelseif arguments.fat LE 8>
            <cfreturn 7>
        <cfelseif arguments.fat LE 9>
            <cfreturn 8>
        <cfelseif arguments.fat LE 10>
            <cfreturn 9>
        <cfelse>
            <cfreturn 10>
        </cfif>
    </cffunction>
    
    <!--- Calculate fiber points (per 100g) --->
    <cffunction name="getFiberPoints" returntype="numeric" access="private" output="false">
        <cfargument name="fiber" type="numeric" required="true">
        
        <cfif arguments.fiber LE 0.9>
            <cfreturn 0>
        <cfelseif arguments.fiber LE 1.9>
            <cfreturn 1>
        <cfelseif arguments.fiber LE 2.8>
            <cfreturn 2>
        <cfelseif arguments.fiber LE 3.7>
            <cfreturn 3>
        <cfelseif arguments.fiber LE 4.7>
            <cfreturn 4>
        <cfelse>
            <cfreturn 5>
        </cfif>
    </cffunction>
    
    <!--- Calculate protein points (per 100g) --->
    <cffunction name="getProteinPoints" returntype="numeric" access="private" output="false">
        <cfargument name="protein" type="numeric" required="true">
        
        <cfif arguments.protein LE 1.6>
            <cfreturn 0>
        <cfelseif arguments.protein LE 3.2>
            <cfreturn 1>
        <cfelseif arguments.protein LE 4.8>
            <cfreturn 2>
        <cfelseif arguments.protein LE 6.4>
            <cfreturn 3>
        <cfelseif arguments.protein LE 8.0>
            <cfreturn 4>
        <cfelse>
            <cfreturn 5>
        </cfif>
    </cffunction>
    
    <!--- 
        Get detailed scoring breakdown for debugging/display purposes
    --->
    <cffunction name="getScoreBreakdown" returntype="struct" access="public" output="false">
        <cfargument name="nutritionFacts" type="struct" required="true">
        
        <cftry>
            <!--- Extract nutrition values --->
            <cfset var calories = structKeyExists(arguments.nutritionFacts, "calories") AND isNumeric(arguments.nutritionFacts.calories) ? arguments.nutritionFacts.calories : 0>
            <cfset var sugar = structKeyExists(arguments.nutritionFacts, "sugar") AND isNumeric(arguments.nutritionFacts.sugar) ? arguments.nutritionFacts.sugar : 0>
            <cfset var fat = structKeyExists(arguments.nutritionFacts, "fat") AND isNumeric(arguments.nutritionFacts.fat) ? arguments.nutritionFacts.fat : 0>
            <cfset var fiber = structKeyExists(arguments.nutritionFacts, "fiber") AND isNumeric(arguments.nutritionFacts.fiber) ? arguments.nutritionFacts.fiber : 0>
            <cfset var protein = structKeyExists(arguments.nutritionFacts, "protein") AND isNumeric(arguments.nutritionFacts.protein) ? arguments.nutritionFacts.protein : 0>
            
            <!--- Calculate points --->
            <cfset var caloriesPoints = getCaloriesPoints(calories)>
            <cfset var sugarPoints = getSugarPoints(sugar)>
            <cfset var fatPoints = getFatPoints(fat)>
            <cfset var fiberPoints = getFiberPoints(fiber)>
            <cfset var proteinPoints = getProteinPoints(protein)>
            
            <!--- Calculate scores --->
            <cfset var negativePoints = caloriesPoints + sugarPoints + fatPoints>
            <cfset var positivePoints = fiberPoints + proteinPoints>
            <cfset var nutritionalScore = negativePoints - positivePoints>
            <cfset var grade = calculateGrade(arguments.nutritionFacts)>
            
            <cfreturn {
                "nutritionValues": {
                    "calories": calories,
                    "sugar": sugar,
                    "fat": fat,
                    "fiber": fiber,
                    "protein": protein
                },
                "points": {
                    "caloriesPoints": caloriesPoints,
                    "sugarPoints": sugarPoints,
                    "fatPoints": fatPoints,
                    "fiberPoints": fiberPoints,
                    "proteinPoints": proteinPoints
                },
                "scores": {
                    "negativePoints": negativePoints,
                    "positivePoints": positivePoints,
                    "nutritionalScore": nutritionalScore
                },
                "grade": grade
            }>
            
        <cfcatch type="any">
            <cfreturn {
                "error": "Failed to calculate score breakdown",
                "grade": "E"
            }>
        </cfcatch>
        </cftry>
    </cffunction>
    
</cfcomponent>
