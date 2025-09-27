import React, { useState } from 'react';
import { productService } from '../services/productService';

const ApiTest = () => {
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);

  const testConnection = async () => {
    setLoading(true);
    setResult(null);
    
    try {
      console.log('🔍 Testing API connection from React...');
      const response = await productService.getAllProducts({ limit: 3 });
      
      console.log('✅ React API Response:', response);
      setResult({
        success: true,
        data: response
      });
    } catch (error) {
      console.error('❌ React API Error:', error);
      setResult({
        success: false,
        error: error.message
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ padding: '20px', border: '2px solid #ccc', margin: '20px' }}>
      <h2>🔧 React API Connection Test</h2>
      
      <button 
        onClick={testConnection} 
        disabled={loading}
        style={{ 
          padding: '10px 20px', 
          fontSize: '16px',
          backgroundColor: loading ? '#ccc' : '#4CAF50',
          color: 'white',
          border: 'none',
          borderRadius: '4px',
          cursor: loading ? 'not-allowed' : 'pointer'
        }}
      >
        {loading ? '🔄 Testing...' : '🧪 Test API Connection'}
      </button>

      {result && (
        <div style={{ 
          marginTop: '20px', 
          padding: '15px', 
          backgroundColor: result.success ? '#e8f5e8' : '#ffe8e8',
          border: `1px solid ${result.success ? '#4CAF50' : '#f44336'}`,
          borderRadius: '4px'
        }}>
          {result.success ? (
            <div>
              <h3>✅ SUCCESS!</h3>
              <p><strong>API Working:</strong> {result.data.success ? 'Yes' : 'No'}</p>
              <p><strong>Products Found:</strong> {result.data.products?.length || 0}</p>
              <p><strong>Total in Database:</strong> {result.data.total}</p>
              <p><strong>Source:</strong> {result.data.source || 'Unknown'}</p>
              {result.data.products?.length > 0 && (
                <p><strong>First Product:</strong> {result.data.products[0].name}</p>
              )}
            </div>
          ) : (
            <div>
              <h3>❌ ERROR</h3>
              <p><strong>Error:</strong> {result.error}</p>
              <p>Check the browser console for more details.</p>
            </div>
          )}
        </div>
      )}
      
      <div style={{ 
        marginTop: '10px', 
        fontSize: '12px', 
        color: '#666',
        fontFamily: 'monospace'
      }}>
        Backend URL: http://localhost:8051/api/products.cfm
      </div>
    </div>
  );
};

export default ApiTest;
