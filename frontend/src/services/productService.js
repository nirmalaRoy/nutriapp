import axios from 'axios';

// Create axios instance with base configuration
const baseURL = process.env.REACT_APP_API_URL || 'http://localhost:8051';

const api = axios.create({
  baseURL,
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: false, // Changed to false to avoid CORS issues
  timeout: 10000, // 10 second timeout
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const sessionId = localStorage.getItem('sessionId');
    if (sessionId) {
      config.headers.Authorization = `Bearer ${sessionId}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Removed mock data helper functions - now using MySQL backend


export const productService = {
  async searchProducts(params = {}) {
    try {
      
      // Use simple fetch like our working test
      const queryString = new URLSearchParams(params).toString();
      const url = `http://localhost:8051/api/products.cfm?${queryString}`;
      
      const response = await fetch(url);
      const data = await response.json();
      
      return data;
    } catch (error) {
      console.error('❌ Search API call failed:', error.message);
      return {
        success: false,
        error: 'Failed to search products. Please check your connection.',
        products: [],
        total: 0
      };
    }
  },

  async getAllProducts(params = {}) {
    try {
      
      // Use simple fetch like our working test
      const queryString = new URLSearchParams(params).toString();
      const url = `http://localhost:8051/api/products.cfm?${queryString}`;
      
      const response = await fetch(url);
      const data = await response.json();
      
      return data;
    } catch (error) {
      console.error('❌ Get products API call failed:', error.message);
      return {
        success: false,
        error: 'Failed to load products. Please check your connection.',
        products: [],
        total: 0
      };
    }
  },

  async getProduct(id) {
    try {
      
      const url = `http://localhost:8051/api/products.cfm?pathInfo=/${id}`;
      
      const response = await fetch(url);
      const data = await response.json();
      
      return data;
    } catch (error) {
      console.error('❌ Get product API call failed:', error.message);
      return {
        success: false,
        error: 'Failed to load product. Please check your connection.'
      };
    }
  },

  async getProductSuggestions(id) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 2000);
      
      const response = await api.get(`/api/products.cfm?pathInfo=/suggestions/${id}`, {
        signal: controller.signal
      });
      clearTimeout(timeoutId);
      return response.data;
    } catch (error) {
      console.error('❌ Get product suggestions API call failed:', error.message);
      return {
        success: false,
        error: 'Failed to load product suggestions. Please check your connection.'
      };
    }
  },

  async addProduct(productData) {
    try {
      
      const url = 'http://localhost:8051/api/products.cfm';
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(productData)
      });
      
      const data = await response.json();
      return data;
    } catch (error) {
      console.error('❌ Backend add failed:', error);
      return {
        success: false,
        error: 'Failed to add product. Please check your connection.'
      };
    }
  },

  async updateProduct(id, productData) {
    try {
      
      const url = `http://localhost:8051/api/products.cfm?pathInfo=/${id}`;
      const response = await fetch(url, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(productData)
      });
      
      const data = await response.json();
      return data;
    } catch (error) {
      console.error('❌ Backend update failed:', error);
      return {
        success: false,
        error: 'Failed to update product. Please check your connection.'
      };
    }
  },

  async deleteProduct(id) {
    try {
      
      const url = `http://localhost:8051/api/products.cfm?pathInfo=/${id}`;
      const response = await fetch(url, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
        }
      });
      
      const data = await response.json();
      return data;
    } catch (error) {
      console.error('❌ Backend delete failed:', error);
      return {
        success: false,
        error: 'Failed to delete product. Please check your connection.'
      };
    }
  },

  async getCategories() {
    try {
      
      const url = 'http://localhost:8051/api/products.cfm?pathInfo=/categories';
      
      const response = await fetch(url);
      const data = await response.json();
      
      return data;
    } catch (error) {
      console.error('❌ Get categories API call failed:', error.message);
      return {
        success: false,
        error: 'Failed to load categories. Please check your connection.',
        categories: []
      };
    }
  },

  async getRatings() {
    try {
      
      const url = 'http://localhost:8051/api/products.cfm?pathInfo=/ratings';
      
      const response = await fetch(url);
      const data = await response.json();
      
      return data;
    } catch (error) {
      console.error('❌ Get ratings API call failed:', error.message);
      return {
        success: false,
        error: 'Failed to load ratings. Please check your connection.',
        ratings: []
      };
    }
  }
};
