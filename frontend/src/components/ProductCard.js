import React from 'react';
import { Link } from 'react-router-dom';
import './ProductCard.css';

const ProductCard = ({ product, showSuggestions = false, isAdmin = false, onEdit = null, onDelete = null }) => {
  const getRatingColor = (rating) => {
    const colors = {
      'A': '#4CAF50',
      'B': '#8BC34A',
      'C': '#FFC107',
      'D': '#FF9800',
      'E': '#F44336'
    };
    return colors[rating] || '#gray';
  };

  const getRatingName = (rating) => {
    const names = {
      'A': 'Excellent',
      'B': 'Good',
      'C': 'Fair', 
      'D': 'Poor',
      'E': 'Very Poor'
    };
    return names[rating] || rating;
  };

  const formatPrice = (price) => {
    if (!price) return null;
    return `₹${parseInt(price).toLocaleString('en-IN')}`;
  };

  return (
    <div className={`product-card ${isAdmin ? 'admin-mode' : ''}`}>
      <div className="product-card-header">
        <div className="product-rating" style={{ backgroundColor: getRatingColor(product.rating) }}>
          <div className="nutri-score-label-small">Nutri-Score</div>
          <span className="rating-letter">{product.rating}</span>
          <span className="rating-name">{getRatingName(product.rating)}</span>
        </div>
        <div className="product-header-right">
          {isAdmin && (
            <div className="admin-badge">
              🛠️ Admin
            </div>
          )}
          {product.price && (
            <div className="product-price">
              {formatPrice(product.price)}
            </div>
          )}
        </div>
      </div>

      <div className="product-info">
        <h3 className="product-name">{product.name}</h3>
        <p className="product-brand">{product.brand}</p>
        
        {product.description && (
          <p className="product-description">
            {product.description.length > 100 
              ? `${product.description.substring(0, 100)}...`
              : product.description
            }
          </p>
        )}

        <div className="product-category">
          <span className="category-tag">
            {getCategoryDisplayName(product.category)}
          </span>
        </div>
      </div>

      <div className="product-actions">
        <Link to={`/product/${product._id}`} className="btn btn-primary product-view-btn">
          View Details
        </Link>
        
        {showSuggestions && (
          <div className="product-suggestions-preview">
            {product.rating === 'A' ? (
              <div className="suggestion-hint best-option">
                <span className="suggestion-icon">👑</span>
                <span className="suggestion-text">Best Choice</span>
              </div>
            ) : (
              <div className="suggestion-hint better-available">
                <span className="suggestion-icon">⬆️</span>
                <span className="suggestion-text">
                  {getBetterOptionsText(product.rating)} available
                </span>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Nutrition info preview if available */}
      {product.nutritionFacts && (
        <div className="nutrition-preview">
          <div className="nutrition-item">
            <span className="nutrition-label">Protein:</span>
            <span className="nutrition-value">{product.nutritionFacts.protein}g</span>
          </div>
          <div className="nutrition-item">
            <span className="nutrition-label">Calories:</span>
            <span className="nutrition-value">{product.nutritionFacts.calories}</span>
          </div>
        </div>
      )}

      {/* Admin Actions */}
      {isAdmin && (
        <div className="admin-actions">
          {onEdit && (
            <button 
              className="admin-edit-btn"
              onClick={() => onEdit(product)}
              title="Edit Product"
              type="button"
            >
              <span>✏️</span>
              <span>Edit</span>
            </button>
          )}
          {onDelete && (
            <button 
              className="admin-delete-btn"
              onClick={() => onDelete(product)}
              title="Delete Product"
              type="button"
            >
              <span>🗑️</span>
              <span>Delete</span>
            </button>
          )}
        </div>
      )}
    </div>
  );
};

// Helper function to get category display names
const getCategoryDisplayName = (category) => {
  const displayNames = {
    protein_powder: 'Protein Powder',
    chips: 'Chips',
    chocolates: 'Chocolates',
    popcorn: 'Popcorn',
    biscuits: 'Biscuits',
    cereals: 'Cereals',
    nuts: 'Nuts',
    energy_bars: 'Energy Bars',
    drinks: 'Drinks'
  };
  return displayNames[category] || category.replace(/[_-]/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
};

// Helper function to get better options text based on current rating
const getBetterOptionsText = (currentRating) => {
  return 'Better options';
};

export default ProductCard;
