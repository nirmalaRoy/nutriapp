import React from 'react';
import './NutritionDetails.css';

const NutritionDetails = ({ nutritionFacts, servingSize = "30g", isLarge = false, isFullWidth = false }) => {
  if (!nutritionFacts) {
    return <div className="nutrition-details">No nutrition information available</div>;
  }

  // Calculate percentages based on recommended daily values (2000 calorie diet)
  const dailyValues = {
    calories: 2000,
    protein: 50,      // grams
    carbs: 300,       // grams  
    fat: 65,          // grams
    fiber: 25,        // grams
    sugar: 50,        // grams (recommended limit)
    sodium: 2300,     // mg
    saturatedFat: 20, // grams
    cholesterol: 300, // mg
    vitaminC: 90,     // mg
    calcium: 1000,    // mg
    iron: 18          // mg
  };

  const calculateDV = (nutrient, amount) => {
    if (!dailyValues[nutrient] || !amount) return 0;
    return Math.round((amount / dailyValues[nutrient]) * 100);
  };

  const formatValue = (value, unit = 'g') => {
    if (value === 0 || value === '0') return `0${unit}`;
    if (value < 1 && value > 0) return `<1${unit}`;
    return `${value}${unit}`;
  };

  return (
    <div className={`nutrition-details ${isLarge ? 'nutrition-details-large' : ''} ${isFullWidth ? 'nutrition-details-fullwidth' : ''}`}>
      <div className="nutrition-title">
        <h3>🥗 Nutritional Content</h3>
        <p className="serving-size">Per serving ({servingSize})</p>
      </div>
      
      <div className="nutrition-content">
        {/* Single Pie Chart with all nutrients */}
        <div className="pie-chart-container">
          <div 
            className="pie-chart" 
            style={{
              background: (() => {
                // Color scheme: green, yellow, blue, orange, purple, brown, black, then light colors
                const colors = {
                  protein: '#16a34a',      // green
                  carbs: '#eab308',        // yellow  
                  fat: '#2563eb',          // blue
                  fiber: '#f97316',        // orange
                  sugar: '#9333ea',        // purple
                  sodium: '#92400e',       // brown
                  calcium: '#000000',      // black
                  iron: '#fca5a5',         // light red
                  vitaminC: '#86efac',     // light green  
                  potassium: '#93c5fd'     // light blue
                };

                // Calculate the total for percentage distribution
                const totalMacros = nutritionFacts.protein + nutritionFacts.carbs + nutritionFacts.fat;
                const proteinPercent = totalMacros > 0 ? (nutritionFacts.protein / totalMacros) * 60 : 0;
                const carbsPercent = totalMacros > 0 ? (nutritionFacts.carbs / totalMacros) * 60 : 0;
                const fatPercent = totalMacros > 0 ? (nutritionFacts.fat / totalMacros) * 60 : 0;
                
                // Remaining 40% for other nutrients
                const fiberPercent = nutritionFacts.fiber ? Math.min((nutritionFacts.fiber / 25) * 10, 10) : 0;
                const sugarPercent = nutritionFacts.sugar ? Math.min((nutritionFacts.sugar / 50) * 15, 15) : 0;
                const sodiumPercent = nutritionFacts.sodium ? Math.min((nutritionFacts.sodium / 2000) * 8, 8) : 0;
                const calciumPercent = nutritionFacts.calcium ? Math.min((nutritionFacts.calcium / 1000) * 7, 7) : 0;
                const ironPercent = nutritionFacts.iron ? Math.min((nutritionFacts.iron / 18) * 5, 5) : 0;
                const vitaminCPercent = nutritionFacts.vitaminC ? Math.min((nutritionFacts.vitaminC / 90) * 4, 4) : 0;
                const potassiumPercent = nutritionFacts.potassium ? Math.min((nutritionFacts.potassium / 4700) * 4, 4) : 0;
                
                let currentPercent = 0;
                const segments = [];
                
                if (proteinPercent > 0) {
                  segments.push(`${colors.protein} ${currentPercent}% ${currentPercent + proteinPercent}%`);
                  currentPercent += proteinPercent;
                }
                
                if (carbsPercent > 0) {
                  segments.push(`${colors.carbs} ${currentPercent}% ${currentPercent + carbsPercent}%`);
                  currentPercent += carbsPercent;
                }
                
                if (fatPercent > 0) {
                  segments.push(`${colors.fat} ${currentPercent}% ${currentPercent + fatPercent}%`);
                  currentPercent += fatPercent;
                }
                
                if (fiberPercent > 0) {
                  segments.push(`${colors.fiber} ${currentPercent}% ${currentPercent + fiberPercent}%`);
                  currentPercent += fiberPercent;
                }
                
                if (sugarPercent > 0) {
                  segments.push(`${colors.sugar} ${currentPercent}% ${currentPercent + sugarPercent}%`);
                  currentPercent += sugarPercent;
                }
                
                if (sodiumPercent > 0) {
                  segments.push(`${colors.sodium} ${currentPercent}% ${currentPercent + sodiumPercent}%`);
                  currentPercent += sodiumPercent;
                }
                
                if (calciumPercent > 0) {
                  segments.push(`${colors.calcium} ${currentPercent}% ${currentPercent + calciumPercent}%`);
                  currentPercent += calciumPercent;
                }

                if (ironPercent > 0) {
                  segments.push(`${colors.iron} ${currentPercent}% ${currentPercent + ironPercent}%`);
                  currentPercent += ironPercent;
                }

                if (vitaminCPercent > 0) {
                  segments.push(`${colors.vitaminC} ${currentPercent}% ${currentPercent + vitaminCPercent}%`);
                  currentPercent += vitaminCPercent;
                }

                if (potassiumPercent > 0) {
                  segments.push(`${colors.potassium} ${currentPercent}% ${currentPercent + potassiumPercent}%`);
                  currentPercent += potassiumPercent;
                }
                
                // Fill remaining with light gray
                if (currentPercent < 100) {
                  segments.push(`#e9ecef ${currentPercent}% 100%`);
                }
                
                return `conic-gradient(${segments.join(', ')})`;
              })()
            }}
          >
            <div className="center-circle">
              <div className="calories-display">
                <span className="calories-number">{nutritionFacts.calories}</span>
                <span className="calories-label">Calories</span>
              </div>
            </div>
          </div>

          {/* Legend */}
          <div className="pie-legend">
            <div className="legend-item">
              <span className="legend-color" style={{ backgroundColor: '#16a34a' }}></span>
              <span className="legend-text">🥩 Protein: {formatValue(nutritionFacts.protein)} ({calculateDV('protein', nutritionFacts.protein)}% DV)</span>
            </div>
            
            <div className="legend-item">
              <span className="legend-color" style={{ backgroundColor: '#eab308' }}></span>
              <span className="legend-text">🌾 Carbs: {formatValue(nutritionFacts.carbs)} ({calculateDV('carbs', nutritionFacts.carbs)}% DV)</span>
            </div>
            
            <div className="legend-item">
              <span className="legend-color" style={{ backgroundColor: '#2563eb' }}></span>
              <span className="legend-text">🥑 Fat: {formatValue(nutritionFacts.fat)} ({calculateDV('fat', nutritionFacts.fat)}% DV)</span>
            </div>

            {nutritionFacts.fiber !== undefined && (
              <div className="legend-item">
                <span className="legend-color" style={{ backgroundColor: '#f97316' }}></span>
                <span className="legend-text">🌿 Fiber: {formatValue(nutritionFacts.fiber)} ({calculateDV('fiber', nutritionFacts.fiber)}% DV)</span>
              </div>
            )}

            {nutritionFacts.sugar !== undefined && (
              <div className="legend-item">
                <span className="legend-color" style={{ backgroundColor: '#9333ea' }}></span>
                <span className="legend-text">🍯 Sugar: {formatValue(nutritionFacts.sugar)} {nutritionFacts.sugar > 10 ? '⚠️ High' : nutritionFacts.sugar > 5 ? '⚡ Moderate' : '✅ Low'}</span>
              </div>
            )}

            {nutritionFacts.sodium !== undefined && (
              <div className="legend-item">
                <span className="legend-color" style={{ backgroundColor: '#92400e' }}></span>
                <span className="legend-text">🧂 Sodium: {formatValue(nutritionFacts.sodium, 'mg')} ({calculateDV('sodium', nutritionFacts.sodium)}% DV)</span>
              </div>
            )}

            {nutritionFacts.calcium !== undefined && (
              <div className="legend-item">
                <span className="legend-color" style={{ backgroundColor: '#000000' }}></span>
                <span className="legend-text">🦴 Calcium: {formatValue(nutritionFacts.calcium, 'mg')} ({calculateDV('calcium', nutritionFacts.calcium)}% DV)</span>
              </div>
            )}

            {nutritionFacts.iron !== undefined && (
              <div className="legend-item">
                <span className="legend-color" style={{ backgroundColor: '#fca5a5' }}></span>
                <span className="legend-text">⚒️ Iron: {formatValue(nutritionFacts.iron, 'mg')} ({calculateDV('iron', nutritionFacts.iron)}% DV)</span>
              </div>
            )}

            {nutritionFacts.vitaminC !== undefined && (
              <div className="legend-item">
                <span className="legend-color" style={{ backgroundColor: '#86efac' }}></span>
                <span className="legend-text">🍊 Vitamin C: {formatValue(nutritionFacts.vitaminC, 'mg')} ({calculateDV('vitaminC', nutritionFacts.vitaminC)}% DV)</span>
              </div>
            )}

            {nutritionFacts.potassium !== undefined && (
              <div className="legend-item">
                <span className="legend-color" style={{ backgroundColor: '#93c5fd' }}></span>
                <span className="legend-text">🍌 Potassium: {formatValue(nutritionFacts.potassium, 'mg')} ({calculateDV('potassium', nutritionFacts.potassium)}% DV)</span>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default NutritionDetails;
