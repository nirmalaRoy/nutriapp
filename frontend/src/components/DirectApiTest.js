import React, { useState, useEffect } from 'react';

const DirectApiTest = () => {
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);

  // Auto-test on component mount
  useEffect(() => {
    testDirectConnection();
  }, []);

  const testDirectConnection = async () => {
    setLoading(true);
    setResult(null);
    
    try {
      console.log('🔍 Testing DIRECT fetch from React component...');
      
      // Use direct fetch to bypass any axios issues
      const response = await fetch('http://localhost:8051/api/products.cfm?limit=3');
      const data = await response.json();
      
      console.log('✅ Direct fetch Response:', data);
      setResult({
        success: true,
        data: data,
        method: 'Direct Fetch'
      });
    } catch (error) {
      console.error('❌ Direct fetch Error:', error);
      setResult({
        success: false,
        error: error.message,
        method: 'Direct Fetch'
      });
    } finally {
      setLoading(false);
    }
  };

  const testAxiosConnection = async () => {
    setLoading(true);
    setResult(null);
    
    // Import axios dynamically to avoid issues
    const axios = await import('axios');
    
    try {
      console.log('🔍 Testing axios from React component...');
      
      const response = await axios.default.get('http://localhost:8051/api/products.cfm?limit=3', {
        headers: {
          'Content-Type': 'application/json',
        },
        timeout: 10000,
        withCredentials: false
      });
      
      console.log('✅ Axios Response:', response.data);
      setResult({
        success: true,
        data: response.data,
        method: 'Axios'
      });
    } catch (error) {
      console.error('❌ Axios Error:', error);
      setResult({
        success: false,
        error: error.message,
        details: error.response?.data || 'No response data',
        method: 'Axios'
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ 
      padding: '20px', 
      border: '3px solid #ff6b35', 
      margin: '20px',
      backgroundColor: '#fff5f0',
      borderRadius: '8px'
    }}>
      <h2 style={{ color: '#ff6b35' }}>🚨 DIRECT API CONNECTION TEST</h2>
      
      <div style={{ marginBottom: '20px' }}>
        <button 
          onClick={testDirectConnection} 
          disabled={loading}
          style={{ 
            padding: '10px 20px', 
            fontSize: '16px',
            backgroundColor: loading ? '#ccc' : '#ff6b35',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: loading ? 'not-allowed' : 'pointer',
            marginRight: '10px'
          }}
        >
          {loading ? '🔄 Testing...' : '🧪 Test Direct Fetch'}
        </button>

        <button 
          onClick={testAxiosConnection} 
          disabled={loading}
          style={{ 
            padding: '10px 20px', 
            fontSize: '16px',
            backgroundColor: loading ? '#ccc' : '#35a7ff',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: loading ? 'not-allowed' : 'pointer'
          }}
        >
          {loading ? '🔄 Testing...' : '🔧 Test Axios'}
        </button>
      </div>

      {result && (
        <div style={{ 
          marginTop: '20px', 
          padding: '15px', 
          backgroundColor: result.success ? '#e8f5e8' : '#ffe8e8',
          border: `2px solid ${result.success ? '#4CAF50' : '#f44336'}`,
          borderRadius: '4px'
        }}>
          {result.success ? (
            <div>
              <h3 style={{ color: '#2e7d32' }}>✅ {result.method} SUCCESS!</h3>
              <p><strong>API Working:</strong> {result.data.success ? 'Yes' : 'No'}</p>
              <p><strong>Products Found:</strong> {result.data.products?.length || 0}</p>
              <p><strong>Total in Database:</strong> {result.data.total}</p>
              <p><strong>Source:</strong> {result.data.source || 'Unknown'}</p>
              {result.data.products?.length > 0 && (
                <div>
                  <p><strong>First Product:</strong> {result.data.products[0].name}</p>
                  <p><strong>Brand:</strong> {result.data.products[0].brand}</p>
                  <p><strong>Category:</strong> {result.data.products[0].category}</p>
                </div>
              )}
            </div>
          ) : (
            <div>
              <h3 style={{ color: '#c62828' }}>❌ {result.method} ERROR</h3>
              <p><strong>Error:</strong> {result.error}</p>
              {result.details && (
                <p><strong>Details:</strong> {JSON.stringify(result.details)}</p>
              )}
              <p style={{ color: '#666', fontSize: '14px' }}>
                Check browser console (F12) for more details.
              </p>
            </div>
          )}
        </div>
      )}
      
      <div style={{ 
        marginTop: '15px', 
        fontSize: '12px', 
        color: '#666',
        fontFamily: 'monospace',
        backgroundColor: '#f5f5f5',
        padding: '10px',
        borderRadius: '4px'
      }}>
        <div><strong>Backend URL:</strong> http://localhost:8051/api/products.cfm</div>
        <div><strong>Expected Result:</strong> 24 products from MySQL</div>
        <div><strong>React App URL:</strong> http://localhost:3000</div>
      </div>
    </div>
  );
};

export default DirectApiTest;
