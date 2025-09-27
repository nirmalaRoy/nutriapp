import React, { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import { productService } from '../services/productService';
import ProductCard from '../components/ProductCard';
import './ProductSearch.css';

const ProductSearch = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  const [searchQuery, setSearchQuery] = useState(searchParams.get('keyword') || '');
  const [selectedCategory, setSelectedCategory] = useState(searchParams.get('category') || '');
  const [selectedRating, setSelectedRating] = useState(searchParams.get('rating') || '');
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [ratings, setRatings] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [hasSearched, setHasSearched] = useState(false);

  useEffect(() => {
    loadInitialData();
  }, []);

  useEffect(() => {
    // Auto-search if URL params exist
    if (searchParams.get('keyword') || searchParams.get('category') || searchParams.get('rating')) {
      handleSearch();
    }
  }, [searchParams]);

  const loadInitialData = async () => {
    try {
      // Load categories and ratings
      const [categoriesResponse, ratingsResponse] = await Promise.all([
        productService.getCategories(),
        productService.getRatings()
      ]);

      if (categoriesResponse.success || categoriesResponse.categories) {
        setCategories(categoriesResponse.categories || []);
      }

      if (ratingsResponse.success || ratingsResponse.ratings) {
        setRatings(ratingsResponse.ratings || []);
      }
    } catch (error) {
      console.error('Failed to load initial data:', error);
    }
  };

  const handleSearch = async () => {
    try {
      setLoading(true);
      setError('');
      setHasSearched(true);

      const searchParams = {};
      if (searchQuery.trim()) searchParams.keyword = searchQuery.trim();
      if (selectedCategory) searchParams.category = selectedCategory;
      if (selectedRating) searchParams.rating = selectedRating;

      const response = await productService.searchProducts(searchParams);

      if (response.success) {
        setProducts(response.products || []);
      } else {
        setError(response.error || 'Search failed');
        setProducts([]);
      }
    } catch (error) {
      setError('An error occurred while searching');
      setProducts([]);
    } finally {
      setLoading(false);
    }
  };

  const handleFormSubmit = (e) => {
    e.preventDefault();
    updateUrlParams();
    handleSearch();
  };

  const updateUrlParams = () => {
    const params = new URLSearchParams();
    if (searchQuery.trim()) params.set('keyword', searchQuery.trim());
    if (selectedCategory) params.set('category', selectedCategory);
    if (selectedRating) params.set('rating', selectedRating);
    setSearchParams(params);
  };

  const clearFilters = () => {
    setSearchQuery('');
    setSelectedCategory('');
    setSelectedRating('');
    setSearchParams({});
    setProducts([]);
    setHasSearched(false);
  };

  const getRatingColor = (ratingCode) => {
    const rating = ratings.find(r => r.code === ratingCode);
    return rating ? rating.color : '#gray';
  };

  const hasActiveFilters = searchQuery || selectedCategory || selectedRating;

  return (
    <div className="search-page">
      <div className="container">
        {/* Search Header */}
        <div className="search-header">
          <h1 className="search-title">🔍 Search Products</h1>
          <p className="search-subtitle">
            Find products by name, category, or rating
          </p>
        </div>

        {/* Search Form */}
        <div className="search-form-container">
          <form onSubmit={handleFormSubmit} className="search-form">
            <div className="search-inputs">
              <div className="form-group">
                <label className="form-label">Search by name or brand</label>
                <input
                  type="text"
                  className="form-input search-input"
                  placeholder="Enter product name or brand..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
              </div>

              <div className="form-group">
                <label className="form-label">Category</label>
                <select
                  className="form-select"
                  value={selectedCategory}
                  onChange={(e) => setSelectedCategory(e.target.value)}
                >
                  <option value="">All Categories</option>
                  {categories.map(category => (
                    <option key={category.name} value={category.name}>
                      {category.displayName}
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Rating</label>
                <select
                  className="form-select"
                  value={selectedRating}
                  onChange={(e) => setSelectedRating(e.target.value)}
                >
                  <option value="">All Ratings</option>
                  {ratings.map(rating => (
                    <option key={rating.code} value={rating.code}>
                      {rating.code} - {rating.name}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <div className="search-actions">
              <button type="submit" className="btn btn-primary" disabled={loading}>
                {loading ? 'Searching...' : 'Search Products'}
              </button>
              
              {hasActiveFilters && (
                <button 
                  type="button" 
                  className="btn btn-secondary"
                  onClick={clearFilters}
                  disabled={loading}
                >
                  Clear Filters
                </button>
              )}
            </div>
          </form>
        </div>

        {/* Active Filters Display */}
        {hasActiveFilters && (
          <div className="active-filters">
            <h3 className="active-filters-title">Active Filters:</h3>
            <div className="filter-tags">
              {searchQuery && (
                <span className="filter-tag">
                  Keyword: "{searchQuery}"
                </span>
              )}
              {selectedCategory && (
                <span className="filter-tag">
                  Category: {categories.find(c => c.name === selectedCategory)?.displayName || selectedCategory}
                </span>
              )}
              {selectedRating && (
                <span className="filter-tag" style={{ backgroundColor: getRatingColor(selectedRating) }}>
                  Rating: {selectedRating}
                </span>
              )}
            </div>
          </div>
        )}

        {/* Error Display */}
        {error && (
          <div className="alert alert-error">
            {error}
          </div>
        )}

        {/* Results */}
        {loading ? (
          <div className="search-loading">
            <div className="loading">Searching products...</div>
          </div>
        ) : hasSearched ? (
          <div className="search-results">
            <div className="results-header">
              <h2 className="results-title">
                {products.length > 0 ? (
                  <>Found {products.length} product{products.length !== 1 ? 's' : ''}</>
                ) : (
                  'No products found'
                )}
              </h2>
              
              {products.length > 0 && (
                <p className="results-subtitle">
                  Click on any product to view details and get better suggestions
                </p>
              )}
            </div>

            {products.length > 0 ? (
              <div className="products-grid">
                {products.map(product => (
                  <ProductCard 
                    key={product._id} 
                    product={product} 
                    showSuggestions={true}
                  />
                ))}
              </div>
            ) : (
              <div className="no-results">
                <div className="no-results-content">
                  <div className="no-results-icon">🔍</div>
                  <h3 className="no-results-title">No products found</h3>
                  <p className="no-results-text">
                    Try adjusting your search criteria or browse different categories
                  </p>
                  <button 
                    className="btn btn-primary"
                    onClick={clearFilters}
                  >
                    Browse All Products
                  </button>
                </div>
              </div>
            )}
          </div>
        ) : (
          <div className="search-placeholder">
            <div className="placeholder-content">
              <div className="placeholder-icon">🥗</div>
              <h3 className="placeholder-title">Ready to find better nutrition?</h3>
              <p className="placeholder-text">
                Use the search form above to find products by name, category, or rating.
                We'll help you discover better alternatives!
              </p>
              
              {/* Quick category buttons */}
              <div className="quick-categories">
                <h4 className="quick-categories-title">Or browse by category:</h4>
                <div className="category-buttons">
                  {categories.slice(0, 5).map(category => (
                    <button
                      key={category.name}
                      className="btn btn-secondary category-button"
                      onClick={() => {
                        setSelectedCategory(category.name);
                        setSearchParams({ category: category.name });
                        handleSearch();
                      }}
                    >
                      {category.displayName}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default ProductSearch;
