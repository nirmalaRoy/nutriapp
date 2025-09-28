# Nutri-Score Auto-Grading Implementation

## Overview
This document describes the implementation of automatic grade calculation using a simplified Nutri-Score formula. Product grades (A-E) are now automatically calculated based on nutritional data instead of being manually set.

## Implementation Details

### Formula Used
```
NegativePoints = CaloriesPoints + SugarPoints + FatPoints
PositivePoints = FiberPoints + ProteinPoints  
NutritionalScore = NegativePoints - PositivePoints

Grade = 
  "A" if NutritionalScore <= -1
  "B" if 0 <= NutritionalScore <= 2
  "C" if 3 <= NutritionalScore <= 10
  "D" if 11 <= NutritionalScore <= 18
  "E" if NutritionalScore >= 19
```

## Files Modified

### Backend Changes

#### 1. NutriScoreCalculator.cfc (NEW)
- **Location**: `backend/components/NutriScoreCalculator.cfc`
- **Purpose**: Implements Nutri-Score calculation logic
- **Key Methods**:
  - `calculateGrade(nutritionFacts)` - Main calculation method
  - `getScoreBreakdown(nutritionFacts)` - Detailed scoring for debugging

#### 2. products.cfm (MODIFIED)
- **Location**: `backend/api/products.cfm`
- **Changes**:
  - Added NutriScoreCalculator initialization
  - POST handler now calculates grades automatically
  - PUT handler recalculates grades on update
  - Removed manual rating input from API

#### 3. ProductService.cfc (MODIFIED)
- **Location**: `backend/components/ProductService.cfc`
- **Changes**:
  - Added NutriScoreCalculator integration
  - Removed `rating` from required fields validation
  - Auto-calculate grades in `addProduct()` and `updateProduct()` methods
  - Removed manual rating validation

#### 4. Database Migration Script (NEW)
- **Location**: `backend/database/recalculate_grades.sql`
- **Purpose**: Recalculates grades for existing products
- **Usage**: Run this script to update all existing products with calculated grades

### Frontend Changes

#### 1. AdminPanel.js (MODIFIED)
- **Location**: `frontend/src/pages/AdminPanel.js`
- **Changes**:
  - Removed `rating` from form state
  - Replaced rating dropdown with read-only display
  - Updated form validation to not require rating
  - Added visual indicators showing auto-calculation

#### 2. AdminPanel.css (MODIFIED)
- **Location**: `frontend/src/pages/AdminPanel.css`
- **Changes**:
  - Added styles for read-only rating fields
  - Styled auto-calculation indicators
  - Added help text styling

## How It Works

### For New Products:
1. User creates product with nutritional data
2. Backend automatically calculates grade using Nutri-Score formula
3. Grade is stored in database and returned to frontend
4. Frontend displays the calculated grade

### For Existing Products:
1. Run the migration script `recalculate_grades.sql` to update existing products
2. All future updates will recalculate grades automatically

### Grade Calculation Process:
1. **Extract Nutrition Values**: Calories, sugar, fat, fiber, protein from `nutritionFacts`
2. **Calculate Points**: Each nutrient gets points based on defined ranges
3. **Calculate Score**: NegativePoints - PositivePoints
4. **Determine Grade**: Based on final nutritional score ranges

## Point Calculation Details

### Negative Points (Higher is worse):
- **Calories**: 0-10 points (0-80 cal = 0pts, >800 cal = 10pts)
- **Sugar**: 0-10 points (0-4.5g = 0pts, >45g = 10pts)  
- **Fat**: 0-10 points (0-1g = 0pts, >10g = 10pts)

### Positive Points (Higher is better):
- **Fiber**: 0-5 points (0-0.9g = 0pts, >4.7g = 5pts)
- **Protein**: 0-5 points (0-1.6g = 0pts, >8g = 5pts)

## Migration Steps

1. **Backend**: Deploy updated `.cfm` and `.cfc` files
2. **Database**: Run `recalculate_grades.sql` to update existing products
3. **Frontend**: Deploy updated React components and styles
4. **Verification**: Check that grades display correctly and are not editable

## Benefits

- **Consistency**: All grades calculated using the same standardized formula
- **Objectivity**: Removes subjective manual grading
- **Automation**: No human intervention required for grade assignment
- **Transparency**: Users can see grades are based on actual nutritional data
- **Nutri-Score Compliance**: Uses established European nutritional scoring system

## Notes

- Products without nutritional data default to grade "E"
- Calculation errors also default to grade "E" for safety
- The frontend clearly indicates grades are auto-calculated
- Original Nutri-Score formula has been simplified for this implementation
- All nutritional values are expected to be per 100g serving
