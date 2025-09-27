import axios from 'axios';

// Create axios instance with base configuration
const baseURL = process.env.REACT_APP_API_URL || 'http://localhost:8051';

const api = axios.create({
  baseURL,
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: true,
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

// Response interceptor to handle auth errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    // Only auto-redirect on 401 for non-auth API calls
    // Let AuthContext handle session validation errors properly
    if (error.response?.status === 401 && 
        !error.config?.url?.includes('/auth.cfm/validate') &&
        !error.config?.url?.includes('/auth.cfm/me')) {
      // Unauthorized - clear session
      localStorage.removeItem('sessionId');
      // Optionally redirect to login
      if (window.location.pathname !== '/login' && window.location.pathname !== '/register') {
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);

export const authService = {
  async login(email, password) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 2000);
      
      const response = await api.post('/api/auth.cfm/login', {
        email,
        password
      }, {
        signal: controller.signal
      });
      clearTimeout(timeoutId);
      return response.data;
    } catch (error) {
      console.error('❌ Login API call failed:', error.message);
      return {
        success: false,
        error: 'Login failed. Please check your connection and try again.'
      };
    }
  },

  async register(userData) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 2000);
      
      const response = await api.post('/api/auth.cfm/register', userData, {
        signal: controller.signal
      });
      clearTimeout(timeoutId);
      return response.data;
    } catch (error) {
      console.error('❌ Register API call failed:', error.message);
      return {
        success: false,
        error: 'Registration failed. Please check your connection and try again.'
      };
    }
  },

  async logout(sessionId) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 2000);
      
      const response = await api.post('/api/auth.cfm/logout', { sessionId }, {
        signal: controller.signal
      });
      clearTimeout(timeoutId);
      return response.data;
    } catch (error) {
      console.error('❌ Logout API call failed:', error.message);
      // Clear local session even if server logout fails
      localStorage.removeItem('sessionId');
      return { 
        success: true,
        message: 'Logged out locally (server may be unavailable)'
      };
    }
  },

  async validateSession(sessionId) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 2000);
      
      const response = await api.get('/api/auth.cfm/validate', {
        signal: controller.signal
      });
      clearTimeout(timeoutId);
      return response.data;
    } catch (error) {
      console.error('❌ Session validation API call failed:', error.message);
      return {
        success: false,
        error: 'Session validation failed. Please login again.'
      };
    }
  },

  async getCurrentUser() {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 2000);
      
      const response = await api.get('/api/auth.cfm/me', {
        signal: controller.signal
      });
      clearTimeout(timeoutId);
      return response.data;
    } catch (error) {
      console.error('❌ Get current user API call failed:', error.message);
      return {
        success: false,
        error: 'Failed to get user info. Please login again.'
      };
    }
  }
};
