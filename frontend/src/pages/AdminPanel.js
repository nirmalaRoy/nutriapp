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
    rating: '',
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
        rating: productForm.rating,
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
      rating: '',
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
      rating: product.rating || '',
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
                        <label className="form-label">Rating *</label>
                        <select
                          name="rating"
                          value={productForm.rating}
                          onChange={handleFormInputChange}
                          className="form-select"
                          required
                        >
                          <option value="">Select Rating</option>
                          {ratings.map(rating => (
                            <option key={rating.code} value={rating.code}>
                              {rating.code} - {rating.name}
                            </option>
                          ))}
                        </select>
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
                        <label className="form-label">Rating *</label>
                        <select
                          name="rating"
                          value={productForm.rating}
                          onChange={handleFormInputChange}
                          className="form-select"
                          required
                        >
                          <option value="">Select rating</option>
                          {ratings.map(rating => (
                            <option key={rating.code} value={rating.code}>
                              {rating.code} - {rating.name}
                            </option>
                          ))}
                        </select>
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
