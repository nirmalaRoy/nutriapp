# Chart Endpoints Guide

## Overview
The Nutriapp backend now includes powerful CFML cfchart functionality that generates various data visualizations based on your product data. All chart endpoints return PNG images that can be displayed directly in web pages or downloaded.

## Available Chart Endpoints

### 1. Rating Distribution Chart
**Endpoint:** `GET http://localhost:8051/api/products.cfm/charts/ratings`
- **Description:** Shows the distribution of product ratings (A, B, C, D, E) as a pie chart
- **Returns:** PNG image (800x600)
- **Colors:** Rating-specific colors matching your UI theme

### 2. Category Distribution Chart
**Endpoint:** `GET http://localhost:8051/api/products.cfm/charts/categories`
- **Description:** Shows the distribution of products across categories as a pie chart
- **Returns:** PNG image (900x600)
- **Features:** Displays category names with underscores converted to spaces

### 3. Category Rating Distribution Chart
**Endpoint:** `GET /api/products.cfm/charts/category-ratings/{category}`
- **Description:** Shows rating distribution for a specific category as a bar chart
- **Parameters:** 
  - `{category}` - Category name (e.g., "protein_powder", "chips")
- **Returns:** PNG image (800x600)
- **Example:** `/api/products.cfm/charts/category-ratings/protein_powder`

### 4. Price Range Distribution Chart
**Endpoint:** `GET /api/products.cfm/charts/price-range`
- **Description:** Shows product distribution across price ranges as a bar chart
- **Price Ranges:** $0-5, $6-10, $11-20, $21-50, $50+, Not Specified
- **Returns:** PNG image (800x600)

### 5. Product Nutrition Chart
**Endpoint:** `GET /api/products.cfm/charts/nutrition/{productId}`
- **Description:** Shows nutrition facts for a specific product as a bar chart
- **Parameters:** 
  - `{productId}` - Product ID from database
- **Returns:** PNG image (900x700)
- **Displays:** Calories, Protein, Carbs, Fat, Fiber, Sugar, Sodium
- **Colors:** Each nutrient has a unique color for easy identification

### 6. Top Rated Products Chart
**Endpoint:** `GET /api/products.cfm/charts/top-rated`
- **Description:** Shows top 10 products with A & B ratings as a horizontal bar chart
- **Returns:** PNG image (1000x600)
- **Features:** Products sorted by rating (A first) then alphabetically

### 7. Chart List Endpoint
**Endpoint:** `GET /api/products.cfm/charts/`
- **Description:** Returns JSON list of all available chart endpoints
- **Returns:** JSON with available chart information

## Usage Examples

### Basic Usage
```html
<!-- Display rating distribution chart -->
<img src="http://localhost:8500/api/products.cfm/charts/ratings" 
     alt="Rating Distribution" 
     style="max-width: 100%; height: auto;">

<!-- Display category distribution -->
<img src="http://localhost:8500/api/products.cfm/charts/categories" 
     alt="Category Distribution">

<!-- Display nutrition facts for specific product -->
<img src="http://localhost:8500/api/products.cfm/charts/nutrition/PRODUCT_ID_HERE" 
     alt="Nutrition Facts">
```

### JavaScript Usage
```javascript
// Get chart as blob for processing
fetch('http://localhost:3000/api/products.cfm/charts/ratings')
  .then(response => response.blob())
  .then(blob => {
    const imageUrl = URL.createObjectURL(blob);
    document.getElementById('chart-container').innerHTML = 
      `<img src="${imageUrl}" alt="Rating Chart">`;
  });

// Dynamic category chart
const category = 'protein_powder';
const chartUrl = `http://localhost:3000/api/products.cfm/charts/category-ratings/${category}`;
```

### React Component Example
```jsx
const ChartComponent = ({ chartType, params = '' }) => {
  const chartUrl = `http://localhost:3000/api/products.cfm/charts/${chartType}${params}`;
  
  return (
    <div className="chart-container">
      <img 
        src={chartUrl} 
        alt={`${chartType} chart`}
        onError={(e) => e.target.style.display = 'none'}
        style={{ maxWidth: '100%', height: 'auto' }}
      />
    </div>
  );
};

// Usage
<ChartComponent chartType="ratings" />
<ChartComponent chartType="nutrition" params="/PRODUCT_ID" />
<ChartComponent chartType="category-ratings" params="/chips" />
```

## Chart Features

### Visual Design
- Clean, professional appearance with white backgrounds
- Consistent color scheme matching your app's theme
- Appropriate sizing for web display
- No-cache headers for real-time data updates

### Data Handling
- Real-time data from MySQL database
- Automatic error handling for invalid parameters
- Graceful handling of missing or invalid data
- Proper HTTP status codes for different scenarios

### Performance
- Direct PNG generation using CFML's built-in cfchart
- Efficient database queries with proper indexing support
- Reasonable chart dimensions for web performance
- Cache-Control headers prevent unwanted caching

## Error Handling

### HTTP Status Codes
- `200` - Chart generated successfully
- `400` - Bad request (missing/invalid parameters)
- `404` - Resource not found (product/category doesn't exist)
- `500` - Server error (database issues, etc.)

### Error Response Format (JSON)
```json
{
  "success": false,
  "error": "Error description here"
}
```

## Notes

1. **CORS Headers:** All chart endpoints include proper CORS headers for frontend access
2. **Real-time Data:** Charts reflect current database state (no caching)
3. **URL Parameters:** Use URL-encoded values for categories with special characters
4. **Image Format:** All charts are returned as PNG format for broad compatibility
5. **Frontend Integration:** Charts can be embedded directly in HTML img tags or processed via JavaScript

## Future Enhancements

Potential additions could include:
- Chart format options (SVG, JPEG)
- Custom chart dimensions via URL parameters  
- Comparison charts between multiple products
- Trend charts over time
- Export functionality for high-resolution charts
