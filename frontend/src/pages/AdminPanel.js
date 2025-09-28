import React, { useState, useEffect, useRef } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { productService } from '../services/productService';
import ProductCard from '../components/ProductCard';
import './AdminPanel.css';

const AdminPanel = () => {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState('products');
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [ratings, setRatings] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  
  // Ref to store timeout IDs for cleanup
  const timeoutRef = useRef();

  // Add Product Form State
  const [showAddForm, setShowAddForm] = useState(false);
  const [productForm, setProductForm] = useState({
    name: '',
    brand: '',
    category: '',
    description: '',
    price: '',
    ingredients: '',
    nutritionFacts: {
      calories: '',
      protein: '',
      carbs: '',
      fat: '',
      fiber: '',
      sugar: ''
    }
  });

  // Edit Product State
  const [editingProduct, setEditingProduct] = useState(null);
  const [showEditForm, setShowEditForm] = useState(false);
  
  // Ref for scrolling to edit form
  const editFormRef = useRef(null);

  useEffect(() => {
    loadInitialData();
  }, []);

  // Cleanup timeout on unmount
  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);

  const loadInitialData = async () => {
    try {
      setLoading(true);
      
      // Load all necessary data
      const [productsResponse, categoriesResponse, ratingsResponse] = await Promise.all([
        productService.getAllProducts({ limit: 100 }),
        productService.getCategories(),
        productService.getRatings()
      ]);

      if (productsResponse.success) {
        setProducts(productsResponse.products || []);
      }

      if (categoriesResponse.success || categoriesResponse.categories) {
        setCategories(categoriesResponse.categories || []);
      }

      if (ratingsResponse.success || ratingsResponse.ratings) {
        setRatings(ratingsResponse.ratings || []);
      }

    } catch (error) {
      setError('Failed to load admin data');
    } finally {
      setLoading(false);
    }
  };

  const handleFormInputChange = (e) => {
    const { name, value } = e.target;
    
    if (name.startsWith('nutrition_')) {
      const nutritionField = name.replace('nutrition_', '');
      setProductForm(prev => ({
        ...prev,
        nutritionFacts: {
          ...prev.nutritionFacts,
          [nutritionField]: value
        }
      }));
    } else {
      setProductForm(prev => ({
        ...prev,
        [name]: value
      }));
    }
    
    // Clear messages
    if (error) setError('');
    if (success) setSuccess('');
  };

  const handleAddProduct = async (e) => {
    e.preventDefault();
    
    try {
      setLoading(true);
      setError('');
      setSuccess('');

      // Prepare product data
      const productData = {
        name: productForm.name.trim(),
        brand: productForm.brand.trim(),
        category: productForm.category,
        description: productForm.description.trim(),
        price: productForm.price ? parseFloat(productForm.price) : undefined
      };

      // Add ingredients if provided
      if (productForm.ingredients.trim()) {
        productData.ingredients = productForm.ingredients
          .split(',')
          .map(ingredient => ingredient.trim())
          .filter(ingredient => ingredient.length > 0);
      }

      // Add nutrition facts if any are provided
      const nutritionFacts = {};
      Object.keys(productForm.nutritionFacts).forEach(key => {
        const value = productForm.nutritionFacts[key];
        if (value && value.toString().trim()) {
          nutritionFacts[key] = key === 'calories' ? parseInt(value) : parseFloat(value);
        }
      });

      if (Object.keys(nutritionFacts).length > 0) {
        productData.nutritionFacts = nutritionFacts;
      }

      const response = await productService.addProduct(productData);

      if (response.success) {
        // Close form first for immediate feedback
        setShowAddForm(false);
        resetForm();
        setSuccess('Product added successfully!');
        
        // Reload products
        await loadInitialData();
        
        // Clear success message after a delay
        timeoutRef.current = setTimeout(() => {
          setSuccess('');
        }, 3000);
      } else {
        setError(response.error || 'Failed to add product');
      }

    } catch (error) {
      setError('An error occurred while adding the product');
    } finally {
      setLoading(false);
    }
  };

  const resetForm = () => {
    setProductForm({
      name: '',
      brand: '',
      category: '',
      description: '',
      price: '',
      ingredients: '',
      nutritionFacts: {
        calories: '',
        protein: '',
        carbs: '',
        fat: '',
        fiber: '',
        sugar: ''
      }
    });
  };

  const handleCancelAdd = () => {
    setShowAddForm(false);
    resetForm();
    setError('');
    setSuccess('');
  };

  const handleEditProduct = (product) => {
    setEditingProduct(product);
    setProductForm({
      name: product.name || '',
      brand: product.brand || '',
      category: product.category || '',
      description: product.description || '',
      price: product.price || '',
      ingredients: Array.isArray(product.ingredients) ? product.ingredients.join(', ') : '',
      nutritionFacts: {
        calories: product.nutritionFacts?.calories || '',
        protein: product.nutritionFacts?.protein || '',
        carbs: product.nutritionFacts?.carbs || '',
        fat: product.nutritionFacts?.fat || '',
        fiber: product.nutritionFacts?.fiber || '',
        sugar: product.nutritionFacts?.sugar || ''
      }
    });
    setShowEditForm(true);
    setShowAddForm(false); // Close add form if open
    setError('');
    setSuccess('');
    
    // Scroll to edit form after it renders
    setTimeout(() => {
      if (editFormRef.current) {
        editFormRef.current.scrollIntoView({ 
          behavior: 'smooth', 
          block: 'start' 
        });
      }
    }, 100);
  };

  const handleUpdateProduct = async (e) => {
    e.preventDefault();
    
    try {
      setLoading(true);
      setError('');
      setSuccess('');
      
      // Prepare the update data
      const updateData = {
        ...productForm,
        price: parseFloat(productForm.price) || 0,
        ingredients: productForm.ingredients ? productForm.ingredients.split(',').map(ing => ing.trim()) : [],
        nutritionFacts: {
          ...productForm.nutritionFacts,
          calories: parseInt(productForm.nutritionFacts.calories) || 0,
          protein: parseFloat(productForm.nutritionFacts.protein) || 0,
          carbs: parseFloat(productForm.nutritionFacts.carbs) || 0,
          fat: parseFloat(productForm.nutritionFacts.fat) || 0,
          fiber: parseFloat(productForm.nutritionFacts.fiber) || 0,
          sugar: parseFloat(productForm.nutritionFacts.sugar) || 0
        }
      };
      
      const result = await productService.updateProduct(editingProduct._id, updateData);
      
      if (result.success) {
        // Close form first for immediate feedback
        handleCancelEdit();
        setSuccess(result.message || 'Product updated successfully!');
        
        // Reload products to reflect the changes
        await loadInitialData();
        
        // Clear success message after a delay
        timeoutRef.current = setTimeout(() => {
          setSuccess('');
        }, 3000);
      } else {
        setError(result.error || 'Failed to update product');
      }
      
    } catch (error) {
      setError('An error occurred while updating the product');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteProduct = async (product) => {
    if (!window.confirm(`Are you sure you want to delete "${product.name}"? This action cannot be undone.`)) {
      return;
    }
    
    try {
      setLoading(true);
      setError('');
      
      const result = await productService.deleteProduct(product._id);
      
      if (result.success) {
        setSuccess(result.message || 'Product deleted successfully!');
        
        // Reload products to reflect the changes
        await loadInitialData();
      } else {
        setError(result.error || 'Failed to delete product');
      }
      
    } catch (error) {
      setError('An error occurred while deleting the product');
    } finally {
      setLoading(false);
    }
  };

  const handleCancelEdit = () => {
    setShowEditForm(false);
    setEditingProduct(null);
    resetForm();
    setError('');
    setSuccess('');
  };

  const getProductsByRating = (rating) => {
    return products.filter(product => product.rating === rating);
  };

  // Calculate Nutri-Score preview based on current nutrition input
  const calculateNutriScorePreview = (nutritionFacts) => {
    const calories = parseFloat(nutritionFacts.calories) || 0;
    const sugar = parseFloat(nutritionFacts.sugar) || 0;
    const fat = parseFloat(nutritionFacts.fat) || 0;
    const fiber = parseFloat(nutritionFacts.fiber) || 0;
    const protein = parseFloat(nutritionFacts.protein) || 0;

    // Calculate points (simplified version of backend logic)
    let caloriesPoints = 0;
    if (calories > 80) caloriesPoints = Math.min(Math.floor((calories - 80) / 80) + 1, 10);
    
    let sugarPoints = 0;
    if (sugar > 4.5) sugarPoints = Math.min(Math.floor((sugar - 4.5) / 4.5) + 1, 10);
    
    let fatPoints = 0;
    if (fat > 1) fatPoints = Math.min(Math.floor(fat), 10);
    
    let fiberPoints = Math.min(Math.floor(fiber / 0.9), 5);
    let proteinPoints = Math.min(Math.floor(protein / 1.6), 5);

    const negativePoints = caloriesPoints + sugarPoints + fatPoints;
    const positivePoints = fiberPoints + proteinPoints;
    const nutritionalScore = negativePoints - positivePoints;

    // Determine grade
    if (nutritionalScore <= -1) return 'A';
    if (nutritionalScore >= 0 && nutritionalScore <= 2) return 'B';
    if (nutritionalScore >= 3 && nutritionalScore <= 10) return 'C';
    if (nutritionalScore >= 11 && nutritionalScore <= 18) return 'D';
    return 'E';
  };

  // Get color for nutri-score grade
  const getNutriScoreColor = (grade) => {
    const colors = {
      'A': '#2d5a27', // Dark green
      'B': '#6a8a3a', // Light green  
      'C': '#d69e2e', // Yellow
      'D': '#dd6b20', // Orange
      'E': '#e53e3e'  // Red
    };
    return colors[grade] || '#667eea';
  };

  if (!user || user.role !== 'admin') {
    return (
      <div className="admin-panel">
        <div className="container">
          <div className="access-denied">
            <h1>Access Denied</h1>
            <p>You don't have permission to access this page.</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="admin-panel">
      <div className="container">
        {/* Header */}
        <div className="admin-header">
          <h1 className="admin-title">🛠️ Admin Panel</h1>
          <p className="admin-subtitle">
            Welcome back, {user.username}! Manage products and categories.
          </p>
        </div>

        {/* Messages */}
        {error && (
          <div className="alert alert-error">
            {error}
          </div>
        )}

        {success && (
          <div className="alert alert-success">
            {success}
          </div>
        )}

        {/* Tabs */}
        <div className="admin-tabs">
          <button
            className={`tab-button ${activeTab === 'products' ? 'active' : ''}`}
            onClick={() => setActiveTab('products')}
          >
            Products ({products.length})
          </button>
          <button
            className={`tab-button ${activeTab === 'analytics' ? 'active' : ''}`}
            onClick={() => setActiveTab('analytics')}
          >
            Analytics
          </button>
        </div>

        {/* Tab Content */}
        {activeTab === 'products' && (
          <div className="tab-content">
            {/* Add Product Section */}
            <div className="admin-section">
              <div className="section-header">
                <h2 className="section-title">Manage Products</h2>
                <div className="section-actions">
                  <button
                    className="btn btn-primary"
                    onClick={() => {
                      setShowAddForm(!showAddForm);
                      if (showEditForm) {
                        handleCancelEdit();
                      }
                    }}
                    disabled={loading}
                  >
                    {showAddForm ? 'Cancel Add' : '+ Add New Product'}
                  </button>
                  {showEditForm && (
                    <button
                      className="btn btn-secondary"
                      onClick={handleCancelEdit}
                      disabled={loading}
                    >
                      Cancel Edit
                    </button>
                  )}
                </div>
              </div>

              {/* Add Product Form */}
              {showAddForm && (
                <div className="add-product-form">
                  <h3 className="form-title">Add New Product</h3>
                  <form onSubmit={handleAddProduct}>
                    <div className="form-grid">
                      <div className="form-group">
                        <label className="form-label">Product Name *</label>
                        <input
                          type="text"
                          name="name"
                          value={productForm.name}
                          onChange={handleFormInputChange}
                          className="form-input"
                          required
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">Brand *</label>
                        <input
                          type="text"
                          name="brand"
                          value={productForm.brand}
                          onChange={handleFormInputChange}
                          className="form-input"
                          required
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">Category *</label>
                        <select
                          name="category"
                          value={productForm.category}
                          onChange={handleFormInputChange}
                          className="form-select"
                          required
                        >
                          <option value="">Select Category</option>
                          {categories.map(category => (
                            <option key={category.name} value={category.name}>
                              {category.displayName}
                            </option>
                          ))}
                        </select>
                      </div>

                      <div className="form-group">
                        <label className="form-label">Nutri-Score</label>
                        <div className="nutri-score-preview">
                          <div className="nutri-score-badge">
                            {(() => {
                              const previewGrade = calculateNutriScorePreview(productForm.nutritionFacts);
                              return (
                                <>
                                  <span 
                                    className="nutri-score-letter" 
                                    style={{ backgroundColor: getNutriScoreColor(previewGrade) }}
                                  >
                                    {previewGrade}
                                  </span>
                                  <div className="nutri-score-info">
                                    <span className="nutri-score-label">Preview</span>
                                    <small className="nutri-score-note">Based on nutrition data</small>
                                  </div>
                                </>
                              );
                            })()}
                          </div>
                        </div>
                      </div>

                      <div className="form-group">
                        <label className="form-label">Price</label>
                        <input
                          type="number"
                          name="price"
                          value={productForm.price}
                          onChange={handleFormInputChange}
                          className="form-input"
                          step="0.01"
                          min="0"
                        />
                      </div>

                      <div className="form-group form-group-full">
                        <label className="form-label">Description</label>
                        <textarea
                          name="description"
                          value={productForm.description}
                          onChange={handleFormInputChange}
                          className="form-textarea"
                          rows="3"
                        />
                      </div>

                      <div className="form-group form-group-full">
                        <label className="form-label">Ingredients (comma-separated)</label>
                        <input
                          type="text"
                          name="ingredients"
                          value={productForm.ingredients}
                          onChange={handleFormInputChange}
                          className="form-input"
                          placeholder="Ingredient 1, Ingredient 2, Ingredient 3"
                        />
                      </div>
                    </div>

                    {/* Nutrition Facts */}
                    <div className="nutrition-section">
                      <h4 className="nutrition-title">Nutrition Facts (Optional)</h4>
                      <div className="nutrition-grid">
                        <div className="form-group">
                          <label className="form-label">Calories</label>
                          <input
                            type="number"
                            name="nutrition_calories"
                            value={productForm.nutritionFacts.calories}
                            onChange={handleFormInputChange}
                            className="form-input"
                          />
                        </div>
                        <div className="form-group">
                          <label className="form-label">Protein (g)</label>
                          <input
                            type="number"
                            name="nutrition_protein"
                            value={productForm.nutritionFacts.protein}
                            onChange={handleFormInputChange}
                            className="form-input"
                            step="0.1"
                          />
                        </div>
                        <div className="form-group">
                          <label className="form-label">Carbs (g)</label>
                          <input
                            type="number"
                            name="nutrition_carbs"
                            value={productForm.nutritionFacts.carbs}
                            onChange={handleFormInputChange}
                            className="form-input"
                            step="0.1"
                          />
                        </div>
                        <div className="form-group">
                          <label className="form-label">Fat (g)</label>
                          <input
                            type="number"
                            name="nutrition_fat"
                            value={productForm.nutritionFacts.fat}
                            onChange={handleFormInputChange}
                            className="form-input"
                            step="0.1"
                          />
                        </div>
                        <div className="form-group">
                          <label className="form-label">Fiber (g)</label>
                          <input
                            type="number"
                            name="nutrition_fiber"
                            value={productForm.nutritionFacts.fiber}
                            onChange={handleFormInputChange}
                            className="form-input"
                            step="0.1"
                          />
                        </div>
                        <div className="form-group">
                          <label className="form-label">Sugar (g)</label>
                          <input
                            type="number"
                            name="nutrition_sugar"
                            value={productForm.nutritionFacts.sugar}
                            onChange={handleFormInputChange}
                            className="form-input"
                            step="0.1"
                          />
                        </div>
                      </div>
                    </div>

                    <div className="form-actions">
                      <button type="submit" className="btn btn-primary" disabled={loading}>
                        {loading ? 'Adding...' : 'Add Product'}
                      </button>
                      <button type="button" className="btn btn-secondary" onClick={handleCancelAdd}>
                        Cancel
                      </button>
                    </div>
                  </form>
                </div>
              )}

              {/* Edit Product Form */}
              {showEditForm && editingProduct && (
                <div className="add-product-form edit-product-form" ref={editFormRef}>
                  <h3 className="form-title">Edit Product: {editingProduct.name}</h3>
                  <form onSubmit={handleUpdateProduct}>
                    <div className="form-grid">
                      <div className="form-group">
                        <label className="form-label">Product Name *</label>
                        <input
                          type="text"
                          name="name"
                          value={productForm.name}
                          onChange={handleFormInputChange}
                          className="form-input"
                          required
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">Brand *</label>
                        <input
                          type="text"
                          name="brand"
                          value={productForm.brand}
                          onChange={handleFormInputChange}
                          className="form-input"
                          required
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">Category *</label>
                        <select
                          name="category"
                          value={productForm.category}
                          onChange={handleFormInputChange}
                          className="form-select"
                          required
                        >
                          <option value="">Select category</option>
                          {categories.map(cat => (
                            <option key={cat.name} value={cat.name}>
                              {cat.displayName}
                            </option>
                          ))}
                        </select>
                      </div>

                      <div className="form-group">
                        <label className="form-label">Nutri-Score</label>
                        <div className="nutri-score-current">
                          <div className="nutri-score-badge current">
                            <span 
                              className="nutri-score-letter" 
                              style={{ backgroundColor: getNutriScoreColor(editingProduct?.rating || 'E') }}
                            >
                              {editingProduct?.rating || 'E'}
                            </span>
                            <div className="nutri-score-info">
                              <span className="nutri-score-label">Current Score</span>
                              <small className="nutri-score-note">Will update on save</small>
                            </div>
                          </div>
                          {editingProduct?.nutritionFacts && (
                            <div className="nutri-score-breakdown">
                              <div className="breakdown-header">
                                <span>Nutritional Values</span>
                              </div>
                              <div className="breakdown-item">
                                <span className="breakdown-label">Calories:</span>
                                <span className="breakdown-value">{editingProduct.nutritionFacts.calories || 0}</span>
                              </div>
                              <div className="breakdown-item">
                                <span className="breakdown-label">Sugar:</span>
                                <span className="breakdown-value">{editingProduct.nutritionFacts.sugar || 0}g</span>
                              </div>
                              <div className="breakdown-item">
                                <span className="breakdown-label">Fat:</span>
                                <span className="breakdown-value">{editingProduct.nutritionFacts.fat || 0}g</span>
                              </div>
                              <div className="breakdown-item positive">
                                <span className="breakdown-label">Fiber:</span>
                                <span className="breakdown-value">{editingProduct.nutritionFacts.fiber || 0}g</span>
                              </div>
                              <div className="breakdown-item positive">
                                <span className="breakdown-label">Protein:</span>
                                <span className="breakdown-value">{editingProduct.nutritionFacts.protein || 0}g</span>
                              </div>
                            </div>
                          )}
                        </div>
                      </div>

                      <div className="form-group form-group-full">
                        <label className="form-label">Description</label>
                        <textarea
                          name="description"
                          value={productForm.description}
                          onChange={handleFormInputChange}
                          className="form-textarea"
                          rows="3"
                          placeholder="Product description..."
                        />
                      </div>

                      <div className="form-group">
                        <label className="form-label">Price (₹)</label>
                        <input
                          type="number"
                          name="price"
                          value={productForm.price}
                          onChange={handleFormInputChange}
                          className="form-input"
                          min="0"
                          step="0.01"
                        />
                      </div>

                      <div className="form-group form-group-full">
                        <label className="form-label">Ingredients</label>
                        <input
                          type="text"
                          name="ingredients"
                          value={productForm.ingredients}
                          onChange={handleFormInputChange}
                          className="form-input"
                          placeholder="Comma-separated ingredients..."
                        />
                      </div>

                      <div className="nutrition-section">
                        <h4 className="nutrition-title">Nutrition Facts</h4>
                        <div className="nutrition-grid">
                          <div className="form-group">
                            <label className="form-label">Calories</label>
                            <input
                              type="number"
                              name="nutrition_calories"
                              value={productForm.nutritionFacts.calories}
                              onChange={handleFormInputChange}
                              className="form-input"
                              min="0"
                            />
                          </div>

                          <div className="form-group">
                            <label className="form-label">Protein (g)</label>
                            <input
                              type="number"
                              name="nutrition_protein"
                              value={productForm.nutritionFacts.protein}
                              onChange={handleFormInputChange}
                              className="form-input"
                              min="0"
                              step="0.1"
                            />
                          </div>

                          <div className="form-group">
                            <label className="form-label">Carbs (g)</label>
                            <input
                              type="number"
                              name="nutrition_carbs"
                              value={productForm.nutritionFacts.carbs}
                              onChange={handleFormInputChange}
                              className="form-input"
                              min="0"
                              step="0.1"
                            />
                          </div>

                          <div className="form-group">
                            <label className="form-label">Fat (g)</label>
                            <input
                              type="number"
                              name="nutrition_fat"
                              value={productForm.nutritionFacts.fat}
                              onChange={handleFormInputChange}
                              className="form-input"
                              min="0"
                              step="0.1"
                            />
                          </div>

                          <div className="form-group">
                            <label className="form-label">Fiber (g)</label>
                            <input
                              type="number"
                              name="nutrition_fiber"
                              value={productForm.nutritionFacts.fiber}
                              onChange={handleFormInputChange}
                              className="form-input"
                              min="0"
                              step="0.1"
                            />
                          </div>

                          <div className="form-group">
                            <label className="form-label">Sugar (g)</label>
                            <input
                              type="number"
                              name="nutrition_sugar"
                              value={productForm.nutritionFacts.sugar}
                              onChange={handleFormInputChange}
                              className="form-input"
                              min="0"
                              step="0.1"
                            />
                          </div>
                        </div>
                      </div>
                    </div>

                    <div className="form-actions">
                      <button type="submit" className="btn btn-primary" disabled={loading}>
                        {loading ? 'Updating...' : 'Update Product'}
                      </button>
                      <button type="button" className="btn btn-secondary" onClick={handleCancelEdit}>
                        Cancel
                      </button>
                    </div>
                  </form>
                </div>
              )}
            </div>

            {/* Products List */}
            <div className="admin-section">
              <h3 className="section-title">All Products</h3>
              {loading ? (
                <div className="loading">Loading products...</div>
              ) : products.length > 0 ? (
                <div className="products-grid">
                  {products.map(product => (
                    <ProductCard 
                      key={product._id} 
                      product={product} 
                      isAdmin={true}
                      onEdit={handleEditProduct}
                      onDelete={handleDeleteProduct}
                    />
                  ))}
                </div>
              ) : (
                <div className="no-products">
                  <p>No products found. Add some products to get started!</p>
                </div>
              )}
            </div>
          </div>
        )}

        {activeTab === 'analytics' && (
          <div className="tab-content">
            <div className="admin-section">
              <h2 className="section-title">Product Analytics</h2>
              
              {/* Rating Distribution */}
              <div className="analytics-grid">
                {ratings.map(rating => {
                  const ratingProducts = getProductsByRating(rating.code);
                  return (
                    <div key={rating.code} className="analytics-card">
                      <div 
                        className="rating-badge-large"
                        style={{ backgroundColor: rating.color }}
                      >
                        <span className="rating-letter">{rating.code}</span>
                        <span className="rating-name">{rating.name}</span>
                      </div>
                      <div className="analytics-data">
                        <span className="analytics-count">{ratingProducts.length}</span>
                        <span className="analytics-label">Products</span>
                      </div>
                    </div>
                  );
                })}
              </div>

              {/* Category Distribution */}
              <div className="analytics-section">
                <h3 className="analytics-title">Products by Category</h3>
                <div className="category-analytics">
                  {categories.map(category => {
                    const categoryProducts = products.filter(p => p.category === category.name);
                    return (
                      <div key={category.name} className="category-stat">
                        <span className="category-name">{category.displayName}</span>
                        <span className="category-count">{categoryProducts.length} products</span>
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default AdminPanel;
