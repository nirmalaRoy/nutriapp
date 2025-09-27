import React, { useState, useEffect, useCallback } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { productService } from '../services/productService';
import ProductCard from '../components/ProductCard';
import NutritionDetails from '../components/NutritionDetails';
import './ProductDetails.css';

const ProductDetails = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [product, setProduct] = useState(null);
  const [suggestions, setSuggestions] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [suggestionsLoading, setSuggestionsLoading] = useState(false);

  const loadProduct = useCallback(async () => {
    try {
      setLoading(true);
      setError('');

      const response = await productService.getProduct(id);
      
      if (response.success) {
        setProduct(response.product);
        // Load suggestions if product has suggestions
        if (response.product?.suggestions) {
          setSuggestions(response.product.suggestions);
        } else {
          loadSuggestions(response.product);
        }
      } else {
        setError(response.error || 'Product not found');
      }
    } catch (error) {
      setError('Failed to load product');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    if (id) {
      loadProduct();
    }
  }, [id, loadProduct]);

  const loadSuggestions = async (productData) => {
    try {
      setSuggestionsLoading(true);
      const response = await productService.getProductSuggestions(productData._id);
      
      if (response.success) {
        setSuggestions(response.suggestions);
      }
    } catch (error) {
      console.error('Failed to load suggestions:', error);
    } finally {
      setSuggestionsLoading(false);
    }
  };

  const getRatingInfo = (rating) => {
    const ratingMap = {
      'A': { name: 'Best', color: '#4CAF50', description: 'Highest quality, excellent nutrition' },
      'B': { name: 'Better', color: '#8BC34A', description: 'Good quality with minor concerns' },
      'C': { name: 'Good', color: '#FFC107', description: 'Average quality, acceptable choice' },
      'D': { name: 'Bad', color: '#FF9800', description: 'Below average, better alternatives exist' },
      'E': { name: 'Worst', color: '#F44336', description: 'Poor quality, not recommended' }
    };
    return ratingMap[rating] || { name: rating, color: '#gray', description: 'Unknown rating' };
  };

  const formatPrice = (price) => {
    if (!price) return null;
    return `₹${parseInt(price).toLocaleString('en-IN')}`;
  };

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

  if (loading) {
    return (
      <div className="product-details-page">
        <div className="container">
          <div className="loading">Loading product details...</div>
        </div>
      </div>
    );
  }

  if (error || !product) {
    return (
      <div className="product-details-page">
        <div className="container">
          <div className="error-container">
            <div className="error-content">
              <div className="error-icon">❌</div>
              <h2 className="error-title">Product Not Found</h2>
              <p className="error-message">{error || 'The requested product could not be found.'}</p>
              <div className="error-actions">
                <button 
                  className="btn btn-primary"
                  onClick={() => navigate('/search')}
                >
                  Search Products
                </button>
                <button 
                  className="btn btn-secondary"
                  onClick={() => navigate('/')}
                >
                  Go Home
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  const ratingInfo = getRatingInfo(product.rating);

  return (
    <div className="product-details-page">
      <div className="container">
        {/* Breadcrumb */}
        <nav className="breadcrumb">
          <Link to="/" className="breadcrumb-link">Home</Link>
          <span className="breadcrumb-separator">›</span>
          <Link to="/search" className="breadcrumb-link">Search</Link>
          <span className="breadcrumb-separator">›</span>
          <span className="breadcrumb-current">{product.name}</span>
        </nav>

        {/* Product Header */}
        <div className="product-header">
          <div className="product-basic-info">
            <div className="product-rating-large" style={{ backgroundColor: ratingInfo.color }}>
              <span className="rating-letter-large">{product.rating}</span>
              <span className="rating-name-large">{ratingInfo.name}</span>
            </div>
            
            <div className="product-title-info">
              <h1 className="product-title">{product.name}</h1>
              <p className="product-brand-large">{product.brand}</p>
              <div className="product-meta">
                <span className="product-category-large">
                  {getCategoryDisplayName(product.category)}
                </span>
                {product.price && (
                  <span className="product-price-large">
                    {formatPrice(product.price)}
                  </span>
                )}
              </div>
            </div>
          </div>
          
          <div className="rating-description">
            <p className="rating-description-text">
              <strong>Rating {product.rating}:</strong> {ratingInfo.description}
            </p>
          </div>
        </div>

        {/* Product Content - Complete Width Sections */}
        <div className="product-content-complete">
          {/* Description Section - Full Width */}
          {product.description && (
            <div className="product-section-full">
              <h2 className="section-title">Description</h2>
              <p className="product-description-full">{product.description}</p>
            </div>
          )}

          {/* Ingredients Section - Full Width */}
          {product.ingredients && product.ingredients.length > 0 && (
            <div className="product-section-full">
              <h2 className="section-title">Ingredients</h2>
              <div className="ingredients-list">
                {product.ingredients.map((ingredient, index) => (
                  <span key={index} className="ingredient-tag">
                    {ingredient}
                  </span>
                ))}
              </div>
            </div>
          )}

          {/* Nutrition Chart Section - Full Width */}
          {product.nutritionFacts && (
            <div className="product-section-full nutrition-section-full">
              <NutritionDetails 
                nutritionFacts={product.nutritionFacts}
                servingSize="30g"
                isFullWidth={true}
              />
            </div>
          )}
        </div>

        {/* Suggestions Section */}
        {(suggestions || suggestionsLoading) && (
          <div className="suggestions-section">
            <h2 className="section-title">🚀 Find Better Options</h2>
            
            {suggestionsLoading ? (
              <div className="loading">Loading suggestions...</div>
            ) : (
              <>
                {/* Best Options - All better rated products */}
                {suggestions?.better && suggestions.better.length > 0 && product.rating !== 'A' && (
                  <div className="suggestions-group">
                    <div className="suggestions-header">
                      <h3 className="suggestions-title">
                        ⭐ Best Options ({getBetterRatingsDisplay(product.rating)})
                      </h3>
                      <p className="suggestions-description">
                        All products with better ratings than your current selection
                      </p>
                    </div>
                    <div className="suggestions-grid">
                      {suggestions.better.slice(0, 6).map(suggestion => (
                        <ProductCard key={suggestion._id} product={suggestion} />
                      ))}
                    </div>
                  </div>
                )}

                {/* Other Best Options - For A-rated products */}
                {product.rating === 'A' && suggestions?.best && suggestions.best.filter(p => p._id !== product._id).length > 0 && (
                  <div className="suggestions-group">
                    <div className="suggestions-grid nutritional-comparison">
                      {suggestions.best
                        .filter(suggestion => suggestion._id !== product._id)
                        .slice(0, 6)
                        .map((suggestion, index) => (
                          <div key={suggestion._id} className="comparison-card">
                            <div className="nutrition-rank">#{index + 1}</div>
                            <ProductCard product={suggestion} />
                          </div>
                        ))}
                    </div>
                  </div>
                )}

                {/* No Suggestions - Only when no better alternatives exist */}
                {product.rating !== 'A' && 
                 (!suggestions?.better || suggestions.better.length === 0) && (
                  <div className="no-suggestions">
                    <div className="no-suggestions-content">
                      <div className="no-suggestions-icon">🏆</div>
                      <h3 className="no-suggestions-title">Great Choice!</h3>
                      <p className="no-suggestions-text">
                        No better alternatives found in this category right now.
                      </p>
                    </div>
                  </div>
                )}

                {/* No Other Best Options - When A-rated product has no other A-rated alternatives */}
                {product.rating === 'A' && 
                 (!suggestions?.best || suggestions.best.filter(p => p._id !== product._id).length === 0) && (
                  <div className="no-suggestions">
                    <div className="no-suggestions-content">
                      <div className="no-suggestions-icon">👑</div>
                      <h3 className="no-suggestions-title">Exceptional Choice!</h3>
                      <p className="no-suggestions-text">
                        This is the only A-rated product in its category - you've found the absolute best!
                      </p>
                    </div>
                  </div>
                )}
              </>
            )}
          </div>
        )}


        {/* Action Buttons */}
        <div className="product-actions">
          <Link to="/search" className="btn btn-secondary">
            ← Back to Search
          </Link>
          <Link 
            to={`/search?category=${product.category}`}
            className="btn btn-primary"
          >
            Browse More {getCategoryDisplayName(product.category)}
          </Link>
        </div>
      </div>
    </div>
  );
};

// Helper function to get ALL better ratings
const getBetterRatings = (currentRating) => {
  const ratingOrder = ['E', 'D', 'C', 'B', 'A'];
  const currentIndex = ratingOrder.indexOf(currentRating);
  return ratingOrder.slice(currentIndex + 1); // Get all better ratings
};

// Helper function to display better ratings nicely
const getBetterRatingsDisplay = (currentRating) => {
  const betterRatings = getBetterRatings(currentRating);
  if (betterRatings.length === 0) return '';
  if (betterRatings.length === 1) return `Rating ${betterRatings[0]}`;
  if (betterRatings.length === 2) return `Ratings ${betterRatings.join(' & ')}`;
  return `Ratings ${betterRatings.slice(0, -1).join(', ')} & ${betterRatings[betterRatings.length - 1]}`;
};

export default ProductDetails;
