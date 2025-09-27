import React, { useState, useEffect } from 'react';

const SimpleFetchTest = () => {
  const [result, setResult] = useState('Testing...');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    testSimpleFetch();
  }, []);

  const testSimpleFetch = async () => {
    setIsLoading(true);
    setResult('🔄 Testing connection...');
    
    try {
      console.log('🧪 Starting simple fetch test...');
      
      // Use the simplest possible fetch
      const response = await fetch('http://localhost:8051/api/products.cfm?limit=2');
      
      console.log('📡 Response received:', {
        ok: response.ok,
        status: response.status,
        statusText: response.statusText,
        headers: response.headers
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      console.log('✅ Data parsed successfully:', data);
      
      setResult(`✅ SUCCESS! Found ${data.total} products from ${data.source}`);
      
    } catch (error) {
      console.error('❌ Simple fetch failed:', error);
      
      if (error.name === 'TypeError' && error.message.includes('Failed to fetch')) {
        setResult('❌ CORS Error: Cannot connect to backend (likely CORS policy blocking)');
      } else if (error.message.includes('JSON')) {
        setResult('❌ JSON Parse Error: Backend returned invalid JSON');
      } else {
        setResult(`❌ Error: ${error.message}`);
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div style={{ 
      padding: '15px', 
      margin: '10px 0',
      border: '2px solid #e74c3c', 
      borderRadius: '5px',
      backgroundColor: '#ffeaea',
      fontFamily: 'monospace'
    }}>
      <h3 style={{ margin: '0 0 10px 0', color: '#c0392b' }}>🚨 SIMPLE FETCH TEST</h3>
      
      <div style={{ 
        padding: '10px', 
        backgroundColor: isLoading ? '#fff3cd' : (result.includes('SUCCESS') ? '#d4edda' : '#f8d7da'),
        border: '1px solid ' + (isLoading ? '#ffeaa7' : (result.includes('SUCCESS') ? '#c3e6cb' : '#f5c6cb')),
        borderRadius: '3px',
        marginBottom: '10px'
      }}>
        <strong>Result:</strong> {result}
      </div>
      
      <button 
        onClick={testSimpleFetch}
        disabled={isLoading}
        style={{
          padding: '8px 16px',
          backgroundColor: isLoading ? '#ccc' : '#e74c3c',
          color: 'white',
          border: 'none',
          borderRadius: '3px',
          cursor: isLoading ? 'not-allowed' : 'pointer'
        }}
      >
        {isLoading ? '🔄 Testing...' : '🔄 Test Again'}
      </button>
      
      <div style={{ fontSize: '12px', marginTop: '10px', color: '#666' }}>
        <strong>Instructions:</strong><br/>
        1. Open browser console (F12)<br/>
        2. Click "Test Again" and watch console output<br/>
        3. Share any red error messages you see
      </div>
    </div>
  );
};

export default SimpleFetchTest;
