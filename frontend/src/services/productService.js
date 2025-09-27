import axios from 'axios';

// Create axios instance with base configuration
const baseURL = process.env.REACT_APP_API_URL || 'http://localhost:8051';
console.log('🔧 ProductService API Configuration:', {
  baseURL,
  envVar: process.env.REACT_APP_API_URL,
  NODE_ENV: process.env.NODE_ENV
});

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

// Test backend connectivity function (for debugging)
const testBackendConnectivity = async () => {
  try {
    console.log('🧪 Testing backend connectivity...');
    const response = await fetch('http://localhost:8051/api/products.cfm?limit=1');
    const data = await response.json();
    console.log('✅ Backend connection successful:', data);
    return data;
  } catch (error) {
    console.error('❌ Backend connection failed:', error.message);
    return { success: false, error: error.message };
  }
};

// Make test function available globally for browser console debugging
window.testBackend = testBackendConnectivity;

export const productService = {
  async searchProducts(params = {}) {
    try {
      console.log('🔍 SearchProducts called with params:', params);
      
      // Use simple fetch like our working test
      const queryString = new URLSearchParams(params).toString();
      const url = `http://localhost:8051/api/products.cfm?${queryString}`;
      console.log('📡 Making request to:', url);
      
      const response = await fetch(url);
      const data = await response.json();
      
      console.log('✅ SearchProducts response:', data);
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
      console.log('📋 GetAllProducts called with params:', params);
      
      // Use simple fetch like our working test
      const queryString = new URLSearchParams(params).toString();
      const url = `http://localhost:8051/api/products.cfm?${queryString}`;
      console.log('📡 Making request to:', url);
      
      const response = await fetch(url);
      const data = await response.json();
      
      console.log('✅ GetAllProducts response:', data);
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
      console.log('📄 GetProduct called with id:', id);
      
      const url = `http://localhost:8051/api/products.cfm?pathInfo=/${id}`;
      console.log('📡 Making request to:', url);
      
      const response = await fetch(url);
      const data = await response.json();
      
      console.log('✅ GetProduct response:', data);
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
      console.log('➕ Attempting to add product via backend API:', productData.name);
      
      const url = 'http://localhost:8051/api/products.cfm';
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(productData)
      });
      
      const data = await response.json();
      console.log('✅ Backend add successful:', data);
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
      console.log('🔄 Attempting to update product via backend API:', id);
      
      const url = `http://localhost:8051/api/products.cfm?pathInfo=/${id}`;
      const response = await fetch(url, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(productData)
      });
      
      const data = await response.json();
      console.log('✅ Backend update successful:', data);
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
      console.log('🗑️ Attempting to delete product via backend API:', id);
      
      const url = `http://localhost:8051/api/products.cfm?pathInfo=/${id}`;
      const response = await fetch(url, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
        }
      });
      
      const data = await response.json();
      console.log('✅ Backend delete successful:', data);
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
      console.log('📂 GetCategories called');
      
      const url = 'http://localhost:8051/api/products.cfm?pathInfo=/categories';
      console.log('📡 Making request to:', url);
      
      const response = await fetch(url);
      const data = await response.json();
      
      console.log('✅ GetCategories response:', data);
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
      console.log('⭐ GetRatings called');
      
      const url = 'http://localhost:8051/api/products.cfm?pathInfo=/ratings';
      console.log('📡 Making request to:', url);
      
      const response = await fetch(url);
      const data = await response.json();
      
      console.log('✅ GetRatings response:', data);
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
