import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { productService } from '../services/productService';
import ProductCard from '../components/ProductCard';
import './Home.css';

const Home = () => {
  const { user } = useAuth();
  const [featuredProducts, setFeaturedProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadHomeData();
  }, []);

  const loadHomeData = async () => {
    try {
      setLoading(true);
      
      // Load featured products (top rated products)
      const productsResponse = await productService.getAllProducts({ 
        limit: 8,
        rating: 'A' 
      });
      
      if (productsResponse.success) {
        setFeaturedProducts(productsResponse.products || []);
      }
      
      // Load categories
      const categoriesResponse = await productService.getCategories();
      if (categoriesResponse.success || categoriesResponse.categories) {
        setCategories(categoriesResponse.categories || []);
      }
      
    } catch (error) {
      console.error('Failed to load home data:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="page">
        <div className="container">
          <div className="loading">Loading...</div>
        </div>
      </div>
    );
  }

  return (
    <div className="page">
      <div className="container">
        {/* Hero Section */}
        <section className="hero-section">
          <div className="hero-content">
            <h1 className="hero-title">
              Welcome to NutriApp
            </h1>
            <p className="hero-subtitle">
              Discover the best nutrition products with our intelligent rating system. 
              Find products rated from A (Best) to E (Worst) and get personalized recommendations.
            </p>
            <div className="hero-actions">
              <Link to="/search" className="btn btn-primary">
                🔍 Search Products
              </Link>
              {!user && (
                <Link to="/register" className="btn btn-secondary">
                  Get Started
                </Link>
              )}
            </div>
          </div>
        </section>

        {/* Categories Section */}
        <section className="categories-section">
          <h2 className="section-title">Product Categories</h2>
          <div className="categories-grid">
            {categories.map((category) => (
              <Link
                key={category.name}
                to={`/search?category=${category.name}`}
                className="category-card"
              >
                <div className="category-icon">
                  {getCategoryIcon(category.name)}
                </div>
                <h3 className="category-name">{category.displayName}</h3>
                <p className="category-description">
                  {category.description || `Discover ${category.displayName.toLowerCase()}`}
                </p>
              </Link>
            ))}
          </div>
        </section>

        {/* Featured Products Section */}
        {featuredProducts.length > 0 && (
          <section className="featured-section">
            <div className="section-header">
              <h2 className="section-title">Top Rated Products</h2>
              <Link to="/search?rating=A" className="view-all-link">
                View All A-Rated →
              </Link>
            </div>
            <div className="products-grid">
              {featuredProducts.slice(0, 4).map((product) => (
                <ProductCard key={product._id} product={product} />
              ))}
            </div>
          </section>
        )}

        {/* Rating System Explanation */}
        <section className="rating-system-section">
          <div className="card">
            <div className="card-header">
              <h2 className="card-title">Nutri-Score System</h2>
              <p className="card-subtitle">
                Products are automatically graded A (Excellent) to E (Very Poor) based on the European Nutri-Score algorithm, analyzing nutritional content including calories, sugar, fat, fiber, and protein.
              </p>
            </div>
            <div className="rating-badges">
              <div className="rating-badge rating-a">
                <span className="rating-letter">A</span>
                <span className="rating-name">Excellent</span>
              </div>
              <div className="rating-badge rating-b">
                <span className="rating-letter">B</span>
                <span className="rating-name">Good</span>
              </div>
              <div className="rating-badge rating-c">
                <span className="rating-letter">C</span>
                <span className="rating-name">Fair</span>
              </div>
              <div className="rating-badge rating-d">
                <span className="rating-letter">D</span>
                <span className="rating-name">Poor</span>
              </div>
              <div className="rating-badge rating-e">
                <span className="rating-letter">E</span>
                <span className="rating-name">Very Poor</span>
              </div>
            </div>
          </div>
        </section>

        {/* User-specific content */}
        {user && (
          <section className="user-section">
            <div className="card">
              <h2 className="card-title">
                Welcome back, {user.username}! 👋
              </h2>
              <p className="card-subtitle">
                Ready to find better nutrition products?
              </p>
              <div className="mt-4">
                <Link to="/search" className="btn btn-primary">
                  Start Searching
                </Link>
              </div>
            </div>
          </section>
        )}
      </div>
    </div>
  );
};

// Helper function to get category icons
const getCategoryIcon = (categoryName) => {
  const icons = {
    protein_powder: '💪',
    chips: '🍟',
    chocolates: '🍫',
    popcorn: '🍿',
    biscuits: '🍪',
    cereals: '🥣',
    nuts: '🥜',
    energy_bars: '⚡',
    drinks: '🥤'
  };
  return icons[categoryName] || '🥗';
};

export default Home;
